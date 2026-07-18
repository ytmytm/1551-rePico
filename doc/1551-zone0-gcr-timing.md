# 1551-rePico: zone 0 GCR timing (tracks 1–17)

**Status:** confirmed 2026-07-18 — keep both tweaks for `REPICO1551` builds.  
**Code:** `firmware/src/globals.c` (`bytetimer_values`, `d64_sector_gap`), gated on `#if REPICO1551`.

## Summary

Stock 1551 DOS (and some fastloaders) failed on densest tracks (speed zone 0, tracks 1–17) with the original 1541-rePico packing: **26 µs/byte** and **12** GCR gap bytes between sectors. Typical symptom: `23, READ ERROR, track, sector` (data-block checksum) while the directory on track 18 (zone 1) still worked.

**Keep for 1551:** zone 0 at **28 µs/byte** and sector gap **21** (same as zone 1).  
**1541 builds** stay at the original **26 µs / gap 12** until proven otherwise.

Offline D64→GCR encode/decode of failing sectors was correct; the issue is live capture timing (header → short gap → data), not corrupt image bytes.

## A/B results (REPICO1551)

| Config | Zone 0 timer | Zone 0 gap | Result |
|--------|--------------|------------|--------|
| Original | 26 µs | 12 | `LOAD "GEOS 3*"` → `23, READ ERROR, 11,17`; Carrion fastloader on tracks 1–8 still OK |
| Gap only | 26 µs | 21 | First GEOS load OK; later GEOS stages failed |
| Timer only | 28 µs | 12 | GEOS OK; **hypaload** and **qm_…** demos failed |
| **Both (keep)** | **28 µs** | **21** | Reliable — GEOS, hypaload, qm_ demos all pass |

Also useful contrast: Carrion starts on track 18 then fastloads zone 0 successfully with original timing — fastloaders can tolerate packing that stock DOS rejects.

## Emulation tradeoff

Zone 0 no longer matches a real drive’s fastest density band:

- Byte period matches zone 1 (28 µs).
- Inter-sector gaps match zone 1 (21 × `0x55`).
- Revolution time on tracks 1–17 is slightly longer than ~200 ms real (~220 ms with both tweaks).

GCR payload and checksums remain correct. Risk is mainly timing-sensitive protections or loaders that assume authentic zone-0 bitrate/RPM; none of the titles above required reverting.

## Related ISR notes (1551)

Separate from gap/timer, also done for 1551 bring-up:

- No `sleep_us(3)` on `BYTE_READY` pulse (CPLD latches on falling edge).
- PA bus direction set only on SO read/write mode change, not every byte.

See `hardware-1551-III-Pico/notes.txt` for session log.
