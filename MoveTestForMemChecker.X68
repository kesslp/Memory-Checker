*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
counter EQU 0

    ORG    $400
START:                  ; first instruction of program

* Put program code here
            MOVE.B  #1,D0
            MOVE.B  #2,D1
            MOVE.B  #3,D2
            MOVE.B  #4,D3
            MOVE.B  #5,D4
            MOVE.B  #6,D5
            MOVE.B  #7,D6            


    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
