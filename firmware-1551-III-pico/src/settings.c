/**********************************
 * user settings (rotary, flash)
 *
 * Author: 1551-rePico
 * Last change: 2026/08/31
 ***********************************/

#include "settings.h"
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
    uint8_t zone0_timer_us;   /* legacy v1 field, ignored */
    uint8_t zone0_gap;        /* legacy v1 field, ignored */
    uint8_t rotary_reversed;
    uint8_t reserved;
    uint16_t crc16;
} settings_blob_t;

static bool rotary_reversed;
static bool density_from_cpu;

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

void settings_init_defaults(void)
{
    rotary_reversed = false;
    density_from_cpu = false;
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
    blob.rotary_reversed = rotary_reversed ? 1u : 0u;
    blob.reserved = density_from_cpu ? 1u : 0u;
    blob.crc16 = crc16_ccitt((const uint8_t *)&blob, sizeof(blob) - sizeof(blob.crc16));

    uint8_t page[FLASH_PAGE_SIZE];
    memset(page, 0xFFu, sizeof(page));
    memcpy(page, &blob, sizeof(blob));

    uint32_t ints = save_and_disable_interrupts();
    flash_range_erase(SETTINGS_FLASH_OFFSET, FLASH_SECTOR_SIZE);
    flash_range_program(SETTINGS_FLASH_OFFSET, page, FLASH_PAGE_SIZE);
    restore_interrupts(ints);

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

    rotary_reversed = (0 != blob->rotary_reversed);
    density_from_cpu = (0 != blob->reserved);
    return true;
}

bool settings_get_rotary_reversed(void) { return rotary_reversed; }
bool settings_get_density_from_cpu(void) { return density_from_cpu; }

void settings_set_rotary_reversed(bool reversed)
{
    rotary_reversed = reversed;
}

void settings_set_density_from_cpu(bool from_cpu)
{
    density_from_cpu = from_cpu;
}
