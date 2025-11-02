	MOV R1, #5
	MOV R2, #8
	SUBS R1, R1, #1 ;address 4
	B.EQ DONE
	BR R2
DONE:
	HALT
