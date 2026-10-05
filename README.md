# 1551-rePico

Commodore **1551** disk-drive replacement for Plus/4 / C16 / C116, based on Raspberry Pi Pico(2). Firmware and GCR/SD logic are derived from [1541-rePico](https://github.com/fook42/1541-rePico) / [1541-rebuild](https://github.com/ThKattanek/1541-rebuild).

## Relation to Pi1551-III

This project reuses the **mechanical stack** from [Pi1551-III](https://github.com/ytmytm/Pi1551-III): front panel, top/bottom faceplates, and the same overall assembly. For BOM, Gerbers, cabling notes, and build instructions for those parts, follow the Pi1551-III repository.

What this repo replaces is **only the main horizontal module** — the board Pi1551-III calls **Pi1551-III Module-rotated** (Raspberry Pi 3 + TCBM interface). Here that role is filled by `hardware-1551-III-Pico/`: a Pico2 + **6510T** (or [MOS CPU Replacer](https://github.com/monotech/MOS_CPU_Replacer)) + CPLD + RAM + ROM board that still mates with the Pi1551-III panel and covers. The finished device (Pi1551-III or this rePico1551 stack) connects to the computer through a ribbon cable to **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)** — same as Pi1551-III.

In short: same case and front panel as Pi1551-III; swap the Pi 3 mainboard for the Pico/6510T board in this repo.

## Repository layout (release)

| Path | Role |
|------|------|
| `firmware-1551-III-pico/` | **Supported** firmware |
| `hardware-1551-III-Pico/` | **Supported** KiCad mainboard (replaces Pi1551-III Module-rotated) |
| `hdl-1551-III/` | **Supported** CPLD (`Fake6523`) for III board |
| `roms/` | **Supported** 1551 DOS images for the 27C512 (see [`roms/README.md`](roms/README.md)) |
| `no-OS-FatFS-SD-SDIO-SPI-RPi-Pico/` | Shared FatFs/SD submodule |
| `tools/` | Optional host helper (`conv_x64` D64↔G64); see [`tools/README.md`](tools/README.md) |
| `experimental/` | **Archival only** — early plug-over-1551-mainboard daughterboard + old 1541-derived firmware (see `experimental/README.md`) |

Upstream 1541-rePico is not merged further; useful changes may be cherry-picked into `firmware-1551-III-pico` by hand.

## Architecture vs a stock 1551

Compared to an original Commodore 1551 drive, the roles split like this:

| Stock 1551 | This board |
|------------|------------|
| **6510T** CPU | Same **6510T**, or a [MOS CPU Replacer](https://github.com/monotech/MOS_CPU_Replacer) in that socket |
| ~2 KB SRAM | **32 KB** SRAM (`KM62256`) with a **1551-RAMBoard-style** map: `$0000–$3FFF` + `$8000–$9FFF` (extra RAM window; decode in the CPLD) |
| ~16 KB ROM | **64 KB** EPROM (`27C512`): two **32 KB** DOS images, selected by jumper **J2** — burn a [1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard) 64K image from [`roms/`](roms/) |
| Device #8 / #9 (hardware strap) | Jumper / strap for **device 8 or 9** (same idea as stock) |
| **6523** TPI (Tri-Port Interface) + discrete address decode | **XC9572XL CPLD** (`hdl-1551-III/` Fake6523): TPI replacement **and** RAM/ROM chip-select decode |
| Analog floppy + mech | **Pico2** emulates the analog path and runs the UI |

**Pico2** responsibilities:

- **2 MHz Phi0** clock for the 6502 side and **100 Hz IRQ** (PWM) — these take dedicated GPIOs that a stock 1551 gate-array / discrete clock would otherwise free up
- Front-panel **UI**: OLED (I2C), plus rotary encoder, Back/Insert, SD card-detect, and DS0/DS1 via a **74HCT165** shift register (same panel as Pi1551-III). The '165 exists because after clock, IRQ, floppy bus, SPI SD, and I2C there were not enough GPIOs left for every panel/input line directly
- **SD card**: FatFs images (D64/G64/PRG), directory browser / Load Selector, **card-detect hotplug** (eject/remount + rebuild selector list; sockets without a CD switch still work)
- Floppy **datastream**: GCR byte stream to/from the “head”, **BYTE_READY** / related timing
- **Stepper** lines and **density** (DS0/DS1 from the CPU when that option is enabled)
- **Write-protect / disk-change** sensing toward the 1551 firmware (WPS) and activity LED

Host link is unchanged in concept: the assembled drive talks **TCBM** over a ribbon to **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)**.

## How this project evolved

This is not a changelog — just enough background to see what is inherited and what is new.

**Starting point.** Firmware GCR packing, SD image I/O, and much of the menu/OLED skeleton come from [1541-rePico](https://github.com/fook42/1541-rePico) (itself from [1541-rebuild](https://github.com/ThKattanek/1541-rebuild)). The goal here was a **1551** for Plus/4 / C16 / C116 that still fits the **[Pi1551-III](https://github.com/ytmytm/Pi1551-III)** case and talks to the host through **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)** — so the Pi 3 “Module-rotated” board had to become a Pico + real 6510T path instead.

**Daughterboard bring-up** (now under `experimental/`). First hardware was a plug-over board on a stock 1551 mainboard: reuse CPU / TPI / RAM / ROM, let the Pico replace the analog floppy path, and put [Fake6523](https://github.com/ZXByteman/Fake6523) in the CPLD for the TPI side. That phase proved TCBM and GCR on real silicon, shook out pin maps, and showed several things that later became design rules: Phi0 and the 100 Hz IRQ can come from the Pico (the gate array is optional), `XR/~W` can be made in the CPLD, chip-selects must be PHI2-qualified or RAM contends on the bus, and `byte_latched` is the classic floppy byte-ready latch cleared by any TPI access. Zone 0 also needed slower byte timing / larger gaps than the 1541 defaults. Once the motherboard was only a carrier for RAM/ROM, a self-contained board was clearly the next step.

**1551-III-Pico.** Address decode moved into the CPLD (no more discrete `'139` / `'00`), with a [1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard)-style map and 64K DOS images. The PCB mates with the Pi1551-III front panel (SH1106 OLED + 74HCT165 — needed because Phi0/IRQ ate GPIOs). Firmware forked into `firmware-1551-III-pico/` (panel UI, density helpers, WPS on virtual disk change, SD card-detect hotplug, Plus/4 selector bits). Upstream 1541-rePico is no longer merged as a whole; only occasional hand cherry-picks. The early daughterboard tree stayed only as archaeology.

**Rough split today**

| Mostly from 1541-rePico | Mostly new for 1551 / this board |
|-------------------------|----------------------------------|
| GCR encode/decode, track buffers, D64/G64 image path | Hardware: KiCad III board, CPLD glue + Fake6523 ports, RAMBOard decode |
| FatFs / SD driver wiring, much of the menu framework | Pico as Phi0 + 100 Hz IRQ source; '165 front-panel inputs |
| Build/flash with pico-sdk / picotool | TCBM / Plus/4 host path via tcbm2sd; Parobek + patched DOS ROMs |
| | Zone-0 timing, byte-ready latch model, SD hotplug, III-specific pinout |

Released product paths are `firmware-1551-III-pico/`, `hardware-1551-III-Pico/`, `hdl-1551-III/`, and `roms/`.

## How to build and flash (1551-III-Pico)

### 1. Clone this repo (with submodules)

The FatFs/SD driver is a **git submodule**. Without it, CMake will fail.

```bash
git clone --recurse-submodules <URL-of-this-repo>
cd 1551-rePico   # or whatever the clone directory is named
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

For the supported firmware you need at least `no-OS-FatFS-SD-SDIO-SPI-RPi-Pico/`.  
(`experimental/firmware/buildtools/bitfire` is only for the archival 1541 tree.)

### 2. Host packages

**Linux (Debian-like):**

```bash
sudo apt install cmake ninja-build libusb-1.0-0-dev build-essential \
  pkg-config python3 xxd gcc-arm-none-eabi \
  libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib
```

**macOS (Homebrew):**

```bash
brew install cmake ninja libusb pkg-config python3
brew install --cask gcc-arm-embedded
```

`xxd` is usually already available on macOS (Xcode Command Line Tools). If `cmake` cannot find the Arm embedded toolchain, ensure `arm-none-eabi-gcc` is on your `PATH` (the `gcc-arm-embedded` cask installs it under `/Applications` or as linked brew binaries).

### 3. Raspberry Pi Pico SDK

From [pico-sdk](https://github.com/raspberrypi/pico-sdk):

```bash
git clone https://github.com/raspberrypi/pico-sdk.git
cd pico-sdk
git submodule update --init lib/mbedtls
export PICO_SDK_PATH="$(pwd)"
echo "export PICO_SDK_PATH=$PICO_SDK_PATH" >> ~/.profile
```

Open a new shell (or `source ~/.profile`) so `PICO_SDK_PATH` is set.

Alternatively, if you use the Raspberry Pi Pico VS Code extension / `.pico-sdk`, that can provide the SDK without a manual clone.

### 4. picotool (for USB flash)

From [picotool](https://github.com/raspberrypi/picotool): clone and build/install as in its README / BUILDING.md so `picotool` is on your `PATH`.

### 5. Configure and compile firmware

```bash
cd firmware-1551-III-pico
mkdir -p build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
```

Output (among others):

- `1551-III-Pico.uf2`
- `1551-III-Pico.elf`

### 6. Flash the Pico2 over USB

Connect the board’s Pico2 USB, then:

```bash
picotool load -t uf2 1551-III-Pico.uf2 -x -f
```

`-f` forces reboot into BOOTSEL when the app is running; `-x` starts the new firmware after load.

### Hardware / CPLD / panel (not this firmware tree)

#### Main PCB

KiCad project: [`hardware-1551-III-Pico/`](hardware-1551-III-Pico/) (see also its [`README.md`](hardware-1551-III-Pico/README.md)).

- Schematic PDF: [`plots/1551-III-Pico.pdf`](hardware-1551-III-Pico/plots/1551-III-Pico.pdf)
- Gerbers / drills: [`plots/`](hardware-1551-III-Pico/plots/)
- Fab pack for ordering: [`production/1551-III_Pico_2b.zip`](hardware-1551-III-Pico/production/1551-III_Pico_2b.zip)
- BOM / pick-and-place: [`production/bom.csv`](hardware-1551-III-Pico/production/bom.csv), [`positions.csv`](hardware-1551-III-Pico/production/positions.csv), [`designators.csv`](hardware-1551-III-Pico/production/designators.csv)
- **JP1–JP3**: leave default **1–2** (Pico ↔ `74HCT165`). The alternate wiring was only insurance if the shift register failed; do not change them.

#### CPLD

Program [`hdl-1551-III/Fake6523.jed`](hdl-1551-III/Fake6523.jed) into the XC9572XL. The `.jed` was built with [Xilinx ISE 14.7](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html) (sources/project live in `hdl-1551-III/`). Rebuild and JTAG flash steps (a Raspberry Pi 3 and jumper wires are enough — no dedicated programmer) are documented in [plus4-tcbm2sd → CPLD firmware](https://github.com/ytmytm/plus4-tcbm2sd/blob/main/HardwareFirmware.md#cpld-firmware); the procedure is the same for this board.

The CPLD is more than a bare 6523 socket clone. The bidirectional **ports** (TCBM on port A, head data on port B, handshake / MODE / DEVNUM / SYNC on port C) are based on [ZXByteman/Fake6523](https://github.com/ZXByteman/Fake6523) — a 1551-proven fork of go4retro’s Fake6523. On top of that the same chip is **logic glue** that replaced discrete decode and part of the old gate-array role:

- **Address decode** for the RAMBOard-style map: TPI at `$4000–$7FFF`, RAM at `$0000–$3FFF` and `$8000–$9FFF`, ROM at `$A000–$FFFF`, driving `/RAMSEL`, `/RAMOE`, and `/ROMSEL`
- **PHI2 qualification** of those chip-selects (and of TPI `/CS`) — without it the prototype showed data-bus contention with RAM installed; qualifying every select with PHI2 fixed bring-up
- **`XR/~W`** — a write strobe qualified with PHI2 for SRAM `/WE`, generated in the CPLD instead of taking the gate-array XR/W
- **`byte_latched` handshake** between Pico GCR and the 6502 side (below)

**How `byte_latched` really works.** There is no dedicated 1551 service manual in the usual places, but the 1541/1571 manuals describe the gate-array **byte-ready / SOE** path and a latch that is cleared by an access that looks a lot like the old ATN-related clear. Stock 1551 DOS does the same thing in software: it waits on the latched flag (CPU port bit), then does `BIT $4000` (any TPI access) to clear byte-ready. On this board that maps cleanly onto the CPLD:

1. Pico asserts **`byte_ready_3v3`** when a GCR byte is on the head bus.
2. The CPLD sets **`byte_latched`** on the falling edge of that strobe (so the Pico pulse can be short — no `sleep_us(3)` padding).
3. **`byte_latched` clears whenever TPI `/CS` is active** (CPU touching `$4000–$7FFF`) or on reset — same “any access to the byte-ready / TPI window clears the latch” behaviour the service docs and the ROM disassembly imply.

So the “mystery” latch is not a special sideband to invent: it is the classic floppy byte-ready latch, regenerated in Fake6523 from Pico strobe + TPI chip-select.

#### DOS ROM (27C512)

Program a 64K image from [`roms/`](roms/) (see [`roms/README.md`](roms/README.md)). Images and the RAM-expansion / fastloader patch come from **[1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard)**; jumper **J2** selects the active 32K half (use the patched upper bank).

#### Front panel / mechanical

Faceplates and mechanical assembly: follow **[Pi1551-III](https://github.com/ytmytm/Pi1551-III)**.

#### Host adapter

**[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)** + ribbon cable.

#### Load Selector / host software (TODO)

`firmware-1551-III-pico/SoftwareC16/db12b.prg` is a Plus/4 directory browser binary kept for a future on-device Load Selector path. **For now** we use the **DirectoryBrowser** shipped with **[Parobek](https://github.com/ytmytm/plus4-parobek)** (utility ROM for C16/116/Plus4). Parobek is the recommended host ROM anyway: it autodetects the [1551-RAMBOard](https://github.com/ytmytm/1551-RAMBOard) DOS patch and provides a fastloader that uses the extra RAM / track cache.

---

# Upstream 1541-rePico notes (historical)

replacement of analog-part of Commodore 1541-Floppy devices based on Pi-Pico(2)

## preface/credits ##
this project was derived from the original 1541-rebuild from Thorsten Kattanek (https://github.com/ThKattanek/1541-rebuild) !
parts of his code were taken from there and adopted for Raspberry Pico and modified to handle disk images differently. Thanks!

the C64 selector-programm was developed and implemented by Peiselulli !

thanks to [BensonRSI](https://github.com/BensonRSI) for adding debugging documentation, dev-containers and github-magic !

## Features ##

latest version:
- software: 1.6.1
- hardware: 1.6

### Hardware ###

single board, size 59mm x 60 mm

- Raspberry Pico2 socket/solder-pads
- VIA 40pin socket
- levelshifter (BSS138 & 74LVC4245) for stable signals
- connectors for
  - I2C Display
  - SPI SD-Card adapter
  - Rotary-Encoder + Switch (KY-040 compatible)
  - Write-Protect-Signal

one size fits for all 1541 models.

### Software ###

#### Pico2 Firmware ####

- mounting of D64 & G64 & PRG Files
- 35 & 42 track image files supported
- read and write access for both D64 & G64
- sd-card hotswap feature (refresh of directory content)

#### C64 Image Selector ####

- browsing through sd-card content via "virtual disk-image"
  - subdirectory support
  - 4 way scrolling
- highlighting and selecting of different file-types (D64,G64,PRG,Folder)
- simple mounting and also fastloading of selected entry


## how to build ##

> For the **current 1551-III product**, use **[How to build and flash (1551-III-Pico)](#how-to-build-and-flash-1551-iii-pico)** above.  
> The steps below are the old 1541-rePico / archival flow (`experimental/firmware/`).

### prepare tools (linux) ###

```
sudo apt install cmake ninja-build libusb-1.0-0-dev build-essential pkg-config python3 xxd gcc-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib acme
```

### pico-sdk ###

from : <https://github.com/raspberrypi/pico-sdk>

- clone this repo
- create a environment variable called "PICO_SDK_PATH" which points to this repo
- place a "export PICO_SDK_PATH= <path to your pico-sdk>" at the end of your .profile script
- then cd into this repo-folder and initialize the mbedtls submodule (picotool mentiones this)

all in one:
```
git clone https://github.com/raspberrypi/pico-sdk.git
export PICO_SDK_PATH=$(pwd)/pico-sdk
echo "export PICO_SDK_PATH=$PICO_SDK_PATH" >> ~/.profile"
cd pico-sdk
git submodule update --init lib/mbedtls
```

### picotool ###

from : <https://github.com/raspberrypi/picotool>

- clone this repo
- install the picotool as described in README.md and BUILDING.md file there

```
git clone https://github.com/raspberrypi/picotool.git
```

### build steps ###

Archival tree only:

```
cd experimental/firmware
mkdir build
cd build
cmake -G Ninja ..
ninja
```

## howto flash ##

```
picotool load -t uf2 1541-rePico.uf2 -x -f
```


## debugging with OpenOCD ##

### prerequisites ###

- **CMSIS-DAP Compatible Debugger** (e.g., Raspberry Pi Debug Probe, STLink, or SEGGER J-Link) 
get binaries for a pico here : https://github.com/raspberrypi/debugprobe
- **OpenOCD** installed ( built in devcontainer or  with "build_openocd.sh")
- **gdb-multiarch** for GDB debugging ( preinstalled in devcontainer )

### setup ###

1. Connect your debugger to the Pico using the SWD pins:
   - SWCLK → GPIO 24 (or pin 20)
   - SWDIO → GPIO 25 (or pin 21)
   - GND → GND

2. Ensure the debugger is connected via USB to your development machine

### starting OpenOCD ###

Start OpenOCD in a terminal:

```
openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg
```

OpenOCD will listen on port 3333 for GDB connections.

### debugging in VS Code ###

VS Code launch configurations are available:

**Pico Debug (Cortex-Debug)** - Integrated debugging with OpenOCD

#### using Cortex-Debug (recommended) ####

Press `F5` or select "Pico Debug (Cortex-Debug)" from the Run menu. This will:
- Start OpenOCD automatically
- Load your firmware
- Break at `main()`
- Allow step debugging, breakpoints, and variable inspection

#### using external OpenOCD ####

1. Start OpenOCD in a terminal (see above)
2. Select "Pico Debug (Cortex-Debug with external OpenOCD)" from Run menu
3. VS Code will connect to the running OpenOCD instance

### useful GDB commands ###

When debugging, common GDB commands include:

```
continue         # Resume execution
step             # Step into function
next             # Step over function
break <func>     # Set breakpoint at function
break <file>:<line>  # Set breakpoint at file:line
print <var>      # Print variable value
display <var>    # Show variable on each step
backtrace        # Show call stack
```

### troubleshooting ###

**"Device not found"**: 
- Check CMSIS-DAP debugger is connected
- Verify SWD pin connections
- Try `openocd -d` for debug output
- Connect the USB for the targetdevice, then the USB for debugprobe
( to keep correct order of /dev/ttyACMx )

**GDB connection failed**: 
- Ensure OpenOCD is running on port 3333
- Check firewall settings

# documentation #

## project documentation ##

t.b.d.

## supported disk formats ##

currently [D64](doc/D64.TXT) and [G64](doc/G64.TXT) are supported as for reading and writing.  
as bonus, **PRG** files can be loaded by an on-the-fly routine that creates a valid D64 image out of it.

additionaly a small tool [conv_x64](tools/) is provided that allows easy conversion from one to the other on you linux-pc.

## Links ##

- great collection of basics about disk-image-formats can be found here:  
<https://ist.uwaterloo.ca/~schepers/formats.html>

- forum64 project discussion thread (base of 1541-rebuild and 1541-rePico)  
<https://www.forum64.de/index.php?thread/59884-laufwerk-der-1541-emulieren>

