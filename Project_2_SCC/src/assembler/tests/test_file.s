	ORG     #0x000

caseA_or_identity:
    ; x | 0 -> x
    MOV     R1, #0x1234
    MOV     R2, #0x0000
    OR      R3, R1, R2          ; expect R3 = 0x00001234

caseB_or_disjoint_masks:
    ; 0xF0F0 | 0x0F0F -> 0x0000FFFF
    MOV     R4, #0xF0F0
    MOV     R5, #0x0F0F
    OR      R6, R4, R5          ; expect R6 = 0x0000FFFF

caseC_or_set_msb:
    ; Force MSB = 1
    MOV     R7, #0x0000
    MOVT    R7, #0x8000         ; R7 = 0x80000000
    OR      R8, R7, R1          ; expect R8 = 0x80001234

done_or:
    HALT
