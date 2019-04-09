
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
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global rng
	.global read_character

Lab7:				;diplays the prompt and initializes the interrupts then goes into an
					;infinate loop until the endgame variable is set to 0
					;NOTE: baud rate must be set to 115200
	STMFD sp!, {lr}
	BL uart_init
	BL GPIO_init
	BL interrupt_init	;initalize the UART interrupt
	BL timer0_interrupt_init ;initialize timer interrupt
	BL timer1_interrupt_init

infLoop:

	B infLoop
	LDMFD sp!, {lr}
	mov pc, lr
