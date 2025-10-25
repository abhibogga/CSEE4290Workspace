    ORG     #0x000
start:
    MOV     R1, #0x1234     ; any value
    CMP     R1, R1          ; sets flags: N=0, Z=1, C=0, V=0
    MOVF    R2              ; move NZCV into low nibble of R2; upper bits = 0
    HALT
