start:
    MOV R2, #0x0;
    MOV R5, #0x400;
setup:
    MOV R0, #0x0;
    MOV R1, #0x04;
SOMETHING:    
    ADD R0, R0, #0x01;


STOP:
    HALT