*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR          EQU $0D
LF          EQU $0A

mask        EQU $0000000F
ascii_mask  EQU $00FF
counter     EQU 0
stack       EQU $B000
page_count  EQU 30

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
                BRA         getOpCode                   * Jump to getOpCode sub routine

                

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


* Put program  here
getOpCode                        *Gets opcode
    *LEA     code,A0             *Loads "code" which is the op code
    
    CLR.L   D7
    CLR.L   D6
    CLR.L   D3
    CLR.L   D1
    CLR.L   D0
    
    *MOVEA.L  A0,A1             *move this instruction after address output
    MOVE.W  (A5)+,D4            *move data at starting addr to D4
    MOVE.W  A5,D1               *move starting addr into D1
    MOVE.B  #15,D0              *convert number into hex and output to console
    MOVE.B  #16,D2
    TRAP    #15
    
    LEA     outputColon,A1      *output the colon and a space to the console
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVEA.L A0,A1               *used to clear A0
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
    MOVE.W  D4,D3
    ROL.W   #8,D3
    CMP.B   #$44,D3
    BEQ     negMethod
    CLR.L   D3
    
    LEA     outputLEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addaDestEA
    
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
    
    ADD.B   #1,D7
    
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
    
    CMP.B   #2,D6
    BEQ     addaOrder           *go do ADDA stuff
    
    JSR     sourceEA            *outputs what the source is
    
    LEA     outputComma,A1      *Commas~~~
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addDestinationEA       *outputs what the destination is
    
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
    
    CMP.B   #8,D3
    BGE     dataOpCode
    
    LEA     outputPound,A1      *output #
    MOVE.B  #14,D0
    TRAP    #15
    
    CLR.L   D1
    MOVE.B  D3,D1               *output 1-7
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *return to subQmethod
    
display8ForSubQ

    LEA     outputPound,A1      *output #
    MOVE.B  #14,D0
    TRAP    #15
    CLR.L   D1
    MOVE.B  #8,D1               *output 8
    MOVE.B  #3,D0
    TRAP    #15
    
    RTS                         *return to subQMethod
    
divsWOpCode
    CMP.B   #8,D5
    BEQ     divsWCheck          *bits 8,7,6 need to make 7 to be DIVSW
    BRA     mulsWOpCode
    
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
    
mulsWOpCode
    CMP.B   #12,D5
    BNE     negOpCode    

mulsWMethod
    LEA     outputMULSW,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addDestinationEA
    
    BRA     DONE
    
negOpCode
    MOVE.W  D4,D3
    ROL.W   #8,D3
    CMP.B   #$44,D3
    BNE     braOpCode
    
negMethod
    LEA     outputNEG,A1        *output NEG to the console
    MOVE.B  #14,D0
    TRAP    #15
    
    CLR.L   D3
    MOVE.W  D4,D3               *move original word from D4
    MOVE.B  #10,D1              *hacks
    ROL.W   D1,D3               *ROL by 10
    AND.L   #00000003,D3        *Mask 
    JSR     byteOpMode          *check if B,W,L
        
    JSR     sourceEA
    
    BRA     DONE

braOpCode
    MOVE.W  D4,D3               *move the opcode word into D3
    ROL.W   #8,D3               *isolate the last byte
    CMP.B   #$60,D3
    BNE     dataOpCode
    
braMethod
    LEA     outputBRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D4,D3
    AND.W   #$00FF,D3
    CMP.B   #$00,D3
    BEQ     16BitDisplacement
    CMP.B   #$FF,D3
    BEQ     32BitDisplacement
    ROL.B   #4,D3
    CMP.B   #$F,D3
    JSR     printNeg
    CLR.L   D1
    AND.B   #$0F,D3
    MOVE.B  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    BRA     DONE
    
16BitDisplacement
32BitDisplacement
printNeg
    LEA     outputNegSign,A1
    MOVE.B  #14,D0
    TRAP    #15
    ROL.B   #4,D3
    RTS
       
    
dataOpCode
    CLR.L   D3
    LEA     outputData,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     DONE


altOrder                            *outputs the Dn as the source for ADD
    JSR     addDestinationEA
    
    LEA     outputComma,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     sourceEA
    BRA     DONE
    
addaOrder                           *ADDA method
    JSR     sourceEA                *output source first
    
    LEA     outputComma,A1          *Comma
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     addaDestEA              *Have to set destination mode in addaDestEA
    BRA     DONE


dotOpMode                           *Checks if it's a Byte,Word, or Long for ADD and SUB
    MOVE.W  D4,D3                   *Gets the original code from D4                 
    MOVE.B  #10,D2                  *yay hacks
    
    ROL.W   D2,D3                   *Rotates the original left by 10 bits
    AND.L   #$00000007,D3           *mask it up
    
    CMP.B   #3,D3                   
    BGE     altOpMode               *if value is > 3, Dn is the source
    
    BRA     byteOpMode    

