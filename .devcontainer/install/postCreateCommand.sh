#!/bin/bash

#
# Users host Gitconfig is copied by default into the devcontainer which can lead to
# issues with local paths. Therefore, some settings are removed or overwritten
# accordingly. See also
#   https://github.com/microsoft/vscode-remote-release/issues/4632
#   https://github.com/microsoft/vscode-remote-release/issues/4603
#

sudo usermod -aG plugdev vscode
WS=`pwd`
echo "Working in $WS"
sudo cp $WS/.devcontainer/install/*.rules /etc/udev/rules.d/

echo "checking for picoSDK"
if [[ ! -d build/pico-sdk ]]; then
    echo "Cloning picoSDK"
    git clone https://github.com/raspberrypi/pico-sdk.git build/pico-sdk
    export PICO_SDK_PATH=$(pwd)/build/pico-sdk
    echo "export PICO_SDK_PATH=$PICO_SDK_PATH" >> ~/.profile
fi
# Always ensure USB + crypto submodules (needed for pico_enable_stdio_usb).
cd build/pico-sdk
git submodule update --init lib/mbedtls lib/tinyusb
cd "${WS}"

echo "checking for openocd for RP2350"
if [[ ! -f build/openocd_rp2350 ]]  && [[ ${BUILD_OPENOCD} == "ON" ]]; then
    echo "Installing OpenOCD for RP2350"
    $WS/.devcontainer/install/build_openocd.sh 
    touch build/openocd_rp2350
    cd ${WS}
fi

if [[ ! -f /usr/bin/xxd ]]; then
    cd build
    wget https://github.com/ckormanyos/xxd/releases/download/v1.2/xxd-x86_64-linux-gnu.tar.gz
    tar -xzf xxd-x86_64-linux-gnu.tar.gz
    sudo mv xxd-x86_64-linux-gnu/xxd /usr/bin/xxd
    rm -rf xxd-x86_64-linux-gnu
    rm xxd-x86_64-linux-gnu.tar.gz
    cd ${WS}
fi

cd /usr/bin
echo "checking for picotool with load function"
if [[ ! -f picotool ]]; then
    sudo cp $WS/.devcontainer/install/picotool .
fi



echo "checking for multiarch binaries"
if [[ ! -e objdump-multiarch ]]; then
    echo "Ubuntun 24.04 has no special multiarch binaries anymore"
    sudo ln -s /usr/bin/objdump objdump-multiarch  
    sudo ln -s /usr/bin/nm nm-multiarch 
fi
 
cd -