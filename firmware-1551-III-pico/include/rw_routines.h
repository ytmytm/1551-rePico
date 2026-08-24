/**********************************
 * header - read and write image routines
 *
 * Author: F00K42
 * Last change: 2026/02/14
 ***********************************/

#ifndef _RWROUTINES_H_
#define _RWROUTINES_H_

#include <stdint.h>
#include "hw_config.h"
#include "f_util.h"
#include "ff.h"

int8_t read_disk(FIL* fd, const int image_type, FILINFO fileinfo);
int8_t write_disk(FIL* fd, const int image_type, const uint8_t num_tracks);

void convert_d64track2gcr(uint8_t track_nr, uint8_t image_id1, uint8_t image_id2);
void convert_gcr2d64track(uint8_t track_nr);

size_t buffer_to_track(uint8_t* buffer, size_t buffer_len, uint8_t track_nr, uint8_t* last_sector);

#endif
