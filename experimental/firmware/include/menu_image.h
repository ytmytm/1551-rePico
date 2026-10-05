/**********************************
 * header - generate menu image header
 *
 * Author: F00K42
 * Last change: 2026/05/08
 ***********************************/

#ifndef _MENU_IMAGE_H
#define _MENU_IMAGE_H

#include <stdint.h>
#include "hw_config.h"
#include "f_util.h"
#include "ff.h"

enum {
    TYPE_NONE = 0,
    TYPE_DIR = 1,
    TYPE_D64 = 2,
    TYPE_G64 = 3,
    TYPE_PRG = 4,
    TYPE_VALID = 255,
    TYPE_UNKNOWN = 255
};

void generate_empty_image(uint8_t image_id1, uint8_t image_id2, uint8_t track_number);
void generate_bam(const char* const image_name, const uint8_t* const image_id_buffer);

void generate_directory_entry(const uint8_t* filename, const uint8_t filetype, const uint8_t des_track, const uint8_t des_sector, const uint16_t size);
size_t generate_menu_file(DIR* dir_obj, const uint8_t* dir_path, const uint8_t dest_track);

#endif