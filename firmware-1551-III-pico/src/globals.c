/**********************************
 * global variables & defines
 *
 * Author: F00K42
 * Last change: 2026/02/14
 ***********************************/

#include "globals.h"
#include "version.h"
#include "gui_constants.h"

const uint16_t d64_track_offset[MAX_TRACKS] = { 0x0000,0x0015,0x002A,0x003F,0x0054,0x0069,0x007E,0x0093,
                                                0x00A8,0x00BD,0x00D2,0x00E7,0x00FC,0x0111,0x0126,0x013B,
                                                0x0150,0x0165,0x0178,0x018B,0x019E,0x01B1,0x01C4,0x01D7,
                                                0x01EA,0x01FC,0x020E,0x0220,0x0232,0x0244,0x0256,0x0267,
                                                0x0278,0x0289,0x029A,0x02AB,0x02BC,0x02CD,0x02DE,0x02EF,
                                                0x0300,0x0311 };

const uint8_t d64_sector_count[NUM_SPEEDZONES] = {21,    //Spuren 1-17
                                                19,    //Spuren 18-24
                                                18,    //Spuren 25-30
                                                17};   //Spuren 31-42

const uint8_t d64_track_zone[MAX_TRACKS] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //Spuren 1-17
                                            1,1,1,1,1,1,1,                      //Spuren 18-24
                                            2,2,2,2,2,2,                        //Spuren 25-30
                                            3,3,3,3,3,3,3,3,3,3,3,3};           //Spuren 31-42

uint8_t d64_sector_puffer[21*D64_SECTOR_SIZE+5];


const uint8_t g64_head[] = {'G','C','R','-','1','5','4','1', G64_VERSION, G64_TRACKCOUNT*2, (G64_TRACKSIZE&0xff), ((G64_TRACKSIZE>>8)&0xff)};
uint32_t g64_jumptable[2*G64_TRACKCOUNT];
uint32_t g64_speedtable[2*G64_TRACKCOUNT];

const uint8_t g64_speedzones[NUM_SPEEDZONES] = { 3, 2, 1, 0};

uint16_t g64_tracklen[G64_TRACKCOUNT];

// enough space to store 42 tracks, each 7928 bytes byte length
uint8_t g64_tracks[G64_TRACKCOUNT][G64_TRACKSIZE];

uint8_t id1 = 0;    // id1 and id2 identify a floppy-disk
uint8_t id2 = 0;    // - these need to change to .. signal a disk-change or after a format...

// Originale Bitraten
//Zone 0: 8000000/26 = 307692 Hz    (ByteReady 38461.5 Hz)
//Zone 1: 8000000/28 = 285714 Hz    (ByteReady 35714.25 Hz)
//Zone 2: 8000000/30 = 266667 Hz    (ByteReady 33333.375 Hz)
//Zone 3: 8000000/32 = 250000 Hz    (ByteReady 31250 Hz)

//Höhere Werte verlangsammen die Bitrate (=us delay-values between bytes)
// Pi1551-III: same speed-zone tables as 1541-rePico upstream (#else in firmware/globals.c).
const int64_t bytetimer_values[NUM_SPEEDZONES] = {26, 28, 30, 32};
const uint8_t d64_sector_gap[NUM_SPEEDZONES] = {12, 21, 16, 13};

bool block_data_changes = false;

const char* version_str = product_version_name_s " " VERSION " BY FOOK42 & PEISELULLI";
