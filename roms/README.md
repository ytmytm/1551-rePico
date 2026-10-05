# 1551 DOS ROM images

Burn a **64 KB** image into the board’s **27C512 / 27E512** (socket U5). Jumper **J2** selects which 32 KB half is mapped.

These files are the same deliverables documented by **[1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard)** (RAM/ROM expansion map used on this board: `$0000–$3FFF` + `$8000–$9FFF` RAM, `$A000–$FFFF` ROM). Prefer the patched upper bank together with **[Parobek](https://github.com/ytmytm/plus4-parobek)** for the HypaRAM / track-cache fastloader.

## What to program (recommended)

| File | Size | Use |
|------|------|-----|
| [`1551.318008-01-64k.bin`](1551.318008-01-64k.bin) | 64K | Stock 1551 DOS (318008-01): lower half = unpatched base, upper half = RAMBOard patch |
| [`super_dos_1551-64k.bin`](super_dos_1551-64k.bin) | 64K | SuperDOS (40-track) + same RAMBOard patch in the upper half |

Leave **J2** so the **upper** (patched) half is selected for normal use. Details: [1551-RAMBOard README](https://github.com/ytmytm/1551-RAMBOard).

## 32K / 16K copies (same payloads, shorter names)

Copied from a Pi1551 SD card tree; byte-identical to the RAMBOard outputs under the names used there:

| File | Size | Same as |
|------|------|---------|
| [`dos1551-ram.bin`](dos1551-ram.bin) | 32K | `1551.318008-01-patched.bin` (upper half of the 64K stock image) |
| [`1551.318008-01-patched.bin`](1551.318008-01-patched.bin) | 32K | RAMBOard patched stock DOS |
| [`super_dos_ram.bin`](super_dos_ram.bin) | 32K | `super_dos_1551-patched.bin` |
| [`super_dos_1551-patched.bin`](super_dos_1551-patched.bin) | 32K | RAMBOard patched SuperDOS |
| [`dos1551.bin`](dos1551.bin) | 16K | Stock 1551 DOS base ([zimmers.net 318008-01](https://www.zimmers.net/anonftp/pub/cbm/firmware/drives/new/1551/1551.318008-01.bin)) |
| [`super_dos_1551.rom`](super_dos_1551.rom) | 16K | SuperDOS 1551 ([plus4world](https://plus4world.powweb.com/dl/utils/s/super_dos_1551.rom)) |

## Provenance

- Patch / 64K packing / build steps: [ytmytm/1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard)
- Stock 1551 ROM: Commodore 318008-01 (via zimmers.net, as linked from RAMBOard)
- SuperDOS: plus4world `super_dos_1551.rom` (as linked from RAMBOard)
- Local copies of the shorter names came from a Pi1551 `sdcard/` tree; the `*-64k.bin` / `*-patched.bin` files match the RAMBOard First Bank build outputs

Rebuild yourself with the RAMBOard `Makefile` / Releases if you need a fresh binary.
