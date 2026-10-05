        !to "menu.prg",cbm

        !cpu 6510

;   Typ [8bit, 1 =file, 2=dir], 
;   Filename[chars],stopbyte[8bit, =0] .. jeweils pro eintrag hintereinander
    TYPE_NONE = 0
    TYPE_DIR = 1
    TYPE_D64 = 2
    TYPE_G64 = 3
    TYPE_PRG = 4
    TYPE_UNKNOWN = 255

tmp1 = $02
tmp2 = $ff
ptr1 = $fb
ptr2 = $fd
ptr3 = $f7
directory_end = $ae
x_pos = $92

current_pos = $c1
current_endpos = $c3

current_cursor_position = $9e
current_index_number = $ac

LOAD = $014b
STACK_START = $0138
DRIVECODE_START = $0146

TOGGLE_DISKWRITE_FOR_DISKSWITCH = 2

;CLEANUP_BLOCK_WRITTEN = 1
DRIVE_RESET = 1


MAX_LINE = 23

LINE_SIZES = $033c  ;"MAX_LINE"-bytes to line lengths


!macro dec_word .x {
        lda .x
        bne +
        dec .x+1
+       dec .x
        }

!macro inc_word .x {
        inc .x
        bne +
        inc .x+1
+
}

!macro conv_to_screen {
        cmp #$5f
        bne +
        lda #$64
        bne .store_code
+
        cmp #$60
        bcc .store_code
        sbc #$20
.store_code:
        }
        ;rts

        !ifndef NO_BASIC_HEADER {
        *= $0801
        !by $0b,$08,$00,$00,$9e,$32,$30,$36,$31,$00,$00,$00
        } else {
        * = $0808
        }
        jsr fastload_init
        ;lda #$36
        ;sta $01
        dec $01
restart:
        jsr load_menu_file
        jsr $e518
        ldy #40
-       lda buttomline-1,y
        ora #$80
        sta $0400+24*40-1,y
        lda #$0b
        sta $d800-1,y
        sta $d800+24*40-1,y
        dey
        bne -
        sta $d020
        sty $d021
        lda #$1b
        sta $d011
        ;lda #$39
        sta $d012
        lda #$17
        sta $d018
        lda #$7f
        sta $dc0d
        lda $dc0d
        lda #<irq
        sta $0314
        lda #>irq
        sta $0315
        lda #$81
        sta $d01a
        inc $d019

        ;ldy #<directory_start  ; is zero now
        sty ptr1
        lda #>directory_start
        sta ptr1+1
        sta current_pos+1
-       lda (ptr1),y
        beq end_of_top_line_string
        +conv_to_screen
        ora #$80
        sta $0400,y
        iny
        cpy #40
        bne -
        dey
-       iny
        lda (ptr1),y
        bne -
end_of_top_line_string:
        tya
        tax
-       cpx #40
        bcs end_top_line
        lda #$a0
        sta $0400,x
        inx
        bne -
end_top_line:
        ;tya
        ;sec
        ;adc #<directory_start
        ;sta current_pos
        iny
        sty  current_pos
        ;lda #$00
        ;adc #>directory_start
        ;lda #>directory_start
        ;sta current_pos+1

        jsr calc_at_current_pos
        ldx tmp1
        stx maxline_cmp_value_calc_sizes
        beq +
        dex
+       stx maxline_cmp_value

repaint:
        jsr print_at_current_pos
keyloop:
        jsr $ffe4
        beq keyloop
        cmp #17    ;cursor down
        bne no_cursor_down
        lda current_cursor_position
maxline_cmp_value = *+1
        cmp #MAX_LINE-1
        bcc do_cursor_down
        jsr try_scroll_down
        jmp repaint
do_cursor_down:
        inc current_cursor_position
        jmp keyloop

no_cursor_down:
        cmp #145    ;cursor up
        bne no_cursor_up
        lda current_cursor_position
        beq do_scroll_up
        dec current_cursor_position                
        jmp keyloop
