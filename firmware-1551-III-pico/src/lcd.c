// Ansteuerung eines HD44780 kompatiblen LCD im 4-Bit-Interfacemodus
// http://www.mikrocontroller.net/articles/HD44780
// http://www.mikrocontroller.net/articles/AVR-GCC-Tutorial/LCD-Ansteuerung
//
// Die Pinbelegung ist über defines in lcd-routines.h einstellbar
//
// adoption for portexpander PCF8574 via I2C:
// implementation: F00K42
// last change: 11/10/2025

#include "lcd.h"

extern uint8_t DEV_I2C_ADDR;

// definition of LCD-ROW offsets .. needed for setcursor-routine
const uint8_t lcd_rowoffset[] = { 0, 0x40, LCD_COLS, 0x40+LCD_COLS };

// custom character definitions for LCD display
const uint8_t customchars[][8] = {
                                    { 4,14,31, 0, 0, 0, 0, 0},  // Menü More Top
                                    { 0, 0, 0, 0,31,14, 4, 0},  // Menü More Down
                                    { 0, 4, 6,31, 6, 4, 0, 0},  // Menü Position
                                    { 0,28,31,17,17,31, 0, 0},  // Directory Symbol
                                    {15,27,17,27,31,27,27,31},  // Diskimage
                                    {63,63,63,63,63,63,63,63}   // Cursor
                                };

#define num_of_customchars  count_of(customchars)

////////////////////////////////////////////////////////////////////////////////
// Sendet eine Ausgabeoperation an das LCD
void pcf_lcd_out( uint8_t data )
{
    i2c_write_blocking(I2C_PORT, DEV_I2C_ADDR, &data, 1, false);
}

void error_lcd_out( uint8_t data )
{
    (void) data;
    // not doing anything.. no display attached via i2c
}
////////////////////////////////////////////////////////////////////////////////
// Erzeugt einen Enable-Puls zusammen mit den Daten
static void lcd_enable( uint8_t data )
{
    lcd_out( data | LCD_EN );   // Enable auf 1 setzen
    sleep_us( LCD_ENABLE_US ); // kurze Pause
    lcd_out( data );            // Enable auf 0 setzen
}

////////////////////////////////////////////////////////////////////////////////
// Erzeugt einen Enable-Puls zusammen mit den Daten
static void lcd_out_enable( uint8_t data )
{
    lcd_out( data );        // Enable auf 0 setzen
    lcd_enable( data );
}

////////////////////////////////////////////////////////////////////////////////
// Initialisierung: muss ganz am Anfang des Programms aufgerufen werden.
void lcd_setup( void )
{
    // warten auf die Bereitschaft des LCD
    sleep_ms( LCD_BOOTUP_MS );

    lcd_out( 0 );   // init all LCD outputs to 0
    sleep_ms( 20 );

    // Soft-Reset muss 3mal hintereinander gesendet werden zur Initialisierung
    lcd_out_enable( LCD_SOFT_RESET );
    sleep_ms( LCD_SOFT_RESET_MS1 );

    lcd_enable( LCD_SOFT_RESET );
    sleep_ms( LCD_SOFT_RESET_MS2 );

    lcd_enable( LCD_SOFT_RESET );
    sleep_ms( LCD_SOFT_RESET_MS3 );

    // 4-bit Modus aktivieren 
    lcd_out_enable( LCD_SET_FUNCTION | LCD_FUNCTION_4BIT );
    sleep_ms( LCD_SET_4BITMODE_MS );

    // 4-bit Modus / 2 Zeilen / 5x7
    lcd_command( LCD_SET_FUNCTION |
                 LCD_FUNCTION_4BIT |
                 LCD_FUNCTION_2LINE |
                 LCD_FUNCTION_5X7 );

    // Display aus
    lcd_command( LCD_SET_DISPLAY |
                 LCD_DISPLAY_OFF |
                 LCD_CURSOR_OFF |
                 LCD_BLINKING_OFF);

    // Cursor inkrement / kein Scrollen
    lcd_command( LCD_SET_ENTRY |
                 LCD_ENTRY_INCREASE |
                 LCD_ENTRY_NOSHIFT );

    // Display ein / Cursor aus / Blinken aus
    lcd_command( LCD_SET_DISPLAY |
                 LCD_DISPLAY_ON |
                 LCD_CURSOR_OFF |
                 LCD_BLINKING_OFF);

    lcd_clear();

    // eigene Zeichen im LCD Display setzen
    for(uint8_t i=0; i<num_of_customchars; ++i)
    {
        lcd_generatechar(i+1, customchars[i]);
    }

}

