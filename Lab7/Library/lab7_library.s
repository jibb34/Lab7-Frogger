	.data

; GAME VARIABLES GO HERE -------------------------------------------------------
GAME_STATUS: .word 0x0; if game is running, this value is 0, if the game is over, or has not started yet, it is a 1, and 2 if the game is paused.
BOARD_UPDATE: .byte 0x0 ; if this is not 0 the game moves the obstacles on the board
FROG_LIVES: .byte 0x4 ; the game lives, if this reaches 0 the game is over
PLAYER_SCORE: .word 0x0; this is the player's score, this should be displayed once the game is over
WIN_COUNTER: .byte 0x0; this counter is incremented every time the player gets to the other end of the board safely, should be reset when it reaches 3, and the game should "level up"

;--------------------------------------------------------------------------------
board1: .string  "|---------------------------------------------|", 0xD, 0xA
board2: .string  "|*********************************************|", 0xD, 0xA
board3: .string  "|*****     *****     *****     *****     *****|", 0xD, 0xA
board4: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board5: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board6: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board7: .string  "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xD, 0xA
board8: .string  "|.............................................|", 0xD, 0xA
board9: .string  "|                                             |", 0xD, 0xA
board10: .string "|                                             |", 0xD, 0xA
board11: .string "|                                             |", 0xD, 0xA
board12: .string "|                                             |", 0xD, 0xA
board13: .string "|                                             |", 0xD, 0xA
board14: .string "|                                             |", 0xD, 0xA
board15: .string "|......................&......................|", 0xD, 0xA
board16: .string "|---------------------------------------------|", 0xD, 0xA, 0x0
language: .string "1234567890qwertyuiopasdfghjklzxcvbnm!@#$%^&*()_", 0xD, 0xA, 0
	.text
	.global lab7_library
	.global read_character
	.global output_character
	.global output_string
	.global read_from_keypad
	.global button_table
	.global Uart0Handler
	.global PortAHandler
	.global Timer0Handler
	.global Timer1Handler
	.global Timer2Handler
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global rng
	.global playNote
	.global shift_string
	.global fill_string
	.global mode
song: .string "D5-D4-RRA4---D4-D5---E5-E4-RRA4---E4-E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4---E4-E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-B5-B4-A5---A4-g5---A4-E5-D5-"
m2: .string "--D4-RRA4-D4---D5---E5-E4-RRA4-E4---E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4-A3---E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-E6-E5-A5--A4--G5-g5-A4-E5---;"
boardPtr: .word board1
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
	MOV r4, #0x0000
	MOVT r4, #0x4003
	BL read_character
	CMP r0, #0x72
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

	CMP r0, #0x31
	BNE not1
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
;----------------------
not1:
	CMP r0, #0x32
	BNE not2
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
;---------------------
not2:
	CMP r0, #0x33
	BNE not3
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]

not3:
	CMP r0, #0x30
	BNE not0
	SUB r0, r0, #0x30
	LDR r1, modePtr
	STRB r0, [r1]
not0:
	LDMFD SP!, {lr, r0-r12}
	BX lr

Timer0Handler: ;handels music speed
	STMFD SP!, {lr, r1-r5, r7-r11}
	MOV r4, #0
	MOVT r4, #0x4003


	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]

	BL nextNote
	LDMFD SP!, {lr, r1-r5, r7-r11}
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
	STMFD SP!, {lr, r0-r5, r7-r12}
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
	LDMFD SP!, {lr, r0-r5, r7-r12}
	BX lr


nextNote:
	STMFD SP!, {lr, r3-r5, r7-r12}

restartSong:
	ADR r4, song
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





.end
