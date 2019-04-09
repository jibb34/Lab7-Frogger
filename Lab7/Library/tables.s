	.text
	.global button_table
	.global playNote




button_table: ;intakes r0 with the format D3,D2,D1,D1,A5,A4,A3,A2 in binary and returns the corresponding ascii value base on a preagreed map
    STMFD SP!,{r1-r12,lr} ; Store register lr on stack

    AND r1, r0, #0xF
    AND r2, r0, #0xF0
    LSR r2,#4

    CMP r2, #1
    BNE not1stRow
        CMP r1, #1
        BNE not1x1
        MOV r0, #0x31
not1x1:
        CMP r1, #2
        BNE not1x2
        MOV r0, #0x32
not1x2:
        CMP r1, #4
        BNE not1x3
        MOV r0, #0x33
not1x3:
        CMP r1, #8
        BNE not1x4
        MOV r0, #0x2B
not1x4:
not1stRow:
    CMP r2, #2
    BNE not2ndRow
        CMP r1, #1
        BNE not2x1
        MOV r0, #0x34
not2x1:
        CMP r1, #2
        BNE not2x2
        MOV r0, #0x35
not2x2:
        CMP r1, #4
        BNE not2x3
        MOV r0, #0x36
not2x3:
        CMP r1, #8
        BNE not2x4
        MOV r0, #0x2D
not2x4:
not2ndRow:
    CMP r2, #4
    BNE not3rdRow
        CMP r1, #1
        BNE not3x1
        MOV r0, #0x37
not3x1:
        CMP r1, #2
        BNE not3x2
        MOV r0, #0x38
not3x2:
        CMP r1, #4
        BNE not3x3
        MOV r0, #0x39
not3x3:
        CMP r1, #8
        BNE not3x4
        MOV r0, #0x2F
not3x4:
not3rdRow:
    CMP r2, #8
    BNE not4thRow
        CMP r1, #1
        BNE not4x1
        MOV r0, #0x00
not4x1:
        CMP r1, #2
        BNE not4x2
        MOV r0, #0x30
not4x2:
        CMP r1, #4
        BNE not4x3
        MOV r0, #0x00
not4x3:
        CMP r1, #8
        BNE not4x4
        MOV r0, #0x0D
not4x4:
not4thRow:
    LDMFD sp!, {r1-r12,lr}
    BX lr

playNote: ; input: address of note in r4, output: value to plug in directly to timer1's interrupt interval
	STMFD SP!, {lr, r1-r3, r5, r7-r12}
	;TODO: takes value of address of current note location, turns it into a note based on value, and updates timer1
	;upper hex value = how much to shift (octave)
	LDRB r1, [r4]
	CMP r1, #0x52
	BEQ rest
	CMP r1, #0x3B
	BEQ end
	CMP r1, #0x2D
	BEQ legato
	LDRB r2, [r4, #1]
	SUB r2, r2, #50
	ADD r6, r6, #1


; conversion from input to data to create sound
	CMP r1, #0x43 ;if C
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0xBBA8
	MOVTEQ r0, #0x3

	CMP r1, #0x64 ;if Db
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x85E0
	MOVTEQ r0, #0x3

	CMP r1, #0x44 ;if D
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x5380
	MOVTEQ r0, #0x3

	CMP r1, #0x65 ;if Eb
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x2358
	MOVTEQ r0, #0x3

	CMP r1, #0x45 ;if E
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0xF67F
	MOVTEQ r0, #0x2

	CMP r1, #0x46 ;if F
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0xCBEC
	MOVTEQ r0, #0x2

	CMP r1, #0x67 ;if Gb
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0xA3AD
	MOVTEQ r0, #0x2

	CMP r1, #0x47 ;if G
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x7DC1
	MOVTEQ r0, #0x2

	CMP r1, #0x61 ;if Ab
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x5A1F
	MOVTEQ r0, #0x2

	CMP r1, #0x41 ;if A
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x382F
	MOVTEQ r0, #0x2

	CMP r1, #0x62 ;if Bb
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0x187B
	MOVTEQ r0, #0x2

	CMP r1, #0x42 ;if B
	ITT EQ ;if then, then (on equal)
	MOVEQ r0, #0xFA32
	MOVTEQ r0, #0x1

	LSR r0, r0, r2 ; 1 shift right = 1 octave up from 2
end:
	CMP r1, #0x3B ; if song end then restart
	IT EQ
	MOVEQ r0, #0xF
rest:
	CMP r1, #0x52 ; if rest
	IT EQ
	MOVEQ r0, #0x0
legato:
	CMP r1, #0x2D ;if legato
	IT EQ
	MOVEQ r0, #0x2D

	LDMFD SP!, {lr, r1-r3, r5, r7-r12}
	BX lr

.end
