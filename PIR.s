#include <xc.inc>
    
global  PIR_Setup

psect PIR_code,class=CODE
PIR_Setup:
    movlw 0x03
    movwf TRISG, A
    movlw 0x00
    movwf PORTG, A
    return

