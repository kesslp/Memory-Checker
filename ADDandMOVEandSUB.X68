*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR EQU $0D
LF EQU $0A

mask    EQU $0000000F
counter EQU 0

    ORG    $400
START:                  ; first instruction of program

* Put program  here
getOpCode                       *Gets opcode
    LEA     code,A0             *Loads "code" which is the op code
    MOVE.W  (A0),D4
    
    MOVE.W  D4,D2               *gets put into D4 and D2
    
    ROL.W   #4,D2               *rotate the first 4 significant bits to lower 4 bits
    
    AND.L   #mask,D2            *mask it to get only the first byte
    
    MOVE.B  D2,D5               *put that value into D5

nopOpCode
    CMP.W   #$4E71,D4
    BNE     rtsOpCode
    
    LEA     outputNOP,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     DONE
    
rtsOpCode
    CMP.W   #$4E75,D4
    BNE     leaOpCode
    
    LEA     outputRTS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
leaOpCode
    CMP.B   #4,D5
    BNE     oriOpCode
    
    LEA     outputLEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    BRA     DONE
    
oriOpCode                       *OR opcode
    CMP.B   #0,D5               
    BNE     moveByteOpCode      *if not, go to next opcode
    
moveByteOpCode                  *MOVE.B opcode
    CMP.B   #1,D5
    BNE     moveWordOpCode 

moveByteMethod                  *MOVE.B output
    LEA     outputMOVE,A1       *Outputs "MOVE" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputByte,A1       *Outputs ".B" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA            *Jump to subroutine sourceEA
    
    LEA     outputComma,A1      *Outputs a comma onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA   *Jump to subroutine moveDestinationEA
    
    BRA     DONE                *Yay done
    

moveWordOpCode                  *MOVE.W opcode
    CMP.B   #3,D5
    BNE     moveLongOpCode
   
moveWordMethod                  *MOVE.W output
    MOVE.W  D4,D2               *D4 has the original word
    MOVE.W  #10,D1              *Move the value 10 into D1 since ROL has issues with
    ROL.W   D1,D2               *   immediate values > 8
    
    CMP.W   #1,D2               *If the rotated value is a 1, it's a MOVEA.W
    BEQ     moveAWordMethod    
    
    LEA     outputMOVE,A1       *Outputs "MOVE." onto console
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveWordMethodpt2   *Go to the rest of the method~
    
moveAWordMethod                 *MOVEA.W opcode
    LEA     outputMOVEA,A1      *Outputs "MOVEA" onto console
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveWordMethodpt2   *Go to the rest of the method~
    
moveWordMethodpt2               *Part 2 of the MOVE/MOVEA.W series
    LEA     outputWord,A1       *Outputs ".W" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA            *Yay subroutines
    
    LEA     outputComma,A1      *outputs a comma onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA   *Gotta check the destination~

    BRA     DONE                *I'm done, bra

moveLongOpCode                  *MOVE.L opcode
    CMP.B   #2,D5
    BNE     addOpCode
    
moveLongOpCodeMethod            *MOVE.L output
    MOVE.W  A2,D2               *Gotta check if it's actually a MOVEA
    MOVE.W  #10,D1
    ROL.W   D1,D2
    
    CMP.W   #1,D2
    BEQ     moveALongMethod   

    LEA     outputMOVE,A1       *outputs "MOVE" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     moveLongMethodpt2   *Go to Part 2 of the MOVE series~
    
moveALongMethod                 *MOVEA.L output
    LEA     outputMOVEA,A1      *Outputs "MOVEA" onto console
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveLongMethodpt2   *Go to part 2~
    
moveLongMethodpt2               *Part 2, the sequel(SQL?)
    
    LEA     outputLong,A1       *Outputs ".L" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA            *Go output source
    
    LEA     outputComma,A1      *Yay commas
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA    *Output destination
    BRA     DONE

