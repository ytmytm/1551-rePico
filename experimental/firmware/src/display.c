/**********************************
 * routines for display
 *
 * Author: F00K42
 * Last change: 2026/02/09
***********************************/
#include "display.h"

extern uint8_t DEV_I2C_ADDR;

uint8_t display_init(void)
{
    my_i2c_init();

    // find display
    DEV_I2C_ADDR = 0;
    for (uint8_t i2c_addr = 0x20; i2c_addr<=0x3f; ++i2c_addr)
    {
        if ((0x27 < i2c_addr) && (0x38 > i2c_addr)) { continue; }

        if (my_i2c_test(i2c_addr))
        {
            DEV_I2C_ADDR = i2c_addr;
            break;
        }
    }

    if ((OLED_I2C_ADDR_0 == DEV_I2C_ADDR) ||
        (OLED_I2C_ADDR_1 == DEV_I2C_ADDR))
    {
        // OLED attached via I2C
        display_setup       = &oled_setup;
        display_clear       = &oled_clear;
        display_data        = &oled_data;
        display_generatechar= &oled_generatechar;
        display_home        = &oled_home;
        display_print       = &oled_print;
        display_setcursor   = &oled_setcursor;
        display_string      = &oled_string;
        display_setbright   = &oled_setbright;
    } else {
        // -> we may have an LCD attached
        display_setup       = &lcd_setup;
        display_clear       = &lcd_clear;
        display_data        = &lcd_data;
        display_generatechar= &lcd_generatechar;
        display_home        = &lcd_home;
        display_print       = &lcd_print;
        display_setcursor   = &lcd_setcursor;
        display_string      = &lcd_string;
        display_setbright   = &lcd_setbright;

        // select which low-level routines to use for communication with the display
        if (0 != DEV_I2C_ADDR)
        {
            // LCD attached via PCF8574 / I2C
            lcd_out = &pcf_lcd_out;
        } else {
            // TODO: error-handling .. no display attached
            lcd_out = &error_lcd_out;
        }
    }

    // call the right display setup routine.
    display_setup();

    return 1;
}


char* dez2out(int32_t value, uint8_t digits, char* dest)
{
    const int32_t   _dez[]={1,10,100,1000,10000,100000,1000000,10000000};
    bool            show = true;

    if ((0 == digits) || (7 < digits))
    {
        digits = 8;
        show = false;
    }
    if (0 > value)
    {
        *dest++='-';
        value=-value;
    }
    while (0 < digits)
    {
        --digits;
        uint8_t c = value/_dez[digits];
        if ((true == show) || (0 != c) || (0 == digits))
        {
            show = true;
            *dest++=c+'0';
        }
        value=value%_dez[digits];
    }
    *dest=0;
    return dest;
}

char* hex2out(uint32_t dez, uint8_t digits, char* dest)
{
    bool show = true;
    if (0 == digits)
    {
        digits = 8;
        show = false;
    }
    while (0 < digits)
    {
        --digits;
        uint8_t c=(dez>>(digits<<2))&0x0F;
        if ((true == show) || (0 != c) || (0 == digits))
        {
            show = true;
            if (c>9) { c+=7; }
            *dest++=c+'0';
        }
    }
    *dest=0;
    return dest;
}
