    ORG     #0x400;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;
    FCB     #0x0;

    ORG     #0x500;
RESULT:
    FCB     #0x0;

    ORG     #0x0;

setup:
    CLR     R4;              ; R4 = 0
    ADD     R4, R4, #0x400;  ; base ptr = 0x400

    CLR     R5;
    ADD     R5, R5, #0xA;    ; length = 10

    CLR     R6;
    ADD     R6, R6, #0x500;  ; RESULT address = 0x500

initialize:
    LOAD    R0, R4;          ; first element x0
    ADD     R1, R0, #0;      ; current_sum = x0
    ADD     R2, R0, #0;      ; max_sum = x0
    ADD     R4, R4, #1;      ; advance ptr
    SUB     R5, R5, #1;      ; remaining count

kadane_loop:
    CMP     R5, #0;
    B.eq    done;

    LOAD    R0, R4;          ; x = *ptr
    ADDS    R3, R1, R0;      ; temp = current_sum + x (updates flags)
    CMP     R3, R0;
    B.ge    keep_temp;
    ADD     R1, R0, #0;      ; current_sum = x
    B       check_max;
keep_temp:
    ADD     R1, R3, #0;      ; current_sum = temp
check_max:
    CMP     R1, R2;
    B.le    step;
    ADD     R2, R1, #0;      ; max_sum = current_sum
step:
    ADD     R4, R4, #1;
    SUB     R5, R5, #1;
    B       kadane_loop;

done:
    STOR   R2, R6;          ; RESULT = max_sum @ 0x500
    HALT;
