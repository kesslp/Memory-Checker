*-----------------------------------------------------------
* Title      : Getting the address range from user
* Written by : Paul Kessler
* Date       : 5/23/2015 
* Description: Gets starting and ending address range from user as a string and 
*            : and converts from ascii to Hex
*-----------------------------------------------------------
mask    EQU         $00FF
stack   EQU         $B000

        ORG         $400
        CLR.B       D0                          * clears D0 cause we need it
        LEA         start_addr_msg, A1          * loads start address message
        MOVE.B      #14, D0                     * Displays message
        TRAP        #15
        MOVE.B      #2, D0                      * takes user input as a string
        TRAP        #15
        MOVE.L      (A1),ascii_val_start        * Moves string to DC
        
start   LEA         stack,SP                    * initialize stack pointer
        CLR.W       D7                          * We need D7 to be 0
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
        MOVE.W      D7,st_val
        MOVEA.W     st_val, A6
            
        LEA         end_addr_msg, A1
        MOVE.B      #14, D0
        TRAP        #15
        MOVEA.L     A4,A1
        MOVE.B      #2, D0
        TRAP        #15
        MOVE.L      (A1),ascii_val_end
        
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
        MOVE.W      D7,end_val
        
        CLR.L       D0
        CLR.L       D1
        MOVE.W      A6, st_val
        MOVE.W      st_val,D0
        MOVE.W      end_val,D1
        MOVEA.W     st_val,A0
        MOVEA.W     end_val,A1
        MOVE.L      (A0),D3
        MOVE.L      (A1),D4
        SIMHALT

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
        
start_addr_msg  DC.B    'Enter a starting address to disassemble: $', 0
end_addr_msg    DC.B    'Enter a ending address to stop disassembling: $', 0
ascii_val_start DC.W    $0000
ascii_val_end   DC.W    $0000
st_val          DC.W    $0000
end_val         DC.W    $0000
            END     $400   




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
