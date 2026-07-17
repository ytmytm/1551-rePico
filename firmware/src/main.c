/////////////////////////////////////////////////
// 1541-rePico
/////////////////////////////////////////////////
// author: F00K42
// last changed: 2026/07/10
// repo: https://github.com/fook42/1541-rePico
/////////////////////////////////////////////////


#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/timer.h"
#include "hardware/clocks.h"
#include "hardware/sync.h"

#include "pinout.h"
#include "board1551.h"

#define _EXTERN_

#include "version.h"
#include "display.h"
#include "lcd.h"
#include "oled.h"
#include "i2c.h"
#include "gcr.h"
#include "menu.h"
#include "mymenu.h"
#include "gui_constants.h"
#include "globals.h"
#include "rw_routines.h"
#include "menu_image.h"
#include "c64_selector.h"
#if !defined(REPICO1551)
#include "c64_intro.h"
#endif

#include "hw_config.h"
#include "f_util.h"
#include "ff.h"

#include "main.h"


#define START_MESSAGE_TIME 1500

volatile int16_t rotary_delta = 0;

static volatile uint8_t key_queue[KEY_QUEUE_SIZE];
static volatile uint8_t key_q_head = 0;
static volatile uint8_t key_q_tail = 0;

static uint64_t key2_down_time=0;
uint8_t num_max_tracks;
uint16_t selected_image_nr = 0xFFFF;

// Quadrature gray-code: index = (prev<<2)|curr, value = step direction (0 = invalid/noise)
static const int8_t rotary_transition[16] = {
     0, -1,  1,  0,
     1,  0,  0, -1,
    -1,  0,  0,  1,
     0,  1, -1,  0
};
static uint8_t rotary_prev_ab = 0;
static int8_t rotary_accum = 0;

// ---------------------------------------------------------------

static void key_push(uint8_t key)
{
    uint8_t next = (uint8_t)((key_q_head + 1u) % KEY_QUEUE_SIZE);
    if (next != key_q_tail)
    {
        key_queue[key_q_head] = key;
        key_q_head = next;
    }
}

static void wait_key(uint8_t want)
{
    while (get_key_from_buffer() != want)
    {
    }
}

static void rotary_on_edge(void)
{
    // Full quadrature decode on A/B. Sampling only A-fall+B (old approach) is
    // direction-stable with a long block, but with a short filter it accepts the
    // opposite half-cycle and reverses. Count a detent after ROTARY_DETENT_STEPS.
    uint8_t curr = (uint8_t)((gpio_get(GPIO_BT1) ? 2u : 0u) | (gpio_get(GPIO_BT2) ? 1u : 0u));
    int8_t step = rotary_transition[(rotary_prev_ab << 2) | curr];
    rotary_prev_ab = curr;
    if (step == 0)
        return;

    rotary_accum = (int8_t)(rotary_accum + step);
    if (rotary_accum >= ROTARY_DETENT_STEPS)
    {
        rotary_accum = (int8_t)(rotary_accum - ROTARY_DETENT_STEPS);
        rotary_delta++;
    }
    else if (rotary_accum <= -ROTARY_DETENT_STEPS)
    {
        rotary_accum = (int8_t)(rotary_accum + ROTARY_DETENT_STEPS);
        rotary_delta--;
    }
}

void gpio_callback(uint gpio, uint32_t events)
{
    (void)events;
    if ((GPIO_STP0==gpio) || (GPIO_STP1==gpio))
    {
        static uint64_t last_int;
        // general gpio-ISR .. triggered for STP0 or STP1 change.. no need to detect the cause
        if ((time_us_64()-last_int) > STEP_MIN_TIME)
        {
            stepper_signal_puffer[stepper_signal_w_pos] = ((bool_to_bit(gpio_get(GPIO_STP0))<<1) | (bool_to_bit(gpio_get(GPIO_STP1))));
            stepper_signal_w_pos++;
        }
        last_int = time_us_64();
    }
    else if ((GPIO_BT1 == gpio) || (GPIO_BT2 == gpio))
    {
        rotary_on_edge();
    }
    else if (GPIO_BT3 == gpio)
    {
        // Pushbutton: level-based edge after debounce. Avoids release bounce
        // producing a second KEY2_DOWN/KEY2_UP pair.
        static bool button_down = false;
        static uint64_t last_button_us;
        uint64_t now = time_us_64();
        if ((now - last_button_us) < BUTTON_DEBOUNCE_US)
            return;

        bool pressed = !gpio_get(GPIO_BT3); // active low with pull-up
        if (pressed == button_down)
            return;

        button_down = pressed;
        last_button_us = now;

        if (pressed)
        {
            key2_down_time = now;
            key_push(KEY2_DOWN);
        }
        else
        {
            uint64_t down_time = key2_down_time;
            if (down_time > now)
            {
                down_time -= (now + 1);
                now = (uint64_t)-1;
            }

            if ((now - down_time) > TIMEOUT2_KEY2)
                key_push(KEY2_TIMEOUT2);
            else if ((now - down_time) > TIMEOUT1_KEY2)
                key_push(KEY2_TIMEOUT1);
            else
                key_push(KEY2_UP);

            key2_down_time = now;
        }
    }
}

// ---------------------------------------------------------------

int main()
{
    stdio_init_all();

    if (display_init())
    {
        display_home();
    }

    show_start_message();

    // init input-keys
    init_key_inputs();

    // Stepper Initialisieren
    init_stepper();

    // Motor Initialisieren
    init_motor();

    // Steursignale BYTE_READY, SYNC und SOE Initialisieren
    init_control_signals();

#if REPICO1551
    init_board1551();
#else
    init_soe_gatearray();
    clear_soe_gatearray();
#endif

    init_bytetimer();

    init_writeprot();
    disable_write_protection();

    // setup menus
    menu_init(&main_menu,     main_menu_entrys,     count_of(main_menu_entrys),     LCD_LINE_SIZE, LCD_LINE_COUNT);
    menu_init(&image_menu,    image_menu_entrys,    count_of(image_menu_entrys),    LCD_LINE_SIZE, LCD_LINE_COUNT);
    menu_init(&settings_menu, settings_menu_entrys, count_of(settings_menu_entrys), LCD_LINE_SIZE, LCD_LINE_COUNT);
    menu_init(&info_menu,     info_menu_entrys,     count_of(info_menu_entrys),     LCD_LINE_SIZE, LCD_LINE_COUNT);

    menu_set_root(&main_menu);
    // ----

    sleep_ms(START_MESSAGE_TIME);

    display_clear();
    display_home();

    set_gui_mode(GUI_SELECTOR);

    while (true) {
        check_stepper_signals();
        update_gui();
    }
}
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

FRESULT mount_sdcard(void)
{
    char mount_path[] = {"/"};
    BYTE mount_option = 1; /* 0=Do not mount (delayed mount), 1=Mount immediately */

    FRESULT fr = f_mount(&fs, mount_path, mount_option);
    // uint8_t retry_count = 3;

    // while ((FR_OK != fr) && (retry_count > 0)) {
    //     retry_count--;
    //     sleep_ms(1000);
    //     fr = f_mount(&fs, mount_path, mount_option);
    // }

    if (FR_OK == fr)
    {
        fb_dir_entry_count = get_dir_entry_count(mount_path); // open card, count entries on root level

        strcpy(current_path, mount_path);
    }
    return fr;
}


