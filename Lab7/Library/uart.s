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
	.global poll_character
	.global shift_string
	.global fill_string

poll_character: ; halts program until character from input and places char in r0
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	mov r1, #0xC000 ;store UARTDR Data address in r0
	movt r1, #0x4000
	mov r2, #0xC018 ; store UARTSR status address in r1
	movt r2, #0x4000
testLoop:
	LDR r3, [r2]
	AND r3, r3, #0x0010 ;isolates RxFE for testing
	CMP r3, #0x10
	BEQ testLoop ; loops perpetually until 5th bit of UARTSR is 1

	LDRB r0, [r1] ;store value in first 8 bits of r0

	LDMFD sp!, {lr, r1-r12}
	BX lr


read_character: ; reads character from input and places char in r0
	STMFD SP!,{lr, r1-r12}	; Store register lr on stack
	mov r1, #0xC000 ;store UARTDR Data address in r0
	movt r1, #0x4000
	mov r2, #0xC018 ; store UARTSR status address in r1
	movt r2, #0x4000
	MOV r0, #0x0
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
	LDRB r2,[r5]		;load UARTRR data to r2
 	AND r2,r2, #0x20	;mask UARTFR with xFF and store result in r0
 	CMP	r2,#0x20	;check if r3 is 0
 	BEQ NOOUTPUTCHARACTER	;if not 0 branch to NOOUTPUTCHARACTER
 	STRB r0,[r1]			;if 0 store byte in transmit register
	LDMFD sp!, {lr, r1-r12}
	BX lr

;----------------------------------------------------------
output_string: ;outputs string starting at address stored in r4
	STMFD SP!,{lr, r0-r3, r5-r12}	; Store register lr on stack
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
	LDMFD sp!, {lr, r0-r3, r5-r12}
	BX lr


shift_string:    ;r0 begining of the string
                ;r1 length of string
                ;r2 direction of travel (0 = left, 1 = right)
                ;r3 character we are shifting in, outputs character we are shifting out. If input character is 0, last character of string is shifted in
    STMFD SP!, {lr, r4-r12}
	CMP r3, #0x0
	BNE notzero
	SUB r6, r1, #1
	LDRB r3, [r0, r6]
notzero:
    MOV r6, r2
    MOV r2, r3
    SUB r1, r1, #0x1 ;sets string length correctly
	CMP r6, #0x0
	BNE shftRgt
    MOV r4, r1

shiftMemoryLeft:
    LDRB r3, [r0, r1] ;takes old last value
    STRB r2, [r0, r1] ;shifts new value in
    CMP r1, #0x0 ; if string length becomes 0
	BEQ shiftDone ; we are done
    SUB r1, r1, #1 ;decrements string length
    MOV r2, r3 ;moves old value into register that replaces the next character

	B shiftMemoryLeft

shftRgt:
	MOV r5, #0x0
	ADD r1, r1, #0x1

shiftMemoryRight:
	LDRB r3, [r0, r5]
	STRB r2, [r0, r5]
	ADD r5, r5, #0x1
	MOV r2, r3
	CMP r5, r1
	BEQ shiftDone
	B shiftMemoryRight

shiftDone:
    LDMFD sp!, {lr, r4-r12}
    BX lr



fill_string: ;takes string base address in r0, string length in r1, and character to fill with in r2
	STMFD sp!, {lr, r3-r12}
	MOV r5, #0x0
fillLoop:
	STRB r2, [r0, r5]
	ADD r5, r5, #0x1
	CMP r5, r1
	BNE fillLoop

	LDMFD sp!, {lr, r3-r12}
	BX lr

.end


