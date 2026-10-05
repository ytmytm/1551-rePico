/**********************************
 * user settings (zone0 timing, rotary, flash)
 *
 * Author: 1551-rePico
 * Last change: 2026/07/18
 ***********************************/

#include "settings.h"
#include "globals.h"
#include "rw_routines.h"
#include "hardware/flash.h"
#include "hardware/sync.h"
#include <string.h>

#define SETTINGS_MAGIC0  'R'
#define SETTINGS_MAGIC1  '4'
#define SETTINGS_MAGIC2  'S'
#define SETTINGS_MAGIC3  'T'
#define SETTINGS_VERSION 1u

/* Last flash sector — safe for Pico / Pico 2 user data */
#define SETTINGS_FLASH_OFFSET  (PICO_FLASH_SIZE_BYTES - FLASH_SECTOR_SIZE)

typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t zone0_timer_us;
    uint8_t zone0_gap;
    uint8_t rotary_reversed;
    uint8_t reserved;
    uint16_t crc16;
} settings_blob_t;

static uint8_t zone0_timer_us;
static uint8_t zone0_gap;
static bool rotary_reversed;

/* Emulation hooks from main.c (avoid including main.h — it defines globals) */
extern bool is_image_mount;
extern uint8_t akt_image_type;
extern volatile uint8_t akt_half_track;
extern volatile bool send_byte_ready;
extern void start_bytetimer(uint8_t half_track);
extern void stop_bytetimer(void);

static uint16_t crc16_ccitt(const uint8_t *data, size_t len)
{
    uint16_t crc = 0xFFFFu;
    for (size_t i = 0; i < len; ++i)
    {
        crc ^= (uint16_t)data[i] << 8;
        for (uint8_t b = 0; b < 8; ++b)
        {
            if (crc & 0x8000u)
                crc = (uint16_t)((crc << 1) ^ 0x1021u);
            else
                crc <<= 1;
        }
    }
    return crc;
}

static bool bounds_ok(uint8_t timer, uint8_t gap)
{
    return (timer >= ZONE0_TIMER_MIN) && (timer <= ZONE0_TIMER_MAX)
        && (gap >= ZONE0_GAP_MIN) && (gap <= ZONE0_GAP_MAX);
}

static void rebuild_zone0_gcr(void)
{
    if (!is_image_mount)
        return;
    if ((G64_IMAGE == akt_image_type) || (UNDEF_IMAGE == akt_image_type))
        return;

    stop_bytetimer();
    send_byte_ready = false;

    for (uint8_t track_nr = 0; track_nr < MAX_TRACKS; ++track_nr)
    {
        if (0 != d64_track_zone[track_nr])
            continue;
        convert_gcr2d64track(track_nr);
        convert_d64track2gcr(track_nr, id1, id2);
    }

    send_byte_ready = true;
    start_bytetimer(akt_half_track);
}

void settings_init_defaults(void)
{
#if REPICO1551
    zone0_timer_us = 28;
    zone0_gap = 21;
#else
    zone0_timer_us = 26;
    zone0_gap = 12;
#endif
    rotary_reversed = false;
    bytetimer_values[0] = zone0_timer_us;
    d64_sector_gap[0] = zone0_gap;
}

void settings_apply(bool gap_changed)
{
    bytetimer_values[0] = zone0_timer_us;
    d64_sector_gap[0] = zone0_gap;

    if (is_image_mount)
    {
        if (gap_changed)
            rebuild_zone0_gcr();
        else
        {
            stop_bytetimer();
            start_bytetimer(akt_half_track);
        }
    }
}

void settings_boot_load(void)
{
    settings_init_defaults();
    (void)settings_load_from_flash();
}

bool settings_save_to_flash(void)
{
    settings_blob_t blob;
    memset(&blob, 0, sizeof(blob));
    blob.magic[0] = SETTINGS_MAGIC0;
    blob.magic[1] = SETTINGS_MAGIC1;
    blob.magic[2] = SETTINGS_MAGIC2;
    blob.magic[3] = SETTINGS_MAGIC3;
    blob.version = SETTINGS_VERSION;
    blob.zone0_timer_us = zone0_timer_us;
    blob.zone0_gap = zone0_gap;
    blob.rotary_reversed = rotary_reversed ? 1u : 0u;
    blob.crc16 = crc16_ccitt((const uint8_t *)&blob, sizeof(blob) - sizeof(blob.crc16));

    uint8_t page[FLASH_PAGE_SIZE];
    memset(page, 0xFFu, sizeof(page));
    memcpy(page, &blob, sizeof(blob));

    bool was_mount = is_image_mount;
    if (was_mount)
        stop_bytetimer();

    uint32_t ints = save_and_disable_interrupts();
    flash_range_erase(SETTINGS_FLASH_OFFSET, FLASH_SECTOR_SIZE);
    flash_range_program(SETTINGS_FLASH_OFFSET, page, FLASH_PAGE_SIZE);
    restore_interrupts(ints);

    if (was_mount)
        start_bytetimer(akt_half_track);

    const settings_blob_t *stored =
        (const settings_blob_t *)(XIP_BASE + SETTINGS_FLASH_OFFSET);
    if ((stored->magic[0] != SETTINGS_MAGIC0) || (stored->crc16 != blob.crc16))
        return false;
    return true;
}

bool settings_load_from_flash(void)
{
    const settings_blob_t *blob =
        (const settings_blob_t *)(XIP_BASE + SETTINGS_FLASH_OFFSET);

    if ((blob->magic[0] != SETTINGS_MAGIC0) || (blob->magic[1] != SETTINGS_MAGIC1)
        || (blob->magic[2] != SETTINGS_MAGIC2) || (blob->magic[3] != SETTINGS_MAGIC3))
        return false;
    if (blob->version != SETTINGS_VERSION)
        return false;

    uint16_t crc = crc16_ccitt((const uint8_t *)blob, sizeof(*blob) - sizeof(blob->crc16));
    if (crc != blob->crc16)
        return false;
    if (!bounds_ok(blob->zone0_timer_us, blob->zone0_gap))
        return false;

    uint8_t old_gap = zone0_gap;
    zone0_timer_us = blob->zone0_timer_us;
    zone0_gap = blob->zone0_gap;
    rotary_reversed = (0 != blob->rotary_reversed);
    settings_apply(old_gap != zone0_gap);
    return true;
}

uint8_t settings_get_zone0_timer(void) { return zone0_timer_us; }
uint8_t settings_get_zone0_gap(void) { return zone0_gap; }
bool settings_get_rotary_reversed(void) { return rotary_reversed; }

void settings_set_zone0_timer(uint8_t us)
{
    if (us < ZONE0_TIMER_MIN) us = ZONE0_TIMER_MIN;
    if (us > ZONE0_TIMER_MAX) us = ZONE0_TIMER_MAX;
    if (us == zone0_timer_us)
        return;
    zone0_timer_us = us;
    settings_apply(false);
}

void settings_set_zone0_gap(uint8_t gap)
{
    if (gap < ZONE0_GAP_MIN) gap = ZONE0_GAP_MIN;
    if (gap > ZONE0_GAP_MAX) gap = ZONE0_GAP_MAX;
    if (gap == zone0_gap)
        return;
    zone0_gap = gap;
    settings_apply(true);
}

void settings_set_rotary_reversed(bool reversed)
{
    rotary_reversed = reversed;
}
