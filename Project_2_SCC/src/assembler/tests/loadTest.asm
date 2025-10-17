start:
    ORG #0x400;
    FCB #0x1234;

    ORG #0x404;
    FCB #0x5678;

    ORG #0x408;
    FCB #0x8765;

    ORG #0x0000;

    LOAD R0, R0, #0x400;

    LOAD R1, R0, #0; 
    LOAD R2, R0, #4;
    LOAD R3, R0, #8;

    HALT;

