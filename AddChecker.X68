*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
        
        ADD.W      D0, D3
        ADD.W      D3, D4
        ADD.W      D2, D5
        ADD.B      #1, D0

    SIMHALT             ; halt simulator
        
* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
