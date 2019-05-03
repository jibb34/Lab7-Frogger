	.text
	.global div_and_mod
	.global rng
	.global convertToAscii



rng:
	STMFD SP!, {lr, r1-r12}
	MOV r4, #0x0000
	MOVT r4, #0x4003
	LDRB r1, [r4, #0x50]
	MOV r4, #0x2000
	MOVT r4, #0x4003
	LDRB r3, [r4, #0x50]
	ADD r1, r1, r3
	BL div_and_mod
	LDMFD SP!, {lr, r1-r12}
	BX lr





div_and_mod:
	STMFD r13!, {r2-r12, r14}

	; The dividend is passed in r1 and the divisor in r0.
	; The quotient is returned in r1 and the remainder in r0.
	; -----------------------------------------------------------
	; Converting negatives to positives:
	MOV r8, #0
	CMP r1, #0
	BGE positiveDividend ;if dividend is positive ignore next few lines
	;dividend is negative if this is reached
	RSB r1, r1, #0 ;if value is negative, makes it positive
	EOR r8, r8, #1; inverts 1st bit

positiveDividend:
	CMP r0, #0
	BGE positiveDivisor ; if divisor is positive, ignore next few lines
	;divisor is negative if this is reached
	RSB r0, r0, #0 ;if value is negative, makes it positive
	EOR r8, r8, #1; inverts 1st bit

positiveDivisor:
	;if r8 is 1: final value is negative, this is our "Negative Flag"


; --------------------------------------------------------------
	;Division Algorithm:
	MOV r7, #1 ; sets value of 1 in r7 for code optimization
	MOV r3, #15 ; initialize counter to 15
	MOV r2, #0 ; initialize quotient to 0
	LSL r0, r0, #15 ; left shift divisor 15 places
	MOV r4, r1 ; initialize remainder to dividend
divLoop:
	SUB r4, r4, r0 ; subtracts divisor from remainder
	CMP r4, #0 ; compare the remainder to 0
	BLT yes ; if remainder is less than 0, goto yes
	ADD r2, r7, r2, LSL #1 ; shifts quotient left by 1 and sets LSB to 1
	B Merge ; jump to the merge

yes:
	ADD r4, r4, r0 ; undoes divisor subtraction if we can't subtract
 	LSL r2, #1 ; shift quotient left and sets LSB to 0
Merge:
	LSR r0, #1 ; shifts divisor right 1 bit, brings in a 0 to MSB

	CMP r3, #0 ; compares counter to 0
	BLE Done ; jump to done if counter is <= 0
	SUB r3, r3, #1 ; decrement counter
	B divLoop ; loop back (always)
Done:
	MOV r0, r4 ; puts final remainder in r0
	MOV r1, r2 ; puts final quotient in r1
	CMP r8, #0 ; Checks if "negative Flag" is 0
	BEQ Positive ; skips setting final value to negative if negative flag is 0
	RSB r1, r1, #0
Positive:
	LDMFD r13!, {r2-r12, r14}
	mov pc, lr


convertToAscii:        ;converts the value put in r0 to askii and returns its equivlent in askii in r0, it must be a postive value between 0 and 999
    STMFD SP!,{lr, r2-r12}
    CMP r0, #0xA
    BGE moreThan2Chars
    MOV r6, #0x0
    ADD r4, r0, #0x30
    STRB r4, [r1, r6]
    ADD r6, r6, #1
    MOV r4, #0x0
    STRB r4, [r1, r6]
    ADD r6, r6 ,#1
moreThan2Chars:
    MOV r2,#10
    MOV r3, #1
    MOV r10, r1
    MOV r9, #0
    MOV r6, #0x0
blowupLoop:
    ; loop while r0 is less than r1, keep multiplying by 10
    MUL r3, r3, r2
    CMP r3, r0
    BLE blowupLoop
    MOV r5, #0    ;start r5 which stores the acsii value
    MOV r1, r0    ;sets r0 to the dividend
    MOV r7, #0    ;start the shift counter
    MOV r8, #0
printLoop: ; takes a value, converts it to a string, stores in r3, and pushes it onto stack, if its division
    UDIV r3, r3, r2 ; divides our divisor by 10
    MOV r4, r1    ;sets r4 to r1 to save the value for after div_and_mod
    MOV r0, r3    ;sets r3 to the divisor
    BL div_and_mod    ; takes dividend in r1, divisor in r0, does division, and puts quotient back in r1, remainder in r0 (limited to 16 bits)
    MOV r1, r0    ;set the remainder to be the new dividend
    SUB r4, r4, r0    ;subtract the origoanl dividend(r4) by the remainder
    UDIV r4, r4, r3    ;divide r4 by r3
    ADD r4, r4, #48 ; converts # into ASCII character
    STRB r4, [r10, r6]
    ADD r6, r6, #1

    CMP r3, #1        ;if r3 is greater then 1 then breach to printloop
    BNE printLoop
    MOV r0, r5        ;set r0 to r5
    MOV r1, r9
done:
    LDMFD sp!, {lr, r2-r12}
    BX lr

.end

