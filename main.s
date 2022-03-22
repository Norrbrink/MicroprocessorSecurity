#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Message2, LCD_Clear, LCD_Shift, LCD_delay_ms,  LCD_Write_Hex
extrn	KPD_READ, write_var, depressed, pass_set, Decode_r, previous_pressed
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn	Multiply_16bit, Multiply_824bit 
extrn	PIR_Setup    
extrn	EEPROM_Write, EEPROM_Read, DATA_EE_ADDRH, DATA_EE_ADDR, DATA_EE_DATA, Password_Counter, Password_Setup
extrn	SP, EP, AO, SO, S, Welcome, WM, SecurityON, WP
extrn	DAC_Setup, DAC_Int_Hi
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count: ds 1    ; reserve one byte for counter in the delay routine
UART_counter: ds    1
counter2: ds 1
pass_0_counter: ds 1
pass_1_counter: ds 1
PIR_active: ds 1
unlocked: ds 1
unlock_timer: ds 1
unlock_timer1: ds 1
unlock_timer2: ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
	;banksel 0
 	goto	setup

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	call	PIR_Setup
	movlw	0x00
	movwf	TRISF, A
	
	goto	start
	
	; ******* Main programme ****************************************
start:
	lfsr	0, myArray	; Load FSR0 with address in RAM		
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
;	call LCD_Clear
;	movlw 40
;	call LCD_delay_ms
	;loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;	; move data from TABLAT to (FSR0), inc FSR0	
;	decfsz	counter, A		; count down to zero
;	movwf   UART_counter, A
;UART_Loop_message:
;	movf	TABLAT, W, A
;	call    UART_Transmit_Byte
;	decfsz  UART_counter, A
;	bra	loop		; keep going until finished
;		
;	movlw	myTable_l	; output message to UART
;	lfsr	2, myArray
;	call	UART_Transmit_Message
;	
;	call	LCD_Shift
;	movlw	myTable_l	; output message to LCD
;	addlw	0xff		; don't send the final carriage return to LCD
;	lfsr	2, myArray
	;call	LCD_Write_Message
	
;	movlw 0x00
;	cpfseq PORTD
;	call	LCD_Clear
;PASSWORD:
;    movlw 0x00
;    movwf DATA_EE_ADDRH, A
;    movwf DATA_EE_ADDR, A
;    movlw 0x01
;    movwf DATA_EE_DATA, A
;    call EEPROM_Write
	
	call LCD_Clear
	movlw 40
	call LCD_delay_ms
	call Password_Setup
	call EEPROM_Read
	movwf 0x070, A
	movlw 0xFF
	;cpfseq 0x070, A
	;bra Enter_Password
	bra Set_Password

Set_Password: ; Functions to set and save a Password, initialises the routine
    call LCD_Clear
    movlw 40
    call LCD_delay_ms
    call SP
    call LCD_Shift
    lfsr 1, 0x0B0
    movlw 0x00
    movwf pass_1_counter, A
    movlw 0xFF
    movwf previous_pressed, A
Pass_set:  ;Reads and Decodes the Keypad Inputs  
    call KPD_READ
    movlw 40
    call LCD_delay_ms
    movf previous_pressed, W, A
    cpfseq Decode_r, A
    bra Pass_Write
    bra Pass_set
Pass_Write: ;Saves the password to memory
    movlw 0x00
    cpfseq write_var, A
    call KPD_Check
    movlw 0x00
    cpfseq write_var, A
    movff Decode_r, POSTINC1, A
    movlw 0x00
    cpfseq write_var, A
    incf pass_1_counter, A
    movff Decode_r, previous_pressed, A
    movlw 0x2A
    cpfseq Decode_r, A
    bra Pass_set
    bra Enter_Password
    ;bra Success_message


Enter_Password: ; Functions to Enter password and compare it to the saved password
    call LCD_Clear
    movlw 40
    call LCD_delay_ms
    call EP
    call LCD_Shift
    lfsr 0, 0x0A0
    movlw 0x00
    movwf pass_0_counter, A
    ;movlw 0xFF
    ;movwf previous_pressed, A
    ;movwf Decode_r
Pass_set2:    ;Reads and Decodes the Keypad Inputs
    call KPD_READ
    movlw 40
    call LCD_delay_ms
    decf unlock_timer
    movlw 0xFF
    movwf unlock_timer2, A
    movlw 0x00
    cpfseq unlocked, A
    call unlock_delay 
    movf previous_pressed, W, A
    cpfseq Decode_r, A
    bra Pass_Write2
    bra Pass_set2
Pass_Write2: ;Saves the password in Data memory to be compared with the Correct Password
    movlw 0x00
    cpfseq write_var, A
    call KPD_Check
    movlw 0x00
    cpfseq write_var, A
    movff Decode_r, POSTINC0, A
    movlw 0x00
    cpfseq write_var, A
    incf pass_0_counter, A
    movff Decode_r, previous_pressed, A
    movlw 0x2A
    cpfseq Decode_r, A
    bra Pass_set2
    bra Pass_Check
unlock_delay:
    decf unlock_timer2
    movlw 0x00
    cpfseq unlock_timer2, A
    bra unlock_delay
    cpfseq unlock_timer, A
    return
