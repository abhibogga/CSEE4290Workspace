    ORG     #0x000

start:
    MOV     R1, #0x81        ; seed = 0b1000_0001
    LSR     R2, R1, #1       ; expect R2 = 0x00000040
    HALT
