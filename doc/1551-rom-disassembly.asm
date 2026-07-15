;
; 	    The Complete Commodore 1551 ROM disassembly
;			by Attila Grósz
;		     http://yape.plus4.net
;                  grosza_AT_hotmail_DOT_com
;
;			   revision 0
;
;	      Based on 1541 ROM disassembly from AAY1541
;
;

; ROM is mapped between $C000-$FFFF in the drive memory
	ORG $C000 - 2
	DW  $C000
; Zeropage vectors
zp0E = $0E ;(3)
zp12 = $12 ;(1)
zp15 = $15 ;(7)
zp1E = $1E ;(24)
zp20 = $20 ;(37)
zp27 = $27 ;(38) address of current buffer
zp32 = $32 ;(3)
zp34 = $34 ;(3)
zp45 = $45 ;(9)
zp49 = $49 ;(15)
zp4E = $4E ;(6)
zp59 = $59 ;(4)
zp6A = $6A ;(3)
zp6C = $6C ;(25)
zp6E = $6E ;(79)
zp70 = $70 ;(22)
zp74 = $74 ;(8)
zp7F = $7F ;(42) counter for erased files
zp81 = $81 ;(17)
zp82 = $82 ;(11)
zp8D = $8D ;(85)
zpA4 = $A4 ;(9)  Pointer: Next byte in command buffer [0200]
zpA6 = $A6 ;(10)
zpC0 = $C0 ;(4)
zpC4 = $C4 ;(3)
zpC9 = $C9 ;(2)
zpCB = $CB ;(1)
zpE5 = $E5 ;(1)
;-------------------
; Zeropage variables
;-------------------
;
zp00 = $00 ;(9)  cpu data direction register
zp01 = $01 ;(65) cpu port, FDC control register
; bit 0: drive head stepper 0 (STP)
; bit 1: drive head stepper 1 (STP)
; bit 2: drive motor on/off (MTR)
; bit 3: drive LED (ACT)
; bit 4: write protect sensor (WPS)
; bit 5: density select #0 (DS0)
; bit 6: density select #1 (DS1)
; bit 7: byte latched (1 - yes, 0 - no)
;
zp02 = $02 ;(14) Command code for buffer 0
zp03 = $03 ;(2)  Command code for buffer 1
zp04 = $04 ;(3)  Command code for buffer 2
zp05 = $05 ;(1)  Command code for buffer 3
zp06 = $06 ;(6)  Command code for buffer 4
zp07 = $07 ;(2)  Command code for buffer 5 (unused)
zp08 = $08 ;(6)	 Track and sector for buffer 0
zp09 = $09 ;(5)
zp0A = $0A ;(2)	 Track and sector for buffer 1
zp0C = $0C ;(1)	 Track and sector for buffer 2
zp14 = $14 ;(6) disk id 1
zp18 = $18 ;(6) block header id 1
zp19 = $19 ;(6) block header id 2
zp1A = $1A ;(5) track blockheader
zp1B = $1B ;(5) sector blockheader
zp1C = $1C ;(3) checksum of block header
zp1D = $1D ;(5) current drive number (always 0)
zp22 = $22 ;(8) write protect flag for drive 0 or 1
zp23 = $23 ;(2) write protect flag for drive 1 (unused)
zp24 = $24 ;(4)
zp26 = $26 ;(1)
zp29 = $29 ;(6) FDC current track
zp2B = $2B ;(14) drive status flag
           ;     bit 5: drive motor
           ;     bit 6: stepper motor
           ;     bit 7: drive ready
