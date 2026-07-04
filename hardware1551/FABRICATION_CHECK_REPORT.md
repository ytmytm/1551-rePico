# 1551-rePico Remaining Work Before Bring-Up

Date: 2026-07-03

This file now lists only the remaining or intentionally deferred items. Confirmed/done fabrication checks were removed to keep the report usable.

## Hardware/CPLD Before Programming

1. Rebuild/refit `Fake6523.jed`.
   - The old fitted artifacts used `soe_3v3` on `U3 P18`, while this PCB leaves `P18` unconnected.
   - Keep `Fake6523.v`, `Fake6523.ucf`, fitter output, and the final `.jed` together as the known-good programmed set.
   - Re-check byte-latch behavior after the new fit, especially `BYTE_READY_3V3`, `BYTE_LATCHED`, and `/~{CS_TPI}` clear timing.

2. Decide whether the future CPLD mode will use real CPU timing.
   - Current design uses gate-array `/XR{slash}~{W}` on `_write`.
   - `/R{slash}~{W}`, `/PHI2`, and `/PHI0` are already routed to CPLD pins for possible later use.

3. Keep the new experiment jumpers in their default positions for normal bring-up.
   - `JP2` default: board `PHI0_BRD` feeds the active `/PHI0` net.
   - `JP5`/`JP6` default: Pico `GPIO3` drives `/DEVNUM_3V3`, and board `/~{IRQ_BRD}` feeds `/~{IRQ}`.
   - `JP7` default ties the alternate DEVNUM source to `GND`, but it is isolated while `JP5` is in the default position.

## Firmware TODO

1. Update Pico firmware for the 1551 pin map.
   - `GPIO0`: normally isolated by `JP2`; can be switched in later to test a Pico-generated 2 MHz `PHI0`.
   - `GPIO1`: `/MODE_3V3`
   - `GPIO2`: `/SYNC_3V3`
   - `GPIO3`: normally `/DEVNUM_3V3`; can be switched later to test Pico-generated IRQ pulses.
   - `GPIO4`: `/MTR_3V3`
   - `GPIO5`: `/WPS_3V3`
   - `GPIO6`: `/STP0_3V3`
   - `GPIO7`: `/STP1_3V3`
   - `GPIO8..15`: `/YB0..YB7`
   - `GPIO16..19`: SD card SPI
   - `GPIO20..21`: I2C
   - `GPIO22`: `/BYTE_READY_3V3`
   - `GPIO26..28`: rotary encoder

2. Treat BSS138-translated lines as open-drain style GPIO.
   - Affected nets: `/MTR_3V3`, `/STP0_3V3`, `/STP1_3V3`, `/WPS_3V3`.
   - Assert low by driving output low.
   - Deassert by switching the GPIO to input/high-Z and letting the pullups work.
   - Do not drive these lines push-pull high.

3. Avoid Pico/CPLD bus contention.
   - Shared nets include `/YB0..YB7`, `/MODE_3V3`, `/SYNC_3V3`, `/DEVNUM_3V3`, and `/BYTE_READY_3V3`.
   - Firmware must know when the CPLD side is driving and when it is high-Z.

4. Document and implement the byte handshake.
   - `BYTE_READY_3V3` is the Pico-side strobe.
   - `BYTE_LATCHED` goes to the gate array.
   - `/~{CS_TPI}` clears `BYTE_LATCHED`; this means any CPU access to the TPI I/O address space clears the latch.
   - The 1541/1571 service manuals are still relevant here: they document the gate-array byte-ready/SOE behavior and the reused ATN-related latch behavior, even though there is no dedicated 1551 service manual in the repo.
   - Re-confirm exact behavior after rebuilding the CPLD.

5. Decide reset handling.
   - CPLD passes `/~{RESET}` to `/~{RESET_3V3}`.
   - Pico `RUN` only follows that reset if `JP1` is bridged.

6. Document the IRQ/PHI0 experiment jumper modes.
   - `JP2` is a 3-way solder jumper for `PHI0`: default `A-C` connects `PHI0_BRD` to `/PHI0`; experiment `B-C` connects Pico `GPIO0` to `/PHI0` instead.
   - `JP5` and `JP6` must be changed together for the IRQ experiment. Default keeps `GPIO3 -> /DEVNUM_3V3` and `/~{IRQ_BRD} -> /~{IRQ}`. Swapped mode connects `GPIO3 -> /~{IRQ}` and lets `JP7` set `/DEVNUM_3V3`.
   - `JP7` selects the fixed device number only when `JP5` is in swapped mode: default `GND` is device #8; switched `+3V3` is device #9.
   - Avoid partial jumper swaps: changing only one of `JP5` or `JP6` can leave either IRQ or DEVNUM disconnected from the intended source.
   - When changing any 3-way jumper, cut the default `A-C` bridge before adding the `B-C` bridge. Leaving both bridges closed can short two signal sources together.
   - Before testing Pico-generated `PHI0`, verify the programmed CPLD leaves `U3 P31` as input/high-Z. The old fitted output marks `P31` as unused/tied, but the final JED should be checked before driving `/PHI0` from `GPIO0`.

## Reference Notes To Keep

- TCBM connector naming is intentionally preserved for the adapter: `/DAV` is on `J10` pin 11 and `/ACK` is on `J10` pin 13.
- Board-side `YB*`, `MODE`, `DEVNUM_BRD`, `SYNC`, `DS0`, and `DS1` are intentionally not connected to the active Pico-side nets.
- Only SMD parts are expected in the assembly BOM; through-hole parts/modules are manual assembly.
- New `JP2`, `JP5`, `JP6`, and `JP7` solder jumpers are for future CPU clock/IRQ experiments, not for the first normal bring-up.
