#include <xc.inc>

global  Multiply_16bit, Multiply_824bit  
extrn	LCD_Write_Hex
    
psect multi_acs   ; reserve data space in access ram
ARG2L: ds    1    
ARG2H: ds    1
RES0: ds    1
RES1: ds    1
RES2: ds    1
RES3: ds    1
RES1_temp: ds    1
RES2_temp: ds    1


    
psect	multi_code, class=CODE
Multiply_16bit:
movlw	0x8A
movwf	ARG2L, A
movlw	0x41
movwf	ARG2H, A    
MOVF    ADRESL, W, A 
MULWF   ARG2L, A          ; ARG1L * ARG2L-> ; PRODH:PRODL 
MOVFF   PRODH, RES1    ; 
MOVFF   PRODL, RES0    ;  
MOVF    ADRESH, W, A 
MULWF   ARG2H, A          ; ARG1H * ARG2H-> ; PRODH:PRODL 
MOVFF   PRODH, RES3    ; 
MOVFF   PRODL, RES2    ; 
MOVF    ADRESL, W, A 
MULWF   ARG2H, A          ; ARG1L * ARG2H-> ; PRODH:PRODL 
MOVF    PRODL, W, A       ; 
ADDWF   RES1, F, A        ; Add cross 
MOVF    PRODH, W, A       ; products 
ADDWFC  RES2, F, A        ; 
CLRF    WREG, A           ; 
ADDWFC  RES3, F, A        ; 
MOVF    ADRESH, W, A       ; 
MULWF   ARG2L, A          ; ARG1H * ARG2L-> ; PRODH:PRODL 
MOVF    PRODL, W, A       ; 
ADDWF   RES1, F, A        ; Add cross 
MOVF    PRODH, W, A       ; products
ADDWFC  RES2, F, A        ; 
CLRF    WREG, A           ; 
ADDWFC  RES3, F, A        ; 
;movf	RES3, W, A
;call	LCD_Write_Hex
;movf	RES2, W, A
;call	LCD_Write_Hex
;movf	RES1, W, A
;call	LCD_Write_Hex    
;movf	RES0, W, A
;call	LCD_Write_Hex
lfsr 0, 0x0A0
movf RES3, W, A    
addlw 0x30
movwf POSTINC0, A
movlw 0x2E
movwf POSTINC0, A 
    
return
    
Multiply_824bit:
movlw	0x0A 
movff	RES1, RES1_temp
movff	RES2, RES2_temp
MULWF   RES0, A        ;    ARG1 * ARG2L-> ; PRODH:PRODL 
MOVFF   PRODH, RES1    ; 
MOVFF   PRODL, RES0    ;   
MULWF   RES2_temp, A   ;    ARG1 * ARG2U-> ; PRODH:PRODL 
MOVFF   PRODH, RES3    ; 
MOVFF   PRODL, RES2    ;  
MULWF   RES1_temp, A   ;    ARG1 * ARG2H-> ; PRODH:PRODL 
MOVF    PRODL, W, A       ; 
ADDWF   RES1, F, A        ; Add cross         ; 
MOVF    PRODH, W, A       ; products 
ADDWFC  RES2, F, A        ; 
CLRF    WREG, A           ; 
ADDWFC  RES3, F, A        ;        
;movf	RES3, W, A
;call	LCD_Write_Hex
;movf	RES2, W, A
;call	LCD_Write_Hex
;movf	RES1, W, A
;call	LCD_Write_Hex    
;movf	RES0, W, A
;call	LCD_Write_Hex
movf RES3, W, A    
addlw 0x30
movwf POSTINC0, A  
return
    
end