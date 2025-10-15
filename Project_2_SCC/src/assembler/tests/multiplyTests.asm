ORG #0x400;

// -----------MUL Tests------------
start:
    //Two positive values in registers
    MOV R0, #3;
    MOV R1, #7;
    MUL R2, R1, R0;
    STOR R2, #0x400; //Result should be 21

    //Zero test
    MOV R0, #0;
    MOV R1, #7;
    MUL R2, R1, R0;
    STOR R2, #0x408; //Result should be 0

    //Negative Tests
    MOV R0 ,#-3;
    MOV R1, #7;
    MUL R2, R1, R0;
    STOR R2, #0x404; //Result should be -21, no flags updated @this time

    MOV R0, #-4;
    MOV R1, #-5;
    MUL R2, R0, R1;
    STOR R2, #0x40C; //Result should be 20
    
// -----------MULI Tests------------
    //Two postive register immediete values
    MOV     R0, #3;
    MULI    R2, R0, #7;
    STOR    R2, #0x410; //Result should be 21
    
    //Zero test
    MOV     R0, #0;
    MULI    R2, R0, #7;
    STOR    R2, #0x414; //Result should be 0

    //Negative Tests
    MOV     R0, #-3;
    MULI    R2, R0, #7;
    STOR    R2, #0x418; //Result should be -21, no flags updated @this time

    MOV     R0, #-4;
    MULI    R2, R0, #-5;
    STOR    R2, #0x41C; //Result should be 20
// -----------MULS Tests------------
    //Two positive values in registers
    MOV R0, #3;
    MOV R1, #7;
    MULS R2, R1, R0;
    STOR R2, #0x420; //Result should be 21

    //Zero test
    MOV R0, #0;
    MOV R1, #7;
    MULS R2, R1, R0;
    STOR R2, #0x424; //Result should be 0

    //Negative Tests
    MOV R0 ,#-3;
    MOV R1, #7;
    MULS R2, R1, R0;
    STOR R2, #0x428; //Result should be -21, no flags updated @this time

    MOV R0, #-4;
    MOV R1, #-5;
    MULS R2, R0, R1;
    STOR R2, #0x42C; //Result should be 20
// -----------MULSI Tests------------
    //Two postive register immediete values
    MOV     R0, #3;
    MULSI    R2, R0, #7;
    STOR    R2, #0x430; //Result should be 21
    
    //Zero test
    MOV     R0, #0;
    MULSI    R2, R0, #7;
    STOR    R2, #0x434; //Result should be 0

    //Negative Tests
    MOV     R0, #-3;
    MULSI    R2, R0, #7;
    STOR    R2, #0x438; //Result should be -21, no flags updated @this time

    MOV     R0, #-4;
    MULSI    R2, R0, #-5;
    STOR    R2, #0x43C; //Result should be 20

    HALT;