addOpCode                        *ADD opcode
    CMP.B   #13,D5
    BNE     subOpCode    
    
addMethod                        *ADD output
    LEA     outputADD,A1         *Outputs "ADD" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     dotOpMode           *Checks if it's a byte,word, or long
    
    CMP.B   #1,D6               *If D6 == 1, the data register is the source
    BEQ     altOrder            *   D6 was decided in dotOpMode(?)
    
    JSR     sourceEA            *outputs what the source is
    
    LEA     outputComma,A1      *Commas~~~
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addDestinationEA     *outputs what the destination is
    
    BRA     DONE
    
subOpCode
    CMP.B   #9,D5               *is it SUB?
    BNE     subQOpCode          *not SUB, check if SUBQ

subMethod
    LEA     outputSUB,A1        *output SUB to the console
    MOVE.B  #14,D0  
    TRAP    #15

    JSR     dotOpMode           *check if its a B,W, or L

    CMP.B   #1,D6               *if D6 == 1, the data register is the source
    BEQ     altOrder

    JSR     sourceEA            *outputs what the source is

    LEA     outputComma,A1      *commas
    MOVE.B  #14,D0
    TRAP    #15

    JSR     addDestinationEA    *outputs what ths destination is

    BRA     DONE                

subQOpCode
    CMP.B   #5,D5               *is it SUBQ?
    BNE     divsWOpCode         *check if its DIVS.W
    
subQMethod
    LEA     outputSUBQ,A1       *output SUBQ
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.W  D4,D3               *move original word from D4
    MOVE.B  #10,D1              *hacks
    ROL.W   D1,D3               *ROL by 10
    AND.L   #00000003,D3        *Mask 
    JSR     byteOpMode          *check if B,W,L
    
    JSR     subQData            *outputs #1-#8
    
    LEA     outputComma,A1      *commas
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA            *get the source
    
    BRA     DONE
    
    
subQData
    MOVE.W  D4,D3               *move original word from D4
    ROL.W   #7,D3               *ROL 7
    AND.L   #$00000007,D3       *mask the bits
    
    CMP.B   #0,D3               *if its 0 display 8
    BEQ     display8ForSubQ
    
    LEA     outputPound,A1      *output #
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1               *output 1-7
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *return to subQmethod
    
display8ForSubQ

    LEA     outputPound,A1      *output #
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #8,D1               *output 8
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *return to subQMethod
    
divsWOpCode
    CMP.B   #8,D5
    BEQ     divsWCheck          *bits 8,7,6 need to make 7 to be DIVSW
    
divsWCheck
    MOVE.W  D4,D3
    MOVE.B  #10,D2
    ROL.W   D2,D3
    AND.L   #$00000007,D3
    CMP.B   #7,D3
    BNE     DONE
    
    LEA     outputDIVSW,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA 
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addDestinationEA
    
    BRA     DONE

altOrder                            *outputs the Dn as the source for ADD
    JSR     addDestinationEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    BRA     DONE

dotOpMode                           *Checks if it's a Byte,Word, or Long for ADD and SUB
    MOVE.W  D4,D3                   *Gets the original code from D4                 
    MOVE.B  #10,D2                  *yay hacks
    
    ROL.W   D2,D3                   *Rotates the original left by 10 bits
    AND.L   #$00000007,D3           *mask it up
    
    CMP.B   #3,D3                   
    BGT     altOpMode               *if value is > 3, Dn is the source
    
    BRA     byteOpMode    

altOpMode                           *Dn is the source
    MOVE.B  #1,D6                   *D6 is 1 if Dn is the source
    AND.B   #$3,D3                  *Mask it so it can continue with the output
    BRA     byteOpMode              *without the meddling 2^2 bit
    
byteOpMode                          *It's a byte?
    CMP.B   #0,D3
    BNE     wordOpMode
    
    LEA     outputByte,A1           *Output ".B" !
    MOVE.B  #14,D0
    TRAP    #15
    RTS                             *Time to return back in time
    
