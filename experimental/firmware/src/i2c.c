/* basic i2c routines for Pico2 */
// implementation: F00K42
// last change: 11/10/2025

#include "i2c.h"

uint8_t DEV_I2C_ADDR;

void my_i2c_init(void)
{
    // I2C Initialisation. Using it at 100Khz.
    i2c_init(I2C_PORT, 400*1000);
    
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);
}

////////////////////////////////////////////////////////////////////////////////
// Testet eine I2C-Addresse auf Antwort
bool my_i2c_test(uint8_t addr)
{
    uint8_t rxdata;
    return i2c_read_blocking(I2C_PORT, addr, &rxdata, 1, false) >= 0;
}
