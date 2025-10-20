;==============================================================
;  Software MUL Immediate (SCC ISA compliant)
;  Computes: R0 = R0 * #imm
;==============================================================

    ORG     #0x0

;---------------------------------------------
; Setup registers
;---------------------------------------------
    ADD     R1, R0, #0x0      ; R1 = R0 (copy multiplicand)
    CLR     R2                ; R2 = 0 (accumulator)
    MOV     R3, #0xA          ; R3 = multiplier (immediate 10)
                              ; change #0xA to any constant

;---------------------------------------------
; Multiply loop (shift-and-add)
;---------------------------------------------
LOOP:
    AND     R4, R3, #0x1      ; isolate LSB of multiplier
    CMP     R4, #0x0
    B.eq    SKIP_ADD

    ADD     R2, R2, R1        ; if LSB=1, add multiplicand

SKIP_ADD:
    LSL     R1, R1, #0x1      ; multiplicand <<= 1
    LSR     R3, R3, #0x1      ; multiplier >>= 1
    CMP     R3, #0x0
    B.ne    LOOP

;---------------------------------------------
; Store result back to destination
;---------------------------------------------
    ADD     R0, R2, #0x0      ; R0 = R2 (copy result)

;---------------------------------------------
; End program
;---------------------------------------------
    HALT
