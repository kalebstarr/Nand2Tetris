// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/4/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, 
// the screen should be cleared.

(LOOP)
    @KBD
    D=M
    @COLOR_BLACK
    D;JNE
    @COLOR_WHITE
    D;JEQ
    @LOOP
    0;JMP

(COLOR_BLACK)
    @R5
    D=M
    @SCREEN
    A=D+A
    M=-1
    
    @R5
    M=M+1

    @R5
    D=M
    @8191
    D=D-A
    @CLEAR
    D;JGT

    @COLOR_BLACK
    0;JMP

(COLOR_WHITE)
    @R5
    D=M
    @SCREEN
    A=D+A
    M=0
    
    @R5
    M=M+1

    @R5
    D=M
    @8191
    D=D-A
    @CLEAR
    D;JGT

    @COLOR_WHITE
    0;JMP

(CLEAR)
    @R5
    M=0

    @LOOP
    0;JMP