do_scroll_up:
        jsr try_scroll_up
        jmp repaint

no_cursor_up:
        cmp #136    ;f7
        bne no_f7
        lda #MAX_LINE
-       pha
        jsr try_scroll_down
        bcc +
        jsr calc_at_current_pos
+       pla
        sec
        sbc #$01
        bne -
        jmp repaint

no_f7:  cmp #133    ;f1
        bne no_f1
        lda #MAX_LINE
-       pha
        jsr try_scroll_up
        bcc +
        jsr calc_at_current_pos
+       pla
        sec
        sbc #$01
        bne -
        jmp repaint

no_f1:  cmp #29     ;cursor right
        bne no_crsr_right
        lda x_pos
        cmp #255-40
        bcs keyloop
        inc x_pos
        jmp repaint
        
no_crsr_right:
        cmp #157    ;cursor left
        bne no_crsr_left
        lda x_pos
        beq keyloop
        dec x_pos
        jmp repaint
        
no_crsr_left:
        cmp #$13    ; home
        bne no_home
        lda #$00
        sta x_pos
        jmp repaint

no_home:       
        cmp #$20
        beq do_space

        cmp #$0d    ;return
        beq do_space
do_keyloop:
        jmp keyloop
do_space:
        sbc #$20
        sta do_run
        jsr get_current_type
        sta current_type
        cmp #TYPE_PRG+1
        bcs do_keyloop
        cmp #TYPE_DIR
        bcc do_keyloop
        lda #$00
        sta $d01a
        inc $d019
        lda #$31
        sta $0314
        lda #$ea
        sta $0315
        lda #$81
        sta $dc0d
        ;lda $dc0d
        
        lda current_cursor_position
        ;sec        ; carry is set because no "bcc do_keyloop"
        adc current_index_number
        sta index
        lda current_index_number+1
        adc #$00
        sta index+1

        jsr upload_code
        !ifdef CLEANUP_BLOCK_WRITTEN {
        jsr clear_buffer_2
        }
        jsr block_write
        jsr wait_for_flipdisk
        !ifdef DRIVE_RESET {
        jsr drive_reset
        }
current_type = *+1
        lda #$00
        cmp #TYPE_DIR
        bne +
        jmp restart
+        
        ;jsr $e518
do_run = *+1
        lda #$00
        beq do_exit
        sei
        ldx #load_run_text_len
        stx $c6
-       lda load_run_text-1,x
        sta $0277-1,x
        dex
        bne -
do_exit:
        ;lda #$37
        inc $01
        ;jsr $E422
        ;cli
        ;jmp $a474
        jsr $fda3
        jmp $fcf8   ;part of reset, jumps to ($a000)

irq:    ldy #$02
        lda $d012
-       cmp $d012
        beq -
        sty $d021
        lda #<irq2
        sta $0314
        ;lda #>irq2
        ;sta $0315
current_cursor_position_this_irq = *+1
        lda #$00
        clc
        adc #$42
        sta $d012

        lda current_cursor_position
        asl
        asl
        asl
        sta current_cursor_position_this_irq
        sta current_cursor_position_other_irq
        inc $d019
        dec $028B
        bne +
        inc $028B
+
        jmp $ea81

irq2:
        ldy #$03
-       dey
        bne -
        sty $d021
        lda #<irq
        sta $0314
        ;lda #>irq
        ;sta $0315
current_cursor_position_other_irq = *+1
        lda #$00
        clc
        adc #$39
        sta $d012
        inc $d019
        jmp $ea31

    !if >irq2 != >irq {
        !error "irq and irq in different pages"
    }

get_current_type:
        lda current_pos
        sta ptr1
        lda current_pos+1
        sta ptr1+1
        ldx #$00
        beq get_current_type_loop ;unconditional
--      inx
        ldy #$00
-       iny
        lda (ptr1),y
        bne -
        tya
        sec
        adc ptr1
        sta ptr1
        bcc +
        inc ptr1+1
+
        
