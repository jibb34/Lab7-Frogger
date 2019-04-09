	.text
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




read_character: ; reads character from input and places char in r0
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	mov r1, #0xC000 ;store UARTDR Data address in r0
	movt r1, #0x4000
	mov r2, #0xC018 ; store UARTSR status address in r1
	movt r2, #0x4000

	LDRB r0, [r1] ;store value in first 8 bits of r0
	LDMFD sp!, {lr, r1-r12}
	BX lr
output_character: ;puts text on the screen take what ever value is in r0 and put it on the screen
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	MOV r1, #0xC000		;store first half of location of UARTDR in r0
	MOVT r1, #0x4000	;store second half of location of UARTDR in r0
	MOV r5, #0xC018		;store first half of location of UARTFR in r1
	MOVT r5, #0x4000	;store second half of location of UARTFR in r1
	MOV r2, #0			;set up r2
NOOUTPUTCHARACTER:
	LDR r2,[r5]		;load UARTRR data to r2
 	AND r2,r2, #0x20	;mask UARTFR with xFF and store result in r0
 	CMP	r2,#0x20	;check if r3 is 0
 	BEQ NOOUTPUTCHARACTER	;if not 0 branch to NOOUTPUTCHARACTER
 	STRB r0,[r1]			;if 0 store byte in transmit register
	LDMFD sp!, {lr, r1-r12}
	BX lr

;----------------------------------------------------------
output_string: ;outputs string starting at address stored in r4
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	MOV r3, r0
PRINTTODISPLAY:
	LDRB r0, [r4], #1	;loads value from memory
	CMP r0,#0			;check if r3 is 0 if not then it will break to PRINTTODISPLAY
	BEQ displayDone
	BL output_character	;outputs charactor
	B PRINTTODISPLAY
displayDone:
	MOV r0, #0xA
	BL output_character
	MOV r0, #0xD
	BL output_character
	MOV r0, r3
	LDMFD sp!, {lr, r1-r12}
	BX lr

.end