FRESULT umount_sdcard(void)
{
    char mount_path[] = {""};

    return f_unmount(mount_path);
}

void show_fs_error(FRESULT error_code)
{
    // display_string("f_mount error:");
    // display_data(error_code+'A');
    const char* error_txt=FRESULT_str(error_code);
    size_t err_str_len=strlen(error_txt);
    uint8_t err_str_offset=0;
    bool pressed = false;
    do
    {
        display_setcursor(0, 1);
        display_print(error_txt, err_str_offset++, 16);
        sleep_ms(333);
        if (get_key_from_buffer() == KEY2_DOWN)
            pressed = true;
    }
    while (!pressed && ((err_str_offset+15)<err_str_len));

    while (!pressed)
    {
        if (get_key_from_buffer() == KEY2_DOWN)
            pressed = true;
    }
    return;
}
/////////////////////////////////////////////////////////////////////


int64_t steppertimer_callback(alarm_id_t id, void *user_data)
{
    send_byte_ready = false;
    stop_bytetimer();

    // neue track Geschwindigkeit setzen -> timer restart
    akt_track_pos = 0;

    akt_half_track = selected_track&0x7E;

    start_bytetimer(akt_half_track);
    send_byte_ready = true;
    return 0;
}


void start_stepper_timer(void)
{
    if (stepper_alarm) { cancel_alarm(stepper_alarm); }
    stepper_alarm = add_alarm_in_ms(STEPPER_DELAY_TIME, steppertimer_callback, NULL, false);
}

/////////////////////////////////////////////////////////////////////

void check_stepper_signals(void)
{
    // Auf Steppermotor aktivität prüfen
    // und auswerten
    if(stepper_signal_r_pos != stepper_signal_w_pos)    // Prüfen ob sich was neues im Ringpuffer für die Steppersignale befindet
    {
        uint8_t stepper = stepper_signal_puffer[(stepper_signal_r_pos+255)&0xFF]<<2;
        stepper |= stepper_signal_puffer[stepper_signal_r_pos];
        stepper_signal_r_pos++;

        switch(stepper)
        {
            case 0b00000011:
            case 0b00000100:
            case 0b00001001:
            case 0b00001110:
                {
                    // DEC
                    stepper_dec();
                    start_stepper_timer();
                }
                break;

            case 0b00000001:
            case 0b00000110:
            case 0b00001011:
            case 0b00001100:
                {
                    // INC
                    stepper_inc();
                    start_stepper_timer();
                }
                break;

            default:
                break;
        }
    }
}

/////////////////////////////////////////////////////////////////////

void init_key_inputs(void)
{
    gpio_init(GPIO_BT1);
    gpio_init(GPIO_BT2);
    gpio_init(GPIO_BT3);
    gpio_set_dir(GPIO_BT1, GPIO_IN);
    gpio_set_dir(GPIO_BT2, GPIO_IN);
    gpio_set_dir(GPIO_BT3, GPIO_IN);
    gpio_set_pulls(GPIO_BT1, true, false);
    gpio_set_pulls(GPIO_BT2, true, false);
    gpio_set_pulls(GPIO_BT3, true, false);

    rotary_prev_ab = (uint8_t)((gpio_get(GPIO_BT1) ? 2u : 0u) | (gpio_get(GPIO_BT2) ? 1u : 0u));
    rotary_accum = 0;
    rotary_delta = 0;

    gpio_set_irq_enabled_with_callback(GPIO_BT1, GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true, &gpio_callback);
    gpio_set_irq_enabled(GPIO_BT2, GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true);
    gpio_set_irq_enabled(GPIO_BT3, GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true);
}

uint8_t get_key_from_buffer(void)
{
    uint32_t ints = save_and_disable_interrupts();
    int16_t delta = rotary_delta;
    if (delta < 0)
    {
        rotary_delta = (int16_t)(delta + 1);
        restore_interrupts(ints);
        return KEY0_DOWN;
    }
    if (delta > 0)
    {
        rotary_delta = (int16_t)(delta - 1);
        restore_interrupts(ints);
        return KEY1_DOWN;
    }

    if (key_q_tail != key_q_head)
    {
        uint8_t val = key_queue[key_q_tail];
        key_q_tail = (uint8_t)((key_q_tail + 1u) % KEY_QUEUE_SIZE);
        restore_interrupts(ints);
        return val;
    }
    restore_interrupts(ints);
    return NO_KEY;
}

void show_longpress(void)
{
    static uint8_t shown_time_steps;
    uint64_t my_now_time = time_us_64();
    uint64_t my_down_time = key2_down_time;
    char filler;
    if (my_down_time > my_now_time)
    {
        my_down_time -= (my_now_time+1);
        my_now_time = ((uint64_t)-1);
    }

    const uint64_t block_step = TIMEOUT2_KEY2/LCD_LINE_SIZE;
    uint8_t  time_steps = (my_now_time-my_down_time)/block_step;
    filler = display_pointer_char;
    if (time_steps>=LCD_LINE_SIZE) { filler = display_cursor_char; }

    if (shown_time_steps != time_steps)
    {
        display_setcursor(0,2);
        for(int i=0; i<LCD_LINE_SIZE; i++)
        {
            if(i<time_steps)
                display_data(filler);
            else
                display_data(' ');
        }
    }
}