unlock_delay2:
    decf unlock_timer1, A
    movlw 0xFF 
    movwf unlock_timer,A
    movlw 0x00
    cpfseq unlock_timer1, A
    return
    call Alarm
    
Success_message: ;Welcome Message and prompt to further actions
bcf GIE
call LCD_Clear
movlw 40
call LCD_delay_ms
call Welcome
movlw 0x05
movwf counter2, A
call double_delay
call SetAP_Prompt
call KPD_READ
goto $
;cpfseq 0
SetAP_Prompt: ;Set Alarm or New Password Prompt
call LCD_Clear
movlw 40
call LCD_delay_ms
call AO ;Set alarm
call LCD_Shift ;Shifts onto new line
call SO ;Set new password
bra SetAP1
goto $



SetAP1: ;Checks for Alarm Input
call KPD_READ
movlw 40
call LCD_delay_ms
;call LCD_Clear
movlw 40
call LCD_delay_ms
movlw 0x00
cpfseq write_var, A
call KPD_Check
movlw 0x23
cpfseq Decode_r, A
bra SetAP2
bra AlarmSet

SetAP2:
movlw 0x2A
cpfseq Decode_r, A
bra SetAP1
bra Set_Password

AlarmSet:
call LCD_Clear
movlw 40
call LCD_delay_ms
call SecurityON
call SecuritySystem_Setup
goto $


double_delay:
movlw 0xFF
call LCD_delay_ms
decfsz counter2, A
bra double_delay
return
    
    
KPD_func: ;Function to Read and Decode the inputs of the keypad
	call KPD_READ
	movlw 0xF0
	movlw 40
	call LCD_delay_ms
	;call LCD_Clear
	movlw 40
	call LCD_delay_ms
	movlw 0x00
	cpfseq write_var, A
	call KPD_Check
	bra KPD_func
	goto	$		; goto current line in cod
KPD_Check:
    movlw 0x00
    cpfseq depressed, A
    return
    call LCD_Write_Message
    movlw 0x01 
    movwf depressed, A
    incf Password_Counter, A
    movlw 0x2A
    return

Pass_Check:
    lfsr 0, 0x0A0
    lfsr 1, 0x0B0
    movf pass_1_counter, W, A
    cpfseq pass_0_counter, A
    bra wrong_password
Length_Check:    
    movlw 0x00
    cpfseq pass_0_counter, A
    bra Pass_congruency
    bra Success_message
Pass_congruency:    
    movf POSTINC0, W, A
    cpfseq POSTINC1, A
    bra wrong_password
    decf pass_0_counter, A 
    bra Length_Check
 wrong_password:
    call LCD_Clear
    movlw 40
    call LCD_delay_ms
    call WP
    movlw 0x05
    movwf counter2, A
    call double_delay
    bra Enter_Password
	; ******* Main programme ****************************************

;loop_1: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
;	decfsz	counter, A		; count down to zero
;	bra	loop_1		; keep going until finished
;		
;	movlw	myTable_l	; output message to UART
;	lfsr	2, myArray
;	call	UART_Transmit_Message
;
;	movlw	myTable_l	; output message to LCD
;				; don't send the final carriage return to LCD
;	lfsr	2, myArray
;	call	LCD_Write_Message
;	
measure_loop:
	call	ADC_Read
	movf	ADRESH, W, A
	call	LCD_Write_Hex
	movf	ADRESL, W, A
	call	LCD_Write_Hex
	call	LCD_Clear
	movlw 40
	call LCD_delay_ms
	call Multiply_16bit
	call LCD_Shift
	call Multiply_824bit
	call Multiply_824bit
	call Multiply_824bit
	movlw 0x56
	movwf POSTINC0, A ; Adding units to Voltage
	lfsr	2, 0x0D0
	movlw 0x06
	call	LCD_Write_Message2
	movlw 40
	call LCD_delay_ms
	return

SecuritySystem_Setup:
    movlw 0xFB
    movwf TRISD, A
    movlw 40
    call LCD_delay_ms
    movlw 0x04
    movwf PORTD, A
    movlw 40
    call LCD_delay_ms
SecuritySystem:
;    movlw 00100100B 
;    cpfseq PORTD ;Check Key Switch
;    call keyAlarm
;    call measure_loop 
;    lfsr 0, 0x0D0
;    movlw 0x30
;    cpfseq INDF0, A ;Check PIR
;    call Alarm
    ;call measure_loop
    ;lfsr 0, 0x0D0
    ;movlw 0x30
    ;cpfseq INDF0, A  ;Check Speaker
    ;call Alarm
;    call Ultrasonic
;    lfsr 0, 0x0D0
;    movlw 0x34
;    cpfseq INDF0, A  ;Check Ultrasonic
;    call Alarm
    movlw 10100100B 
    cpfseq PORTD ;Check Window/Door Switch
    call Alarm
    bra SecuritySystem
Alarm:
    call DAC_Setup
    call Enter_Password
keyAlarm:
    movlw 0x01
    movwf unlocked, A
    movlw 0xFF
    movwf unlock_timer, A
    movlw 0x03
    movwf unlock_timer1, A
    call Enter_Password
    
    
Ultrasonic:
    movlw 0x00
    movwf TRISA, A
    movlw 10
    call LCD_delay_ms
    movlw 0x01
    movwf TRISA
    movlw 10
    call LCD_delay_ms
    call measure_loop
    return
    
end rst
