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

    LDURB  W2, [X0]  // Load byte into X2 from memory pointed to by X0 (*src)
    ADD X0, X0, #1 // Increment src pointer
    STURB  W2, [X1]  // Store byte in X2 into memory pointed to by X2 (*dst)
    ADD  X1, X1, #1     // Increment dst pointer
    CMP   X2, #0         // Was the byte 0? 
    BNE   _strcpyloop    // If not, repeat the _strcpyloop
    

    YIELD