    ORG     #0x600
RESULT:
    FCB     #0x0; FCB #0x0; FCB #0x0; FCB #0x0   ; reserve space at 0x600

    ORG     #0x0

    ; R1 will be our test register
    ; R6 will hold the destination address 0x600

setup:
    ; R1 = 0x0000ABCD using MOV (low 16 bits)
    MOV     R1, #0xABCD      ; after this: R1 = 0x0000ABCD

    ; R1 = 0x1234ABCD using MOVT (high 16 bits)
    MOVT    R1, #0x1234      ; after this: R1 = 0x1234ABCD

    ; R6 = 0x600 (base address where we'll write the result)
    CLR     R6
    ADD     R6, R6, #0x600   ; R6 = 0x00000600

    ; store R1 -> [R6 + #0]
    STOR   R1, R6, #0       ; memory[0x600] = 0x1234ABCD

    HALT
