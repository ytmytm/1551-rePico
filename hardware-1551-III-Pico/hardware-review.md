# Review hardware-1551-III-Pico

Data review: 2026-08-13

Zakres: tylko projekt `hardware-1551-III-Pico`, z porownaniem do `hdl-1551-III/Fake6523.v`, `hdl-1551-III/Fake6523.ucf`, `hdl-1551-III/Fake6523.rpt`, `hardware-1551-III-Pico/notes.txt` i `doc/1551-rom-ram-ramboard-decode.txt`.

## Wniosek ogolny

Schemat po przeniesieniu dekodera adresu do CPLD wyglada spojnie. `U12 74LS139` i `U15 74LS00` zostaly usuniete, stare nety dekodera nie wystepuja juz w schemacie ani PCB, a nety KiCada zgadzaja sie z pinoutem HDL/UCF.

Nie widze blokera logicznego, ktory jednoznacznie zatrzymywalby testowa produkcje plytki. Do zamkniecia przed wyslaniem zostaje jedna rzecz produkcyjna: pola BOM/JLC dla `U19`, bo schemat chce `74HCT165`, a pola produkcyjne nadal wskazuja wariant LS.

Fit `hdl-1551-III` przeszedl dla wariantu z osobnym `/RAMOE`, ale CPLD jest wypelniony do konca:

```text
Macrocells:     72/72  (100%)
Product Terms: 206/360 (57%)
FB inputs:     136/216 (63%)
Registers:      58/72  (81%)
Pins:           47/52  (90%)
```

Nie dokladac juz logiki do XC9572XL w tej rewizji bez swiadomego usuwania czegos innego.

Ostrzezenia fittera sa znane i nie wygladaja na nowy problem po dodaniu dekodera: dotycza inferowanych/zignorowanych `BUFG` na pinach `port_a<5..7>` oraz sciezki projektu ISE. Nie ma bledow fitowania.

## Dekoder W CPLD

Aktualne znaczenie sygnalow:

```text
/RAMSEL = RAM /CS, zalezy tylko od adresu
/RAMOE  = RAM /OE, aktywne tylko gdy RAM jest wybrany i CPU czyta
XR/~W   = ogolny /WE, aktywne przy R/W=0 i PHI2=1
/ROMSEL = ROM /CE i /OE, zalezy tylko od adresu ROM
```

Rownania po fitterze:

```text
/RAMSEL = A14 OR (A15 AND A13)
/RAMOE  = NOT ((NOT A14 AND NOT A15 AND R/W) OR (NOT A14 AND NOT A13 AND R/W))
/ROMSEL = NOT A15 OR (NOT A14 AND NOT A13)
TPI /CS wewnetrznie = NOT (A14 AND NOT A15)
```

Mapa adresow:

```text
$0000-$3fff = RAM
$4000-$7fff = TPI
$8000-$9fff = dodatkowy RAM
$a000-$ffff = ROM
```

## Weryfikacja Netow KiCad

Sprawdzone w `1551-III-Pico.kicad_sch` i `1551-III-Pico.kicad_pcb`:

```text
U9 P39 = A14
U9 P42 = /RAMOE
U9 P58 = /RAMSEL
U9 P59 = /ROMSEL
U9 P61 = A13
U9 P62 = A15
U4 pin 20 /CS = /RAMSEL
U4 pin 22 /OE = /RAMOE
U4 pin 27 /WE = XR/~W
U5 pin 20 /CE = /ROMSEL
U5 pin 22 /OE = /ROMSEL
U6 CPU A13/A14/A15 sa na tych samych netach A13/A14/A15
```

Nie znaleziono juz w schemacie ani PCB: `U12`, `U15`, `74LS139`, `74LS00`, `~{CS_TPI}`, `~{RAM_LOW}`, `~{RAM_HIGH}`, `~{ROM_LOW}`, `~{ROM_HIGH}`, `~{E2}`.

Dodany test/symulator:

```text
python3 hardware-1551-III-Pico/test_hardware_model.py
```

Test sprawdza model dekodera adresu dla calego zakresu `$0000-$ffff`, brak konfliktu driverow na magistrali danych przy odczycie, kwalifikowanie `/RAMOE` i `XR/~W`, kolejnosc bitow z `U19 74HCT165`, krytyczne piny KiCada kontra HDL/UCF oraz wybrane pullupy/wejscia stale.

## Audyt CPU/RAM/ROM

CPU `U6 6510T`: adresy, dane, `R/W`, `PHI0`, `PHI2`, `/RESET`, `/IRQ`, `/AEC` i portowe linie 1551 sa podlaczone; `/RESET`, `/IRQ` i `/AEC` maja pullupy.

SRAM `U4 KM62256CLP`: adresowanie jest zgodne z planem RAMBoard:

```text
RAM A0..A13 = CPU A0..A13
RAM A14     = CPU A15
RAM D0..D7  = CPU D0..D7
```

Sterowanie SRAM:

```text
pin 20 /CS = /RAMSEL
pin 22 /OE = /RAMOE
pin 27 /WE = XR/~W
```

EPROM `U5 27C512`: adresy i dane sa kompletne, `ROM A15` jest ustawiany przez `J2 + R1 3.3K do +5V`, a `/CE` i `/OE` ida na `/ROMSEL`. Nie widze wiszacych wejsc przy RAM/ROM.

