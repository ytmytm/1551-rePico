/* mymenu definition */
// last change: 18/07/2026

#ifndef MYMENUE_H
#define MYMENUE_H

#include "menu.h"
#include "settings.h"

MENU_STRUCT main_menu;
MENU_STRUCT image_menu;
MENU_STRUCT settings_menu;
MENU_STRUCT info_menu;

enum  MENU_IDS{M_BACK, M_IMAGE, M_SETTINGS, M_INFO, \
               M_BACK_IMAGE, M_MENU_IMAGE, M_LOAD_IMAGE, M_SAVE_IMAGE, M_UNLOAD_IMAGE, M_RELOAD_DISK, M_WP_IMAGE, M_NEW_IMAGE, \
               M_BACK_SETTINGS, M_Z0_TIMER, M_Z0_GAP, M_REV_ROTARY, M_LOAD_SETTINGS, M_SAVE_SETTINGS, M_RESTART, \
               M_BACK_INFO, M_VERSION_INFO, M_SDCARD_INFO};

/// Hauptmenü
MENU_ENTRY main_menu_entrys[] = {{"Disk Menu", M_IMAGE,ENTRY_MENU,   0,&image_menu},
                                 {"Settings",  M_SETTINGS,ENTRY_MENU,0,&settings_menu},
                                 {"Info",      M_INFO,ENTRY_MENU,    0,&info_menu}};
/// Image Menü
MENU_ENTRY image_menu_entrys[] = {{"..",           M_BACK_IMAGE,ENTRY_TO_PARENT},
                                  {"Load Selector",M_MENU_IMAGE},
                                  {"Load Image",   M_LOAD_IMAGE},
                                  {"Save Image",   M_SAVE_IMAGE},
                                  {"Unload Image", M_UNLOAD_IMAGE},
                                  {"ReInsert Disk",M_RELOAD_DISK},
                                  {"WriteProt.",   M_WP_IMAGE, ENTRY_ONOFF, 1},
                                  {"New Image",    M_NEW_IMAGE}};
/// Settings Menü
MENU_ENTRY settings_menu_entrys[] = {
    {"..",            M_BACK_SETTINGS, ENTRY_TO_PARENT},
    {"Z0 timer",      M_Z0_TIMER, ENTRY_8BIT_DEC, 28, 0, ZONE0_TIMER_MIN, ZONE0_TIMER_MAX},
    {"Z0 gap",        M_Z0_GAP,   ENTRY_8BIT_DEC, 21, 0, ZONE0_GAP_MIN, ZONE0_GAP_MAX},
    {"Rev rotary",    M_REV_ROTARY, ENTRY_ONOFF, 0},
    {"Load settings", M_LOAD_SETTINGS},
    {"Save settings", M_SAVE_SETTINGS},
    {"Restart",       M_RESTART}
};

/// Info Menü
MENU_ENTRY info_menu_entrys[] = {{"..",           M_BACK_INFO,ENTRY_TO_PARENT},
                                 {"Version",      M_VERSION_INFO},
                                 {"SD Card Info", M_SDCARD_INFO}};

#endif
