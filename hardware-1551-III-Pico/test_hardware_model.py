#!/usr/bin/env python3
"""Regression checks for the 1551-III-Pico hardware model.

This is not an analog simulator. It is a small executable specification for the
parts that are easy to get subtly wrong before ordering PCBs:

* CPLD address decode for RAM, ROM and the internal Fake6523/TPI port.
* CPU bus read/write enable combinations.
* 74HCT165 parallel-load/shift behavior for the slow Pico inputs.
* Selected KiCad netlist facts that should match the HDL/UCF pinout.
* Known input nets that must either be driven or have pullups.
"""

from __future__ import annotations

import re
import unittest
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PCB = ROOT / "1551-III-Pico.kicad_pcb"
SCH = ROOT / "1551-III-Pico.kicad_sch"


def bit(value: int, index: int) -> int:
    return (value >> index) & 1


@dataclass(frozen=True)
class Decode:
    address: int
    rw: int = 1
    phi2: int = 1

    @property
    def a13(self) -> int:
        return bit(self.address, 13)

    @property
    def a14(self) -> int:
        return bit(self.address, 14)

    @property
    def a15(self) -> int:
        return bit(self.address, 15)

    @property
    def ram_sel_n(self) -> int:
        # TEMP: address decode OR ~PHI2 (inactive in PHI1).
        addr = self.a14 | (self.a15 & self.a13)
        return 1 if not self.phi2 else addr

    @property
    def ram_oe_n(self) -> int:
        # /OE follows /CS (also PHI2-qualified via _ramsel).
        return self.ram_sel_n

    @property
    def rom_sel_n(self) -> int:
        # TEMP: address decode AND PHI2.
        if not self.phi2:
            return 1
        return 0 if (self.a15 and (self.a14 or self.a13)) else 1

    @property
    def tpi_cs_n(self) -> int:
        # TEMP: address decode OR ~PHI2 (inactive in PHI1).
        addr = self.a15 | (0 if self.a14 else 1)
        return 1 if not self.phi2 else addr

    @property
    def xrw_n(self) -> int:
        return 0 if ((not self.rw) and self.phi2) else 1

    @property
    def selected_devices(self) -> set[str]:
        selected: set[str] = set()
        if self.ram_sel_n == 0:
            selected.add("RAM")
        if self.rom_sel_n == 0:
            selected.add("ROM")
        if self.tpi_cs_n == 0:
            selected.add("TPI")
        return selected

    @property
    def cpu_data_drivers(self) -> set[str]:
        if not self.rw:
            return {"CPU"}
        drivers: set[str] = set()
        # TEMP: /OE==/CS; still treat /WE as forcing SRAM outputs off.
        if self.ram_sel_n == 0 and self.ram_oe_n == 0 and self.xrw_n == 1:
            drivers.add("RAM")
        if self.rom_sel_n == 0:
            drivers.add("ROM")
        if self.tpi_cs_n == 0:
            drivers.add("CPLD_TPI")
        return drivers

    @property
    def ram_write_enabled(self) -> bool:
        return self.ram_sel_n == 0 and self.xrw_n == 0


class ShiftRegister165:
    """74HC/HCT165 model using the actual U19 pin mapping.

    After /PL goes low, Q7 outputs D7 first. Each rising CP edge shifts toward
    Q7 and shifts DS into bit 0. In this design DS is tied to GND.
    """

    INPUT_ORDER = (
        "ROT_SW",  # D0
        "ROT_CLK",  # D1
        "ROT_DT",  # D2
        "DS0",  # D3
        "DS1",  # D4
        "SD_CD",  # D5
        "SW4_BACK",  # D6
        "SW5_INSERT",  # D7
    )

    def __init__(self, serial_in: int = 0) -> None:
        self.serial_in = serial_in & 1
        self.value = 0

    def load(self, pins: dict[str, int]) -> None:
        value = 0
        for index, name in enumerate(self.INPUT_ORDER):
            value |= (pins[name] & 1) << index
        self.value = value

    def q7(self) -> int:
        return bit(self.value, 7)

    def clock_rising_edge(self) -> int:
        out = self.q7()
        self.value = ((self.value << 1) & 0xFE) | self.serial_in
        return out

    def read_byte_msb_first(self, pins: dict[str, int]) -> int:
        self.load(pins)
        value = 0
        for _ in range(8):
            value = (value << 1) | self.clock_rising_edge()
        return value


