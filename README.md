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
| `no-OS-FatFS-SD-SDIO-SPI-RPi-Pico/` | Shared FatFs/SD submodule |
| `experimental/` | **Archival only** — early plug-over-1551-mainboard daughterboard + old 1541-derived firmware (see `experimental/README.md`) |

Upstream 1541-rePico is not merged further; useful changes may be cherry-picked into `firmware-1551-III-pico` by hand.

## Architecture vs a stock 1551

Compared to an original Commodore 1551 drive, the roles split like this:

| Stock 1551 | This board |
|------------|------------|
| **6510T** CPU | Same **6510T**, or a [MOS CPU Replacer](https://github.com/monotech/MOS_CPU_Replacer) in that socket |
| ~2 KB SRAM | **32 KB** SRAM (`KM62256`) with a **1551-RAMBoard-style** map: `$0000–$3FFF` + `$8000–$9FFF` (extra RAM window; decode in the CPLD) |
| ~16 KB ROM | **64 KB** EPROM (`27C512`): two **32 KB** DOS images, selected by jumper **J2** |
| Device #8 / #9 (hardware strap) | Jumper / strap for **device 8 or 9** (same idea as stock) |
| **6523** TPI (Tri-Port Interface) + discrete address decode | **XC9572XL CPLD** (`hdl-1551-III/` Fake6523): TPI replacement **and** RAM/ROM chip-select decode |
| Analog floppy + mech | **Pico2** emulates the analog path and runs the UI |

**Pico2** responsibilities:

- Front-panel **UI**: OLED, rotary encoder, Back/Insert buttons (via 74HCT165 shift register, same panel as Pi1551-III)
- **SD card**: FatFs images (D64/G64/PRG), directory browser / Load Selector, **card-detect hotplug** (eject/remount + rebuild selector list; sockets without a CD switch still work)
- Floppy **datastream**: GCR byte stream to/from the “head”, **BYTE_READY** / related timing
- **Stepper** lines and **density** (DS0/DS1 from the CPU when that option is enabled)
- **Write-protect / disk-change** sensing toward the 1551 firmware (WPS), activity LED, and the 2 MHz **Phi0** clock for the 6502 side

Host link is unchanged in concept: the assembled drive talks **TCBM** over a ribbon to **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)**.

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

- Main PCB: `hardware-1551-III-Pico/` (KiCad)
- CPLD: program [`hdl-1551-III/Fake6523.jed`](hdl-1551-III/Fake6523.jed) into the XC9572XL. The `.jed` was built with [Xilinx ISE 14.7](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html) (sources/project live in `hdl-1551-III/`). Rebuild and JTAG flash steps (a Raspberry Pi 3 and jumper wires are enough — no dedicated programmer) are documented in [plus4-tcbm2sd → CPLD firmware](https://github.com/ytmytm/plus4-tcbm2sd/blob/main/HardwareFirmware.md#cpld-firmware); the procedure is the same for this board.
- Front panel, faceplates, mechanical assembly: follow **[Pi1551-III](https://github.com/ytmytm/Pi1551-III)**
- Host adapter: **[plus4-tcbm2sd](https://github.com/ytmytm/plus4-tcbm2sd)** + ribbon cable

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

currently [D64](/doc/D64.TXT) and [G64](/doc/G64.TXT) are supported as for reading and writing.  
as bonus, **PRG** files can be loaded by an on-the-fly routine that creates a valid D64 image out of it.

additionaly a small tool [conv_x64](/tools) is provided that allows easy conversion from one to the other on you linux-pc.

## Links ##

- great collection of basics about disk-image-formats can be found here:  
<https://ist.uwaterloo.ca/~schepers/formats.html>

- forum64 project discussion thread (base of 1541-rebuild and 1541-rePico)  
<https://www.forum64.de/index.php?thread/59884-laufwerk-der-1541-emulieren>