get_current_type_loop:
        cpx current_cursor_position
        bne --
        ldy #$00
        lda (ptr1),y
        rts

calc_at_current_pos:
        lda current_pos
        sta ptr1
        lda current_pos+1
        sta ptr1+1
        lda #$00
        sta tmp1
calc_big_loop:
        lda ptr1
        cmp directory_end
        lda ptr1+1
        sbc directory_end+1
        bcs end_calcing

        ldy #$ff
-       iny
        lda (ptr1),y
        bne -
        tya
        sec
        adc ptr1
        sta ptr1
        bcc +
        inc ptr1+1
+
        inc tmp1
        lda tmp1
        cmp #MAX_LINE
        bne calc_big_loop
end_calcing:
        jmp end_printing


print_at_current_pos:
        ;cal line sizes
        lda current_pos
        sta ptr1
        lda current_pos+1
        sta ptr1+1
        ldx #$ff
--      
        ldy #$00
        inx
maxline_cmp_value_calc_sizes = *+1
        cpx #00
        beq print_at_current_pos_continue
        dey
-       iny
        lda (ptr1),y
        bne -
        tya
        sta LINE_SIZES,x
        sec
        adc ptr1
        sta ptr1
        bcc --
        inc ptr1+1
        bne --

print_at_current_pos_continue:        
        ;print
        
        lda #<LINE_SIZES
        sta line_size

        lda current_pos
        sta ptr1
        lda current_pos+1
        sta ptr1+1
        lda #$00
        sta tmp1
        lda #40
        sta ptr2
        sta ptr3
        lda #$04
        sta ptr2+1
        lda #$d8
        sta ptr3+1
print_big_loop:
        lda ptr1
        cmp directory_end
        lda ptr1+1
        sbc directory_end+1
        bcc +
        jmp end_printing
+
        ldy #$00
        lax (ptr1),y
        +inc_word ptr1        

        lda x_pos
line_size = *+1
        cmp LINE_SIZES
        bcc do_print
-       lda (ptr1),y
        beq +
        iny
        bne -
+       sty tmp2
        ldy #$00
        lda #$20
-       sta (ptr2),y
        iny
        cpy #40
        bne -
        ldy tmp2
        jmp end_line

do_print:
        lda x_pos
        clc
        adc ptr1
        sta ptr1
        bcc +
        inc ptr1+1
+        
-       lda (ptr1),y
        beq string_ends
        +conv_to_screen
        sta (ptr2),y
        lda filetypecolor-1,x
        sta (ptr3),y
        iny
        cpy #40
        bne -
        ;find end of string
-       lda (ptr1),y
        beq end_line
        iny
        bne -
        ;!byte $02
string_ends:
        sty tmp2
        lda #$20
-       sta (ptr2),y
        iny
        cpy #40
        bne -
        ldy tmp2
end_line:
        tya
        sec
        adc ptr1
        sta ptr1
        bcc +
        inc ptr1+1
        clc
+       lda ptr2
        adc #40
        sta ptr2
        sta ptr3
        bcc +
        inc ptr2+1
        inc ptr3+1
+       inc line_size
        inc tmp1
        lda tmp1
        cmp #MAX_LINE
        beq end_printing
        jmp print_big_loop
end_printing:
        lda ptr1
        sta current_endpos
        lda ptr1+1
        sta current_endpos+1
        rts

!macro current_pos_equ_ptr1_plus_1 {
        lax ptr1
        sbx #$100-$01
        stx current_pos
        lda ptr1+1
        adc #$00
        sta current_pos+1
        }


try_scroll_up:
        lda current_index_number
        ora current_index_number+1
        beq try_scroll_up_failed
        lax current_pos
        sbx #$02
        stx ptr1
        lda current_pos+1
        sbc #$00
        sta ptr1+1
        ldy #$00
        jmp try_scroll_up_do_search
-
        +dec_word ptr1
try_scroll_up_do_search:
        lda (ptr1),y
        bne -
        +current_pos_equ_ptr1_plus_1
        +dec_word current_index_number
        sec
        rts
        