def parse_pcb_footprint_pads(path: Path) -> dict[tuple[str, str], str]:
    footprints: dict[tuple[str, str], str] = {}
    current_ref: str | None = None
    current_pad: str | None = None
    current_net: str | None = None

    for line in path.read_text(encoding="utf-8").splitlines():
        ref_match = re.search(r'\(property "Reference" "([^"]+)"', line)
        if ref_match:
            current_ref = ref_match.group(1)

        pad_match = re.search(r'\(pad "([^"]+)" ', line)
        if pad_match:
            current_pad = pad_match.group(1)
            current_net = None

        net_match = re.search(r'\(net \d+ "([^"]+)"\)', line)
        if current_ref and current_pad and net_match:
            current_net = net_match.group(1)
            footprints[(current_ref, current_pad)] = current_net

        if current_pad and line.startswith("\t\t)"):
            current_pad = None
            current_net = None

    return footprints


class AddressDecodeTest(unittest.TestCase):
    def test_whole_address_space_selects_exactly_one_device(self) -> None:
        # During PHI2; PHI1 leaves RAM/ROM deselected.
        expected_ranges = {
            "RAM": [(0x0000, 0x3FFF), (0x8000, 0x9FFF)],
            "TPI": [(0x4000, 0x7FFF)],
            "ROM": [(0xA000, 0xFFFF)],
        }
        for address in range(0x10000):
            decode = Decode(address, phi2=1)
            self.assertEqual(len(decode.selected_devices), 1, f"${address:04x}")
            selected = next(iter(decode.selected_devices))
            self.assertTrue(
                any(lo <= address <= hi for lo, hi in expected_ranges[selected]),
                f"${address:04x} selected {selected}",
            )

    def test_boundary_addresses(self) -> None:
        cases = {
            0x0000: "RAM",
            0x3FFF: "RAM",
            0x4000: "TPI",
            0x7FFF: "TPI",
            0x8000: "RAM",
            0x9FFF: "RAM",
            0xA000: "ROM",
            0xBFFF: "ROM",
            0xC000: "ROM",
            0xFFFF: "ROM",
        }
        for address, expected in cases.items():
            self.assertEqual(Decode(address, phi2=1).selected_devices, {expected})

    def test_ram_and_rom_inactive_during_phi1(self) -> None:
        for address in range(0x10000):
            decode = Decode(address, rw=1, phi2=0)
            self.assertEqual(decode.ram_sel_n, 1, f"${address:04x}")
            self.assertEqual(decode.rom_sel_n, 1, f"${address:04x}")
            self.assertEqual(decode.tpi_cs_n, 1, f"${address:04x}")
            self.assertEqual(decode.selected_devices, set())

    def test_ram_output_enable_tracks_ram_select(self) -> None:
        for address in range(0x10000):
            read = Decode(address, rw=1, phi2=1)
            write = Decode(address, rw=0, phi2=1)
            self.assertEqual(read.ram_oe_n == 0, read.selected_devices == {"RAM"})
            self.assertEqual(write.ram_oe_n == 0, write.selected_devices == {"RAM"})

    def test_xrw_is_general_phi2_qualified_write(self) -> None:
        self.assertEqual(Decode(0x0000, rw=0, phi2=0).xrw_n, 1)
        self.assertEqual(Decode(0x0000, rw=0, phi2=1).xrw_n, 0)
        self.assertEqual(Decode(0x0000, rw=1, phi2=0).xrw_n, 1)
        self.assertEqual(Decode(0x0000, rw=1, phi2=1).xrw_n, 1)

    def test_cpu_data_bus_has_no_read_contention(self) -> None:
        for address in range(0x10000):
            drivers = Decode(address, rw=1, phi2=1).cpu_data_drivers
            self.assertEqual(len(drivers), 1, f"${address:04x}: {drivers}")
            # PHI1: RAM/ROM/TPI all inactive.
            phi1 = Decode(address, rw=1, phi2=0).cpu_data_drivers
            self.assertEqual(phi1, set(), f"${address:04x} PHI1: {phi1}")

    def test_ram_write_happens_only_in_ram_ranges(self) -> None:
        for address in range(0x10000):
            decode = Decode(address, rw=0, phi2=1)
            self.assertEqual(decode.ram_write_enabled, decode.selected_devices == {"RAM"})
            self.assertFalse(Decode(address, rw=0, phi2=0).ram_write_enabled)

class ShiftRegisterTest(unittest.TestCase):
    def test_u19_outputs_d7_first_msb_first(self) -> None:
        pins = {
            "ROT_SW": 1,
            "ROT_CLK": 0,
            "ROT_DT": 1,
            "DS0": 0,
            "DS1": 1,
            "SD_CD": 0,
            "SW4_BACK": 1,
            "SW5_INSERT": 0,
        }
        reg = ShiftRegister165()
        self.assertEqual(reg.read_byte_msb_first(pins), 0b01010101)

    def test_tied_serial_input_shifts_zeroes_after_loaded_bits(self) -> None:
        reg = ShiftRegister165(serial_in=0)
        reg.load({name: 1 for name in ShiftRegister165.INPUT_ORDER})
        bits = [reg.clock_rising_edge() for _ in range(12)]
        self.assertEqual(bits[:8], [1] * 8)
        self.assertEqual(bits[8:], [0, 0, 0, 0])


class KiCadNetlistTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.pads = parse_pcb_footprint_pads(PCB)

    def assert_pad_net(self, ref: str, pad: str, net: str) -> None:
        self.assertEqual(self.pads.get((ref, pad)), net, f"{ref} pad {pad}")

    def test_cpld_decode_pins_match_ucf(self) -> None:
        expected = {
            ("U9", "39"): "/A14",
            ("U9", "42"): "/~{RAMOE}",
            ("U9", "58"): "/~{RAMSEL}",
            ("U9", "59"): "/~{ROMSEL}",
            ("U9", "61"): "/A13",
            ("U9", "62"): "/A15",
            ("U9", "40"): "/XR{slash}~{W}",
        }
        for key, net in expected.items():
            self.assert_pad_net(*key, net)

    def test_memory_control_pins(self) -> None:
        expected = {
            ("U4", "20"): "/~{RAMSEL}",
            ("U4", "22"): "/~{RAMOE}",
            ("U4", "27"): "/XR{slash}~{W}",
            ("U5", "20"): "/~{ROMSEL}",
            ("U5", "22"): "/~{ROMSEL}",
        }
        for key, net in expected.items():
            self.assert_pad_net(*key, net)

    def test_memory_address_mapping(self) -> None:
        expected = {
            ("U4", "1"): "/A15",  # RAM A14 gets CPU A15.
            ("U4", "26"): "/A13",
            ("U5", "1"): "Net-(J2-Pin_1)",  # ROM A15 bank jumper.
            ("U5", "26"): "/A13",
            ("U5", "27"): "/A14",
        }
        for key, net in expected.items():
            self.assert_pad_net(*key, net)

    def test_u19_shift_register_pins(self) -> None:
        expected = {
            ("U19", "1"): "/SERIAL_LOAD",
            ("U19", "2"): "/SERIAL_CLK",
            ("U19", "3"): "/DS1",
            ("U19", "4"): "/SD_CD",
            ("U19", "5"): "SW4_BACK",
            ("U19", "6"): "SW5_INSERT",
            ("U19", "7"): "unconnected-(U19-~{Q7}-Pad7)",
            ("U19", "8"): "GND",
            ("U19", "9"): "/SERIAL_DT",
            ("U19", "10"): "GND",
            ("U19", "11"): "/ROT_SW",
            ("U19", "12"): "/ROT_CLK",
            ("U19", "13"): "/ROT_DT",
            ("U19", "14"): "/DS0",
            ("U19", "15"): "GND",
            ("U19", "16"): "+5V",
        }
        for key, net in expected.items():
            self.assert_pad_net(*key, net)

    def test_known_pullup_or_driven_inputs_are_not_floating(self) -> None:
        pullup_resistors = {
            "R44": {"/ROT_SW", "+3V3"},
            "R43": {"/ROT_CLK", "+3V3"},
            "R42": {"/ROT_DT", "+3V3"},
            "R28": {"/SD_CD", "+3V3"},
            "R40": {"SW4_BACK", "+3V3"},
            "R41": {"SW5_INSERT", "+3V3"},
            "R17": {"/BYTE_READY_3V3", "+3V3"},
            "R32": {"/SERIAL_DT_3V3", "+3V3"},
            "R38": {"/WPS_3V3", "+3V3"},
            "R25": {"/MTR_3V3", "+3V3"},
            "R27": {"/ACT_3V3", "+3V3"},
            "R21": {"/~{IRQ}", "+3V3"},
        }
        for ref, expected_nets in pullup_resistors.items():
            with self.subTest(ref=ref):
                actual_nets = {self.pads.get((ref, "1")), self.pads.get((ref, "2"))}
                self.assertEqual(actual_nets, expected_nets)

        driven_or_tied = {
            ("U19", "10"): "GND",  # serial input DS.
            ("U19", "15"): "GND",  # /CE.
            ("U19", "3"): "/DS1",
            ("U19", "14"): "/DS0",
        }
        for key, net in driven_or_tied.items():
            self.assert_pad_net(*key, net)

    def test_removed_external_decoder_is_absent(self) -> None:
        text = SCH.read_text(encoding="utf-8") + PCB.read_text(encoding="utf-8")
        removed = (
            "74LS139",
            "74LS00",
            "~{CS_TPI}",
            "~{RAM_LOW}",
            "~{RAM_HIGH}",
            "~{ROM_LOW}",
            "~{ROM_HIGH}",
            "~{E2}",
        )
        for token in removed:
            self.assertNotIn(token, text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