void update_gui(void)
{
    static uint8_t shown_half_track = 255;
    static bool shown_motor_status = false;
    static bool key2_pressed = false;
    static uint32_t wait_counter0 = 0;
    bool new_motor_status;
    uint8_t key_code = get_key_from_buffer();
    char byte_str[8];
    FILINFO next_dir_entry;

    switch (current_gui_mode)
    {
    case GUI_INFO_MODE:

        if(KEY2_UP == key_code)
        {
            key2_pressed = false;
            set_gui_mode(GUI_MENU_MODE);
        } else if(KEY2_TIMEOUT2 == key_code)
        {
            key2_pressed = false;
            // next image...
            if (selected_image_nr<fb_dir_entry_count)
            {
                seek_to_dir_entry(selected_image_nr, current_path);
                FRESULT fr = f_readdir(&dir_object, &next_dir_entry);
                if((0 != next_dir_entry.fname[0]) && (FR_OK == fr))
                {
                    if(!(next_dir_entry.fattrib & AM_DIR))
                    {
                        if (TYPE_VALID == open_dir_entry(next_dir_entry))
                        {
                            ++selected_image_nr;
                            set_gui_mode(GUI_INFO_MODE);
                        }
                    }
                }
            }
        } else if(KEY2_TIMEOUT1 == key_code)
        {
            key2_pressed = false;
        } else if(KEY2_DOWN == key_code)
        {
            key2_pressed = true;
        }
        if (key2_pressed) { show_longpress(); }

        if(shown_half_track != akt_half_track)
        {
            shown_half_track = akt_half_track;
            display_setcursor(disp_trackno_p);
            (void)dez2out((shown_half_track>>1)+1, 2, byte_str);
            display_data(byte_str[0]);
            display_data(byte_str[1]);
        }

        new_motor_status = get_motor_status();
        if(shown_motor_status != new_motor_status)
        {
            shown_motor_status = new_motor_status;
            display_setcursor(disp_motortxt_p);
            if(shown_motor_status)
                display_string(disp_motor_on_s);
            else
                display_string(disp_motor_off_s);
        }

        if((is_image_mount) && (gui_current_line_offset > 0))
        {
            //// Filename Scrolling

            ++wait_counter0;

            if(300000 == wait_counter0)
            {
                wait_counter0 = 0;

                if(0 == gui_line_scroll_end_begin_wait)
                {
                    // Es darf gescrollt werden
                    if(!gui_line_scroll_direction)
                    {
                        ++gui_line_scroll_pos;
                        if(gui_line_scroll_pos >= gui_current_line_offset)
                        {
                            gui_line_scroll_end_begin_wait = 6;
                            gui_line_scroll_direction = 1;
                        }
                    }
                    else
                    {
                        --gui_line_scroll_pos;
                        if(gui_line_scroll_pos == 0)
                        {
                            gui_line_scroll_end_begin_wait = 6;
                            gui_line_scroll_direction = 0;
                        }
                    }

                    display_setcursor(disp_scrollfilename_p);
                    display_print(image_filename,gui_line_scroll_pos,LCD_LINE_SIZE);
                } else {
                    --gui_line_scroll_end_begin_wait;
                }
            }
        }
        break;

    case GUI_MENU_MODE:
        check_menu_events(menu_update(key_code));
        break;

    case GUI_FILE_BROWSER:
        filebrowser_update(key_code);
        break;

    case GUI_SELECTOR:
        if(KEY2_UP == key_code)
        {
            unmount_image();
            set_gui_mode(GUI_MENU_MODE);
            break;
        } else if(KEY2_TIMEOUT2 == key_code)
        {
            // exit_main = 0;
        }

        handle_selector_image();

        if(shown_half_track != akt_half_track)
        {
            shown_half_track = akt_half_track;
            display_setcursor(disp_trackno_p);
            (void)dez2out((shown_half_track>>1)+1, 2, byte_str);
            display_data(byte_str[0]);
            display_data(byte_str[1]);
        }

        new_motor_status = get_motor_status();
        if(shown_motor_status != new_motor_status)
        {
            shown_motor_status = new_motor_status;
            display_setcursor(disp_motortxt_p);
            if(shown_motor_status)
                display_string(disp_motor_on_s);
            else
                display_string(disp_motor_off_s);
        }
        break;

    default:
        break;
    }
}

void check_menu_events(const uint16_t menu_event)
{
    const uint8_t command = (uint8_t) ((menu_event >> 8) & 0xff);
    const uint8_t value = (uint8_t) (menu_event & 0xff);

    FRESULT fr;

    switch(command)
    {
        case MC_EXIT_MENU:
            set_gui_mode(GUI_INFO_MODE);
            break;

        case MC_SELECT_ENTRY:
            switch(value)
            {
                /// Main Menü

                /// Image Menü
                case M_MENU_IMAGE:
                    set_gui_mode(GUI_SELECTOR);
                    break;
                case M_LOAD_IMAGE:
                    fr = mount_sdcard();
                    display_clear();
                    display_home();
                    if (FR_OK == fr)
                    {
                        set_gui_mode(GUI_FILE_BROWSER);
                    } else {
                        display_string("f_mount error:");
                        display_data(fr+'A');
                        show_fs_error(fr);
                        menu_refresh();
                    }
                    break;

                case M_SAVE_IMAGE:
                    if (is_image_mount)
                    {
                        char byte_str[8];
                        int file_op_status;
                        // todo: create save-file dialog, name, type
                        // for now: open a "standard-file" (G64)
                        fr = mount_sdcard();
                        display_clear();
                        display_home();
                        if (FR_OK != fr)
                        {
                            display_string("f_mount error:");
                            display_data(fr+'A');
                            show_fs_error(fr);
                            menu_refresh();
                            break;
                        }
                        if (FR_OK == f_open(&fd, product_save_g64_name_s, FA_CREATE_ALWAYS|FA_WRITE))
                        {
                            display_string("G64 file opened");
                            display_setcursor(0,1);
                            file_op_status = write_disk(&fd, G64_IMAGE, num_max_tracks);
                            if (file_op_status>0)
                            {
                                (void)dez2out(file_op_status+1,2,byte_str);
                                display_data(byte_str[0]);
                                display_data(byte_str[1]);
                                display_string(" Tracks saved ");
                            } else {
                                display_string("Error:");
                                (void)dez2out(-file_op_status,2,byte_str);
                                display_data(byte_str[0]);
                                display_data(byte_str[1]);
                            }
                        } else {
                            display_string("G64 file open");
                            display_setcursor(0,1);
                            display_string("failed 4 writing");
                        }
                        f_close(&fd);
                        sleep_ms(3000);
                        display_clear();
                        display_home();
                        if (FR_OK == f_open(&fd, product_save_d64_name_s, FA_CREATE_ALWAYS|FA_WRITE))
                        {
                            display_string("D64 file opened");
                            display_setcursor(0,1);
                            file_op_status = write_disk(&fd, D64_IMAGE, num_max_tracks);
                            if (file_op_status>0)
                            {
                                (void)dez2out(file_op_status+1,2,byte_str);
                                display_data(byte_str[0]);
                                display_data(byte_str[1]);
                                display_string(" Tracks saved ");
                            } else {
                                display_string("Error:");
                                (void)dez2out(-file_op_status,2,byte_str);
                                display_data(byte_str[0]);
                                display_data(byte_str[1]);
                            }
                        } else {
                            display_string("D64 file open");
                            display_setcursor(0,1);
                            display_string("failed 4 writing");
                        }
                        f_close(&fd);
                        sleep_ms(3000);
                        umount_sdcard();
                        menu_refresh();
                    }
                    break;

                case M_UNLOAD_IMAGE:
                    unmount_image();
                    umount_sdcard();
                    set_gui_mode(GUI_INFO_MODE);
                    break;

                case M_RELOAD_DISK:
                    if (is_image_mount)
                    {
                        is_image_mount = false;
                        for(uint8_t i=0; i<LCD_LINE_SIZE; i++)
                        {
                            display_setcursor(i,0);
                            display_data(display_cursor_char);
                            sleep_ms(50);
                        }
                        for(uint8_t i=0; i<LCD_LINE_SIZE; i++)
                        {
                            display_setcursor(i,0);
                            display_data(' ');
                            sleep_ms(50);
                        }
                        is_image_mount = true;
                        set_gui_mode(GUI_INFO_MODE);
                    }
                    break;

                case M_WP_IMAGE:
                    if(menu_get_entry_var1(&image_menu, M_WP_IMAGE))
                    {
                        enable_write_protection();
                    } else {
                        disable_write_protection();
                    }
                    set_gui_mode(GUI_INFO_MODE);
                    break;

                /// Settings Menü
                case M_RESTART:
                    // exit_main = 0;
                    menu_refresh();
                    break;

                /// Info Menü
                case M_VERSION_INFO:
                    show_start_message();
                    wait_key(KEY2_DOWN);
                    menu_refresh();
                    break;

                case M_SDCARD_INFO:
                    if (FR_OK == mount_sdcard())
                    {
                        show_sdcard_info_message();
                        wait_key(KEY2_DOWN);
                    } else {
                        display_clear();
                        display_home();
                        display_string("f_mount error:");
                        display_data(fr+'A');
                        show_fs_error(fr);
                    }
                    umount_sdcard();
                    menu_refresh();
                    break;

                default:
                    break;
            }
            break;

        default:
            break;
    }
}

