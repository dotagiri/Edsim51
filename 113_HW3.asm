ORG 00H

CLR P3.5
CLR P3.4
CLR P3.3		; clear RS

E EQU P3.2
RS EQU P3.3
MOV TMOD, #51H	; initialize timer 1
SETB TR0
SETB TR1
AGAIN:
	ACALL DIRECTION
	; TL1 holds # of rots which is in A
	CJNE A, #255, CONT
	ACALL CLRTIMER
CONT:
	; convert hex to dec
	ACALL HEXTODECTOASCII
	ACALL LCD
	RET
DIRECTION:
	MOV TL1, #0H	; reset rev count
	MOV C, P2.0
	MOV ACC.0, C
	MOV C,F0
	MOV 0, C
	ACALL ROTATE
	RET			; return to AGAIN

ROTATE:
	CLR P3.0			
	CLR P3.1			
	ACALL CLRTIMER		; reset timer		
MOV C, P2.0			; move SW0 value to carry
	MOV F0, C			; and then to F0 - this is the new motor direction
	MOV P3.0, C			; move SW0 value (in carry) to motor control bit 1
	CPL C				; invert the carry
	MOV P3.1, C	
; motor starts here

ACALL DELAY	; delay for 10ms as motor spins
RET 			; returns to DIRECTION

LOOP:	
MOV A, @R1
	JZ CLRLCD		; if no more digits, clear the lcd
	ACALL sendCharacter
	DEC R1
	JMP LOOP

CLRTIMER:
	CLR RS
	CLR C
	CLR A		; reset revolution count
	CLR TR1 	; stop timer 1
	CLR TR0	; stop timer 0 
MOV TL0, #0	; reset timer 1
	SETB TR1	; start timer 1
	SETB TR0	; start timer 0
	RET

CLRLCD:
	; new value has entered so clear rev count 
	MOV TL1, #0H	; reset rev count
	MOV A, #01H		; clear lcd display
	ACALL CMD
	ACALL CLRTIMER
	JMP AGAIN
CMD:
	CLR RS
	MOV P1, A
	ACALL PulseE	
	RET

DELAY:
	MOV TH0, #0F6H	; initialize THO with higher byte of 2.5ms
	MOV TL0, #03BH	; initialize TL0 with lower byte of 2.5ms 
	SETB TR0		
	SETB P3.5		; start timer by giving HIGH to INT1 pin
	MOV TL1, #0H	; reset rev count
HERE: 
JNB TF0, HERE	; wait until timer reached 10ms
MOV A, TL1
MOV TL1, #0H	; reset rev count
MOV B, #4
MUL AB
XCH A,B		; need to check if A overflowed
JNZ SIXTEEN
XCH A,B
CLR P3.5		; stop timer by giving LOW to INT1 pin
CLR TF0		; clear timer of flag
RET			; return from timer function

HEXTODECTOASCII:
	MOV R1, #63H
	; pad 2 zero’s
	MOV @R1, #'0'
	INC R1
	MOV @R1, #'0'
	INC R1
	; enter division
	ACALL DIVISION

HEXTODECTOASCIITWO:
	MOV R1, #63H
	; pad 2 zero’s
	MOV @R1, #'0'
	INC R1 ;64H
	MOV @R1, #'0'
	INC R1 ;65H

	MOV B, #30H
	MOV A, R7
	ADD A, B
	MOV @R1, A
	INC R1 ; 66H
	
	MOV A, R6
	ADD A,B
	MOV @R1, A
	INC R1 		; 67H

	MOV A, R5
	ADD A,B
	MOV @R1, A

	ACALL LCD

DIVISION:
	MOV B, #10
	DIV AB
	XCH A,B
	ADD A, #30H
	MOV @R1, A
	XCH A,B
	JZ LCD
	INC R1
	SJMP DIVISION

SIXTEEN:
	XCH A,B		; put the lower and higher bytes back in order
	CLR P3.5		; stop timer by giving LOW to INT1 pin
CLR TF0		; clear timer of flag
	
	ACALL SPLIT
	; R5 has first digit, R6 second, R7 third
	JMP HEXTODECTOASCIITWO 	; conversion function for 16-bits

SECOND: 
	INC R1
	INC R0		; go to higher byte stored in 71H
	MOV A, @R0		; put higher byte into A
	JZ LCD
	JMP DIVISION

SPLIT:
	; split the 16 bit number
	MOV R4, B		; store original higher byte into R4
	MOV B, #10
	DIV AB		; first digit
	MOV R7, B		; store first digit into R7
	
	DIV AB	
	MOV R6, B		; second digit into R6
	
	ADD A, R4
	MOV R5, A		; put this digit into R5 (MSB)
	
MOV A, R7		; put first digit back into A
	MOV B, #2		
	MUL AB
	; assume number is only in A
	MOV B, #10
	DIV AB		; divide mul 2 number by 10
	MOV R7, B		; save remainder
	MOV R3, A		; store quotient

MOV A, R6		; get second digit
ADD A, R3		; add quotient + second digit
MOV B, #2
MUL AB
	MOV B, #10
	DIV AB	
	MOV R6, B		; save 2nd remainder
	MOV R3, A		; store 2nd quotient

	MOV A, R5		; get first digit (MSB)
	ADD A, R3		; add quotient + third digit
	MOV B, #2
	MUL AB
ADD A, R4
	MOV B, #10
	DIV AB
MOV R5, #6
		
	RET			; return to SIXTEEN

LCD:
	CLR P3.3		; clear RS
	MOV P1, #38H	; set interface data length to 8 bits, 2 line, 5x7 font
	ACALL PulseE

;entry mode set
MOV P1, #06H
	ACALL PulseE
	
	;display on/off control
	MOV P1, #0FH
	ACALL PulseE

	;send data
	SETB RS		; clear RS
	JMP LOOP
PulseE:
	SETB P3.2		; negative edge on E
	CLR P3.2
	ACALL DELAYL
	RET

DELAYL:	;delay for lcd, dont want to wait 10ms
	MOV R0, #50
	DJNZ R0, $
	RET

sendCharacter:
	MOV P1, A
	ACALL PulseE
	RET
