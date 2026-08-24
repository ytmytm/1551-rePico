/* menu structure handling */

// taken over from 1541-rebuild from Th.Kattanek

// last change: 18/07/2026

#include "menu.h"
#include "display.h"
#include "gui_constants.h"

static MENU_STRUCT *current_menu;
static bool editing_8bit = false;
static uint8_t menu_shown_window_pos = 0xff;
static uint8_t menu_cursor_shown = 0xff;

void menu_init(MENU_STRUCT* menu, MENU_ENTRY *menu_entrys, const uint8_t menu_entry_count, const uint8_t lcd_col_count, const uint8_t lcd_row_count)
{
    menu->entry_list = menu_entrys;
    menu->entry_count = menu_entry_count;
    menu->lcd_col_count = lcd_col_count;
    menu->lcd_row_count = lcd_row_count;

    menu->pos = 0;
    menu->lcd_cursor_pos = 0;
    menu->lcd_window_pos = 0;

    menu->lcd_cursor_char    = display_pointer_char;  // 126 Standard Pfeil
    menu->lcd_more_top_char  = display_more_top_char;
    menu->lcd_more_down_char = display_more_down_char;

    menu->view_obsolete = 1;
    editing_8bit = false;
}

void menu_set_root(MENU_STRUCT *menu)
{
    current_menu = menu;
    editing_8bit = false;
}

static MENU_ENTRY *menu_current_entry(void)
{
    uint8_t menu_index = current_menu->lcd_window_pos + current_menu->lcd_cursor_pos;
    return &current_menu->entry_list[menu_index];
}

static MENU_ENTRY *menu_entry_at_row(uint8_t screen_row)
{
    uint8_t menu_index = (uint8_t)(current_menu->lcd_window_pos + screen_row);
    if (menu_index >= current_menu->entry_count)
        return 0;
    return &current_menu->entry_list[menu_index];
}

static bool show_preset_star(const MENU_ENTRY *e)
{
    if (ENTRY_8BIT_DEC != e->type)
        return false;
    if ((24u == e->var_min) && (36u == e->var_max))
        return (26u == e->var1) || (28u == e->var1);
    if ((8u == e->var_min) && (28u == e->var_max))
        return (12u == e->var1) || (21u == e->var1);
    return false;
}

static void adjust_8bit(MENU_ENTRY *e, int8_t delta)
{
    int16_t v = (int16_t)e->var1 + delta;
    if (v < (int16_t)e->var_min)
        v = e->var_min;
    if (v > (int16_t)e->var_max)
        v = e->var_max;
    e->var1 = (uint8_t)v;
}

static void menu_clear_row(uint8_t row)
{
    display_setcursor(0, row);
    for (uint8_t c = 0; c < current_menu->lcd_col_count; c++)
        display_data(' ');
}

static void menu_paint_entry_value(MENU_ENTRY *e, uint8_t screen_row)
{
    switch (e->type)
    {
    case ENTRY_ONOFF:
        display_setcursor((uint8_t)(current_menu->lcd_col_count - 3u), screen_row);
        if (e->var1)
            display_string("On");
        else
            display_string("Off");
        break;
    case ENTRY_BIN:
        if (e->var1)
            display_string(" 0");
        else
            display_string(" 1");
        break;
    case ENTRY_BOOL:
        if (e->var1)
            display_string(" T");
        else
            display_string(" F");
        break;
    case ENTRY_8BIT_DEC:
    {
        char num[4];
        num[0] = ' ';
        num[1] = (char)('0' + (e->var1 / 10u));
        num[2] = (char)('0' + (e->var1 % 10u));
        num[3] = 0;
        display_string(num);
        if (show_preset_star(e))
            display_data('*');
        if (editing_8bit && (current_menu->lcd_cursor_pos == screen_row))
            display_data('<');
        break;
    }
    default:
        break;
    }
}

static void menu_paint_row(uint8_t screen_row)
{
    MENU_ENTRY *e = menu_entry_at_row(screen_row);
    if (0 == e)
    {
        menu_clear_row(screen_row);
        return;
    }

    menu_clear_row(screen_row);
    display_setcursor(1, screen_row);
    display_string(e->name);
    menu_paint_entry_value(e, screen_row);
}

static void menu_paint_scroll_hints(void)
{
    display_setcursor((uint8_t)(current_menu->lcd_col_count - 1u), 0);
    display_data(current_menu->lcd_window_pos > 0 ? current_menu->lcd_more_top_char : ' ');
    display_setcursor((uint8_t)(current_menu->lcd_col_count - 1u),
                      (uint8_t)(current_menu->lcd_row_count - 1u));
    display_data((current_menu->lcd_window_pos + current_menu->lcd_row_count) < current_menu->entry_count
                     ? current_menu->lcd_more_down_char
                     : ' ');
}

static void menu_paint_cursor(void)
{
    if (menu_cursor_shown < current_menu->lcd_row_count)
    {
        display_setcursor(0, menu_cursor_shown);
        display_data(' ');
    }

    display_setcursor(0, current_menu->lcd_cursor_pos);
    if (editing_8bit)
        display_data(display_cursor_char);
    else
        display_data(current_menu->lcd_cursor_char);

    menu_cursor_shown = current_menu->lcd_cursor_pos;
}

static void menu_repaint_visible(void)
{
    for (uint8_t i = 0; i < current_menu->lcd_row_count; i++)
        menu_paint_row(i);

    menu_paint_scroll_hints();
    menu_paint_cursor();
    menu_shown_window_pos = current_menu->lcd_window_pos;
}

