/**********************************
 * 74HCT165 shift register (U19) on 1551-III-Pico
 *
 * JP1..JP3 bridged 1-2: GPIO26=/PL, GPIO27=CP, GPIO28=Q7
 * Bit order matches hardware-1551-III-Pico/test_hardware_model.py
***********************************/
#ifndef SHIFT165_H
#define SHIFT165_H

#include <stdbool.h>
#include <stdint.h>

#define SHIFT165_BIT_ROT_SW      0u
#define SHIFT165_BIT_ROT_CLK     1u
#define SHIFT165_BIT_ROT_DT      2u
#define SHIFT165_BIT_DS0         3u
#define SHIFT165_BIT_DS1         4u
#define SHIFT165_BIT_SD_CD       5u
#define SHIFT165_BIT_SW4_BACK    6u
#define SHIFT165_BIT_SW5_INSERT  7u

void shift165_init(void);
uint8_t shift165_poll(void);

uint8_t shift165_last_byte(void);
bool shift165_line_high(uint8_t bit_index);
bool shift165_sd_card_present(void);

/* 1551 FDC port DS0/DS1 (bits 5/6) -> speed zone 0..3 */
uint8_t shift165_density_zone_from_byte(uint8_t value);
uint8_t shift165_density_zone(void);

#endif
