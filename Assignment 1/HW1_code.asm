ORG 00h
	JMP MAIN
ORG 40H
MAIN:
	MOV R0, #40H	;start storing fib num from here
	MOV R7, #6	;number of fib to be generated
	MOV R1, #00H
	MOV @R0, #0H;move first number in memory
	INC R0
	MOV @R0,#01H	;move the second number
	MOV R2, #01H
	
LABEL:
	INC R0		;move to next open space
	MOV A, R1
	ADD A, R2	;add two numbers
	MOV @R0, A	;store total into memory
	MOV B, R2	;store second number 
	MOV R1, B	;second number in R1
	MOV R2, A 	;total in R2
	DJNZ R7,LABEL	;loop
	END 
