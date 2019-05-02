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
PLAYER_SCORE: .word 0x0
GAME_TIMER: .word 0x3C
InfoDisplay: .string "Your Current Score is: ", 0x0
PLAYER_SCORE_ASCII: .word 0x0 ; this is the player's score, this should be displayed once the game is over
PLAYER_SCORE_ASCII_BUFFER: .word 0x0 ;buffer for player score
timerDisplay: .string "Time Left: ",0x0
GAME_TIMER_ASCII: .word 0x0

GAME_STATUS: .word 0x0 ; if game is running, this value is 0, if the game is over, or has not started yet, it is a 1, and 2 if the game is paused.
BOARD_UPDATE: .byte 0x0 ; if this is not 0 the game moves the obstacles on the board
FROG_LIVES: .byte 0x4 ; the game lives, if this reaches 0 the game is over
WIN_COUNTER: .byte 0x0 ; this counter is incremented every time the player gets to the other end of the board safely, should be reset when it reaches 3, and the game should "level up"
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
	.global output_7_seg
	.global shiftSetOfRows
	.global spawnWaterTile
	.global spawnRoadTile
	.global generateRandomCharacter
	.global checkForSpawn
	.global mode
	.global update_game_information
	.global convertToAscii
songPtr: .word song
boardPtr: .word board0
languagePtr: .word language
settingsPtr: .word settings
frogLocationPtr: .word frogLocation
previousFrogValuePtr: .word previousFrogValue
previousFrogLocationPtr: .word previousFrogLocation
;Game variable pointers:
GAME_STATUS_PTR: .word GAME_STATUS
GAME_TIMER_PTR: .word GAME_TIMER
GAME_TIMER_ASCII_PTR: .word GAME_TIMER_ASCII
BOARD_UPDATE_PTR: .word BOARD_UPDATE
FROG_LIVES_PTR: .word FROG_LIVES
PLAYER_SCORE_ASCII_PTR: .word PLAYER_SCORE_ASCII
PLAYER_SCORE_PTR: .word PLAYER_SCORE
WIN_COUNTER_PTR: .word WIN_COUNTER
INFO_DISPLAY_PTR: .word InfoDisplay
TIMER_DISPLAY_PTR: .word timerDisplay
modePtr: .word 0x20005000
;-------------------------------------------------------------