wordOpMode                          *It's a word?
    CMP.B   #1,D3
    BNE     longOpMode
    
    LEA     outputWord,A1           *Output ".W" onto console
    MOVE.B  #14,D0
    TRAP    #15
    RTS                             *Time warp~
    
longOpMode                          *It better be a long then
    LEA     outputLong,A1           *outputs ".L" onto console
    MOVE.B  #14,D0
    TRAP    #15
    RTS                             *whoosh~
 
    
sourceEA                            *output the Source EA
    MOVE.W  D4,D3                   *Put the original opcode into D3
    MOVE.W  D3,D2                   *Copy that into D2
    
    ROR.W   #3,D2                   *Whoo~ Rotating~
    AND.L   #$00000007,D2           *D2 has Mode
    

    AND.L   #$00000007,D3           *D3 has Register

 
DnMode                          *Is the Mode a Data Register?
    CMP.B   #0,D2
    BNE     AnMode
    
    LEA     outputDn,A1         *outputs "D" onto console
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.B  D3,D1               *outputs the register, whatever the numeric value is
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *wooo~
  
AnMode                          *Mode is an Address Register?
    CMP.B   #1,D2
    BNE     deRefAnMode
    
    LEA     outputAn,A1         *Outputs "A" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1               *Outputs the register value
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *psssh
    
deRefAnMode                     *Mode is a (A0)?
    CMP.B   #2,D2               
    BNE     immidiateData
    
    LEA     outputdeRefAn1,A1   *Outputs "(A" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1               *outputs register value
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA     outputdeRefAn2,A1   *makes it pretty by outputting ")"
    MOVE.B  #14,D0
    TRAP    #15
    
    RTS                         *=-=
    
immidiateData                   *Mode is an #<data>
    LEA     outputPound,A1      *Outputs "#"
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1               *Outputs register value
    MOVE.B  #3,D0
    TRAP    #15

    RTS                         *~owo~
    

addDestinationEA                *Since ADD only has data register in dest area
    MOVE.W  D4,D3
    
    MOVE.W  D3,D2
    
    MOVE.L  #10,D1
    ROL.W   D1,D2
    AND.L   #$00000007,D2       *D2 has mode
    
    
    ROL.W   #7,D3
    AND.L   #$00000007,D3       *D3 has register
    
DnRegister                      *For ADD only, since it only has Dn 
    LEA     outputDn,A1         *outputs "D"
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1               *Outputs register value
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS

moveDestinationEA               *Destination output for MOVE
    MOVE.W  D4,D3
    MOVE.W  D3,D2
    
    ROL.W   #7,D3
    AND.L   #$00000007,D3       *D3 has Register
    
    MOVE.W  #10,D1      
    ROL.W   D1,D2               *D2 has Mode
    AND.L   #$00000007,D2
    
    BRA     DnMode              *output what it is, bra
    
DONE

    SIMHALT             ; halt simulator

* Put variables and constants here

code        DC.W    $43D2


addCode     DC.W    $D640

moveCode1   DC.W    $303C
moveCode2   DC.W    $0011

outputADD   DC.B    'ADD.',0
outputSUB   DC.B    'SUB.',0
outputSUBQ  DC.B    'SUBQ.',0
outputMOVE  DC.B    'MOVE.',0
outputMOVEA DC.B    'MOVEA.',0
outputDIVSW DC.B    'DIVS.W ',0
outputNOP   DC.B    'NOP ',0
outputRTS   DC.B    'RTS ',0
outputLEA   DC.B    'LEA ',0

outputByte  DC.B    'B ',0
outputWord  DC.B    'W ',0
outputLong  DC.B    'L ',0

outputdeRefAn1   DC.B    '(A',0
outputdeRefAn2   DC.B    ')',0

outputAn    DC.B    'A',0
outputDn    DC.B    'D',0
outputPound DC.B    '#',0

outputComma DC.B    ',',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
