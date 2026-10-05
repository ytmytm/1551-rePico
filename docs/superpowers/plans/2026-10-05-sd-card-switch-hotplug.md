# SD Card Switch Hotplug Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Debounced SD card-detect via 74HCT165 bit 5: eject unmounts image+FS (including when a disk is already mounted); insert remounts and rebuilds the Load Selector list; unwired CD still mounts at boot.

**Architecture:** Poll CD edges in `poll_shift_inputs`, queue a pending event, apply in the main loop via `sdcard_handle_cd_pending()` so work does not nest inside `service_tick` / `send_disk_change`.

**Tech Stack:** Pico SDK, FatFs (no-OS-FatFS), existing `shift165` + `unmount_image` / `mount_sdcard` / `insert_menu_image`.

## Global Constraints

- Do not refuse `f_mount` solely because CD is high (unwired socket).
- On eject with `is_image_mount`: always call `unmount_image()` (host disk-change); discard dirty tracks without saving.
- Debounce ~100 ms; polarity: inserted = CD low.

---

## File map

| File | Role |
|------|------|
| `firmware-1551-III-pico/src/main.c` | CD debounce, pending flag, eject/insert handlers, relax `mount_sdcard` |
| `hardware-1551-III-Pico/notes.txt` | Mark SD switch software done / behaviour note |
| `docs/superpowers/specs/2026-10-05-sd-card-switch-hotplug-design.md` | Spec (already written) |

---

### Task 1: CD edge detect + pending flag

**Files:** `firmware-1551-III-pico/src/main.c`

- [ ] Add `SD_CD_DEBOUNCE_US` (100000), `sd_cd_last_present`, `sd_cd_pending` (`none`/`ejected`/`inserted`), `sd_cd_busy`.
- [ ] In `init_key_inputs`, seed `sd_cd_last_present` from `shift165_sd_card_present()`.
- [ ] In `poll_shift_inputs`, on `SHIFT165_BIT_SD_CD` change after debounce, set `sd_cd_pending` (do not handle FS yet).
- [ ] Add `sdcard_handle_cd_pending()` stub called from `main()` after `service_tick()`.

### Task 2: Eject path (mounted image + FS)

- [ ] Implement eject: stop byte timer; clear `send_byte_ready` and `track_is_written`.
- [ ] If `is_image_mount`: `unmount_image()` (covers D64/G64/PRG/selector).
- [ ] Else: `close_disk_image(&fd)`.
- [ ] `f_closedir(&dir_object)`; `umount_sdcard()`; reset `current_path` and FB state.
- [ ] OLED `"SD card removed"`; `set_gui_mode(GUI_MENU_MODE)`.
- [ ] Guard with `sd_cd_busy` so nested `service_tick` during `send_disk_change` does not re-enter.

### Task 3: Insert path + mount_sdcard

- [ ] Remove hard `FR_NOT_READY` from `mount_sdcard` when CD high (try mount anyway).
- [ ] Insert: `mount_sdcard` (optional one retry after ~200 ms); on OK reset path to `/`, `set_gui_mode(GUI_SELECTOR)`.
- [ ] On fail: show existing mount error UI; stay in menu.

### Task 4: Notes + build check

- [ ] Update `hardware-1551-III-Pico/notes.txt` for SD switch handling.
- [ ] Build `firmware-1551-III-pico` if build dir exists; fix compile errors.