////////////////////////////////////////////////////////////////////////////////
// Sendet ein Datenbyte an das LCD via pcf8574 output
void lcd_data( const uint8_t data )
{
    lcd_out_enable( ( data     & 0xF0) | LCD_RS | LCD_BACKLIGHT );    // zuerst die oberen, 
    lcd_out_enable( ((data<<4) & 0xF0) | LCD_RS | LCD_BACKLIGHT );    // dann die unteren 4 Bit senden

    sleep_us( LCD_WRITEDATA_US );
}

////////////////////////////////////////////////////////////////////////////////
// Sendet einen Befehl an das LCD via pcf8574 output
void lcd_command( const uint8_t data )
{
    lcd_out_enable( ( data     & 0xF0) | LCD_BACKLIGHT );    // zuerst die oberen, 
    lcd_out_enable( ((data<<4) & 0xF0) | LCD_BACKLIGHT );    // dann die unteren 4 Bit senden

    sleep_us( LCD_COMMAND_US );
}

////////////////////////////////////////////////////////////////////////////////
// Sendet den Befehl zur Löschung des Displays
void lcd_clear( void )
{
    lcd_command( LCD_CLEAR_DISPLAY );
    sleep_ms( LCD_CLEAR_DISPLAY_MS );
}

////////////////////////////////////////////////////////////////////////////////
// Sendet den Befehl: Cursor Home
void lcd_home( void )
{
    lcd_command( LCD_CURSOR_HOME );
    sleep_ms( LCD_CURSOR_HOME_MS );
}

////////////////////////////////////////////////////////////////////////////////
// Setzt den Cursor in Spalte x (0..LCD_COLS) & Zeile y (0..LCD_ROWS)

void lcd_setcursor( const uint8_t x, const uint8_t y )
{
    if (LCD_ROWS > y)
    {
        uint8_t offset = (lcd_rowoffset[y] + x) & 0x7F;
        lcd_command( LCD_SET_DDADR | offset );
    }
}

////////////////////////////////////////////////////////////////////////////////
// Schreibt einen String auf das LCD

void lcd_string( const char* data )
{
    while( *data != '\0' )
    {
        lcd_data( *data++ );
    }
}

////////////////////////////////////////////////////////////////////////////////
// Schreibt einen String auf das LCD mit erweiterten Parametern
// start:   Position des erstes Zeichens im String was ausgegeben werden soll
// length:  Maximale Anzahl der Zeichen die Ausgegeben werden sollen

void lcd_print( const char *string, const uint8_t start, const uint8_t length)
{
    uint8_t char_counter = 1;
    uint8_t current_char = string[start];

    while((current_char != '\0') && ((char_counter-1) < length))
    {
        lcd_data(current_char);
        current_char = string[start+char_counter++];
    }
}

////////////////////////////////////////////////////////////////////////////////
// Schreibt ein Zeichen in den Character Generator RAM

void lcd_generatechar( const uint8_t code, const uint8_t *data )
{
    // Startposition des Zeichens einstellen
    lcd_command( LCD_SET_CGADR | (code<<3) );

    // Bitmuster übertragen
    for ( uint8_t i=0; i<8; ++i )
    {
        lcd_data( data[i] );
    }
}

////////////////////////////////////////////////////////////////////////////////
// set "bright" mode or "light" mode for 128x64 display
void lcd_setbright( bool bright_on )
{
    (void) bright_on;
}