try_scroll_down_failed:
try_scroll_up_failed:
        clc
        rts


try_scroll_down:
        lda current_endpos
        cmp directory_end
        lda current_endpos+1
        sbc directory_end+1
        bcs try_scroll_down_failed
        lda current_pos
        sta ptr1
        lda current_pos+1
        sta ptr1+1
        ldy #$00
        beq try_scroll_down_do_search   ;unconditional
-       
        +inc_word ptr1
try_scroll_down_do_search:
        lda (ptr1),y
        bne -
        +current_pos_equ_ptr1_plus_1
        +inc_word current_index_number
        sec
        rts



load_menu_file:
        lda #fname_end-fname
        ldx #<fname
        ldy #>fname
        jsr $ffbd     ; call SETNAM
        lda #$01
        ldx $ba
        ldy #$00      ; $00 means: load to new address
        jsr $ffba     ; call SETLFS

        ;ldx #<directory_start
        ldy #>directory_start
        ;lda #$00      ; $00 means: load to memory (not verify)
        lxa #$00
        stx $c3
        sty $c4
        jsr LOAD      ; call LOAD
        bcs .error    ; if carry set, a load error has happened
        lda #$00
        sta current_index_number
        sta current_index_number+1
        sta current_cursor_position
        sta x_pos
        rts
.error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

        ;... error handling ...
-       inc $d020
        jmp -
    
block_write:
        ; open the channel file

        LDA #cname_end-cname
        LDX #<cname
        LDY #>cname
        JSR $FFBD     ; call SETNAM

        LDA #$02      ; file number 2
        ldx $ba
        tay           ; secondary address 2
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        ; open the command channel

        LDA #bpcmd_end-bpcmd
        LDX #<bpcmd
        LDY #>bpcmd
        JSR $FFBD     ; call SETNAM
        LDA #$0F      ; file number 15
        LDX $BA       ; last used device number
        tay           ; secondary address 15
        JSR $FFBA     ; call SETLFS

        jsr $FFC0     ; call OPEN (open command channel and send B-P command)
        BCS error    ; if carry set, the file could not be opened

        ; check drive error channel here to test for
        ; FILE NOT FOUND error etc.

        LDX #$02      ; filenumber 2
        JSR $FFC9     ; call CHKOUT (file 2 now used as output)

        LDY #$00
.loop   LDA sector_address,Y   ; read byte from memory
        JSR $FFD2     ; call CHROUT (write byte to channel buffer)
        INY
        cpy #sector_len
        BNE .loop     ; next byte, end when 256 bytes are read

        LDX #$0F      ; filenumber 15
        JSR $FFC9     ; call CHKOUT (file 15 now used as output)

        LDY #$00
.loop2  LDA bwcmd,Y   ; read byte from command string
        JSR $FFD2     ; call CHROUT (write byte to command channel)
        INY
        CPY #bwcmd_end-bwcmd
        BNE .loop2    ; next byte, end when 256 bytes are read
.close

        JSR $FFCC     ; call CLRCHN

        LDA #$0F      ; filenumber 15
        JSR $FFC3     ; call CLOSE

        LDA #$02      ; filenumber 2
        JSR $FFC3     ; call CLOSE

        JMP $FFCC     ; call CLRCHN

error:
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed

        !ifdef DRIVE_RESET {
drive_reset:
        lda #drive_init_end-drive_init
        ldx #<drive_init
        ldy #>drive_init
        bne execute_code_cont ;unconditional 
        }
                
        !ifdef CLEANUP_BLOCK_WRITTEN {
clear_buffer_2:
        ldx #<clear_buffer2
        ldy #>clear_buffer2
        bne execute_code ;unconditional
        } 

wait_for_flipdisk:
        ldx #<wait_for_diskchange
        ldy #>wait_for_diskchange

execute_code:
        ;in x/y code (x low)
        stx me_dest
        sty me_dest+1
        lda #me_comm_end-me_comm
        ldx #<me_comm
        ldy #>me_comm
        bne execute_code_cont

