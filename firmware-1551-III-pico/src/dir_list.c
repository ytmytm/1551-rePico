/**********************************
 * Sorted directory listing cache (case-insensitive by filename)
 **********************************/
#include "dir_list.h"
#include <string.h>

extern DIR dir_object;

static FILINFO dir_list_cache[DIR_LIST_MAX];
static uint16_t dir_list_entry_count;
static char dir_list_path[512];

static bool dir_list_is_dir(const FILINFO *info)
{
    return 0 != (info->fattrib & AM_DIR);
}

static int dir_list_icase_cmp(const char *sa, const char *sb)
{
    while (0 != *sa && 0 != *sb)
    {
        char ca = *sa++;
        char cb = *sb++;
        if (ca >= 'A' && ca <= 'Z')
            ca = (char)(ca + ('a' - 'A'));
        if (cb >= 'A' && cb <= 'Z')
            cb = (char)(cb + ('a' - 'A'));
        if (ca != cb)
            return (int)ca - (int)cb;
    }
    return (int)*sa - (int)*sb;
}

static int dir_list_entry_cmp(const void *a, const void *b)
{
    const FILINFO *fa = (const FILINFO *)a;
    const FILINFO *fb = (const FILINFO *)b;
    const bool da = dir_list_is_dir(fa);
    const bool db = dir_list_is_dir(fb);

    if (da != db)
        return da ? -1 : 1;

    return dir_list_icase_cmp(fa->fname, fb->fname);
}

FRESULT dir_list_refresh(const char *path)
{
    if ((NULL == path) || (0 == path[0]))
        return FR_INVALID_NAME;

    dir_list_entry_count = 0;

    f_closedir(&dir_object);

    char pattern[] = {"*"};
    dir_object.pat = pattern;
    FRESULT fr = f_opendir(&dir_object, path);
    if (FR_OK != fr)
        return fr;

    if (1u < strlen(path))
    {
        strcpy(dir_list_cache[0].fname, "..");
        dir_list_cache[0].fattrib = AM_DIR;
        dir_list_cache[0].fsize = 0;
        dir_list_entry_count = 1u;
    }

    while (dir_list_entry_count < DIR_LIST_MAX)
    {
        FILINFO entry;
        fr = f_readdir(&dir_object, &entry);
        if ((FR_OK != fr) || (0 == entry.fname[0]))
            break;
        dir_list_cache[dir_list_entry_count++] = entry;
    }

    const uint16_t sort_start = (1u < strlen(path)) ? 1u : 0u;
    if (dir_list_entry_count > sort_start)
    {
        for (uint16_t i = (uint16_t)(sort_start + 1u); i < dir_list_entry_count; ++i)
        {
            FILINFO tmp = dir_list_cache[i];
            uint16_t j = i;
            while (j > sort_start && dir_list_entry_cmp(&dir_list_cache[j - 1u], &tmp) > 0)
            {
                dir_list_cache[j] = dir_list_cache[j - 1u];
                --j;
            }
            dir_list_cache[j] = tmp;
        }
    }

    strncpy(dir_list_path, path, sizeof(dir_list_path) - 1u);
    dir_list_path[sizeof(dir_list_path) - 1u] = 0;
    return FR_OK;
}

uint16_t dir_list_count(void)
{
    return dir_list_entry_count;
}

bool dir_list_get(uint16_t index, FILINFO *out)
{
    if ((NULL == out) || (index >= dir_list_entry_count))
        return false;
    *out = dir_list_cache[index];
    return true;
}
