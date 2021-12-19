ORG 00H
	SJMP MAIN
ORG 40H
N1: 
	DB "23" ;40H=0x32H,41H=0x33H
	DB 0
N2: 
	DB "58" ;43H=0x35H,44H=0x38H
	DB 0

;function to increment dptr
INCPTR: 
	INC DPTR ;move to next code mem
	CLR A ;reset accumulator
	MOVC A, @A+DPTR
	RET

MAIN:
	MOV DPTR, #N1
	MOVC A, @A+DPTR 
	SUBB A, #30H
	MOV B, #10
	MUL AB
	MOV R0, A ;first digit into r0

	CALL INCPTR

	SUBB A, #30H
	ADD A, R0
	MOV R1, A ;store dec into R1

	CALL INCPTR

	;check for null char
	;if null, move onto new number
	;if not, continue to do same thing
	CJNE A, #0, CONT 
	MOV DPTR, #N2 ;move to 2nd #
	MOVC A, @A+DPTR 
	SUBB A, #30H
	MOV B, #10
	MUL AB
	MOV R0, A ;first digit r0
	CALL INCPTR

	SUBB A, #30H
	ADD A, R0 ;decimal in A
	MOV R3, A ; decimal in R3
	
	MOV B, R3 ;store seocnd number into R1
	MOV A, R1 ;store first number	
	MUL AB
	MOV 40H, B
	MOV 41H, A
	SJMP EXIT
CONT: ;A is not 0
	MOV R2, A ;store third digit
	MOV A, R1 ;store first digit
	MOV B, #10
	MUL AB ;move two digits to 100 place
	MOV R0, A ;store into r0
	MOV A, R2 ;move third back into A
	SUBB A, #30H
	ADD A, R0
	MOV R0, A ;store decimal in r0
	
	MOV DPTR, #N2 ;move to 2nd #
	CLR A
	MOVC A, @A+DPTR 
	SUBB A, #30H
	MOV B, #10
	MUL AB
	MOV R1, A ;first digit into r0
	
	CALL INCPTR
	
	SUBB A, #30H
	ADD A, R1
	MOV B, #10
	MUL AB, 
	MOV R1, A ;store dec into R1
	
	CALL INCPTR
	
	SUBB A, #30H
	ADD A, R1 ;add last digit 
	MOV R1, A ;store decimal in r0

	MOV B, R0 ;store first number into R1
	MOV A, R1 ;store second number	
	MUL AB
	MOV 40H, B
	MOV 41H, A
EXIT:
	END
	
	
	


		


