	ORG     #0x000

caseA_self_xor_zero:
    ; XOR with itself -> 0  => Z=1, N=0
    MOV     R1, #0x1234
    XORS    R2, R1, #0x1234
    MOVF    R3                  ; expect NZCV = 0100 -> R3 = 0x00000004

caseB_keep_msb_set:
    ; XOR with 0 keeps value; MSB=1 => N=1, Z=0
    MOV     R4, #0x0000
    MOVT    R4, #0x8000         ; R4 = 0x80000000
    XORS    R5, R4, #0x0000
    MOVF    R6                  ; expect NZCV = 1000 -> R6 = 0x00000008

caseC_sign_ext_edge:
    ; 0xFFFF sign-extends to 0xFFFFFFFF -> N=1, Z=0  (if your design zero-extends, adjust expectations)
    MOV     R7, #0x0000
    XORS    R8, R7, #0xFFFF
    MOVF    R9                  ; expect NZCV = 1000 -> R9 = 0x00000008

caseD_alt_patterns:
    ; Alternate patterns stress: 0xAAAA_AAAA ^ 0x0000_5555 -> MSB=1
    MOV     R10, #0xAAAA
    MOVT    R10, #0xAAAA        ; R10 = 0xAAAA_AAAA
    XORS    R11, R10, #0x5555   ; R11 = 0xAAAA_FFFF
    MOVF    R12                 ; expect NZCV = 1000 -> R12 = 0x00000008

caseE_cancel_to_zero:
    ; 1 ^ 1 -> 0 => Z=1
    MOV     R13, #0x0001
    XORS    R0,  R13, #0x0001
    MOVF    R2                  ; expect NZCV = 0100 -> R2 = 0x00000004

done:
    HALT
