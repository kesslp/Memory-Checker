*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
        
        SUB.B   D0,D1          *works
        SUB.W   D3,D4          *works
        SUB.L   D5,D6          *works
        SUB.B   (A0),D0        *works
        SUB.B    D0,(A5)       *works
        SUB.W   (A6),D3        *works
        SUB.L    D5,(A4)       *works
        SUBQ.W    #8,D2        *works
        
        ADD.B   D0,D1
        ADD.W   D2,D3
        ADD.L   D4,D5
        ADD.B   (A1),D3
        
        ADDA.W  A1,A2
        ADDA.L  A3,A5
        
        
        *DIVS.W    D1,D0        *works
        *DIVS.W    (A0),D4      *works
        *DIVS.W    #10,D4       *does not work
        *ADD.B     #10,D0       *does not work
        *DIVS.L      $00000000,D1:D2 *dont know the syntax
        LEA     (A2),A1

    SIMHALT             ; halt simulator

* Put variables and constants here

MSG     DC.B    'Hai',0

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
