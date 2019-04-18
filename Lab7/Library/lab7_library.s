	.data
song: .string "D5-D4-RRA4---D4-D5---E5-E4-RRA4---E4-E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4---E4-E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-B5-B4-A5---A4-g5---A4-E5-D5-"
m2: .string "--D4-RRA4-D4---D5---E5-E4-RRA4-E4---E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4-A3---E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-E6-E5-A5--A4--G5-g5-A4-E5---;"

board0: .string  "|---------------------------------------------|", 0xD, 0xA
board1: .string  "|*********************************************|", 0xD, 0xA
board2: .string  "|*****     *****     *****     *****     *****|", 0xD, 0xA
board3: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board4: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board5: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board6: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board7: .string  "|.............................................|", 0xD, 0xA
board8: .string  "|                                             |", 0xD, 0xA
board9: .string  "|                                             |", 0xD, 0xA
board10: .string "|                                             |", 0xD, 0xA
board11: .string "|                                             |", 0xD, 0xA
board12: .string "|                                             |", 0xD, 0xA
board13: .string "|                                             |", 0xD, 0xA
board14: .string "|......................&......................|", 0xD, 0xA
board15: .string "|---------------------------------------------|", 0xD, 0xA, 0x0
language: .string "1234567890qwertyuiopasdfghjklzxcvbnm!@#$%^&*()_", 0xD, 0xA, 0
frogLocation: .word 0x2C5
previousFrogValue: .word 0x2E
previousFrogLocation: .word 0x41D
settings: .word 0x0
GAME_STATUS: .word 0x0; if game is running, this value is 0, if the game is over, or has not started yet, it is a 1, and 2 if the game is paused.
BOARD_UPDATE: .byte 0x0 ; if this is not 0 the game moves the obstacles on the board
FROG_LIVES: .byte 0x4 ; the game lives, if this reaches 0 the game is over
PLAYER_SCORE: .word 0x0; this is the player's score, this should be displayed once the game is over
WIN_COUNTER: .byte 0x0; this counter is incremented every time the player gets to the other end of the board safely, should be reset when it reaches 3, and the game should "level up"
	.text
	.global lab7_library
	.global uart_init
	.global read_character
	.global output_character
	.global output_string
	.global interrupt_init
	.global GPIO_init
	.global read_from_keypad
	.global button_table
	.global Uart0Handler
	.global PortAHandler
	.global virtual_ALU
	.global Timer0Handler
	.global Timer1Handler
	.global Timer2Handler
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global rng
	.global playNote
	.global shiftString
	.global redrawBoard
	.global div_and_mod
	.global shift_string
	.global fill_string
	.global check_valid_location

	.global mode
songPtr: .word song
boardPtr: .word board0
languagePtr: .word language
settingsPtr: .word settings
frogLocationPtr: .word frogLocation
previousFrogValuePtr: .word previousFrogValue
previousFrogLocationPtr: .word previousFrogLocation
;Game variable pointers:
GAME_STATUS_PTR: .word GAME_STATUS
BOARD_UPDATE_PTR: .word BOARD_UPDATE
FROG_LIVES_PTR: .word FROG_LIVES
PLAYER_SCORE_PTR: .word PLAYER_SCORE
WIN_COUNTER_PTR: .word WIN_COUNTER
modePtr: .word 0x20005000
;-------------------------------------------------------------




