*-----------------------------------------------------------
* Title      : Memory test program
* Written by : Paul Kessler
* Date       : 
* Description: Tests memory for sexiness
*-----------------------------------------------------------
  
end_test        EQU     $11         *test pattern terminator
test1           EQU      00         *first test pattern
test2           EQU     $FF         *second test pattern
test3           EQU     $55         *third test pattern
test4           EQU     $AA         *fourth test pattern
*st_addr         EQU     $2000       *Starting address of test
*end_addr        EQU     $6000       *ending address of test
stack           EQU     $7000       *stack location
maxcnt          EQU     10          *maximun number of bad address
start           EQU     $400
                
                ORG     start       *start of the program
BEGIN           LEA     stack, SP   *initialize the stack pointer
                CLR.B   D0          *initialize D0
                CLR.B   bad_cnt     *Initialize the bad address counter
                LEA     tests,A2    *A2 points to the test patterns
                LEA     bad_addr,A3 *pointer to bad count storage
               
                LEA     start_addr_msg, A1
                MOVE.B  #14, D0
                TRAP    #15
                MOVE.B  #4, D0
                TRAP    #15
                MOVE.L  D1, st_addr
                CLR.L   D1
                
                LEA     end_addr_msg, A1
                MOVE.B  #14, D0
                TRAP    #15
                MOVE.B  #4, D0
                TRAP    #15
                MOVE.L  D1, end_addr
                CLR.L   D1
                
TEST_LOOP       MOVE.B  (A2)+, D6
                CMPI.B  #end_test, D6
                BEQ     DONE
                LEA     st_addr, A0
                LEA     end_addr, A1
                JSR     DO_TEST
                MOVE.B  bad_cnt, D7
                CMPI.B  #maxcnt,D7
                BLT     TEST_LOOP
DONE            STOP    #$2700

DO_TEST         MOVEM.W  A3/D1/D7,-(SP)
CHECK_LOOP      MOVE.B  (A2),(A0)
                MOVE.B  (A0),D1
                CMP.B   (A2),D1
                BNE     ERROR_BYTE
                BRA     NEXT_TEST
ERROR_BYTE      MOVE.W  A0,(A3)+
                ADDI.B  #01,bad_cnt
                MOVE.B  bad_cnt,D7
                CMPI.B  #maxcnt,D7
                BGE     EXIT
NEXT_TEST       ADDA.W  #01,A0
                CMPA.W  A0,A1
                BGE     CHECK_LOOP
EXIT            MOVEM.W (SP)+,A3/D1/D7
                RTS
                
tests           DC.B    test1,test2,test3,test4,end_test
padding         DC.B    00
bad_cnt         DS.W    1
bad_addr        DS.W    10
st_addr      DC.L    $00000000
end_addr        DC.L    $00000000
Start_addr_msg  DC.B    'Enter a starting address: ',0
End_addr_msg    DC.B    'Enter an ending address: ',0
                END     $400

          
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
