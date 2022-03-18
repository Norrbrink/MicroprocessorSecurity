#include <xc.inc>
    
global  KPD_READ, write_var, depressed, pass_set, Decode_r, previous_pressed


psect	udata_acs   ; reserve data space in access ram
KPD_counter: ds    1	    ; reserve 1 byte for variable UART_counter
KPD_vert: ds	1 
KPD_hor: ds	1
orgate: ds 1
Decode_c: ds	1
Decode_r: ds	1
delay_count_1: ds 1
write_var: ds 1
depressed: ds 1
pass_set: ds 1
previous_pressed: ds 1
    
psect	data 
c1:
	db	'1','4','7','*',0x0a
					; message, plus carriage return
	myTable_1   EQU	5	; length of data
c2:
	db	'2','5','8','0',0x0a
					; message, plus carriage return
	myTable_2   EQU	5	; length of data	
c3:
	db	'3','6','9','#',0x0a
					; message, plus carriage return
	myTable_3   EQU	5	; length of data
c4:
	db	'A','B','C','D',0x0a
					; message, plus carriage return
	myTable_4   EQU	5	; length of data
   align	2 
    
psect	kpd_code,class=CODE
KPD_READ_03:
    banksel PADCFG1
    bsf	    REPU
    banksel 0
    clrf    LATE, A
    movlw   0x0F
    movwf   TRISE, A
    movlw 0xFF
    movwf delay_count_1, A
    call delay
    movff PORTE, KPD_vert, A
    return
KPD_READ_47:
    movlw 0xF0
    movwf TRISE, A
    movlw 0xFF
    movwf delay_count_1, A
    call delay
    movff PORTE, KPD_hor
    return
KPD_READ:
    call KPD_READ_03
    call KPD_READ_47
    call KPD_Decode
    lfsr 2, Decode_r
    movlw 0x2A
    cpfseq Decode_r, A
    return
    movlw 0x01
    movwf pass_set, A
    ;movf KPD_vert, W
;    iorwf KPD_hor, W, A
;    movwf PORTF, A
    
KPD_Decode:
    movf KPD_vert, W, A
    iorwf KPD_hor, W, A
    movwf orgate, A
    movlw 0x01
    movwf write_var, A
    movlw 0xFF
    cpfseq orgate, A
    bra KPD_not0
    movlw 0x00
    movwf write_var, A 
    movwf depressed, A
    movlw 0xFF
    movwf Decode_r, A
    return
KPD_not0:
    movlw 0x0E
    cpfseq KPD_vert, A
    bra KPD_notc1
    movlw 0x01
    movwf Decode_c, A
    movlw	low highword(c1)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(c1)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(c1)	; address of data in PM
    movwf	TBLPTRL, A
    bra KPD_decode_r
KPD_notc1:
    movlw 0x0D
    cpfseq KPD_vert, A
    bra KPD_notc2
    movlw 0x02
    movwf Decode_c, A
    movlw	low highword(c2)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(c2)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(c2)	; address of data in PM
    movwf	TBLPTRL, A
    bra KPD_decode_r
KPD_notc2:
    movlw 0x0B
    cpfseq KPD_vert, A
    bra KPD_notc3
    movlw 0x03
    movwf Decode_c, A
    movlw	low highword(c3)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(c3)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(c3)	; address of data in PM
    movwf	TBLPTRL, A
    bra KPD_decode_r
KPD_notc3:
    movlw 0x07
    cpfseq KPD_vert, A 
    movlw 0x04
    movlw	low highword(c4)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(c4)	; address of data in PM
    movwf	TBLPTRH, A		; load high byte to TBLPTRH
    movlw	low(c4)	; address of data in PM
    movwf	TBLPTRL, A
    movwf Decode_c, A
KPD_decode_r:
    movlw 0xE0
    tblrd*+ 
    cpfseq KPD_hor, A
    bra KPD_notr1
    movf TABLAT, W,  A 
    movwf Decode_r, A
    return
KPD_notr1:
    movlw 0xD0
    tblrd*+
    cpfseq KPD_hor, A
    bra KPD_notr2
    movf TABLAT, W, A 
    movwf Decode_r, A
    return
KPD_notr2:
    movlw 0xB0
    tblrd*+
    cpfseq KPD_hor, A
    bra KPD_notr3
    movf TABLAT, W, A 
    movwf Decode_r, A
    return
KPD_notr3:
    movlw 0x70
    tblrd* 
    movf TABLAT, W, A 
    movwf Decode_r, A
    return
    ; movlw
delay:	decfsz	delay_count_1, A	; decrement until zero
	bra	delay
	return
