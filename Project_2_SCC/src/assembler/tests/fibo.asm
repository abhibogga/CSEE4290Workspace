    ORG     #0x400;
    FCB     #0x0; slot 0
    FCB     #0x0; slot 1
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;

    ORG     #0x0;


; OUTPUT 0, 1, 1, 2, 3, 5, 8, 13, 21, 34
setup:
    MOV     R4, #0x400;     ; base address to store fib numbers
    MOV     R5, #0xA;       ; total numbers to generate = 10
    MOV     R0, #0x0;       ; fib(0)
    MOV     R1, #0x1;       ; fib(1)
    STOR    R0, R4;         ; store 0
    ADD     R4, R4, #0x4;
    STOR    R1, R4;         ; store 1
    ADD     R4, R4, #0x4;
    SUB     R5, R5, #0x2;   ; two numbers already stored

fib_loop:
    CMP     R5, #0x0;
    B.eq    done;

    ; emulate "R2 = R0 + R1" without MOV Rsrc,Rdst:
    ADD     R2, R0, R1;     ; fib_next = a + b
    STOR    R2, R4;         ; store result
    ADD     R4, R4, #0x4;   ; advance pointer

    ; shift registers manually:
    ; R0 = R1 → use temp memory
    MOV     R6, #0x500;
    STOR    R1, R6;         ; save old R1 to mem
    LOAD    R0, R6;         ; load back into R0

    ; R1 = R2 (same trick)
    STOR    R2, R6;
    LOAD    R1, R6;

    SUB     R5, R5, #0x1;
    B       fib_loop;

done:
    HALT;
