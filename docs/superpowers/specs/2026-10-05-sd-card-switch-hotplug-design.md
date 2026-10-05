# SD card switch hotplug (1551-III-Pico)

**Date:** 2026-10-05  
**Status:** approved  
**Branch:** `feature/sd-card-switch-hotplug`  
**Reference:** tcbm2sd Arduino (`PIN_SD_CD`, debounce, `SD.end` / `reload_sd_card`)

## Goal

React to the microSD card-detect line (`/SD_CD` → 74HCT165 bit 5) so removing or inserting a card unmounts/remounts FatFs and rebuilds the Load Selector file list. Boards with no mechanical CD switch (line only pulled up by R28) must still mount at boot.

## Hardware

- Active-low: card inserted → `/SD_CD` low; removed / unwired → high via R28 to +3V3.
- Firmware already exposes `SHIFT165_BIT_SD_CD` and `shift165_sd_card_present()`.
- `hw_config.c` keeps `use_card_detect = false` (library CD unused; we poll the shift register).

## Behaviour

### Unwired CD (always high)

- Do **not** refuse `f_mount` solely because CD reads high.
- Hotplug runs only on **debounced edges** (~100 ms). A line that never changes never triggers eject/insert.

### Debounce

- Same idea as tcbm2sd: ignore transitions shorter than ~100 ms; share timing with other panel input debounce where practical.

### Eject (CD → removed)

Regardless of GUI mode:

1. Stop GCR byte timer; clear `send_byte_ready`.
2. **If a disk image is mounted** (`is_image_mount`, including D64/G64/PRG **or** the virtual selector image):
   - Discard unsaved track writes (`track_is_written = false`); do not auto-save.
   - Call existing `unmount_image()` so the host sees a disk change / empty drive (WPS pulse via `send_disk_change(true, false)`), FatFs file handle is closed, and mount flags are cleared.
3. Close any open directory (`f_closedir`).
4. `umount_sdcard()` (`f_unmount`), then mark the SPI card `STA_NOINIT` so the next mount re-runs `sd_init_medium` (without this, remount returns `FR_DISK_ERR`).
5. Reset browser path to `/` and clear file-browser cursor/count.
6. Show a short OLED message (`SD card removed`) and leave the UI in `GUI_MENU_MODE` (safe with no FS / no image).

### Insert (CD → present)

1. Wait ~250 ms for card contacts to settle, then `mount_sdcard()` (retry a few times).
2. On success: reset path to `/`, then `set_gui_mode(GUI_SELECTOR)` so `handle_selector_image()` → `insert_menu_image()` rebuilds the selector DATAFILE listing and presents a fresh virtual disk to the Plus/4.
3. On failure: show existing `f_mount` error path; stay in menu.

### Re-entrancy

- CD handling must not nest while `insert_menu_image` / `send_disk_change` already call `service_tick()`. Use a busy/pending flag: poll only records a pending edge; the main loop applies it when not already handling CD.

## Out of scope

- Auto-saving dirty D64 tracks on eject.
- GEOS desktop refresh quirks for 1A↔1B disk IDs (separate issue).
- Enabling no-OS-FatFS `use_card_detect` GPIO path.

## Success criteria

- Card out while a D64 (or selector) is mounted → host sees eject; OLED shows removed; no SPI/FatFs use until insert.
- Card in again → FS remounts; selector list rebuilt from new card root.
- Board without CD switch → boot mount still works; no spurious eject.