/////////////////////////////////////////////////////////////////////

void set_gui_mode(const uint8_t gui_mode)
{
    current_gui_mode = gui_mode;
    switch(gui_mode)
    {
        case GUI_INFO_MODE:
            infomode_update();
            break;

        case GUI_MENU_MODE:
            menu_refresh();
            break;

        case GUI_FILE_BROWSER:
            filebrowser_refresh();
            break;

        case GUI_SELECTOR:
            handle_selector_image();
            break;

        default:
            break;
    }
}

void show_start_message(void)
{
    display_clear();
    display_setbright(true);
    display_setcursor(disp_versiontxt_p);
    display_string(disp_versiontxt_s);
    display_setcursor(disp_firmwaretxt_p);
    display_string(disp_firmwaretxt_s);
    display_string(VERSION);
}

/////////////////////////////////////////////////////////////////////

void handle_selector_image(void)
{
    FILINFO hsi_dir_entry;

    if (SELECTOR_IMAGE != akt_image_type)
    {
        // insert the virtual menu-image
        insert_menu_image(current_path);
        infomode_update();
    } else {
        // we have the selector inserted.. now handle the selection
        if (track_is_written)
        {
            if (DIRECTORY_TRACK == track_write_nr)
            {
                // something was changed on the image.. lets fetch the image-number

                // simple approach: convert the complete track, all 19 sectors.. then select sector 2 and read 2 bytes
                convert_gcr2d64track(DIRECTORY_TRACK);
                selected_image_nr = *((uint16_t*) &d64_sector_puffer[1+2*D64_SECTOR_SIZE]);

                if (0 != selected_image_nr)
                {
                    FRESULT fr;
                    display_setcursor(disp_scrollfilename_p);
                    for(uint8_t i=0; i<LCD_LINE_SIZE; i++)
                    {
                        display_data(display_cursor_char);
                        sleep_ms(250/LCD_LINE_SIZE);
                    }
                    display_setcursor(disp_scrollfilename_p);
                    for(uint8_t i=0; i<LCD_LINE_SIZE; i++)
                    {
                        display_data(' ');
                        sleep_ms(250/LCD_LINE_SIZE);
                    }

                    if (1 < strlen(current_path))
                    {
                        --selected_image_nr;
                    }
                    if (0 == selected_image_nr)
                    {
                        // first entry selected, which is ".." in this case
                        // create a fake dir-entry and open it afterwards
                        strcpy(hsi_dir_entry.fname, "..");
                        hsi_dir_entry.fattrib = AM_DIR;
                        fr = FR_OK;
                    } else {
                        seek_to_dir_entry(selected_image_nr-1, current_path);
                        fr = f_readdir(&dir_object, &hsi_dir_entry);
                    }

                    if((0 != hsi_dir_entry.fname[0]) && (FR_OK == fr))
                    {
                        if (TYPE_VALID != open_dir_entry(hsi_dir_entry))
                        {
                            // no valid image available / or we jumped into a folder
                            is_image_mount=false;
                            //rebuild the data-file
                            insert_menu_image(current_path);
                            infomode_update();
                        } else
                        {
                            set_gui_mode(GUI_INFO_MODE);
                        }
                    }
                }
            }
            track_is_written = false;
        }
    }
}

void insert_menu_image(char* menu_path)
{
    FRESULT fr = mount_sdcard();
    if (FR_OK == fr)
    {
        f_closedir(&dir_object);

        char pattern[] = {"*"};

        dir_object.pat = pattern;           /* Save pointer to pattern string */
        fr = f_opendir(&dir_object, menu_path);  /* Open the target directory */

        if(FR_OK == fr)
        {
            stop_bytetimer();
            send_byte_ready = false;         // disable VIA transfer

            const uint8_t id_buffer[]={" F00K"};      // disk-id
            id1 = id_buffer[0];
            id2 = id_buffer[1];
            num_max_tracks = 35;// MAX_TRACKS;
            generate_empty_image(id1,id2,num_max_tracks);

            // generates menu-file..
            size_t menu_file_len = generate_menu_file(&dir_object, menu_path, SCRATCH_TRACK);
            size_t buffer_size = menu_file_len;
            size_t buffer_left;
            int8_t file_track = MENU_DATA_TRACK, next_file_track = file_track;
            uint8_t* file_buffer_pointer = g64_tracks[SCRATCH_TRACK];
            uint8_t prev_sector = 0;
            do
            {
                buffer_left = buffer_to_track(file_buffer_pointer, buffer_size, file_track, &prev_sector);
                if (buffer_left>0)
                {
                    next_file_track = file_track-1;
                    file_buffer_pointer += (buffer_size-buffer_left);
                    buffer_size = buffer_left;
                    // last sector ?? -> update last sector-chain-pointer to new "file_track,0"...
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE]=next_file_track+1;
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE+1]=0;
                }
                convert_d64track2gcr(file_track, id1, id2);
                file_track = next_file_track;
                /* code */
            } while ((buffer_left>0) && (file_track>=0));

            memset(d64_sector_puffer, 0, sizeof(d64_sector_puffer));
            for(uint8_t track_nr=SCRATCH_TRACK; track_nr<num_max_tracks; ++track_nr)
            {
                convert_d64track2gcr(track_nr, id1, id2);
            }

            // generates selector_file..
            buffer_size = menu_prg_len;
            file_track = SELECTOR_TRACK;
            next_file_track = file_track;
            file_buffer_pointer = (uint8_t*) &menu_prg[0];
            prev_sector = 0;
            do
            {
                buffer_left = buffer_to_track(file_buffer_pointer, buffer_size, file_track, &prev_sector);
                if (buffer_left>0)
                {
                    next_file_track = (file_track+1)%num_max_tracks;
                    file_buffer_pointer += (buffer_size-buffer_left);
                    buffer_size = buffer_left;
                    // last sector ?? -> update last sector-chain-pointer to new "file_track,0"...
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE]=next_file_track+1;
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE+1]=0;
                }
                convert_d64track2gcr(file_track, id1, id2);
                file_track = next_file_track;
                /* code */
            } while (buffer_left>0);

