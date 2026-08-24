/**********************************
 * user settings (zone0 timing, rotary, flash)
 *
 * Author: 1551-rePico
 * Last change: 2026/07/18
 ***********************************/

#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdbool.h>
#include <stdint.h>

#define ZONE0_TIMER_MIN  24u
#define ZONE0_TIMER_MAX  36u
#define ZONE0_GAP_MIN    8u
#define ZONE0_GAP_MAX    28u

void settings_init_defaults(void);
void settings_boot_load(void);
bool settings_save_to_flash(void);
bool settings_load_from_flash(void);

void settings_apply(bool gap_changed);

uint8_t settings_get_zone0_timer(void);
uint8_t settings_get_zone0_gap(void);
bool settings_get_rotary_reversed(void);
bool settings_get_density_from_cpu(void);

void settings_set_zone0_timer(uint8_t us);
void settings_set_zone0_gap(uint8_t gap);
void settings_set_rotary_reversed(bool reversed);
void settings_set_density_from_cpu(bool from_cpu);

#endif
