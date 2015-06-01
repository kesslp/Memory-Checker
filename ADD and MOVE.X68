*-----------------------------------------------------------
* Title      : ADD and MOVE
* Written by : Joscelyn
* Date       : 5/24/2015 
* Description: 
*-----------------------------------------------------------
CR EQU $0D
LF EQU $0A

mask    EQU $0000000F
counter EQU 0

    ORG    $400
START:                  ; first instruction of program

* Put program  here
getOpCode
    
    LEA     code,A0
    MOVE.W  (A0),D4
    
    MOVE.W  D4,D2
    
    ROL.W   #4,D2
    
    AND.L   #mask,D2
    
    MOVE.B  D2,D5
    
oriOpCode
    CMP.B   #0,D5
    BNE     moveByteOpCode
    
moveByteOpCode
    CMP.B   #1,D5
    BNE     moveWordOpCode 

moveByteMethod
    LEA     outputMOVE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputByte,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA
    
    BRA     DONE
    

moveWordOpCode
    CMP.B   #3,D5
    BNE     moveLongOpCode
   
moveWordMethod
    MOVE.W  A2,D2
    MOVE.W  #10,D1
    ROL.W   D1,D2
    
    CMP.W   #1,D2
    BEQ     moveAWordMethod    
    
    LEA     outputMOVE,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveWordMethodpt2
    
moveAWordMethod
    LEA     outputMOVEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveWordMethodpt2
    
moveWordMethodpt2
    LEA     outputWord,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA

    BRA     DONE

moveLongOpCode
    CMP.B   #2,D5
    BNE     addOpCode
    
moveLongOpCodeMethod
    MOVE.W  A2,D2
    MOVE.W  #10,D1
    ROL.W   D1,D2
    
    CMP.W   #1,D2
    BEQ     moveALongMethod   

    LEA     outputMOVE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     moveLongMethodpt2
    
moveALongMethod
    LEA     outputMOVEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     moveLongMethodpt2
    
moveLongMethodpt2
    
    LEA     outputLong,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     moveDestinationEA    
    BRA     DONE

addOpCode
    CMP.B   #13,D5
    BNE     DONE     

addMethod
    LEA     outputADD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     dotOpMode           *Checks if it's a byte,word, or long
    
    CMP.B   #1,D6
    BEQ     altOrder   
    
    JSR     sourceEA            *outputs what the source is
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addDestinationEA       *outputs what the destination is
    
    BRA     DONE
    
altOrder
    JSR     addDestinationEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    BRA     DONE

dotOpMode
    LEA     code,A2
    MOVE.W  (A2),D3
    MOVE.B  #10,D2
    
    ROL.W   D2,D3
    AND.L   #$00000007,D3
    
    CMP.B   #3,D3
    BGT     altOpMode
    
    BRA     byteOpMode    

altOpMode                       *Dn is the source
    MOVE.B  #1,D6
    AND.B   #$3,D3
    BRA     byteOpMode
    
byteOpMode
    CMP.B   #0,D3
    BNE     wordOpMode
    
    LEA     outputByte,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
    
wordOpMode
    CMP.B   #1,D3
    BNE     longOpMode
    
    LEA     outputWord,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
    
longOpMode
    LEA     outputLong,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
    
    
sourceEA
    LEA     code,A2
    MOVE.W  (A2),D3
    MOVE.W  D3,D2
    
    ROR.W   #3,D2
    AND.L   #$00000007,D2       *D2 has Mode
    

    AND.L   #$00000007,D3       *D3 has Register

    
DnMode                          *Mode is a Data Register
    CMP.B   #0,D2
    BNE     AnMode
    
    LEA     outputDn,A1
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS
  
AnMode                          *Mode is an Address Register
    CMP.B   #1,D2
    BNE     deRefAnMode
    
    LEA     outputAn,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS
    
deRefAnMode
    CMP.B   #2,D2
    BNE     immidiateData
    
    LEA     outputdeRefAn1,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    LEA     outputdeRefAn2,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    RTS
    
immidiateData                   *Mode is an #<data>
    LEA     outputPound,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15

    RTS
    

addDestinationEA                *Since ADD only has data register in dest area
    LEA     code,A2
    MOVE.W  (A2),D3
    
    MOVE.W  D3,D2
    
    MOVE.L  #10,D1
    ROL.W   D1,D2
    AND.L   #$00000007,D2
    
    
    ROL.W   #7,D3
    AND.L   #$00000007,D3
    
DnRegister                      *For ADD only
    LEA     outputDn,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS

moveDestinationEA
    LEA     code,A2
    MOVE.W  (A2),D3
    MOVE.W  D3,D2
    
    ROL.W   #7,D3
    AND.L   #$00000007,D3       *D3 has Register
    
    MOVE.W  #10,D1      
    ROL.W   D1,D2               *D2 has Mode
    AND.L   #$00000007,D2
    
    BRA     DnMode
    
DONE

    SIMHALT             ; halt simulator

* Put variables and constants here

code        DC.W    $D640

addCode     DC.W    $D640

moveCode1   DC.W    $303C
moveCode2   DC.W    $0011

outputADD   DC.B    'ADD.',0
outputMOVE  DC.B    'MOVE.',0
outputMOVEA DC.B    'MOVEA.',0

outputByte  DC.B    'B ',0
outputWord  DC.B    'W ',0
outputLong  DC.B    'L ',0

outputdeRefAn1   DC.B    '(A',0
outputdeRefAn2   Dc.B    ')',0

outputAn    DC.B    'A',0
outputDn    DC.B    'D',0
outputPound DC.B    '#',0

outputComma DC.B    ',',0
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