altOpMode                           *But wait, there's more!
    CMP.B   #3,D3                   *If it's 3, it's an ADDA.W
    BEQ     addaWOpMode
    
    CMP.B   #7,D3                   *If it's a 7, it's an ADDA.L
    BEQ     addaLOpMode             *Otherwise, it's just ADD with Dn in source
    
    *LEA     outputDot,A1            *Since ADD needs a dot to be ADD.
    *MOVE.B  #14,D0
    *TRAP    #15
    
    MOVE.B  #1,D6                   *D6 is 1 if Dn is the source
    AND.B   #$3,D3                  *Mask it so it can continue with the output
    BRA     byteOpMode              *without the meddling 2^2 bit

addaWOpMode                         *It's an ADDA.W
    MOVE.W  #2,D6
    
    LEA     outputADDA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputDot,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputWord,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    RTS
    
addaLOpMode                         *It's an ADDA.L
    MOVE.W  #2,D6
    
    ADD.B   #1,D7
    
    LEA     outputADDA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputDot,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputLong,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    RTS
    
    
byteOpMode                          *It's a byte?
    CMP.B   #0,D3
    BNE     wordOpMode
    
    LEA     outputDot,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputByte,A1           *Output ".B" !
    MOVE.B  #14,D0
    TRAP    #15
    RTS                             *Time to return back in time
    
wordOpMode                          *It's a word?
    CMP.B   #1,D3
    BNE     longOpMode
    
    LEA     outputDot,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     outputWord,A1           *Output ".W" onto console
    MOVE.B  #14,D0
    TRAP    #15
    RTS                             *Time warp~
    
longOpMode                          *It better be a long then
    LEA     outputDot,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA     outputLong,A1           *outputs ".L" onto console
    MOVE.B  #14,D0
    TRAP    #15
    
    ADD.B   #1,D7
   
    RTS                             *whoosh~
 
    
sourceEA                            *output the Source EA
    MOVE.W  D4,D3                   *Put the original opcode into D3
    MOVE.W  D3,D2                   *Copy that into D2
    
    ROR.W   #3,D2                   *Whoo~ Rotating~
    AND.L   #$00000007,D2           *D2 has Mode
    

    AND.L   #$00000007,D3           *D3 has Register

 
DnMode                          *Is the Mode a Data Register?
    CLR.L   D1
    
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
    BNE     immediateData
    
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
    
immediateData                   *Mode is an #<data>
    CMP.B   #7,D2               *Mode for #<data> is 111
    BNE     DONE                
    
    CMP.B   #4,D3               *Register for #<data> is 100
    BNE     DONE
                               
    LEA     outputPound,A1      *Outputs "#"
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     code,A2             *Gets the address, shifts it by a word
    ADD.L   #2,A2               *to get the immediate value    
    
    CMP.B   #1,D7
    BEQ     immeDataLong
    
    MOVE.W  (A2),D3
    
    BRA     immediateDatapt2

immeDataLong
    MOVE.L  (A2),D3    
    
    
immediateDatapt2               *Outputs register value
    MOVE.L  D3,D1
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
    
addaDestEA                      *Sets up the dest mode to be proper
    MOVE.W  D4,D3               *Get the original code again
    MOVE.W  D3,D2
    
    ROL.W   #7,D3               
    AND.L   #$00000007,D3       *D3 has register
    
    MOVE.W  #10,D1
    ROL.W   D1,D2               *Have to AND it by 1, since the mode for ADDA
    AND.L   #$00000001,D2       *is always an Address
    
    BRA     DnMode
        
DONE
    CMP.W   A5,A6
    BLE     END   
    LEA     outputNextLine,A1
    MOVE.B  #14,D0
    TRAP    #15 
    JMP     getOpCode
    
END
    SIMHALT             ; halt simulator

* Put variables and constants here

code        DC.W    $43D2


addCode     DC.W    $D640

moveCode1   DC.W    $303C
moveCode2   DC.W    $0011

outputADD   DC.B    'ADD',0
outputADDA  DC.B    'A',0
outputSUB   DC.B    'SUB',0
outputSUBQ  DC.B    'SUBQ',0
outputMOVE  DC.B    'MOVE.',0
outputMOVEA DC.B    'MOVEA.',0
outputMULSW DC.B    'MULS.W',0
outputDIVSW DC.B    'DIVS.W ',0
outputNOP   DC.B    'NOP ',0
outputRTS   DC.B    'RTS ',0
outputLEA   DC.B    'LEA ',0
outputData  DC.B    'DATA ',0
outputNEG   DC.B    'NEG',0
outputBRA   DC.B    'BRA ',0

outputByte  DC.B    'B ',0
outputWord  DC.B    'W ',0
outputLong  DC.B    'L ',0

outputdeRefAn1   DC.B    '(A',0
outputdeRefAn2   DC.B    ')',0

outputAn    DC.B    'A',0
outputDn    DC.B    'D',0
outputPound DC.B    '#',0
outputCurrentAddr   DC.W    $0000

outputComma     DC.B    ',',0
outputDot       DC.B    '.',0
outputNextLine  DC.B    ' ',CR,LF,0
outputSpace     DC.B    ' ',0
outputColon     DC.B    ': ',0
outputNegSign   DC.B    '-',0
    END    $400        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
