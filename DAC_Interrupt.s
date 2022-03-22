#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi

psect udata_acs
decreasing: ds 1
    
psect	dac_code, class=CODE  
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	movlw 0x00
	movwf PORTH, A
;	cpfseq decreasing, A
	incf	LATJ, F, A	; increment PORTD
;	movlw 0x01
;	cpfseq decreasing, A
	;decf	LATJ, F, A	; increment PORTD
	movlw 0x02
	movwf PORTH, A
	movlw 0x00
	movwf PORTH, A
;	movlw 0x01
;	cpfseq decreasing, A
;	call settoincrease
	bcf	TMR0IF		; clear interrupt flag
	movlw 0x80
	cpfseq LATJ, A
	retfie	f		; fast return from interrupt
	movlw 0x00
	movwf LATJ, A
	;movwf decreasing, A
	retfie f
DAC_Setup:
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A	    ; Clear PORTD outputs
	clrf	TRISH, A
	movlw 0x01
	movwf decreasing, A
	movlw	10001000B	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	clrf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	return
settoincrease:
    movlw 0x00
    cpfseq LATJ
    return
    movlw 0x01
    movwf decreasing
    return
	end

