/**********************************
 * header - global variables & defines
 *
 * Author: F00K42
 * Last change: 2026/02/14
 ***********************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdint.h>
#include "pico/stdlib.h"
#include "display.h"


/////
#define LCD_LINE_COUNT  display_row_count
#define LCD_LINE_SIZE   display_col_count

// Spur auf dem der Lesekopf beim Start/Reset stehen soll
// Track 17 --> Directory (Tracks 0..41 !)
#define DIRECTORY_TRACK (17)
#define INIT_TRACK      DIRECTORY_TRACK
#define MENU_DATA_TRACK (16)
#define SELECTOR_TRACK  (18)

#define PRGFILE_TRACK   (16)  // we have Tracks 0..16 to store a PRG file into
#define SCRATCH_TRACK   (18)  // we use Tracks 18..41 for preparing the PRG data

#define CBMDOS_TYPE_PRG (0x82)

// offset inside directory track of ID1+ID2
#define DIR_ID_OFFSET   (0xA2)

#define MAX_TRACKS      (42)
#define NUM_SPEEDZONES  (4)

#define GCR_SYNCMARK    (0xFF)
// *** definition of GCR-structure
// see: https://ist.uwaterloo.ca/~schepers/formats/G64.TXT

#define G64_VERSION     (0x00)
#define G64_TRACKCOUNT  MAX_TRACKS
#define G64_TRACKSIZE   (7928)  // = 0x1ef8

extern const uint16_t d64_track_offset[MAX_TRACKS];
extern const uint8_t d64_sector_count[NUM_SPEEDZONES];
extern const uint8_t d64_track_zone[MAX_TRACKS];

#define D64_SECTOR_SIZE (256)
extern uint8_t d64_sector_puffer[21*D64_SECTOR_SIZE+5];

extern const uint8_t g64_head[12];
extern uint32_t g64_jumptable[2*G64_TRACKCOUNT];
extern uint32_t g64_speedtable[2*G64_TRACKCOUNT];

#define G64_HEADERSIZE (sizeof(g64_head)+sizeof(g64_jumptable)+sizeof(g64_speedtable)) // should be 684 bytes

extern const uint8_t g64_speedzones[NUM_SPEEDZONES];

extern uint16_t g64_tracklen[G64_TRACKCOUNT];

// enough space to store 42 tracks, each 7928 bytes byte length
extern uint8_t g64_tracks[G64_TRACKCOUNT][G64_TRACKSIZE];

extern uint8_t id1;    // id1 and id2 identify a floppy-disk
extern uint8_t id2;    // - these need to change to .. signal a disk-change or after a format...

enum {UNDEF_IMAGE, G64_IMAGE, D64_IMAGE, PRG_IMAGE, SELECTOR_IMAGE};

extern int64_t bytetimer_values[NUM_SPEEDZONES];

extern uint8_t d64_sector_gap[NUM_SPEEDZONES];

#define HEADER_GAP_BYTES (9)

// Zeit die nach der letzten Stepperaktivität vergehen muss, um einen neuen Track von SD Karte zu laden
// (1541 Original Rom schaltet STP1 alle 15ms)
// Default 15
#define STEPPER_DELAY_TIME (5)

extern bool block_data_changes;

extern const char* version_str;
#endif