#if !defined(REPICO1551)
            // generates intro file..
            buffer_size = intro_prg_len;
            file_track++;   // we just take the next track after the last selector-file-track
            uint8_t intro_track = file_track;   //store for directory-creation
            file_buffer_pointer = (uint8_t*) &intro_prg[0];
            prev_sector = 0;
            do
            {
                buffer_left = buffer_to_track(file_buffer_pointer, buffer_size, file_track, &prev_sector);
                if (buffer_left>0)
                {
                    next_file_track = (file_track+1)%num_max_tracks;
                    file_buffer_pointer += (buffer_size-buffer_left);
                    buffer_size = buffer_left;
                    // last sector ?? -> update last sector-chain-pointer to new "file_track,0"...
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE]=next_file_track+1;
                    d64_sector_puffer[1+prev_sector*D64_SECTOR_SIZE+1]=0;
                }
                convert_d64track2gcr(file_track, id1, id2);
                file_track = next_file_track;
                /* code */
            } while (buffer_left>0);
#endif

            memset(d64_sector_puffer, 0, sizeof(d64_sector_puffer));
            strcpy(image_filename, "\06 ONSCREEN MENU");
            generate_bam(product_bam_label_s, id_buffer);
            // create a file-entry in the directory...
            generate_directory_entry("SELECTOR", CBMDOS_TYPE_PRG, SELECTOR_TRACK ,0,((uint16_t) (menu_prg_len/254))+1);
            generate_directory_entry("DATAFILE", CBMDOS_TYPE_PRG, MENU_DATA_TRACK,0,((uint16_t) (menu_file_len/254))+1);
#if !defined(REPICO1551)
            generate_directory_entry("INTRO",    CBMDOS_TYPE_PRG, intro_track    ,0,((uint16_t) (intro_prg_len/254))+1);
#endif
            convert_d64track2gcr(DIRECTORY_TRACK, id1, id2);

            akt_track_pos = 0;
            selected_track = (INIT_TRACK << 1);
            akt_half_track = selected_track;

            send_byte_ready = true;         // enable VIA transfer
            is_image_mount = true;

            akt_image_type = SELECTOR_IMAGE;    // to identify the write-back-channel handling
            track_is_written = false;

            disable_write_protection();      // we need to be able to receive the answer of menu-selector as "write"

            send_disk_change();

            start_bytetimer(akt_half_track);    // start the track-spinning

            menu_set_entry_var1(&image_menu, M_WP_IMAGE, floppy_wp);
        }
    } else {
        display_clear();
        display_home();
        display_string("f_mount error:");
        display_data(fr+'A');
        show_fs_error(fr);
    }
}

/////////////////////////////////////////////////////////////////////

void infomode_update(void)
{
    uint8_t byte_str[3];

    display_clear();

    display_setcursor(disp_tracktxt_p);
    display_string(disp_tracktxt_s);

    display_setcursor(disp_trackno_p);
    (void)dez2out((akt_half_track>>1)+1, 2, byte_str);
    display_data(byte_str[0]);
    display_data(byte_str[1]);

    if(get_motor_status())
    {
        display_setcursor(disp_motortxt_p);
        display_string(disp_motor_on_s);
    }

    if(floppy_wp)
    {
        display_setcursor(disp_writeprottxt_p);
        display_string(disp_writeprot_on_s);
    }

    display_setcursor(disp_scrollfilename_p);
    if(is_image_mount)
    {
        display_print(image_filename,0,LCD_LINE_SIZE);

        // Für Scrollenden Filename
        int8_t var = (int8_t)strlen(image_filename) - LCD_LINE_SIZE;
        if(var < 0)
        {
            var = 0;
        }

        gui_current_line_offset = var;
        gui_line_scroll_pos = 0;
        gui_line_scroll_direction = 0;
        gui_line_scroll_end_begin_wait = 6;
    } else {
        display_string(disp_nofilemounted_s);
    }
}

/////////////////////////////////////////////////////////////////////

void filebrowser_update(uint8_t key_code)
{
    static uint32_t fbup_wait_counter0 = 0;

    switch (key_code)
    {
    case KEY0_DOWN:
        if(fb_cursor_pos > 0)
        {
            --fb_cursor_pos;
            filebrowser_refresh();
        }
        else
        {
            if(fb_window_pos > 0)
            {
                --fb_window_pos;
                filebrowser_refresh();
            }
        }
        break;
    case KEY1_DOWN:
        if((fb_cursor_pos < (LCD_LINE_COUNT-1)) && (fb_cursor_pos < (fb_dir_entry_count-1)))
        {
            ++fb_cursor_pos;
            filebrowser_refresh();
        }
        else
        {
            if(fb_window_pos < (fb_dir_entry_count - LCD_LINE_COUNT))
            {
                ++fb_window_pos;
                filebrowser_refresh();
            }
        }
        break;
    case KEY2_UP:
        //fn open dir_entry...
        uint8_t ode_return = open_dir_entry(fb_dir_entry[fb_cursor_pos]);
        if (TYPE_VALID != ode_return)
        {
            // no valid image available / or we jumped into a folder
            if (TYPE_NONE == ode_return)
            {
                display_clear();
                display_setcursor(disp_unsupportedimg_p);
                display_string(disp_unsupportedimg_s);
                sleep_ms(1000);
            }
            is_image_mount=false;
            filebrowser_refresh();
        } else {
            selected_image_nr = fb_window_pos+fb_cursor_pos+1;
            set_gui_mode(GUI_INFO_MODE);
        }
        break;
    case KEY2_TIMEOUT1:
        set_gui_mode(GUI_MENU_MODE);
        break;
    case KEY2_TIMEOUT2:
        // move up one directory level if possible
        if (1 < strlen(current_path))
        {
            FILINFO fbu_dir_entry;
            strcpy(fbu_dir_entry.fname, "..");
            fbu_dir_entry.fattrib = AM_DIR;
            (void) open_dir_entry(fbu_dir_entry);
            is_image_mount=false;
            filebrowser_refresh();
        }
        break;

    default:
    }

    //// Filename Scrolling
    ++fbup_wait_counter0;

    if((fb_current_line_offset > 0) && (fbup_wait_counter0 >= 300000))
    {
        fbup_wait_counter0 = 0;

        if(0 == fb_line_scroll_end_begin_wait)
        {
            // Es darf gescrollt werden
            if(!fb_line_scroll_direction)
            {
                ++fb_line_scroll_pos;
                if(fb_line_scroll_pos >= fb_current_line_offset)
                {
                    fb_line_scroll_end_begin_wait = 6;
                    fb_line_scroll_direction = 1;
                }
            }
            else
            {
                --fb_line_scroll_pos;
                if(fb_line_scroll_pos == 0)
                {
                    fb_line_scroll_end_begin_wait = 6;
                    fb_line_scroll_direction = 0;
                }
            }

            display_setcursor(2,fb_cursor_pos);
            display_print(fb_dir_entry[fb_cursor_pos].fname,fb_line_scroll_pos, LCD_LINE_SIZE-3 );
        }
        else
        {
            --fb_line_scroll_end_begin_wait;
        }
    }
}

