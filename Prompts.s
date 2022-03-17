#include <xc.inc>

global SP, EP, AO, SO, S, Welcome
    
extrn LCD_Write_Message2 

psect	udata_acs   ; reserve data space in access ram
prompt_counter:    ds 1    ; reserve one byte for a counter variable
prompt_counter_1:    ds 1    ; reserve one byte for a counter variable   
    
psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
myArray2:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
SetPassword:
	db	'S','e','t',' ','P','a','s','s','w','o','r','d',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
        align	2
	
EnterPassword:
	db	'E','n','t','e','r',' ','P','a','s','s','w','o','r','d',0x0a
					; message, plus carriage return
	myTable_2   EQU	15	; length of data
        align	2
AlarmOption:
	db	'S','e','t',' ','A','l','a','r','m','-','#',0x0a
					; message, plus carriage return
	myTable_3   EQU	12	; length of data
        align	2

SetOption:
	db	'S','e','t',' ','P','a','s','s','w','o','r','d','-','*',0x0a
					; message, plus carriage return
	myTable_4   EQU	15	; length of data
        align	2
Set1:
	db	'P','r','e','s','s',' ','*',' ','t','o',' ','s','e','t',0x0a
					; message, plus carriage return
	myTable_5   EQU	15	; length of data   
	align	2
	
psect prompt_code, class=CODE	
SP:	
	lfsr	0, myArray2	; Load FSR0 with address in RAM	
	movlw	low highword(SetPassword)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(SetPassword)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(SetPassword)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	addlw	0xFF
	movwf 	prompt_counter, A		; our counter register
	movwf	prompt_counter_1, A
	bra	loop_1
	
EP:	
	lfsr	0, myArray2	; Load FSR0 with address in RAM	
	movlw	low highword(EnterPassword)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(EnterPassword)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(EnterPassword)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_2	; bytes to read
	addlw	0xFF
	movwf 	prompt_counter, A		; our counter register
	movwf	prompt_counter_1, A
	bra	loop_1
	
AO:	
	lfsr	0, myArray2	; Load FSR0 with address in RAM	
	movlw	low highword(AlarmOption)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(AlarmOption)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(AlarmOption)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_3	; bytes to read
	addlw	0xFF
	movwf 	prompt_counter, A		; our counter register
	movwf	prompt_counter_1, A
	bra	loop_1
	
SO:	
	lfsr	0, myArray2	; Load FSR0 with address in RAM	
	movlw	low highword(SetOption)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(SetOption)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(SetOption)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_4	; bytes to read
	addlw	0xFF
	movwf 	prompt_counter, A		; our counter register
	movwf	prompt_counter_1, A
	bra	loop_1
	
S:	
	lfsr	0, myArray2	; Load FSR0 with address in RAM	
	movlw	low highword(Set1)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(Set1)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(Set1)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_5	; bytes to read
	addlw	0xFF
	movwf 	prompt_counter, A		; our counter register
	movwf	prompt_counter_1, A
	bra	loop_1

loop_1: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	prompt_counter, A		; count down to zero
	bra	loop_1		; keep going until finished

	movf	prompt_counter_1, W, A	; output message to LCD
				; don't send the final carriage return to LCD
	lfsr	2, myArray2
	call	LCD_Write_Message2
	return

Welcome:
    call SO
    return