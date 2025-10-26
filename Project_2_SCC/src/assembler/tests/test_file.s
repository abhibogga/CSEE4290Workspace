    ORG     #0x000
start:
    MOV     R1, #0xFFFF       ; lower 16 bits = all 1’s
    AND     R2, R1, #0xFFFF        ; 0xFFFFFFFF & 0xFFFFFFFF = 0xFFFFFFFF
    HALT