static void menu_move_cursor(uint8_t old_cursor)
{
    if (old_cursor < current_menu->lcd_row_count)
    {
        display_setcursor(0, old_cursor);
        display_data(' ');
        menu_paint_row(old_cursor);
    }

    menu_paint_cursor();
}

enum menu_refresh_mode
{
    MENU_REFRESH_NONE = 0,
    MENU_REFRESH_CURSOR,
    MENU_REFRESH_ROW,
    MENU_REFRESH_VISIBLE,
    MENU_REFRESH_FULL
};

uint16_t menu_update(const uint8_t key_code)
{
    uint8_t command = MC_NO_COMMAND;
    uint8_t value = 0x00;
    enum menu_refresh_mode refresh = MENU_REFRESH_NONE;
    uint8_t old_cursor = current_menu->lcd_cursor_pos;
    uint8_t old_window = current_menu->lcd_window_pos;
    uint8_t repaint_row = current_menu->lcd_cursor_pos;

    switch (key_code)
    {
        case KEY0_DOWN:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                adjust_8bit(e, -1);
                refresh = MENU_REFRESH_ROW;
                command = MC_CHANGE_ENTRY;
                value = e->id;
            }
            else if (current_menu->lcd_cursor_pos > 0)
            {
                current_menu->lcd_cursor_pos--;
                refresh = MENU_REFRESH_CURSOR;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            else if (current_menu->lcd_window_pos > 0)
            {
                current_menu->lcd_window_pos--;
                refresh = MENU_REFRESH_VISIBLE;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            break;

        case KEY1_DOWN:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                adjust_8bit(e, +1);
                refresh = MENU_REFRESH_ROW;
                command = MC_CHANGE_ENTRY;
                value = e->id;
            }
            else if ((current_menu->lcd_cursor_pos < (current_menu->lcd_row_count - 1))
                     && ((current_menu->lcd_window_pos + current_menu->lcd_cursor_pos) < (current_menu->entry_count - 1)))
            {
                current_menu->lcd_cursor_pos++;
                refresh = MENU_REFRESH_CURSOR;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            else if (current_menu->lcd_window_pos < (current_menu->entry_count - current_menu->lcd_row_count))
            {
                current_menu->lcd_window_pos++;
                refresh = MENU_REFRESH_VISIBLE;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            break;

        case KEY2_UP:
        {
            uint8_t menu_index = current_menu->lcd_window_pos + current_menu->lcd_cursor_pos;
            MENU_ENTRY *e = &current_menu->entry_list[menu_index];
            value = e->id;

            if (editing_8bit && (ENTRY_8BIT_DEC == e->type))
            {
                editing_8bit = false;
                refresh = MENU_REFRESH_ROW;
                command = MC_SELECT_ENTRY;
                break;
            }

            command = MC_SELECT_ENTRY;

            switch (e->type)
            {
                case ENTRY_MENU:
                    e->menu->parent_menu = current_menu;
                    current_menu = e->menu;
                    current_menu->lcd_cursor_pos = 1;
                    editing_8bit = false;
                    refresh = MENU_REFRESH_FULL;
                    break;

                case ENTRY_TO_PARENT:
                    current_menu = current_menu->parent_menu;
                    editing_8bit = false;
                    refresh = MENU_REFRESH_FULL;
                    break;

                case ENTRY_ONOFF:
                case ENTRY_BOOL:
                case ENTRY_BIN:
                    e->var1 ^= 1;
                    e->var1 &= 1;
                    refresh = MENU_REFRESH_ROW;
                    break;

                case ENTRY_8BIT_DEC:
                    editing_8bit = true;
                    refresh = MENU_REFRESH_ROW;
                    command = MC_NO_COMMAND;
                    break;

                default:
                    break;
            }
            break;
        }

        case KEY2_TIMEOUT1:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                editing_8bit = false;
                refresh = MENU_REFRESH_ROW;
                command = MC_SELECT_ENTRY;
                value = e->id;
            }
            else if (current_menu->parent_menu != 0)
            {
                current_menu = current_menu->parent_menu;
                refresh = MENU_REFRESH_FULL;
            }
            else
            {
                command = MC_EXIT_MENU;
            }
            break;

        case KEY2_TIMEOUT2:
            break;

        default:
            break;
    }

    if (MENU_REFRESH_FULL == refresh)
    {
        menu_refresh();
    }
    else if (MENU_REFRESH_VISIBLE == refresh)
    {
        if (old_window != current_menu->lcd_window_pos)
            menu_repaint_visible();
    }
    else if (MENU_REFRESH_ROW == refresh)
    {
        menu_paint_row(repaint_row);
        menu_paint_cursor();
    }
    else if (MENU_REFRESH_CURSOR == refresh)
    {
        if (old_window == current_menu->lcd_window_pos)
            menu_move_cursor(old_cursor);
        else
            menu_repaint_visible();
    }

    return (((uint16_t) command) << 8 | value);
}

void menu_refresh()
{
    display_clear();

    menu_shown_window_pos = 0xff;
    menu_cursor_shown = 0xff;
    menu_repaint_visible();
}

void menu_set_entry_var1(MENU_STRUCT *menu, const uint8_t id, const uint8_t var1)
{
    for (int i = 0; i < menu->entry_count; i++)
    {
        if (menu->entry_list[i].id == id)
        {
            menu->entry_list[i].var1 = var1;
            break;
        }
    }
}

uint8_t menu_get_entry_var1(MENU_STRUCT *menu, const uint8_t id)
{
    for (int i = 0; i < menu->entry_count; i++)
    {
        if (menu->entry_list[i].id == id)
        {
            return menu->entry_list[i].var1;
        }
    }
    return 0;
}
