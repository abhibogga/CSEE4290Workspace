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

// string copy loop
_strcpyloop:
    LDRB   W2, [X0], #1       // load byte from *src
    STRB   W2, [X1], #1       // store byte into *dst
    CMP     X2, #0         // check if null
    BNE     _strcpyloop    // repeat until zero

YIELD