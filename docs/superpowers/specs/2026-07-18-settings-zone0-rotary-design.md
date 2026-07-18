# Settings: zone0 timing, reverse rotary, flash save/load

**Date:** 2026-07-18  
**Status:** approved for implementation planning  
**Target:** 1551-rePico / 1541-rePico OLED Settings menu

## Goal

Add runtime-tunable Settings for zone-0 GCR byte timer and sector gap, reverse rotary direction, explicit flash Save/Load, auto-load on boot when a valid save exists, and fix the non-functional Restart item.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Persistence | Pico flash; only when user Saves |
| Boot | Auto-load if valid flash blob; else firmware defaults |
| Numeric edit | Select line → short press enters edit → rotary adjusts → short press or long-back exits |
| Apply while image mounted | Timer live; gap rebuilds GCR for D64/PRG/selector; G64 gap stored for later only |
| Reverse rotary | On/Off toggle; immediate |
| Restart | Real soft reboot (`watchdog_reboot` or equivalent) |

## Settings menu layout

```
..
Z0 timer   <nn>[*]
Z0 gap     <nn>[*]
Rev rotary On|Off
Load settings
Save settings
Restart
```

- `*` suffix when timer is 26 or 28, or gap is 12 or 21.
- Bounds: timer **24–36** µs; gap **8–28** bytes.
- Defaults: build defaults from `globals.c` (REPICO1551: 28/21; else 26/12). Reverse default Off.

## Editing UX

1. Rotary moves cursor among Settings lines (unchanged).
2. Short press on `ENTRY_8BIT_DEC` (timer/gap): enter edit mode (visual focus on value).
3. While editing: rotary increments/decrements within bounds; does not move menu cursor.
4. Short press again or long-press-back: exit edit, keep value, run apply.
5. `Rev rotary` (`ENTRY_ONOFF`): short press toggles; apply immediately.
6. `Load settings` / `Save settings`: run action, brief OLED status, refresh Settings.
7. `Restart`: soft reboot (picks up auto-load of last Save).

## Runtime data model

Mutable zone-0 overlays (zones 1–3 remain fixed compile-time values):

- `zone0_timer_us` → drives `bytetimer_values[0]` (array becomes non-`const` or overlay read path)
- `zone0_gap` → drives `d64_sector_gap[0]`
- `rotary_reversed` → negates detent sign when translating `rotary_delta` to KEY0/KEY1

Apply on change / Load:

1. Write runtime vars into the arrays/flags used by emulation.
2. If image spinning: `start_bytetimer(akt_half_track)`.
3. If gap changed and mounted type is D64, PRG, or selector: reconvert affected tracks to GCR using current gap.
4. If mounted type is G64: do not rewrite track RAM for gap; timer still restarts. Gap value remains for future D64/PRG/selector loads.

## Flash format

Fixed location near end of flash (Pico/RP2350-safe offset, erase-unit aligned).

| Field | Size | Notes |
|-------|------|-------|
| magic | 4 | `'R','4','S','T'` |
| version | 1 | `1` |
| zone0_timer_us | 1 | |
| zone0_gap | 1 | |
| rotary_reversed | 1 | 0/1 |
| reserved | 1 | 0 |
| crc16 | 2 | over all preceding bytes |

- **Save:** write current runtime; show `Saved` or `Save fail`.
- **Load:** validate magic/version/CRC/bounds; on success apply; show `Loaded` or `No save`.
- **Boot:** same as Load, silent on failure (keep defaults).

## Architecture / files

| File | Change |
|------|--------|
| `firmware/include/mymenu.h` | New IDs and Settings entries |
| `firmware/include/menu.h`, `firmware/src/menu.c` | Implement `ENTRY_8BIT_DEC` edit mode; render value + `*` |
| `firmware/src/globals.c`, `firmware/include/globals.h` | Mutable zone0 timer/gap; accessors |
| `firmware/src/settings.c`, `firmware/include/settings.h` (new) | Flash blob, CRC, save/load/boot, apply helpers |
| `firmware/src/main.c` | Menu wiring; rotary reverse; boot load; Restart reboot |
| `firmware/src/rw_routines.c` | Use runtime gap; reconvert helper for mounted non-G64 |
| `firmware/CMakeLists.txt` | Add `settings.c` |

## Out of scope

- Persisting settings on SD card
- Tuning zones 1–3 from the menu
- Rewriting G64 track data when gap changes
- Host-side unit tests (manual OLED verification)

## Test plan (manual)

1. Settings shows defaults with `*` on 28 and 21 (1551 build) or 26 and 12 (1541).
2. Edit timer/gap with rotary; clamps at bounds; `*` appears only on presets.
3. Reverse rotary swaps up/down in menus and file browser.
4. With D64 mounted, change gap → GCR rebuild; zone0 behavior changes without reload.
5. With G64 mounted, change gap → value stored; timer change applies live.
6. Save → reboot → settings restored.
7. Change values without Save → reboot → previous Save (or defaults) restored.
8. Load restores flash over unsaved tweaks.
9. Restart reboots the board.
