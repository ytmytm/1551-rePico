/* menu structure handling */

// taken over from 1541-rebuild from Th.Kattanek

// last change: 18/07/2026

#include "menu.h"
#include "display.h"
#include "gui_constants.h"

static MENU_STRUCT *current_menu;
static bool editing_8bit = false;

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

uint16_t menu_update(const uint8_t key_code)
{
    uint8_t command = MC_NO_COMMAND;
    uint8_t value = 0x00;

    switch(key_code)
    {
        case KEY0_DOWN:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                adjust_8bit(e, -1);
                current_menu->view_obsolete = 1;
                command = MC_CHANGE_ENTRY;
                value = e->id;
            }
            else if(current_menu->lcd_cursor_pos > 0)
            {
                current_menu->lcd_cursor_pos--;
                current_menu->view_obsolete = 1;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            else if(current_menu->lcd_window_pos > 0)
            {
                current_menu->lcd_window_pos--;
                current_menu->view_obsolete = 1;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            break;

        case KEY1_DOWN:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                adjust_8bit(e, +1);
                current_menu->view_obsolete = 1;
                command = MC_CHANGE_ENTRY;
                value = e->id;
            }
            else if(    (current_menu->lcd_cursor_pos < (current_menu->lcd_row_count-1))
                && (current_menu->lcd_cursor_pos < (current_menu->entry_count-1)))
            {
                current_menu->lcd_cursor_pos++;
                current_menu->view_obsolete = 1;
                command = MC_CHANGE_ENTRY;
                value = current_menu->entry_list[current_menu->lcd_window_pos + current_menu->lcd_cursor_pos].id;
            }
            else if(current_menu->lcd_window_pos < (current_menu->entry_count - current_menu->lcd_row_count))
            {
                current_menu->lcd_window_pos++;
                current_menu->view_obsolete = 1;
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
                    current_menu->view_obsolete = 1;
                    command = MC_SELECT_ENTRY; /* commit value */
                    break;
                }

                command = MC_SELECT_ENTRY;

                switch (e->type)
                {
                    case ENTRY_MENU:
                        e->menu->parent_menu = current_menu;
                        current_menu = e->menu;
                        current_menu->lcd_cursor_pos = 1;
                        current_menu->view_obsolete = 1;
                        editing_8bit = false;
                        break;

                    case ENTRY_TO_PARENT:
                        current_menu = current_menu->parent_menu;
                        current_menu->view_obsolete = 1;
                        editing_8bit = false;
                        break;

                    case ENTRY_ONOFF:
                    case ENTRY_BOOL:
                    case ENTRY_BIN:
                        e->var1 ^= 1;
                        e->var1 &= 1;
                        current_menu->view_obsolete = 1;
                        break;

                    case ENTRY_8BIT_DEC:
                        editing_8bit = true;
                        current_menu->view_obsolete = 1;
                        command = MC_NO_COMMAND; /* entered edit, no commit yet */
                        break;

                    default:
                        break;
                }
            }
            break;

        case KEY2_TIMEOUT1:
            if (editing_8bit)
            {
                MENU_ENTRY *e = menu_current_entry();
                editing_8bit = false;
                current_menu->view_obsolete = 1;
                command = MC_SELECT_ENTRY; /* commit and stay in menu */
                value = e->id;
            }
            else if(current_menu->parent_menu != 0)
            {
                current_menu = current_menu->parent_menu;
                current_menu->view_obsolete = 1;
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

    if(current_menu->view_obsolete)
    {
        current_menu->view_obsolete = 0;

        menu_refresh();
    }

    return (((uint16_t) command) << 8 | value);
}

void menu_refresh()
{
    display_clear();

    for(int i=0; (i<current_menu->lcd_row_count) && (i<current_menu->entry_count); i++)
    {
        MENU_ENTRY *e = &current_menu->entry_list[i+current_menu->lcd_window_pos];
        display_setcursor(1,i);
        display_string(e->name);

        switch(e->type)
        {
        case ENTRY_ONOFF:
                if(e->var1)
                    display_string(" On");
                else
                    display_string(" Off");
            break;
        case ENTRY_BIN:
                if(e->var1)
                    display_string(" 0");
                else
                    display_string(" 1");
            break;
        case ENTRY_BOOL:
                if(e->var1)
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
                if (editing_8bit
                    && (current_menu->lcd_cursor_pos == (uint8_t)i))
                {
                    display_data('<');
                }
            }
            break;
        }

    }

    display_setcursor(0, current_menu->lcd_cursor_pos);
    if (editing_8bit)
        display_data(display_cursor_char);
    else
        display_data(current_menu->lcd_cursor_char);

    if(current_menu->lcd_window_pos > 0)
    {
        display_setcursor(current_menu->lcd_col_count-1, 0);
        display_data(current_menu->lcd_more_top_char);
    }

    if(current_menu->lcd_window_pos+current_menu->lcd_row_count < current_menu->entry_count)
    {
        display_setcursor(current_menu->lcd_col_count-1, current_menu->lcd_row_count-1);
        display_data(current_menu->lcd_more_down_char);
    }
}

void menu_set_entry_var1(MENU_STRUCT *menu, const uint8_t id, const uint8_t var1)
{
    for(int i=0; i<menu->entry_count; i++)
    {
        if(menu->entry_list[i].id == id)
        {
            menu->entry_list[i].var1 = var1;
            break;
        }
    }
}

uint8_t menu_get_entry_var1(MENU_STRUCT *menu, const uint8_t id)
{
    for(int i=0; i<menu->entry_count; i++)
    {
        if(menu->entry_list[i].id == id)
        {
            return menu->entry_list[i].var1;
        }
    }
    return 0;
}
