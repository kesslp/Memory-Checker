*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR              EQU $0D
LF              EQU $0A
add_mask        EQU $0000000F
ascii_mask      EQU $00FF
stack           EQU $B000
                
*---- User input address range -----

                ORG         $400                        * start of the program
                LEA         stack,SP                    * initialize the stack
                CLR.B       D0                          * clear D0
                LEA         start_addr_msg, A1          * ask for starting address
                MOVE.B      #14, D0
                TRAP        #15                         
                MOVE.B      #2, D0                      * take in user input as string
                TRAP        #15
                MOVE.L      (A1),ascii_val_start        * store ascii address in DC
                MOVEM.W     A0-A6/D0-D7,-(SP)           * push registers on the stack
                JSR         get_addr                    * strip ascii characters to hex
                MOVEM.W     (SP)+, A0-A6/D0-D7          * restore registers
                MOVE.W      addr_val_temp, st_val       * store address value into st_val
                MOVE.W      st_val, D5                  * check if address is correct
                CLR.L       ascii_val_start             * clr DC for end address input
                
                LEA         end_addr_msg, A1            * ask for ending address
                MOVE.B      #14, D0
                TRAP        #15
                MOVEA.L     A4,A1                       * reset address at A1 to get user input
                MOVE.B      #2, D0                      * take address as a string
                TRAP        #15
                MOVE.L      (A1),ascii_val_start        * save in DC
                MOVEM.W     A0-A6/D0-D7,-(SP)           * push registers on the stack
                JSR         get_addr                    * strip ascii address into hex
                MOVEM.W     (SP)+, A0-A6/D0-D7          * restore the registers
                MOVE.W      addr_val_temp, end_val      * store address in end_val
                MOVE.W      end_val, D6                 * check if result is correct
                MOVEA.W     st_val,A5                   * store start val in A5
                MOVEA.W     end_val,A6                  * store end val in A6
                BRA         ADD_checker                 * Jump to add sub routine

                

get_addr                            
                CLR.W       D7                          * we need D7 to be 0
                LEA         ascii_val_start, A1         * load ascii value to be stripped
                MOVE.B      (A1)+,D0                    * store first byte in D0
                ANDI.W      #ascii_mask,D0              * mask the first byte
                JSR         strip_ascii                 * strip ascii char into hex
                ASL.W       #8,D0                       * shift left 8
                ASL.W       #4,D0                       * shift left 4
                OR.W        D0,D7
                MOVE.B      (A1)+,D0                    * move next byte into D0
                ANDI.W      #ascii_mask,D0              * mask the second byte
                JSR         strip_ascii                 * strip ascii to hex
                ASL.W       #8,D0                       * shift left 8
                OR.W        D0,D7
                MOVE.B      (A1)+,D0                    * move next byte into D0
                ANDI.W      #ascii_mask,D0              * mask byte in D0
                JSR         strip_ascii                 * strip ascii into hex
                ASL.W       #4,D0                       * shift left 4
                OR.W        D0,D7
                MOVE.B      (A1)+,D0                    * move final byte into D0
                ANDI.W      #ascii_mask,D0              * mask final byte
                JSR         strip_ascii                 * strip it to hex
                OR.W        D0,D7
                MOVE.W      D7,addr_val_temp            * store hex address in temp value
                RTS                                     * return
     
                
strip_ascii     CMP.B       #$39,D0                     *Is it in range of 0-9?
                BLE         sub30                       *It's a number
                CMP.B       #$46,D0                     *Is it A...F?
                BLE         sub37                       *It's A...F
                SUB.B       #$57,D0                     *It's a...f
                BRA         ret_sa                      *Go back
sub37           SUB.B       #$37,D0                     *Strip 37
                BRA         ret_sa                      *Go back
sub30           SUB.B       #$30,D0                     *Strip 30
ret_sa          RTS                                     *Go back


*---- Data ----

start_addr_msg  DC.B    'Enter a starting address to disassemble: $', 0
end_addr_msg    DC.B    'Enter a ending address to stop disassembling: $', 0
ascii_val_start DC.W    $0000
ascii_val_end   DC.W    $0000
addr_val_temp   DC.W    $0000
st_val          DC.W    $0000
end_val         DC.W    $0000

*--- Data end ----

*-----Disassemble ADD Opcodes start------------

ADD_Checker
*    LEA     addCode,A0
    
    CLR.L   D7
    CLR.L   D1
    CLR.L   D0
    
    MOVEA.L A0,A1
    
    MOVE.W  (A5)+,D4
    MOVE.W  D4,addCode
    MOVE.W  D4,D2
    
    ROL.W   #4,D2
    
    AND.L   #add_mask,D2
    
    MOVE.B  D2,D5
    
moveOpCode
    CMP.B   #1,D5
    BNE     addOpCode

moveMethod
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
    
    JSR     destinationEA       *outputs what the destination is
    
    BRA     DONE
    
altOrder
    JSR     destinationEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    BRA     DONE

dotOpMode
    LEA     addCode,A2
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
    LEA     addCode,A2
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
   
destinationEA
    LEA     addCode,A2
    MOVE.W  (A2),D3
    
    ROL.W   #7,D3
    AND.L   #$00000007,D3
    
DnRegister
    LEA     outputDn,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS
    
DONE
    CMP.L   A5,A6
    BGT     ADD_Checker
    
    SIMHALT             ; halt simulator
    
    
addCode             DC.W    $0000
outputADD           DC.B    'ADD.',0
outputByte          DC.B    'B ',0
outputWord          DC.B    'W ',0
outputLong          DC.B    'L ',0
outputdeRefAn1      DC.B    '(A',0
outputdeRefAn2      DC.B    ')',0
outputAn            DC.B    'A',0
outputDn            DC.B    'D',0
outputPound         DC.B    '#',0
outputComma         DC.B    ',',0



                END         $400   


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