levelUp:
	STMFD SP!, {lr, r0-r12}
	MOV r4, #0x2000
	MOVT r4, #0x4003
	LDR r1, [r4, #0x28]
	MOV r2, #0x3500
	MOVT r2, #0xC
	SUB r1, r1, r2
	STR r1, [r4, #0x28]
	;reset board


	LDMFD SP!, {lr, r0-r12}
	BX lr
update_game_information: ; r0 - game status, r1 - game timer, r2 - Player score \\ returns current values in the same regs
						; if -1 is put into a register, the info isn't updated
	STMFD SP!, {lr, r3-r12}
	CMP r0, #-1
	BEQ noStatusUpdate
	LDR r4, GAME_STATUS_PTR
	STRB r0, [r4]
noStatusUpdate:
	LDRB r0, [r4]

	CMP r1, #-1
	BEQ noTimerUpdate
	LDR r4, GAME_TIMER_PTR
	STRB r1, [r4]
noTimerUpdate:
	LDRB r1, [r4]

	CMP r2, #-1
	BEQ noScoreUpdate
	LDR r4, PLAYER_SCORE_PTR
	STRB r2, [r4]
noScoreUpdate:
	LDRB r2, [r4]


	LDMFD SP!, {lr, r3-r12}
	BX lr

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
	BEQ gameRunning


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

	B notValidKey

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
	CMP r0,#'l'
	IT EQ
	BLEQ levelUp
	BNE notL

notL:
	CMP r3,#0
	BEQ notValidKey

	;get frog location
	LDR r4, boardPtr
	LDR r9, frogLocationPtr
	LDR r10, [r9]
	;calculate new frog location
	ADD r5, r10, r3
	;get value at new frog location
	LDRB r2,[r4,r5]
	;check if its a valid postion
	BL check_valid_location
	;replace frog with prevous value
	LDR r8, previousFrogValuePtr
	LDR r11, [r8]
	STRB r11, [r4,r10]

	CMP r0, #0
	BNE notHittingObstacle

	BL resetFrog
	B hittingObstacle


notHittingObstacle:

	;save value at new frog location to previousFrogValue
	STR r2,[r8]
	;set previousFrogLocation to frogLocation
	LDR r8, previousFrogLocationPtr
	STR r10,[r8]
	;set new frog location to frog location
	STR r5, [r9]
	;store frog in new location
	MOV r2,#0x26
	STRB r2,[r4,r5]
	B notDed2
hittingObstacle:


	LDR r4, FROG_LIVES_PTR
	LDRB r0, [r4]

	SUB r0, r0, #1
	STRB r0, [r4]
	CMP r0, #0x0
	BEQ ded2
	B notDed2
ded2:
	MOV r0, #1
	MOV r1, #-1
	MOV r2, #-1
	BL update_game_information
	MOV r0, #0x2
	BL illuminate_RGB_LED

notDed2:
notValidKey:


	LDMFD SP!, {lr, r0-r12}
	BX lr

Timer0Handler: ;timer for game clock (1 second per cycle)
	STMFD SP!, {lr, r3-r5, r7-r11}
	MOV r4, #0
	MOVT r4, #0x4003
	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]

	MOV r0, #-1
	MOV r1, #-1
	MOV r2, #-1
	BL update_game_information
	CMP r0, #0
	BEQ gameStarted





gameStarted:
	LDR r4, GAME_TIMER_PTR
	LDR r1, [r4]
	SUB r1, r1, #0x1
	MOV r0, #-1
	MOV r2, #-1
	BL update_game_information
	CMP r1, #0x0
	BEQ timesUp
	LDR r4, GAME_STATUS_PTR
	LDRB r1, [r4]
	CMP r1, #0x0
	BEQ noMusic

	BL nextNote

timesUp:
	LDR r4, GAME_STATUS_PTR
	LDRB r1, [r4]
	MOV r1, #0x1
	STRB r1, [r4] ;set game status to over if time runs out

noMusic:





	LDMFD SP!, {lr, r3-r5, r7-r11}
	BX lr


Timer1Handler: ; controls speaker pitch
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
	MOV r4, #0x2000
	MOVT r4, #0x4003
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]


	LDR r4, BOARD_UPDATE_PTR
	LDRB r0, [r4]
	LDR r4, boardPtr
  	CMP r0, #0
	BNE noWaterUpdate

	STMFD SP!, {lr, r0-r3}
	MOV r0, #3
	MOV r1, #7
	MOV r2, #1
	MOV r3, #0
	BL shiftSetOfRows
	LDMFD SP!, {lr, r0-r3}

noWaterUpdate:
	BL removeFrog

	CMP r0, #0
	BNE noTruckUpdate
	MOV r0, #8
	MOV r1, #9
	MOV r2, #1
	MOV r8, #0
	MOV r3, #1
truckLinesFinished:
	STMFD SP!, {lr, r0-r3}
	BL shiftSetOfRows
	LDMFD SP!, {lr, r0-r3}
	ADD r0, r0, #2
	ADD r1, r1, #2
	ADD r8, r8, #1
	CMP r8, #3
	BNE truckLinesFinished
noTruckUpdate:


	MOV r0, #9
	MOV r1, #10
	MOV r2, #0
	MOV r8, #0
	MOV r3, #2
