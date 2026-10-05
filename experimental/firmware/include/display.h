/**********************************
 * header - routines for display
 *
 * Author: F00K42
 * Last change: 2026/02/09
***********************************/

#ifndef _DISPLAY_H_INCLUDE_
#define _DISPLAY_H_INCLUDE_

#include "oled.h"
#include "lcd.h"

enum {
    display_none_char = 0,
    display_more_top_char = 1,
    display_more_down_char,
    display_pointer_char,
    display_dir_char,
    display_disk_char,
    display_cursor_char
 };


#ifndef _EXTERN_
#define _EXTERN_ extern
#endif

// function pointers to be used later
_EXTERN_ void (*display_setup)(void);
_EXTERN_ void (*display_clear)(void);
_EXTERN_ void (*display_home)(void);
_EXTERN_ void (*display_setcursor)(const uint8_t column, const uint8_t row);
_EXTERN_ void (*display_data)( const uint8_t character);
_EXTERN_ void (*display_string)( const char* char_array);
_EXTERN_ void (*display_print)( const char* char_array, const uint8_t array_offset, const uint8_t print_length);
_EXTERN_ void (*display_generatechar)(const uint8_t, const uint8_t*);
_EXTERN_ void (*display_setbright)( bool bright_on );

// detect the display type & set it up
uint8_t display_init(void);

char* dez2out(int32_t value, uint8_t digits, char* dest);
char* hex2out(uint32_t dez, uint8_t digits, char* dest);

#endif // _DISPLAY_H_INCLUDE_
