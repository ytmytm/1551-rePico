# conv_x64

Small host tool to convert between D64 and G64 image formats (round-trip through the same GCR structures the firmware uses).

## Main purpose

Originally for testing read/write paths in [1541-rePico](https://github.com/fook42/1541-rePico). Still useful here for checking D64/G64 images before putting them on an SD card for **1551-III-Pico** — the GCR layer is shared.

The supported product firmware lives in `../firmware-1551-III-pico/`; this tool is optional and not required to build or flash the drive.

## Usage

```text
conv_x64 <file_in> <file_out>
```

Extension of `file_in` (`.d64` or `.g64`) selects the reader; extension of `file_out` selects the writer.

## How to build

```bash
gcc -fcommon -o conv_x64 conv_x64.c gcr.c rw_tracks.c
```

Ignore the type-conversion warnings.

2026/02/14 - fook42