carLinesFinished:
	STMFD SP!, {lr, r0-r3}
	BL shiftSetOfRows
	LDMFD SP!, {lr, r0-r3}
	ADD r0, r0, #2
	ADD r1, r1, #2
	ADD r8, r8, #1
	CMP r8, #3
	BNE carLinesFinished
	BL putBackFrog

	MOV r4, #0x2000
	MOVT r4, #0x4003
	LDRB r1, [r4, #0x48]
	ORR r1, r1, #0x0
	STRB r1, [r4, #0x48]


	BL redrawBoard

	;TODO: update frog position, flip boardupdate bit, shift game rows if boardupdate is true, redraw game board

	; if valid position for frog, continue and add to score, else subtract life

	;if life == 0, set game over to true

	;is position a fly? if so, add to score and replace fly

	; is a winning tile? add to score, add to win counter, restart game

		; if win counter == 3, increase clock period by .05 seconds

;stabliliztion:
	;flip board update bit
	LDR r4, BOARD_UPDATE_PTR
	LDRB r0, [r4]
	EOR r0, r0, #1
	STRB r0, [r4]

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
	ADD r6, r6, #0x1
	MOV r0, #0x1B
	BL output_character ; clears screen
	ADD r6, r6, #0x1
	MOV r0, #0x5B
	BL output_character ; clears screen
	ADD r6, r6, #0x1
	MOV r0, #0x48
	BL output_character ; clears screen
	LDR r4, INFO_DISPLAY_PTR
	BL output_string
	;TODO: output score in string form here
	LDR r2, PLAYER_SCORE_PTR
	LDR r0, [r2]
	LDR r1, PLAYER_SCORE_ASCII_PTR
	BL convertToAscii
	LDR r4, PLAYER_SCORE_ASCII_PTR
	BL output_string

	LDR r4, TIMER_DISPLAY_PTR
	BL output_string
	;TODO: output timer in string form here
	LDR r2, GAME_TIMER_PTR
	LDRB r0, [r2]
	LDR r1, GAME_TIMER_ASCII_PTR
	BL convertToAscii
	LDR r4, GAME_TIMER_ASCII_PTR
	BL output_string

	LDR r4, boardPtr
	BL output_string

	; set leds to correct lives
	LDR r4, FROG_LIVES_PTR
	LDRB r2, [r4]

	CMP r2, #0x4
	IT GE
	MOVGE r0, #0xF

	CMP r2, #0x3
	IT EQ
	MOVEQ r0, #0x7

	CMP r2, #0x2
	IT EQ
	MOVEQ r0, #0x3

	CMP r2, #0x1
	IT EQ
	MOVEQ r0, #0x1

	CMP r2, #0x0
	IT EQ
	MOVEQ r0, #0x0

	BL illuminate_LEDs
	LDMFD SP!, {lr, r0-r12}
	BX lr

shiftSetOfRows:	;r0 starting row
				;r1 ending row
				;r2 set shift pattern
				;r3 set line type, 0 for water, 1 for trucks and 2 for cars
	STMFD SP!, {lr, r4-r12}
	MOV r4, r0
	MOV r11, r3
	LDR r10, boardPtr
	MOV r9, r1
	MOV r5, #49
	ADD r8, r2, #1

shiftLines:
	MOV r0, r10
	MUL r7, r4, r5
	ADD r0, r0, r7
	ADD r0, r0, #1
	MOV r1, #45

	STMFD SP!, {r0-r2}
	MOV r0, r11
	MOV r1, r4
	BL generateRandomCharacter
	MOV r3, r0
	LDMFD SP!, {r0-r2}

	STMFD SP!, {r0-r3}
	BL shift_string
	LDMFD SP!, {r0-r3}
	MOV r1, r8
	MOV r0, #2
	BL div_and_mod
	MOV r2, r0
	ADD r8, r8, #1
	ADD r4, r4, #1
	CMP r4, r9
	BNE shiftLines
	LDMFD SP!, {lr, r4-r12}
	BX lr

generateRandomCharacter:	;r0 if 0 then water, if 1 then truck, if 2 then car
							;r1 nth row
							;r2 spawn direction
	STMFD SP!, {lr, r3-r12}
	MOV r7, r1
	MOV r5, #49
	MOV r4, r0
	MUL r1, r1, r5
	CMP r2, #0 ;if spawn direction left
	BNE isRight
	MOV r0,#0
	MOV r2,#0
	ADD r0, r1, #45	;first place in spawn location
	MOV r1, #-1	;sixth place in spawn location
	CMP r4, #0
	BNE isNotWaterLeft

	STMFD SP!, {r0}
	BL checkForFrog
	CMP r0, r7
	BNE frogNotInWaterSectionLeft
	MOV r0, r1
	BL shiftFrog
frogNotInWaterSectionLeft:
	LDMFD SP!, {r0}


	BL spawnWaterTile
	LDMFD SP!, {lr, r3-r12}
	BX lr
isNotWaterLeft:
	MOV r2, r4
	BL spawnRoadTile
	LDMFD SP!, {lr, r3-r12}
	BX lr

isRight:
	MOV r0,#0
	MOV r2,#1
	ADD r0, r1, #1	;first place in spawn location
	MOV r1,#1
	CMP r4, #0
	BNE isNotWaterRight

	STMFD SP!, {r0}
	BL checkForFrog
	CMP r0, r7
	BNE frogNotInWaterSectionRight
	MOV r0, r1
	BL shiftFrog
frogNotInWaterSectionRight:
	LDMFD SP!, {r0}

	BL spawnWaterTile
	LDMFD SP!, {lr, r3-r12}
	BX lr
isNotWaterRight:
	MOV r2, r4
	BL spawnRoadTile
	LDMFD SP!, {lr, r3-r12}
	BX lr

spawnWaterTile:	;r0 beginning spawn location
				;r1 spawn direction left=-1, right=1
	STMFD SP!, {lr, r2-r12}
	MOV r4, r0
	MOV r5, r1
	MOV r2, #0x4C
	MOV r3, #0x6
	BL checkForSpawn
	CMP r0, #0x4C
	BNE notLogSpawn
	LDMFD SP!, {lr, r2-r12}
	BX lr
notLogSpawn:
	MOV r0, r4
	MOV r1, r5
	MOV r2, #0x41
	MOV r3, #0x0
	BL checkForSpawn
	CMP r0, #0x41
	BNE notAlligatorHeadSpawn
	MOV r0, #0x61
	LDMFD SP!, {lr, r2-r12}
	BX lr
notAlligatorHeadSpawn:
	MOV r0, r4
	MOV r1, r5
	MOV r2, #0x61
	MOV r3, #0x5
	BL checkForSpawn
	CMP r0, #0x61
	BNE notAlligatorBodySpawn
	MOV r0, #0x61
	LDMFD SP!, {lr, r2-r12}
	BX lr
notAlligatorBodySpawn:
	MOV r0, r4
	MOV r1, r5
	MOV r2, #0x54
	MOV r3, #0x2
	BL checkForSpawn
	CMP r0, #0x54
	BNE notTurtleSpawn
	LDMFD SP!, {lr, r2-r12}
	BX lr
notTurtleSpawn:
	;check if space is needed
	MOV r0, r4
	LDR r4, boardPtr
	LDRB r1, [r4,r0]
	CMP r1, #0x7E
	BNE isWaterTile

	;at this point all possible continuating spawning possiblities are false
	MOV r0,#7
	BL rng
	CMP r0, #0x0 ;if random number is 0, obstical needs to be created
	BNE isWaterTile
	MOV r0,#4
	BL rng
	CMP r0, #0x0 ;if random number is 1, Log tile
	BNE notLogTile
	MOV r0, #0x4C
	LDMFD SP!, {lr, r2-r12}
	BX lr
notLogTile:
	CMP r0, #0x1 ;if random number is 2, alligator tile
	BNE notAlligatorTile
	MOV r0, #0x41
	LDMFD SP!, {lr, r2-r12}
	BX lr
notAlligatorTile:
	CMP r0, #0x2 ;if random number is 3, Turtle
	BNE notTurtleTile
	MOV r0, #0x54
	LDMFD SP!, {lr, r2-r12}
	BX lr
notTurtleTile:
	CMP r0, #0x3 ;if random number is 4, lilypad
	BNE notLilypadTile
	MOV r0, #0x4F
notLilypadTile:
	LDMFD SP!, {lr, r2-r12}
	BX lr

isWaterTile:
	MOV r0, #0x7E

	LDMFD SP!, {lr, r2-r12}
	BX lr


spawnRoadTile:	;r0 beginning spawn location
				;r1 spawn direction left=-1, right=1
				;r2 1 if truck, 2 if car
	STMFD SP!, {lr, r3-r12}
	MOV r7, r0
	MOV r4,r2
	MOV r2, #0x23
	MOV r3, #0x4
	BL checkForSpawn
	CMP r0, #0x23
	BNE notTruckSpawn
	LDMFD SP!, {lr, r3-r12}
	BX lr
notTruckSpawn:
;check if space is needed
	LDR r5, boardPtr
	LDRB r1, [r5,r7]
	CMP r1, #0x20
	BNE isRoadTile

	MOV r0,#7
	BL rng
	CMP r0, #0x0 ;if random number is 0, obstical needs to be created
	BNE isRoadTile

	CMP r4, #1
	BNE notTruckTile
	MOV r0, #0x23
	LDMFD SP!, {lr, r3-r12}
	BX lr
notTruckTile:
	CMP r4, #2 ;if random number is 2, car
	BNE notCarTile
	MOV r0, #0x43
notCarTile:
	LDMFD SP!, {lr, r3-r12}
	BX lr
isRoadTile:
	MOV r0, #0x20
	LDMFD SP!, {lr, r3-r12}
	BX lr

checkForSpawn:	;r0 beginning spawn location
				;r1 spawn direction left=-1, right=1
				;r2 search value
				;r3 max length
	STMFD SP!, {lr, r4-r12}
	MOV r5, #0
	LDR r4, boardPtr
countSpawn:
	LDRB r7, [r4,r0]
	CMP r7, r2
	BNE countDone
	ADD r5, r5, #1
	ADD r0, r0, r1
	B countSpawn

countDone:
	MOV r0, r3
	MOV r1, r5
	BL div_and_mod
	CMP r0, #0
	BEQ notSearchValue
	MOV r0, r2
	LDMFD SP!, {lr, r4-r12}
	BX lr
notSearchValue:
	MOV r0, #0x0
	LDMFD SP!, {lr, r4-r12}
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
	BX lr

output_7_seg: ;puts text on the screen take what ever value is in r0 and put it on the screen
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	MOV r1, #0x8000		;SSI REG
	MOVT r1, #0x4000

	MOV r2, #0
NOOUTPUT7SEG:
	LDR r2,[r1, #0xC]		;load SSISR data to r2
 	AND r2,r2, #0x8	;isolate bit to check if SSI receive is full
 	CMP	r2,#0x0	;check if r3 is 0
 	BNE NOOUTPUT7SEG	;if not 0 branch to NOOUTPUT7SEG
 	STRB r0,[r1, #0x8]			;if 0 store byte in transmit register
	LDMFD sp!, {lr, r1-r12}
	BX lr
putBackFrog:
	STMFD SP!,{lr, r0-r12}
	LDR r5, frogLocationPtr
	LDR r7,[r5]
	MOV r3, #0x26
	LDRB r2,[r4,r7]
	BL check_valid_location
	CMP r0, #0
	BNE validSpace
	;frog is killed actions taken here
	;decriment lives/points here
	LDR r4, FROG_LIVES_PTR
	LDRB r0, [r4]

	SUB r0, r0, #1
	STRB r0, [r4]
	CMP r0, #0x0
	BEQ ded
	B notDed
ded:
	MOV r0, #1
	MOV r1, #-1
	MOV r2, #-1
	BL update_game_information
	MOV r0, #0x2
	BL illuminate_RGB_LED
notDed:
	BL resetFrog

	LDR r7, frogLocationPtr
	LDR r7,[r7]
	;move to spawn location
validSpace:
	STRB r3,[r4,r7]
	LDMFD sp!, {lr, r0-r12}
	BX lr
removeFrog:
	STMFD SP!,{lr, r0-r12}
	LDR r5, frogLocationPtr
	LDR r7,[r5]
	LDR r3, previousFrogValuePtr
	LDR r3, [r3]
	STRB r3,[r4,r7]
	LDMFD sp!, {lr, r0-r12}
	BX lr

resetFrog:
	STMFD SP!,{lr, r0-r12}
	;reset prevousFrogLocation
	LDR r7, previousFrogLocationPtr
	MOV r1, #0x41D
	STR r1,[r7]
	;reset previosFrogValue
	LDR r7, previousFrogValuePtr
	MOV r1, #0x2E
	STR r1,[r7]
	;reset frogLocation
	LDR r7, frogLocationPtr
	MOV r1, #0x2C5
	STR r1,[r7]
	LDMFD sp!, {lr, r0-r12}
	BX lr
checkForFrog:
	STMFD SP!,{lr, r1-r12}
	MOV r0, #-1
	LDR r5, boardPtr
	LDR r3, frogLocationPtr
	LDR r2, [r3]
	ADD r2, r2, r5
checkRowForFrog:
	CMP r5, r2
	BGE frogFound
	ADD r5, r5, #49
	ADD r0, r0, #1
	B checkRowForFrog
frogFound:
	LDMFD sp!, {lr, r1-r12}
	BX lr
shiftFrog:	;r0 -1 for left shift, 1 for right shift
	STMFD SP!,{lr, r1-r12}
	LDR r3, frogLocationPtr
	LDR r5, [r3]
	LDR r4, boardPtr
	ADD r5, r5, r0
	LDRB r2, [r4,r5]
	CMP r2, #0x7C
	BNE notEndOfBoard
	BL resetFrog
	LDMFD sp!, {lr, r1-r12}
	BX lr
notEndOfBoard:
	STR r5,[r3]
	LDMFD sp!, {lr, r1-r12}
	BX lr

.end
