	.data
song: .string "D5-D4-RRA4---D4-D5---E5-E4-RRA4---E4-E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4---E4-E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-B5-B4-A5---A4-g5---A4-E5-D5-"
m2: .string "--D4-RRA4-D4---D5---E5-E4-RRA4-E4---E5---g5-g4-RRA5---g4-g5---E5-E4-RRA4-A3---E5---D5-D4-RRA4---D4-g5---E5-E4-RRA4---E4-G5---g5-g4-A5-A4-D6-D5-E6-E5-A5--A4--G5-g5-A4-E5---;"
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
	.global timer0_interrupt_init
	.global timer1_interrupt_init
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global rng
	.global playNote
songPtr: .word song


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
	CMP r0, #0x77
	BNE notW
	LDR r1, [r4, #0xC] ;disable timer 0
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]
	MOV r2, #0x3800
	MOVT r2, #0x1
	LDR r1, [r4, #0x28]
	ADD r1, r1, r2
	STR r1, [r4, #0x28]
	LDR r1, [r4, #0xC] ;enable timer 0
	EOR r1, r1, #0x1
	STR r1, [r4, #0xC]
notW:
	CMP r0, #0x73
	BNE notS
	LDR r1, [r4, #0xC] ;disable timer 0
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]
	MOV r2, #0x3800
	MOVT r2, #0x1
	LDR r1, [r4, #0x28]
	SUB r1, r1, r2
	STR r1, [r4, #0x28]
	LDR r1, [r4, #0xC] ;enable timer 0
	EOR r1, r1, #0x1
	STR r1, [r4, #0xC]
notS:
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
	BL output_character
	LDMFD SP!, {lr, r0-r12}
	BX lr

Timer0Handler:
	STMFD SP!, {lr, r3-r5, r7-r12}
	MOV r4, #0
	MOVT r4, #0x4003
	;clear timer
	LDRB r1, [r4, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x24]
	BL nextNote
	; handle game stuff here:

	LDMFD SP!, {lr, r3-r5, r7-r12}
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




.end
