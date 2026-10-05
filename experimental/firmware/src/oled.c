/* routines for OLED display */
//
// access OLED display controller SSD1306 via I2C 
//
// implementation: F00K42
// last change: 19/09/2021

#include "i2c.h"
#include "oled.h"
#include "Font_c64_ascii.h"

extern uint8_t DEV_I2C_ADDR;
uint8_t oled_cursor_x, oled_cursor_y;
bool oled_bright = false;

const uint8_t OLED_customchars[][8] = {
{ // Menü More Top
    0b00000000,
    0b00010000,
    0b00110000,
    0b01110000,
    0b11110000,
    0b01110000,
    0b00110000,
    0b00010000
},
{ // Menü More Down
    0b00000000,
    0b00001000,
    0b00001100,
    0b00001110,
    0b00001111,
    0b00001110,
    0b00001100,
    0b00001000
},
{ // Menü Position
    0b00111000,
    0b00111000,
    0b00111000,
    0b11111110,
    0b01111100,
    0b00111000,
    0b00010000,
    0b00000000
},
{  // Directory Symbol
    0b00000000,
    0b11111110,
    0b11000010,
    0b11011010,
    0b01011010,
    0b01010010,
    0b01000010,
    0b00111110
},
{ // Diskimage
//     0b00000000,
//     0b01111111,
//     0b11111111,
//     0b11011111,
//     0b10001001,
//     0b11011111,
//     0b11111111,
//     0b11111111
// },
    0b00000000,
    0b11110000,
    0b00111100,
    0b00110000,
    0b00111100,
    0b00001110,
    0b00010001,
    0b00010111,
},
{  // Cursor
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
}
};

#define num_of_customchars  count_of(OLED_customchars)

////////////////////////////////////////////////////////////////////////////////
// lowlevel routines to access SSD1306 display controller

void ssd1306_command( const uint8_t data )
{
    uint8_t buffer[]={SSD1306_I2C_COMMAND, data};
    i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, buffer, count_of(buffer), false);
}

void ssd1306_data( const uint8_t data )
{
    uint8_t buffer[]={SSD1306_I2C_DATA, data};
    i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, buffer, count_of(buffer), false);
}

////////////////////////////////////////////////////////////////////////////////
// setup the display
// see datasheet SSD1306 - p.64
void oled_setup( void )
{
    ssd1306_command(SSD1306_DISPLAYOFF);
    ssd1306_command(SSD1306_MULTIPLEX); 
    ssd1306_command(0x3F);
    ssd1306_command(SSD1306_DISPLAY_OFFSET);    
    ssd1306_command(0x00);                          // no offset
    ssd1306_command(SSD1306_DSP_STARTLINE | 0x00);  // line 0
    ssd1306_command(SSD1306_SEG_REMAP_127);         // flip horizontal
    ssd1306_command(SSD1306_COM_LITTLEENDIAN);      // rotate screen 180
    ssd1306_command(SSD1306_COM_PINS);
    ssd1306_command(0x02);              // 02 = every 2nd Line 4 rows (2nd Line at Row 4..8) ... 12 = every Line (8 rows)
    ssd1306_command(SSD1306_SETCONTRAST);
    ssd1306_command(0x7F);
    ssd1306_command(SSD1306_ALLON_RESUME);
    ssd1306_command(SSD1306_NORMALDISPLAY);
    ssd1306_command(SSD1306_CLOCK_DIV);
    ssd1306_command(0x80);
    ssd1306_command(SSD1306_CHARGEPUMP);
    ssd1306_command(0x14);                          // using internal VCC
    ssd1306_command(SSD1306_DISPLAYON);             // switch on Display
}

////////////////////////////////////////////////////////////////////////////////
// clear display
void oled_clear( void )
{
    uint8_t buffer[(16*8)+1];
    memset(buffer, 0, count_of(buffer));
    buffer[0] = SSD1306_I2C_DATA;
    for(uint8_t rows=0; rows<8; ++rows)
    {
        oled_setcursor(0, rows);

        i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, buffer, count_of(buffer), false);
    }
}

////////////////////////////////////////////////////////////////////////////////
// place display cursor top left
void oled_home( void )
{
    ssd1306_command(SSD1306_PAGE_START | 7);
    ssd1306_command(SSD1306_COLUMN_START_L );
    ssd1306_command(SSD1306_COLUMN_START_H );
    oled_cursor_x = 0;
    oled_cursor_y = 0;
}

////////////////////////////////////////////////////////////////////////////////
// set cursor position
void oled_setcursor( const uint8_t spalte, const uint8_t zeile )
{
    ssd1306_command(SSD1306_PAGE_START | (7-zeile));
    ssd1306_command(SSD1306_COLUMN_START_L |  ((FONT_WIDTH*spalte)     & 0x0f));
    ssd1306_command(SSD1306_COLUMN_START_H | (((FONT_WIDTH*spalte)>>4) & 0x0f));
    oled_cursor_x = spalte;
    oled_cursor_y = zeile;
}

////////////////////////////////////////////////////////////////////////////////
// write 1 character
void oled_data( const uint8_t data )
{
    if (0 == data) { return; }

    uint8_t buffer[FONT_HEIGHT+1];
    buffer[0] = SSD1306_I2C_DATA;

    if (num_of_customchars >= data)
    {
        memcpy((void*) &buffer[1], (const void*) &OLED_customchars[data-1][0], FONT_HEIGHT);
    } else if ((FONT_MAXCHAR < data) || (FONT_MINCHAR > data))
    {
        memcpy((void*) &buffer[1], (const void*) &FontData[FONT_MAXCHAR-FONT_MINCHAR][0], FONT_HEIGHT);
    } else {
        memcpy((void*) &buffer[1], (const void*) &FontData[data-FONT_MINCHAR][0], FONT_HEIGHT);
    }

    i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, buffer, count_of(buffer), false);

    if (oled_bright)
    {
        ssd1306_command(SSD1306_PAGE_START | (3-oled_cursor_y));
        ssd1306_command(SSD1306_COLUMN_START_L |  ((FONT_WIDTH*oled_cursor_x)     & 0x0f));
        ssd1306_command(SSD1306_COLUMN_START_H | (((FONT_WIDTH*oled_cursor_x)>>4) & 0x0f));

        i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, buffer, count_of(buffer), false);
    }

    ++oled_cursor_x;
    oled_setcursor(oled_cursor_x, oled_cursor_y);
}

////////////////////////////////////////////////////////////////////////////////
// write a string
void oled_string( const char* data )
{
    while( 0 != data[0] )
    {
        oled_data( *data++ );
    }
}

////////////////////////////////////////////////////////////////////////////////
// write a substring of "string" starting at "start" with size "length"
void oled_print( const char *string, const uint8_t start, const uint8_t length)
{
    uint8_t char_counter = 1;
    uint8_t current_char = string[start];

    while((0 != current_char) && ((char_counter-1) < length))
    {
        oled_data(current_char);
        current_char = string[start+char_counter++];
    }
}

////////////////////////////////////////////////////////////////////////////////
// specify user-defined characters with "data"-bitmap
void oled_generatechar( const uint8_t code, const uint8_t *data )
{
}

////////////////////////////////////////////////////////////////////////////////
// set "bright" mode or "light" mode for 128x64 display
void oled_setbright( bool bright_on )
{
    oled_bright = bright_on;
}
