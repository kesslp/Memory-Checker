*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
mask    EQU         $00FF
stack   EQU         $B000

        ORG         $400
        CLR.B       D0
        LEA         start_addr_msg, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #2, D0
        TRAP        #15
        MOVE.L      (A1),ascii_val_start
        
        LEA         end_addr_msg, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVE.B      #2, D0
        TRAP        #15
        MOVE.L      (A1),ascii_val_end
        
start   LEA         stack,SP
        CLR.W       D7
        LEA         ascii_val_start, A1
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
        MOVE.W      D7,(A1)
        MOVE.W      (A1),st_val
        *MOVEA.W     st_val, A1
        *MOVE.L      (A1),D0
       
        LEA         stack,SP
        CLR.W       D7
        LEA         ascii_val_end, A1
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
        MOVE.W      D7,(A1)
        MOVE.W      (A1),end_val
        
        MOVEA.W     st_val,A0
        MOVEA.W     end_val,A1
        CLR.L       D0
        CLR.L       D1
        MOVE.L      (A0),D0
        MOVE.L      (A1),D1

strip_ascii CMP.B   #$39,D0 *Is it in range of 0-9?
            BLE     sub30   *It's a number
            CMP.B   #$46,D0 *Is it A...F?
            BLE     sub37   *It's A...F
            SUB.B   #$57,D0 *It's a...f
            BRA     ret_sa  *Go back
sub37       SUB.B   #$37,D0 *Strip 37
            BRA     ret_sa  *Go back
sub30       SUB.B   #$30,D0 *Strip 30
ret_sa      RTS             *Go back

* Data
        
start_addr_msg DC.B 'Enter a starting address to disassemble: $', 0
end_addr_msg   DC.B 'Enter a ending address to stop disassembling: $', 0
ascii_val_start DC.W    $0000
ascii_val_end   DC.W    $0000
st_val      DS.W    $0000
end_val     DS.W    $0000
            END     $400   

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