uint8_t open_dir_entry(FILINFO od_file_entry)
{
    int8_t last_track_read;

    stop_bytetimer();
    send_byte_ready = false;      // this blocks current transfers to the VIA
    close_disk_image(&fd);

    if(od_file_entry.fattrib & AM_DIR)
    {
        // selected entry seems to be a directory
        if (0 == strcmp(od_file_entry.fname, ".."))
        {
            // parent directory selected .. so we go one level up
            char* last_slash = strrchr(current_path,'/');
            if (NULL != last_slash)
            {
                *last_slash = 0;
            }
            if (1 > strlen(current_path))
            {
                current_path[0]='/';
                current_path[1]=0;
            }
        } else {
            // append new filder-name to the existing path
            if (1 < strlen(current_path))
            {
                strcat(current_path, "/");
            }
            strcat(current_path, od_file_entry.fname);
        }
        f_chdir(current_path);
        fb_dir_entry_count = get_dir_entry_count(current_path);

        fb_cursor_pos = 0;
        fb_window_pos = 0;
        return TYPE_DIR;
    }

    akt_image_type = open_disk_image(&fd, &od_file_entry);

    if(UNDEF_IMAGE == akt_image_type)
    {
        fd.obj.fs = 0;
    }

    if(0 == fd.obj.fs)
    {
        return TYPE_NONE;
    }

    strcpy(image_filename, od_file_entry.fname);

    // read complete image
    if ((last_track_read=read_disk(&fd, akt_image_type, od_file_entry ))>0)
    {
        close_disk_image(&fd);  // we can close the image - everything needed is in ram now.
        akt_track_pos = 0;

        send_byte_ready = true;         // enable VIA transfer
        is_image_mount = true;
        num_max_tracks = last_track_read+1;

        enable_write_protection();      // this is the default
        if (0 == (od_file_entry.fattrib & AM_RDO))
        {
            disable_write_protection();
        }

        send_disk_change();

        start_bytetimer(akt_half_track);    // start the track-spinning

        menu_set_entry_var1(&image_menu, M_WP_IMAGE, floppy_wp);
    } else {
        close_disk_image(&fd);
        akt_image_type = UNDEF_IMAGE;
        is_image_mount = false;
        return TYPE_NONE;
    }
    return TYPE_VALID;    // dont know which type we opened, but it was okay
}


/////////////////////////////////////////////////////////////////////
// refresh filebrowser view:
// - clear display
// - list max.4 entries from current directory (starting from fb_window_pos)
// - mark directories with a symbol
// - create arrow-up and arrow-down when needed
// - prepare filename-scrolling when too long (for other view)
//
void filebrowser_refresh(void)
{
    display_clear();

    seek_to_dir_entry(fb_window_pos, current_path);

    uint8_t i=0;

    if ((1 < strlen(current_path)) && (0 == fb_window_pos))
    {
        strcpy(fb_dir_entry[0].fname, "..");
        fb_dir_entry[0].fattrib = AM_DIR;
        ++i;
    }

    while((i<LCD_LINE_COUNT) && ((fb_window_pos + i) < fb_dir_entry_count))
    {
        FRESULT fr = f_readdir(&dir_object, &(fb_dir_entry[i]));
        if((0 == fb_dir_entry[i].fname[0]) || (FR_OK != fr))
        {
            break;
        }
        ++i;
    }

    for (uint8_t j=0; j<i; j++)
    {
        display_setcursor(1,j);
        if(fb_dir_entry[j].fattrib & AM_DIR)
        {
            display_data(display_dir_char);
        } else {
            display_data(' ');
        }

        display_print(fb_dir_entry[j].fname, 0, LCD_LINE_SIZE-3);
    }

    display_setcursor(0, fb_cursor_pos);
    display_data(display_pointer_char);


    if(fb_window_pos > 0)
    {
        display_setcursor(LCD_LINE_SIZE-1,0);
        display_data(display_more_top_char);
    }

    if((fb_window_pos + LCD_LINE_COUNT) < fb_dir_entry_count)
    {
        display_setcursor(LCD_LINE_SIZE-1, LCD_LINE_COUNT-1);
        display_data(display_more_down_char);
    }

    // Für Scrollenden Filename
    int8_t var = (int8_t)strlen(fb_dir_entry[fb_cursor_pos].fname) - (LCD_LINE_SIZE-3);
    if(var < 0)
        fb_current_line_offset = 0;
    else
        fb_current_line_offset = var;

    fb_line_scroll_pos = 0;
    fb_line_scroll_direction = 0;
    fb_line_scroll_end_begin_wait = 6;
}

/////////////////////////////////////////////////////////////////////

uint16_t get_dir_entry_count(const char* entrycount_path)
{
    uint16_t entry_count = 0;

    f_closedir(&dir_object);

    char pattern[] = {"*"};

    dir_object.pat = pattern;           /* Save pointer to pattern string */
    if (FR_OK == f_opendir(&dir_object, entrycount_path))  /* Open the target directory */
    {
        FILINFO gdec_dir_entry;
        while(FR_OK == f_readdir(&dir_object, &gdec_dir_entry))
        {
            if(0 == gdec_dir_entry.fname[0])
            {
                break;
            }
            ++entry_count;
        }
    }
    if (1 < strlen(entrycount_path)) { ++entry_count; }
    return entry_count;
}

/////////////////////////////////////////////////////////////////////

uint16_t seek_to_dir_entry(uint16_t entry_num, const char* seek_path)
{
    f_closedir(&dir_object);

    char pattern[] = {"*"};
    // if we are in a subfolder and not the first entry (="..") was selected, decrease the seek index by 1
    if ((1 < strlen(seek_path)) && (0 < entry_num)) { --entry_num; }

    dir_object.pat = pattern;           /* Save pointer to pattern string */
    if(FR_OK == f_opendir(&dir_object, seek_path))  /* Open the target directory */
    {
        f_readdir(&dir_object, 0);  // rewind the directory
        while (0 < entry_num)
        {
            FILINFO seek_dir_entry;
            FRESULT fr = f_readdir(&dir_object, &seek_dir_entry);
            if((FR_OK != fr) || (0 == seek_dir_entry.fname[0]))
            {
                break;
            }
            --entry_num;
        }
    }
    return entry_num;
}

/////////////////////////////////////////////////////////////////////

uint8_t open_disk_image(FIL* fd, FILINFO *file_entry)
{
    size_t namelen;
    char extension[5];
    uint8_t image_type;

    namelen = strlen(file_entry->fname);
    if(4 > namelen) return UNDEF_IMAGE;

    // check the extension for a supported type (d64, g64, prg)
    namelen -= 4; // move copy-pointer 4 backwards
    for (int i=0; i<5; i++)
    {
        extension[i] = tolower(file_entry->fname[namelen+i]);
    }

    if(0 == strcmp(extension,".g64"))
    {
        image_type = G64_IMAGE;
    }
    else if(0 == strcmp(extension,".d64"))
    {
        image_type = D64_IMAGE;
    }
    else if(0 == strcmp(extension,".prg"))
    {
        image_type = PRG_IMAGE;
    } else {
        // extension unknown -> we wont try to open the file at all..
        return UNDEF_IMAGE;
    }

    if (FR_OK != f_chdir(current_path))
    {
        return UNDEF_IMAGE;
    }
    if (FR_OK != f_open(fd, file_entry->fname, FA_READ))
    {
        // image could not be opened for reading
        f_close(fd);
        return UNDEF_IMAGE;
    }
    return image_type;
}

