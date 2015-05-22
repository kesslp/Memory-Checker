*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
mask    EQU         $FFFF
stack   EQU         $B000

        ORG         $400
        CLR.B       D0
        LEA         start_addr_msg, A1
        LEA         ascii_val, A2
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #2, D0
        TRAP        #15
        MOVE.L      (A1),(A2)+
        
        
start   LEA         stack, SP
        CLR.W       D7
        LEA         ascii_val,A1
        MOVE.B      (A1)+,D0
        ANDI.W      #mask,D0
        JSR         strip_ascii
        ASL.W       #8,D0
        ASL.W       #4,D0
        OR.W        D0,D7
        MOVE.B      (A1)+,D0
        ANDI.W      #mask,D0
        JSR         strip_ascii
        ASL.W       #8,D0
        OR.W        D0,D7
        MOVE.B      (A1)+,D0
        ANDI.W      #mask,D0
        JSR         strip_ascii
        ASL.W       #4,D0
        OR.W        D0,D7
        MOVE.B      (A1)+,D0
        ANDI.W      #mask,D0
        JSR         strip_ascii
        OR.W        D0,D7
        MOVE.W      D7,(A1)+
        STOP        #$2700

strip_ascii CMP.B   #$39,D0
            BLE     sub30
            CMP.B   #$46,D0
            BLE     sub37
            SUB.B   #$57,D0
            BRA     ret_sa
sub37       SUB.B   #$37,D0
            BRA     ret_sa
sub30       SUB.B   #$30,D0
ret_sa      RTS

* Data

start_addr_msg DC.B 'Enter a starting address to disassemble: ', 0
end_addr_msg   DC.B 'Enter a ending address to stop disassembling: ', 0
ascii_val   DC.W    '',''
con_val     DS.W    1
            END     $400       
        
        

        

        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