upload_code:
        ; open the command channel

        LDA #mw_end-mw_comm
        LDX #<mw_comm
        LDY #>mw_comm
execute_code_cont:
        JSR $FFBD     ; call SETNAM
        LDA #$0F      ; file number 15
        LDX $BA       ; last used device number
        tay           ; secondary address 15
        JSR $FFBA     ; call SETLFS

        jsr $FFC0     ; call OPEN (open command channel and send B-P command)
        BCS error     ; if carry set, the file could not be opened

        LDA #$0F      ; filenumber 15
        jsr $FFC3     ; call CLOSE
        JMP $FFCC     ; call CLRCHN

me_comm:
         !text "M-E"
me_dest:
         !byte <DRIVECODE_START
         !byte >DRIVECODE_START
me_comm_end:

cname:  !text "#"
cname_end:

bpcmd:  !text "B-P:2 0"
bpcmd_end:

bwcmd:  !text "U2:2 0 18 2"
        !BYTE $0D     ; carriage return, required to start command
bwcmd_end:

        !ifdef DRIVE_RESET {
drive_init:
        !text "I"
drive_init_end:
        }

fname:  !text "DATAFILE"
fname_end:
       
load_run_text:
        !byte 'S'
        !byte 'y'
        !byte '3'
        !byte '1'
        !byte '2'
        !byte $0d
        !byte 'R'
        !byte 'u'
        !byte $0d
load_run_text_len = *-load_run_text

buttomline:
        !scr "<space>=mount <ret>=run F1=pgup F7=pgdwn"

mw_comm:
         !text "M-W"
mw_dest: !word DRIVECODE_START
         !byte diskdrive_code_len
diskdrive_code:
        !pseudopc DRIVECODE_START {
        !ifdef CLEANUP_BLOCK_WRITTEN {
clear_buffer2:
        lxa #$00
-       sta $0600,x
        inx
        bne -
        rts
        }
wait_for_diskchange:
        !if TOGGLE_DISKWRITE_FOR_DISKSWITCH > 1 {
        ldx #TOGGLE_DISKWRITE_FOR_DISKSWITCH
        }
--
-       lda $1c00
        and #$10
        bne -
-       lda $1c00
        and #$10
        beq -
        !if TOGGLE_DISKWRITE_FOR_DISKSWITCH > 1 {
        dex
        bne --
        }
        rts
        }
diskdrive_code_len = * - diskdrive_code
mw_end:

filetypecolor:
        !byte $0e   ; dir
        !byte $03   ; d64
        !byte $03   ; g64
        !byte $0f   ; prg


sector_address:
index:  !word 0
        !ifdef CLEANUP_BLOCK_WRITTEN {
        !text "MENU"
        }
sector_len = * - sector_address


directory_start = (*+$ff) & $ff00

        ;all stuff after this is erased
        ;by loading "DATAFILE"

fastload_init:
        ldx #fastload_stack_len
-       lda fastload_stack-1,x
        sta STACK_START-1,x
        dex
        bne -
        ldy #>(fastload_main_len)
-       
fastload_main_src_ptr = *+2
        lda fastload_main,x
fastload_main_dst_ptr = *+2
        sta $e000,x
        inx
        bne -
        inc fastload_main_src_ptr
        inc fastload_main_dst_ptr
        dey
        bpl -
        rts

fastload_stack:
!pseudopc STACK_START {
        lda #1
        ldx #<load_star_name
        ldy #>load_star_name
        jsr $ffbd     ; call SETNAM
        lda #$01
        ldx $ba
        tay           ; $01 means: load to origin address
        jsr $ffba     ; call SETLFS

        lda #$00
        !bin "fastload_0140.bin",$2c,2+11
        jmp $f5a9
        !bin "fastload_0140.bin",,2+11+$2f
load_star_name:
        !text "*"
        }
fastload_stack_len = * - fastload_stack      

fastload_main:
        !bin "fastload_e000.bin",,2
fastload_main_len = *-1