/////////////////////////////////////////////////////////////////////

void close_disk_image(FIL* fd)
{
    f_close(fd);
}

/////////////////////////////////////////////////////////////////////

void init_writeprot(void)
{
    gpio_init(GPIO_WPS);
#if REPICO1551
    // Drive both levels on WPS_3V3 (BSS138 gate@3V3). High = FET off; low = FET on.
    // R10 must pull CPU WPS to 5V when FET is off — Pico cannot force 5V high through the FET.
    gpio_set_dir(GPIO_WPS, GPIO_OUT);
    gpio_put(GPIO_WPS, false);   // default protected until mount/menu sets otherwise
    gpio_set_pulls(GPIO_WPS, false, false);
#else
    gpio_set_dir(GPIO_WPS, GPIO_IN);
    // 1541: external 74LS04; Pico pull-up would fight the inverter input.
    gpio_set_pulls(GPIO_WPS, false, false);
#endif
}

/////////////////////////////////////////////////////////////////////

void send_disk_change(void)
{
    // 1551 IRQ (~every 16650 cycles @ 2 MHz ≈ 8 ms) samples $01 bit4 in L_FA41.
    // Hold each level long enough for several IRQ samples (Pi1541-style eject/insert).
    // clear_wps/set_wps are board-mapped so clear=protected (0), set=writable (1) at the CPU.
    const uint32_t hold_ms = 50;

    clear_wps();            // protected while old disk ejects
    sleep_ms(hold_ms);
    set_wps();              // no disk / notch open
    sleep_ms(hold_ms);
    clear_wps();            // protected while new disk inserts
    sleep_ms(hold_ms);
    if (!floppy_wp) {
        set_wps();          // final: writable
    }
    // else leave protected
}

/////////////////////////////////////////////////////////////////////

void unmount_image(void)
{
    close_disk_image(&fd);
    is_image_mount = 0;
    akt_image_type = UNDEF_IMAGE;
    num_max_tracks = 0;
    enable_write_protection();
    menu_set_entry_var1(&image_menu, M_WP_IMAGE, 1);
    send_disk_change();
}

/////////////////////////////////////////////////////////////////////

void show_sdcard_info_message(void)
{
    if (0 != fs.fs_type)    // check for valid mounted file-system
    {
        display_clear();
        display_home();

        display_string(disp_sdinfo_size_s);
        // sprintf(out_str, "%d MB", (uint16_t)(info.capacity / 1024 / 1024));
        // display_string(out_str);

        display_setcursor(0,1);
        display_string(disp_sdinfo_part_s);

        switch (fs.fs_type)
        {
            case FS_FAT12:
                display_string("FAT12");
                break;
            case FS_FAT16:
                display_string("FAT16");
                break;
            case FS_FAT32:
                display_string("FAT32");
                break;
            case FS_EXFAT:
                display_string("EXT FAT");
                break;
            default:
                break;
        }
    }
    sleep_ms(START_MESSAGE_TIME);

    // struct sd_raw_info info;

    // uint8_t counter = 5;
    // uint8_t get_info_ok = 0;
    // char out_str[21];

    // while(counter != 0)
    // {
    //     if(0 != sd_raw_get_info(&info))
    //     {
    //         display_setcursor(disp_sdinfo_manuf_p);
    //         display_string(disp_sdinfo_manuf_s);
    //         sprintf(out_str, "%.x", info.manufacturer);
    //         display_string(out_str);

    //         display_setcursor(disp_sdinfo_oem_p);
    //         display_string(disp_sdinfo_oem_s);
    //         display_string((char*) info.oem);

    //         display_setcursor(disp_sdinfo_prod_p);
    //         display_string(disp_sdinfo_prod_s);
    //         display_string((char*) info.product);

    //         display_setcursor(disp_sdinfo_size_p);
    //         display_string(disp_sdinfo_size_s);
    //         sprintf(out_str, "%d MB", (uint16_t)(info.capacity / 1024 / 1024));
    //         display_string(out_str);

    //         get_info_ok = 1;

    //         break;
    //     }

    //     release_sd_card();
    //     (void) init_sd_card();

    //     counter--;
    // }

    // if(!get_info_ok)
    // {
    //     display_clear();
    //     display_setcursor(disp_geterr_failure_p);
    //     display_string(disp_geterr_failure_s);
    //     display_setcursor(disp_sdrawgetinfo_p);
    //     display_string(disp_sdrawgetinfo_s);
    //     return;
    // }

    // _delay_ms(START_MESSAGE_TIME);

    // display_clear();

    // display_setcursor(disp_sdinfo_rev_p);
    // display_string(disp_sdinfo_rev_s);
    // sprintf(out_str,"%c.%c",(info.revision>>4)+'0', (info.revision&0x0f)+'0');
    // display_string(out_str);

    // display_setcursor(disp_sdinfo_serial_p);
    // display_string(disp_sdinfo_serial_s);
    // sprintf(out_str,"%04X%04X",(unsigned int) (info.serial >> 16),(unsigned int) (info.serial & 0xffff));
    // display_string(out_str);

    // display_setcursor(disp_sdinfo_part_p);
    // display_string(disp_sdinfo_part_s);
    // switch(partition->type)
    // {
    //     case 0x01:
    //         display_string("FAT12");
    //         break;

    //     case 0x04:
    //         display_string("FAT16 <32MB");
    //         break;

    //     case 0x05:
    //         display_string("EXTENDED");
    //         break;

    //     case 0x06:
    //         display_string("FAT16");
    //         break;

    //     case 0x0b:
    //         display_string("FAT32");
    //         break;

    //     case 0x0c:
    //         display_string("FAT32 LBA");
    //         break;

    //     case 0x0e:
    //         display_string("FAT16 LBA");
    //         break;

    //     case 0x0f:
    //         display_string("EXT LBA");
    //         break;

    //     default:
    //         display_string("UNKNOWN");
    //         break;
    // }
    // _delay_ms(START_MESSAGE_TIME);
}

/////////////////////////////////////////////////////////////////////

void init_stepper(void)
{
    // Stepper PINs als Eingang schalten
    gpio_init(GPIO_STP0);
    gpio_init(GPIO_STP1);
    gpio_set_pulls(GPIO_STP0, true, false);
    gpio_set_pulls(GPIO_STP1, true, false);
    gpio_set_dir(GPIO_STP0, GPIO_IN);
    gpio_set_dir(GPIO_STP1, GPIO_IN);

    selected_track = (INIT_TRACK << 1);
    akt_half_track = selected_track;

    // Pin Change Interrupt für beide STPx PIN's aktivieren
    gpio_set_irq_enabled(GPIO_STP0, GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true);
    gpio_set_irq_enabled(GPIO_STP1, GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true);
}

/////////////////////////////////////////////////////////////////////

