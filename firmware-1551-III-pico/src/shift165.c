/**********************************
 * 74HCT165 parallel-load shift register inputs for Pi1551-III front panel
***********************************/
#include "pico/stdlib.h"

#include "shift165.h"
#include "pinout.h"

static uint8_t shift165_value;

static uint8_t shift165_read_byte(void)
{
    gpio_put(GPIO_SERIAL_LOAD, false);
    sleep_us(2);
    gpio_put(GPIO_SERIAL_LOAD, true);
    sleep_us(2);

    uint8_t value = 0;
    for (uint8_t i = 0; i < 8u; ++i)
    {
        value = (uint8_t)((value << 1) | (gpio_get(GPIO_SERIAL_DT) ? 1u : 0u));
        gpio_put(GPIO_SERIAL_CLK, true);
        sleep_us(2);
        gpio_put(GPIO_SERIAL_CLK, false);
        sleep_us(2);
    }
    return value;
}

void shift165_init(void)
{
    gpio_init(GPIO_SERIAL_LOAD);
    gpio_init(GPIO_SERIAL_CLK);
    gpio_init(GPIO_SERIAL_DT);
    gpio_set_dir(GPIO_SERIAL_LOAD, GPIO_OUT);
    gpio_set_dir(GPIO_SERIAL_CLK, GPIO_OUT);
    gpio_set_dir(GPIO_SERIAL_DT, GPIO_IN);
    gpio_set_pulls(GPIO_SERIAL_DT, true, false);
    gpio_put(GPIO_SERIAL_LOAD, true);
    gpio_put(GPIO_SERIAL_CLK, false);

    shift165_value = shift165_read_byte();
}

uint8_t shift165_poll(void)
{
    shift165_value = shift165_read_byte();
    return shift165_value;
}

uint8_t shift165_last_byte(void)
{
    return shift165_value;
}

bool shift165_line_high(uint8_t bit_index)
{
    return 0 != (shift165_value & (1u << bit_index));
}

bool shift165_sd_card_present(void)
{
    /* SD_CD is pulled up; socket pulls low when a card is inserted. */
    return !shift165_line_high(SHIFT165_BIT_SD_CD);
}

uint8_t shift165_density_zone_from_byte(uint8_t value)
{
    /* Matches 1551 ROM: zone index << 5 onto CPU port bits 5 (DS0) and 6 (DS1). */
    bool ds0 = 0 != (value & (1u << SHIFT165_BIT_DS0));
    bool ds1 = 0 != (value & (1u << SHIFT165_BIT_DS1));
    return (uint8_t)((ds0 ? 1u : 0u) | (ds1 ? 2u : 0u));
}

uint8_t shift165_density_zone(void)
{
    return shift165_density_zone_from_byte(shift165_value);
}