## Audyt CPLD/TPI/TCBM

`U9 XC9572XL` jest zasilany z `+3V3`, ma podlaczone wszystkie piny z UCF i poprawnie wykorzystuje `~{RESET}` jako GSR. Niepodlaczone piny CPLD `P8`, `P18`, `P23`, `P51` sa oznaczone jako no-connect i fitter pokazuje je jako `TIE`, wiec nie wygladaja jak przypadkowo wiszace uzywane wejscia.

Linie TCBM `DIO1..DIO8`, `STATUS0`, `STATUS1`, `DEV`, `DAV`, `ACK` ida do CPLD zgodnie z UCF. Pullupy TCBM ida do `+3V3`, co pasuje do pracy CPLD na 3.3 V i do jego 5 V tolerant wejsc.

Warto pamietac, ze `byte_latched` jest generowane z asynchronicznego `byte_ready_3v3` i wewnetrznego `/CS`; to jest istniejacy model z eksperymentu. Nie znalazlem tu nowego bledu schematowego, ale to pozostaje punkt bring-up firmware/HDL, nie ERC.

## Audyt Pico I Shift Register

`U3 Pico` ma `VSYS` podlaczone do `+5V`, `3V3` zasila logike 3.3 V, a `VBUS`, `RUN`, `3V3_EN`, `ADC_VREF`, `SWCLK`, `SWDIO` sa swiadomie no-connect. To jest akceptowalne dla modulu uruchamianego przez USB/BOOTSEL i bez osobnego debug SWD na plytce.

`U19 74HCT165`: `/PL = SERIAL_LOAD`, `CP = SERIAL_CLK`, `Q7 = SERIAL_DT`, `DS = GND`, `/CE = GND`, `VCC = +5V`, `GND = GND`, a `/Q7` jest no-connect. Wejscia panelowe i SD-card-detect maja pullupy do `+3V3`; `DS0/DS1` sa czytane z portu CPU i nie wymagaja tu osobnych pullupow jesli CPU je aktywnie steruje.

Uwaga produkcyjna: symbol/wartosc mowi `74HCT165`, ale pola JLC/MFR w schemacie i PCB nadal wskazuja `SN74LS165ADR(LX)` / `C42403065`. Jesli faktycznie ma byc HCT, trzeba poprawic pola BOM/JLC przed assembly. Jesli swiadomie dopuszczasz LS, dopisz to w BOM, bo obecna notatka na schemacie mowi, ze "musi byc HCT".

## Zasilanie I Montaz

`+5V` zasila CPU/RAM/ROM/U19 i `VSYS` Pico, `+3V3` zasila CPLD, pullupy 3.3 V i peryferia Pico. Kondensatory 100 nF sa przy glownych ukladach (`C1..C6`, `C10`), a przy SD jest dodatkowy `C11 10u`. Nie robilem analizy impedancji ani rozmieszczenia przy pinach zasilania, tylko sprawdzenie netlisty.

`README.md` w katalogu projektu opisuje juz rewizje Pico (KiCad / plots / production / ROM); nie jest juz starym tekstem Pi1551-III Module-rotated.

`JP1..JP3` (solder jumpers GPIO26..28): domyslnie mostkowane **1–2** do `74HCT165` (`/PL`, `CP`, `Q7`). Alternatywna sciezka na schemacie (bezposrednio do enkodera) byla tylko ubezpieczeniem na wypadek problemow z '165; shift register dziala, firmware zaklada tryb 1–2 — **zostawic JP1–JP3 bez zmian**.

## Otwarte

- [x] Nałozyc overlay warstwy Edge.Cuts z MOSReplacer - miec pewnosc ze sie zmiesci nad footprint 6510T
      potrzeba 6.5mm z lewej i 10.54mm z prawej (moze byc nad ROM/RAM, ale nie nad RPIco)
- [x] Porownac z tcbm2sd jak daleko poza krawedz wystaje gniazdo SD card
- [x] Uruchomic ERC/DRC w KiCadzie lokalnie; `kicad-cli` nie jest dostepny w tym srodowisku.
- [x] Sprawdzic pola BOM/JLC dla `U19`: HCT zgodnie ze schematem/notatka albo swiadomie LS i opisane w BOM. Aktualnie nadal `SN74LS165ADR(LX)` / `C42403065`. (LS/HCT bez roznicy)
- [x] Przejrzec wygenerowany BOM/position files po ostatnich zmianach, szczegolnie usuniecie `U12/U15` i dodanie netow CPLD `/RAMSEL`, `/RAMOE`, `/ROMSEL`.
- [x] Dodac i uruchomic test/symulator `hardware-1551-III-Pico/test_hardware_model.py`.
- [x] Dopisac w firmware obsluge `74HCT165`.
- [x] Opisac `JP1..JP3`: default 1–2 do '165; fallback na enkoder tylko jako ubezpieczenie — nie ruszac (README projektu KiCad).
- [x] Uaktualnic `hardware-1551-III-Pico/README.md` dla tej rewizji (BOM/plots/production + notka JP1–JP3).

[2026-08-31]
Too dim ACT LED:
- remove R27 (3.3K)
- move R23 to R27 footprint (470R)
- short R23 pads (0R)
Should be much brighter, comparable to PWR
