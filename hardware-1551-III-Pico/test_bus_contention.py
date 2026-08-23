#!/usr/bin/env python3
"""Independent bus-contention audit for hdl-1551-III Fake6523 + III-Pico memory wiring.

Does NOT import or reuse test_hardware_model.py. Equations are taken directly from:

    hdl-1551-III/Fake6523.v

        wire _cs = a15 | ~a14 | ~phi2;            // TPI /CS (TEMP: + PHI2)
        assign _ramsel = a14 | (a15 & a13) | ~phi2;  // TEMP: + PHI2
        assign _ramoe = _ramsel;                  // /OE follows /CS
        assign _romsel = ~(a15 & (a14 | a13) & phi2);  // TEMP: + PHI2
        assign _xrw = !(!_writereal & phi2);      // XR/~W to RAM /WE
        assign data = (!_cs & _xrw ? data_out : 8'bz);

Board facts (from KiCad, not from the other test):
    - SRAM /CS <- /RAMSEL, /OE <- /RAMOE, /WE <- XR/~W
    - TEMP: /CS, /RAMSEL and /ROMSEL inactive during PHI1
    - EPROM /CE and /OE both <- /ROMSEL
    - CPLD data[7:0] shares CPU D0..D7 with RAM/ROM
    - 62256: when /WE is active, outputs are disabled even if /OE is low

Run:
    python3 hardware-1551-III-Pico/test_bus_contention.py
"""

from __future__ import annotations

import sys
from dataclasses import dataclass


def bit(value: int, index: int) -> int:
    return (value >> index) & 1


@dataclass(frozen=True)
class Cycle:
    """One CPU bus cycle snapshot (address + R/W + PHI2)."""

    address: int
    rw: int  # 1 = read, 0 = write  (CPU R/~W, Verilog _writereal)
    phi2: int  # 1 = PHI2 high

    @property
    def a13(self) -> int:
        return bit(self.address, 13)

    @property
    def a14(self) -> int:
        return bit(self.address, 14)

    @property
    def a15(self) -> int:
        return bit(self.address, 15)

    # --- exact Fake6523.v equations (active-low nets are *_n) ---

    @property
    def tpi_cs_n(self) -> int:
        """wire _cs = a15 | ~a14 | ~phi2;  active low in $4000-$7FFF during PHI2."""
        addr = self.a15 | (0 if self.a14 else 1)
        return 1 if not self.phi2 else addr

    @property
    def ram_sel_n(self) -> int:
        """assign _ramsel = a14 | (a15 & a13) | ~phi2;"""
        addr = self.a14 | (self.a15 & self.a13)
        return 1 if not self.phi2 else addr

    @property
    def ram_oe_n(self) -> int:
        """assign _ramoe = _ramsel;"""
        return self.ram_sel_n

    @property
    def rom_sel_n(self) -> int:
        """assign _romsel = ~(a15 & (a14 | a13) & phi2);"""
        if not self.phi2:
            return 1
        return 0 if (self.a15 and (self.a14 or self.a13)) else 1

    @property
    def xrw_n(self) -> int:
        """assign _xrw = !(!_writereal & phi2);  -> RAM /WE."""
        write = 0 if self.rw else 1
        return 0 if (write and self.phi2) else 1

    @property
    def cpld_drives_data(self) -> bool:
        """assign data = (!_cs & _xrw ? data_out : Z)."""
        return (self.tpi_cs_n == 0) and (self.xrw_n == 1)

    @property
    def ram_drives_data(self) -> bool:
        # /OE follows /CS, but /WE active forces SRAM outputs off (62256).
        if self.ram_sel_n != 0 or self.ram_oe_n != 0:
            return False
        if self.xrw_n == 0:
            return False
        return True

    @property
    def rom_drives_data(self) -> bool:
        # Both /CE and /OE tied to /ROMSEL on the PCB.
        return self.rom_sel_n == 0

    @property
    def cpu_drives_data(self) -> bool:
        # 6502 drives write data while PHI2 is high.
        return self.rw == 0 and self.phi2 == 1

    @property
    def data_drivers(self) -> frozenset[str]:
        drivers: set[str] = set()
        if self.ram_drives_data:
            drivers.add("RAM")
        if self.rom_drives_data:
            drivers.add("ROM")
        if self.cpld_drives_data:
            drivers.add("CPLD_TPI")
        if self.cpu_drives_data:
            drivers.add("CPU")
        return frozenset(drivers)

    @property
    def chip_selects(self) -> frozenset[str]:
        selected: set[str] = set()
        if self.ram_sel_n == 0:
            selected.add("RAM")
        if self.rom_sel_n == 0:
            selected.add("ROM")
        if self.tpi_cs_n == 0:
            selected.add("TPI")
        return frozenset(selected)

    @property
    def ram_oe_we_both_active(self) -> bool:
        return self.ram_oe_n == 0 and self.xrw_n == 0

    def label(self) -> str:
        rw_s = "R" if self.rw else "W"
        return f"${self.address:04X} {rw_s} PHI2={self.phi2}"


