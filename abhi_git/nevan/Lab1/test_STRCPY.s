.global _start
.text
_start:

MOVZ X0, #0x0050 //address of source...pointers need to be x registers
//because 64 bit addressing in ARM8-A
MOVZ X1, #0x013C //address of destination
MOVZ X5, #0x65 //asci for e
MOVZ X6, #0x66 //asci for f


STURB W5, [X0] //put e into source addresss
STURB W6, [X0,#1] //put f into the address one next to the source
//now you have a string to copy..."ef".
STURB WZR, [X0,#2] //put 0 after your string
//so the computer understands where to stop

_strcpyloop:

LDURB W2, [X0] //load e from memory into working register 2
ADD X0,X0,#1 //increment source pointer
STURB W2, [X1] //store e from register into destination in memory
ADD X1,X1,#1//increment destination pointer
CMP X2,#0 //see if your working register is 0 (end of string)
BNE _strcpyloop //if NOT, loop again
YIELD
