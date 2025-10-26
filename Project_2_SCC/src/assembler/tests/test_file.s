	ORG     #0x000

caseA_invert_zero:
    MOV     R1, #0x0000
    NOT     R2, R1              ; expect R2 = 0xFFFFFFFF

caseB_invert_all_ones:
    SET     R3                  ; R3 = 0xFFFFFFFF
    NOT     R4, R3              ; expect R4 = 0x00000000

caseC_invert_pattern:
    MOV     R5, #0x55AA
    MOVT    R5, #0x55AA         ; R5 = 0x55AA55AA
    NOT     R6, R5              ; expect R6 = 0xAA55AA55

done:
    HALT
