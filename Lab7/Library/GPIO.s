	.text
	.global read_from_keypad
	.global illuminate_LEDs
	.global illuminate_RGB_LED



;------------------------------- Functional Subroutines ---------------------------------------------------


read_from_keypad:	;returns values of the push buttons to r0
	STMFD SP!,{r1-r12,lr}
	MOV r4, #0x7000
	MOVT r4, #0x4000; sets base address of port D
	MOV r5, #0x4000
	MOVT r5, #0x4000; sets base address of port A
   	MOV r1, #0x0
   	MOV r0, #0x1
readLoop:;while port A = 0x00, loop 1 through port D pins
	STRB r0, [r4, #0x3FC]
	LDRB r1, [r5, #0x3FC]
	AND r1, r1, #0x3C
	CMP r1, #0x0
	BNE endReadLoop
	LSL r0, r0, #0x1 ;shift the 1 bit left in r0
	B readLoop
endReadLoop:
	LSL r0, r0, #0x3 ; shifts 3 more for ORing with r1, since we already shifted it 1 after the fact
	LSR r1, r1, #0x2
	ORR r0, r0, r1; adds r1 to the first 4 bits of r0, gives us our final output
	MOV r3, #0xF
   	MOV r4, #0x7000
	MOVT r4, #0x4000
	STRB r3, [r4, #0x3FC]
	;BL button_table
	LDMFD sp!, {r1-r12,lr}
	BX lr

illuminate_LEDs:	;take value in r0 and send it to LEDs
	STMFD SP!,{r1-r12,lr}
	MOV r4, #0x5000
	MOVT r4, #0x4000 ;store base address of Port B to r4
	STRB r0, [r4, #0x3FC]

	LDMFD sp!, {r1-r12,lr}
	BX lr

illuminate_RGB_LED:	;input is r0, its mapped as such 111(green, blue, red) send that value to the RGB LED
	STMFD SP!,{r1-r12,lr}
	MOV r4, #0x5000
	MOVT r4, #0x4002 ;store base address of Port F to r4
	LSL r0, r0, #1
	STRB r0, [r4,#0x3FC]	;store value in r0

	LDMFD sp!, {r1-r12,lr}
	BX lr




.end
