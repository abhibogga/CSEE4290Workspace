.global _start
.text
_start:
    MOVZ x0, #0x50      
    MOVZ x1, #0x13C
    MOVZ x5, #0x66 //The # means that its a literal value, not a label

    //Store Unsigned Byte [Register, address offset]
    STURB W5, [X0]
	STURB W6, [X0, #1]
    STURB WZR, [X0, #2] 
    YIELD