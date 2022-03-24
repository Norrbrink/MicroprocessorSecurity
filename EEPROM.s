#include <xc.inc>
global EEPROM_Write, EEPROM_Read, DATA_EE_ADDRH, DATA_EE_ADDR, DATA_EE_DATA, Password_Counter, Password_Counter2, Password_Setup, EEPROM_Refresh
    
psect udata_acs
DATA_EE_ADDRH: ds 1
DATA_EE_ADDR: ds 1
DATA_EE_DATA: ds 1
Password_Counter: ds 1
Password_Counter2: ds 1   
psect	eeprom_code,class=CODE
Password_Setup:
    movlw 0x00
    movwf Password_Counter
    ;lfsr 0, 0x0C0
    return
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
    MOVF   DATA_EE_ADDRH      ;
    MOVWF   EEADRH             ; Upper bits of Data Memory Address to read
    MOVF   DATA_EE_ADDR       ;
    MOVWF   EEADR              ; Lower bits of Data Memory Address to read
    BCF     EECON1, 0x07      ; Point to DATA memory
    BCF     EECON1, 0x06       ; Access EEPROM
    BSF     EECON1, 0x00         ; EEPROM Read
    NOP
    MOVF    EEDATA, W          ; W = EEDATA
    return
    
EEPROM_Refresh:
    CLRF    EEADR              ; Start at address 0
    CLRF    EEADRH             ;
    BCF     EECON1, 0x06       ; Set for memory
    BCF     EECON1, 0x07      ; Set for Data EEPROM
    BCF     INTCON, 0x07        ; Disable interrupts
    BSF     EECON1, 0x02       ; Enable writes
LOOP:                              ; Loop to refresh array
    BSF     EECON1, 0x00         ; Read current address
    MOVLW   0x55               ;
    MOVWF   EECON2             ; Write 55h
    MOVLW   0xAA               ;
    MOVWF   EECON2             ; Write 0AAh
    BSF     EECON1, 0x01         ; Set WR bit to begin write
    BTFSC   EECON1, 0x01         ; Wait for write to complete
    BRA     $-2
    INCFSZ  EEADR, F           ; Increment address
    BRA     LOOP               ; Not zero, do it again
    INCFSZ  EEADRH, F          ; Increment the high address
    BRA     LOOP               ; Not zero, do it again
    BCF     EECON1, 0x02       ; Disable writes
    BSF     INTCON, 0x07        ; Enable interrupts
