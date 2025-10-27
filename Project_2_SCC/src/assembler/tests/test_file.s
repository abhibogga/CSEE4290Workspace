	ORG     #0x000

; --- Case A: basic add ---
caseA_basic:
    MOV     R1, #0x1234          ; R1 = 0x00001234
    MOV     R2, #0x0001          ; R2 = 0x00000001
    ADD     R3, R1, R2           ; expect R3 = 0x00001235

; --- Case B: MSB remains set after add ---
caseB_msb:
    MOV     R4, #0x0000
    MOVT    R4, #0x8000          ; R4 = 0x80000000
    MOV     R5, #0x0001
    ADD     R6, R4, R5           ; expect R6 = 0x80000001

; --- Case C: wraparound (no flags since plain ADD) ---
caseC_wrap:
    SET     R7                    ; R7 = 0xFFFFFFFF
    MOV     R8, #0x0001
    ADD     R9, R7, R8           ; expect R9 = 0x00000000

; --- Case D: full 32-bit add ---
caseD_full32:
    MOV     R10, #0xABCD
    MOVT    R10, #0x1234         ; R10 = 0x1234ABCD
    MOV     R11, #0x1111
    MOVT    R11, #0x2222         ; R11 = 0x22221111
    ADD     R12, R10, R11        ; expect R12 = 0x3456BCDE

done:
    HALT
