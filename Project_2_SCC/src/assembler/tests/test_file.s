	ORG     #0x000

caseA_zero_result:
    ; R1 ^ R2 -> 0x00000000  → Z=1, N=0
    MOV     R1, #0x1234
    MOV     R2, #0x1234
    XORS    R3, R1, R2          ; expect R3 = 0x00000000
    MOVF    R7                  ; expect R7 low nibble = 0100 (0x4)

caseB_msb_set:
    ; Build MSB mask in a register, then toggle MSB from 0 → 1
    MOV     R4, #0x0000         ; R4 = 0
    MOV     R5, #0x8000
    LSL     R5, R5, #16         ; R5 = 0x80000000
    XORS    R6, R4, R5          ; expect R6 = 0x80000000  → N=1, Z=0
    MOVF    R8                  ; expect R8 low nibble = 1000 (0x8)

done:
    HALT
