	.text
	.global lab7_library
	.global uart_init
	.global interrupt_init
	.global GPIO_init
	.global timer0_interrupt_init
	.global timer1_interrupt_init



interrupt_init:		;initialize UART interrupt
	STMFD SP!, {lr, r0-r12}
	;TODO: init interrupts for UART-----------------------------
	MOV r3, #0xE000
	MOVT r3, #0xE000
	MOV	r4, #0xC000
	MOVT r4, #0x4000
    LDR r1, [r4, #0x30]
    MOV r2, #0x301
	BIC r1, r1, r2
	STR r1, [r4, #0x30]
	;allow receive interrupt to be sent to interrupt controller
	LDR r1, [r4, #0x38]
	ORR r1, #0x10
	STR r1, [r4, #0x38]
	LDR r1, [r4, #0x30]
	MOV r2, #0x301
	ORR r1, r1, r2
	STR r1, [r4, #0x30]
	;init interrupts for GPIOPORTA
	MOV r4, #0x4000
	MOVT r4, #0x4000
	;GPIO interrupt Sense (GPIOIS)
	LDR r1, [r4, #0x404]
	BIC r1, r1, #0x3C
	STR r1, [r4, #0x404]
	;GPIO interrupt Both Edges(GPIOIBE)
	LDR r1, [r4, #0x408]
	BIC r1, r1, #0x3C
	STR r1, [r4, #0x408]
	;GPIO Interrupt Event (GPIOIEV)
	LDR r1, [r4, #0x40C]
	ORR r1, #0x3C
	STR r1, [r4, #0x40C]
	;GPIO Interrupts Mask (GPIOIM)
	LDR r1, [r4, #0x410]
	ORR r1, #0x3C
	STR r1, [r4, #0x410]
	;enable interrupts
	LDR r1, [r3, #0x100]
	ORR r1, #0x21
	STR r1, [r3, #0x100]
	LDMFD sp!, {lr, r0-r12}
	BX lr


timer0_interrupt_init:	;initalize Timer interrupt
	STMFD SP!, {lr, r0-r12}
	;init Timer interrupt---------------------------
	MOV r3, #0xE000
	MOVT r3, #0xE000
	MOV r4, #0x0000
	MOVT r4, #0x4003 ; sets base address for Timer0
	MOV r2, #0xE000
	MOVT r2, #0x400F
	;Connect clock to Timer
	LDRB r1, [r2, #0x604]
	ORR r1, r1, #0x1
	STRB r1, [r2, #0x604]
	MOV r0, #0x0
	MOV r1, #0xFFFF
stabilize:
	ADD r0, #0x1
	CMP r0, r1
	BLT stabilize
	;temporarily disable timer for initilization process
	LDRB r1, [r4, #0xC]
	BIC r1, r1, #0x1
	STRB r1, [r4, #0xC]
	;set timer up for 32-bit Mode
	LDRB r1, [r4]
	BIC r1, r1, #0x7
	STRB r1, [r4]
	;puts timer into periodic mode
	LDRB r1, [r4, #0x4]
	BIC r1, r1, #0x1
	ORR r1, r1, #0x2 ;sets lowest 2 bits to b'10
	STRB r1, [r4, #0x4]
	;set interrupt interval
	LDR r1, [r4, #0x28]
	MOV r1, #0x8480
	MOVT r1, #0x1E ; initial clock speed (.125 seconds)
	STR r1, [r4, #0x28]
	;set timer to interrup when top limit of timer reached
	LDRB r1, [r4, #0x18]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x18]
	;enable timer interrupt (NVIC)
	LDR r1, [r3, #0x100]
	MOV r2, #0x0
	MOVT r2, #0x8
	ORR r1, r1, r2
	STR r1, [r3, #0x100]
	;re-enable timer
	LDR r1, [r4, #0xC]
	ORR r1, r1, #0x1
	STR r1, [r4, #0xC]
	LDMFD sp!, {lr, r0-r12}
	BX lr

timer1_interrupt_init:	;initalize Timer interrupt for speaker
	STMFD SP!, {lr, r0-r12}
	;init Timer interrupt---------------------------
	MOV r3, #0xE000
	MOVT r3, #0xE000
	MOV r4, #0x1000
	MOVT r4, #0x4003 ; sets base address for Timer1
	MOV r2, #0xE000
	MOVT r2, #0x400F
	;Connect clock to Timer
	LDRB r1, [r2, #0x604]
	ORR r1, r1, #0x2
	STRB r1, [r2, #0x604]
	MOV r0, #0x0
	MOV r1, #0xFFFF
stabilize2:
	ADD r0, #0x1
	CMP r0, r1
	BLT stabilize2

	;temporarily disable timer for initilization process
	LDR r1, [r4, #0xC]
	BIC r1, r1, #0x1
	STR r1, [r4, #0xC]
	;set timer up for 32-bit Mode
	LDRB r1, [r4]
	BIC r1, r1, #0x7
	STRB r1, [r4]
	;puts timer into periodic mode
	LDRB r1, [r4, #0x4]
	BIC r1, r1, #0x1
	ORR r1, r1, #0x2 ;sets lowest 2 bits to b'10
	STRB r1, [r4, #0x4]
	;set interrupt interval
	LDR r1, [r4, #0x28]
	MOV r1, #0x9C40 ;approx 400 hz
	STR r1, [r4, #0x28]
	;set timer to interrup when top limit of timer reached
	LDRB r1, [r4, #0x18]
	ORR r1, r1, #0x1
	STRB r1, [r4, #0x18]
	;enable timer interrupt (NVIC)
	LDR r1, [r3, #0x100]
	MOV r2, #0x0
	MOVT r2, #0x8
	LSL r2, r2, #2
	ORR r1, r1, r2
	STR r1, [r3, #0x100]
	;re-enable timer
;	LDR r1, [r4, #0xC]
;	ORR r1, r1, #0x1
;	STR r1, [r4, #0xC]
	LDMFD sp!, {lr, r0-r12}
	BX lr

GPIO_init:		;initializes GPIO
	STMFD SP!,{lr, r0-r12}
	;TODO: init clock

   	;init clock:
   	MOV r5, #0xE000
   	MOVT r5, #0x400F
   	LDRB r3, [r5, #0x608]
   	ORR r3, r3, #0x2F ;(b'00101111) bitmap XGFEDCBA
   	STRB r3, [r5, #0x608]; enables clock for ports A, B, C, D, F
   	MOV r6, #0xFF


 	MOV r4, #0x5000; address for port B
 	MOVT r4, #0x4000
 	MOV r8, #0x7000; address for port D
	MOVT r8, #0x4000
 	MOV r7, #0x5000; address for port F
	MOVT r7, #0x4002
	MOV r9, #0x4000 ; address for port A
	MOVT r9, #0x4000
	MOV r10, #0x6000
	MOVt r10, #0x4000; address for port C
	; init Ports:

   ;Port B
  	LDRB r1, [r4, #0x400]
  	ORR r1, #0xF
	STRB r1, [r4, #0x400] ;sets led pins as output
	LDRB r1, [r4, #0x51C]
  	ORR r1, #0xF
	STRB r1, [r4, #0x51C] ; enables led pins to digital
	;Port F

	LDRB r1, [r7, #0x400]
	ORR r1, #0x1E
	STRB r1, [r7, #0x400]; set RGB LED pins as output
	LDRB r1, [r7, #0x51C]
	ORR r1, #0x1E
	STRB r1, [r7, #0x51C] ; enables RGB LED pins to digital

	;Port C
	LDRB r1, [r10, #0x400]
	ORR r1, #0x10
	STRB r1, [r10, #0x400]; set speaker pin to output
	LDRB r1, [r10, #0x51C]
	ORR r1, #0x10
	STRB r1, [r10, #0x51C] ; enables speaker pin to digital

	;Port D init
	LDRB r1, [r8, #0x51C]
	ORR r1, r1, #0xF
   	STRB r1, [r8, #0x51C];enables push button pins to digital
 	LDRB r1, [r9, #0x400]
	ORR r1, #0xF
   	STRB r1, [r8, #0x400] ;sets push button pins as output


	;Port A
	LDRB r1, [r9, #0x51C]
	ORR r1, r1, #0x3C;(b'0011 1100)(xx(a5)(a4)(a3)(a2)xx
	STRB r1, [r9, #0x51C] ; enables keypad input pins to digital
	LDRB r1, [r9, #0x400]
	BIC r1, #0x3C
	STRB r1, [r9, #0x400] ; sets kip to input
	LDMFD sp!, {lr, r0-r12}
	BX lr

uart_init:
	STMFD SP!,{r0-r12,lr}	; Store register lr on stack
	;initializes UART
	;/* Provide clock to UART0  */
    ;(*((volatile uint32_t *)(0x400FE618))) |= 1;
    MOV r0, #0xE618		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x400F	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#1			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Enable clock to PortA  */
    ;(*((volatile uint32_t *)(0x400FE608))) |= 1;
    MOV r0, #0xE608		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x400F	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#1			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Disable UART0 Control  */
    ;(*((volatile uint32_t *)(0x4000C030))) |= 0;
    MOV r0, #0xC030		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Set UART0_IBRD_R for 57600 baud */
    ;(*((volatile uint32_t *)(0x4000C024))) |= 8;
    MOV r0, #0xC024		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#8			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Set UART0_FBRD_R for 57600 baud */
    ;(*((volatile uint32_t *)(0x4000C028))) |= 44;
    MOV r0, #0xC028		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#44		;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Use System Clock */
    ;(*((volatile uint32_t *)(0x4000CFC8))) |= 0;
    MOV r0, #0xCFC8		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Use 8-bit word length, 1 stop bit, no parity */
    ;(*((volatile uint32_t *)(0x4000C02C))) |= 0x60;
    MOV r0, #0xC02C		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0x60			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Enable UART0 Control  */
    ;(*((volatile uint32_t *)(0x4000C030))) |= 0x301;
    MOV r0, #0xC030		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0x301			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Make PA0 and PA1 as Digital Ports  */
    ;(*((volatile uint32_t *)(0x4000451C))) |= 0x03;
    MOV r0, #0x451C		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0x03			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Change PA0,PA1 to Use an Alternate Function  */
    ;(*((volatile uint32_t *)(0x40004420))) |= 0x03;
    MOV r0, #0x4420		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0x03			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
    ;/* Configure PA0 and PA1 for UART  */
    ;(*((volatile uint32_t *)(0x4000452C))) |= 0x11;
    MOV r0, #0x452C		;set the second half of r0 to the second half of the hex value a above
    MOVT r0, #0x4000	;set the first half of r0 to the first half of the hex value a above
    MOV r1,#0x11			;set r1 to integer above
    BL LOAD_SETTINGS	;do load procedure
	LDMFD sp!, {r0-r12,lr}
	BX lr
LOAD_SETTINGS:			;subroutine for uart_init does the loading and saving of the new settings
	STMFD sp!, {lr, r3-r12}
    LDRH r2,[r0]			;load the value in memory location r0 to r1
    ORR r2, r2, r1		;or r1 with the integer value above
    STRH r2, [r0]		;store r1 in the memory location r0
    LDMFD sp!, {lr, r3-r12}
	BX lr


.end



