/**********************************
 * header - main routines, defines, variables
 *
 * Author: F00K42
 * Last change: 2026/02/16
***********************************/
#include "hw_config.h"
#include "f_util.h"
#include "ff.h"
#include "globals.h"
#include "board_config.h"

// functions
FRESULT mount_sdcard(void);
FRESULT umount_sdcard(void);
void show_fs_error(FRESULT error_code);

void check_stepper_signals(void);
void check_motor_signal(void);

void init_key_inputs(void);
uint8_t get_key_from_buffer(void);
void show_longpress(void);
void update_gui(void);
void check_menu_events(const uint16_t menu_event);
void set_gui_mode(const uint8_t gui_mode);
void filebrowser_update(uint8_t key_code);
void filebrowser_refresh(void);

void infomode_update(void);

void handle_selector_image(void);
void insert_menu_image(char* menu_path);

uint16_t get_dir_entry_count(const char* entrycount_path);

void show_start_message(void);
void show_sdcard_info_message(void);

void init_stepper(void);
void stepper_inc(void);
void stepper_dec(void);
void init_motor(void);
void init_control_signals(void);
#if REPICO1551
void init_board1551(void);
#else
void init_soe_gatearray(void);
#endif

uint8_t open_dir_entry(FILINFO od_file_entry);

uint8_t open_disk_image(FIL* fd, FILINFO *file_entry);
void close_disk_image(FIL* fd);
void unmount_image(void);

void init_writeprot(void);
void send_disk_change(void);

bool repeating_timer_callback(__unused struct repeating_timer *t);
void init_bytetimer(void);
void start_bytetimer(uint8_t half_track);
void stop_bytetimer(void);

int64_t steppertimer_callback(alarm_id_t id, void *user_data);
void start_stepper_timer(void);

/////////////
#define set_byte_ready()    gpio_set_dir(GPIO_BRDY,GPIO_IN)    // HiZ
#define clear_byte_ready()  {gpio_set_dir(GPIO_BRDY,GPIO_OUT);gpio_put(GPIO_BRDY,false);}   // auf Ground ziehen

#if REPICO1551
#define get_soe_status()    (true)
#else
#define get_soe_status()    gpio_get(GPIO_SOE)
#define set_soe_gatearray()     gpio_put(GPIO_SOE_GA,true)
#define clear_soe_gatearray()   gpio_put(GPIO_SOE_GA,false)
#endif

#define get_so_status()     gpio_get(GPIO_OE)

// WPS at CPU bit4: 0 = write-protected, 1 = writable (1551 ROM AND #$10 / BNE = not protected).
// 1541: Pico feeds board 74LS04 → invert at GPIO (HiZ → protected at VIA).
// 1551-rePico: GPIO5 → BSS138 → CPU WPS (no inverter). MOSFET can only pull WPS low;
//   high is R10 (+ Pico driving WPS_3V3 high so the FET is firmly off). Never push 5V.
#if REPICO1551
#define clear_wps()         {gpio_set_dir(GPIO_WPS,GPIO_OUT);gpio_put(GPIO_WPS,false);}  // FET on  → WPS=0
#define set_wps()           {gpio_set_dir(GPIO_WPS,GPIO_OUT);gpio_put(GPIO_WPS,true);}   // FET off → WPS=1 via R10
#else
#define clear_wps()          gpio_set_dir(GPIO_WPS,GPIO_IN)    // HiZ → inverter → protected
#define set_wps()           {gpio_set_dir(GPIO_WPS,GPIO_OUT);gpio_put(GPIO_WPS,false);}   // low → inverter → writable
#endif

#define get_motor_status()  gpio_get(GPIO_MTR)

#define set_sync()          gpio_put(GPIO_SYNC,true)
#define clear_sync()        gpio_put(GPIO_SYNC,false)

#define out_gcr_byte(gcr_byte)  gpio_put_masked(PAPORT_MASK,gcr_byte<<GPIO_PAPORT)
#define in_gcr_byte()       (gpio_get_all()&PAPORT_MASK)>>GPIO_PAPORT

#define enable_write_protection()   {clear_wps();floppy_wp=true;}
#define disable_write_protection()  {set_wps();floppy_wp=false;}


// Filesystem-variables:
FATFS       fs;             // filesystem handle - only created once
DIR         dir_object;
FIL         fd;             // file descriptor for every open file
FILINFO     fb_dir_entry[DISPLAY_LINE_MAX];
//
//
// Button bounce filter (us). Rotary uses a quadrature state machine (no ms block).
#define BUTTON_DEBOUNCE_US      (30000u)
#define PANEL_BUTTON_DEBOUNCE_US (50000u)
#define KEY_QUEUE_SIZE          (8)
#if REPICO1551
/* Pi1551-III panel encoder: 2 valid quadrature edges per detent */
#define ROTARY_DETENT_STEPS     (2)
#else
#define ROTARY_DETENT_STEPS     (4)
#endif
// timer_t key_longpress_timer;

volatile uint16_t akt_track_pos = 0;

uint8_t selected_track;     // this holds the selected tracknumber
volatile uint8_t akt_half_track;     // this will be the one to be transfered
uint8_t old_half_track;

// timer definition

struct repeating_timer bytetimer;


char image_filename[256]; //Maximal 256 Zeichen
char current_path[512];

uint8_t current_gui_mode;

uint8_t gui_current_line_offset;         // >0 dann ist der Name länger als die maximale Anzeigelaenge
uint8_t gui_line_scroll_pos;             // Kann zwischen 0 und fb_current_line_offset liegen
uint8_t gui_line_scroll_direction;       // Richtung des Scrollings
uint8_t gui_line_scroll_end_begin_wait;

// Alles für den FilebrowserSS
uint16_t fb_dir_entry_count = 0;         // Anzahl der Einträge im aktuellen Direktory
uint8_t fb_cursor_pos = 0;               // Position des Cursors auf dem LCD Display
uint8_t fb_window_pos = 0;               // Position des Anzeigebereichs innerhablb der Menüeinträge

uint8_t fb_current_line_offset = 0;         // >0 dann ist der Name länger als die maximale Anzeigelaenge
uint8_t fb_line_scroll_pos = 0;             // Kann zwischen 0 und fb_current_line_offset liegen
uint8_t fb_line_scroll_direction = 0;       // Richtung des Scrollings
uint8_t fb_line_scroll_end_begin_wait = 10;


// floppydisk emulation
uint8_t akt_image_type = UNDEF_IMAGE;     // 0=kein Image, 1=G64, 2=D64, 3=Selector
bool is_image_mount;

bool floppy_wp = true;  // Hier wird der aktuelle WriteProtection Zustand gespeichert
                        // false=Nicht Schreibgeschützt , true=Schreibgeschützt

#define STEP_MIN_TIME (2000)    // us between 2 step changes.

uint8_t stepper_signal_puffer[256]; // Ringpuffer für Stepper Signale (256 Bytes)
volatile uint8_t stepper_signal_r_pos = 0;
volatile uint8_t stepper_signal_w_pos = 0;

alarm_id_t stepper_alarm = 0;

volatile bool track_is_written   = false;
volatile bool send_byte_ready    = true;

volatile uint8_t  track_write_nr;
volatile uint16_t track_write_pos;
