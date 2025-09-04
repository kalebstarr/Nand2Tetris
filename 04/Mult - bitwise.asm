// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/4/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
// The algorithm is based on repetitive addition.



// !!!!!!!!!WARNING!!!!!!!!!
// This code does not perform well enough for the tests.

// sum = 0
// for each bit (i) of Y:
//   if i is 1:
//     Add X shifted by bit position to sum
//   Shift X left by 1
//   Shift Y right by 1

    @sum
    M=0

    @R0
    D=M
    @num_x
    M=D
    @R1
    D=M
    @num_y
    M=D

(LOOP)
    // LOOP cond
    @num_y
    D=M
    @ASSIGN
    D;JEQ

    // Prepare return
    @POS1
    D=A
    @jumper
    M=D
    @GETLSB
    0;JMP

(POS1)
    @lsb
    D=M
    @POS2
    D;JEQ

    @num_x
    D=M
    @sum
    M=D+M

(POS2)
    // Shift x left
    @num_x
    D=M
    M=D+M

    @LOOP
    D=A
    @jumper
    M=D
    @SHIFTYRIGHT
    0;JMP

(ASSIGN)
    @sum
    D=M
    @R2
    M=D
(END)
    @END
    0;JMP

// Basically div 2
(SHIFTYRIGHT)
    @quot
    M=0
    (SHIFTYRIGHTLOOP)
        @num_y
        D=M
        @2
        D=D-A
        @SHIFTYRIGHTLOOPEND
        D;JLT

        @num_y
        M=M-1
        M=M-1
        @quot
        M=M+1

        @SHIFTYRIGHTLOOP
        0;JMP

    (SHIFTYRIGHTLOOPEND)
    @quot
    D=M
    @num_y
    M=D

    @jumper
    A=M
    0;JMP
    
(GETLSB)
    @num_y
    D=M
    @1
    D=D&A
    @lsb
    M=D

    @jumper
    A=M
    0;JMP
