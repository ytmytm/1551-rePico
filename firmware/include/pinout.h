/**********************************
 * header - pinout assignment for Pico2 to baseboard
 *
 * Author: F00K42
 * Last change: 2026/02/15
***********************************/
#include "hardware/spi.h"

// Gate-array / 1551 bus connection (GPIO numbers shared across targets)
// 1551: GPIO0=PHI0(PWM), GPIO1=MODE, GPIO3=IRQ-exp(PWM), GPIO8..15=YB0..7
#define GPIO_SOE    0
#define GPIO_OE     1
#define GPIO_SYNC   2
#define GPIO_SOE_GA 3
#define GPIO_MTR    4
#define GPIO_WPS    5
#define GPIO_STP0   6
#define GPIO_STP1   7

#define GPIO_PAPORT 8  //defines the first bit of 8
#define PAPORT_MASK (uint32_t)(0xFF<<GPIO_PAPORT)
/*
#define GPIO_PA0    8
#define GPIO_PA1    9
#define GPIO_PA2    10
#define GPIO_PA3    11
#define GPIO_PA4    12
#define GPIO_PA5    13
#define GPIO_PA6    14
#define GPIO_PA7    15
*/

// SPI defines
#define SPI_PORT    spi0
#define SPI_MISO    16
#define SPI_CS      17
#define SPI_SCK     18
#define SPI_MOSI    19

// I2C defines
#define I2C_PORT    i2c0
#define I2C_SDA     20
#define I2C_SCL     21

// 3 für den Drück-Dreh-Schalter
#define GPIO_BT1    27
#define GPIO_BT2    26
#define GPIO_BT3    28

#define GPIO_BRDY   22