Uart0Handler:
	STMFD SP!, {lr, r0-r12}
		;clear UART interrupt
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDRB r1, [r4, #0x044]
	ORR r1, r1, #0x10
	STRB r1, [r4, #0x044]


	LDR r0, GAME_STATUS_PTR
	LDRB r0,[r0]
	CMP r0, #0
	BNE gameRunning


	MOV r4, #0x0000
	MOVT r4, #0x4003
	BL read_character
	CMP r0, #'m'
	BNE notR
	LDR r1, [r4, #0xC] ;toggle timer 0
	EOR r1, r1, #0x1
	STR r1, [r4, #0xC]
	MOV r4, #0x1000
	MOVT r4, #0x4003
	LDR r1, [r4, #0xC] ;timer 1 off
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]


notR:

	CMP r0, #'1'
	BNE not1
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
;----------------------
not1:
	CMP r0, #'2'
	BNE not2
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
;---------------------
not2:
	CMP r0, #'3'
	BNE not3
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]

not3:
	CMP r0, #'0'
	BNE not0
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
not0:


	MOV r4, #0x0000
	MOVT r4, #0x4003

	LDMFD SP!, {lr, r0-r12}
	BX lr

gameRunning:

	BL read_character	;read UART value

	MOV r3, #0x0
	CMP r0, #0x77		;if UART value is w do the following:
	BNE notW
	SUB r3, r3, #49
notW:
	CMP r0, #0x61		;if UART value is A do the following:
	BNE notA
	SUB r3, r3, #1


notA:

	CMP r0, #0x73
	BNE notS
	ADD r3, r3, #49
notS:
	CMP r0, #0x64
	BNE notD
	ADD r3, r3, #1
notD:
	CMP r3,#0
	BEQ notValidKey

	;get frog location
	LDR r4, boardPtr
	LDR r9, frogLocationPtr
	LDR r10, [r9]
	;calculate new frog location
	ADD r5, r10, r3
	;get value at new frog location
	LDRB r7,[r4,r5]
	;check if its a valid postion
	;replace frog with prevous value
	LDR r8, previousFrogValuePtr
	LDR r11, [r8]
	STRB r11, [r4,r10]
	;save value at new frog location to previousFrogValue
	STR r7,[r8]
	;set previousFrogLocation to frogLocation
	LDR r8, previousFrogLocationPtr
	STR r10,[r8]
	;set new frog location to frog location
	STR r5, [r9]
	;store frog in new location
	MOV r7,#0x26
	STRB r7,[r4,r5]

	MOV r2, #0x3800
	MOVT r2, #0x1
	LDR r1, [r4, #0x28]
	SUB r1, r1, r2
	STR r1, [r4, #0x28]
	LDR r1, [r4, #0xC] ;enable timer 0
	EOR r1, r1, #0x1
	STR r1, [r4, #0xC]

notValidKey:
	BL output_string

	LDMFD SP!, {lr, r0-r12}
	BX lr

Timer0Handler:
	STMFD SP!, {lr, r3-r5, r7-r11}
	MOV r4, #0
	MOVT r4, #0x4003
	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]
	BL nextNote

	; handle game stuff here:

	;TODO: update frog position, flip boardupdate bit, shift game rows if boardupdate is true, redraw game board

	; if valid position for frog, continue and add to score, else subtract life

	;if life == 0, set game over to true

	;is position a fly? if so, add to score and replace fly

	; is a winning tile? add to score, add to win counter, restart game

		; if win counter == 3, increase clock period by .05 seconds
	LDMFD SP!, {lr, r3-r5, r7-r11}
	BX lr


Timer1Handler:
	STMFD SP!, {lr, r0-r12}
	MOV r4, #0x1000
	MOVT r4, #0x4003
	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]
	; invert signal of pin 4 of port C
	MOV r4, #0x6000
	MOVT r4, #0x4000 ;store base address of Port C to r4
	LDRB r0, [r4, #0x3FC]
	EOR r0, #0x10
	STRB r0, [r4, #0x3FC]

	LDMFD SP!, {lr, r0-r12}
	BX lr

Timer2Handler: ;Main handler
	STMFD SP!, {lr, r1-r5, r7-r11}
	MOV r4, #0
	MOVT r4, #0x4003
	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]

	; handle game stuff here:


	;TODO: update frog position, flip boardupdate bit, shift game rows if boardupdate is true, redraw game board

	; if valid position for frog, continue and add to score, else subtract life

	;if life == 0, set game over to true

	;is position a fly? if so, add to score and replace fly

	; is a winning tile? add to score, add to win counter, restart game

		; if win counter == 3, increase clock period by .05 seconds
	LDMFD SP!, {lr, r1-r5, r7-r11}
	BX lr


PortAHandler:   ;if keypad gets a input this subroutine will check the value given by uart, if its not 0x0D then it will print it out and stores
				;it on the stack if the value is 0x0D then it will run the virtual alu and print the result to the screen
	STMFD SP!, {lr, r0-r12}
	MOV r4, #0x7000
	MOVT r4, #0x4000
	MOV r1, #0
	STRB r1, [r4, #0x3FC]
   	MOV r4, #0x4000
	MOVT r4, #0x4000
	;disable interrupts
	MOV r3, #0xE000
	MOVT r3, #0xE000
	STRB r2, [r3, #0x180]
	ORR r2, r2, #0x1F
	LDRB r2, [r3, #0x180]
	;do stuff on keyboard press here: -----------------------------------------
	BL read_from_keypad
	MOV r1, #0x00DF
	MOVT r1, #0x0000
delayLoop:				;delay to syncronize buttons
	SUB r1, r1, #1
	CMP r1, #0
	BNE delayLoop

	BL button_table		; run button_table
	BL buttonOptions

	;-------------------------------------------------------
	MOV r4, #0x4000
	MOVT r4, #0x4000
	;clear interrupts
	LDR r1, [r4, #0x41C]
	ORR r1, #0x3C
	STR r1, [r4, #0x41C]

	;enable interrupts again
	STRB r2, [r3, #0x100]
	ORR r2, r2, #0x1
	LDRB r2, [r3, #0x100]
	LDMFD SP!, {lr, r0-r12}
	BX lr

buttonOptions:
	STMFD SP!, {lr, r0-r12}
	LDR r4, settingsPtr
	LDR r3, [r4]
	CMP r0, #0x31	;if button 1(pause) is clicked, disable all interrupts except gpio
	BNE notPause
	MOV r5, #0x1
	AND r5,r5,r3
	CMP r5,#0
	BNE unPause
	ORR r3, #0x1
	STR r3, [r4]
	MOV r4, #0xE000
	MOVT r4, #0xE000
	LDR r1, [r4, #0x180]
	MOV r2, #0x36
	MOVT r2, #0x28
	ORR r1, r1, r2
	STR r1, [r4, #0x180]
	LDMFD SP!, {lr, r0-r12}
	BX lr
unPause:
	BIC r3, #0x1
	STR r3, [r4]
	LDR r1, [r4, #0x100]
	MOV r2, #0x36
	MOVT r2, #0x28
	ORR r1, r1, r2
	STR r1, [r4, #0x180]
	LDMFD SP!, {lr, r0-r12}
	BX lr
notPause:
	CMP r0, #0x32	;if button 2(quit) is clicked, disable all interrupt and exit infinate loop
	BNE notQuit
	ORR r3, #0x2
	STR r3, [r4]
	MOV r2, #0x2F
	MOVT r2, #0x28
	ORR r1, r1, r2
	STR r1, [r4, #0x180]
	LDMFD SP!, {lr, r0-r12}
	BX lr
notQuit:
	CMP r0, #0x33	;if button 3(mute/unmute) is clicked, disable/enable music
	BNE notMute
	MOV r10, #0x6000
	MOVt r10, #0x4000; address for port C
	MOV r5, #0x4
	AND r5, r5, r3
	CMP r5,#0
	BNE unMute
	ORR r3, #0x1
	STR r3, [r4]
	LDRB r1, [r10, #0x400]
	BIC r1, #0x10
	STRB r1, [r10, #0x400]; set speaker pin to output
	LDRB r1, [r10, #0x51C]
	BIC r1, #0x10
	STRB r1, [r10, #0x51C] ; enables speaker pin to digital
	LDMFD SP!, {lr, r0-r12}
	BX lr
unMute:
	BIC r3, #0x1
	STR r3, [r4]
	LDRB r1, [r10, #0x400]
	ORR r1, #0x10
	STRB r1, [r10, #0x400]; set speaker pin to output
	LDRB r1, [r10, #0x51C]
	ORR r1, #0x10
	STRB r1, [r10, #0x51C] ; enables speaker pin to digital
	LDMFD SP!, {lr, r0-r12}
	BX lr
notMute:
	LDMFD SP!, {lr, r0-r12}
	BX lr


nextNote:
	STMFD SP!, {lr, r3-r5, r7-r12}



restartSong:
	LDR r4, songPtr
	ADD r4, r4, r6
	BL playNote ; gets the next note from string in memory
	MOV r4, #0x1000
	MOVT r4, #0x4003
	CMP r0, #0x2D
	ITT EQ
	ADDEQ r6, r6, #0x1
	BEQ holdNote
	LDR r1, [r4, #0xC] ;disable timer 1
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]
	CMP r0, #0xF
	IT EQ
	MOVEQ r6, #0x0
	BEQ restartSong


	ADD r6, r6, #0x1 ;increase pointer offset
	MOV r4, #0x1000
	MOVT r4, #0x4003
	CMP r0, #0x0
	BEQ timerOff
	LDR r1, [r4, #0x28] ;set to new value
	MOV r1, r0
	STR r1, [r4, #0x28]
holdNote:
	LDR r1, [r4, #0xC] ;enable timer 1
	ORR r1, r1, #0x1
	STR r1, [r4, #0xC]
timerOff:

	LDMFD SP!, {lr, r3-r5, r7-r12}
	BX lr



redrawBoard:	;shifts strings and redraws board
	STMFD SP!, {lr, r0-r12}
	LDR r4, boardPtr
	BL output_string
	MOV r0, #3
	MOV r1, #7
	MOV r2, #1
	BL shiftSetOfRows

	LDR r5, frogLocationPtr
	LDR r7,[r5]
	LDR r3, previousFrogValuePtr
	LDR r3, [r3]
	STRB r3,[r4,r7]

	MOV r0, #8
	MOV r1, #14
	MOV r2, #1
	BL shiftSetOfRows
	;check for conflicts
	MOV r3, #0x26
	STRB r3,[r4,r7]
	BL output_string
	LDMFD SP!, {lr, r0-r12}
	BX lr

shiftSetOfRows:	;r0 starting row
				;r1 ending row
				;r2 set shift pattern
	STMFD SP!, {lr, r3-r12}
	MOV r3, r0
	MOV r9, r1
	MOV r5, #49
	ADD r8, r2, #1
shiftLines:
	CMP r3, #7
	BEQ shiftLines
	MUL r7, r3, r5
	MOV r0, r4
	ADD r0, r0, r7
	ADD r0, r0, #1
	MOV r1, #45
	BL shift_string
	MOV r1, r8
	MOV r0, #2
	BL div_and_mod
	MOV r2, r0
	ADD r8, r8, #1
	ADD r3, r3, #1
	CMP r3, r9
	BNE shiftLines
	LDMFD SP!, {lr, r3-r12}
	BX lr

check_valid_location:
	STMFD SP!, {lr, r3-r12}

	MOV r0, #0x1

	CMP r1, #100
	IT GT
	MOVGT r0, #0x2

	CMP r1, #145
	IT GT
	MOVGT r0, #0x1

	CMP r2, #'*'
	IT EQ
	MOVEQ r0, #0x0


	CMP r2, #'A'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'-'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'|'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'C'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'#'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'H'
	IT EQ
	MOVEQ r0, #0x0

	CMP r2, #'~'
	IT EQ
	MOVEQ r0, #0x0


	LDMFD SP!, {lr, r3-r12}





.end
