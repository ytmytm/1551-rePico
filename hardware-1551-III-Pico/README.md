# 1551-III-Pico mainboard

KiCad project for the **horizontal main module** of [1551-rePico](../README.md): Pico2 + 6510T (or [MOS CPU Replacer](https://github.com/monotech/MOS_CPU_Replacer)) + XC9572XL CPLD + 32 KB SRAM + 64 KB EPROM. It replaces the Pi1551-III **Module-rotated** board and mates with the [Pi1551-III](https://github.com/ytmytm/Pi1551-III) front panel and faceplates.

Host connection is a ribbon cable to **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)** (same as Pi1551-III).

## Design files

| Artifact | Path |
|----------|------|
| KiCad project | this folder (`1551-III-Pico.kicad_pro`) |
| Schematic PDF | [`plots/1551-III-Pico.pdf`](plots/1551-III-Pico.pdf) |
| Gerbers / drills | [`plots/`](plots/) |
| JLCPCB-style fab pack | [`production/1551-III_Pico_2b.zip`](production/1551-III_Pico_2b.zip) |
| BOM / positions | [`production/bom.csv`](production/bom.csv), [`production/positions.csv`](production/positions.csv), [`production/designators.csv`](production/designators.csv) |

## Related firmware / CPLD / ROMs

- Firmware: [`../firmware-1551-III-pico/`](../firmware-1551-III-pico/)
- CPLD bitstream: [`../hdl-1551-III/Fake6523.jed`](../hdl-1551-III/Fake6523.jed) — flash notes in the [top-level README](../README.md#cpld)
- DOS EPROM images (27C512): [`../roms/`](../roms/) — see [1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard) for provenance and patch details
- Mechanical / panel BOM: **[Pi1551-III](https://github.com/ytmytm/Pi1551-III)**

## Notes

- Internal bring-up / review notes: [`notes.txt`](notes.txt), [`hardware-review.md`](hardware-review.md)
- ROM bank select on this board is jumper **J2** (two 32 KB halves of the 27C512). Prefer a [1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard) 64K image so the upper half is the RAM-expansion / fastloader patch.
- **JP1–JP3** (GPIO26–28 ↔ `74HCT165`): leave as shipped / default **1–2**. They were only a fallback so the Pico could talk to the front-panel encoder directly if the shift register failed; '165 works and current firmware expects that path — do not rewire them.
