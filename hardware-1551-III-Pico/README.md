# Pi1551-III Module-rotated
This is the main PCB and holds most of the active components. It is designed to be used with [Pi1551-III Module Panel](../Pi1551-III%20Module%20Panel) (see its [BOM](../Pi1551-III%20Module%20Panel/README.md#3-bom) when ordering). The Raspberry Pi footprint is rotated 180° so USB and HDMI are accessible; we recommend **not** installing the barrel jack (J1) or the 470 µF capacitor (C6)—power the device from the Raspberry Pi’s USB Micro port.

- [1> Build instructions](#1-build-instructions)
- [2> Schematic](#2-schematic)
- [3> BOM](#3-bom)

# 1> Build instructions
Assembly of this module is described in the top-level [README Assembly section](../README.md#3-assembly): start with the smallest parts first (SMD if hand-soldering, then buzzer, RPi GPIO header, TCBM connector, MiniDIN-7). The BOM for this module is [below](#3-bom).


# 2> Schematic
The supplied KiCad files should be sufficient as both a schematic and as a  starting point for ordering PCBs (basically you could just zip the contents of the export folder and upload that on a fabrication site), the schematic is also available in [PDF-format](../documentation/schematic) (if present in this repo) for when things don’t work as expected after assembly.

# 3> BOM
This BOM matches the schematic in this folder. Optional parts in parentheses. Gerbers, a BOM with JLCPCB part numbers, and SMD position data are in the [Releases](https://github.com/ytmytm/Pi1551-III/releases) section.

| Reference             | Item                                                              | Count | Order  |
| --------------------- | ----------------------------------------------------------------- | ----- | ------ |
| Module PCB            | PCB for this project                                              |     1 | [Releases](https://github.com/ytmytm/Pi1551-III/releases)
| Faceplate FB1         | Top faceplate PCB                                                 |     1 | [Releases](https://github.com/ytmytm/Pi1551-III/releases)
| Faceplate FB2         | Bottom faceplate PCB                                              |  (1)  | [Releases](https://github.com/ytmytm/Pi1551-III/releases)
| A1              | 2×20 pin female header (RPi GPIO)                                    |     1 |
|                 | Raspberry Pi 3A / 3B / 3B+                                           |     1 |
| BZ1             | Passive buzzer (pin spacing 3.81–7 mm)                               |  (1)  |
| C6              | 470 µF electrolytic (8 mm × 3.5 mm)                                  |  (1)* |
| D2              | Schottky diode (BAT54, BAS40, 1N5819, etc.) SMD SOD-123 — protects Pi |     1 |
| J1              | 2.1 mm × 5.5 mm barrel jack                                           |  (1)* |
| J3              | 2×8 (16-pin) IDC connector, vertical (ribbon to tcbm2sd)             |     1 |
| J4              | MiniDIN-7 female socket (tape/TAP)                                   |     1 |
| J8              | [Pi1551-III Module Panel](../Pi1551-III%20Module%20Panel) (assembled) | 1 |
| JP1, JP2        | Solder jumpers (on PCB; set per schematic)                           |     2 |
| Q1–Q4           | MMBT3904 or 2N3904 (SOT-23 SMD) — TAP circuit                        |     4 |
| R1              | 3.3 kΩ (0805 or similar SMD) — with D2                               |     1 |
| R2, R3 *1       | 470 Ω (0805 SMD) — for panel LEDs                                    |     2 |
| R4–R24          | 3.3 kΩ (0805 SMD) — TAP / level shifting, pullups                    |    21 |
| Mounting *2           | Nylon M3 hex standoffs 6mm (M-F)                                  |     4 |
| Mounting *2           | Nylon M3 hex standoffs 8mm (M-F)                                  |     2 |
| Mounting *3           | Nylon M3 hex standoffs 12mm (M-F)                                 |    (4)|
| Mounting *2           | Nylon M3 hex standoffs 20mm (M-F)                                 |     4 |
| Mounting *2           | Nylon M3x6mm nylon screws                                         |     6 |
| Mounting *2           | Nylon M3x6mm nylon nuts                                           |     12 |

**\*** Recommended not to install J1 (barrel jack) or C6 (470 µF). Power the device from the Raspberry Pi’s USB Micro port.

**D2 (Schottky):** Orient with the cathode stripe towards the silkscreen mark.

1) For LEDs on [Pi1551-III Module Panel](../Pi1551-III%20Module%20Panel); 470 Ω suits most coloured LEDs — use a higher value for blue or "bright" types.
2) M3 nylon standoff kits usually contain what you need; check quantities.
3) Only when *not* installing bottom faceplate ([Pi1551-III Faceplate FB2](../faceplates/Pi1551-III%20Module%20FB2)).
