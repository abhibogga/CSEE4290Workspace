lable1:
    MOV r2, #0x3
    SUB r1, r3, #0x9
    ADD r0, r12, #0x3
    ADDS r0, r14, #0x5
;
thingy:
    CMP r1,r1, #0x40
    AND r4,r3, #0x32
    ANDS r4, r3, #0xa3
    or r4,r15, #0x4a
    ors r4,r15, #0x4a
    not r0, r3
    B lable1; check this for errors
    B #0x0000
    
    BR r4, #0xa5
    MOV32 r3, #0x0
    XOR r1,r2,r3
    XORS r1,r2,r3


    HALT