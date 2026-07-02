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

## Firmware TODO

1. Update Pico firmware for the 1551 pin map.
   - `GPIO0`: use for the planned 2 MHz clock generator / 100 Hz IRQ spike generator test.
   - `GPIO1`: `/MODE_3V3`
   - `GPIO2`: `/SYNC_3V3`
   - `GPIO3`: `/DEVNUM_3V3`
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

## Reference Notes To Keep

- KiCad files were saved again after the hardware corrections; this report intentionally keeps only deferred CPLD/firmware work and a few bring-up reminders.
- TCBM connector naming is intentionally preserved for the adapter: `/DAV` is on `J10` pin 11 and `/ACK` is on `J10` pin 13.
- Board-side `YB*`, `MODE`, `DEVNUM_BRD`, `SYNC`, `DS0`, and `DS1` are intentionally not connected to the active Pico-side nets.
- Only SMD parts are expected in the assembly BOM; through-hole parts/modules are manual assembly.
