.global _start
.text
_start:
    //place move instructions here
    MOVZ	X0, #0x0050
    MOVZ	X1, #0x013C
    MOVZ	X5, #0x65
    MOVZ	X6, #0x66

    // store values in memory
    STURB W5, [X0]
    STURB W6, [X0, #1]
    STURB WZR, [X0, #2]

//strcpy operation
_strcpyloop: 
    LDRB  W2, [X0, #1]  // Load byte into X2 from memory pointed to by X0 (*src)
    STRB W2, [X1, #1]  // Store byte in X2 into memory pointed to by X2 (*dst)
    CMP   X2, #0         // Was the byte 0? 
    BNE   _strcpyloop    // If not, repeat the _strcpyloop

YIELD