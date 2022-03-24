#include <xc.inc>

global  ADC_Setup, ADC_Setup1, ADC_Setup2, ADC_Read     
    
psect	adc_code, class=CODE
    
ADC_Setup:
;bsf TRISA, PORTA_RA0_POSN, A ; pin RA0==AN0 input
movlw 0x01
movwf TRISA, A
banksel ANCON0
bsf ANSEL0 ; set AN0 to analog
banksel 0
;movlw 0x01 ; select AN0 for measurement
movlw 00000001B ; select AN0, AN1, AN2 for measurement
movwf ADCON0, A ; and turn ADC on
movlw 0x30 ; Select 4.096V positive reference
movwf ADCON1, A ; 0V for -ve reference and -ve input
movlw 0xF6 ; Right justified output
movwf ADCON2, A ; Fosc/64 clock and acquisition times
return



ADC_Setup1:
;bsf TRISA, PORTA_RA0_POSN, A ; pin RA0==AN0 input
movlw 0x02 ;pin RA1==AN1
movwf TRISA, A
banksel ANCON0
bsf ANSEL1
banksel 0
movlw 00000101B ; select AN1 for measurement
movwf ADCON0, A ; and turn ADC on
movlw 0x30 ; Select 4.096V positive reference
movwf ADCON1, A ; 0V for -ve reference and -ve input
movlw 0xF6 ; Right justified output
movwf ADCON2, A ; Fosc/64 clock and acquisition times
return

ADC_Setup2:
;bsf TRISA, PORTA_RA0_POSN, A ; pin RA0==AN0 input
movlw 0x04 ;pin RA2==AN2
movwf TRISA, A
banksel ANCON0
bsf ANSEL2 ; set AN0 to analog
banksel 0
movlw 00001001B ; select AN2 for measurement
movwf ADCON0, A ; and turn ADC on
movlw 0x20 ; Select 4.096V positive reference
movwf ADCON1, A ; 0V for -ve reference and -ve input
movlw 0xF6 ; Right justified output
movwf ADCON2, A ; Fosc/64 clock and acquisition times
return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end