void stepper_inc(void)
{
    if(selected_track >= ((MAX_TRACKS-1)<<1)) return;

    ++selected_track;
}

/////////////////////////////////////////////////////////////////////

void stepper_dec(void)
{
    if(selected_track == 0) return;

    --selected_track;
}

/////////////////////////////////////////////////////////////////////

void init_motor(void)
{
    // Als Eingang schalten
    gpio_init(GPIO_MTR);
    gpio_set_pulls(GPIO_MTR, true, false);
    gpio_set_dir(GPIO_MTR, GPIO_IN);
}

/////////////////////////////////////////////////////////////////////

void init_control_signals(void)
{
    // Als Ausgang schalten
    //DDxn = 0 , PORTxn = 0 --> HiZ
    //DDxn = 1 , PORTxn = 0 --> Output Low (Sink)
    gpio_init(GPIO_BRDY);
    gpio_set_pulls(GPIO_BRDY, false, false);
    gpio_set_dir(GPIO_BRDY, GPIO_IN);
    // BYTE_READY_DDR &= ~(1<<BYTE_READY);             // Byte Ready auf HiZ
    // BYTE_READY_PORT &= ~(1<<BYTE_READY);

    gpio_init(GPIO_SYNC);
    gpio_set_dir(GPIO_SYNC, GPIO_OUT);

    gpio_set_drive_strength(GPIO_SYNC, GPIO_DRIVE_STRENGTH_12MA);

    // Als Eingang schalten
    gpio_init_mask(PAPORT_MASK);
    gpio_set_pulls(GPIO_PAPORT  , true, false);
    gpio_set_pulls(GPIO_PAPORT+1, true, false);
    gpio_set_pulls(GPIO_PAPORT+2, true, false);
    gpio_set_pulls(GPIO_PAPORT+3, true, false);
    gpio_set_pulls(GPIO_PAPORT+4, true, false);
    gpio_set_pulls(GPIO_PAPORT+5, true, false);
    gpio_set_pulls(GPIO_PAPORT+6, true, false);
    gpio_set_pulls(GPIO_PAPORT+7, true, false);
    gpio_set_dir_in_masked(PAPORT_MASK); // should set all 8 bits to input

    gpio_set_drive_strength(GPIO_PAPORT  , GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+1, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+2, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+3, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+4, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+5, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+6, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(GPIO_PAPORT+7, GPIO_DRIVE_STRENGTH_12MA);

#if !REPICO1551
    gpio_init(GPIO_SOE);
    gpio_set_pulls(GPIO_SOE, true, false);
    gpio_set_dir(GPIO_SOE, GPIO_IN);
#endif

    gpio_init(GPIO_OE);
    gpio_set_pulls(GPIO_OE, true, false);
    gpio_set_dir(GPIO_OE, GPIO_IN);
}

/////////////////////////////////////////////////////////////////////

#if !REPICO1551
void init_soe_gatearray(void)
{
    gpio_init(GPIO_SOE_GA);
    gpio_set_dir(GPIO_SOE_GA, GPIO_OUT);
    set_soe_gatearray();
}
#endif

/////////////////////////////////////////////////////////////////////

void init_bytetimer(void)
{
    stop_bytetimer();
}

/////////////////////////////////////////////////////////////////////

void start_bytetimer(uint8_t half_track)
{
    (void) add_repeating_timer_us(-bytetimer_values[d64_track_zone[half_track>>1]], repeating_timer_callback, NULL, &bytetimer);
}

/////////////////////////////////////////////////////////////////////

void stop_bytetimer(void)
{
    (void) cancel_repeating_timer(&bytetimer);
}

///////////////////////////////////////
///////// ISR
///////////////////////////////////////


//ISR (TIMER0_COMPA_vect)
bool repeating_timer_callback(__unused struct repeating_timer *t)
{
    // ISR wird alle 26,28,30 oder 32µs ausfgrufen
    // Je nach dem welche Spur gerade aktiv ist

    uint8_t akt_gcr_byte;

    if(get_so_status())
    {
        static uint8_t old_gcr_byte = 0;
        uint8_t is_sync;
        // LESE MODUS
        // Daten aus Ringpuffer senden wenn Motor an und ein Image gemountet ist
        if(get_motor_status() && is_image_mount)
        {                                                               // Wenn Motor läuft
            akt_gcr_byte = g64_tracks[akt_half_track>>1][akt_track_pos++];          // Nächstes GCR Byte holen
            if(akt_track_pos == g64_tracklen[akt_half_track>>1]) akt_track_pos = 0; // Ist Spurende erreicht? Zurück zum Anfang

            if((GCR_SYNCMARK == akt_gcr_byte) && (GCR_SYNCMARK == old_gcr_byte))    // Prüfen auf SYNC (mindesten 2 aufeinanderfolgende 0xFF)
            {                                                           // Wenn SYNC
                clear_sync();                                           // SYNC Leitung auf Low setzen
                is_sync = 1;                                            // SYNC Merker auf 1
            }
            else
            {                                                           // Wenn kein SYNC
                set_sync();                                             // SYNC Leitung auf High setzen
                is_sync = 0;                                            // SYNC Merker auf 0
            }
        }
        else
        {                                                               // Wenn Motor nicht läuft
            akt_gcr_byte = 0x00;                                        // 0 senden wenn Motor aus
            is_sync = 0;                                                // SYNC Merker auf 0
        }

        // SOE
        // Unabhängig ob der Motor läuft oder nicht
        if(get_soe_status())
        {
            if(!is_sync)
            {
                gpio_set_dir_out_masked(PAPORT_MASK);
                out_gcr_byte(akt_gcr_byte);

                if(send_byte_ready)
                {
                    // BYTE_READY für 3µs löschen
                    clear_byte_ready();
                    sleep_us(3);
                    set_byte_ready();
                }
            }
            // else --> kein Byte senden !!
        }
        old_gcr_byte = akt_gcr_byte;
    }
    else
    {
        // SCHREIB MODUS

        if (!block_data_changes)    // only accept changes when no image-dump is happening
        {
            // SOE
            // Unabhängig ob der Motor läuft oder nicht
            if(get_soe_status())
            {
                gpio_set_dir_in_masked(PAPORT_MASK);
                akt_gcr_byte = in_gcr_byte();

                if(send_byte_ready)
                {
                    // BYTE_READY für 3µs löschen
                    clear_byte_ready();
                    sleep_us(3);
                    set_byte_ready();
                }
            }

            // Daten aus Ringpuffer senden wenn Motor an
            if(get_motor_status())
            {
                if (!track_is_written)
                {
                    track_write_nr  = akt_half_track>>1;
                    track_write_pos = akt_track_pos;
                }
                // Wenn Motor läuft
                g64_tracks[akt_half_track>>1][akt_track_pos++] = akt_gcr_byte;  // Nächstes GCR Byte schreiben
                track_is_written = true;
                if(akt_track_pos == g64_tracklen[akt_half_track>>1]) akt_track_pos = 0;    // Ist Spurende erreicht? Zurück zum Anfang
            }
        }
    }
    return true;
}
