    ORG     #0x000

start:
    ; --- Case A: result = 0 → Z=1, N=0 ---
    MOV     R1, #0xF0F0
    MOVT    R1, #0xF0F0
    ANDS    R2, R1, #0x0F0F     ; R2 = 0x00000000
    MOVF    R3                  ; R3 low nibble = NZCV with Z=1

start2:
    ; --- Case B: result has MSB=1 → N=1, Z=0 ---
    MOV     R4, #0x0000
    MOVT    R4, #0x8000         ; R4 = 0x80000000
    ANDS    R5, R4, #0xFFFF     ; sign-extends to 0xFFFFFFFF → R5 = 0x80000000
    MOVF    R6                  ; R6 low nibble = NZCV with N=1

    HALT
