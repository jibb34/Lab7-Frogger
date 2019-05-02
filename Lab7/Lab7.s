	.data
menu: .string  0xA, 0xD
Logo0: .string " ________  _______      ___      ______     ______  ________  _______    ", 0xA, 0xD
Logo1: .string "|_   __  ||_   __ \   .'   `.  .' ___  |  .' ___  ||_   __  ||_   __ \   ", 0xA, 0xD
Logo2: .string "  | |_ \_|  | |__) | /  .-.  \/ .'   \_| / .'   \_|  | |_ \_|  | |__) | ", 0xA, 0xD
Logo3: .string "  |  _|     |  __ /  | |   | || |   ____ | |   ____  |  _| _   |  __ /  ", 0xA, 0xD
Logo4: .string " _| |_     _| |  \ \_\  `-'  /\ `.___]  |\ `.___]  |_| |__/ | _| |  \ \_ ", 0xA, 0xD
Logo5: .string "|_____|   |____| |___|`.___.'  `._____.'  `._____.'|________||____| |___|" ,0xA, 0xD, 0xD, 0xA
title: .string "MAIN MENU", 0xD, 0xA, 0xD, 0xA
op1: .string "1: Start Game", 0xD, 0xA
op2: .string "2: How to Play", 0xD, 0xA
op3: .string "3: Hiscores", 0xD, 0xA, 0xD, 0xA, "Press M to mute music", 0xD, 0xA, 0x0

inst: .string "The instructions will go here. (Press 0 to return)", 0
hiscoreString: .string 0xD, 0xA ,"Hiscores will go here once they are implemented (Press 0 to return)", 0xD, 0xA, 0xD, 0xA, 0xD, 0xA
hiscores1: .string " 1>-------- : ----",0xD, 0xA
hiscores2: .string " 2>-------- : ----",0xD, 0xA
hiscores3: .string " 3>-------- : ----",0xD, 0xA
hiscores4: .string " 4>-------- : ----",0xD, 0xA
hiscores5: .string " 5>-------- : ----",0xD, 0xA
hiscores6: .string " 6>-------- : ----",0xD, 0xA
hiscores7: .string " 7>-------- : ----",0xD, 0xA
hiscores8: .string " 8>-------- : ----",0xD, 0xA
hiscores9: .string " 9>-------- : ----",0xD, 0xA
hiscores10: .string "10>-------- : ----",0xD, 0xA, 0x0

	.text
	.global Lab7
	.global lab7_library
	.global uart_init
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
	.global timer0_interrupt_init
	.global timer1_interrupt_init
	.global timer2_interrupt_init
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global rng
	.global read_character
	.global shift_string
	.global poll_character
	.global fill_string
	.global mode
	.global SPI_init
	.global output_7_seg
	.global update_game_information
menuPtr: .word menu
instPtr: .word inst
hiscoreStringPtr: .word hiscoreString
hiscoresPtr: .word hiscores1
modePtr: .word 0x20005000


Lab7:				;diplays the prompt and initializes the interrupts then goes into an
					;infinate loop until the endgame variable is set to 0
					;NOTE: baud rate must be set to 460800
	STMFD sp!, {lr}
	MOV r0, #1
	MOV r1, #-1
	MOV r2, #-1
	BL update_game_information
	BL uart_init

	BL GPIO_init
;	BL SPI_init
	;initalize the UART interrupt
	;TODO: draw menu, provide branch to different outputs depending on result
	BL timer0_interrupt_init ;initialize timer interrupt
	BL timer1_interrupt_init
	BL interrupt_init
	MOV r0, #0x7
	BL illuminate_RGB_LED


mainMenu:

	ADD r6, r6, #0x1
	MOV r0, #0xC
	BL output_character ; clears screen
	LDR r4, menuPtr
	BL output_string
	MOV r3, #0x0
	LDR r1, modePtr
	MOV r0, #0x0
	STRB r0, [r1]
menuLoop:

	MOV r0, #0xF908

	LDRB r0, [r1]
	CMP r0, #0x1
	BEQ startGame
	CMP r0, #0x2
	BEQ instructions
	CMP r0, #0x3
	BEQ hiscores
	MOV r0, #0x0
	B menuLoop


instructions:
	MOV r0, #0xC
	BL output_character ; clears screen
	LDR r4, instPtr
	BL output_string
	MOV r0, #0x0
loop1:
	BL poll_character
	CMP r0, #0x30
	BEQ mainMenu
	B loop1

hiscores:
	MOV r0, #0xC
	BL output_character ; clears screen
	LDR r4, hiscoreStringPtr
	BL output_string

loop2:
	BL poll_character

	CMP r0, #0x30
	BEQ mainMenu

	B loop2

startGame:
;game starts here
	MOV r0, #0x4
	BL illuminate_RGB_LED
	MOV r0, #0
	MOV r1, #60
	MOV r2, #0
	BL update_game_information
	MOV r4, #0x0000
	MOVT r4, #0x4003
	LDR r1, [r4, #0x28]
	MOV r1, #0x2400
	MOVT r1, #0xF4 ; update timer clock speed
	STR r1, [r4, #0x28]
	MOV r4, #0x1000
	MOVT r4, #0x4003
	LDR r1, [r4, #0xC] ;toggle timer off (turn off music)
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]
	BL timer2_interrupt_init
	ADD r6, r6, #0x1
	MOV r0, #0xC
	BL output_character ; clears screen

infLoop:

	B infLoop
	LDMFD sp!, {lr}
	mov pc, lr
