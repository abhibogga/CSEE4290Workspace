    ORG #0x400;
R2DATA:
    FCB #0x12345678;  

    ORG #0x0;

    MOV R2, #0x0;
    MOV R5, #0x400;
setup:
    MOV R0, #0x0;
    MOV R1, #0x04;
SOMETHING:    
    ADDS R0, R0, #0x01;

CHECK1:
    SUBS R4, R1, R0;
    B.NE SOMETHING;
    ADDS R2, R2, #0x01;
    STOR R2, R5;
    SUBS R2, R2, #0x02;
    B.EQ STOP;
    B setup;


STOP:
    HALT