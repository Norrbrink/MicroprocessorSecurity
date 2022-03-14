#include <xc.inc>
global EEPROM_Write, EEPROM_Read, DATA_EE_ADDRH, DATA_EE_ADDR, DATA_EE_DATA
    
psect udata_acs
DATA_EE_ADDRH: ds 1
DATA_EE_ADDR: ds 1
DATA_EE_DATA: ds 1
    
psect	eeprom_code,class=CODE
    
EEPROM_Write:
    MOVF   DATA_EE_ADDRH, W, A      ;
    MOVWF   EEADRH, A             ; Upper bits of Data Memory Address to write
    MOVF   DATA_EE_ADDR, W, A       ;
    MOVWF   EEADR, A              ; Lower bits of Data Memory Address to write
    MOVF   DATA_EE_DATA, W, A       ;
    MOVWF   EEDATA, A             ; Data Memory Value to write
    BCF     EECON1, 0x07, 0       ; Point to DATA memory
    BCF     EECON1, 0x06, 0       ; Access EEPROM
    BSF     EECON1, 0x02, 0       ; Enable writes
   
    BCF     INTCON, 0x07,0        ; Disable Interrupts
    MOVLW   0x55               ;
    MOVWF   EECON2, A             ; Write 55h
    MOVLW   0xAA               ;
    MOVWF   EECON2, A             ; Write 0AAh
    BSF     EECON1, 1        ; Set WR bit to begin write
    BTFSC   EECON1, 0x01, 0         ; Wait for write to complete GOTO $-2
    BSF     INTCON, 0x07, 0        ; Enable Interrupts
    
			       ; User code execution
    BCF     EECON1, 0x02, 0       ; Disable writes on write complete (EEIF set)
    return
    
EEPROM_Read:
    MOVLW   DATA_EE_ADDRH      ;
    MOVWF   EEADRH             ; Upper bits of Data Memory Address to read
    MOVLW   DATA_EE_ADDR       ;
    MOVWF   EEADR              ; Lower bits of Data Memory Address to read
    BCF     EECON1, 0x07      ; Point to DATA memory
    BCF     EECON1, 0x06       ; Access EEPROM
    BSF     EECON1, 0x00         ; EEPROM Read
    NOP
    MOVF    EEDATA, W          ; W = EEDATA


