    ORG     #0x400

    FCB     #1,  #0, #0, #0
    FCB     #2,  #0, #0, #0
    FCB     #3,  #0, #0, #0
    FCB     #4,  #0, #0, #0
    FCB     #5,  #0, #0, #0
    FCB     #6,  #0, #0, #0
    FCB     #7,  #0, #0, #0
    FCB     #8,  #0, #0, #0
    FCB     #9,  #0, #0, #0
    FCB     #10, #0, #0, #0

    ORG     #0x500
RESULT:
    FCB     #0, #0, #0, #0

    ORG     #0

setup:
    CLR     R4
    ADD     R4, R4, #0x400

    CLR     R5
    ADD     R5, R5, #10 //Counter

    CLR     R6
    ADD     R6, R6, #0x500 //Result Address

initialize:
    LOAD    R0, R4             ; first element x0
    ADD     R1, R0, #0         ; current_sum = x0
    ADD     R2, R0, #0         ; max_sum = x0
    ADD     R4, R4, #4         ; advance ptr (word stride)
    SUB     R5, R5, #1         ; remaining count-- (now 9)

kadane_loop:
    ; head test: if remaining == 0 -> done
    SUBS    R7, R5, #0
    B.eq    done

    LOAD    R0, R4             ; x = *ptr
    ADDS    R3, R1, R0         ; temp = current_sum + x  (sets flags)

    ; current_sum = max(temp, x) using signed compare
    SUBS    R7, R3, R0         ; temp - x  (sets N,Z,V)
    B.lt    use_x              ; if temp < x, use x
    ADD     R1, R3, #0         ; current_sum = temp
    B       check_max
use_x:
    ADD     R1, R0, #0         ; current_sum = x

check_max:
    SUBS    R7, R1, R2         ; current_sum - max_sum
    B.le    step               ; if <=, skip update
    ADD     R2, R1, #0         ; max_sum = current_sum

step:
    ADD     R4, R4, #4         ; next element
    SUB     R5, R5, #1         ; remaining count--

    ; loop if remaining != 0 (set flags from R5 without faking them)
    ADDS    R7, R5, #0
    B.ne    kadane_loop

done:
    STOR    R2, R6             ; RESULT = max_sum @ 0x500
    HALT