def all_cycles():
    for address in range(0x10000):
        for rw in (0, 1):
            for phi2 in (0, 1):
                yield Cycle(address, rw, phi2)


def region(address: int) -> str:
    if address < 0x4000:
        return "RAM_LO"
    if address < 0x8000:
        return "TPI"
    if address < 0xA000:
        return "RAM_HI"
    return "ROM"


def main() -> int:
    hard: list[str] = []  # true multi-driver fights on D0..D7
    soft: list[str] = []  # noteworthy but may be inherited / PHI1 windows
    select_overlap: list[str] = []
    oe_we: list[str] = []

    # Representative matrix printed for humans
    samples = [
        0x0000,
        0x3FFF,
        0x4000,
        0x7FFF,
        0x8000,
        0x9FFF,
        0xA000,
        0xBFFF,
        0xC000,
        0xFFFF,
    ]

    print("=== Selection / OE / WE matrix (sample addresses) ===")
    print(
        f"{'addr':>6} {'ph':>3} {'rw':>2}  "
        f"{'RAMCS':>5} {'RAMOE':>5} {'RAMWE':>5}  "
        f"{'ROMCS':>5} {'TPICS':>5}  "
        f"{'selects':<12} {'D-drivers'}"
    )
    for address in samples:
        for phi2 in (0, 1):
            for rw in (1, 0):
                c = Cycle(address, rw, phi2)
                print(
                    f"${address:04X} {phi2:>3} {'R' if rw else 'W':>2}  "
                    f"{c.ram_sel_n:>5} {c.ram_oe_n:>5} {c.xrw_n:>5}  "
                    f"{c.rom_sel_n:>5} {c.tpi_cs_n:>5}  "
                    f"{','.join(sorted(c.chip_selects)) or '-':<12} "
                    f"{','.join(sorted(c.data_drivers)) or '-'}"
                )

    print("\n=== Exhaustive scan ($0000-$FFFF × R/W × PHI2) ===")
    for c in all_cycles():
        if len(c.chip_selects) > 1:
            select_overlap.append(
                f"{c.label()} selects={sorted(c.chip_selects)}"
            )

        if c.ram_oe_we_both_active:
            oe_we.append(c.label())

        drivers = c.data_drivers
        if len(drivers) <= 1:
            continue

        msg = f"{c.label()} region={region(c.address)} drivers={sorted(drivers)}"

        # Classify.
        # Hard: two memory/peripheral devices, or CPU vs device during PHI2.
        if drivers <= {"CPU", "CPLD_TPI"} and c.phi2 == 0:
            # PHI1: CPU not modeled as driving; CPLD alone would be fine.
            # Multi-driver without CPU on PHI1 is still hard if RAM/ROM/CPLD clash.
            if "CPU" not in drivers and len(drivers) > 1:
                hard.append(msg)
            else:
                soft.append(msg)
        elif "ROM" in drivers and "CPU" in drivers:
            # PCB ties ROM /OE to /ROMSEL — write cycles in ROM space fight.
            soft.append(msg + "  [ROM /OE==/ROMSEL: write vs EPROM]")
        elif "CPLD_TPI" in drivers and "CPU" in drivers:
            soft.append(msg + "  [TPI drives while _xrw=1; on write PHI2 _xrw=0 so this is unexpected]")
            hard.append(msg)
        else:
            hard.append(msg)

    # TPI-focused window report
    print("\n=== TPI ($4000-$7FFF) drive window ===")
    print("CPLD drives data when (!_cs && _xrw). TEMP: _cs also requires PHI2.")
    print("PHI1: /CS inactive -> HiZ. PHI2 write: _xrw=0 -> HiZ. PHI2 read: drive.")
    tpi_phi1_write_z = 0
    tpi_phi2_write_z = 0
    tpi_read_drive = 0
    for addr in (0x4000, 0x5FFF, 0x7FFF):
        c_w0 = Cycle(addr, rw=0, phi2=0)
        c_w1 = Cycle(addr, rw=0, phi2=1)
        c_r1 = Cycle(addr, rw=1, phi2=1)
        assert not c_w0.cpld_drives_data, "expected CPLD Z on TPI write PHI1"
        assert not c_w1.cpld_drives_data, "expected CPLD Z on TPI write PHI2"
        assert c_r1.cpld_drives_data, "expected CPLD drive on TPI read"
        tpi_phi1_write_z += 1
        tpi_phi2_write_z += 1
        tpi_read_drive += 1
    print(
        f"  spot-check OK: PHI1-write HiZ={tpi_phi1_write_z}, "
        f"PHI2-write HiZ={tpi_phi2_write_z}, read drive={tpi_read_drive}"
    )

    # ROM-space write fights (design of OE wiring)
    rom_write_fights = sum(
        1
        for c in all_cycles()
        if c.rom_drives_data and c.cpu_drives_data
    )
    print(f"\n=== ROM write fights (ROM drives & CPU drives) ===")
    print(f"  count over full space: {rom_write_fights}")
    print("  cause: U5 /CE and /OE both wired to /ROMSEL (no R/W qualify)")

    # RAM vs ROM / TPI on reads — the symptom class
    ram_rom_read = [
        c
        for c in all_cycles()
        if c.rw == 1 and c.ram_drives_data and c.rom_drives_data
    ]
    ram_tpi_read = [
        c
        for c in all_cycles()
        if c.rw == 1 and c.ram_drives_data and c.cpld_drives_data
    ]
    rom_tpi_read = [
        c
        for c in all_cycles()
        if c.rw == 1 and c.rom_drives_data and c.cpld_drives_data
    ]

    print("\n=== Read-path device vs device (symptom class) ===")
    print(f"  RAM & ROM both driving:  {len(ram_rom_read)}")
    print(f"  RAM & CPLD both driving: {len(ram_tpi_read)}")
    print(f"  ROM & CPLD both driving: {len(rom_tpi_read)}")
    if ram_rom_read:
        hard.append(f"RAM|ROM read fights: e.g. {ram_rom_read[0].label()}")
    if ram_tpi_read:
        hard.append(f"RAM|TPI read fights: e.g. {ram_tpi_read[0].label()}")
    if rom_tpi_read:
        hard.append(f"ROM|TPI read fights: e.g. {rom_tpi_read[0].label()}")

    print(f"\n=== Chip-select overlaps ===")
    print(f"  count: {len(select_overlap)}")
    if select_overlap:
        print(f"  first: {select_overlap[0]}")
        hard.extend(select_overlap[:5])

    print(f"\n=== RAM /OE and /WE both active (expected in TEMP /OE==/CS) ===")
    print(f"  count: {len(oe_we)}")
    if oe_we:
        print(f"  first: {oe_we[0]}")
        print("  note: 62256 keeps outputs off while /WE is low — not a D-bus fight")

    # Deduplicate soft notes that are the known ROM-write class
    soft_unique = soft[:20]

    print("\n=== Summary ===")
    print(f"  HARD contentions (decode/device fights): {len(hard)}")
    print(f"  SOFT / inherited notes (sample up to 20): {len(soft_unique)} of {len(soft)}")
    for line in hard[:30]:
        print(f"  HARD: {line}")
    for line in soft_unique[:10]:
        print(f"  soft: {line}")

    if hard:
        print("\nRESULT: FAIL — decode allows device/device or unexpected bus fights")
        return 1

    print(
        "\nRESULT: PASS — no RAM/ROM/TPI select overlap, no RAM|ROM|TPI read fights."
    )
    print(
        "NOTE: TEMP PHI2-qualified /CS+/RAMSEL+/ROMSEL. ROM-space PHI2 writes still "
        "fight EPROM by PCB (/OE=/ROMSEL)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
