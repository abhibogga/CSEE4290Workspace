	ORG     #0x000

; A) XOR with self → 0
case_xor_self_zero:
    MOV     R1, #0x1357
    XOR     R2, R1, #0x1357         ; expect R2 = 0x00000000

; B) XOR with zero → identity
case_xor_zero_identity:
    MOV     R3, #0xBEEF
    XOR     R4, R3, #0x0000         ; expect R4 = 0x0000BEEF

; C) Toggle only MSB (start with MSB clear)
case_xor_toggle_msb_up:
    MOV     R5, #0x0000
    XOR     R6, R5, #0x8000         ; expect R6 = 0x80000000

; D) Toggle MSB when already set
case_xor_toggle_msb_down:
    MOV     R7, #0x0000
    MOVT    R7, #0x8000             ; R7 = 0x80000000
    XOR     R8, R7, #0x8000         ; expect R8 = 0x00000000

; E) Alternating patterns stress
case_xor_alt_patterns:
    MOV     R9,  #0xAAAA
    MOVT    R9,  #0xAAAA            ; R9 = 0xAAAA_AAAA
    XOR     R10, R9, #0x5555        ; expect R10 = 0xAAAA_FFFF

; F) Sign-extended immediate edge (#0xFFFF → 0xFFFFFFFF)
case_xor_signext_all_ones:
    MOV     R11, #0x0000
    XOR     R12, R11, #0xFFFF       ; expect R12 = 0xFFFFFFFF

done_xor:
    HALT
