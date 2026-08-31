/**********************************
 * user settings (rotary, flash)
 *
 * Author: 1551-rePico
 * Last change: 2026/08/31
 ***********************************/

#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdbool.h>
#include <stdint.h>

void settings_init_defaults(void);
void settings_boot_load(void);
bool settings_save_to_flash(void);
bool settings_load_from_flash(void);

bool settings_get_rotary_reversed(void);
bool settings_get_density_from_cpu(void);

void settings_set_rotary_reversed(bool reversed);
void settings_set_density_from_cpu(bool from_cpu);

#endif
