# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.1.1)
set(toolchainVersion 14_2_Rel1)
set(picotoolVersion 2.1.1)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2 CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(1551-III-Pico C CXX ASM)

option(REPICO1551 "Build for 1551-rePico hardware" ON)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

if(REPICO1551)
    # Plus/4 selector PRGs — do not build SoftwareC64 / dali for this target
    add_subdirectory(./SoftwareC16)
else()
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../experimental/firmware/buildtools)
    add_subdirectory(./SoftwareC64)
endif()

file(GLOB_RECURSE FIRMWARE_SOURCES CONFIGURE_DEPENDS "src/*.c")

add_executable(1551-III-Pico ${FIRMWARE_SOURCES})

add_dependencies(1551-III-Pico GenSelector)
if(NOT REPICO1551)
    add_dependencies(1551-III-Pico GenIntro)
endif()

if(REPICO1551)
    target_compile_definitions(1551-III-Pico PRIVATE REPICO1551=1)
    pico_set_program_name(1551-III-Pico "1551-III-Pico")
else()
    target_compile_definitions(1551-III-Pico PRIVATE REPICO1541=1 REPICO1551=0)
    pico_set_program_name(1551-III-Pico "1541-rePico")
endif()

pico_set_program_version(1551-III-Pico "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(1551-III-Pico 0)
pico_enable_stdio_usb(1551-III-Pico 1)

target_include_directories(1551-III-Pico PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_LIST_DIR}
)

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../no-OS-FatFS-SD-SDIO-SPI-RPi-Pico/src build)

target_link_libraries(1551-III-Pico
        pico_stdlib
        pico_multicore
        hardware_i2c
        hardware_dma
        hardware_pio
        hardware_interp
        hardware_timer
        hardware_clocks
        hardware_pwm
        hardware_spi
        hardware_flash
        no-OS-FatFS-SD-SDIO-SPI-RPi-Pico
)

pico_add_extra_outputs(1551-III-Pico)
