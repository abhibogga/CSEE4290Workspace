n_flag:
    ORG #0x400;
    MOV R0, #4;
    ADDS R1, R0, #-6; //Result should be -2 with flags?

z_flag:
    ORG #0x404;
    MOV R0, #1;
    SUBS R1, R0, #1; //Result should be zero with flags

c_flag:
    ORG #0x408;
    MOV R0, #65535     
    ADD R1, R0, #1       
v_flag:
    ORG #0x40C
    MOV R0, #32767
    ADD R1, R0, #1
    HALT

    