zp2D = $2D ;(10)
zp2E = $2E ;(19)
zp2F = $2F ;(2)
zp30 = $30 ;(8)
zp31 = $31 ;(7)
zp36 = $36 ;(4)
zp37 = $37 ;(4)
zp38 = $38 ;(5)
zp39 = $39 ;(7)
zp3A = $3A ;(2) temporary stack storage
zp3B = $3B ;(9) stepper motor direction (<$80 inner, >=$80 outer)
zp3C = $3C ;(6)
zp3D = $3D ;(3) last sector read
zp3E = $3E ;(2) next sector to be read
zp3F = $3F ;(5) GCR/BIN indicator for current buffer
zp40 = $40 ;(11) current track
zp41 = $41 ;(17)
zp42 = $42 ;(18)
zp43 = $43 ;(20)
zp44 = $44 ;(18)
zp47 = $47 ;(4)
zp48 = $48 ;(9)
zp4B = $4B ;(4)
zp4C = $4C ;(3)
zp4D = $4D ;(5)
zp50 = $50 ;(5)
zp51 = $51 ;(3)
zp52 = $52 ;(5)
zp53 = $53 ;(10)
zp54 = $54 ;(9)
zp55 = $55 ;(2) drive LED flash counter
zp56 = $56 ;(2)
zp57 = $57 ;(6)
zp58 = $58 ;(6)
zp5B = $5B ;(4) TALK flag
zp5C = $5C ;(4) LISTEN flag (1/0)
zp5D = $5D ;(4) format string of disk after init (2A)
zp5E = $5E ;(1)
zp5F = $5F ;(6)
zp61 = $61 ;(2) ROM-test checksum
zp62 = $62 ;(4)
zp63 = $63 ;(3)
zp65 = $65 ;(1)
zp66 = $66 ;(3) device number
zp68 = $68 ;(6)
zp69 = $69 ;(4)
zp72 = $72 ;(4)
zp76 = $76 ;(2) LED blink flag (#$E0 = on)
zp77 = $77 ;(2) last track number
zp78 = $78 ;(69) current drive number
zp79 = $79 ;(86) current track
zp7A = $7A ;(83) current sector
zp7B = $7B ;(102) current channel
zp7C = $7C ;(58) secondary address
zp7D = $7D ;(6)  secondary address from computer
zp7E = $7E ;(26)
zp84 = $84 ;(7)
zp85 = $85 ;(3)
zp86 = $86 ;(3)
zp87 = $87 ;(2)
zp89 = $89 ;(12)
zp8A = $8A ;(7)
zp8B = $8B ;(2)
zp8C = $8C ;(1)
zp8F = $8F ;(1)
zp91 = $91 ;(5) pointer in record
zp92 = $92 ;(15)
zp93 = $93 ;(14)
zp94 = $94 ;(7)
zp95 = $95 ;(10) EOI
zp96 = $96 ;(2)
zp97 = $97 ;(8)
zp98 = $98 ;(26) buffer number
zp99 = $99 ;(6)	 Pointer to first filename
zp9A = $9A ;(55)
zp9B = $9B ;(6)
zpA8 = $A8 ;(38)
zpAC = $AC ;(1)
zpAD = $AD ;(2)
zpAE = $AE ;(1)
zpAF = $AF ;(24)
zpB5 = $B5 ;(1)
zpB6 = $B6 ;(10)
zpBC = $BC ;(9)
zpC2 = $C2 ;(13)
zpC8 = $C8 ;(10)
zpCE = $CE ;(18)
zpD2 = $D2 ;(1)
zpD3 = $D3 ;(1)
zpD4 = $D4 ;(4)
zpD8 = $D8 ;(1)
zpD9 = $D9 ;(7)
zpDA = $DA ;(2)
zpDD = $DD ;(1)
zpDE = $DE ;(7)
zpDF = $DF ;(2)
zpE2 = $E2 ;(1)
zpE3 = $E3 ;(18)
zpE4 = $E4 ;(5)
zpE7 = $E7 ;(1)
zpE8 = $E8 ;(18)
zpE9 = $E9 ;(2)
zpEB = $EB ;(1)
zpED = $ED ;(12)
zpF1 = $F1 ;(1)
zpF3 = $F3 ;(13)
zpF7 = $F7 ;(1)
zpF8 = $F8 ;(3)
zpF9 = $F9 ;(12)
zpFA = $FA ;(12)
zpFB = $FB ;(10)
zpFC = $FC ;(4)
zpFD = $FD ;(5)
zpFE = $FE ;(3)
zpFF = $FF ;(9)
;
; GCR overflow area and stack $100-$1ff
;
V_0100 = $0100
V_0101 = $0101
V_0102 = $0102
V_0103 = $0103
V_0111 = $0111
V_0112 = $0112
V_011B = $011B
V_01A9 = $01A9
V_01FF = $01FF
;
; Command buffer, parser, tables, variables $200-$2ff
;
V_0200 = $0200  ; input buffer $0200-$0229 for command string,
L_0201 = $0201
V_0202 = $0202
V_0203 = $0203
V_0204 = $0204
V_0205 = $0205
V_0206 = $0206
V_022A = $022A	; command number temporary storage (Command code)
V_022B = $022B	; Logical index, channel 0
V_022C = $022C	; Logical index, channel 1
V_022D = $022D	; Logical index, channel 2
V_023A = $023A
V_023B = $023B
V_023C = $023C
V_023D = $023D
V_023E = $023E
V_0243 = $0243
V_0244 = $0244
V_0249 = $0249 	; end of error message
V_024A = $024A 	; active data/file type
V_024B = $024B 	; filename/string length
V_024C = $024C	; Temp. channel number (secondary address)
V_024D = $024D	; Current work with drive number
V_024E = $024E	; Work area to find the best sector
V_024F = $024F	; Buffer allocated
V_0250 = $0250	; Buffer allocated
V_0251 = $0251	; Flag: BAM changed, drive 0
V_0253 = $0253	; Flag for directory entry found (FF = Not found, 00 = Found)
V_0254 = $0254	; Flag for directory output
V_0255 = $0255	; Flag: Waiting for command
V_0256 = $0256  ; buffer allocation register
V_0257 = $0257	; Last used buffer
V_0258 = $0258	; Record length
V_0259 = $0259	; Track of side sector
V_025A = $025A	; Sector of side sector
V_025B = $025B	; Last work (buffers) $025B-$025F
V_0260 = $0260	; Directory sector (buffers) $0260-$0265
V_0266 = $0266	; File's index in directory (buffers) $0266-$026B
V_026C = $026C  ; error flag, counter for led flash?
V_026E = $026E  ; last program's drive number
V_026F = $026F  ; last sector number
V_0270 = $0270  ; temporary storage for channel number
V_0272 = $0272  ; number of blocks free
V_0273 = $0273
V_0274 = $0274	; length of filename/input
V_0275 = $0275
V_0276 = $0276
V_0277 = $0277  ; nr of commas
V_0278 = $0278
V_0279 = $0279  ; nr of commas
V_027A = $027A	; pointer to drive number
V_027B = $027B
V_027F = $027F
V_0280 = $0280
V_0281 = $0281
V_0284 = $0284
V_0285 = $0285
V_0286 = $0286
V_0287 = $0287
V_028A = $028A	; wildcard flag
V_028B = $028B 	; syntax flag
V_028C = $028C  ; number of drives to look for
V_028D = $028D	; Flag: Looking for drive
V_028E = $028E	; last drive number
V_028F = $028F	; Flag: Found in directory
V_0290 = $0290	; Directory sector
V_0291 = $0291	; Sector for first available file
V_0292 = $0292	; Index (in directory) for first available file
V_0293 = $0293	; For the last directory entry 0
V_0294 = $0294	; Current buffer-index
V_0295 = $0295	; Counter: Files
V_0296 = $0296	; Flag: Name matching wild cards
V_0297 = $0297	; Active operating mode (R or W)
V_0298 = $0298	; dos error flag, Flag: Work return
V_0299 = $0299	; Pointer: Re-read error
V_029A = $029A	; Total tracks
V_029B = $029B	; Pointer: BAM last update $029B-$029C
V_029D = $029D	; BAM: image sector (drive 0)
V_02A1 = $02A1	; BAM image $02A1-$02B0
V_02B0 = $02B0
V_02B1 = $02B1	; Buffer for directory output, $02B1-$02D4
V_02B2 = $02B2
V_02B3 = $02B3
V_02C3 = $02C3
V_02C4 = $02C4
V_02D5 = $02D5
V_02F9 = $02F9	; Flag: Don't write BAM
V_02FA = $02FA	; Number of free blocks, low byte for drive 0 and 1, $02FA-$02FB
V_02FC = $02FC	; Number of free blocks, hi byte for drives 0 and 1, $02FC-$02FD
V_02FE = $02FE	; Stepper motor sequence
V_02FF = $02FF
; 4 data buffers, 0-3, $0300-06ff
V_03A9 = $03A9
V_04A9 = $04A9
L_04C5 = $04C5
V_04FF = $04FF
V_0504 = $0504
V_0605 = $0605
V_0610 = $0610
V_06A9 = $06A9
; $0700-07ff	BAM resident in memory
S_08FF = $08FF
V_2036 = $2036
V_21F1 = $21F1
S_3008 = $3008
;
; TIA 6523 registers $4000-$4005
;
; Port registers A, B and C
V_4000 = $4000	; I/O port towards the computer
V_4001 = $4001	; connected to the shift register of the R/W head
V_4002 = $4002	; drive control, status and sync register
;
; bit 7: DAV (DAta Valid)
; 	handshake from bit #6 from $FEF2/FEC2 of plus/4
; bit 6: SYNC
; 	0 -> SYNC found
; 	1 -> no SYNC
; bit 5: MODE (jumper)
; 	drive number (0 -> 8, 1 -> 9)
; bit 4: MODE (R/W head)
; 	0 -> head in write mode
; 	1 -> head in read mode
; bit 3: ACK (ACKnowledge)
; 	handshake to bit #7 of $FEF2/$FEC2
; bit 2: DEV
; 	1 -> drive mapped at $FEF0 on plus/4
; 	0 -> drive mapped at $FEC0 on plus/4
; bit 1: STATUS1 - mapped at $FEF1/FEC1 on plus/4
; bit 0: STATUS0 - mapped at $FEF1/FEC1 on plus/4
; 		  01 Timeout during reading
; 		  10 Timeout during writing
; 		  11 End of data
;
; Data direction registers for ports A, B and C
V_4003 = $4003
V_4004 = $4004
V_4005 = $4005

;--------- Copyright text
T_C000	DB "DAVID G SIRACUSA CBM COPYRIGHT 84"

;--------- Start of 1551 ROM program

S_C022	LDA V_4000	; read data from computer
	CMP V_4000	; port stable?
	BEQ B_C02D	; if yes, then jump
	JMP L_EABD	; otherwise back to main wait loop
	;
B_C02D	AND #$0F	; lowest 4 bits only
	ASL A		; * 2
	TAY		; Y = A, make it an index
	LDA V_C046,Y	; look up address of subroutine
	STA zp6E
	LDA V_C046 + 1,Y
	STA zp6E+1	; $6E/$6F
	LDA V_4002
	AND #$F7
	STA V_4002	; ACK handshake
	JMP ($006E)	; *** Indirect jump to TCBM bus command handler
	;
	; Jump vectors for TCBM bus commands,
	; only $01 - $04 are valid. The 264 is sending these values
	; OR-ed with $80 through the TCBM interface.
	;
V_C046	DB $66,$C0	; $C066: N/A
	DB $71,$C0	; $C071: Command w/ dev nr coming (TALK/LISTEN/UNTALK/UNLISTEN)
	DB $D6,$C0	; $C0D6: Command w/ sec addr. coming (0x60, 0xE0, 0xF0)
	DB $F6,$C0	; $C0F6: Data comes to the drive (filename, command, data etc.)
	DB $4E,$C1	; $C14E: Data goes to computer
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0
	DB $66,$C0	; N/A
	;
; $C066
S_C066 	LDA V_4002	; not a valid command
	ORA #$08	; just acknowledge
	STA V_4002
	JMP L_EABD	; and jump back to main loop
	;
	; Command w/ dev nr coming (TALK/LISTEN/UNTALK/UNLISTEN)
	;
B_C071	LDA V_4002
	BMI B_C071	; wait for DAV handshake from plus/4
	LDA V_4000	; read port data in from plus/4
	PHA		; save to stack
	LDA zp58	;
	BPL B_C08B	; MSB not set?
	LDA #$00	; reset end flag
	STA zp95
	LDA zp59        ; read last data byte
	JSR B_C0F6
	LDA #$00
	STA zp58	;
B_C08B	PLA		; read port value back from stack
	TSX
	STX zp59+1
	LDX #$00
	STA zp8F	; save command
	TAY		; backup A (command) in Y
	AND #$60
	CMP #$40	; talk?
	BEQ B_C0A8	; yes
	CMP #$20	; listen?
	BEQ B_C0C0	; yes
	LDY #$00	; otherwise DATA ($60)
	LDX #$03
	STX zp6E        ; set blink rate ?
	SEI		; disable interrupt
	JMP L_E984
	;
B_C0A8	STX zp5B        ; reset TALK flag
	TYA             ; code in accu
	CMP #$5F	; UNTALK ?
	BEQ B_C0BC	; yes...
	STA zp5B        ; set TALK flag
	STX zp5C        ; reset LISTEN flag
L_C0B3	LDA #$20
	STA zp7C	; save sec. address
	STA zp7D
	JMP L_C133
	;
B_C0BC	LDA #$00
	BEQ B_C135	; always jump

B_C0C0	TYA		; read back A from Y
	CMP #$3F	; UNLISTEN?
	BNE B_C0CF	; no
	LDA #$FF	;
	STA zp95
	LDX #$00
	STX zp5C	; reset flag for listen
	BEQ B_C0BC	; always jump

B_C0CF	STA zp5C	; must be UNTALK then
	STX zp5B
	JMP L_C0B3
	;
	; Command w/ sec addr. coming (0x60, 0xE0, 0xF0)
	;
B_C0D6	LDA V_4002
	BMI B_C0D6	; wait for DAV
	TSX
	STX zp59+1
	LDA V_4000
	STA zp7D	; store secondary address
	TAY
	AND #$0F
	STA zp7C	; store secondary address again
	TYA
	AND #$F0
	CMP #$E0	; CLOSE?
	BNE B_C0F2	; not, then must be OPEN
	JSR S_DBF7	; jump to CLOSE
B_C0F2	LDA #$00
	BEQ B_C135	; always jump to finish
	;
	; Data comes to the drive (filename, command, data etc.)
	;
B_C0F6	LDA V_4002
	BMI B_C0F6	; wait for DAV handshake from computer
	TSX
	STX zp59+1	; save stack pointer
	LDA V_4000	; read data bus
	PHA		; save
	LDA zp58
	BPL B_C12A	; branch if MSB not set, and set it now
	LDA zp59	; read data read last time
	STA zp7E	; store
	JSR S_D217	; open channel
	BCS B_C114
	LDA zpF3,X
	ROR A
	BCS B_C127
B_C114	LDA zp7D	; read sec. addr. as received from computer
	AND #$F0	; get just the command bits...
	CMP #$F0	; open channel command?
	BEQ B_C127	; yes, then jump
	LDA zp7C	; otherwise load secondary address (channel nr?)
	CMP #$01	; = 1 ?
	BEQ B_C130	; yes
	PLA
	LDA #$02
	BNE B_C135	; always jump
B_C127	JSR S_D0D3	; write data into buffer
B_C12A	LDA zp58
	ORA #$80
	STA zp58
B_C130	PLA		; copy back saved data from bus
	STA zp59	; store
L_C133	LDA #$00

B_C135	AND #$03
	ORA #$08
	STA zp97	; preserve status, set ACK bit
	LDA V_4002
	ORA zp97	; send it to machine
	STA V_4002
B_C143	LDA V_4002
	BPL B_C143	; wait for DAV handshake from plus/4
	AND #$FC	; send ACK to plus/4
	STA V_4002
	RTS
;
;$C14E  -------- Data goes to computer
;
B_C14E	LDA V_4002
	BMI B_C14E	; wait for DAV handshake from plus/4
	LDA #$FF
	STA V_4003	; set TIA port A to all outputs
	TSX		; save stack pointer
	STX zp59+1	; ... to $5A
	LDA zp7C	; read saved secondary address
	CMP #$13	; 19
	BCC B_C163	; bigger, then skip
	AND #$0F
B_C163	CMP #$0F	; command channel ?
	BNE B_C169	; no...
	LDA #$10	; if 15 then make it 16
B_C169	TAX		; make and index from it
	SEC
	LDA V_022B,X
	BMI B_C176
	AND #$0F
	STA zp7B
	TAX
	CLC
B_C176	BCS B_C17E
	LDX zp7B
	LDA zpF3,X
	BMI B_C189
B_C17E	LDA #$0D	; CR
	STA V_4000	; send $0D to computer via TIA port A
	LDA #$0A
	STA zp97
	BNE B_C1A7
B_C189	LDA V_023E,X
	STA V_4000	; send the rest of the buffer
	LDA zpF3,X
	AND #$08
	EOR #$08
	ASL A
	ASL A
	ASL A		; multiply by 8 (becomes $40 (64) or 0)
	PHA
	JSR S_D4F9
	PLA
	CMP #$40
	BNE B_C1A3
	LDA #$03
B_C1A3	ORA #$08
	STA zp97	; $97 = $38
B_C1A7	LDA V_4002
	AND #$FC	; clear status bits in TIA
	ORA zp97	; copy status
	STA V_4002	; send...
B_C1B1	LDA V_4002
	BPL B_C1B1	; wait for DAV handshake from machine
	LDX #$00
	STX V_4003	; set TIA port A to input
	AND #$F7
	STA V_4002	; clear ACK handshake
B_C1C0	LDA V_4002	; received?
	BMI B_C1C0	; not yet
	ORA #$08	; set ACK handshake...
	AND #$FC	; ...clear status bits...
	STA V_4002	; ... done
	RTS
;$C1CD  --------
S_C1CD	LDX #$0D	; CR
	STX V_4000	; send to computer
	LDA #$0A	; $8 / $2
	STA zp97
	BNE B_C1A7	; jump always, set error status and device in TIA
S_C1D8	LDA #$01
	JMP B_C135
	;
	LDX V_0274	; X = length of filename
	DEX		; decrease by 1
	BEQ B_C1FB	; zero?
	LDA L_0201
	TAY
	CMP #$52	; "R"
	BEQ B_C220	; yes...
	CMP #$53	; "S"
	BEQ B_C220	; yes...
	CMP #$39	; 9?
	BEQ B_C208	; yes
	CMP #$38	; 8?
	BNE B_C203	; no... then error
B_C1F7	LDX #$08
	BNE B_C20A	; always jump, set device number to 8
B_C1FB	LDA zp66
	CMP #$08	; check device number
	BEQ B_C208	; = 8 ? then jump
	BNE B_C1F7
B_C203	LDA #$31
	JMP L_C2B2	; 31, 'syntax error'
	;
	; Set device number flag in TIA register
	;
B_C208	LDX #$09	; set device number to 9
B_C20A	STX zp66
	TXA
S_C20D	ASL A
	ASL A		; accu * 4 = $24
	AND #$04	; isolate device nr flag in register
	EOR #$04	; toggle device number flag towards computer...
	STA zp97
	LDA V_4002
	AND #$FB
	ORA zp97	; and then ...
	STA V_4002	; ... set device number (0 for #8 and 1 for #9)
	RTS
;$C220  --------
B_C220	DEX
	BEQ B_C203
	LDX #$01
	LDA V_0202
	CPY #$52	; "R"
	BEQ B_C22D
	DEX
B_C22D	STA zp68,X
	RTS

;$C230  -------- Interpret command from computer

S_C230	LDA #$00
	STA V_02F9
	LDA V_028E	; last drive number
	STA zp78	; drive number
	JSR L_E7FB	; prepare 'ok' message
	LDA zp7D	; secondary address
	BPL B_C24A
	AND #$0F
	CMP #$0F	; 15, command channel
	BEQ B_C24A	; yes
	JMP L_D8EE	; to OPEN command
	;
B_C24A	JSR S_C39D	; determine line length and erase flags
	LDA (zpA4),Y	; get first character
	STA V_0275	; and store
	LDX #$0C	; 12

B_C254	LDA V_F0C6 + 1,X	; commands
	CMP V_0275	; compare to first character
	BEQ B_C264	; found?
	DEX
	BPL B_C254
	LDA #$31	; not found
	JMP L_C2B2	; 31, 'syntax error'
	;
B_C264	STX V_022A	; number of command words
	CPX #$0A
	BCC B_C26E	; command number < 10? (1541 has 9!!!)
	JSR S_C2D8	; test for 'R', 'S', and 'N'
B_C26E	LDX V_022A	; command number
	LDA V_F0D4,X	; jump address lo
	STA zp6E
	LDA V_F0E1,X	; jump address hi
	STA zp6E+1
	JMP ($006E)	; *** Indirect jump to command
	;
L_C27E	LDA #$00
	STA V_02F9
	;
L_C283	LDA V_026C
	BNE L_C2B2
	LDY #$00
	TYA		; error number 0
	STY zp79	; track number 0
L_C28D	STY zp7A	; sector number 0
	STY zpA4
	JSR S_E806	; prepare 'ok' message
	JSR S_F3F0	; erase error flag

L_C297	LDA zp78	; drive number
	STA V_028E	; save as last drive number
	TAX
	LDA #$00
	STA zp5F,X
	JSR S_C2A7	; erase input buffer
	JMP L_D62D	; close internal channel

	; Erase input buffer

S_C2A7	LDY #$28	; erase 41 characters
	LDA #$00
B_C2AB	STA V_0200,Y	; $200 to $228
	DEY
	BPL B_C2AB
	RTS

;------------------------------------
;$C2B2  -------- Output error message
;------------------------------------

L_C2B2	LDY #$00
	STY zp79	; track = 0
	STY zp7A	; sector = 0
	JMP S_E781	; error number acc, generate error message

	; Check input line

S_C2BB	LDX #$00
	STX V_027A	; pointer to drive number
	LDA #$3A	; ':'
	JSR S_C352	; test line to ':' or to end
	BEQ B_C2CC	; no colon found?
	DEY
	DEY
	STY V_027A	; point to drive number (before colon)
B_C2CC	JMP L_C452

	; Check ':' on input line

S_C2CF	LDY #$00	; pointer to input buffer
	LDX #$00	; counter for commas
	LDA #$3A	; ':'
	JMP S_C352
	;
S_C2D8	JSR S_C2CF
	BNE S_C2E2
B_C2DD	LDA #$34
	JMP L_C2B2	; 34, 'syntax error'
	;
S_C2E2	DEY
	DEY		; set pointer to colon
	STY V_027A	; position of the drive number
	TXA		; comma before the colon
	BNE B_C2DD	; yes, then 'syntax error'
S_C2EA	LDA #$3D	; '='
	JSR S_C352	; check input to '='
	TXA		; comma found?
	BEQ B_C2F4	; no
	LDA #$40	; bit 6
B_C2F4	ORA #$21	; and set bit 0 and 5
	STA V_028B	; flag for syntax check
	INX
	STX V_0277
	STX V_0278
	LDA V_028A	; wildcard found?
	BEQ B_C312	; no
	LDA #$80
	ORA V_028B	; set bit 7
	STA V_028B
	LDA #$00
	STA V_028A	; reset wildcard flag
B_C312	TYA		; '=' found?
	BEQ B_C33E	; no
	STA V_027A,X
	LDA V_0277	; number of commas before '='
	STA V_0279
	LDA #$8D	; shift CR
	JSR S_C352	; check line to end
	INX		; increment comma counter
	STX V_0278	; store number of commas
	DEX
	LDA V_028A	; wildcard found?
	BEQ B_C32F	; no
	LDA #$08	; set bit 3
B_C32F	CPX V_0277	; comma after '='?
	BEQ B_C336	; no
	ORA #$04	; set bit 2
B_C336	ORA #$03	; set bits 0 and 1
	EOR V_028B
	STA V_028B	; as flag for syntax check
B_C33E	LDA V_028B	; syntax flag
	LDX V_022A	; command number
	AND V_F0E5,X	; combine with check byte
	BNE B_C34A
	RTS
;$C34A  --------
B_C34A	STA V_026C	; set error flag
	LDA #$30
	JMP L_C2B2	; 30, 'syntax error'

	; Search character in input buffer

S_C352	STA V_0275	; save character
B_C355	CPY V_0274	; already done?
	BCS B_C388	; yes
	LDA (zpA4),Y	; get char from buffer
	INY
	CMP V_0275	; compared with char
	BEQ B_C38A	; found
	CMP #$2A	; '*'
	BEQ B_C36A
	CMP #$3F	; '?'
	BNE B_C36D
B_C36A	INC V_028A	; set wildcard flag
B_C36D	CMP #$2C	; ','
	BNE B_C355
	TYA
	STA V_027B,X	; note comma position
	LDA V_028A	; wildcard flag
	AND #$7F
	BEQ B_C383	; no wildcard
	LDA #$80
	STA zpE8,X	; note flag
	STA V_028A	; and save as wildcard flag
B_C383	INX		; increment comma counter
	CPX #$04	; 4 commas already?
	BCC B_C355	; no, continue
B_C388	LDY #$00
B_C38A	LDA V_0274	; set flag for line end
	STA V_027B,X
	LDA V_028A	; wildcard flag
	AND #$7F
	BEQ B_C39B	; no wildcard
	LDA #$80
	STA zpE8,X	; set flag
B_C39B	TYA
	RTS

;$C39D  -------- Check line length

S_C39D	LDY zpA4	; pointer to command input buffer
	BEQ B_C3B5	; zero?
	DEY
	BEQ B_C3B4	; one?
	LDA V_0200,Y	; pointer to input buffer
	CMP #$0D	; 'CR'
	BEQ B_C3B5	; yes, line end
	DEY
	LDA V_0200,Y	; preceding character
	CMP #$0D	; 'CR'
	BEQ B_C3B5	; yes
	INY
B_C3B4	INY		; pointer to old value again
B_C3B5	STY V_0274	; same line length
	CPY #$2A	; compare with 42 characters
	LDY #$FF
	BCC S_C3C6	; smaller, ok
	STY V_022A
	LDA #$32
	JMP L_C2B2	; 32, 'syntax error' line too long

	; Clear flags for command input

S_C3C6	LDY #$00
	TYA
	STA zpA4	; pointer to input buffer lo
	STA V_0258	; record length
	STA V_024A	; file type
	STA V_0296
	STA zp99
	STA V_0279	; comma counter
	STA V_0277	;      "
	STA V_0278	;      "
	STA V_028A	; wildcard flag
	STA V_026C	; error flag
	LDX #$05
B_C3E7	STA V_0279,X	; flags for line analysis
	STA zpD8,X	; directory sectors
	STA zpDD,X	; buffer pointer
	STA zpE2,X	; drive number
	STA zpE7,X	; wildcard flag
	STA V_027F,X	; track number
	STA V_0284,X	; sector number
	DEX
	BNE B_C3E7
	RTS

;$C3FC  -------- Preserve drive number

S_C3FC	LDA V_0278	; number of commas
	STA V_0277	; save
	LDA #$01
	STA V_0278	; number of drive numbers
	STA V_0279
S_C40A	LDY V_028E	; last drive number
	LDX #$00
B_C40F	STX zp99
	LDA V_027A,X	; position of the colon
	JSR S_C426	; get drive number before colon
	LDX zp99
	STA V_027A,X	; save exact position
	TYA
	STA zpE3,X	; drive number in table
	INX
	CPX V_0278	; got all drive numbers?
	BCC B_C40F	; no, continue
	RTS
;$C426  -------- Search for drive number
S_C426	TAX		; note position
	LDY #$00
	LDA #$3A	; ':'
	CMP L_0201,X	; colon behind it?
	BEQ B_C43C	; yes
	CMP V_0200,X	; colon here?
	BNE B_C436	; no
	INX
B_C436	TYA
B_C437	AND #$01	; drive number
B_C439	TAY
	TXA
	RTS
;$C43C  --------
B_C43C	LDA V_0200,X	; get drive number
	INX
	INX
	CMP #$30	; '0'?
	BEQ B_C437
	CMP #$31	; '1'?
	BEQ B_C4B2
	BNE B_C436	; no, use last drive number
	TYA		; last drive number
	ORA #$80	; set bit 7, uncertain drive number
	AND #$81	; erase remaining bits
	BNE B_C439
	BNE B_C439

	; Get drive number

V_C452
L_C452	LDA #$00
	STA V_028B	; erase syntax flag
	LDY V_027A	; position in command line
B_C45A	LDA (zpA4),Y	; get chars from command buffer
	JSR S_C4A5	; get drive number
	BPL B_C472	; certain number?
	INY		; increment pointer
	CPY V_0274	; line end?
	BCS B_C46D	; yes
	LDY V_0274
	DEY
	BNE B_C45A	; search line for drive number
B_C46D	DEC V_028B
	LDA #$00
B_C472	AND #$01
	STA zp78	; drive number
	RTS
;$C477  --------
S_C477	LDA zp78	; drive number
	EOR #$01	; switch bit 0
	AND #$01
	STA zp78
	RTS

;$C480  -------- Check given file type

S_C480	LDY #$00
	LDA V_0277	; '=' found?
	CMP V_0278
	BEQ B_C4A0	; no
	DEC V_0278	; get pointer
	LDY V_0278
	LDA V_027A,Y	; set pointer to character behind '='
	TAY
	LDA (zpA4),Y	; pointer to buffer
	LDY #$04	; compare with marker for file type
B_C498	CMP V_F0FB + 1,Y ; 'S', 'P', 'U', 'R'
	BEQ B_C4A0	; agreement
	DEY
	BNE B_C498
B_C4A0	TYA
	STA V_0296	; note file type (1-4)
	RTS
;$C4A5  -------- Check given drive number
S_C4A5	CMP #$30	; '0'
	BEQ B_C4AF
	CMP #$31	; '1'
	BEQ B_C4B2
	ORA #$80	; no zero or one, then set bit 7
B_C4AF	AND #$81
	RTS
;$C4B2  -------- Verify drive number
B_C4B2	LDA #$31
	JMP L_C2B2
	;
S_C4B7	LDA #$00
	STA zp6E
	STA V_028D	; reset for looking for drive flag
	PHA
	LDX V_0278	; number of drive numbers
B_C4C2	PLA		;
	ORA zp6E
	PHA
	LDA #$01
	STA zp6E
	DEX
	BMI B_C4DC
	LDA zpE3,X
	BPL B_C4D5
	ASL zp6E
	ASL zp6E	; $6e * 4
B_C4D5	LSR A		; ac = ac * 2
	BCC B_C4C2	; not overflow? then back
	ASL zp6E	; $6e * 2
	BNE B_C4C2	; not zero? then back
B_C4DC	PLA
	TAX
	LDA V_C528 + 2,X	; get syntax flag
	PHA
	AND #$03
	STA V_028C
	PLA
	ASL A
	BPL B_C527
	LDA zpE3
L_C4ED	AND #$01	; isolate drive number
	STA zp78
	LDA V_028C
	BEQ B_C521
	JSR S_C722	; initialize drive
	BEQ B_C50D	; error?
	JSR S_C477	; switch to other drive
	LDA #$00
	STA V_028C
	JSR S_C722	; initialize drive
	BEQ B_C526	; no error?
	BEQ B_C526
V_C508
B_C508	LDA #$74
	JSR L_C2B2	; 74, 'drive not ready'
B_C50D	JSR S_C477
	JSR S_C722	; initialize drive
	PHP
	JSR S_C477	; switch to other drive
	PLP
	BEQ B_C526	; no error?
	LDA #$00
	STA V_028C	; number of drives
	BEQ B_C526
B_C521	JSR S_C722	; initialize drive
	BNE B_C508	; error?
B_C526	RTS
;$C527  --------
B_C527	ROL A		; drive number from carry after bit 0
V_C528	JMP L_C4ED	; *** Self mod. indirect jump!

	; Flags for drive check

	DB $00,$80,$41,$01,$01,$01,$01,$81
	DB $81,$81,$81,$42,$42,$42,$42

	; Search for file in directory

S_C53A	JSR S_C4B7	; initialize drive
L_C53D	LDA #$00
	STA V_0292	; pointer
	JSR S_C691	; read first directory block
	BNE B_C55D	; entry present?
B_C547	DEC V_028C	; drive number clear?
	BPL B_C54D	; no
	RTS
;$C54D  --------
B_C54D	LDA #$01
	STA V_028D
	JSR S_C477	; change drive...
	JMP L_C53D	; ...and search
	;
B_C558	JSR S_C6FC	; search next file in directory
	BEQ B_C56D	; not found?
B_C55D	JSR S_C5BD	; verify directory entry
	LDA V_028F
	BEQ B_C566	; more files?
	RTS
;$C566  --------
B_C566	LDA V_0253
	BMI B_C558	; file not found?
	BPL B_C55D	; yes
B_C56D	LDA V_028F
	BEQ B_C547
	RTS
;$C573  --------
S_C573	JSR S_C6E9	; search next directory block
	BEQ B_C58F	; not found?
	BNE B_C59F
B_C57A	LDA #$01
	STA V_028D
	JSR S_C477	; change drive
S_C582	LDA #$00
	STA V_0292	; read directory block
	JSR S_C691	; found?
	BNE B_C59F
	STA V_028F
B_C58F	LDA V_028F
	BNE B_C5BC
	DEC V_028C
	BPL B_C57A
	RTS
;$C59A  --------
S_C59A	JSR S_C6FC	; next entry in directory
	BEQ B_C58F	; not found?
B_C59F	JSR S_C5BD	; check entry
	LDX V_0253
	BPL B_C5AE	; file found?
	LDA V_028F
	BEQ S_C59A	; yes
	BNE B_C5BC	; no, then done
B_C5AE	LDA V_0296
	BEQ B_C5BC
	LDA zpE8,X	; file type
	AND #$07
	CMP V_0296	; same as desired file type?
	BNE S_C59A	; no
B_C5BC	RTS
;$C5BD  --------
S_C5BD	LDX #$FF
	STX V_0253	; flag for data found
	INX
	STX V_028A
	JSR B_C66E	; set pointer to data
	BEQ B_C5D1
B_C5CB	RTS
;$C5CC  --------
B_C5CC	JSR S_C679	; pointer to next file
	BNE B_C5CB	; end, then done
B_C5D1	LDA zp78	; drive number
	EOR zpE3,X
	LSR A
	BCC B_C5E3
	AND #$40
	BEQ B_C5CC
	LDA #$02
	CMP V_028C	; search both drives?
	BEQ B_C5CC	; yes
B_C5E3	LDA V_027A,X
	TAX
	JSR S_C787	; get length of filename
	LDY #$03
	JMP L_C602
	;
B_C5EF	LDA V_0200,X	; get chars out of command line
	CMP (zp8D),Y	; same character in directory?
	BEQ B_C600	; yes
	CMP #$3F	; '?'
	BNE B_C5CC	; no
	LDA (zp8D),Y	; shift blank, end of name?
	CMP #$A0	; yes
	BEQ B_C5CC
B_C600	INX		; increment pointer
	INY
L_C602	CPX V_0276	; end of the name in the command?
	BCS B_C610	; yes
	LDA V_0200,X	; next character
	CMP #$2A	; '*'
	BEQ B_C61A	; yes, file found
	BNE B_C5EF	; continue search
B_C610	CPY #$13	; 19
	BCS B_C61A	; reached end of name
	LDA (zp8D),Y
	CMP #$A0	; shift blank, end of name
	BNE B_C5CC	; not found
B_C61A	LDX V_0279
	STX V_0253
	LDA zpE8,X
	AND #$80
	STA V_028A
	LDA V_0294
	STA zpDE,X
	LDA zp7A	; sector number of the directory
	STA zpD9,X	; enter in table
	LDY #$00
	LDA (zp8D),Y	; file type
	INY
	PHA
	AND #$40	; isolate search-protect bit
	STA zp6E	; (6) and save
	PLA
	AND #$DF	; erase bit 7
	BMI B_C641
	ORA #$20	; set bit 5
B_C641	AND #$27	; erase bits 3 and 4
	ORA zp6E	; get bit 6 again
	STA zp6E
	LDA #$80
	AND zpE8,X	; isolate flag for wildcard
	ORA zp6E
	STA zpE8,X	; write in table
	LDA zpE3,X
	AND #$80
	ORA zp78	; drive number
	STA zpE3,X
	LDA (zp8D),Y
	STA V_0280,X	; first track of file
	INY
	LDA (zp8D),Y
	STA V_0285,X	; get sector from directory
	LDA V_0258	; record length
	BNE B_C66E
	LDY #$15
	LDA (zp8D),Y	; record length
	STA V_0258	; get from directory
B_C66E	LDA #$FF
	STA V_028F
	LDA V_0278
	STA V_0279
S_C679	DEC V_0279
	BPL B_C67F
	RTS
;$C67F  --------
B_C67F	LDX V_0279
	LDA zpE8,X	; wildcard flag set?
	BMI B_C68B	; yes
	LDA V_0280,X	; track number already set
	BNE S_C679	; yes
B_C68B	LDA #$00
	STA V_028F
	RTS
;$C691  --------
S_C691	LDY #$00
	STY V_0291
	DEY
	STY V_0253
	LDA V_F0C3	; 18, directory track
	STA zp79
	LDA #$01
	STA zp7A	; sector 1
	STA V_0293
	JSR S_D5C8	; read sector
L_C6A9	LDA V_0293
	BNE B_C6AF
	RTS
;$C6AF  --------
B_C6AF	LDA #$07
	STA V_0295	; number of directory entries (-1)
	LDA #$00
	JSR S_D649	; get pointer from buffer
	STA V_0293	; save as track number
L_C6BC	JSR S_D63B	; set buffer pointer
	DEC V_0295	; decrement counter
	LDY #$00
	LDA (zp8D),Y	; first byte from directory
	BNE B_C6E0
	LDA V_0291
	BNE S_C6FC
	JSR S_DF76	; get track and sector number
	LDA zp7A
	STA V_0291	; sector number
	LDA zp8D
	LDX V_0292
	STA V_0292	; buffer pointer
	BEQ S_C6FC
	RTS
;$C6E0  --------
B_C6E0	LDX #$01
	CPX V_0292	; buffer pointer to one?
	BNE B_C714
	BEQ S_C6FC
S_C6E9	LDA V_F0C3	; 18, track number of BAM
	STA zp79	; track number
	LDA V_0290
	STA zp7A	; sector number
	JSR S_D5C8	; read block
	LDA V_0294
	JSR S_D61B	; set buffer pointer
S_C6FC	LDA #$FF
	STA V_0253	; erase-file found flag
	LDA V_0295
	BMI B_C70E	; all directory entries checked?
	LDA #$20
	JSR S_D31C	; increment buffer ptr by 32, next entry
	JMP L_C6BC	; and continue
	;
B_C70E	JSR S_D5A0	; set buffer pointer
	JMP L_C6A9	; read next block
	;
B_C714	LDA zp8D
	STA V_0294
	JSR S_DF76	; get track & sector number from buffer
	LDA zp7A
	STA V_0290	; save sector number
	RTS
;$C722  -------- Test and initalise drive
S_C722	LDX zp78
	LSR zp22,X
	BCC B_C74A
	LDA #$FF
	STA V_0298	; set error flag
	JSR S_D12A	; read directory track
	LDY #$FF
	CMP #$02	; 20, 'read error'?
	BEQ B_C740
	CMP #$03	; 21, 'read error'?
	BEQ B_C740
	CMP #$0F	; 74, 'drive not ready'?
	BEQ B_C740
	LDY #$00
B_C740	LDX zp78	; drive number
	TYA
	STA zp5F,X	; save error flag
	BNE B_C74A
	JSR S_D15E	; load BAM
B_C74A	LDX zp78	; drive number
	LDA zp5F,X	; transmit error code
	RTS

;$C74F  -------- Name of file in directory buffer

S_C74F	PHA
	JSR S_C787	; get end of the name
	JSR S_C769	; write filename in buffer
	PLA
	SEC
	SBC V_024B	; compare length with maximal length
	TAX
	BEQ B_C768
	BCC B_C768
	LDA #$A0	; pad with 'shift blank'
B_C762	STA (zp8D),Y
	INY
	DEX
	BNE B_C762
B_C768	RTS

;$C769  -------- Copy filename to work buffer

S_C769	TYA		; buffer number
	ASL A
	TAY		; times 2 as pointer
	LDA $009A,Y
	STA zp8D
	LDA $009B,Y	; buffer pointer after $9b/$9c
	STA zp8D+1
	LDY #$00
B_C778	LDA V_0200,X	; transmit characters in buffer
	STA (zp8D),Y
	INY
	BEQ B_C786	; buffer already full?
	INX
	CPX V_0276
	BCC B_C778
B_C786	RTS

;$C787  -------- Search for end of name in command

S_C787	LDA #$00
	STA V_024B
	TXA
	PHA
B_C78E	LDA V_0200,X	; get characters out of buffer
	CMP #$2C	; ','
	BEQ B_C7A9
	CMP #$3D	; '='
	BEQ B_C7A9
	INC V_024B	; increment length of name
	INX
	LDA #$0F	; 15
	CMP V_024B
	BCC B_C7A9	; greater?
	CPX V_0274	; end of input line?
	BCC B_C78E
B_C7A9	STX V_0276
	PLA
	TAX		; pointer to end of name
	RTS
;$C7AF  --------
S_C7AF	LDA zp7C
	PHA		; secondary address and channel number
	LDA zp7B
	PHA
	JSR S_C7BF	; create file entry for directory
	PLA
	STA zp7B
	PLA		; get data back
	STA zp7C
	RTS
;$C7BF  --------
S_C7BF	LDA #$11	; 17
	STA zp7C	; secondary address
	JSR S_D1FB	; open channel to read
	JSR S_D63B	; set buffer pointer
	LDA V_0253
	BPL B_C7D8	; not yet last entry?
	LDA V_028D
	BNE B_C7DD
	JSR S_C8E7	; write 'blocks free.'
	CLC
	RTS
;$C7D8  --------
B_C7D8	LDA V_028D
	BEQ B_C7FC
B_C7DD	DEC V_028D
	BNE B_C7EF
	DEC V_028D
	JSR S_C477
	JSR S_C8E7
	SEC
	JMP S_C477
	;
B_C7EF	LDA #$00
	STA V_0273
	STA V_028D	; drive 0
	JSR S_C898	; create header ???
	SEC
	RTS
;$C7FC  --------
B_C7FC	LDX #$18
	LDY #$1D
	LDA (zp8D),Y	; number of blocks hi
	STA V_0273	; in buffer
	BEQ B_C809	; zero?
	LDX #$16
B_C809	DEY
	LDA (zp8D),Y	; number of blocks lo
	STA V_0272	; in buffer
	CPX #$16
	BEQ B_C81D
	CMP #$0A	; 10
	BCC B_C81D
	DEX
	CMP #$64	; 100
	BCC B_C81D
	DEX
B_C81D	JSR S_C88D	; erase buffer
	LDA (zp8D),Y	; file type
	PHA
	ASL A		; bit 7 in carry
	BPL B_C82B	; bit 6 not set?
	LDA #$3C	; '<' for protected file
	STA V_02B2,X	; write behind file type
B_C82B	PLA
	AND #$0F	; isolate bits 0-3
	TAY		; as file type marker
	LDA V_F106,Y	; 3rd letter of the file type
	STA V_02B1,X	; in buffer
	DEX
	LDA V_F101,Y	; 2nd letter of the file type
	STA V_02B1,X	; in buffer
	DEX
	LDA V_F0FB + 1,Y	; 1st letter of the file type
	STA V_02B1,X	; in buffer
	DEX
	DEX
	BCS B_C84C	; file not closed?
	LDA #$2A	; '*'
	STA V_02B2,X	; before file type in buffer
B_C84C	LDA #$A0	; pad with 'shift blank'
	STA V_02B1,X	; in buffer
	DEX
	LDY #$12
B_C854	LDA (zp8D),Y	; filenames
	STA V_02B1,X	; write in buffer
	DEX
	DEY
	CPY #$03
	BCS B_C854
	LDA #$22	; '='
	STA V_02B1,X	; write before file type
B_C864	INX
	CPX #$20
	BCS B_C874
	LDA V_02B1,X	; character from buffer
	CMP #$22	; '='
	BEQ B_C874
	CMP #$A0	; 'shift blank' at end of name
	BNE B_C864
B_C874	LDA #$22	; fill through '='
	STA V_02B1,X
B_C879	INX
	CPX #$20
	BCS B_C888
	LDA #$7F	; bit 7
	AND V_02B1,X
	STA V_02B1,X	; erase in the remaining chars
	BPL B_C879
B_C888	JSR S_C59A	; search for the directory entry
	SEC
	RTS

;$C88D  -------- Clear Directory Output Buffer

S_C88D	LDY #$1B
	LDA #$20
B_C891	STA V_02B0,Y	; write in buffer
	DEY
	BNE B_C891
	RTS

;$C898  -------- Create header with disk name

S_C898	JSR S_EF84	; initialize if needed
	JSR S_EF4A	; read disk name
	JSR S_C88D	; erase buffer
	LDA #$FF
	STA zp6E
	LDX zp78	; drive number
	STX V_0272	; as block number lo in buffer
	LDA #$00
	STA V_0273	; block number lo
	LDX zp98	; buffer number
	LDA V_F123,X	; hi-byte of the buffer address
	STA zp8D+1
	LDA V_F0C6	; $90, position of disk name
	STA zp8D	; save
	LDY #$16
	LDA (zp8D),Y	; pad buffer with 'shift blank'
	CMP #$A0
	BNE B_C8CE
	LDA #$31	; '1'
	DB $2C
B_C8C6	LDA (zp8D),Y	; character from buffer
	CMP #$A0	; compare with 'shift blank'
	BNE B_C8CE
	LDA #$20	; ' ' blank
B_C8CE	STA V_02B3,Y	; in buffer
	DEY
	BPL B_C8C6
	LDA #$12	; 'RVS ON'
	STA V_02B1	; in buffer
	LDA #$22	; '"'
	STA V_02B2	; write before
	STA V_02C3	; and after disk name
	LDA #$20	; ' ' blank
	STA V_02C4	; behind it
	RTS

;$C8E7  -------- Print 'blocks free.'

S_C8E7	JSR S_C88D	; erase buffer
	LDY #$0B	; 12 characters
B_C8EC	LDA V_C8F8,Y	; 'blocks free.'
	STA V_02B1,Y	; write in buffer
	DEY
	BPL B_C8EC
	JMP S_EDB8	; number of free blocks in front
	;
; $C8F8 'Blocks free.'
V_C8F8	DB "BLOCKS FREE."

	; Perform [S] - Scratch command

	JSR S_C480	; ascertain file type
	JSR S_C40A	; get drive number
	JSR S_C4B7	; initialize drive if needed
	LDA #$00
	STA zp7F	; counter for erased files
	JSR S_C582	; search for file in directory
	BMI B_C953	; not found?
B_C916	JSR S_DEF2	; is file open
	BCC B_C94E	; yes
	LDY #$00
	LDA (zp8D),Y	; file type
	AND #$40	; scratch protect
	BNE B_C94E	; yes
	JSR S_C997	; erase file and note in directory
	LDY #$13
	LDA (zp8D),Y	; track number of the first side-sector
	BEQ B_C936	; none present?
	STA zp79	; note track number
	INY
	LDA (zp8D),Y	; and sector number
	STA zp7A
	JSR S_C95E	; erase side-sector
B_C936	LDX V_0253	; file number
	LDA #$20
	AND zpE8,X	; bit 5 set?
	BNE B_C94C	; yes, file not closed
	LDA V_0280,X	; get track...
	STA zp79
	LDA V_0285,X	; ...and sector
	STA zp7A
	JSR S_C95E	; erase file
B_C94C	INC zp7F	; increment number of erased files
B_C94E	JSR S_C573	; search for next file
	BPL B_C916	; if present, erase
B_C953	LDA zp7F	; number of erased files
	STA zp79	; save as 'track'
	LDA #$01	; 1 as disk status
	LDY #$00	; 0 as 'sector'
	JMP L_C28D	; message 'files scratched'

	; Erase file

S_C95E	JSR S_EDCA	; free block in BAM
	JSR S_D5C8
	JSR S_EF84	; get buffer number in BAM
	LDA zpA8,X
	CMP #$FF
	BEQ L_C975
	LDA V_02F9
	ORA #$40
	STA V_02F9
L_C975	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	JSR S_D271	; get track
	STA zp79
	JSR S_D271	; get sector
	STA zp7A
	LDA zp79	; track number
	BNE B_C98E	; not equal to zero
	JSR S_ED5F	; write BAM
	JMP L_D37D	; close channel
	;
B_C98E	JSR S_EDCA	; free block in BAM
	JSR S_D5A0	; read next block
	JMP L_C975	; and continue

	; Erase dir entry

S_C997	LDY #$00
	TYA
	STA (zp8D),Y	; set file type to zero
	JSR S_DF99	; write block
	JMP S_D6EC	; and check

	; Perform [D] - Backup command (Unused)

L_C9A2	LDA #$31
	JMP L_C2B2	; 31, 'syntax error'
	;
	JMP L_C2B2

	; Format disk ??

V_C9A7
S_C9A7	LDA #$03
	JSR S_D808
	LDX #$03
	LDA #$F0
	STA zpFF
	STA V_02FE
	JSR L_C9C8	;
	LDA #$01
	STA zp0E
	LDA #$00
	STA zp0E+1
	LDA #$80
	STA V_02FE
	JMP L_C9C8
	;
L_C9C8	LDY #$03
B_C9CA	LDA V_02FE
	STA zp02,X
	JSR S_D819
	CMP #$02
	BCC B_C9E4	; smaller than two, then ok
	LDA #$FF
	STA zp40
	STA zpFF
	DEY
	BNE B_C9CA
	LDX #$00
	JMP L_E746	; 21, 'read error'
	;
B_C9E4	RTS

;$C9E5  -------- Perform [C] - Copy command

	LDA #$E0
	STA V_024F
	JSR S_EF3C
	JSR S_EF84	; get buffer number of BAM
	LDA #$FF
	STA zpA8,X
	LDA #$0F
	STA V_0256
	JSR S_C2CF	; check input line
	BNE B_CA01
	JMP L_C9A2	; 31, 'syntax error'
	;
B_CA01	JSR S_C2E2	; check input
	JSR S_C40A	; test drive number
	LDA V_028B	; flag for syntax check
	AND #$55	; "U"
	BNE B_CA1D
	LDX V_027A
	LDA V_0200,X	; character of the command
	CMP #$2A	; '*'
	BNE B_CA1D
B_CA18	LDA #$30
	JMP L_C2B2	 ; 30, 'syntax error'
	;
B_CA1D	LDA V_028B	; syntax flag
	AND #$D9
	BNE B_CA18	; 30, 'syntax error'
	JMP L_CA47
	;
	LDA #$00
	STA V_0258
	STA V_028C	; number of drives
	STA V_0280	; track number in directory
	STA V_0281
	LDA zpE4
	AND #$01
	STA zp78	; drive number
	ORA #$01
	STA V_0291
	LDA V_027B
	STA V_027A
	RTS
;$CA47  --------
L_CA47	JSR S_C53A	; search for file in directory
	LDA V_0278	; number of filenames in command
	CMP #$03	; smaller than three?
	BCC B_CA96	; yes
	LDA zpE3	; first drive number
	CMP zpE4	; second drive number
	BNE B_CA96	; not on same drive?
	LDA zpDE	; directory block of the 1st file
	CMP zpDF	; same directory block as second file?
	BNE B_CA96	; no
	LDA zpD9	; directory sector of first file
	CMP zpDA	; same directory sector as second file?
	BNE B_CA96	; no
	JSR S_CBC1	; is file present?
	LDA #$01
	STA V_0279
	JSR S_CAEF
	JSR S_D235	; get data type
	BEQ B_CA77	; rel-file? yes
	CMP #$02	; prg-file?
	BNE B_CA7C	; no
B_CA77	LDA #$64
	JSR L_C2B2	; 64, 'file type mismatch'
B_CA7C	LDA #$12	; 18
	STA zp7C	; secondary address
	LDA V_023C
	STA V_023D
	LDA #$FF
	STA V_023C
	JSR S_DB61	; prepare append
	LDX #$02
	JSR S_CAAE	; copy file
	JMP L_C27E	; done
	;
B_CA96	JSR S_CA9C	; copy file
	JMP L_C27E	; done

	;

S_CA9C	JSR S_CBDC	;
	LDA zpE3	; drive number of first file
	AND #$01
	STA zp78	; backup drive number
	JSR S_D5D9
	JSR S_D81E	; enter file in directory
	LDX V_0277
S_CAAE	STX V_0279
	JSR S_CAEF
	LDA #$11	; 17
	STA zp7C
	JSR S_D1FB	;
	JSR S_D235	; get data type
	BNE B_CAC3	; no rel-file?
	JSR S_CB48
B_CAC3	LDA #$08
	STA zp95
	JMP L_CACD
	;
B_CACA	JSR S_D0BA	; write byte in buffer
L_CACD	JSR S_CB2A	; and get byte
	LDA #$80
	JSR S_DEE1	; test bit 7
	BEQ B_CACA	; not set?
	JSR S_D235	; check file type
	BEQ B_CADF	; rel-file?
	JSR S_D0BA	; get data byte in buffer
B_CADF	LDX V_0279
	INX
	CPX V_0278
	BCC S_CAAE
	LDA #$12	; 18
	STA zp7C
	JMP L_DC39	; close channel
	;
S_CAEF	LDX V_0279
	LDA zpE3,X	; drive number
	AND #$01
	STA zp78	; save
	LDA V_F0C3	; 18, directory track
	STA zp79	; save
	LDA zpD9,X	; directory sector
	STA zp7A
	JSR S_D5C8	; read block
	LDX V_0279
	LDA zpDE,X	; pointer in block
	JSR S_D61B	; set buffer pointer
	LDX V_0279
	LDA zpE8,X	; file type
	AND #$07	; isolate
	STA V_024A	; and save
	LDA #$00
	STA V_0258
	JSR S_DAD7	; get parameters for rel-file
	LDY #$01
	JSR S_D235	; get file type
	BEQ B_CB26	; rel-file?
	INY
B_CB26	TYA
	JMP S_D61B	; set buffer pointer
	;
S_CB2A	LDA #$11	; 17
	STA zp7C
S_CB2E	JSR S_D4ED	; open channel and get byte
	STA zp7E
	LDX zp7B	; channel number
	LDA zpF3,X	; ... as index
	AND #$08	; isolate end marker
	STA zp95
	BNE B_CB47	; not set?
	JSR S_D235	; get data type
	BEQ B_CB47	; rel-file?
	LDA #$80
	JSR L_DED2	; set bit 7
B_CB47	RTS
;$CB48  --------
S_CB48	JSR S_D329	; set drive number
	JSR S_E306
	LDA zp93
	PHA
	LDA zp92
	PHA
	LDA #$12	; 18
	STA zp7C
	JSR S_D217	; open write channel
	JSR S_D329	; set drive number
	JSR S_E306
	JSR S_E3D7
	LDA zp93
	STA zp7F+1
	LDA zp92
	STA zp7F
	LDA #$00
	STA zp81
	STA zp91
	STA zp94
	PLA
	STA zp92
	PLA
	STA zp93
	JMP L_E476

	; Perform [R] - Rename command

	JSR S_C40A	; get drive number from command line
	LDA zpE4
	AND #$01
	STA zpE4	; 2nd drive number
	CMP zpE3	; compare with 1st drive number
	BEQ B_CB8C	; same?
	ORA #$80
B_CB8C	STA zpE3
	JSR S_C53A	; search for file in directory
	JSR S_CBDC	; does name exist?
	LDA zpE4
	AND #$01
	STA zp78	; drive number
	LDA zpDA
	STA zp7A	; sector number
	JSR S_DF92	; read block from directory
	JSR S_D6EC	; ok?
	LDA zpDF	; pointer to directory entry
	CLC
	ADC #$03	; pointer plus 3 to file name
	JSR S_D61B	; set buffer pointer
	JSR S_E0CE	; get buffer number
	TAY
	LDX V_027A
	LDA #$10	; 16 characters
	JSR S_C74F	; write name in buffer
	JSR S_DF99	; write block to directory
	JSR S_D6EC	; ok?
	JMP L_C27E	; done, prepare disk status

	; Check if file present

S_CBC1	LDA zpE9	; file type
	AND #$07
	STA V_024A	; save
	LDX V_0278
B_CBCB	DEX
	CPX V_0277
	BCC B_CBDB
	LDA V_0280,X	; track number
	BNE B_CBCB	; not zero?
	LDA #$62
	JMP L_C2B2	; 62, 'file not found'
	;
B_CBDB	RTS
;$CBDC  --------
S_CBDC	JSR S_CBC1	; does file exist with old name?
B_CBDF	LDA V_0280,X	; track number of new file
	BEQ B_CBE9	; file erased?
	LDA #$63
	JMP L_C2B2	; 63, 'file exists'
	;
B_CBE9	DEX
	BPL B_CBDF
	RTS

;$CBED  -------- Perform [M] - Memory command

	LDA L_0201	; 2nd character from buffer
	CMP #$2D	; '-'
	BNE B_CC3D
	LDA V_0203
	STA zp6E
	LDA V_0204
	STA zp6E+1	; address in $6E/$6F
	LDY #$00
	LDA V_0202	; 3rd character from buffer
	CMP #$52	; "R"
	BEQ B_CC12	; to memory read
	CMP #$57	; "W"
	BEQ B_CC42	; to memory write
	CMP #$45	; "E"
	BNE B_CC3D
	JMP ($006E)	; *** Indirect jump!

	; M-R memory read

B_CC12	LDA (zp6E),Y	; read byte
	STA zp7E
	LDA V_0274	; length of command line
	CMP #$06	; less than 6?
	BCC B_CC37	; yes
	LDX V_0205	; number
	DEX
	BEQ B_CC37	; only one byte?
	TXA		; number of bytes
	CLC
	ADC zp6E	; plus start address
	INC zp6E
	STA V_0249	; end pointer
	LDA zp6E
	STA zpA6	; buffer pointer for error message
	LDA zp6E+1	; set to start address for 'M-R'
	STA zpA6+1
	JMP L_D596	; byte out
	;
B_CC37	JSR S_D1FB	; open read channel
	JMP L_D58D	; byte out
	;
B_CC3D	LDA #$31
	JMP L_C2B2	; 31, 'syntax error'

	; M-W memory write

B_CC42	LDA V_0206,Y	; read character
V_CC45	STA (zp6E),Y	; and save
	INY
	CPY V_0205	; number of characters
	BCC B_CC42	; all characters?
	RTS

;$CC4E  -------- Perform [U] - User command
;
; User commands:
;
; User command	Function
; ------------  --------
; u0		Restore default user command table address ($FFEA)
; u1 or ua	Block read replacement at $CE51
; u2 or ub	Block write replacement at $CE8b
; u3 or uc	Jump to $0500
; u4 or ud	Jump to $0503
; u5 or ue	Jump to $0506
; u6 or uf	Jump to $0509
; u7 or ug	Jump to $050c
; u8 or uh	Jump to $050f
; u9 or ui	Jump to ($fffa) reset tables ($ea39)
; u: or uj	Power up vector ($e9b5)
;
	LDY L_0201	; second char
	CPY #$30	; '0'
	BNE B_CC5E	; no
S_CC55	LDA #$EA
	STA zp6A	; pointer to table of user-addresses
	LDA #$FF	; $FFEA
	STA zp6A+1
	RTS
;$CC5E  --------
B_CC5E	JSR S_CC64
	JMP L_C27E	; done, prepare error message
	;
S_CC64	DEY
	TYA
	AND #$0F	; isolate number
	ASL A		; times 2
	TAY		; make an index of it
	LDA (zp6A),Y	; as pointer in table
	STA zp74
	INY		; address at $74/$75
	LDA (zp6A),Y
	STA zp74+1
	JMP ($0074)	; *** Indirect jump, execute function!

	; Open direct access channel, number

L_CC76	LDA V_028E	; last drive number
	STA zp78
	LDA zp7C	; channel number
	PHA		; check drive and initialize
	JSR S_C722
	PLA
	STA zp7C
	LDX V_0274	; length of filename
	DEX
	BNE B_CC97	; greater than one?
	LDA #$01
	JSR S_D338	; layout buffer and channel
	JMP L_CCE3	; set flags, done
	;
B_CC92	LDA #$70
	JMP L_C2B2	; 70, 'no channel'
	;
B_CC97	LDY #$01
	JSR B_CD6E	; get buffer number
	LDX V_0285	; buffer number
	CPX #$05	; bigger than 5?
	BCS B_CC92	; 70, 'no channel'
	LDA #$00
	STA zp6E
	STA zp6E+1
	SEC
B_CCAA	ROL zp6E
	ROL zp6E+1
	DEX
	BPL B_CCAA
	LDA zp6E
	AND V_024F
	BNE B_CC92
	LDA zp6E+1
	AND V_0250
	BNE B_CC92
	LDA zp6E
	ORA V_024F
	STA V_024F
	LDA zp6E+1
	ORA V_0250
	STA V_0250
	LDA #$00
	JSR S_D338	; search channel
	LDX zp7B	; channel number
	LDA V_0285	; buffer number
	STA zpA8,X
	TAX
	LDA zp78	; drive number
	STA zp02,X
	STA V_025B,X
L_CCE3	LDX zp7C	; secondary address
	LDA V_022B,X
	ORA #$40	; set READ and WRITE flags
	STA V_022B,X
	LDY zp7B	; channel number
	LDA #$FF
	STA V_0244,Y	; end pointer
	LDA #$89
	STA $00F3,Y	; set READ and WRITE flags
	LDA $00A8,Y	; buffer number
	STA V_023E,Y
	ASL A		; times 2
	TAX
	LDA #$01
	STA zp9A,X	; buffer pointer to one
V_CD05	LDA #$0E
	STA $00ED,Y	; flag for direct access
	JMP L_C27E	; done

	; Perform [B] - Block/Buffer command

	LDY #$00
	LDX #$00
	LDA #$2D	; '-'
	JSR S_C352	; search for minus sign
	BNE B_CD22	; found?
B_CD18	LDA #$31
	JMP L_C2B2	; 31, 'syntax error'
	;
B_CD1D	LDA #$30
	JMP L_C2B2	; 30, 'syntax error'
	;
B_CD22	TXA
	BNE B_CD1D
	LDX #$05
	LDA V_0200,Y	; char from buffer
B_CD2A	CMP V_CD4F,X	; compare with 'AFRWEP'
	BEQ B_CD34	; found?
	DEX
	BPL B_CD2A	; compare with all characters
	BMI B_CD18	; not found, error
B_CD34	TXA
	ORA #$80	; command number, set bit 7
	STA V_022A
	JSR S_CD5F + 2	; get parameters
	LDA V_022A
	ASL A		; number times 2
	TAX		; as index
	LDA V_CD56,X	; address of command hi
	STA zp6E+1
	LDA V_CD54 + 1,X	; address lo
B_CD4A	STA zp6E
	JMP ($006E)	; *** Indirect jump to command
	;
V_CD4F	EOR (zp45+1,X)	; AFRWEP
; $CD51
	DB "R"
; $CD52
	DB "WE"
V_CD54	BVC B_CD4A + 1
V_CD56	CMP V_CDE6 + 1
	PHA
	DEC V_CE65
; $CD5D
	DB $97,$CE
S_CD5F	LDX V_A0CE
	BRK
	LDX #$00	; Get parameters form block commands
	LDA #$3A	; ':'
	JSR S_C352	; test line to colon
	BNE B_CD6E	; found?
	LDY #$03	; no, begin at 4th character
B_CD6E	LDA V_0200,Y	; search for separating char
	CMP #$20	; ' ' blank
	BEQ B_CD7D
	CMP #$1D	; cursor right
	BEQ B_CD7D
	CMP #$2C	; ',' comma
	BNE B_CD84
B_CD7D	INY
	CPY V_0274	; line end?
	BCC B_CD6E
	RTS
;$CD84  --------
B_CD84	JSR S_CD93	; preserve next parameter
	INC V_0277	; increment parameter counter
	LDY V_0279
	CPX #$04	; compare with maximum number
	BCC B_CD7D
	BCS B_CD1D	; 30, 'syntax error'
S_CD93	LDA #$00
	STA zp6E
	STA zp6E+1	; erase storage area for decimal numbers
	STA zp70+1
	LDX #$FF
B_CD9D	LDA V_0200,Y	; get characters from input buffer
	CMP #$40
	BCS B_CDBC	; no digits?
	CMP #$30	; '0'
	BCC B_CDBC	; no digits?
	AND #$0F	; convert ASCII digits to hex
	PHA		; and save
	LDA zp6E+1
	STA zp70	; move digits one further
	LDA zp6E
	STA zp6E+1
	PLA
	STA zp6E	; note read number
	INY		; increment pointer in input buffer
	CPY V_0274	; line end reached
	BCC B_CD9D	; no
B_CDBC	STY V_0279	; save pointer
	CLC
	LDA #$00
B_CDC2	INX
	CPX #$03
	BCS B_CDD6	; convert hex digits to one byte
	LDY zp6E,X
B_CDC9	DEY
	BMI B_CDC2
	ADC V_CDE4,X	; add decimal value
	BCC B_CDC9
	CLC
	INC zp70+1
	BNE B_CDC9
B_CDD6	PHA
	LDX V_0277	; counter for paramaters
	LDA zp70+1
	STA V_0280,X	; hi-byte
	PLA
	STA V_0285,X	; lo-byte
	RTS
;$CDE4  -------- Decimal values  1, 10, 100
V_CDE4	DB $01,$0A,$64
;	-------- B-F block free
V_CDE7	DB " "		; get track, sector and drive number
	INC zpCE
	JSR S_EDCA	; free block
	JMP L_C27E	; done, prepare error message
	;
	LDA #$01
	STA V_02F9
	;
	; B-A block allocate
	;
	JSR S_CEE6	; get track, sector and drive number
	LDA zp7A	; sector
	PHA		; save
	JSR S_F065	; find block in BAM
	BEQ B_CE0B	; block allocated?
	PLA		; desired sector
	CMP zp7A	; = next free sector?
	BNE B_CE1E	; no
	JSR S_EDFB	; allocate block in BAM
	JMP L_C27E	; done
	;
B_CE0B	PLA
B_CE0C	LDA #$00
	STA zp7A	; sector 0
	INC zp79	; next track
	LDA zp79	; track number
	CMP V_F11A	; 36, last track number + 1
	BCS B_CE23	; >=, then 'no block'
	JSR S_F065	; find free block in next track
	BEQ B_CE0C	; not found, check next track
B_CE1E	LDA #$65
	JSR S_E781	; 65, 'no block' next free block
B_CE23	LDA #$65
	JSR L_C2B2	; 65, 'no block' no more free blocks
	;
	; Read block to buffer
	;
S_CE28	JSR S_CEE3	; open channel, set parameters
	JMP S_D5B3	; read block from disk
	;
S_CE2E	JSR S_D23F	; set pointer to buffer
	LDA (zp9A,X)	; get byte
	RTS

;$CE34  -------- Read block from disk

S_CE34	JSR S_CE28	; open channel, read block
	LDA #$00
	JSR S_D61B	; set buffer pointer to zero
	JSR S_CE2E	; get a byte from the buffer
	STA V_0244,Y
	LDA #$89	; set read and write flag
	STA $00F3,Y
	RTS

;$CE48  -------- B-R block read

	JSR S_CE34	; read block from disk
	JSR S_D53F	; prepare byte from buffer
S_CE4E	JMP L_C27E	; prepare error message
	;
	; U1, Block read without changing buffer pointer
	;
	JSR S_CD5F + 2	; get parameters of the command
	JSR S_CE34	; read block from disk
	LDA V_0244,Y	; end pointer
	STA V_023E,Y	; save as data byte
	LDA #$FF
	STA V_0244,Y	; end pointer to $FF
	JMP L_C27E	; done, prepare error message
	;
	; B-W block write
	;
V_CE65	JSR S_CEE3	; open channel
	JSR S_D63B	; set buffer pointer
	TAY
	DEY
	CMP #$02	; buffer pointer lo less than 2?
	BCS B_CE73	; no
	LDY #$01
B_CE73	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	TYA
	JSR S_D10D	; write byte in buffer
	TXA
	PHA
	JSR S_D5B7	; write block to disk
	PLA
	TAX
	LDY zp7B
	JSR S_D541	; get byte from buffer
	JMP L_C27E	; done, error message
	;
	; U2, Block write without changing buffer pointer
	;
V_CE8B	JSR S_CD5F + 2	; get command parameters
	JSR S_CEE3	; open channel
	JSR S_D5B7	; and write block to disk
	JMP L_C27E	; done
	;
	; B-E block execute
	;
	JSR S_CE28	; open channel and read block
	LDA #$00
	STA zp6E	; address low
	LDX zp98	; buffer number
	LDA V_F123,X	; buffer address high
	STA zp6E+1
	JSR S_CEAB	; execute routine
	JMP L_C27E	; done
	;
S_CEAB	JMP ($006E)	; *** Indirect jump to routine
	;
	; B-P block pointer
	;
	JSR S_CEC3	; open channel, get buffer number
	LDA zp98	; buffer number
	ASL A		; * 2
	TAX		; as index
	LDA V_0286	; pointer value
	STA zp9A,X	; save as buffer pointer
	JSR S_D23F	; prepare a byte in buffer
	JSR S_D541	; for output
	JMP L_C27E	; done
	;
	;  Open channel
	;
S_CEC3	LDX zp99
	INC zp99
	LDA V_0285,X	; buffer number
	TAY
	DEY
	DEY
	CPY #$0C	; buffer number smaller than 14?
	BCC B_CED6	; yes
B_CED1	LDA #$70
	JMP L_C2B2	; 70, 'no channel'
	;
B_CED6	STA zp7C	; secondary address
	JSR S_D1FB	; open channel
	BCS B_CED1	; already allocated, 'no channel'
	JSR S_E0CE	; buffer number
	STA zp98	; set
	RTS

;$CEE3  -------- Check buffer number and open channel

S_CEE3	JSR S_CEC3	; check buffer number and open channel
S_CEE6	LDX zp99	; channel number
	LDA V_0285,X	; buffer address
	AND #$01
	STA zp78	; drive number
	LDA V_0287,X
	STA zp7A	; sector
	LDA V_0286,X
	STA zp79	; track
	JSR S_D6B0	; track and sector ok?
	RTS

;$CEFD  -------- Set pointer for REL file

S_CEFD	JSR S_CF1B	; record number * record length
	JSR S_CF5D	; divide by 254
	LDA zp89	; remainder = pointer in data block
	STA zp94	; data pointer
	JSR S_CF60	; divide by 120 = side-sector number
	INC zp94
	INC zp94	; data pointer + 2 (track/sector pointer!)
	LDA zp84	; result of division
	STA zp92	; equals side-sector number
	LDA zp89	; remainder
	ASL A		; times 2
	CLC
	ADC #$10	; plus 16
	STA zp93	; =pointer in side-sector to data block
	RTS
;$CF1B  --------
S_CF1B	JSR S_CF8F	; erase work storage
	STA zp8B
	LDX zp7B	; channel number
	LDA zpB6,X	; record number lo
	STA zp89
	LDA zpBC,X	; record number hi
	STA zp8A
	BNE B_CF30
	LDA zp89
	BEQ B_CF3B	; record number not zero?
B_CF30	LDA zp89
	SEC
	SBC #$01	; then subtract one
	STA zp89
	BCS B_CF3B
	DEC zp8A
B_CF3B	LDA zpC8,X	; record length
	STA zp6E
B_CF3F	LSR zp6E
	BCC B_CF46
	JSR S_CFA3	; record number * record length
B_CF46	JSR S_CF9B	; shift register left
	LDA zp6E
	BNE B_CF3F
	LDA zp91
	CLC
	ADC zp84
	STA zp84
	BCC B_CF5C	; result in $8B/$8C/$8D
	INC zp85
	BNE B_CF5C
	INC zp86
B_CF5C	RTS

;$CF5D  -------- Divide by 254

S_CF5D	LDA #$FE
	DB $2C
	; Divide by 120
S_CF60	LDA #$78
	BIT V_06A9
	STA zp6E	; divisor
	LDA #$00
	STA zp89
	STA zp8A
	LDX #$18
B_CF6F	ASL zp84
	ROL zp85
	ROL zp86
	ROL zp89
	ROL zp8A
	LDA zp89
	SEC
	SBC zp6E
	TAY
	LDA zp8A
	SBC #$00
	BCC B_CF8B
	INC zp84
	STA zp8A
	STY zp89
B_CF8B	DEX
	BNE B_CF6F
	RTS

;$CF8F  -------- Erase work storage

S_CF8F	LDA #$00
	STA zp84
	STA zp85
	STA zp86
	RTS
;$CF98  -------- Left shift 3-byte register twice
	JSR S_CF9B
	; Left shift 3-byte register once
S_CF9B	CLC
	ROL zp89
	ROL zp8A
	ROL zp8B
	RTS

;$CFA3  -------- Add 3-byte registers

S_CFA3	CLC
	LDX #$FD
B_CFA6	LDA zp87,X	; register $84/$85/$86
	ADC zp8C,X	; add to register $89/$8a/$8b
	STA zp87,X
	INX
	BNE B_CFA6
	RTS
;$CFB0  --------
S_CFB0	LDX #$00
B_CFB2	TXA
	STA zpD4,X
	INX
	CPX #$04
	BNE B_CFB2
	LDA #$06
	STA zpD4,X
	RTS
;$CFBF  --------
S_CFBF	LDY #$04
	LDX zp7B	; channel number
L_CFC3	LDA $00D4,Y
	STX zpD4,Y
	CMP zp7B	; channel number
	BEQ B_CFD3
	DEY
	BMI S_CFB0
	TAX
	JMP L_CFC3
	;
B_CFD3	RTS
;$CFD4  --------
S_CFD4	JSR S_CFBF
	LDX zp7B
	LDA zpA8,X
	BMI B_CFDF
	LDA zpAF,X
B_CFDF	CMP #$FF
	BEQ B_CFFB
	LDA zpA8,X
	EOR #$80
	STA zpA8,X
	PHA
	LDA zpAF,X
	EOR #$80
	STA zpAF,X
	TAY
	PLA
	BPL B_CFF5
	TYA
B_CFF5	AND #$BF
	TAX
	JMP S_D6EC
	;
B_CFFB	LDA zpA8,X
	BPL B_D001
	LDA zpAF,X
B_D001	AND #$BF
	TAY
	LDA V_025B,Y
	AND #$01
	STA zp78
	JSR S_D3E4
	BPL B_D015
	LDA #$70
	JMP L_C2B2
	;
B_D015	LDX zp7B
	ORA #$80
	LDY zpA8,X
	BPL B_D021
	STA zpA8,X
	BMI B_D023
B_D021	STA zpAF,X
B_D023	LDA zp79	; track
	PHA
	LDA zp7A	; sector
	PHA
	LDA #$01
	STA zp70
	LDA zpA8,X
	BPL B_D033
	LDA zpAF,X
B_D033	AND #$BF
	TAY
	LDA V_F123,Y
	STA zp70+1
	LDY #$00
	LDA (zp70),Y
	STA zp7A
	LDA #$00
	STA zp70
	LDA zpA8,X
	BPL B_D04B
	LDA zpAF,X
B_D04B	AND #$BF
	TAY
	LDA V_F123,Y
	STA zp70+1
	LDY #$00
	LDA (zp70),Y
	STA zp79
	BEQ B_D085
	JSR S_D235
	BEQ B_D06B
	JSR S_DEE6
	BNE B_D06B
	JSR S_D0AB
	JMP L_D07C
	;
B_D06B	LDX zp7B
	LDA zpA8,X
	EOR #$80
	STA zpA8,X
	LDA zpAF,X
	EOR #$80
	STA zpAF,X
	JSR S_DF92
L_D07C	PLA
	STA zp7A	; get sector
	PLA
	STA zp79	; and track number
	JMP L_D08E
	;
B_D085	PLA
	STA zp7A	; get back sector
	PLA
	STA zp79	; and track number
	JSR S_D0AB
L_D08E	JSR S_E0CE
	TAX
	JMP S_D6EC	; and verify
	;
B_D095	LDA #$70
	JMP L_C2B2	; 70, 'no channel'
	;
S_D09A	JSR S_CFBF
	JSR S_E0F2
	BNE B_D0AA
	JSR S_D3E4
	BMI B_D095
	JSR S_E0FD
B_D0AA	RTS

;$D0AB  -------- Change buffer

S_D0AB	LDX zp7B	; channel number
	LDA zpA8,X
	EOR #$80
	STA zpA8,X
	LDA zpAF,X	; rotate bit 7 in table
	EOR #$80
	STA zpAF,X
	RTS

;$D0BA  -------- Write data in buffer

S_D0BA	LDX #$12	; channel 18
	STX zp7C
	JSR S_D217	; open write channel
	JSR S_D235	; check file type
	BCC B_D0CB	; no rel-file
	LDA #$20
	JSR B_DED8	; change buffer
B_D0CB	LDA zp7C	; secondary address
	CMP #$0F	; 15?
	BEQ B_D0F4	; yes
	BNE B_D0DB	; no
S_D0D3	LDA zp7D	; secondary address
	AND #$8F
	CMP #$0F	; greater than 15?
	BCS B_D0F4	; then input buffer
B_D0DB	JSR S_D235	; check file type
	BCS B_D0E5	; rel-file or direct access?
	LDA zp7E	; data byte
	JMP L_D2F3	; write in buffer
	;
B_D0E5	BNE B_D0EA	; direct access file?
	JMP L_E1E6	; write data byte in rel-file
	;
B_D0EA	LDA zp7E
	JSR S_D10D	; write data byte in buffer
	LDY zp7B	; channel number
	JMP S_D541	; prepare next byte for output
	;
B_D0F4	LDA #$04	; channel 4
	STA zp7B	; corresponding input buffer
	JSR S_D63B	; set buffer pointer
	CMP #$2A	; 40
	BEQ B_D104	; buffer end?
	LDA zp7E
	JSR S_D10D	; write data byte in buffer
B_D104	LDA zp95	; end flag set?
	BEQ B_D109	; yes
	RTS
;$D109  --------
B_D109	INC V_0255	; set command flag
	RTS

;$D10D  -------- Write data byte in buffer

S_D10D	PHA		; save data byte
	JSR S_E0CE	; get buffer number
	BPL B_D119	; associated buffer?
	PLA
	LDA #$61
	JMP L_C2B2	; 61, 'file not open'
	;
B_D119	ASL A		; buffer number times 2
	TAX		; as index
	PLA		; data byte
	STA (zp9A,X)	; write in buffer
	INC zp9A,X	; increment buffer pointer
	RTS

;$D121  -------- Perform [I] - Initalise command

	JSR S_C2BB	; find drive number
	JSR S_D15E	; load BAM
	JMP L_C27E	; prepare disk status
	;
	; Read BAM from disk
	;
S_D12A	JSR S_EF7A
	TAY
	LDX zpA8,Y
	CPX #$FF
	BNE B_D148
	PHA
	JSR S_D3E4
	TAX
	BPL B_D140
	LDA #$70
	JSR S_E784	; 70, 'no channel'
B_D140	PLA
	TAY
	TXA
	ORA #$80
	STA $00A8,Y
B_D148	TXA
	AND #$0F
	STA zp98
	LDX #$00
	STX zp7A	; sector 0
	LDX V_F0C3	; 18
	STX zp79	; track 18
	JSR S_D808	; transmit parameter to disk controller
	LDA #$B0	; command code 'read block header'
	JMP B_D6DF	; transmit to disk controller
	;
	; Load BAM
	;
S_D15E	JSR S_EF3C
	JSR S_D465
	JSR S_D12A	; read block
	LDX zp78	; drive number
	LDA #$00
	STA V_0251,X	; reset flag for "BAM changed'
	JSR L_D6D9
	LDA zp98
	ASL A
	TAX
	LDA #$02	; buffer pointer to $200
	STA zp9A,X
	LDA (zp9A,X)	; get character from buffer
	LDX zp78	; drive number
	STA zp5D,X
	LDA #$00
	STA zp22,X	; flag for write protect
	STA zp5F,X	; flag for read error
	;
	; Calculate blocks free
	;
L_D185	JSR S_EDA5	; buffer address to $6C/$6D
	LDY #$04	; begin at position 4
	LDA #$00
	TAX
B_D18D	CLC
	ADC (zp6C),Y	; add number of free blocks per track
	BCC B_D193
	INX		; X as hi-byte
B_D193	INY
	INY
	INY
	INY		; plus 4
	CPY #$48	; track 18?
	BEQ B_D193	; then skip
	CPY #$90	; last track number?
	BNE B_D18D	; no
	PHA		; lo-byte
	TXA		; hi-byte
	LDX zp78	; drive number
	STA V_02FC,X	; hi-byte to $2FC
	PLA		; lo-byte
	STA V_02FA,X	; to $2FA
	RTS
;$D1AB  --------
S_D1AB	JSR S_D805	; parameters to disk controller
	JSR S_D1D3	; read block
	JSR S_D6EC	; ok?
	JSR S_D247	; get byte from buffer
	STA zp79	; track
	JSR S_D247	; next byte from buffer
	STA zp7A	; sector
	RTS
;$D1BF  --------
L_D1BF	JSR S_D1AB
	LDA zp79	; track
	BNE B_D1C7
	RTS
;$D1C7  --------
B_D1C7	JSR S_CFD4	; change buffer
	JSR S_D805	; parameters to disk controller
	JSR S_D1D3	; read block
	JMP S_CFD4	; change buffer
	;
	; Read block
	;
S_D1D3	LDA #$80	; code for 'read'
	BNE B_D1D9
S_D1D7	LDA #$90	; code for 'write'
B_D1D9	STA V_024D	; save
	JSR S_E0CE	; get buffer number
	TAX
	JSR L_D659	; get track/sector, read/write block
	TXA
	PHA
	ASL A		; buffer pointer times 2
	TAX
	LDA #$00
	STA zp9A,X	; pointer in buffer to zero
	JSR S_D235	; get file type
	CMP #$04	; rel-file or direct access?
	BCS B_D1F8	; yes
	INC zpB6,X
	BNE B_D1F8	; increment block counter
	INC zpBC,X
B_D1F8	PLA
	TAX
	RTS

;$D1FB  -------- Open channel for reading

S_D1FB	LDA zp7C	; secondary address
	CMP #$13	; 19
	BCC B_D203	; smaller?
	AND #$0F
B_D203	CMP #$0F
	BNE B_D209
	LDA #$10	; 16
B_D209	TAX
	SEC		; pre-set error
	LDA V_022B,X	; channel number
	BMI B_D216	; reserved already? then return with Carry set
	AND #$0F	; isolate channel nr
	STA zp7B	; save as current channel
	TAX		; ... to X
	CLC		; flag for ok
B_D216	RTS

;$D217  -------- Open channel for write

S_D217	LDA zp7C	; secondary address
	CMP #$13	; 19
	BCC B_D21F	; smaller?
	AND #$0F
B_D21F	TAX
	LDA V_022B,X	; channel number
	TAY
	ASL A
	BCC B_D231
	BMI B_D233
B_D229	TYA
	AND #$0F
	STA zp7B
	TAX
	CLC		; flag for ok
	RTS
;$D231  --------
B_D231	BMI B_D229
B_D233	SEC		; flag for channel allocated
	RTS

;$D235  -------- Get file type into accu
;
; also returns the Z flag set when REL ($04) type
;
S_D235	LDX zp7B
	LDA zpED,X
	LSR A
	AND #$07
	CMP #$04	; 'REL'?
	RTS

;$D23F  -------- Get buffer and channel numbers

S_D23F	JSR S_E0CE	; get buffer number
	ASL A
	TAX
	LDY zp7B
	RTS

;$D247  -------- Get a byte from buffer

S_D247	LDX zp7B	; get buffer and channel number
	LDA zpA8,X
	BPL B_D24F
	LDA zpAF,X
B_D24F	AND #$BF
	ASL A
	TAX
	LDY zp7B
	LDA V_0244,Y	; end pointer
	BEQ B_D26C
	LDA (zp9A,X)	; get byte from buffer
	PHA
	LDA zp9A,X	; buffer pointer
	CMP V_0244,Y	; equal end pointer?
	BNE B_D268	; no
	LDA #$FF	; buffer pointer to -1
	STA zp9A,X
B_D268	PLA		; data byte
	INC zp9A,X	; increment buffer pointer
	RTS
;$D26C  --------
B_D26C	LDA (zp9A,X)	; get character from buffer
	INC zp9A,X	; increment buffer pointer
	RTS

;$D271  -------- Get byte and read next block

S_D271	JSR S_D247	; get byte from buffer
	BNE B_D2E7	; not last character?
	STA zp7E	; save data byte
	LDA V_0244,Y	; end pointer
	BEQ B_D285	; yes
	LDA #$80
	STA $00F3,Y	; READ-flag
	LDA zp7E	; data byte
	RTS
;$D285  --------
B_D285	JSR S_CFD4	; change buffer and read next block
	LDA #$00
	STA zp6E	; set buffer pointer to zero
	LDX zp7B	; get channel number
	LDA zpA8,X	; buffer number
	BPL B_D294
	LDA zpAF,X	; buffer number from 2nd table
B_D294	AND #$BF	; erase V bit
	ASL A
	TAX
	LDA zp9B,X	; buffer pointer hi
	STA zp8D+1
	LDA zp6E
	STA zp9A,X	; buffer pointer lo, new value
	STA zp8D
	JSR S_D247	; get first byte from buffer
	CMP #$00	; track number zero
	BEQ B_D2E8	; yes, then last block
	STA zp79	; save last track number
	JSR S_D247	; get next byte
	STA zp7A	; save as following track
	JSR S_CFD4	; change buffer and read next block
	LDX zp7B
	LDA zpA8,X
	BPL B_D2BB
	LDA zpAF,X	; get drive number
B_D2BB	AND #$BF	; erase V bit
	TAX
	LDA V_025B,X	; isolate drive number
	AND #$01
	STA zp78	; and save
	LDX zp7B
	LDA zpA8,X
	BPL B_D2CD
	LDA zpAF,X
	; Transmit parameter to disk controller
B_D2CD	AND #$BF
	ASL A
	TAY
	LDA zp79	; track number
	STA $0008,Y	; transmit
	LDA zp7A	; sector number
	STA $0009,Y	; transmit
	LDA zp78	; drive number
	ASL A		; * 2
	TAX		; make an index from it
	JSR S_D1D3	; transmit read command
	JSR S_CFD4	; change buffer and read block
	LDA zp7E	; get data byte
B_D2E7	RTS
;$D2E8  --------
B_D2E8	JSR S_D247	; get next byte from buffer
	LDY zp7B
	STA V_0244,Y	; save as end pointer
	LDA zp7E	; get data byte back
	RTS
;$D2F3  -------- Write byte in buffer and block
L_D2F3	JSR S_D10D	; byte in buffer
	BEQ B_D2F9	; buffer full?
	RTS
;$D2F9  --------
B_D2F9	JSR S_D329	; get drive number
	JSR S_EF89	; find free block in BAM
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	LDA zp79
	JSR S_D10D	; track number as first byte
	LDA zp7A
	JSR S_D10D	; sector number as second byte
	JSR S_D1D7	; write block
	JSR S_CFD4	; change buffer
	JSR S_D805	; parameter to disk controller
	LDA #$02
	JMP S_D61B	; buffer pointer to 2
	;
S_D31C	STA zp6E
	JSR S_D63B	; get buffer pointer
	CLC
	ADC zp6E
	STA zp9A,X	; and increment
	STA zp8D
	RTS

;$D329  -------- Get drive number

S_D329	JSR S_E0CE	; get drive number
	TAX
	LDA V_025B,X
	AND #$01	; isolate drive number
	STA zp78	; and save
	RTS

;$D335  -------- Find write channel and buffer

S_D335	SEC		; flag for writing
	BCS B_D339
	;
	; Find read channel and buffer
	;
S_D338	CLC		; flag for reading
B_D339	PHP		; save
	STA zp6E	; buffer number
	JSR L_D37D	; close channel
	JSR S_D4D1	; allocate free channel
	STA zp7B	; channel number
	LDX zp7C	; secondary address
	PLP
	BCC B_D34B	; read channel?
	ORA #$80	; flag for writing
B_D34B	STA V_022B,X	; set
	AND #$3F
	TAY
	LDA #$FF	; default value
	STA $00A8,Y
	STA $00AF,Y	; write in associated table
	STA $00CE,Y
	DEC zp6E	; decrement buffer number
	BMI B_D37C	; done already?
	JSR S_D3E4	; find buffer
	BPL B_D36D	; found?
L_D365	JSR S_D3B0	; erase flags in table
	LDA #$70
	JMP L_C2B2	; 70, 'no channel'
	;
B_D36D	STA $00A8,Y	; buffer number in table
	DEC zp6E	; buffer number
	BMI B_D37C	; already done?
	JSR S_D3E4	; find buffer
	BMI L_D365	; not found?
	STA $00AF,Y	; buffer number in table
B_D37C	RTS

;$D37D  -------- Close channel

L_D37D	LDA zp7C	; secondary address
	CMP #$0F	; 15?
	BNE B_D384	; no
	RTS		; else done already
;$D384  --------
B_D384	LDX zp7C
	LDA V_022B,X	; channel number
	CMP #$FF	; not associated (=free)?
	BEQ B_D3AF	; then done
	AND #$3F
	STA zp7B	; channel number
	LDA #$FF
	STA V_022B,X	; erase association in table
	LDX zp7B
	LDA #$00
	STA zpF3,X	; erase READ and WRITE flag
	JSR S_D3B0	; free buffer
	LDX zp7B	; channel number
	LDA #$01	; set bit 0
B_D3A3	DEX
	BMI B_D3A9	; shift to correct position
	ASL A
	BNE B_D3A3
B_D3A9	ORA V_0256	; free in allocation register
	STA V_0256
B_D3AF	RTS
;$D3B0  -------- Free buffer
S_D3B0	LDX zp7B	; channel number
	LDA zpA8,X	; buffer number
	CMP #$FF
	BEQ B_D3C1	; not associated?
	PHA
	LDA #$FF
	STA zpA8,X	; erase buffer association
	PLA
	JSR S_D445	; erase buffer allocation register
B_D3C1	LDX zp7B	; channel number
	LDA zpAF,X
	CMP #$FF	; associated in second table?
	BEQ B_D3D2	; no
	PHA
	LDA #$FF
	STA zpAF,X	; erase association
	PLA
	JSR S_D445	; erase buffer in allocation register
B_D3D2	LDX zp7B	; channel number
	LDA zpCE,X
	CMP #$FF	; associated in 3rd table?
	BEQ B_D3E3	; no
	PHA
	LDA #$FF
	STA zpCE,X	; erase association
	PLA
	JSR S_D445	; erase buffer in allocation register
B_D3E3	RTS
;$D3E4  -------- Find buffer
S_D3E4	TYA
	PHA
	LDY #$01
	JSR S_D40C
	BPL B_D3F9
	DEY
	JSR S_D40C
	BPL B_D3F9
	JSR S_D48B
	TAX
	BMI B_D408
B_D3F9	LDA zp78
	STA zp02,X
	STA V_025B,X
	TXA
	ASL A
	TAY
	LDA #$02
	STA $009A,Y
B_D408	PLA
	TAY
	TXA
	RTS
;$D40C  --------
S_D40C	LDX #$07
B_D40E	LDA V_024F,Y
	AND V_EE54,X	; erase bit
	BEQ B_D41A
	DEX
	BPL B_D40E
	RTS
;$D41A  --------
B_D41A	LDA V_024F,Y
	EOR V_EE54,X	; rotate bit
	STA V_024F,Y
	TXA		; buffer number
	DEY
	BMI B_D42A
	CLC
	ADC #$08
B_D42A	TAX		; buffer number
B_D42B	RTS
;$D42C  --------
L_D42C	LDX zp7B
	LDA zpA8,X
	BMI B_D43B
	TXA
	CLC
	ADC #$07
	TAX
	LDA zpA8,X
	BPL B_D42B
B_D43B	CMP #$FF
	BEQ B_D42B
	PHA
	LDA #$FF
	STA zpA8,X
	PLA
S_D445	AND #$0F
	TAY		; buffer number
	INY
	LDX #$10	; 16
B_D44B	ROR V_0250
	ROR V_024F	; rotate 16-bit allocation register
	DEY
	BNE B_D455
	CLC		; erase bit for buffer
B_D455	DEX
	BPL B_D44B
	RTS

;$D459  -------- Close all channels

S_D459	LDA #$0E	; 14
	STA zp7C	; secondary address
B_D45D	JSR L_D37D	; close channel
	DEC zp7C	; next secondary address
	BNE B_D45D
	RTS

;$D465  -------- Close all channels of other drives

S_D465	LDA #$0E	; 14
	STA zp7C	; secondary address
B_D469	LDX zp7C
	LDA V_022B,X	; association table
	CMP #$FF	; channel associated?
	BEQ B_D486	; no
	AND #$3F
	STA zp7B	; channel number
	JSR S_E0CE	; get buffer number
	TAX
	LDA V_025B,X	; drive number
	AND #$01	; isolate
	CMP zp78	; equal to actual drive number
	BNE B_D486	; no
	JSR L_D37D	; close channel
B_D486	DEC zp7C	; next channel
	BPL B_D469
	RTS
;$D48B  --------
S_D48B	LDA zp6E
	PHA
	LDY #$00
B_D490	LDX zpD4,Y
	LDA zpA8,X
	BPL B_D49A
	CMP #$FF
	BNE B_D4B0
B_D49A	TXA
	CLC
	ADC #$07
	TAX
	LDA zpA8,X
	BPL B_D4A7
	CMP #$FF
	BNE B_D4B0
B_D4A7	INY
	CPY #$05
	BCC B_D490
	LDX #$FF
	BNE B_D4CC
B_D4B0	STX zp6E
	AND #$3F
	TAX
B_D4B5	LDA zp02,X
	BMI B_D4B5
	CMP #$02
	BCC B_D4C5
	LDX zp6E
	CPX #$07
	BCC B_D49A
	BCS B_D4A7
B_D4C5	LDY zp6E
	LDA #$FF
	STA $00A8,Y
B_D4CC	PLA
	STA zp6E
	TXA
	RTS

;$D4D1  -------- Find channel and allocate

S_D4D1	LDY #$00
	LDA #$01	; set bit 0
B_D4D5	BIT V_0256
	BNE B_D4E3	; channel free?
	INY
	ASL A		; rotate bit to left
	BNE B_D4D5	; all channels checked?
	LDA #$70
	JMP L_C2B2	; 70, 'no channel'
	;
B_D4E3	EOR #$FF	; rotate bit model
	AND V_0256	; erase bit
	STA V_0256	; allocate channel
	TYA
	RTS

;$D4ED  -------- Get byte for output

S_D4ED	JSR S_D1FB	; open channel for reading
	JSR S_D4F9	; get byte in output register
	LDX zp7B	; channel number
	LDA V_023E,X	; get byte
	RTS
;$D4F9  --------
S_D4F9	LDX zp7B	; channel number
	LDA zpED,X	; check file type
	LSR A
	AND #$07
	CMP #$04	; REL?
	BNE B_D507	; no...
	JMP L_E25B	; get byte from REL-file
	;
B_D507	LDA zp7C	; secondary address
	CMP #$0F	; 15
	BEQ B_D567	; yes, read error channel
	LDA zpF3,X
	AND #$08	; end flag set?
	BNE B_D526	; no
	JSR S_D235	; check file type
	CMP #$07	; direct access file?
	BNE B_D521	; no
	LDA #$89	; set READ and WRITE flag
	STA zpF3,X
	JMP L_D531
	;
B_D521	LDA #$00
	STA zpF3,X	; erase READ and WRITE flag
	RTS
;$D526  --------
B_D526	LDA zp7C	; secondary address
	BEQ B_D55C	; zero, LOAD?
	JSR S_D235	; check file type
	CMP #$04	; rel-file or direct access?
	BCC B_D553	; no
L_D531	JSR S_D23F	; get buffer and channel number
	LDA zp9A,X	; buffer pointer
	CMP V_0244,Y	; equal end pointer?
	BNE S_D53F	; no
	LDA #$00
	STA zp9A,X	; buffer pointer to zero
S_D53F	INC zp9A,X	; increment buffer pointer
S_D541	LDA (zp9A,X)	; get byte from buffer
	STA V_023E,Y	; into output register
	LDA zp9A,X	; buffer pointer
	CMP V_0244,Y	; equal end pointer?
	BNE B_D552	; no
	LDA #$81
	STA $00F3,Y	; set flags
B_D552	RTS
;$D553  --------
B_D553	JSR S_D271	; get byte from buffer
L_D556	LDX zp7B	; channel number
	STA V_023E,X	; byte in output register
	RTS
;$D55C  --------
B_D55C	LDA V_0254	; flag for directory?
	BEQ B_D553	; no
	JSR S_EBD4	; create directory line
	JMP L_D556
	;
B_D567	JSR S_D63B	; set buffer pointer
	CMP #$D4
	BNE B_D586
	LDA zp8D+1
	CMP #$02
	BNE B_D586
	LDA #$0D	; CR
	STA zp7E	; in output register
	JSR S_F3F0	; erase error flags
	LDA #$00
	JSR S_E800	; create 'ok' message
	DEC zpA6	; set buffer pointer back
	LDA #$80	; set READ flag
	BNE B_D598
B_D586	JSR S_D247	; get byte from buffer
	STA zp7E	; into output register
	BNE L_D596
L_D58D	LDA #$D4
	JSR S_D61B	; set buffer pointer in front of error pointer
	LDA #$02
	STA zp9B,X	; hi-address
L_D596	LDA #$88	; set READ flag
B_D598	STA zpF8
	LDA zp7E	; data byte
	STA V_0243	; into output register
	RTS

;$D5A0  -------- Read next block

S_D5A0	JSR S_E0CE	; get buffer number
	ASL A		; times 2
	TAX		; make an index of it
	LDA #$00
	STA zp9A,X	; buffer pointer to zero
	LDA (zp9A,X)	; get first byte from buffer
	BEQ B_D5B2	; no block following?
	DEC zp9A,X	; buffer pointer to -1
	JMP S_D271	; read next block
	;
B_D5B2	RTS

;$D5B3  -------- Read block

S_D5B3	LDA #$80	; command code for reading
	BNE B_D5B9	; always jump
	; Write block
S_D5B7	LDA #$90	; command code for writing
B_D5B9	ORA zp78	; drive number
	STA V_024D	; save code
	LDA zp98
	JSR S_D808	; parameter to disk controller
	LDX zp98
	JMP L_D6E6	; execute command
	;
	; Allocate buffer and read block
	;
S_D5C8	LDA #$01
S_D5CA	STA V_024A	; file type to sequential
	LDA #$11	; 17
	STA zp7C	; secondary address
	JSR S_DD7D	; allocate buffer and read block
	LDA #$02
	JMP S_D61B	; buffer pointer to 2
	;
	; Allocate new block
	;
S_D5D9	LDA #$12	; 18
	STA zp7C	; secondary address
	JMP L_DE15	; allocate new block
	;
	; Write dir block
	;
S_D5E0	JSR S_DF76	; get track and sector number
	LDA #$01
	STA zp6E	; a block
	LDA zp68	; save step width 10 for block
	PHA		; allocation
	LDA #$03
	STA zp68
	JSR S_EF98	; find free block in BAM
	PLA
	STA zp68	; get step width back
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	LDA zp79
	JSR S_D10D	; track number in buffer
	LDA zp7A
	JSR S_D10D	; sector number in buffer
	JSR S_D1D7	; write block to disk
	JSR S_D6EC	; and verify
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
B_D60E	JSR S_D10D	; fill buffer with zeroes
	BNE B_D60E
	JSR S_D10D	; zero as following track
	LDA #$FF
	JMP S_D10D	; $FF as number of bytes
	;
	; Set buffer pointer
	;
S_D61B	STA zp6E	; save pointer
	JSR S_E0CE	; get buffer number
	ASL A		; times 2
	TAX
	LDA zp9B,X	; buffer pointer hi
	STA zp8D+1
	LDA zp6E
	STA zp9A,X	; buffer pointer lo, new value
	STA zp8D
	RTS
;$D62D  -------- Close internal channel
L_D62D	LDA #$11	; 17
	STA zp7C
	JSR L_D37D	; close channel
	LDA #$12	; 18
	STA zp7C
	JMP L_D37D	; close channel
	;
	; Set buffer pointer
	;
S_D63B	JSR S_E0CE	; get buffer number
L_D63E	ASL A
	TAX
	LDA zp9B,X	; buffer pointer hi
	STA zp8D+1
	LDA zp9A,X	; buffer pointer lo
	STA zp8D
	RTS

;$D649  -------- Get byte from buffer

S_D649	STA zp70	; pointer lo
	JSR S_E0CE	; get buffer number
	TAX
	LDA V_F123,X	; hi-byte buffer address
	STA zp70+1	; pointer hi
	LDY #$00
	LDA (zp70),Y	; get byte from buffer
	RTS

;$D659  -------- Check track and sector numbers

L_D659	LDA V_025B,X	; command code for disk controller
	AND #$01	; drive number
	ORA V_024D	; plus command code
S_D661	PHA		; save
	STX zp98	; buffer number
	TXA
	ASL A		; times 2
	TAX
	LDA zp09,X	; sector
	STA V_024D	; save
	LDA zp08,X	; track
	BEQ B_D69B	; 66, 'illegal track or sector'
	CMP V_F11A	; 36, highest track number + 1
	BCS B_D69B	; 66, 'illegal track or sector'
	TAX
	PLA		; command code
	PHA
	AND #$F0
	CMP #$90	; code for writing?
	BNE B_D6CB	; no
	PLA
	PHA
	LSR A
	BCS B_D687
	LDA zp5D
	BCC B_D689
B_D687	LDA zp5E
B_D689	BEQ B_D690
	CMP V_F118	; 'A', format marker
	BNE L_D6C3	; 73, 'cbm dos v2.6 tdisk'
B_D690	TXA		; track number
	JSR S_F0B6	; get maximum sector number
	CMP V_024D	; compare with sector number
	BEQ B_D69B	; equal, then error
	BCS B_D6CB	; smaller?
B_D69B	JSR S_D6A3	; get track and sector number
B_D69E	LDA #$66
	JMP S_E781	; 66, 'illegal track or sector'
	;
	; Get track and sector numbers for current job
	;
S_D6A3	LDA zp98	; buffer number
	ASL A		; *2
	TAX		; as index
	LDA zp08,X
	STA zp79	; track
	LDA zp09,X
	STA zp7A	; sector
	RTS

;$D6B0  -------- Check for valid track and sector numbers

S_D6B0	LDA zp79	; track
	BEQ B_D69E	; zero, then error
	CMP V_F11A	; 36, maximum track number + 1
	BCS B_D69E	; 66, 'illegal track and sector number'
	JSR S_F0B6	; get maximum sector number
	CMP zp7A	; sector
	BEQ B_D69E
	BCC B_D69E	; error
	RTS

;$D6C3  -------- DOS mismatch error

L_D6C3	JSR S_D6A3	; get track and sector number
	LDA #$73
	JMP S_E781	; 73, 'cbm dos v2.6 tdisk'
	;
B_D6CB	LDX zp98	; buffer number
	PLA
	STA V_024D	; command code for disk controller
	STA V_025B,X	; write in table
	STA zp02,X	; and in command register
	JMP S_D819
	;
	; Read block
	;
L_D6D9	LDA #$80	; code for read
	BNE B_D6DF	; always jump
	; Write block
L_D6DD	LDA #$90	; code for write
B_D6DF	ORA zp78	; drive number
	LDX zp98	; buffer number
S_D6E3	STA V_024D
L_D6E6	LDA V_024D	; command code
	JSR S_D661	; check track and sector
	; Verify execution
S_D6EC	JSR S_D6F9	; verify execution
	BCS S_D6EC	; wait for end
	PHA
	LDA #$00
	STA V_0298	; erase error flag
	PLA
	RTS
;$D6F9  --------
S_D6F9	LDA zp02,X	; command code (bit 7) still in register?
	CMP #$02	; yes
	BCC B_D713	; error-free execution
	CMP #$08	; 8?
	BEQ B_D70B	; write protect
	CMP #$0B	; 11
	BEQ B_D70B	; ID mismatch
	CMP #$0F	; 15
	BNE B_D715
B_D70B	BIT V_0298
	BMI B_D713
	JMP B_D78A	; create error message
	;
B_D713	CLC		; execution ended
	RTS

;$D715  -------- Additional attempts for read errors

B_D715	TYA
	PHA
	LDA zp78	; drive number
	PHA
	LDA V_025B,X
	AND #$01	; drive number
	STA zp78
	JSR L_F3F7	; set LED flag
	JSR S_D7F0	; read attempt
	CMP #$02
	BCS B_D72E	; not ok?
	JMP L_D7B7	; done
	;
B_D72E	LDA V_025B,X	; command code
	AND #$F0	; isolate
	PHA
	CMP #$90	; code for write
	BNE B_D73F	; no
	LDA zp78	; drive number
	ORA #$B8
	STA V_025B,X
B_D73F	BIT zp69
	BVS B_D77C
	LDA #$00
	STA V_0299	; counter for searches next to track
	STA V_029A
B_D74B	LDY V_0299	; counter
	LDA V_029A
	SEC
	SBC V_F11C + 2,Y	; constants for read attempts
	STA V_029A
	LDA V_F11C + 2,Y
	JSR S_D7C5	; position head next to track
	INC V_0299	; increment counter
	JSR S_D7F0	; read attempt
	CMP #$02	; return message
	BCC B_D770	; smaller than 2, ok?
	LDY V_0299	; load counter
	LDA V_F11C + 2,Y	; get constants
	BNE B_D74B	; not yet zero (table end)?
B_D770	LDA V_029A
	JSR S_D7C5	; position head
	LDA zp02,X
	CMP #$02	; return message
	BCC B_D7A6	; ok?
B_D77C	BIT zp69
	BPL B_D78F
B_D780	PLA		; command code
	CMP #$90	; for writing?
	BNE B_D78A	; no
	ORA zp78	; drive number
	STA V_025B,X	; command code in table
B_D78A	LDA zp02,X	; return message
	JSR L_E746	; set error message
B_D78F	PLA
	BIT V_0298
	BMI L_D7B7
	PHA
	LDA #$C0	; command code for head positioning
	ORA zp78	; drive number
	STA zp02,X	; in command register
	JSR S_D819	; wait for execution
	JSR S_D7F0	; attempt command execution again
	CMP #$02	; return message
	BCS B_D780	; incorrect?
B_D7A6	PLA
	CMP #$90	; command code for writing
	BNE L_D7B7	; no
	ORA zp78	; drive number
	STA V_025B,X	; in table
	JSR S_D7F0	; attempt execution again
	CMP #$02	; return message
	BCS B_D78A	; error?
L_D7B7	PLA
	STA zp78	; get drive number back
	PLA
	TAY
	LDA zp02,X	; error code
	PHA
	JSR S_F3F0
	PLA
	CLC		; end-of-execution flag
	RTS

;$D7C5  -------- Move head by half a track

S_D7C5	CMP #$00
	BEQ B_D7E1
	BMI B_D7D7
B_D7CB	LDY #$01
	JSR S_D7E2	; transmit data for head position
	SEC
	SBC #$01
	BNE B_D7CB
	BEQ B_D7E1
B_D7D7	LDY #$FF
	JSR S_D7E2	; transmit data for head position
	CLC
	ADC #$01
	BNE B_D7D7
B_D7E1	RTS
;$D7E2  -------- Move head one track in or out
S_D7E2	PHA
	TYA
	STA zp54
B_D7E6	CMP zp54	; wait for return message from...
	BEQ B_D7E6
	LDA #$00	; ...disk controller
	STA zp54
	PLA
	RTS

;$D7F0  -------- Attempt command execution multiple times

S_D7F0	LDA zp69	; maximum number of repetitions
	AND #$3F
	TAY
B_D7F5	LDA V_025B,X	; command
	STA zp02,X	; transmit to disk controller
	JSR S_D819	; wait for execution
	CMP #$02	; ok?
	BCC B_D804	; yes
	DEY		; decrement counter
	BNE B_D7F5	; attempt again
B_D804	RTS

;$D805  -------- Transmit param to disk controller

S_D805	JSR S_E0CE	; get buffer number
	;
S_D808	ASL A		; track number
	TAY
	LDA zp79	; track number
	STA $0008,Y	; transmit
	LDA zp7A	; sector number
	STA $0009,Y	; transmit
	LDA zp78	; drive number
	ASL A		; times 2
	TAX
	RTS
;$D819  --------
S_D819	LDA zp02,X	; wait for execution
	BMI S_D819
	RTS

;$D81E  -------- Enter file in dir

S_D81E	LDA zp7C	; secondary address
	PHA
	LDA zp7B	; channel number
	PHA
	LDA zp7A	; sector number
	PHA
	LDA zp79	; track number
	PHA		; save
	LDA #$11	; 17
	STA zp7C	; as secondary address
	JSR S_DF76	; get track and sector number
	LDA V_024A	; file type
	PHA		; save
	LDA zpE3	; drive number
	AND #$01
	STA zp78	; set
	LDX zp98	; buffer number
	EOR V_025B,X
	LSR A
	BCC B_D84F	; equal drive number?
	LDX #$01
	STX V_0292	; pointer in directory
	JSR S_C691	; load dir and find first entry
	BEQ B_D86A	; not found?
	BNE B_D877	; found?
B_D84F	LDA V_0291	; sector number in directory
	BEQ B_D860	; equal zero?
	CMP zp7A	; equal sector number?
	BEQ B_D877	; yes
	STA zp7A	; save sector number
	JSR S_D5B3	; read block
	JMP B_D877
	;
B_D860	LDA #$01
	STA V_0292	; pointer to one
	JSR S_C6FC	; find next entry in directory
	BNE B_D877	; found?
B_D86A	JSR S_D5E0	; write directory block
	LDA zp7A	; sector number
	STA V_0291
	LDA #$02
	STA V_0292	; pointer to 2
B_D877	LDA V_0292
	JSR S_D61B	; set buffer pointer
	PLA
	STA V_024A	; file type
	CMP #$04	; rel-file?
	BNE B_D887	; no
	ORA #$80	; set bit 7
B_D887	JSR S_D10D	; and write in buffer
	PLA
	STA V_0280	; following track
	JSR S_D10D	; in buffer
	PLA
	STA V_0285	; following sector
	JSR S_D10D	; in buffer
	JSR S_E0CE	; get buffer number
	TAY
	LDA V_027A	; pointer to drive number
	TAX
	LDA #$10	; 16, length of filename
	JSR S_C74F	; write filename in buffer
	LDY #$10
	LDA #$00
B_D8A9	STA (zp8D),Y	; fill with zeroes at position 16
	INY
	CPY #$1B	; position 27 already?
	BCC B_D8A9	; no
	LDA V_024A	; file type
	CMP #$04	; rel-file?
	BNE B_D8CA	; no
	LDY #$10
	LDA V_0259	; track
	STA (zp8D),Y
	INY
	LDA V_025A	; and sector
	STA (zp8D),Y	; the side-sectors in directory entry
	INY
	LDA V_0258	; record length
	STA (zp8D),Y	; in directory
B_D8CA	JSR S_D5B7	; write block
	PLA
	STA zp7B	; channel number
	TAX
	PLA
	STA zp7C	; secondary address
	LDA V_0291
	STA zpD9
	STA V_0260,X
	LDA V_0292
	STA zpDE
	STA V_0266,X
	LDA V_024A	; file type
	STA zpE8
	LDA zp78	; drive number
	STA zpE3
	RTS

;$D8EE  -------- OPEN command, secondary addr 15

L_D8EE	LDA zp7C	; secondary address
	STA V_024C
	JSR S_C39D	; get line length, erase flags
	STX V_022A
	LDX V_0200	; first character from buffer
	LDA V_024C	; secondary address
	BNE B_D92A	; not equal 0 (LOAD)?
	; Check '*' Last file
	CPX #$2A	; '*'
	BNE B_D92A
	LDA zp77	; last track number
	BEQ B_D953
	STA zp79	; track number
	LDA V_026E	; last drive number
	STA zp78	; drive number
	STA zpE3
	LDA #$02
	STA zpE8	; set data type to program
	LDA V_026F	; last sector number
	STA zp7A	; sector
	JSR S_DD7D	; allocate buffer, read block
	LDA #$04	; file type
	ORA zp78	; drive number
L_D922	LDX zp7B	; channel number
	STA $00ED,Y	; set flag
	JMP L_C27E	; done
	;
	; Check '$' Directory
	;
B_D92A	CPX #$24	; '$'
	BNE B_D94C	; no
	LDA V_024C	; secondary address
	BNE B_D936	; not equal to zero?
	JMP L_DB8C	; OPEN $
	;
B_D936	JSR S_C2BB	; analyze line to end
	LDA V_F0C3	; 18, directory track
	STA zp79	; track
	LDA #$00
	STA zp7A	; sector 0
	JSR S_DD7D	; allocate buffer, read block
	LDA zp78	; drive number
	ORA #$02
	JMP L_D922	; continue as above
	;
	; Check '#' direct channel
	;
B_D94C	CPX #$23	; "#"
	BNE B_D962
	JMP L_CC76	; open direct access file
	;
B_D953	LDA #$02
	STA V_0296	; file type program
	LDA #$00
	STA zp78
	STA V_028E	; drive 0
	JSR S_D15E	; load BAM
B_D962	JSR S_C2CF	; analyze line
	BNE B_D96B	; colon found?
	LDX #$00
	BEQ B_D977
B_D96B	TXA		; comma found?
	BEQ B_D973	; no
	LDA #$30
	JMP L_C2B2	; 30, 'syntax error'
	;
B_D973	DEY
	BEQ B_D977
	DEY
B_D977	STY V_027A	; pointer to drive number
	LDA #$8D	; shift CR
	JSR S_C352	; check command line to end ???
	INX
	STX V_0278	; comma counter in file name
	JSR S_C3FC	; get drive number
	JSR S_C4B7	; check drive number
	JSR S_C582	; find file entry in directory
	LDX #$00	; default values
	STX V_0258	; record length
	STX V_0297
	STX V_024A	; file type
	INX
	CPX V_0277	; comma before equal sign?
	BCS B_D9AD	; no
	JSR S_DB40	; get file type and control mode
	INX
	CPX V_0277	; additional comma?
	BCS B_D9AD	; no
	CPY #$04
	BEQ B_D9E8
	JSR S_DB40	; get file type and control method
B_D9AD	LDX V_024C
	STX zp7C	; secondary address
	CPX #$02	; greater than 2?
	BCS B_D9C8	; yes
	STX V_0297	; 0 or 1 (LOAD or SAVE)
	LDA #$40
	STA V_02F9
	LDA V_024A	; file type
	BNE B_D9DE	; not deleted
	LDA #$02	; PRG
	STA V_024A	; as file type
B_D9C8	LDA V_024A
	BNE B_D9DE
	LDA zpE8
	AND #$07	; get file type and command line
	STA V_024A
	LDA V_0280	; track number
	BNE B_D9DE	; not equal zero?
	LDA #$01
	STA V_024A	; file type sequential
B_D9DE	LDA V_0297	; control method
	CMP #$01	; 'W'
	BEQ B_D9FD	; yes
	JMP L_DA77
	;
B_D9E8	LDY V_027A,X	; pointer behind second comma
	LDA V_0200,Y	; get value
	STA V_0258	; record length
	LDA V_0280	; track number
	BNE B_D9AD
	LDA #$01	; 'W'
	STA V_0297	; as second method
	BNE B_D9AD
B_D9FD	LDA zpE8	; file type
	AND #$80	; isolate wildcard flag
	TAX
	BNE B_DA18	; wildcard in name
	LDA #$20
	BIT zpE8	; was file closed?
	BEQ B_DA10	; yes
	JSR S_C997	; byte 0 in buffer and write block
	JMP L_DB1A
	;
B_DA10	LDA V_0280	; track number of the first block
	BNE B_DA18	; already existing
	JMP L_DB1A
	;
B_DA18	LDA V_0200	; first character from input buffer
	CMP #$40	; '@'?
	BEQ B_DA2C	; yes
	TXA
	BNE B_DA27	; wildcard set?
	LDA #$63
	JMP L_C2B2	; 63, 'file exists'
	;
B_DA27	LDA #$33
	JMP L_C2B2	; 33, 'syntax error'
	;
	; Open a file with overwriting (@)
	;
B_DA2C	LDA zpE8	; file type
	AND #$07	; isolate
	CMP V_024A
	BNE B_DA9C	; file type different?
	CMP #$04	; rel-file?
	BEQ B_DA9C	; 64, 'file type mismatch'
	JSR L_DE15
	LDA zp7B
	STA V_0270	; save channel number
	LDA #$11
	STA zp7C
	JSR S_D1FB	; open read channel
	LDA V_0294
	JSR S_D61B	; set buffer pointer for directory
	LDY #$00
	LDA (zp8D),Y	; file type
	ORA #$20	; set bit 5, open file
	STA (zp8D),Y
	LDY #$1A
	LDA zp79	; track
	STA (zp8D),Y
	INY
	LDA zp7A	; and sector
	STA (zp8D),Y	; for open with at-sign
	LDX V_0270	; channel number
	LDA zpD9
	STA V_0260,X	; pointer to directory block
	LDA zpDE
	STA V_0266,X
	JSR S_DF76	; get track and sector number
	JSR S_D5B7	; write block
	JMP B_DB26	; prepare track, sector, and drive number
	;
L_DA77	LDA V_0280	; first track number
	BNE B_DA81	; file not erased?
	LDA #$62
	JMP L_C2B2	; 62, 'file not found'
	;
B_DA81	LDA V_0297	; control mode
	CMP #$03	; 'M'
	BEQ B_DA93	; yes, then no test of unclosed file
	LDA #$20	; bit 5
	BIT zpE8	; test in file type
	BEQ B_DA93	; not set, ok
	LDA #$60
	JMP L_C2B2
	;
B_DA93	LDA zpE8
	AND #$07	; isolate file type
	CMP V_024A
	BEQ B_DAA1
B_DA9C	LDA #$64
	JMP L_C2B2	; 64, 'file type mismatch'
	;
B_DAA1	LDY #$00
	STY V_0279
	LDX V_0297	; control mode
	CPX #$02	; 'A', append
	BNE B_DAC7	; no
	CMP #$04	; rel-file?
	BEQ B_DA9C
	LDA (zp8D),Y
	AND #$4F	; "O"
	STA (zp8D),Y
	LDA zp7C
	PHA
	LDA #$11
	STA zp7C	; channel 17
	JSR S_DF76	; get track and sector number
	JSR S_D5B7	; write block
	PLA
	STA zp7C	; get channel number back
B_DAC7	JSR S_DAD7
	LDA V_0297	; control mode
	CMP #$02
	BNE B_DB26
	JSR S_DB61
	JMP L_C27E	; done
	;
	; Open file for reading
	;
S_DAD7	LDY #$13
	LDA (zp8D),Y	; track
	STA V_0259
	INY
	LDA (zp8D),Y	; record length
	STA V_025A
	INY
	LDA (zp8D),Y	; record length
	LDX V_0258	; last record len
	STA V_0258
	TXA
	BEQ B_DAFA
	CMP V_0258
	BEQ B_DAFA
	LDA #$50	; "P"
	JSR L_C2B2	; 50, 'record not present'
B_DAFA	LDX V_0279
	LDA V_0280,X	; track
	STA zp79
	LDA V_0285,X	; sector
	STA zp7A
	JSR S_DD7D
	LDY zp7B
	LDX V_0279
	LDA zpD9,X
	STA V_0260,Y
	LDA zpDE,X
	STA V_0266,Y
	RTS

;$DB1A  -------- Open file for writing

L_DB1A	LDA zpE3	; drive number
	AND #$01
	STA zp78
	JSR L_DE15
	JSR S_D81E
B_DB26	LDA zp7C	; channel number
	CMP #$02
	BCS B_DB3D
	JSR S_DF79
	LDA zp79
	STA zp77
	LDA zp78
	STA V_026E
	LDA zp7A
	STA V_026F
B_DB3D	JMP L_C283
	;
	; Check file type and control mode
	;
S_DB40	LDY V_027A,X	; pointer in command line
	LDA V_0200,Y	; get characters from line
	LDY #$04
B_DB48	DEY
	BMI B_DB53
	CMP V_F0F3,Y	; control modes 'R', 'W', 'A', 'M'
	BNE B_DB48
	STY V_0297	; save
B_DB53	LDY #$05
B_DB55	DEY
	BMI B_DB60
	CMP V_F0F6 + 1,Y	; file types 'D','S','P','U','L'
	BNE B_DB55
	STY V_024A	; save
B_DB60	RTS

;$DB61  -------- Preparation for append

S_DB61	JSR S_CB2E	; open channel to read, get byte
	LDA #$80
	JSR S_DEE1	; last byte?
	BEQ S_DB61	; no
	JSR S_DFD0	; get track and sector number
	LDX zp7A	; sector number
	INX
	TXA
	BNE B_DB79	; not $FF?
	JSR B_D2F9	; close buffer, write block
	LDA #$02
B_DB79	JSR S_D61B	; buffer pointer to 2
	LDX zp7B	; channel number
	LDA #$01
	STA zpF3,X	; set flag for WRITE
	LDA #$80
	ORA zp7B
	LDX zp7C
	STA V_022B,X	; channel number in table
	RTS

;$DB8C  -------- Open directory

L_DB8C	LDA #$0D	; command number 12
	STA V_022A
	LDA #$00
	LDX V_0274
	DEX
	BEQ B_DBA4
	DEX
	BNE B_DBBD
	LDA L_0201	; second character
	JSR S_C4A5	; get drive number
	BMI B_DBBD	; not a plain number?
B_DBA4	STA zpE3
	INC V_0277
	INC V_0278
	INC V_027A
	LDA #$80
	STA zpE8	; set wildcard flag
	LDA #$2A	; '*'
	STA V_0200	; as file name in command buffer
	STA L_0201
	BNE B_DBD5	; absolute jump
B_DBBD	JSR S_C2CF	; test input line to ":"
	BNE B_DBC7	; found?
	JSR S_C3C6	; erase flags
	LDY #$03
B_DBC7	DEY
	DEY
	STY V_027A	; pointer to drive number in command
	JSR S_C2EA	; analyze line
	JSR S_C480	; ascertain file type
	JSR S_C40A	; get drive number
B_DBD5	JSR S_C4B7	; initialize drive if necessary
	JSR S_C898	; prepare disk title
	JSR S_C582	; load directory
	JSR S_EB0B	; create and prepare directory
	JSR S_D247	; get byte from buffer
	LDX zp7B	; channel number
	STA V_023E,X	; byte in output register
	LDA zp78	; drive number
	STA V_028E	; save as last drive number
	ORA #$04
	STA zpED,X	; PRG-flag
	LDA #$00
	STA zpA4	; set pointer back in input buffer
	RTS

;$DBF7  -------- Close routine

S_DBF7	LDA #$00
	STA V_02F9
	LDA zp7C	; secondary address
	BNE B_DC0B	; not zero?
	LDA #$00	; secondary address 0, LOAD
	STA V_0254
	JSR L_D37D	; close channel
B_DC08	JMP L_D62D	; close internal channels 17 & 18
	;
B_DC0B	CMP #$0F	; 15
	BEQ B_DC23	; yes, close all channels
	JSR L_DC39	; close file
	LDA zp7C	; secondary address
	CMP #$02	; smaller than 2?
	BCC B_DC08
	LDA V_026C
	BNE B_DC20
	JMP L_C27E	; termination
	;
B_DC20	JMP L_C297
	;
B_DC23	LDA #$0E	; 14
	STA zp7C	; secondary address
B_DC27	JSR L_DC39	; close file
	DEC zp7C	; next secondary address
	BPL B_DC27
	LDA V_026C
	BNE B_DC36
	JMP L_C27E	; termination
	;
B_DC36	JMP L_C297
	;
	; Close file
	;
L_DC39	LDX zp7C	; secondary address
	LDA V_022B,X	; get channel number
	CMP #$FF	; no channel associated?
	BNE B_DC43
	RTS		; no, then none
;$DC43  --------
B_DC43	AND #$0F	; isolate channel number
	STA zp7B
	JSR S_D235	; check data type
	CMP #$07	; direct access?
	BEQ B_DC5D	; yes
	CMP #$04	; rel-file?
	BEQ B_DC63	; yes
	JSR S_D217	; channel for writing open
	BCS B_DC60	; no file for writing?
	JSR S_DC99	; write last block
	JSR S_DCDC	; write entry in directory and block
B_DC5D	JSR S_ED5F	; write BAM
B_DC60	JMP L_D37D	; close channel
	;
B_DC63	JSR S_DF2C	; get buffer number, write block
	JSR S_CFD4	; change buffer
	JSR S_E306	; get last side-sector
	LDX zp92	; side-sector number
	STX zp72
	INC zp72
	LDA #$00
	STA zp6E+1
	STA zp70
	LDA zp93
	SEC
	SBC #$0E	; minus 14 for pointer
	STA zp70+1
	JSR S_E08C	; calculate block number of file
	LDX zp7B	; channel number
	LDA zp6E+1
	STA zpB6,X	; record number lo
	LDA zp70
	STA zpBC,X	; record number hi
	LDA #$40
	JSR S_DEE1	; bit 6 set?
	BEQ B_DC96	; no
	JSR S_DCDC	; enter in directory
B_DC96	JMP L_D37D	; close channel
	;
	; Write last block
	;
S_DC99	LDX zp7B	; channel number
	LDA zpB6,X	; record number lo
	ORA zpBC,X	; record number hi
	BNE B_DCAD	; not zero?
	JSR S_D63B	; set buffer pointer
	CMP #$02
	BNE B_DCAD	; not 2
	LDA #$0D	; CR
	JSR S_D10D	; in buffer
B_DCAD	JSR S_D63B	; set buffer pointer
	CMP #$02	; now equal to 2?
	BNE B_DCC3	; no
	JSR S_CFD4	; change buffer
	LDX zp7B	; channel number
	LDA zpB6,X	; record number lo
	BNE B_DCBF
	DEC zpBC,X	; decrement block number hi
B_DCBF	DEC zpB6,X	; and block number lo
	LDA #$00
B_DCC3	SEC
	SBC #$01	; set pointer
	PHA
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	JSR S_D10D	; write zero in buffer
	PLA		; second byte = pointer to end
	JSR S_D10D	; write in buffer
	JSR S_D1D7	; write block to disk
	JSR S_D6EC	; and verify
	JMP S_CFD4	; change buffer
	;
	; Directory entry
	;
S_DCDC	LDX zp7B	; channel number
	STX V_0270	; save
	LDA zp7C	; secondary address
	PHA		; save
	LDA V_0260,X	; sector number in directory
	STA zp7A	; set
	LDA V_0266,X	; pointer in directory
	STA V_0294
	LDA zpED,X
	AND #$01
	STA zp78	; drive number
	LDA V_F0C3	; 18, directory track
	STA zp79	; set
	JSR S_E0CE	; increment buffer number
	PHA
	STA zp98
	JSR S_D5B3	; read directory block
	LDY #$00
	LDA V_F123,X	; buffer address
	STA zp7F+1
	LDA V_0294	; buffer pointer
	STA zp7F
	LDA (zp7F),Y	; file type
	AND #$20	; file closed?
	BEQ B_DD58	; yes
	JSR S_D235	; check file type
	CMP #$04	; rel-file?
	BEQ L_DD60	; yes
	LDA (zp7F),Y
	AND #$8F	; erase bits 4,5, and 6
	STA (zp7F),Y	; in file type
	INY
	LDA (zp7F),Y	; track number
	STA zp79
	STY zp70
	LDY #$1B
	LDA (zp7F),Y	; sector number of the file for
	PHA		; overwriting
	DEY
	LDA (zp7F),Y	; track number for overwriting
	BNE B_DD3D	; set?
	STA zp79	; set track number
	PLA
	STA zp7A	; sector number
	LDA #$67
	JSR S_E781	; 67, 'illegal track or sector'
B_DD3D	PHA
	LDA #$00
	STA (zp7F),Y	; erase track number
	INY
	STA (zp7F),Y	; and sector number of the
	PLA		; substitute file
	LDY zp70
	STA (zp7F),Y
	INY		; set track & sector number of the new file
	LDA (zp7F),Y
	STA zp7A
	PLA
V_DD50	STA (zp7F),Y
	JSR S_C95E	; erase all files
	JMP L_DD60
	;
B_DD58	LDA (zp7F),Y	; get file type
	AND #$0F	; isolate bits 0-3
	ORA #$80	; set bit 7 for closed file
	STA (zp7F),Y
L_DD60	LDX V_0270	; channel number
	LDY #$1C	; block number lo
	LDA zpB6,X	; in directory entry
	STA (zp7F),Y
	INY
	LDA zpBC,X	; and block number hi
	STA (zp7F),Y	; write
	PLA		; buffer number
	TAX
	LDA #$90	; code for 'writing'
	ORA zp78
	JSR S_D6E3	; write block
	PLA
	STA zp7C	; secondary address
	JMP S_D217	; open channel for writing
	;
	; Read block, allocate buffer
	;
S_DD7D	LDA #$01
	JSR S_D338	; find channel and buffer for read
	JSR S_DDED	; set pointer
	LDA V_024A	; file type
	PHA		; save
	ASL A
	ORA zp78	; drive number
	STA zpED,X
	JSR S_D1AB	; read block in buffer
	LDX zp7B	; channel number
	LDA zp79	; track
	BNE B_DD9C	; following track?
	LDA zp7A	; sector
	STA V_0244,X	; as end pointer
B_DD9C	PLA		; file type
	CMP #$04	; rel-file?
	BNE B_DDE0	; no
	LDY zp7C	; secondary address
	LDA V_022B,Y	; channel number
	ORA #$40
	STA V_022B,Y	; set flag for READ and WRITE
	LDA V_0258	; record length
	STA zpC8,X
	JSR S_D3E4	; find buffer for side-sector
	BPL B_DDB8	; found?
	JMP L_D365	; 70, 'no channel'
	;
B_DDB8	LDX zp7B	; channel number
	STA zpCE,X
	LDY V_0259
	STY zp79	; track for side-sector
	LDY V_025A
	STY zp7A	; sector for side-sector
	JSR S_D808	; transmit parameters to disk controller
	JSR S_DFAE	; read block
	JSR S_D6EC	; and verify
L_DDCF	LDX zp7B	; channel number
	LDA #$02
	STA zpC2,X	; pointer for writing
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	JSR S_E28E	; find next record
	JMP S_DF79	; get track and sector number
	;
B_DDE0	JSR S_D271	; get byte from buffer
	LDX zp7B	; channel number
	STA V_023E,X	; byte in output register
	LDA #$88	; set flag for READ
	STA zpF3,X
	RTS

;$DDED  -------- Reset pointer

S_DDED	LDX zp7B	; channel number
	LDA zpA8,X	; buffer number
	ASL A		; times 2
	BMI B_DDFA
	TAY
	LDA #$02
	STA $009A,Y	; buffer pointer lo
B_DDFA	LDA zpAF,X
	ORA #$80	; set bit 7
	STA zpAF,X
	ASL A
	BMI B_DE09
	TAY
	LDA #$02
	STA $009A,Y	; buffer pointer lo
B_DE09	LDA #$00
	STA zpB6,X	; block number lo
	STA zpBC,X	; block number hi
	LDA #$00
	STA V_0244,X	; end pointer
	RTS

;$DE15  -------- Construct a new block

L_DE15	JSR S_F014	; find free sector in BAM
	LDA #$01
	JSR S_D335	; open channel
	JSR S_D805	; transmit parameter to disk controller
	JSR S_DDED	; reset pointer
	LDX zp7B	; channel number
	LDA V_024A	; file type
	PHA
	ASL A
	ORA zp78	; drive number
	STA zpED,X	; save as flag
	PLA
	CMP #$04	; rel-file?
	BEQ B_DE38	; yes
	LDA #$01
	STA zpF3,X	; set WRITE flag
	RTS
;$DE38  --------
B_DE38	LDY zp7C	; secondary address
	LDA V_022B,Y	; channel number in table
	AND #$3F	; erase the top two bits
	ORA #$40	; set bit 6
	STA V_022B,Y	; READ and WRITE flag
	LDA V_0258	; record length
	STA zpC8,X	; in table
	JSR S_D3E4	; find buffer
	BPL B_DE51	; found?
	JMP L_D365	; 70, 'no channel'
	;
B_DE51	LDX zp7B	; channel number
	STA zpCE,X	; buffer number for side-sector
	JSR S_DFFC	; erase buffer
	JSR S_EF89	; find free block in BAM
	LDA zp79	; track
	STA V_0259	; for side-sector
	LDA zp7A	; sector
	STA V_025A	; for side-sector
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	JSR S_D808	; transmit parameter to disk controller
	LDA #$00
	JSR S_E024	; buffer pointer to zero
	LDA #$00
	JSR S_DEC8
	LDA #$11	; 17
	JSR S_DEC8	; as end pointer in buffer
	LDA #$00	; zero
	JSR S_DEC8	; as side-sector number in buffer
	LDA V_0258	; record length
	JSR S_DEC8	; in buffer
	LDA zp79	; track number of this block
	JSR S_DEC8	; in buffer
	LDA zp7A	; sector number
	JSR S_DEC8	; in buffer
	LDA #$10	; 16
	JSR S_E024	; buffer pointer to 16
	JSR S_DF79	; get track and sector number
	LDA zp79	; track number of the first data block
	JSR S_DEC8	; in buffer
	LDA zp7A	; sector number of the first data block
	JSR S_DEC8	; in buffer
	JSR S_DFA7	; write block to disk
	JSR S_D6EC	; and check
	LDA #$02
	JSR S_D61B	; buffer pointer to 2
	LDX zp7B	; channel number
	SEC
	LDA #$00
	SBC zpC8,X	; record length
	STA zpC2,X	; pointer for writing
	JSR S_E41D	; erase buffer
	JSR S_DF54	; write link bytes in buffer
	JSR S_DF99	; write block to disk
	JSR S_D6EC	; and check
	JSR S_ED5F	; write BAM
	JMP L_DDCF	; and done
	;
	; Write byte in side-sector block
	;
S_DEC8	PHA		; save byte
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number of the side-sector
	JMP B_D119	; write byte in buffer
	;
	; Manipulate flags
	;
	BCC B_DED8
L_DED2	LDX zp7B	; channel number
	ORA zpED,X	; set flag
	BNE B_DEDE
B_DED8	LDX zp7B	; channel number
	EOR #$FF
	AND zpED,X	; erase flag
B_DEDE	STA zpED,X
	RTS
;$DEE1  --------
S_DEE1	LDX zp7B	; channel number
	AND zpED,X	; test flag
	RTS

;$DEE6  -------- Verify command code for writing

S_DEE6	JSR S_E0CE	; get buffer number
	TAX
	LDA V_025B,X
	AND #$F0	; isolate command code
	CMP #$90	; code for writing?
	RTS
;$DEF2  --------
S_DEF2	LDX #$00
B_DEF4	STX zp70	; counter for secondary address
	LDA V_022B,X	; get channel number from table
	CMP #$FF
	BNE B_DF05	; file open?
B_DEFD	LDX zp70
	INX		; increment counter
	CPX #$10	; smaller than 16?
	BCC B_DEF4
	RTS
;$DF05  --------
B_DF05	STX zp70
	AND #$3F	; isolate channel number
	TAY
	LDA $00ED,Y
	AND #$01	; isolate drive number
	STA zp6E+1
	LDX V_0253
	LDA zpE3,X
	AND #$01	; isolate drive number
	CMP zp6E+1	; same drive?
	BNE B_DEFD	; no
	LDA V_0260,Y	; sector number in directory
	CMP zpD9,X	; same as file?
	BNE B_DEFD	; no
	LDA V_0266,Y
	CMP zpDE,X	; pointer same?
	BNE B_DEFD	; no
	CLC
	RTS

;$DF2C  -------- Write a block of a REL file

S_DF2C	JSR S_E0D9	; get buffer number
	BVC B_DF37	; no rel-file?
	JSR S_DF99	; write block
	JSR S_D6EC	; and verify
B_DF37	RTS

;$DF38  -------- Write bytes for following track

S_DF38	JSR S_DF66	; set buffer pointer
	LDA zp79	; track number
	STA (zp8D),Y	; in buffer
	INY
	LDA zp7A	; sector number
	STA (zp8D),Y	; in buffer
	JMP S_E240	; set rel-flag
	;
	; Get following track and sector numbers
	;
S_DF47	JSR S_DF66	; set buffer pointer
	LDA (zp8D),Y	; following track number
	STA zp79
	INY
	LDA (zp8D),Y	; and get sector number
	STA zp7A
	RTS

;$DF54  -------- Following track for last block

S_DF54	JSR S_DF66	; set buffer pointer
	LDA #$00	; zero
	STA (zp8D),Y	; as track number
	INY
	LDX zp7B	; channel number
	LDA zpC2,X	; pointer in block
	TAX
	DEX		; minus 1
	TXA
	STA (zp8D),Y	; as pointer in block
	RTS
;$DF66  -------- buffer pointer to zero
S_DF66	JSR S_E0CE	; get buffer number
	ASL A		; times 2
	TAX
	LDA zp9B,X	; buffer pointer hi
	STA zp8D+1
	LDA #$00
	STA zp8D	; buffer pointer lo
	LDY #$00
	RTS

;$DF76  -------- Get track and sector

S_DF76	JSR S_D1FB	; get channel number
S_DF79	JSR S_E0CE	; get buffer number
	STA zp98	; save
	ASL A		; times 2
	TAY
	LDA $0008,Y	; get track
	STA zp79
	LDA $0009,Y	; and sector number from disk controller
	STA zp7A
	RTS

;$DF8B  -------- Write

S_DF8B	LDA #$90	; command code for writing
	STA V_024D
	BNE B_DFBA	; jump always

;       --------- Read

S_DF92	LDA #$80	; command code for reading
	STA V_024D
	BNE B_DFBA	; jump always
	; Write
S_DF99	LDA #$90	; command code for writing
	STA V_024D
	BNE B_DFC6	; jump always
	; Read
	LDA #$80	; command code for reading
	STA V_024D
	BNE B_DFC6	; jump always
	; Write
S_DFA7	LDA #$90	; command code for writing
	STA V_024D
	BNE B_DFB0	; jump always
	; Read
S_DFAE	LDA #$80	; command code for reading
B_DFB0	STA V_024D
	LDX zp7B	; channel number
	LDA zpCE,X	; side-sector buffer number
	TAX
	BPL B_DFCD	; buffer associated?
B_DFBA	JSR S_D805	; generate header for disk controller
	JSR S_E0CE	; get buffer number
	TAX
	LDA zp78	; drive number
	STA V_025B,X
B_DFC6	JSR S_E250	; buffer number
	JSR S_E0CE	; get buffer number
	TAX
B_DFCD	JMP L_D659	; write block
	;
	; Get following track and sector from buffer
	;
S_DFD0	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	JSR S_D247	; get byte
	STA zp79	; save as track
	JSR S_D247	; get byte
	STA zp7A	; as sector
	RTS

;$DFE0  -------- Copy buffer contents

S_DFE0	PHA
	LDA #$00
	STA zp6E
	STA zp70
	LDA V_F123,Y	; buffer address Y, hi
	STA zp6E+1
	LDA V_F123,X	; buffer address X, lo
	STA zp70+1
	PLA
	TAY
	DEY
B_DFF4	LDA (zp6E),Y
	STA (zp70),Y
	DEY
	BPL B_DFF4
	RTS

;$DFFC  -------- Erase buffer Y

S_DFFC	TAY		; buffer number
	LDA V_F123,Y	; get hi-address
	STA zp6E+1
	LDA #$00	; lo-address
	STA zp6E
	TAY
B_E007	STA (zp6E),Y	; erase buffer
	INY
	BNE B_E007
	RTS

;$E00D  -------- Get side-sector number

S_E00D	LDA #$00
	JSR S_E017	; buffer pointer to zero
	LDY #$02
	LDA (zp8D),Y	; byte 2 contains the side-sector number
	RTS
;$E017  -------- Set buffer pointer to side-sector
S_E017	STA zp8D	; printer lo
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	TAX
	LDA V_F123,X	; buffer address hi
	STA zp8D+1	; set
	RTS
;$E024  -------- Buffer pointer for side-sector
S_E024	PHA		; pointer in side-sector
	JSR S_E017	; set buffer pointer
	PHA
	TXA		; buffer number
	ASL A		; times 2
	TAX
	PLA
	STA zp9B,X	; buffer pointer hi
	PLA
	STA zp9A,X	; buffer pointer lo
	RTS

;$E033  -------- Get side sector and buffer pointer

S_E033	JSR S_E0A1	; is side-sector in buffer?
	BMI B_E046	; no
	BVC B_E04D	; ok
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	JSR S_E056	; read side-sector
	JSR S_E0A1	; and check if in buffer
	BPL B_E04D	; yes?
B_E046	JSR S_E306	; get last side-sector
	BIT V_F10E + 1	; set V bit
	RTS
;$E04D  --------
B_E04D	LDA zp93	; side-sector and pointer
	JSR S_E024	; set pointer in side-sector
	BIT V_F10E	; erase V bit
	RTS

;$E056  -------- Read side-sector

S_E056	STA zp98	; buffer number
	LDA #$80	; command code for reading
	BNE B_E060
	; Write side-sector
	STA zp98	; buffer number
	LDA #$90	; command code for writing
B_E060	PHA
	LDA zpED,X
	AND #$01	; isolate drive number
	STA zp78
	PLA
	ORA zp78	; command code plus drive number
	STA V_024D	; save
	LDA (zp8D),Y	; track number
	STA zp79
	INY
	LDA (zp8D),Y	; sector number
	STA zp7A
	LDA zp98	; buffer number
	JSR S_D808	; transmit parameter to disk controller
	LDX zp98	; buffer number
	JMP L_D6E6	; transmit command to disk controller
	;
	; Set buffer pointer in side-sector
	;
S_E080	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	JMP L_D63E	; set buffer pointer
	;
	; Calculate number of blocks in a REL file
	;
B_E087	LDA #$78	; 120 block pointers per side-sector
	JSR S_E097	; add to $6f/$70
S_E08C	DEX		; side-sector number
	BPL B_E087	; next side-sector?
	LDA zp70+1	; pointer value in last block
	LSR A		; divided by 2
	JSR S_E097	; add to previous sum
	LDA zp72	; number of the side-sector block
S_E097	CLC
	ADC zp6E+1
	STA zp6E+1	; add
	BCC B_E0A0
	INC zp70
B_E0A0	RTS

;$E0A1  -------- Verify side-sector in buffer

S_E0A1	JSR S_E00D	; get side-sector number
	CMP zp92	; = number of necessary block?
	BNE B_E0B6	; no
	LDY zp93	; pointer in side-sector
	LDA (zp8D),Y	; track number
	BEQ B_E0B2
	BIT V_F10E	; erase bits
	RTS
;$E0B2  --------
B_E0B2	BIT V_F10E + 2	; set N-bit
	RTS
;$E0B6  --------
B_E0B6	LDA zp92	; side-sector number
	CMP #$06	; 6 or greater?
	BCS B_E0C6	; yes
	ASL A
	TAY
	LDA #$04
	STA zp8D
	LDA (zp8D),Y	; track number
	BNE B_E0CA
B_E0C6	BIT V_F111	; set N and V bits
	RTS
;$E0CA  --------
B_E0CA	BIT V_F10E + 1	; set V bit
	RTS

;$E0CE  -------- Get buffer number

S_E0CE	LDX zp7B	; channel number
	LDA zpA8,X	; buffer number
	BPL B_E0D6
	LDA zpAF,X	; buffer number from second table
B_E0D6	AND #$BF	; erase V bit
	RTS
;$E0D9  --------
S_E0D9	LDX zp7B	; channel number
	STX V_0257	; save
	LDA zpA8,X	; get buffer number
	BPL B_E0EB	; buffer allocated
	TXA
	CLC
	ADC #$07	; increment number by 7
	STA V_0257	; and save
	LDA zpAF,X	; buffer number from table 2
B_E0EB	STA zp6E+1
	AND #$1F	; erase the highest 3 bits
	BIT zp6E+1
	RTS
;$E0F2  --------
S_E0F2	LDX zp7B	; channel number
	LDA zpA8,X	; buffer number
	BMI B_E0FA	; buffer free?
	LDA zpAF,X	; buffer number from table 2
B_E0FA	CMP #$FF	; free?
	RTS
;$E0FD  --------
S_E0FD	LDX zp7B
	ORA #$80
	LDY zpA8,X
	BPL B_E108
	STA zpA8,X
	RTS
;$E108  --------
B_E108	STA zpAF,X
	RTS

;$E10B  -------- Get next record in REL file

S_E10B	LDA #$20
	JSR B_DED8	; erase bit 5
	LDA #$80
	JSR S_DEE1	; test bit 7
	BNE B_E158	; set?
	LDX zp7B	; channel number
	INC zpB6,X	; increment record number
	BNE B_E11F
	INC zpBC,X	; record number hi
B_E11F	LDX zp7B	; channel number
	LDA zpC2,X	; write pointer
	BEQ B_E153	; zero?
	JSR S_D63B	; set buffer pointer
	LDX zp7B	; channel number
	CMP zpC2,X	; buffer pointer smaller than write pointer
	BCC B_E131	; yes
	JSR S_E177	; write block, read next block
B_E131	LDX zp7B	; channel number
	LDA zpC2,X	; write pointer
	JSR S_D61B	; set buffer pointer = write pointer
	LDA (zp9A,X)	; byte from buffer
	STA zp7E	; put in output register
	LDA #$20
	JSR B_DED8	; erase bit 5
	JSR S_E43F	; add record length to write pointer
S_E144	PHA		; and save
	BCC B_E16F	; not yet in last block?
	LDA #$00
	JSR S_D649	; get track number
	BNE B_E16F	; does block exist?
	PLA		; pointer
	CMP #$02	; = 2
	BEQ B_E165	; yes
B_E153	LDA #$80
	JSR L_DED2	; set bit 7
B_E158	JSR S_D23F	; get byte from buffer
	LDA zp9A,X	; buffer pointer
	STA V_0244,Y	; as end pointer
	LDA #$0D	; CR
	STA zp7E	; in output register
	RTS
;$E165  --------
B_E165	JSR S_E170
	LDX zp7B	; channel number
	LDA #$00
	STA zpC2,X	; write pointer to zero
	RTS
;$E16F  --------
B_E16F	PLA
S_E170	LDX zp7B	; channel number
	STA zpC2,X	; set write pointer
	JMP L_E2A9
	;
	; Write block and read next block
	;
S_E177	JSR S_D329	; get drive number
	JSR S_DFD0	; get track and sector number
	JSR S_E0D9	; get bufer number
	BVC B_E198	; no rel-file?
	JSR S_DF99	; write block
	JSR S_CFD4	; change buffer
	LDA #$02
	JSR S_D61B	; buffer pointer to 2
	JSR S_DEE6	; command code for writing?
	BNE B_E1B6	; no
	JSR S_DF92	; read block
	JMP S_D6EC	; and verify
	;
B_E198	JSR S_CFD4	; change buffer
	JSR S_DEE6	; command code for writing?
	BNE B_E1A6	; no
	JSR S_DF92	; read block
	JSR S_D6EC	; and verify
B_E1A6	JSR S_DFD0	; get track and sector number
	LDA zp79	; track
	BEQ B_E1B6	; no following track
	JSR S_CFD4	; change buffer
	JSR S_DF92	; read block
	JSR S_CFD4	; change buffer
B_E1B6	RTS

;$E1B7  -------- Write a byte in a record

S_E1B7	JSR S_E240
	JSR S_E0CE	; get buffer number
	ASL A		; * 2
	TAX		; as index
	LDA zp7E	; data byte
	STA (zp9A,X)	; write in buffer
	LDY zp9A,X	; buffer pointer
	INY		; increment
	BNE B_E1D1	; not equal zero?
	LDY zp7B	; channel number
	LDA $00C2,Y	; write pointer
	BEQ B_E1D9	; equal zero?
	LDY #$02	; buffer pointer to 2
B_E1D1	TYA
	LDY zp7B	; channel number
	CMP $00C2,Y	; buffer pointer = write pointer?
	BNE B_E1DE	; no
B_E1D9	LDA #$20
	JMP L_DED2	; set bit 5
	;
B_E1DE	INC zp9A,X	; increment buffer pointer
	BNE B_E1E5	; not zero?
	JSR S_E177	; else write block, read next one
B_E1E5	RTS

;$E1E6  -------- Write byte in REL file

L_E1E6	LDA #$A0
	JSR S_DEE1	; test bits 6 & 7
	BNE B_E214	; set?
L_E1ED	LDA zp7E	; data byte
	JSR S_E1B7	; write in record
	LDA zp95	; end?
	BEQ B_E203	; yes
	RTS
;$E1F7  --------
B_E1F7	LDA #$20
	JSR S_DEE1	; test bit 5
	BEQ B_E203	; not set
	LDA #$51	; 51, 'overflow in record'
	STA V_026C	; set error flag
B_E203	JSR L_E22E	; fill remainder with zeroes
	JSR S_E28E
	LDA V_026C	; error flag set?
	BEQ B_E211	; no
	JMP L_C2B2	; set error message
	;
B_E211	JMP L_E7FB	; error free execution
	;
B_E214	AND #$80	; bit 7 set?
	BNE B_E21D	; yes
	LDA zp95
	BEQ B_E1F7	; end?
	RTS
;$E21D  --------
B_E21D	LDA zp7E	; data byte
	PHA
	JSR S_E457	; expand side-sector
	PLA
	STA zp7E
	LDA #$80
	JSR B_DED8	; erase bit 7
	JMP L_E1ED	; write byte in file
	;
	; Fill record with 0s
	;
L_E22E	LDA #$20
	JSR S_DEE1	; test bit 5
	BNE B_E23F	; set?
	LDA #$00
	STA zp7E	; zero as data byte
	JSR S_E1B7	; write in record
	JMP L_E22E	; until record full
	;
B_E23F	RTS

;$E240  -------- Write buffer number in table

S_E240	LDA #$40
	JSR L_DED2	; set bit 6
	JSR S_E0D9	; get buffer number
	ORA #$40	; set bit 6
	LDX V_0257	; channel number + 7
	STA zpA8,X	; write in table
	RTS
;$E250  --------
S_E250	JSR S_E0D9	; get buffer number
	AND #$BF	; erase bit 6
	LDX V_0257	; channel number
	STA zpA8,X	; write in table
	RTS
;$E25B  -------- Get byte from REL file
L_E25B	LDA #$80
	JSR S_DEE1	; test bit 7
	BNE L_E299	; set?
	JSR S_D23F	; get byte from buffer
	LDA zp9A,X	; buffer pointer
	CMP V_0244,Y	; compare to end pointer
	BEQ S_E28E	; equal?
	INC zp9A,X	; increment buffer pointer
	BNE B_E276	; not zero?
	JSR S_E177	; write block, read next one
L_E273	JSR S_D23F	; get byte from buffer
B_E276	LDA (zp9A,X)
L_E278	STA V_023E,Y	; in output register
	LDA #$89
	STA $00F3,Y	; set READ and WRITE flag
	LDA zp9A,X	; buffer pointer
	CMP V_0244,Y	; compare to end pointer
	BEQ B_E288	; same?
	RTS
;$E288  --------
B_E288	LDA #$81
	STA $00F3,Y	; set flag for end
	RTS
;$E28E  --------
S_E28E	JSR S_E10B	; find next record
	JSR S_D23F	; get buffer and channel number
	LDA zp7E	; data byte
	JMP L_E278	; into output register
	;
L_E299	LDX zp7B	; channel number
	LDA #$0D	; CR
	STA V_023E,X	; into output register
	LDA #$81
	STA zpF3,X	; set flag for end
	LDA #$50
	JSR L_C2B2	; 50, 'record not present'
L_E2A9	LDX zp7B	; channel number
	LDA zpC2,X	; write pointer
	STA zp7F+1	; save
	DEC zp7F+1
	CMP #$02	; equal 2?
	BNE B_E2B9	; no
	LDA #$FF
	STA zp7F+1
B_E2B9	LDA zpC8,X	; record length
	STA zp81
	JSR S_D63B	; set buffer pointer
	LDX zp7B	; channel number
	CMP zp7F+1	; buffer pointer > write pointer?
	BCC B_E2DF
	BEQ B_E2DF	; no
	JSR S_CFD4	; change buffer
	JSR S_E2ED
	BCC B_E2D8
	LDX zp7B	; channel number
	STA V_0244,X
	JMP S_CFD4	; change buffer
	;
B_E2D8	JSR S_CFD4	; change buffer
	LDA #$FF
	STA zp7F+1
B_E2DF	JSR S_E2ED
	BCS B_E2E7
	JSR S_D63B	; set buffer pointer
B_E2E7	LDX zp7B	; channel number
	STA V_0244,X	; end pointer
	RTS
;$E2ED  --------
S_E2ED	JSR S_DF66	; buffer pointer to zero
	LDY zp7F+1
B_E2F2	LDA (zp8D),Y	; byte from buffer
	BNE B_E303	; not zero?
	DEY
	CPY #$02
	BCC B_E2FF
	DEC zp81
	BNE B_E2F2
B_E2FF	DEC zp81
	CLC
	RTS
;$E303  --------
B_E303	TYA
	SEC
	RTS

;$E306  -------- Get last side-sector

S_E306	JSR S_E00D	; get number of the side-sector
	STA zp92	; save
	LDA #$04
	STA zp8D	; pointer to side-sectors
	LDY #$0A
	BNE B_E317
B_E313	DEY
	DEY
	BMI B_E33D
B_E317	LDA (zp8D),Y	; track number of the previous block
	BEQ B_E313
	TYA
	LSR A		; divide by 2
	CMP zp92	; = number of the actual block?
	BEQ B_E32A	; yes
	STA zp92	; else save all numbers
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	JSR S_E056	; read block
B_E32A	LDY #$00
	STY zp8D	; buffer pointer
	LDA (zp8D),Y	; track number
	BNE B_E33D	; another block?
	INY
	LDA (zp8D),Y	; sector number = end pointer
	TAY
	DEY
	STY zp93	; save end pointer
	TYA
	JMP S_E024	; set buffer pointer
	;
B_E33D	LDA #$67
	JSR S_E781	; 67, 'illegal track or sector'
	;
	; Perform [P] - Position command
	;
	JSR S_C39D	; verify lines
	LDA L_0201	; secondary address
	STA zp7C
	JSR S_D1FB	; find channel number
	BCC B_E354	; found?
	LDA #$70
	JSR L_C2B2	; 70, 'no block'
B_E354	LDA #$A0
	JSR B_DED8	; erase bits 6 & 7
	JSR S_D235	; verify if 'REL'-file
	BEQ B_E363	; yes
	LDA #$64
	JSR L_C2B2	; 64, 'file type mismatch'
B_E363	LDA zpED,X
	AND #$01
	STA zp78	; drive number
	LDA V_0202	; record number lo
	STA zpB6,X
	LDA V_0203	; record number hi
	STA zpBC,X
	LDX zp7B	; channel number
	LDA #$89
	STA zpF3,X	; READ and WRITE flag
	LDA V_0204	; byte-pointer
	BEQ B_E38E	; zero?
	SEC
	SBC #$01
	BEQ B_E38E
	CMP zpC8,X	; compare with record length
	BCC B_E38E
	LDA #$51
	STA V_026C	; 51, 'overflow in record'
	LDA #$00
B_E38E	STA zp91
	JSR S_CEFD	; calculate pointer in rel-file
	JSR S_E033	; and read appropriate side-sector
	BVC B_E3A0	; does block exist?
	LDA #$80
	JSR L_DED2	; set bit 7
	JMP L_E299	; and 50, 'record not present'
	;
B_E3A0	JSR L_E3B0
	LDA #$80
	JSR S_DEE1	; test bit 7
	BEQ B_E3AD	; not set
	JMP L_E299	; 50, 'record not present'
	;
B_E3AD	JMP L_C27E	; done
	;
L_E3B0	JSR S_E3D7
	LDA zp94	; pointer in rel-file
	JSR S_D61B	; set buffer pointer
	LDX zp7B	; channel number
	LDA zpC8,X	; record length
	SEC
	SBC zp91	; minus position
	BCS B_E3C4	; positive?
	JMP B_E33D	; 67, 'illegal track or sector'
	;
B_E3C4	CLC
	ADC zp94	; add pointer in data block
	BCC B_E3CC	; no overflow
	ADC #$01	; plus 2
	SEC
B_E3CC	JSR S_E144	; set pointer
	JMP L_E273	; get byte from buffer
	;
	LDA #$51
	JSR L_C2B2	; 51, 'overflow in record'
S_E3D7	LDA zp8D	; buffer pointer lo
	STA zp81+1
	LDA zp8D+1	; buffer pointer hi
	STA zp82+1
	JSR S_E40B	; compare track and sector
	BNE B_E3E5	; not equal?
	RTS
;$E3E5  --------
B_E3E5	JSR S_DF2C
	JSR S_DF47
	LDA zp79	; track
	BEQ B_E3FD	; no block following?
	JSR S_E40E	; compare track and sector number
	BNE B_E3FA	; not equal?
	JSR S_CFD4	; change buffer
	JMP L_D42C
	;
B_E3FA	JSR L_D42C
B_E3FD	LDY #$00
	LDA (zp81+1),Y	; track
	STA zp79
	INY
	LDA (zp81+1),Y	; and sector of the next block
	STA zp7A
	JMP L_D1BF	; read block
	;
S_E40B	JSR S_DF79
S_E40E	LDY #$00
	LDA (zp81+1),Y	; track number
	CMP zp79	; compare
	BEQ B_E417
	RTS
;$E417  --------
B_E417	INY
	LDA (zp81+1),Y	; sector number
	CMP zp7A	; compare
	RTS

;$E41D  -------- Divide data blocks into records

S_E41D	JSR S_DF66	; set buffer pointer
	LDY #$02
	LDA #$00
B_E424	STA (zp8D),Y	; erase buffer
	INY
	BNE B_E424
	JSR S_E43F	; set pointer to next record
B_E42C	STA zpC2,X
	TAY
	LDA #$FF
	STA (zp8D),Y	; $FF as 1st character in record
	JSR S_E43F	; set pointer to next record
	BCC B_E42C	; done in this block?
	BNE B_E43E	; block full?
	LDA #$00
	STA zpC2,X	; write pointer to zero
B_E43E	RTS

;$E43F  -------- Set pointer to next record

S_E43F	LDX zp7B	; channel number
	LDA zpC2,X	; write pointer
	SEC
	BEQ B_E453	; equal zero?
	CLC
	ADC zpC8,X	; add record length
	BCC B_E456	; smaller than 256?
	BNE B_E453	; equal 256?
	LDA #$02
	BIT V_F10D
	RTS
;$E453  --------
B_E453	ADC #$01	; add two
	SEC
B_E456	RTS

;$E457  -------- Expand side-sector

S_E457	JSR S_D329	; get drive number
	JSR S_E306	; get last side-sector
	JSR S_E3D7
	JSR S_D09A
	LDA zp93
	STA zp7F+1
	LDA zp92	; side-sector number
	STA zp7F
	LDA #$00
	STA zp81
	LDA #$00
	STA zp91
	JSR S_CEFD	; calculate side-sector number and pointer
L_E476	JSR S_EDB8	; number of free blocks
	LDY zp7B	; channel number
	LDX zpC8,Y	; record length
	DEX
	TXA
	CLC
	ADC zp94	; plus pointer in data block
	BCC B_E490
	INC zp93
	INC zp93	; increment pointer to end by 2
	BNE B_E490
	INC zp92	; increment side-sector number
	LDA #$10
	STA zp93	; set pointer to 16
B_E490	LDA zp7F+1
	CLC
	ADC #$02
	JSR S_E024	; set buffer pointer for side-sector
	LDA zp92	; side-sector number
	CMP #$06
	BCC B_E4A3	; smaller than 6?
B_E49E	LDA #$52
	JSR L_C2B2	; 52, 'file too large'
B_E4A3	LDA zp93	; end pointer
	SEC
	SBC zp7F+1	; minus last end pointer
	BCS B_E4AD
	SBC #$0F	; minus 16
	CLC
B_E4AD	STA zp70+1
	LDA zp92	; side-sector number
	SBC zp7F	; minus last side-sector number
	STA zp72	; save
	LDX #$00
	STX zp6E+1	; erase sum for calculation
	STX zp70
	TAX
	JSR S_E08C	; calculate block # of rel-file
	LDA zp70
	BNE B_E4CA
	LDX zp6E+1
	DEX
	BNE B_E4CA
	INC zp81
B_E4CA	CMP V_0273	; block number of rel-file
	BCC B_E4D8	; greater than free blocks on disk?
	BNE B_E49E	; 52, 'file too large'
	LDA V_0272
	CMP zp6E+1
	BCC B_E49E	; 52, 'file too large'
B_E4D8	LDA #$01
	JSR S_D649	; get byte from buffer
	CLC
	ADC #$01	; plus 1
	LDX zp7B
	STA zpC2,X	; as write pointer
	JSR S_EF89	; find free block in BAM
	JSR S_DF38	; track and sector in buffer
	LDA zp81
	BNE B_E503	; only one block needed?
	JSR S_DF99	; write block
B_E4F1	JSR S_CFD4	; change buffer
	JSR S_D805	; transmit parameter to disk controller
	JSR S_EF89	; find free block in BAM
	JSR S_DF38	; track and sector in buffer
	JSR S_E41D	; erase buffer
	JMP L_E50F
	;
B_E503	JSR S_CFD4	; change buffer
	JSR S_D805	; transmit parameter to disk controller
	JSR S_E41D	; erase buffer
	JSR S_DF54	; zero byte and end pointer in buffer
L_E50F	JSR S_DF99	; write block
	JSR S_DF47	; get track and sector
	LDA zp79	; track
	PHA
	LDA zp7A	; and sector
	PHA		; save
	JSR S_DF79	; get track and sector from disk
	LDA zp7A	; controller
	PHA
	LDA zp79	; save track and sector
	PHA
	JSR S_E080	; set buffer pointer for side-sector
	TAX
	BNE B_E534	; pointer not zero?
	JSR S_E589	; write side-sector
	LDA #$10
	JSR S_E024	; buffer pointer to 16
	INC zp7F	; increment side-sector number
B_E534	PLA
	JSR S_DEC8	; track in side-sector
	PLA
	JSR S_DEC8	; sector in side-sector
	PLA
	STA zp7A	; sector
	PLA
	STA zp79	; and get track back
	BEQ B_E553	; no more blocks?
	LDA zp7F	; side-sector number
	CMP zp92	; changed?
	BNE B_E4F1	; yes
	JSR S_E080	; set buffer pointer in side-sector
	CMP zp93	; end pointer
	BCC B_E4F1	; smaller?
	BEQ B_E503	; same
B_E553	JSR S_E080	; set buffer pointer in side-sector
	PHA
	LDA #$00
	JSR S_E017	; buffer pointer to zero
	LDA #$00
	TAY
	STA (zp8D),Y	; zero as track number
	INY
	PLA		; end pointer
	SEC
	SBC #$01	; minus one
	STA (zp8D),Y	; as sector
	JSR S_DFA7	; write block
	JSR S_D6EC	; and verify
	JSR S_ED5F	; update BAM
	JSR S_CEFD	; update pointer for rel-file
	JSR S_CFD4	; change buffer
	JSR S_E033	; right side-sector?
	BVS B_E57F	; no
	JMP L_E3B0
	;
B_E57F	LDA #$80
	JSR L_DED2	; set bit 7
	LDA #$50
	JSR L_C2B2	; 50, 'record not present'
	;
	; Write side-sector and allocate new
	;
S_E589	JSR S_EF89	; find free block in BAM
	JSR S_CFD4	; change buffer
	JSR S_DF2C	; write block
	JSR S_E0CE	; get buffer number
	PHA
	JSR S_DFFC	; erase buffer
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number
	TAY
	PLA
	TAX
	LDA #$10	; 16 bytes of the side-sector
	JSR S_DFE0	; copy in buffer
	LDA #$00
	JSR S_E017	; buffer pointer to 0, old side-sector
	LDY #$02
	LDA (zp8D),Y	; side-sector number
	PHA
	LDA #$00
	JSR S_D61B	; buffer pointer to 0, new side-sector
	PLA
	CLC
	ADC #$01	; increment side-sector number
	STA (zp8D),Y	; and in buffer
	ASL A		; times 2
	ADC #$04	; plus 4
	STA zp81+1
	TAY
	SEC
	SBC #$02	; minus 2
	STA zp82+1	; same pointer to old side-sector
	LDA zp79	; track
	STA zp7F+1
	STA (zp8D),Y	; in buffer
	INY
	LDA zp7A	; sector
	STA zp81
	STA (zp8D),Y	; in buffer
	LDY #$00
	TYA
	STA (zp8D),Y	; zero in buffer
	INY
	LDA #$11	; 17
	STA (zp8D),Y	; number of bytes in block
	LDA #$10	; 16
B_E5DE	JSR S_D61B	; buffer pointer to 16
	JSR S_DF8B	; write block
	JSR S_D6EC	; and verify
	LDX zp7B	; channel number
	LDA zpCE,X	; buffer number of the side-sector
	PHA
	JSR S_E0D9	; get buffer number
	LDX zp7B	; channel number
	STA zpCE,X	; write in table
	PLA
	LDX V_0257	; channel number + 7
	STA zpA8,X	; in table
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
	LDY #$00
	LDA zp79	; track
	STA (zp8D),Y	; in buffer
	INY
	LDA zp7A	; sector
	STA (zp8D),Y	; in buffer
	JMP L_E619
	;
B_E60C	JSR S_E0CE	; get buffer number
	LDX zp7B	; channel number
	JSR S_E056	; read block
	LDA #$00
	JSR S_D61B	; buffer pointer to zero
L_E619	DEC zp82+1
	DEC zp82+1	; counter for side-sector blocks
	LDY zp81+1
	LDA zp7F+1	; track number
	STA (zp8D),Y	; in buffer
	INY
	LDA zp81	; sector number
	STA (zp8D),Y	; in buffer
	JSR S_DF99	; write block
	JSR S_D6EC	; and verify
	LDY zp82+1	; counter for side-sector blocks
	CPY #$03
	BCS B_E60C	; greater than or equal to 3?
	JMP S_CFD4	; change buffer
	;
	; Error codes and messages
	;
	DB $00
	DB $A0,"OK"
	DB $20,$21,$22,$23,$24,$27
	DB $D2,$45,$41,$44
	DB $89
; $E646
	DB $52
; $E647
	DB $83
	DB " TOO LARGe"
	DB $50
	DB $8B
	DB $06
	DB "oVERFLOW"
	DB " IN"
	DB $8B
	DB $25,$28
	DB $8A
	DB $89
	DB $26
	DB $8A
	DB " PROTECT On"
	DB $29
	DB $88
	DB " ID"
	DB $85
	DB $30,$31,$32,$33,$34
	DB $D3,$59,$4E,$54,$41,$58 ; "Syntax"
	DB $89
	DB $60
	DB $8A
; $E68F
	DB $03
	DB $84
; $E691
	DB $63
	DB $83
	DB " EXISTs"
	DB $64
	DB $83
	DB " TYPE"
	DB $85
	DB $65
	DB "nO BLOCK"
	DB $66,$67
	DB "iLLEGAL TRACK OR SECTOR"
	DB $61
; $E6C5
	DB $83,$06
	STY zp39
; $E6C9
	DB "b"
; $E6CA
	DB $83,$06
; $E6CC
	DB $87,$01
; $E6CE
	DB $83,"S"
	JSR S_4353
; $E6D3
	DB "R"
	EOR (zp54,X)
; $E6D6
	DB "CH"
	EOR zpC4
	BVS B_E6AA
; $E6DC
	DB "O C"
	PHA
	EOR (zp4E,X)
	LSR V_CC45
B_E6E5	ADC (zpC4),Y
	EOR #$52	; "R"
; $E6E9
	DB $89,$72
	DEY
	JSR S_5546
	JMP L_73CC
	;
; $E6F2
	DB $C3,"B"
	EOR V_4420
; $E6F7
	DB "OS "
	LSR zp32,X
	ROL V_2036
; $E6FF
	DB "T"
V_E700	DB "D"
	EOR #$53	; "S"
	DB $CB,$74
	CPY zp52
	EOR #$56	; "V"
	EOR zp06
	JSR S_4552
	EOR (zp44,X)
	CMP V_C508 + 1,Y
; $E713
	DB "R"
; $E714
	DB "R"
; $E715
	DB "O",$D2,$0A
; $E718
	DB $D7,"R"
	EOR #$54	; "T"
	CMP zp03
	DEC zp49
	JMP L_04C5
	;
; $E723
	DB $CF,"PE"
	DEC V_CD05
	EOR #$53	; "S"
	EOR V_5441
; $E72E
	DB "C",$C8
	ASL zpCE
; $E732
	DB $4F,$D4,$07
	DEC zp4E+1
	EOR zp4E,X
	CPY zp08
	CPY zp49
; $E73D
	DB "S",$CB
; $E73F
	DB $0B,$D2
	EOR zp43
; $E743
	DB "OR",$C4
	;
	; Prepare error number and message
	;
L_E746	PHA		; save error code
	STX zp98	; drive number
	TXA
	ASL A		; times 2
	TAX		; as pointer
	LDA zp08,X
	STA zp79	; get track
	LDA zp09,X
	STA zp7A	; and sector number
	PLA		; get error code back
	AND #$0F	; isolate bits 0-3
	BEQ B_E761	; zero, then 24, 'read error'
	CMP #$0F	; 15?
	BNE B_E763
	LDA #$74	; 74, 'drive not ready'
	BNE B_E769	; 6
B_E761	LDA #$06
B_E763	ORA #$20	; add $20
	TAX
	DEX
	DEX		; subtract two (= 36)
	TXA
B_E769	PHA		; save error number
	LDA V_022A	; number of the disk command
	CMP #$00	; OPEN or VALIDATE?
	BNE B_E780	; no
	LDA #$FF
	STA V_022A
	PLA		; get error number back
	JSR S_E806	; generate error message
	JSR S_D15E	; load BAM
	JMP S_E784	; set error message
	;
B_E780	PLA
	;
	; Print error message into error buffer
	;
S_E781	JSR S_E806	; set error message
	;
S_E784	JSR S_C2A7	; erase input buffer
	LDA #$00
	STA V_02F9	; erase error flag
	JSR L_F3F7	; turn LED off
	JSR L_D62D	; close channels 17 and 18
	LDA #$00
	STA zpA4	; input buffer pointer to zero
	LDX #$FF
	TXS		; initialize stack pointer
	LDA zp7D	; secondary address
	AND #$0F
	STA zp7C
	CMP #$0F	; 15?
	BEQ B_E7D4	; yes, command channel
	LDA zp5C	; LISTEN active?
	BNE B_E7C4	; yes
	LDA zp5B	; TALK active?
	BNE B_E7BB	; yes
	LDX zp7C	; channel number
	LDA V_022B,X	; open channel to this secondary addr
	CMP #$FF
	BEQ B_E7D4	; no
	AND #$0F
	STA zp7B	; channel
	JMP L_E7CA
	;
	; TALK
	;
B_E7BB	JSR S_D1FB
	JSR S_C1CD
	JMP L_E7CA
	;
	; LISTEN
	;
B_E7C4	JSR S_D217
	JSR S_C1D8
	;
L_E7CA	JSR S_D235	; verify file type
	CMP #$04	; file type REL?
	BCS B_E7D4	; yes
	JSR L_D37D	; close channel
	;
B_E7D4	LDX #$FF	; reset stack pointer
	TXS
	JMP L_EABD	; jump to main loop
	;
	; Convert BIN to 2-Ascii (error message buffer)
	;
S_E7DA	TAX
	LDA #$00
	SED
L_E7DE	CPX #$00
	BEQ B_E7E9	; convert hex to BCD
	CLC
	ADC #$01
	DEX
	JMP L_E7DE
	;
B_E7E9	CLD
	;
	; Convert BCD to 2-Ascii (error message buffer)
	;
S_E7EA	TAX
	LSR A
	LSR A		; shift hi-nibble down
	LSR A
	LSR A
	JSR S_E7F3	; convert to ASCII
	TXA
S_E7F3	AND #$0F	; erase top 4 bits
	ORA #$30	; add '0'
	STA (zpA6),Y	; write in buffer
	INY		; increment buffer pointer
	RTS

;$E7FB  -------- Write OK in buffer

L_E7FB	JSR S_F3F0	; erase error flag
	LDA #$00	; error number 0
	;
	; Print error on track 00,00 to error buffer
	;
S_E800	LDY #$00
	STY zp79	; track 0
	STY zp7A	; sector 0
S_E806	LDY #$00	; buffer pointer
	LDX #$D5
	STX zpA6	; pointer $A5/$A6 to $2D5
	LDX #$02
	STX zpA6+1
	JSR S_E7EA	; error number to ASCII and in buffer
	LDA #$2C	; ',' comma
	STA (zpA6),Y	; write in buffer
	INY		; increment buffer pointer
	LDA V_02D5	; first digit of the disk status
	STA V_0243	; in output register
	TXA		; error number in accumulator
	JSR S_E845	; error message in buffer
	LDA #$2C	; ',' comma
	STA (zpA6),Y	; write in buffer
	INY		; and increment buffer pointer
	LDA zp79	; track number
	JSR S_E7DA	; to ASCII and in buffer
	LDA #$2C	; ',' comma
	STA (zpA6),Y	; write in buffer
	INY		; increment buffer pointer
	LDA zp7A	; sector
	JSR S_E7DA	; convert to ASCII and in buffer
	DEY
	TYA
	CLC
	ADC #$D5
	STA V_0249	; end pointer
	INC zpA6
	LDA #$88	; set READ flag
	STA zpF8
	RTS

;$E845  -------- Write error message string to buffer

S_E845	TAX		; error code to X
	LDA zp7F
	PHA
	LDA zp7F+1	; preserve pointer $7f/$80
	PHA
	LDA #$37
	STA zp7F
	LDA #$E6	; start of the error messages
	STA zp7F+1	; E637
	TXA		; error number in accumulator
	LDX #$00
L_E857	CMP (zp7F,X)	; compare with error number in table
	BEQ B_E87C
	PHA
	JSR S_E8B4	; bit 7 into carry and erase
	BCC B_E866	; not set?
B_E861	JSR S_E8B4	; bit 7 into carry
	BCC B_E861	; wait for character with bit 7 set
B_E866	LDA zp7F+1
	CMP #$E7
	BCC B_E874	; $E746 ...
	BNE B_E878
	LDA #$46	; ...  check to end of table
	CMP zp7F
	BCC B_E878
B_E874	PLA
	JMP L_E857	; no, continue
	;
B_E878	PLA
	JMP L_E88C	; done
	;
B_E87C	JSR S_E8A6	; get a character, bit 7 in carry
	BCC B_E87C	; wait for character with bit 7 set
B_E881	JSR S_E893	; and write in buffer
	JSR S_E8A6	; get next character
	BCC B_E881	; wait for character with bit 7 set
	JSR S_E893	; put character in buffer
L_E88C	PLA
	STA zp7F+1
	PLA		; get pointer $7f/$80 back
	STA zp7F
	RTS

;$E893  -------- Get character and in buffer

S_E893	CMP #$20	; ' ' blank
	BCS B_E8A2	; greater, then write in buffer
	TAX		; save code
	LDA #$20	; blank
	STA (zpA6),Y	; write in buffer
	INY		; increment buffer pointer
	TXA		; code in accumulator
	JSR S_E845	; output previous text
	RTS
;$E8A2  --------
B_E8A2	STA (zpA6),Y	; write character in buffer
	INY		; and increment pointer
	RTS

;$E8A6  -------- Get a char of the error message

S_E8A6	INC zp7F
	BNE S_E8AC	; increment pointer
	INC zp7F+1
S_E8AC	LDA (zp7F,X)	; get character
	ASL A		; bit 7 into carry
	LDA (zp7F,X)	; get character
	AND #$7F	; erase bit 7
	RTS
;$E8B4  --------
S_E8B4	JSR S_E8AC	; bit 7 into carry
	INC zp7F
	BNE B_E8BD	; increment pointer
	INC zp7F+1
B_E8BD	RTS
;$E8BE  -------- Dummy subroutine
L_E8BE	RTS
;$E8BF  --------
	JMP L_E8BE
	;
	CLI
	INC V_0278
	INC V_0274
	LDA #$2A
	STA V_0200
	JMP L_E8D9
	;
	LDA #$01
	STA V_027A
	JSR S_C3FC
L_E8D9	LDA V_0278
	PHA
	LDA #$01
	STA V_0278
V_E8E2	LDA #$FF
	STA zp7F
	JSR S_C53A
	LDA V_0280
	BNE B_E8F3
	LDA #$39
	JSR L_C2B2
B_E8F3	PLA
	STA V_0278
	LDA V_0280
	STA zp79
	LDA V_0285
	STA zp7A
	LDA #$03
	JSR S_D5CA
B_E906	LDA #$00
	STA zp7F+1	; erase checksum
	JSR S_E967	; get byte from file
	STA zp81	; save as start address lo
	JSR S_E979	; from checksum
	JSR S_E967	; get byte from file
	STA zp81+1	; as start address hi
	JSR S_E979	; form checksum
	LDA zp7F
	BEQ B_E928
	LDA zp81
	PHA		; save program start address
	LDA zp81+1
	PHA
	LDA #$00
	STA zp7F
B_E928	JSR S_E967	; get byte from file
	STA zp82+1	; save as counter
	JSR S_E979	; form checksum
B_E930	JSR S_E967	; get byte from file
	LDY #$00
	STA (zp81),Y	; save as program bytes
	JSR S_E979	; form checksum
	LDA zp81
	CLC
	ADC #$01
	STA zp81	; increment $88/$89
	BCC B_E945
	INC zp81+1
B_E945	DEC zp82+1	; decrement pointer
	BNE B_E930
	JSR S_CB2A	; get next byte
	LDA zp7E	; data byte
	CMP zp7F+1	; equal to checksum?
	BEQ B_E95A	; yes
	JSR S_DF79	; transmit parameter to disk controller
	LDA #$50	;
	JSR S_E781	; 50, 'record not present'
B_E95A	LDA zp95	; end?
	BNE B_E906	; no, next data block
	PLA
	STA zp81+1
	PLA		; get program start address back
	STA zp81
	JMP ($0081)	; *** Indirect jump to program
	;
S_E967	JSR S_CB2A	; get byte from file
	LDA zp95	; end?
	BNE B_E976	; no
	JSR S_DF79	; transmit parameter to disk controller
	LDA #$51
	JSR S_E781	; 51, 'overflow in record'
B_E976	LDA zp7E	; data byte
	RTS

;$E979  -------- Generate checksum

S_E979	CLC
	ADC zp7F+1
	ADC #$00
	STA zp7F+1
	RTS

;$E981  -------- Blink LED and loop

L_E981	LDX #$00
	DB $2C		; BIT $xxxx
L_E984	LDX zp6E	;
	TXS		; load X to stack pointer
B_E987	TSX		; read X from stack pointer
B_E988	LDA #$6F
	STA zp00	; set direction of processor port to default
	AND #$60	; drive LED on
	STA zp01	; store #$60 to processor port
	TYA
B_E991	CLC
B_E992	ADC #$01
	BNE B_E992
	DEY
	BNE B_E991	; delay (WAIT)
	LDA #$68
	STA zp01	; drive LED off
B_E99D	TYA
B_E99E	CLC
B_E99F	ADC #$01
	BNE B_E99F
	DEY
	BNE B_E99E	; delay (WAIT)
	DEX
	BPL B_E988	; flash LED
	CPX #$F4
	BNE B_E99D
	BEQ B_E987
L_E9AF	JMP L_E984
	;
B_E9B2	JMP L_E981
	;
	; Drive RESET
	;
	SEI
	CLD
	LDY #$00
	LDX #$02	; memory test on zero lap ($02-$FF)
B_E9BB	TXA
	STA zp00,X
	INX
	BNE B_E9BB
	LDX #$02
B_E9C3	TXA
	CMP zp00,X
	BNE B_E9B2
B_E9C8	INC zp00,X
	INY
	BNE B_E9C8
	CMP zp00,X
	BNE B_E9B2	; memory test failure (x will be the RAM page nr)?
	STY zp00,X	; clear to 0 (zero)
	LDA zp00,X	; check
	BNE B_E9B2	; memory test failed...
	INX
	BNE B_E9C3	; loop
	INC zp6E	; increase blink count
	STX zp74+1
	LDA #$00	; ROM checksumgeneration begins
	STA zp74
	TAY		; Y = A (0)
	LDX #$40
	CLC
B_E9E6	DEC zp74+1
B_E9E8	ADC (zp74),Y
	INY
	BNE B_E9E8
	DEX
	BNE B_E9E6
	STA zp61	; reset count
	ADC #$FF
	BNE L_E9AF	; ROM checksum correct?
	LDA #$01
	STA zp74+1
	INC zp6E
	LDX #$07
B_E9FE	TYA
	CLC
	ADC zp74+1
	STA (zp74),Y
	INY
	BNE B_E9FE
	INC zp74+1
	DEX
	BNE B_E9FE
	LDX #$07
B_EA0E	DEC zp74+1
B_EA10	DEY
	TYA
	CLC
	ADC zp74+1
	CMP (zp74),Y
	BNE B_EA2B
	EOR #$FF	; reverse all bits
	STA (zp74),Y
	EOR (zp74),Y	; check
	STA (zp74),Y
	BNE B_EA2B	; not equal, then jump
	TYA
	BNE B_EA10
	DEX
	BNE B_EA0E
	BEQ B_EA2E	; always jump
B_EA2B	JMP L_E9AF
	;
B_EA2E	LDX #$FF
	STX zp95
	TXS		; clear stack pointer
	JSR S_C3C6	; DOS init
	JSR S_F13D	; FDC init
	LDA #$11
	STA zp68
	LDA #$05
	STA zp69
	LDX #$00
	LDY #$00
B_EA45	LDA #$00
	STA zp9A,X
	INX
	LDA V_F123,Y
	STA zp9A,X
	INX
	INY
	CPY #$05
	BNE B_EA45
	LDA #$00
	STA zp9A,X
	INX
	LDA #$02
	STA zp9A,X
	INX
	LDA #$D5
	STA zp9A,X
	INX
	LDA #$02
	STA zp9A,X
	LDA #$FF
	LDX #$12
B_EA6C	STA V_022B,X
	DEX
	BPL B_EA6C
	LDX #$05
B_EA74	STA zpA8,X
	STA zpAF,X
	STA zpCE,X
	DEX
	BPL B_EA74
	LDA #$05
	STA zpAC
	LDA #$06
	STA zpAD
	LDA #$FF
	STA zpAE
	STA zpB5
	LDA #$05
	STA V_023B
	LDA #$84
	STA V_023A
	LDA #$0F
	STA V_0256
	LDA #$01
	STA zpF7
	LDA #$88
	STA zpF8
	LDA #$E0
	STA V_024F
	LDA #$FF
	STA V_0250
	LDA #$01
	STA zp22
	STA zp23
	JSR S_CC55
	JSR S_CFB0
	LDA #$73
	JSR S_E800
	;
	; Main wait loop
	;
L_EABD	INC zp61	; count
	BNE B_EAC4	; if not zero, skip next call
	JSR S_EADC
B_EAC4	LDA V_4000	; read I/O port from computer
	BPL B_EACC	; 7th bit set?
	JSR S_C022	; yes, then jump
B_EACC	LDA V_0255	; waiting for command?
	BEQ L_EABD	; no...
	LDA #$00	; yes
	STA V_0255	; clear command flag
	JSR S_C230	; analyze and execute command
	JMP L_EABD	; back to main loop
	;
	;
	;
S_EADC	LDA #$0E	; 14
	STA zp63	; as secondary address
	LDA #$00
	STA zp62	; job counter
B_EAE4	LDX zp63
	LDA V_022B,X	; secondary address
	CMP #$FF	; channel associated?
	BEQ B_EAEF	; no
	INC zp62
B_EAEF	DEC zp63
	BPL B_EAE4
	LDA zp62
	BEQ B_EAFE
	LDA zp22
	BEQ B_EAFE
	JSR S_D465
B_EAFE	LDX V_026C
	BEQ B_EB06
	JMP L_F3F7	; set LED flag
	;
B_EB06	LDA zp62
	STA zp96
	RTS
;$EB0B  --------
S_EB0B	LDA #$00
	STA zp7C
	LDA #$01
	JSR S_D338
	LDA #$00
	JSR S_D61B
	LDX zp7B
	LDA #$00
	STA V_0244,X
	JSR S_E0CE
	TAX
	LDA zp78
	STA V_025B,X
	LDA #$01
	JSR S_D10D
	LDA #$04
	JSR S_D10D
	LDA #$01
	JSR S_D10D
	JSR S_D10D
	LDA V_0272
	JSR S_D10D
	LDA #$00
	JSR S_D10D
	JSR S_EBC6
	JSR S_E0CE
	ASL A
	TAX
	DEC zp9A,X
	DEC zp9A,X
	LDA #$00
	JSR S_D10D
B_EB57	LDA #$01
	JSR S_D10D
	JSR S_D10D
	JSR S_C7AF
	BCC B_EB90
	LDA V_0272
	JSR S_D10D
	LDA V_0273
	JSR S_D10D
	JSR S_EBC6
	LDA #$00
	JSR S_D10D
	BNE B_EB57
L_EB7A	JSR S_E0CE
	ASL A
	TAX
	LDA #$00
	STA zp9A,X
	LDA #$88
	LDY zp7B
	STA V_0254
	STA $00F3,Y
	LDA zp7E
	RTS
;$EB90  --------
B_EB90	LDA V_0272	; block number lo
	JSR S_D10D	; write in buffer
	LDA V_0273	; block number hi
	JSR S_D10D	; in buffer
	JSR S_EBC6	; 'blocks free.' in buffer
	JSR S_E0CE	; get buffer number
	ASL A
	TAX
	DEC zp9A,X
	DEC zp9A,X	; buffer pointer minus 2
	LDA #$00
	JSR S_D10D
	JSR S_D10D	; three zeroes as program end
	JSR S_D10D
	JSR S_E0CE	; get buffer number
	ASL A		; times 2
	TAY
	LDA $009A,Y	; buffer pointer
	LDX zp7B
	STA V_0244,X	; as end marker
	DEC V_0244,X
	JMP L_EB7A
	;
	; Transmit dir line
	;
S_EBC6	LDY #$00
B_EBC8	LDA V_02B1,Y	; character from buffer
	JSR S_D10D	; write in output buffer
	INY
	CPY #$1B	; 27 characters?
	BNE B_EBC8
	RTS
;$EBD4  -------- Get byte from buffer
S_EBD4	JSR S_D247	; get byte
	BEQ B_EBDA	; buffer pointer zero?
	RTS
;$EBDA  --------
B_EBDA	STA zp7E	; save data byte
	LDY zp7B	; channel number
	LDA V_0244,Y	; set end marker
	BEQ B_EBEB	; zero (LOAD $)?
	LDA #$80
	STA $00F3,Y	; set READ flag
	LDA zp7E	; data byte
	RTS
;$EBEB  --------
B_EBEB	PHA
	JSR B_EB57	; create directory line in buffer
	PLA
	RTS

;$EBF1  -------- Perform [V] - Validate command

	JSR S_C2BB	; find drive number in input line
	JSR S_D15E	; load BAM
	LDA #$40
	STA V_02F9
	JSR S_ED22	; create new BAM in buffer
	LDA #$00
	STA V_0292
	JSR S_C691	; load directory, find 1st flag
	BNE B_EC46	; found?
B_EC09	LDA #$00
	STA zp7A	; sector 0
	LDA V_F0C3	; 18
	STA zp79	; track 18 for BAM
	JSR S_EC52	; mark directory blocks as allocated
	LDA #$00
	STA V_02F9
	JSR S_ED6A	; write BAM back to disk
	JMP L_C27E	; done, prepare disk status
	;
B_EC20	INY
	LDA (zp8D),Y	; save track
	PHA
	INY
	LDA (zp8D),Y	; and sector
	PHA
	LDY #$13	; pointer to side-sector block
	LDA (zp8D),Y
	BEQ B_EC38	; no track following?
	STA zp79	; track and
	INY
	LDA (zp8D),Y
	STA zp7A	; sector of 1st side-sector block
	JSR S_EC52	; mark side-sector block as
B_EC38	PLA		; allocated
	STA zp7A
	PLA		; get track and sector back
	STA zp79
	JSR S_EC52	; mark blocks of file as allocated
L_EC41	JSR S_C6E9	; read next entry in directory
	BEQ B_EC09	; end of directory?
B_EC46	LDY #$00
	LDA (zp8D),Y	; file type
	BMI B_EC20	; bit 7 set, file closed?
	JSR S_C997	; file type to zero and write BAM
	JMP L_EC41
	;
	; Allocate file blocks in BAM
	;
S_EC52	JSR S_D6B0	; check track and sector number
	JSR S_EDFB	; allocate block in BAM
	JSR S_D5C8	; read next block
L_EC5B	LDA #$00
	JSR S_D61B	; buffer pointer zero
	JSR S_D247	; get byte from buffer
	STA zp79	; track
	JSR S_D247	; get byte from buffer
	STA zp7A	; sector
	LDA zp79	; another block?
	BNE B_EC71	; yes
	JMP L_D37D	; close channel
	;
B_EC71	JSR S_EDFB	; allocate block in BAM
	JSR S_D5A0	; read next block
	JMP L_EC5B	; continue
	;
	; Perform [N] - New (Format) command
	;
	JSR S_C3FC	; get drive number
	LDA zpE3	; drive number
	BPL B_EC86	; not clear?
	LDA #$33
	JMP L_C2B2	; 33, 'syntax error'
	;
B_EC86	AND #$01
	STA zp78	; drive number
	TAX
	LDY #$00
	STY zp5F,X
	ASL A		; times 2
	TAX
	LDY V_027B	; comma position
	CPY V_0274	; compare with end name
	BEQ B_ECB3	; format without ID
	LDA V_0200,Y	; first character of ID
	STA zp14,X	; save
	LDA L_0201,Y	; second character
	STA zp15,X
	JSR S_D459	; close all channels
	LDA #$01
	STA zp79	; track 1
	JSR S_C9A7	; format disk
	JSR S_EE70	; erase buffer
	JMP L_ECC2	; continue as below
	;
B_ECB3	JSR S_D15E	; load BAM
	LDX zp78	; drive number
	LDA zp5D,X
	CMP V_F118	; 'A', marker for 1541 format
	BEQ L_ECC2	; ok
	JMP L_D6C3	; 73, 'cbm dos v2.6 tdisk'
	;
L_ECC2	JSR S_ED22	; create BAM
	LDA zp98	; buffer number
	TAY
	ASL A
	TAX
	LDA V_F0C6	; $90, start of disk name
	STA zp9A,X	; buffer pointer to name
	LDX V_027A
	LDA #$1B	; 27
	JSR S_C74F	; write filenames in buffer
	LDY #$12	; position 18
	LDX zp78	; drive number
	LDA V_F118	; 'A', 1541 format
	STA zp5D,X
	TXA
	ASL A	 	; times 2
	TAX
	LDA zp14,X	; ID, first character
	STA (zp8D),Y	; in buffer
	INY
	LDA zp15,X	; and second character
	STA (zp8D),Y	; in buffer
	INY
	INY
	LDA #$32	; '2'
	STA (zp8D),Y	; in buffer
	INY
	LDA V_F118	; 'A' 1541 format
	STA (zp8D),Y	; in buffer
	LDY #$02
	STA (zp6C),Y	; and at position 2
	LDA V_F0C3	; 18
	STA zp79	; track number
	JSR S_EDFE	; mark block as allocated
	LDA #$01	; 1
	STA zp7A	; sector number
	JSR S_EDFE	; mark block as allocated
	JSR S_ED6A	; write BAM
	JSR S_EE70	; pointer $6D/$6E to buffer, erase buffer
	LDY #$01
	LDA #$FF
	STA (zp6C),Y	; track following is zero
	JSR S_D5B7	; write BAM
	DEC zp7A	; decrement sector number, 0
	JSR S_D5B3	; read block
	JMP L_C27E	; prepare disk status
	;
	; Create BAM
	;
S_ED22	JSR S_EF3C
	LDY #$00
	LDA #$12	; 18
	STA (zp6C),Y	; pointer to directory track
	INY
	TYA		; 1
	STA (zp6C),Y	; pointer to directory sector
	INY
	INY
	INY
B_ED32	LDA #$00
	STA zp6E
	STA zp6E+1	; 3 bytes = 24 bits for sectors
	STA zp70
	TYA		; byte position
	LSR A
	LSR A		; divided by 4 = track number
	JSR S_F0B6	; get number of sectors
	STA (zp6C),Y	; and in BAM
	INY
	TAX
B_ED44	SEC
	ROL zp6E
	ROL zp6E+1	; create bit model
	ROL zp70
	DEX
	BNE B_ED44
B_ED4E	LDA zp6E,X	; 3 bytes
	STA (zp6C),Y	; the BAM in buffer
	INY
	INX
	CPX #$03
	BCC B_ED4E
	CPY #$90	; position 144?
	BCC B_ED32	; no, next track
	JMP L_D185	; calculate number of free blocks
	;
	; Write BAM if needed
	;
S_ED5F	JSR S_E0CE	; get buffer number
	TAX
	LDA V_025B,X	; command for disk controller
	AND #$01
	STA zp78	; isolate drive number
S_ED6A	LDY zp78
	LDA V_0251,Y	; BAM-changed flag set?
	BNE B_ED72	; yes
	RTS
;$ED72  --------
B_ED72	LDA #$00
	STA V_0251,Y	; reset BAM-changed flag
	JSR S_EDA5	; set buffer pointer for BAM
	LDA zp78	; drive number
	ASL A		; times 2
	PHA
	JSR S_EF10	; verify BAM entry
	PLA
	CLC
	ADC #$01	; inrement track number
	JSR S_EF10	; verify BAM entry
	LDA zp79	; track
	PHA
	LDA #$01	; track 1
	STA zp79
B_ED8F	ASL A
	ASL A		; times 4
	STA zp6C
	JSR S_F08B	; verify BAM
	INC zp79	; increment track number
	LDA zp79
	CMP V_F11A	; and compare with max val + 1 = 36
	BCC B_ED8F	; ok, next track
	PLA
	STA zp79	; get track number back
	JMP L_D6DD	; write BAM to disk
	;
	; Set buffer pointer for BAM
	;
S_EDA5	JSR S_EF7A	; get 6 for drive 0
	TAX
	JSR S_EF4A	; allocate buffer
	LDX zp98	; buffer number
	LDA V_F123,X	; buffer address, hi byte
	STA zp6C+1
	LDA #$00	; lo byte
	STA zp6C	; pointer to $6D/$6E
	RTS

;$EDB8  -------- Get number of free blocks for dir

S_EDB8	LDX zp78	; drive number
	LDA V_02FA,X	; number of blocks, lo
	STA V_0272
	LDA V_02FC,X	; number of blocks, hi
	STA V_0273	; in buffer for directory
	RTS

;$EDC7  -------- Mark block as free

	JSR S_EE5B + 1	; set buffer pointer
S_EDCA	JSR S_EE3A	; erase bit for sector in BAM
	SEC
	BNE B_EDF2	; block already free, then done
	LDA (zp6C),Y	; bit model of BAM
	ORA V_EE54,X	; set bit X, marker for free
	STA (zp6C),Y
	JSR S_EDF3	; set flag for BAM changed
	LDY zp6E
	CLC
	LDA (zp6C),Y
	ADC #$01	; increment number of free blocks/track
	STA (zp6C),Y
	LDA zp79	; track
	CMP V_F0C3	; equal to 18?
	BEQ B_EE25	; then skip
	INC V_02FA,X	; increment number of free blocks in disk
	BNE B_EDF2
	INC V_02FC,X	; increment number of blocks hi
B_EDF2	RTS

;$EDF3  -------- Set flag for BAM changed

S_EDF3	LDX zp78	; drive number
	LDA #$01
	STA V_0251,X	; flag = 1
	RTS

;$EDFB  -------- Mark block as allocated

S_EDFB	JSR S_EE5B + 1	; set buffer pointer
S_EDFE	JSR S_EE3A	; erase bit for sector in BAM
	BEQ B_EE39	; already allocated, then done
	LDA (zp6C),Y
	EOR V_EE54,X	; erase bit for block
	STA (zp6C),Y
	JSR S_EDF3	; set flag for BAM changed
	LDY zp6E
	LDA (zp6C),Y
	SEC
	SBC #$01	; decrement number of blocks per track
	STA (zp6C),Y
	LDA zp79	; track
	CMP V_F0C3	; 18?
	BEQ B_EE28
	LDA V_02FA,X	; number of free blocks lo
	BNE B_EE25
	DEC V_02FC,X	; decrement number of free blocks
B_EE25	DEC V_02FA,X
B_EE28	LDA V_02FC,X	; number of free blocks hi
	BNE B_EE39	; more than 255 blocks free?
	LDA V_02FA,X	; free blocks lo
	CMP #$03
	BCS B_EE39	; smaller than 3?
	LDA #$72
	JSR S_E806	; 72, 'disk full'
B_EE39	RTS

;$EE3A  -------- Erase bit for sector in BAM entry

S_EE3A	JSR S_EE7C	; find BAM field for this track
	TYA
	STA zp6E
S_EE40	LDA zp7A	; sector
	LSR A
	LSR A		; divide by 8
	LSR A
	SEC
	ADC zp6E
	TAY		; byte number in BAM entry
	LDA zp7A	; sector number
	AND #$07
	TAX		; bit number in BAM entry
	LDA (zp6C),Y	; byte in BAM
	AND V_EE54,X	; erase bit for corresponding sector
	RTS
;$EE54  -------- Powers of 2
V_EE54	DB $01,$02,$04,$08,$10,$20,$40,$80
;$EE5C  -------- Write BAM after change
S_EE5C	LDA #$FF
	BIT $02F9
	BEQ B_EE6F
	BPL B_EE6F
	BVS B_EE6F
	LDA #$00
	STA V_02F9	; reset flag
	JMP L_D6DD	; write block
	;
B_EE6F	RTS
;$EE70  -------- Erase BAM buffer
S_EE70	JSR S_EDA5	; pointer $6c/$6d to BAM buffer
	LDY #$00
	TYA
B_EE76	STA (zp6C),Y	; erase BAM buffer
	INY
B_EE79	BNE B_EE76
	RTS
;$EE7C  --------
S_EE7C	LDA zp6E
	PHA
	LDA zp6E+1
	PHA
	LDX zp78	; drive number
	LDA zp5F,X
	BEQ B_EE8D	; drive zero?
	LDA #$74
	JSR S_E784	; 'drive not ready'
B_EE8D	JSR S_EF7A	; get buffer number for BAM
	STA zp6E
	TXA
	ASL A
	STA zp6E+1
	TAX
	LDA zp79	; track
	CMP V_029D,X
	BEQ B_EEA9
	INX
	STX zp6E+1
	CMP V_029D,X
	BEQ B_EEA9
	JSR S_EEC6
B_EEA9	LDA zp6E+1
	LDX zp78	; drive number
	STA V_029B,X
	ASL A
	ASL A		; times 4
	CLC
	ADC #$A1
	STA zp6C
	LDA #$02
	ADC #$00
	STA zp6C+1
	LDY #$00
	PLA
	STA zp6E+1
	PLA
	STA zp6E
	RTS
;$EEC6  --------
S_EEC6	LDX zp6E
	JSR S_EF4A
	LDA zp78	; drive number
	TAX
	ASL A
	ORA V_029B,X
	EOR #$01
	AND #$03
	STA zp6E+1
	JSR S_EF10
	LDA zp98	; buffer number
	ASL A
	TAX
	LDA zp79	; track
	ASL A
	ASL A		; times 4
	STA zp9A,X	; equal pointer in BAM field
	LDA zp6E+1
	ASL A
	ASL A
	TAY
B_EEEA	LDA (zp9A,X)
	STA V_02A1,Y
	LDA #$00
	STA (zp9A,X)	; zero in buffer
	INC zp9A,X	; increment buffer pointer
	INY
	TYA
	AND #$03
	BNE B_EEEA
	LDX zp6E+1
	LDA zp79	; track
	STA V_029D,X
	LDA V_02F9
	BNE B_EF0A
	JMP L_D6DD	; write block
	;
B_EF0A	ORA #$80
	STA V_02F9
	RTS
;$EF10  --------
S_EF10	TAY
	LDA V_029D,Y
	BEQ B_EF3B
	PHA
	LDA #$00
	STA V_029D,Y
	LDA zp98	; buffer number
	ASL A		; times 2
	TAX
	PLA
	ASL A
	ASL A
	STA zp9A,X
	TYA
	ASL A
	ASL A
	TAY
B_EF29	LDA V_02A1,Y
	STA (zp9A,X)	; write in buffer
	LDA #$00
	STA V_02A1,Y
	INC zp9A,X	; increment buffer pointer
	INY
	TYA
	AND #$03
	BNE B_EF29
B_EF3B	RTS

;$EF3C  -------- Clear BAM

S_EF3C	LDA zp78	; drive number
	ASL A		; * 2
	TAX		; index
	LDA #$00
	STA V_029D,X
	INX
	STA V_029D,X
	RTS
;$EF4A  --------
S_EF4A	LDA zpA8,X
	CMP #$FF
	BNE B_EF75
	TXA
	PHA
	JSR S_D3E4
	TAX
	BPL B_EF5D
	LDA #$70
	JSR L_C2B2	; 70, 'no channel'
B_EF5D	STX zp98
	PLA
	TAY
	TXA
	ORA #$80
	STA $00A8,Y
	ASL A
	TAX
	LDA V_F0C3	; 18, directory track
	STA zp08,X	; save
	LDA #$00	; 0
	STA zp09,X	; as sector
	JMP L_D6D9	; write block
	;
B_EF75	AND #$0F
	STA zp98	; buffer number
	RTS
;$EF7A  -------- Get buffer number for BAM
S_EF7A	LDA #$06
	LDX zp78	; drive number
	BNE B_EF83
	CLC
	ADC #$07	; gives 13 for drive 0
B_EF83	RTS
;$EF84  -------- Buffer number for BAM
S_EF84	JSR S_EF7A	; get buffer number
	TAX
	RTS
;$EF89  -------- Find and allocate free block
S_EF89	JSR S_DF79	; get track and sector number
	LDA #$03
	STA zp6E	; counter
	LDA #$01
	ORA V_02F9
	STA V_02F9
S_EF98	LDA zp6E	; save counter
	PHA
	JSR S_EE7C	; find BAM field for this track
	PLA
	STA zp6E	; get counter back
	LDA (zp6C),Y	; number of free blocks in track
	BNE B_EFDE	; blocks still free?
	LDA zp79	; track
	CMP V_F0C3	; 18, directory track?
	BEQ B_EFC5	; yes, 'disk full'
	BCC B_EFCA	; smaller, then next lower track
	INC zp79	; increment track number
	LDA zp79
	CMP V_F11A	; 36, highest track number plus one
	BNE S_EF98	; no, continue searching this track
	LDX V_F0C3	; 18, directory track
	DEX		; decrement
	STX zp79	; save as track number
	LDA #$00
	STA zp7A	; begin with sector number zero
	DEC zp6E	; decrement counter
	BNE S_EF98	; not yet zero, then continue
B_EFC5	LDA #$72
	JSR L_C2B2	; 72, 'disk full'
B_EFCA	DEC zp79	; decrement track number
	BNE S_EF98	; not yet 0, continue in this track
	LDX V_F0C3	; 18, directory track
	INX		; increment
	STX zp79	; save as track number
	LDA #$00
	STA zp7A	; begin with sector zero
	DEC zp6E	; decrement counter
	BNE S_EF98	; not yet zero, then continue
	BEQ B_EFC5	; else 'disk full'
B_EFDE	LDA zp7A	; sector number
	CLC
	ADC zp68	; plus step width (10)
	STA zp7A	; as new number
	LDA zp79	; track number
	JSR S_F0B6	; get maximum sector number
	STA V_024E
	STA V_024D	; and save
	CMP zp7A	; greater than selected sector number?
	BCS B_F000	; yes
	SEC		; else
	LDA zp7A	; sector number
	SBC V_024E	; minus maximum sector number
	STA zp7A	; save as new sector number
	BEQ B_F000	; zero?
	DEC zp7A	; else decrement sector number by one
B_F000	JSR S_F065	; check BAM, find free sector
	BEQ B_F008	; not found?
B_F005	JMP S_EDFB	; allocate block in BAM
	;
B_F008	LDA #$00
	STA zp7A	; sector zero
	JSR S_F065	; find free sector
	BNE B_F005	; found?
	JMP L_F060	; no, 'dir sector'
	;
	; Find free sector and allocate
	;
S_F014	LDA #$01
	ORA V_02F9
	STA V_02F9
	LDA zp7F
	PHA
	LDA #$01	; track counter
	STA zp7F
B_F023	LDA V_F0C3	; 18, directory track
	SEC
	SBC zp7F	; minus counter
	STA zp79	; save as track number
	BCC B_F036	; result <= zero?
	BEQ B_F036	; then try top half of directory
	JSR S_EE7C	; find BAM field for this track
	LDA (zp6C),Y	; number of free blocks in this track
	BNE B_F051	; free blocks exist
B_F036	LDA V_F0C3	; 18, directory track
	CLC
	ADC zp7F	; plus counter
	STA zp79	; save as track number
	INC zp7F	; increment counter
	CMP V_F11A	; 36, max track number plus one
	BCC B_F04A	; smaller, then ok
	LDA #$67
	JSR S_E781	; 67, 'illegal track or sector'
B_F04A	JSR S_EE7C	; find BAM field for this track
	LDA (zp6C),Y	; number of free blocks?
	BEQ B_F023	; no more free blocks?
B_F051	PLA
	STA zp7F
	LDA #$00
	STA zp7A	; sector 0
	JSR S_F065	; find free sector
	BEQ L_F060	; not found?
	JMP S_EDFB	; allocate block in BAM
	;
L_F060	LDA #$71
	JSR S_E781	; 71, 'dir error'
	; Find free sectors in current track
S_F065	JSR S_EE7C	; find BAM field for this track
	TYA		; point to number of free blocks
	PHA
	JSR S_F08B	; verify BAM
	LDA zp79	; track
	JSR S_F0B6	; get max number of sectors of the track
	STA V_024E	; save
	PLA
	STA zp6E	; save pointer
B_F078	LDA zp7A	; compare sector
	CMP V_024E	; with maximum number
	BCS B_F088	; greater than or equal to?
	JSR S_EE40	; get bit number of sector
	BNE B_F08A	; sector free?
	INC zp7A	; increment sector number
	BNE B_F078	; and check if free
B_F088	LDA #$00	; no sectors free
B_F08A	RTS

;$F08B  -------- Verify number of free blocks in BAM

S_F08B	LDA zp6E
	PHA
	LDA #$00
	STA zp6E	; counter to zero
	LDY V_F0C4	; 4, number of bytes per track in BAM
	DEY
B_F096	LDX #$07
B_F098	LDA (zp6C),Y
	AND V_EE54,X	; isolate bit
	BEQ B_F0A1
	INC zp6E	; increment counter of free sectors
B_F0A1	DEX
	BPL B_F098
	DEY
	BNE B_F096
	LDA (zp6C),Y	; compare with number on diskette
	CMP zp6E
	BNE B_F0B1	; not equal, then error
	PLA
	STA zp6E
	RTS
;$F0B1  --------
B_F0B1	LDA #$71
	JSR S_E781	; 71, 'dir error'
	; Establish number of sectors per track
S_F0B6	LDX V_F118 + 1	; 4 different values
B_F0B9	CMP V_F118 + 1,X	; track number
	DEX
	BCS B_F0B9	; not greater?
V_F0BF	LDA V_F114,X	; get number of sectors
	RTS		; Dummy subroutine
;$F0C3  --------
; $F0C3
V_F0C3	DB "R"-64
; $F0C4
V_F0C4	DB "D"-64,"D"-64
V_F0C6	BCC B_F0EC + 1
	LSR zp49,X
; $F0CA
	DB "DM"
; $F0CC
	DB "B"
	EOR zp50,X
	ROL zp43
; $F0D1
	DB "R"
; $F0D2
	DB "SN"
V_F0D4	CMP V_21F1,X
	LDX #$ED
	ORA V_424E
	CMP (zpE5),Y
	ADC V_7A04,X
V_F0E1	CMP (zpEB,X)
	CMP (zpC9),Y
V_F0E5	DB $CB,$CD
	CPY V_E8E2 + 1
	CMP #$CB
B_F0EC	CMP #$EC
	EOR (zpDD),Y
; $F0F0
	DB $1C,$9E,$1C
; $F0F3
V_F0F3	DB "R"
; $F0F4
	DB "WA"
V_F0F6	EOR L_5344
	BVC B_F14F + 1
V_F0FB	JMP L_5344	; *** Self mod. indirect jump!
	;
	BVC B_F154 + 1
; $F100
V_F100	DB "R"
V_F101	EOR zp45
; $F103
	DB "R"
; $F104
	DB "SE"
V_F106	JMP L_4751
	;
; $F109
	DB "R"
	JMP L_0201
	;
V_F10D	DB $00
; $F10E
V_F10E	DB $3F
V_F10F	DB $7F
V_F110	DB $BF
; $F111
V_F111	DB $FF,"E"-64,"F"-64
V_F114	ORA (zp12),Y
; $F116
	DB "S"-64,"U"-64
V_F118	EOR (zp04,X)
V_F11A	BIT zp1E+1
V_F11C	ORA V_0112,Y
; $F11F
	DB $FF,$FF,$01
	BRK
; $F123
V_F123	DB "C"-64,"D"-64
	ORA zp06
; $F127
	DB "G"-64,"G"-64
V_F129	AND (zp22,X)
; $F12B
	DB $23,$24
	AND zp26
; $F12F
	DB $27,$28
V_F131	AND #$02
; $F133
	DB "B"-64
; $F134
	DB "D"-64,"F"-64
	PHP
	PHP
; $F138
	DB "K"-64,"S"-64
	ASL zp58,X
	RTS
;$F13D  -------- Init drive
S_F13D	LDA #$6F
	STA zp00	; set data direction register
	AND #$68
	STA zp01	; peripheral control defaults
	LDX #$14
	STX V_4002
	LDX #$1F
	STX V_4005
B_F14F	LDA V_4002
	AND #$20
B_F154	BNE B_F159
	LDA #$08
	DB $2C
B_F159	LDA #$09
	STA zp66
	JSR S_C20D
	LDA #$FF
	STA zp31
	STA zp40
	LDA #$01
	STA zp22
	STA zp23
	LDA #$00
	STA zp4D
	LDY #$12	; Y = 18
	LDA #$01
B_F174	STA $0002,Y	; empty job code buffers
	DEY
	BPL B_F174
	LDA #$00
	STA V_4003	; port A to input (listening to machine...)
	LDA V_4002
	ORA #$08
	AND #$FC
	STA V_4002
	AND #$F7
	STA V_4002
	ORA #$08
	STA V_4002
	CLI		; enable IRQ
	RTS
;
;$F195  -------- IRQ routine
;
; An IRQ signal is generated by an 555 astable multivibrator
; every 16650 cycles for approx. 14 cycles long
;
	PHA
	TXA
	PHA
	TYA
	PHA
	TSX
	STX zp3A	; save stack pointer
L_F19D	LDY #$05
B_F19F	LDA $0002,Y	; check job queue for all DOS channels
	BMI B_F1CB	; job found?
	DEY
	BPL B_F19F
	LDA zp76	; drive LED flashing?
	BNE B_F1BA	; yes...
	LDA zp01
	ORA #$08	; drive LED off
	LDY zp96	; counter for drive led
	BEQ B_F1B5	; timeout?
	AND #$F7	; not, then set drive LED back on
B_F1B5	STA zp01
	JMP L_F1C8
	;
B_F1BA	DEC zp55	; decrease flash counter
	BPL L_F1C8	; timeout?
	LDA #$1E	; reset flash counter
	STA zp55
	LDA zp01
	EOR #$08	; toggle drive LED
	STA zp01
L_F1C8	JMP L_FA41
	;
B_F1CB	AND #$01
	TAX
	CMP zp31
	BEQ B_F1ED
	STA zp31
	AND #$01
	STA zp32
	ROR A
	ROR A
	ROR A
	STA zp38
	LDA V_4002
	AND #$3F
	ORA zp38
	STA V_4002
	JSR S_FA27
	JMP L_FA41
	;
B_F1ED	LDA zp2B
	BMI B_F1F4
	ASL A
	BPL B_F1F7
B_F1F4	JMP L_FA41
	;
B_F1F7	LDA #$20
	STA zp2B
	LDA zp01
	AND #$F7
	STA zp01
	LDY #$05
	STY zp32+1
B_F205	JSR S_F284
	BMI B_F224
L_F20A	DEC zp32+1
	BPL B_F205
	LDY zp34
	JSR S_F286
	LDA zp34+1
	STA zp3B
	ASL zp3B
	LDA #$60
	STA zp2B
	LDA (zp20),Y
	STA zp29
	JMP L_FA41
	;
B_F224	AND #$01
	CMP zp31
	BNE L_F20A
	LDA zp29
	BEQ B_F23E
	SEC
	LDA (zp20),Y
	SBC zp29
	BEQ B_F23E
	STA zp34+1
	LDA zp32+1
	STA zp34
	JMP L_F20A
	;
B_F23E	LDX #$04
	LDA (zp20),Y
	STA zp56
B_F244	CMP V_F118 + 1,X
	DEX
	BCS B_F244
	LDA V_F114,X
	STA zp57
	TXA
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
	STA zp38
	LDA zp01
	AND #$9F
	ORA zp38
	STA zp01
	LDA zp1D
	CMP #$40
	BEQ B_F26F
	CMP #$70
	BEQ B_F26C
	JMP L_F2A6
	;
B_F26C	JMP L_FB7A
	;
B_F26F	LDA zp01
	AND #$FC
	STA zp01
	LDA #$60
	STA zp2B
	LDA #$A4
	STA zp3B
	LDA #$01
	STA zp29
	JMP L_FA12
	;
S_F284	LDY zp32+1
S_F286	LDA $0002,Y
	PHA
	BPL B_F2A0
	AND #$78
	STA zp1D
	TYA
	ASL A
	ADC #$08
	STA zp20
	LDA #$00
	STA zp20+1
	TYA
	CLC
	ADC #$03
	STA zp27+1
B_F2A0	LDY #$00
	STY zp27
	PLA
	RTS
;$F2A6  --------
L_F2A6	LDA #$5A
	STA zp3C
B_F2AA	JSR L_F560
B_F2AD	BIT zp01
	BPL B_F2AD
	BIT V_4000
	LDA V_4001
	CMP #$52	; "R"
	BNE B_F2FD
	LDY #$00
	STA V_0111,Y
	INY
B_F2C1	BIT zp01
	BPL B_F2C1
	BIT V_4000
	LDA V_4001
	STA V_0111,Y
	INY
	CPY #$08
	BNE B_F2C1
	JSR S_F388
	LDY #$04
	LDA #$00
B_F2DA	EOR $0018,Y
	DEY
	BPL B_F2DA
	CMP #$00
	BNE B_F314
	LDA zp1A
	STA zp29
	LDA zp1D
	CMP #$30
	BEQ B_F306
	LDA zp14
	CMP zp18
	BNE B_F311
	LDA zp15
	CMP zp19
	BNE B_F311
	JMP L_F319
	;
B_F2FD	DEC zp3C
	BNE B_F2AA
	LDA #$02
	JSR L_FA12
B_F306	LDA zp18
	STA zp14
	LDA zp19
	STA zp15
L_F30E	LDA #$01
	DB $2C
B_F311	LDA #$0B
	DB $2C
B_F314	LDA #$09
	JMP L_FA12
	;
L_F319	LDA #$7F
	STA zp3D
	LDA zp1B
	CLC
	ADC #$02
	CMP zp57
	BCC B_F328
	SBC zp57
B_F328	STA zp3E
	LDX #$05
	STX zp32+1
	LDX #$FF
B_F330	JSR S_F284
	BPL B_F374
	STA zp38
	AND #$01
	CMP zp31
	BNE B_F374
	LDY #$00
	LDA (zp20),Y
	CMP zp56
	BNE B_F374
	LDY #$01
	SEC
	LDA (zp20),Y
	SBC zp3E
	BPL B_F351
	CLC
	ADC zp57
B_F351	CMP zp3D
	BCS B_F374
	PHA
	LDA zp1D
	BEQ B_F36F
	PLA
	CMP #$09
	BCC B_F374
	CMP #$0C
	BCS B_F374
B_F363	STA zp3D
	LDA zp32+1
	TAX
	CLC
	ADC #$03
	STA zp27+1
	BNE B_F374
B_F36F	PLA
	CMP #$06
	BCC B_F363
B_F374	DEC zp32+1
	BPL B_F330
	TXA
	BPL B_F37E
	JMP L_FA41
	;
B_F37E	STX zp32+1
	JSR S_F284
	LDA zp1D
	JMP L_F3FC
	;
S_F388	LDA zp27
	PHA
	LDA zp27+1
	PHA
	LDA #$11
	STA zp27
	LDA #$01
	STA zp27+1
	LDA #$00
	STA zp2D
	JSR S_F928
	LDA zp44
	STA zp1A
	LDA zp43
	STA zp1B
	LDA zp42
	STA zp1C
	JSR S_F928
	LDA zp41
	STA zp19
	LDA zp42
	STA zp18
	PLA
	STA zp27+1
	PLA
	STA zp27
	RTS
;$F3BB  --------
S_F3BB	LDA zp27+1
	STA zp1E+1
	LDA #$01
	STA zp27+1
	LDA #$11
	STA zp2D
	LDA #$08
	STA zp41
	LDA zp1C
	STA zp42
	LDA zp1B
	STA zp43
	LDA zp1A
	STA zp44
	JSR S_F80C
	LDA zp19
	STA zp41
	LDA zp18
	STA zp42
	LDA #$00
	STA zp43
	STA zp44
	JSR S_F80C
	LDA zp1E+1
	STA zp27+1
	RTS
;$F3F0  --------
S_F3F0	LDA #$00
	STA V_026C
	BEQ B_F3F9
	;
	; Set LED flag
	;
L_F3F7	LDA #$E0
	; Set LED flag to accu
B_F3F9	STA zp76	; drive LED flag for IRQ routine
	RTS
;$F3FC  --------
L_F3FC	CMP #$00
	BEQ B_F403
	JMP L_F57D
	;
B_F403	JSR S_F513
B_F406	BIT zp01
	BPL B_F406
	LDA V_4001
	STA zpFA
	AND #$F8
	TAX
	LDA V_F70C,X
	STA zpF9
	LDA zpFA
	AND #$07
	STA zpFA
B_F41D	BIT zp01
	BPL B_F41D
	LDA V_4001
	STA zpFB
	AND #$C0
	ORA zpFA
	TAX
	LDA V_F70C,X
	ORA zpF9
	PHA
	BNE B_F464
	BEQ B_F464
B_F435	BIT zp01
	BPL B_F435
	LDA V_4001
	STA zpFA
	AND #$F8
	TAX
	LDA V_F70C,X
	STA zpF9
	LDA zpFA
	AND #$07
	STA zpFA
B_F44C	BIT zp01
	BPL B_F44C
	LDA V_4001
	STA zpFB
	AND #$C0
	ORA zpFA
	TAX
	LDA V_F70C,X
	ORA zpF9
	STA (zp27),Y
	INY
	BEQ B_F4D9
B_F464	LDA zpFB
	AND #$3E
	TAX
	LDA V_F70C,X
	STA zpF9
	LDA zpFB
	AND #$01
	STA zpFB
B_F474	BIT zp01
	BPL B_F474
	LDA V_4001
	STA zpFC
	AND #$F0
	ORA zpFB
	TAX
	LDA V_F70C + 2,X
	ORA zpF9
	STA (zp27),Y
	INY
	LDA zpFC
	AND #$0F
	STA zpFC
B_F490	BIT zp01
	BPL B_F490
	LDA V_4001
	STA zpFD
	AND #$80
	ORA zpFC
	TAX
	LDA V_F71C,X
	STA zpF9
	LDA zpFD
	AND #$7C
	TAX
	LDA V_F70C + 1,X
	ORA zpF9
	STA (zp27),Y
	INY
	LDA zpFD
	AND #$03
	STA zpFD
B_F4B6	BIT zp01
	BPL B_F4B6
	LDA V_4001
	STA zpFA
	AND #$E0
	ORA zpFD
	TAX
	LDA V_F729,X
	STA zpF9
	LDA zpFA
	AND #$1F
	TAX
	LDA V_F6FF,X
	ORA zpF9
	STA (zp27),Y
	INY
	JMP B_F435
	;
B_F4D9	LDA zpFB
	AND #$3E
	TAX
	LDA V_F70C,X
	STA zpF9
	LDA zpFB
	AND #$01
	STA zpFB
B_F4E9	BIT zp01
	BPL B_F4E9
	LDA V_4001
	AND #$F0
	ORA zpFB
	TAX
	LDA V_F70C + 2,X
	ORA zpF9
	STA zpFA
	PLA
	CMP #$07
	BNE B_F50B
	JSR S_F60A
	CMP zpFA
	BEQ B_F50E
	LDA #$05
	DB $2C
B_F50B	LDA #$04
	DB $2C
B_F50E	LDA #$01
	JMP L_FA12
	;
S_F513	JSR S_F519
	JMP L_F560
	;
S_F519	LDA zp14
	STA zp18
	LDA zp15
	STA zp19
	LDY #$00
	LDA (zp20),Y
	STA zp1A
	INY
	LDA (zp20),Y
	STA zp1B
	LDA #$00
	EOR zp18
	EOR zp19
	EOR zp1A
	EOR zp1B
	STA zp1C
	JSR S_F3BB
	LDA #$5A
	STA zp3C
B_F53F	JSR L_F560
B_F542	LDA V_0111,Y
B_F545	BIT zp01
	BPL B_F545
	CMP V_4001
	BNE B_F554
	INY
	CPY #$08
	BNE B_F542
	RTS
;$F554  --------
B_F554	DEC zp3C
	BNE B_F53F
	LDA #$02
	DB $2C
L_F55B	LDA #$03
	JMP L_FA12
	;
L_F560	LDY #$12
B_F562	LDX #$FF
B_F564	LDA V_4002
	AND #$40
	BEQ B_F574
	DEX
	BNE B_F564
	DEY
	BNE B_F562
	JMP L_F55B
	;
B_F574	LDA V_4001
	BIT V_4000
	LDY #$00
	RTS
;$F57D  --------
L_F57D	CMP #$10
	BEQ B_F584
	JMP L_F6BA
	;
B_F584	JSR S_F60A
	LDA zp01
	AND #$10
	BNE B_F592
	LDA #$08
	JMP L_FA12
	;
B_F592	JSR S_F8CD + 2
	JSR S_F519
	LDY #$09
B_F59A	BIT zp01
	BPL B_F59A
	BIT V_4000
	DEY
	BNE B_F59A
	LDA #$FF
	STA V_4004
	LDA V_4002
	AND #$EF
	STA V_4002
	LDA #$FF
	LDY #$05
	STA V_4001
	BIT V_4000
B_F5BB	BIT zp01
	BPL B_F5BB
	BIT V_4000
	DEY
	BNE B_F5BB
	LDY #$BB
B_F5C7	LDA $0060,Y
B_F5CA	BIT zp01
	BPL B_F5CA
	BIT V_4000
	STA V_4001
	INY
	BNE B_F5C7
B_F5D7	LDA (zp27),Y
B_F5D9	BIT zp01
	BPL B_F5D9
	BIT V_4000
	STA V_4001
	INY
	BNE B_F5D7
B_F5E6	BIT zp01
	BPL B_F5E6
	BIT V_4000
	LDA V_4002
	ORA #$10
	STA V_4002
	LDA #$00
	STA V_4004
	JSR S_F618
	LDY zp32+1
	LDA $0002,Y
	EOR #$30
	STA $0002,Y
	JMP L_F2A6
	;
S_F60A	LDY #$00
	STY zp30
B_F60E	LDA (zp27),Y
	EOR zp30
	STA zp30
	INY
	BNE B_F60E
	RTS
;$F618  --------
S_F618	LDA #$60
	STA zp27
	LDA zp27+1
	STA zp36
	LDA #$00
	STA zp27+1
	STA zp37
	LDA #$BB
	STA zp2D
	STA zp2E
	JSR S_F928
	LDA zp41
	STA zp2F
	LDY zp2E
	LDA zp42
	STA $0060,Y
	INY
	LDA zp43
	STA $0060,Y
	INY
	LDA zp44
	STA $0060,Y
	INY
	STY zp2E
B_F649	JSR S_F928
	LDY zp2E
	LDA zp41
	STA $0060,Y
	INY
	LDA zp42
	STA $0060,Y
	INY
	BEQ B_F66C
	LDA zp43
	STA $0060,Y
	INY
	LDA zp44
	STA $0060,Y
	INY
	STY zp2E
	BNE B_F649
B_F66C	LDA zp43
	STA (zp27),Y
	INY
	LDA zp44
	STA (zp27),Y
	INY
	STY zp2E
B_F678	JSR S_F928
	LDY zp2E
	LDA zp41
	STA (zp27),Y
	INY
	LDA zp42
	STA (zp27),Y
	INY
	LDA zp43
	STA (zp27),Y
	INY
	LDA zp44
	STA (zp27),Y
	INY
	STY zp2E
	CPY #$BB
	BCC B_F678
	LDA #$45	; "E"
	STA zp1E
	LDA zp27+1
	STA zp1E+1
	LDY #$BA
B_F6A1	LDA (zp27),Y
	STA (zp1E),Y
	DEY
	BNE B_F6A1
	LDA (zp27),Y
	STA (zp1E),Y
	LDX #$BB
B_F6AE	LDA V_011B,Y
	STA (zp27),Y
	INY
	INX
	BNE B_F6AE
	STX zp3F
	RTS
;$F6BA  --------
L_F6BA	CMP #$20
	BEQ B_F6C1
	JMP L_F6F9
	;
B_F6C1	JSR S_F60A
	JSR S_F8CD + 2
	JSR S_F513
	LDY #$BB
B_F6CC	LDA $0060,Y
B_F6CF	BIT zp01	; wait for byte-ready
	BPL B_F6CF
	BIT V_4000	; reset byte-ready signal
	EOR V_4001	; read and ...
	BNE B_F6F4	; ... verify with buffer contents
	INY
	BNE B_F6CC
B_F6DE	LDA (zp27),Y
B_F6E0	BIT zp01	; wait for byte-ready
	BPL B_F6E0
	BIT V_4000	; reset byte-ready signal
	EOR V_4001	; read and ...
	BNE B_F6F4	; ... verify with buffer contents
	INY
	CPY #$FD	; repeat $FC (252) times
	BNE B_F6DE
	JMP L_F30E
	;
B_F6F4	LDA #$07
	JMP L_FA12
	;
L_F6F9	JSR S_F519
	JMP L_F30E
	;
; $F6FF
V_F6FF	DB $FF
V_F700	DB $FF,$FF
; $F702
	DB $FF,$FF,$FF
; $F705
	DB $FF,$FF,$FF
	PHP
	BRK
	ORA (zpFF,X)
; $F70C
V_F70C	DB "L"-64
V_F70D	DB "D"-64
V_F70E	DB "E"-64
; $F70F
	DB $FF,$FF,"B"-64
; $F712
	DB "C"-64,$FF
; $F714
	DB "O"-64,"F"-64,"G"-64
; $F717
	DB $FF,"I"-64,"J"-64
; $F71A
	DB "K"-64,$FF
V_F71C	ORA V_800E
; $F71F
	DB $FF,$00,$00
	BPL B_F761 + 3
; $F724
	DB $FF,$20,$C0
	RTS
;$F728  --------
	RTI
;$F729  --------
V_F729	LDY #$50	; "P"
	CPX #$FF
; $F72D
	DB $FF,$FF,$02
	JSR S_3008
; $F733
	DB $FF,$FF,$00
B_F736	BEQ B_F736 + 1
	RTS
;$F739  --------
B_F739	ORA (zp70,X)
; $F73B
	DB $FF,$FF,$FF
	BCC B_F742 + 1
	LDY #$0C
B_F742	BCS B_F742 + 1
; $F744
	DB $FF,$04,$D0
; $F747
B_F747	DB $FF,$E0,$05
; $F74A
	DB $80,$FF
B_F74C	BCC B_F74C + 1
	PHP
; $F74F
	DB "L"-64,$FF,"O"-64
	ORA #$0D
; $F754
	DB $80,$02
; $F756
	DB $FF,$FF,$FF
; $F759
	DB $03,$FF
; $F75B
	DB $FF,$00,$FF
; $F75E
	DB $FF,$0F,$FF
; $F761
B_F761	DB $0F,$FF,$FF
B_F763 + 1	BPL B_F76B + 1
; $F766
	DB $FF,$FF,$FF
; $F769
	DB $07,$00
B_F76B	JSR S_FF9F + 1	; *** Self mod. indirect jump!
; $F76E
	DB $FF,$06,$FF
	ORA #$FF
; $F773
	DB $FF,$C0,$0A
; $F776
	DB $FF,$FF,$FF
; $F779
	DB $0B,$FF
; $F77B
B_F77B	DB $FF,$40,$FF
; $F77E
	DB $FF,$07,$FF
	ORA $FFFF	;
	BVC B_F793 + 1
; $F786
	DB $FF,$FF,$FF
; $F789
	DB $FF,$10,$30
B_F78C	BCS B_F78C + 1
	BRK
; $F78F
	DB "D"-64,"B"-64
	ASL zp0A
B_F793	ASL $FF7E + 2	;
; $F796
B_F796	DB $FF,$FF,$FF
; $F799
	DB $FF,$FF,$FF
	JSR S_08FF	;
	ORA #$80
	BPL B_F763
	BVC B_F7D4 + 1
	BMI B_F797
	BVS B_F739
	BCS B_F77B
; $F7AB
	DB $FF,$FF,$FF
	BRK
	ASL A
; $F7B0
	DB $FF,$FF,$FF
; $F7B3
	DB $FF,$F0,$FF
; $F7B6
	DB $FF,$FF,$FF
; $F7B9
	DB $FF,$FF,$FF
	RTS
;$F7BD  --------
; $F7BD
	DB $FF,"A"-64,"K"-64
; $F7C0
	DB $FF,$FF,$FF
; $F7C3
	DB $FF,$70,$FF
; $F7C6
	DB $FF,$FF,$FF
; $F7C9
	DB $FF,$C0,$F0
B_F7CC	BNE B_F7CC + 1
	ORA (zp05,X)
; $F7D0
	DB "C"-64,"G"-64
; $F7D2
	DB "K"-64,$FF
B_F7D4	BCC B_F7D4 + 1
; $F7D6
	DB $FF,$FF,$FF
; $F7D9
	DB $FF,$FF,$FF
	LDY #$FF
; $F7DE
	DB "L"-64,"M"-64,$FF
; $F7E1
	DB $FF,$FF,$FF
B_F7E4	BCS B_F7E4 + 1
; $F7E6
	DB $FF,$FF,$FF
; $F7E9
	DB $FF,$40,$60
	CPX #$FF
; $F7EE
	DB "D"-64,"N"-64
; $F7F0
	DB $FF,$FF,$FF
; $F7F3
	DB $FF,$D0,$FF
; $F7F6
	DB $FF,$FF,$FF
; $F7F9
	DB $FF,$FF,$FF
	CPX #$FF
	ORA zpFF
; $F800
V_F800	DB $FF,$FF,$FF
; $F803
	DB $FF,$FF,$FF
; $F806
	DB $FF,$FF,$FF
; $F809
	DB $FF,"Pp"
	;
	; Convert 4 binary bytes to 5 GCR bytes
	;
S_F80C	LDA #$00
	STA zp45+1
	STA zp49
	LDY zp2D
	LDA zp41
	AND #$F0	; isolate hi-nibble
	LSR A
	LSR A
	LSR A
	LSR A		; and rotate to lower nibble
	TAX		; use as index in table
	LDA V_F8BF,X
	ASL A
	ASL A
	ASL A		; times 8
	STA zp45
	LDA zp41
	AND #$0F	; isolate lower nibble
	TAX		; as index in table
	LDA V_F8BF,X
	ROR A
	ROR zp45+1
	ROR A
	ROR zp45+1
	AND #$07
	ORA zp45
	STA (zp27),Y	; in buffer
	INY		; increment buffer
	LDA zp42
	AND #$F0	; isolate upper nibble
	LSR A
	LSR A
	LSR A
	LSR A		; shift to upper nibble
	TAX		; as index in table
	LDA V_F8BF,X
	ASL A
	ORA zp45+1
	STA zp45+1
	LDA zp42
	AND #$0F	; lower nibble
	TAX		; as index
	LDA V_F8BF,X
	ROL A
	ROL A
	ROL A
	ROL A
	STA zp47
	ROL A
	AND #$01
	ORA zp45+1
	STA (zp27),Y	; in buffer
	INY		; increment buffer
	LDA zp43
	AND #$F0	; isolate hi-nibble
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA V_F8BF,X
	CLC
	ROR A
	ORA zp47
	STA (zp27),Y	; in buffer
	INY		; increment buffer pointer
	ROR A
	AND #$80
	STA zp48
	LDA zp43
	AND #$0F	; lower nibble
	TAX		; as index
	LDA V_F8BF,X
	ASL A
	ASL A
	AND #$7C
	ORA zp48
	STA zp48
	LDA zp44
	AND #$F0	; isolate hi-nibble
	LSR A
	LSR A
	LSR A
	LSR A		; shift to lower nibble
	TAX		; as index in table
	LDA V_F8BF,X
	ROR A
	ROR zp49
	ROR A
	ROR zp49
	ROR A
	ROR zp49
	AND #$03
	ORA zp48
	STA (zp27),Y	; in buffer
	INY		; increment buffer pointer
	BNE B_F8AF
	LDA zp1E+1
	STA zp27+1
	LDA #$00
	STA zp27
B_F8AF	LDA zp44
	AND #$0F	; lower nibble
	TAX		; as index
	LDA V_F8BF,X
	ORA zp49
	STA (zp27),Y	; in buffer
	INY		; increment buffer pointer
	STY zp2D	; and save
	RTS
;$F8BF  -------- GCR (5-bit) nybble table
V_F8BF	DB $0A,$0B,$12,$13,$0E,$0F,$16,$17
	DB $09,$19,$1A,$1B,$0D,$1D,$1E,$15
	;
	; Convert 260 bytes to 325 bytes group code
	;
	LDA #$00
	STA zp1E
	STA zp2E
	LDA #$60
	STA zp27
	LDA #$BB
	STA zp2D
	STA zp3F
	LDA zp27+1
	STA zp1E+1
	LDA #$00
	STA zp27+1
	LDA #$07
	STA zp41
	LDY zp2E
	LDA (zp1E),Y
	STA zp42
	INY
	LDA (zp1E),Y
	STA zp43
	INY
	LDA (zp1E),Y
	STA zp44
	INY
B_F8FC	STY zp2E
	JSR S_F80C
	LDY zp2E
	LDA (zp1E),Y
	STA zp41
	INY
	BEQ B_F91B
	LDA (zp1E),Y
	STA zp42
	INY
	LDA (zp1E),Y
	STA zp43
	INY
	LDA (zp1E),Y
	STA zp44
	INY
	BNE B_F8FC
B_F91B	LDA zp30
	STA zp42
	LDA #$00
	STA zp43
	STA zp44
	JMP S_F80C
	;
	; Convert 5 GCR bytes to 4 binary bytes
	;
S_F928	LDY zp2D
	LDA (zp27),Y
	TAX
	AND #$F8
	STA zp45
	TXA
	AND #$07
	STA zp45+1
	INY
	BNE B_F93F
	LDA zp36
	STA zp27+1
	LDY zp37
B_F93F	LDA (zp27),Y
	TAX
	AND #$C0
	ORA zp45+1
	STA zp45+1
	TXA
	AND #$3E
	STA zp47
	TXA
	AND #$01
	STA zp48
	INY
	LDA (zp27),Y
	TAX
	AND #$F0
	ORA zp48
	STA zp48
	TXA
	AND #$0F
	STA zp49
	INY
	LDA (zp27),Y
	TAX
	AND #$80
	ORA zp49
	STA zp49
	TXA
	AND #$7C
	STA zp49+1
	TXA
	AND #$03
	STA zp4B
	INY
	BNE B_F980
	LDA zp36
	STA zp27+1
	LDY zp37
	STY zp27
B_F980	LDA (zp27),Y
	TAX
	AND #$E0
	ORA zp4B
	STA zp4B
	TXA
	AND #$1F
	STA zp4C
	INY
	STY zp2D
	LDX zp45
	LDA V_F70C,X
	LDX zp45+1
	ORA V_F70C,X
	STA zp41
	LDX zp47
	LDA V_F70C,X
	LDX zp48
	ORA V_F70E,X
	STA zp42
	LDX zp49
	LDA V_F71C,X
	LDX zp49+1
	ORA V_F70D,X
	STA zp43
	LDX zp4B
	LDA V_F729,X
	LDX zp4C
	ORA V_F6FF,X
	STA zp44
	RTS
;$F9C2  --------
	LDA #$00
	STA zp2D
	STA zp1E
	STA zp2E
	LDA #$01
	STA zp36
	LDA #$1B
	STA zp37
	LDA zp27+1
	STA zp1E+1
	JSR S_F928
	LDA zp41
	STA zp2F
	LDY zp2E
	LDA zp42
	STA (zp1E),Y
	INY
	LDA zp43
	STA (zp1E),Y
	INY
	LDA zp44
	STA (zp1E),Y
	INY
B_F9EE	STY zp2E
	JSR S_F928
	LDY zp2E
	LDA zp41
	STA (zp1E),Y
	INY
	BEQ B_FA0D
	LDA zp42
	STA (zp1E),Y
	INY
	LDA zp43
	STA (zp1E),Y
	INY
	LDA zp44
	STA (zp1E),Y
	INY
	BNE B_F9EE
B_FA0D	LDA zp1E+1
	STA zp27+1
	RTS
;$FA12  --------
L_FA12	LDY zp32+1
	STA $0002,Y
	LDA zp3F
	BEQ B_FA1E
	JSR S_F618
B_FA1E	JSR S_FA36
	LDX zp3A
	TXS
	JMP L_F19D
	;
S_FA27	LDA #$A0
	STA zp2B
	LDA zp01
	ORA #$04
	STA zp01
	LDA #$A7
	STA zp39
	RTS
;$FA36  --------
S_FA36	LDA zp2B
	ORA #$10
	STA zp2B
	LDA #$FF
	STA zp39
	RTS
;$FA41  --------
L_FA41	LDA zp01	;
	AND #$10	; set write mode
	CMP zp24	; check previous mode, changed?
	STA zp24	;
	BNE B_FA51	; changed...
	LDA zpFE
	BNE B_FA61
	BEQ B_FA71
B_FA51	LDA #$FF
	STA zpFE
	LDA zp01
	ORA #$04	; set drive motor on
	STA zp01
	LDA #$01
	STA zp22
	BNE B_FA71
B_FA61	DEC zpFE
	BNE B_FA71
	LDA zp2B
	CMP #$00
	BNE B_FA71
	LDA zp01
	AND #$FB
	STA zp01
B_FA71	LDA zp54
	BEQ B_FA88
	CMP #$02
	BNE B_FA7F
	LDA #$00
	STA zp54
	BEQ B_FA88
B_FA7F	STA zp3B
	LDA #$02
	STA zp54
	JMP L_FAC5
	;
B_FA88	LDX zp31
	BMI B_FA93
	LDA zp2B
	TAY
	CMP #$20
	BNE B_FA96
B_FA93	JMP L_FB00
	;
B_FA96	DEC zp39
	BNE B_FAB5
	TYA
	BPL B_FAA1
	AND #$7F
	STA zp2B
B_FAA1	AND #$10
	BEQ B_FAB5
	LDA zp01
	AND #$FB
	STA zp01
	LDA #$FF
	STA zp31
	LDA #$00
	STA zp2B
	BEQ B_FA93
B_FAB5	TYA
	AND #$40
	BNE B_FABD
	JMP L_FB00
	;
B_FABD	LDA zp4D
	BNE B_FADC
	LDA zp3B
	BEQ B_FAD3
L_FAC5	LDA zp3B
	BPL B_FAED
	INC zp3B
	LDA zp01
	SEC
	SBC #$01
	JMP L_FAF4
	;
B_FAD3	LDA #$02
	STA zp39
	STA zp4D
	JMP L_FB00
	;
B_FADC	DEC zp39
	BNE L_FB00
	LDA zp2B
	AND #$BF
	STA zp2B
	LDA #$00
	STA zp4D
	JMP L_FB00
	;
B_FAED	DEC zp3B
	LDA zp01
	CLC
	ADC #$01
L_FAF4	AND #$03
	STA zp3C	; note drive head control state
	LDA zp01
	AND #$FC
	ORA zp3C
	STA zp01	; step motor
L_FB00	PLA
	TAY
	PLA
	TAX
	PLA
	RTI		; return from interrupt
;$FB06  --------
S_FB06	LDA #$05
	STA V_0100
B_FB0B	LDX #$1C
	JSR $FD87	; write $1c * 256 GCR gap bytes
	LDX #$14	; counter for repeat, exactly half of the 1541...
	LDY #$00	; .. due to 2x CPU clock frequency
	LDA #$FF
	STA V_4001	; $FF to write head
B_FB19	BIT zp01	; wait for byte-ready
	BPL B_FB19
	BIT V_4000	; delete byte-ready signal
	DEY
	BNE B_FB19
	DEX
	BNE B_FB19	; repeat 10240 / 2 times (1541 has X = #$28 !)
	JSR $FD79
	LDY #$FF
B_FB2B	LDX #$FF
B_FB2D	LDA V_4002
	AND #$40
	BEQ B_FB44
	DEX
	BNE B_FB2D
	DEY
	BNE B_FB2B
B_FB3A	DEC V_0100
	BNE B_FB0B
	LDA #$02
	JMP $FD6F
	;
B_FB44	LDY #$00
	LDX #$00
B_FB48	LDA V_4002
	AND #$40	; check SYNC
	BEQ B_FB48	; not encountered yet?
B_FB4F	LDA V_4002	; read SYNC
	INY
	BNE B_FB56	; Y not zero yet?
	INX
B_FB56	AND #$40	; check SYNC
	BNE B_FB4F	; no SYNC found, back
	STX V_0102	; found SYNC, note X and Y count
	STY V_0101
	LDA #$00
	STA zpFF
	LDX #$08
B_FB66	LDA V_F129,X
	CMP V_0102
	BEQ B_FB73
	DEX
	BPL B_FB66
	BMI B_FB3A
B_FB73	LDA V_F131 + 1,X
	STA V_0103
	RTS
;$FB7A  --------
L_FB7A	LDA zp40
	BPL B_FB99
	LDA #$60
	STA zp2B
	LDA #$01
	STA zp29
	STA zp40
	LDA #$A4
	STA zp3B
	LDA zp01
	AND #$FC	; drive motor off
	STA zp01
	LDA #$0A
	STA zp51
	JMP L_FA41
	;
B_FB99	LDY #$00
	LDA (zp20),Y
	CMP zp40
	BEQ B_FBA8
	LDA zp40
	STA (zp20),Y
	JMP L_FA41
	;
B_FBA8	LDA zp01
	AND #$10	; check write protect sensor
	BNE B_FBB3	; not protected...
	LDA #$08
	JMP $FD68
	;
B_FBB3	LDA zpFF
	BPL B_FBBA
	JSR S_FB06
B_FBBA	LDA V_0103
	STA zp4E
	CLC
	LDA #$03
	STA zp20+1
	LDA #$00
	STA zp20
	STA zp53
	LDY #$00
B_FBCC	LDA #$08
	STA (zp20),Y
	INY
	LDA #$00
	STA (zp20),Y
	INY
	LDA zp53
	STA (zp20),Y
	INY
	LDA zp40
	STA (zp20),Y
	INY
	LDA zp15
	STA (zp20),Y
	INY
	LDA zp14
	STA (zp20),Y
	INY
	LDA #$0F
	STA (zp20),Y
	INY
	STA (zp20),Y
	INY
	TYA
	PHA
	LDX #$07
	LDA #$00
	STA zp30
B_FBFA	DEY
	LDA (zp20),Y
	EOR zp30
	STA zp30
	DEX
	BNE B_FBFA
	STA (zp20),Y
	PLA
	TAY
	INC zp53
	LDA zp53
	CMP zp57
	BCC B_FBCC
	JSR $FDA9
	LDY #$BA
B_FC15	LDA (zp20),Y
	LDX #$45	; "E"
	STX zp20
	STA (zp20),Y
	LDX #$00
	STX zp20
	DEY
	CPY #$FF
	BNE B_FC15
	LDY #$44	; "D"
B_FC28	LDA V_011B,Y
	STA (zp20),Y
	DEY
	BPL B_FC28
	CLC
	LDA #$03
	ADC #$02
	STA zp27+1
	LDA #$00
	TAY
B_FC3A	STA (zp27),Y
	INY
	BNE B_FC3A
	JSR S_F60A
	JSR S_F8CD + 2
	LDA #$00
	STA zp4E+1
	LDX #$03
	JSR $FD87	; write 3 * 256 GCR gap bytes
L_FC4E	LDA #$FF
	STA V_4001	; $FF to write head
	LDY #$05	; write 5 pieces of $FF (sync) bytes
B_FC55	BIT zp01	; wait on byte-ready
	BPL B_FC55
	BIT V_4000	; clear byte-ready signal
	DEY
	BNE B_FC55	; repeat
	LDA #$0A
	STA zp50
	LDY zp4E+1
B_FC65	BIT zp01	; wait on byte-ready
	BPL B_FC65
	BIT V_4000	; clear byte-ready signal
	LDA (zp20),Y
	STA V_4001
	INY
	DEC zp50	; repeat 10 times
	BNE B_FC65
	LDY #$09
B_FC78	BIT zp01	; wait on byte-ready
	BPL B_FC78
	BIT V_4000	; clear byte-ready signal
	LDA #$55	; GCR code for inter-sector gap
	STA V_4001	; write to disk
	DEY
	BNE B_FC78	; repeat this 9 times
	LDA #$FF
	LDY #$05
B_FC8B	BIT zp01	; wait on byte-ready
	BPL B_FC8B
	BIT V_4000	; clear byte-ready signal
	STA V_4001	; write 5 sync bytes to disk
	DEY
	BNE B_FC8B
	LDY #$BB
B_FC9A	BIT zp01
	BPL B_FC9A	; wait on byte-ready
	BIT V_4000	; clear byte-ready signal
	LDA $0060,Y
	STA V_4001	; write buffer contents to disk
	INY
	BNE B_FC9A	; repeat $BB (187) times
B_FCAA	BIT zp01
	BPL B_FCAA	; wait on byte-ready
	BIT V_4000	; clear byte-ready signal
	LDA (zp27),Y
	STA V_4001	; write buffer contents to disk
	INY
	BNE B_FCAA
	LDA #$55	; GAP
	LDY zp4E
B_FCBD	BIT zp01
	BPL B_FCBD	; wait on byte-ready
	BIT V_4000	; clear byte-ready signal
	STA V_4001	; write GCR GAP
	DEY
	BNE B_FCBD
	LDA zp4E+1
	CLC
	ADC #$0A	; add 10 (interleave)
	STA zp4E+1
	DEC zp53
	BEQ B_FCD8
	JMP L_FC4E
	;
B_FCD8	BIT zp01	; wait on byte-ready
	BPL B_FCD8
	BIT V_4000	; clear byte-ready signal
B_FCDF	BIT zp01
	BPL B_FCDF	; wait on byte-ready
	BIT V_4000	; clear byte-ready signal
	JSR $FD79
	LDA #$C8
	STA zp52
B_FCED	LDA #$00
	STA zp4E+1
	LDA zp57
	STA zp53
B_FCF5	LDA #$0A
	STA zp50
	JSR L_F560
	LDY zp4E+1
B_FCFE	LDA (zp20),Y
B_FD00	BIT zp01	; wait on byte-ready
	BPL B_FD00
	BIT V_4000	; clear byte-ready signal
	CMP V_4001	; verify
	BNE $FD1B
	INY
	DEC zp50
	BNE B_FCFE
	CLC
	LDA zp4E+1
	ADC #$0A
	STA zp4E+1
	JMP $FD24
	;
$FD1B	DEC zp52
	BNE B_FCED
	LDA #$06
	JMP $FD68
	;
$FD24	JSR L_F560
	LDY #$BB
$FD29	LDA $0060,Y
$FD2C	BIT zp01	; wait on byte-ready
	BPL $FD2C
	BIT V_4000	; clear byte-ready signal
	CMP V_4001	; verify what's read
	BNE $FD1B
	INY
	BNE $FD29
$FD3B	LDA (zp27),Y
$FD3D	BIT zp01	; wait on byte-ready
	BPL $FD3D
	BIT V_4000	; clear byte-ready signal
	CMP V_4001	; verify
	BNE $FD1B
	INY
	BNE $FD3B
	DEC zp53
	BNE B_FCF5
	INC zp40
	LDA zp40
	CMP #$24
	BCS $FD5B
	JMP L_FA41
	;
$FD5B	LDA #$FF
	STA zp40
	LDA #$00
	STA zp3F
	LDA #$01
	JMP L_FA12
	;
$FD68	DEC zp51
	BEQ $FD6F
	JMP L_FA41
	;
$FD6F	LDY #$FF
	STY zp40
	INY
	STY zp3F
	JMP L_FA12
	;
	; Initialise read mode
	;
$FD79	LDA V_4002
	ORA #$10
	STA V_4002	; set head to read mode
	LDA #$00	; TIA port B to input
	STA V_4004
	RTS

;$FD87  -------- Write GCR gap bytes ($55) to - erase - current track

$FD87	LDA V_4002
	AND #$EF
	STA V_4002	; set head to write mode
	LDA #$FF
	STA V_4004	; TIA port B to output
	LDA #$55	; GCR gap byte
	STA V_4001	; write...
	LDY #$00
$FD9B	BIT zp01	; wait on byte-ready
	BPL $FD9B
	BIT V_4000	; clear byte-ready signal
	DEY
	BNE $FD9B
	DEX
	BNE $FD9B	; repeat this 256 * X times
	RTS

;$FDA9  -------- Convert header in buffer 0 to GCR code

$FDA9	LDA #$00
	STA zp27+1
	STA zp1E
	STA zp2E
	LDA #$BB
	STA zp2D
	LDA #$60
	STA zp27
	CLC
	LDA #$03
	STA zp1E+1	; source buffer is at $1E/$1F
$FDBE	LDY zp2E
	LDA (zp1E),Y	; read 4 normal bytes to $41,$42,$43,$44
	STA zp41
	INY
	LDA (zp1E),Y
	STA zp42
	INY
	LDA (zp1E),Y
	STA zp43
	INY
	LDA (zp1E),Y
	STA zp44
	INY
	BEQ $FDDE
	STY zp2E
	JSR S_F80C
	JMP $FDBE
	;
$FDDE	JMP S_F80C
	;
	STA (zpFF,X)
; $FDE3
	DB $FF,$FF,$FF
; $FDE6
	DB $FF,$FF,$FF
; $FDE9
	DB $FF,$FF,$FF
; $FDEC
	DB $FF,$FF,$FF
; $FDEF
	DB $FF,$FF,$FF
; $FDF2
	DB $FF,$FF,$FF
; $FDF5
	DB $FF,$FF,$FF
; $FDF8
	DB $FF,$FF,$FF
; $FDFB
	DB $FF,$FF,$FF
; $FDFE
	DB $FF,$FF
V_FE00	DB $FF
; $FE01
	DB $FF,$FF,$FF
; $FE04
	DB $FF,$FF,$FF
; $FE07
	DB $FF,$FF,$FF
; $FE0A
	DB $FF,$FF,$FF
; $FE0D
	DB $FF,$FF,$FF
; $FE10
	DB $FF,$FF,$FF
; $FE13
	DB $FF,$FF,$FF
; $FE16
	DB $FF,$FF,$FF
; $FE19
	DB $FF,$FF,$FF
; $FE1C
	DB $FF,$FF,$FF
; $FE1F
	DB $FF,$FF,$FF
; $FE22
	DB $FF,$FF,$FF
; $FE25
	DB $FF,$FF,$FF
; $FE28
	DB $FF,$FF,$FF
; $FE2B
	DB $FF,$FF,$FF
; $FE2E
	DB $FF,$FF,$FF
; $FE31
	DB $FF,$FF,$FF
; $FE34
	DB $FF,$FF,$FF
; $FE37
	DB $FF,$FF,$FF
; $FE3A
	DB $FF,$FF,$FF
; $FE3D
	DB $FF,$FF,$FF
; $FE40
	DB $FF,$FF,$FF
; $FE43
	DB $FF,$FF,$FF
; $FE46
	DB $FF,$FF,$FF
; $FE49
	DB $FF,$FF,$FF
; $FE4C
	DB $FF,$FF,$FF
; $FE4F
	DB $FF,$FF,$FF
; $FE52
	DB $FF,$FF,$FF
; $FE55
	DB $FF,$FF,$FF
; $FE58
	DB $FF,$FF,$FF
; $FE5B
	DB $FF,$FF,$FF
; $FE5E
	DB $FF,$FF,$FF
; $FE61
	DB $FF,$FF,$FF
; $FE64
	DB $FF,$FF,$FF
; $FE67
	DB $FF,$FF,$FF
; $FE6A
	DB $FF,$FF,$FF
; $FE6D
	DB $FF,$FF,$FF
; $FE70
	DB $FF,$FF,$FF
; $FE73
	DB $FF,$FF,$FF
; $FE76
	DB $FF,$FF,$FF
; $FE79
	DB $FF,$FF,$FF
; $FE7C
	DB $FF,$FF,$FF
; $FE7F
	DB $FF,$FF,$FF
; $FE82
	DB $FF,$FF,$FF
; $FE85
	DB $FF,$FF,$FF
; $FE88
	DB $FF,$FF,$FF
; $FE8B
	DB $FF,$FF,$FF
; $FE8E
	DB $FF,$FF,$FF
; $FE91
	DB $FF,$FF,$FF
; $FE94
	DB $FF,$FF,$FF
; $FE97
	DB $FF,$FF,$FF
; $FE9A
	DB $FF,$FF,$FF
; $FE9D
	DB $FF,$FF,$FF
; $FEA0
	DB $FF,$FF,$FF
; $FEA3
	DB $FF,$FF,$FF
; $FEA6
	DB $FF,$FF,$FF
; $FEA9
	DB $FF,$FF,$FF
; $FEAC
	DB $FF,$FF,$FF
; $FEAF
	DB $FF,$FF,$FF
; $FEB2
	DB $FF,$FF,$FF
; $FEB5
	DB $FF,$FF,$FF
; $FEB8
	DB $FF,$FF,$FF
; $FEBB
	DB $FF,$FF,$FF
; $FEBE
	DB $FF,$FF,$FF
; $FEC1
	DB $FF,$FF,$FF
; $FEC4
	DB $FF,$FF,$FF
; $FEC7
	DB $FF,$FF,$FF
; $FECA
	DB $FF,$FF,$FF
; $FECD
	DB $FF,$FF,$FF
; $FED0
	DB $FF,$FF,$FF
; $FED3
	DB $FF,$FF,$FF
; $FED6
	DB $FF,$FF,$FF
; $FED9
	DB $FF,$FF,$FF
; $FEDC
	DB $FF,$FF,$FF
; $FEDF
	DB $FF,$FF,$FF
; $FEE2
	DB $FF,$FF,$FF
; $FEE5
	DB $FF,$FF,$FF
; $FEE8
	DB $FF,$FF,$FF
; $FEEB
	DB $FF,$FF,$FF
; $FEEE
	DB $FF,$FF,$FF
; $FEF1
	DB $FF,$FF,$FF
; $FEF4
	DB $FF,$FF,$FF
; $FEF7
	DB $FF,$FF,$FF
; $FEFA
	DB $FF,$FF,$FF
; $FEFD
	DB $FF,$FF,$FF
; $FF00
V_FF00	DB $FF,$FF,$FF
; $FF03
	DB $FF,$FF,$FF
; $FF06
	DB $FF,$FF,$FF
; $FF09
	DB $FF,$FF,$FF
; $FF0C
	DB $FF,$FF,$FF
; $FF0F
	DB $FF,$FF,$FF
; $FF12
	DB $FF,$FF,$FF
; $FF15
	DB $FF,$FF,$FF
; $FF18
	DB $FF,$FF,$FF
; $FF1B
	DB $FF,$FF,$FF
; $FF1E
	DB $FF,$FF,$FF
; $FF21
	DB $FF,$FF,$FF
; $FF24
	DB $FF,$FF,$FF
; $FF27
	DB $FF,$FF,$FF
; $FF2A
	DB $FF,$FF,$FF
; $FF2D
	DB $FF,$FF,$FF
; $FF30
	DB $FF,$FF,$FF
; $FF33
	DB $FF,$FF,$FF
; $FF36
	DB $FF,$FF,$FF
; $FF39
	DB $FF,$FF,$FF
; $FF3C
	DB $FF,$FF,$FF
; $FF3F
	DB $FF,$FF,$FF
; $FF42
	DB $FF,$FF,$FF
; $FF45
	DB $FF,$FF,$FF
; $FF48
	DB $FF,$FF,$FF
; $FF4B
	DB $FF,$FF,$FF
; $FF4E
	DB $FF,$FF,$FF
; $FF51
	DB $FF,$FF,$FF
; $FF54
	DB $FF,$FF,$FF
; $FF57
	DB $FF,$FF,$FF
; $FF5A
	DB $FF,$FF,$FF
; $FF5D
	DB $FF,$FF,$FF
; $FF60
	DB $FF,$FF,$FF
; $FF63
	DB $FF,$FF,$FF
; $FF66
	DB $FF,$FF,$FF
; $FF69
	DB $FF,$FF,$FF
; $FF6C
	DB $FF,$FF,$FF
; $FF6F
	DB $FF,$FF,$FF
; $FF72
	DB $FF,$FF,$FF
; $FF75
	DB $FF,$FF,$FF
; $FF78
	DB $FF,$FF,$FF
; $FF7B
	DB $FF,$FF,$FF
; $FF7E
	DB $FF,$FF,$FF
; $FF81
	DB $FF,$FF,$FF
; $FF84
	DB $FF,$FF,$FF
; $FF87
	DB $FF,$FF,$FF
; $FF8A
	DB $FF,$FF,$FF
; $FF8D
	DB $FF,$FF,$FF
; $FF90
	DB $FF,$FF,$FF
; $FF93
	DB $FF,$FF,$FF
; $FF96
	DB $FF,$FF,$FF
; $FF99
	DB $FF,$FF,$FF
; $FF9C
	DB $FF,$FF,$FF
; $FF9F
S_FF9F	DB $FF,$FF,$FF
; $FFA2
	DB $FF,$FF,$FF
; $FFA5
	DB $FF,$FF,$FF
; $FFA8
	DB $FF,$FF,$FF
; $FFAB
	DB $FF,$FF,$FF
; $FFAE
	DB $FF,$FF,$FF
; $FFB1
	DB $FF,$FF,$FF
; $FFB4
	DB $FF,$FF,$FF
; $FFB7
	DB $FF,$FF,$FF
; $FFBA
	DB $FF,$FF,$FF
; $FFBD
	DB $FF,$FF,$FF
; $FFC0
	DB $FF,$FF,$FF
; $FFC3
	DB $FF,$FF,$FF
; $FFC6
	DB $FF,$FF,$FF
; $FFC9
	DB $FF,$FF,$FF
; $FFCC
	DB $FF,$FF,$FF
; $FFCF
	DB $FF,$FF,$FF
; $FFD2
	DB $FF,$FF,$FF
; $FFD5
	DB $FF,$FF,$FF
; $FFD8
	DB $FF,$FF,$FF
; $FFDB
	DB $FF,$FF,$FF
; $FFDE
	DB $FF,$FF,$FF
; $FFE1
	DB $FF,$FF,$FF
; $FFE4
	DB $FF,$FF,$A7,$C9,$3B,$F1,$51,$CE,$8B,$CE,$00,$05
	DB $03,$05,$06,$05,$09,$05,$0C,$05,$0F,$05,$39,$EA,$B5,$E9,$95,$F1
; EOF
