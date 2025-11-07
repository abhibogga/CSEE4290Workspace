start:
    MOV R2, #0x0;
    MOV R5, #0x400;
setup:
    MOV R0, #0x0;
    MOV R1, #0x04;
    B setup;
STOP:
    HALT