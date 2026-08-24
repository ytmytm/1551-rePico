/**********************************
 * Sorted directory listing: ".." first (subfolders), then dirs A–Z, then files A–Z.
 **********************************/
#ifndef DIR_LIST_H
#define DIR_LIST_H

#include <stdbool.h>
#include <stdint.h>
#include "ff.h"

#define DIR_LIST_MAX 128u

FRESULT dir_list_refresh(const char *path);
uint16_t dir_list_count(void);
bool dir_list_get(uint16_t index, FILINFO *out);

#endif
