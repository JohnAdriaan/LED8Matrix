;
; IE.inc
;
; This file defines the IE SFR and its fields
;

                $INCLUDE        (John.inc)

; Interrupt Enable register
                SFR   rIE    =  0A8h

DefineBit       EA,   rIE, 7            ; Enable All
IF     (CPU=CPU_STC12)
DefineBit       ELVD, rIE, 6            ; Enable Low Voltage Detect
DefineBit       EADC, rIE, 5            ; Enable Analog-Digital Converter
ELSEIF (CPU=CPU_STC89)
DefineBit       ET2,  rIE, 5            ; Enable Timer 2
ELSE
__ERROR__ "CPU unknown!"
ENDIF
DefineBit       ES,   rIE, 4            ; Enable Serial
DefineBit       ET1,  rIE, 3            ; Enable Timer 1
DefineBit       EX1,  rIE, 2            ; Enable eXternal 1
DefineBit       ET0,  rIE, 1            ; Enable Timer 0
DefineBit       EX0,  rIE, 0            ; Enable eXternal 0

                SFR   rIPH   =  0B7h    ; Interrupt Priority High
                SFR   rIP    =  0B8h    ; Interrupt Priority (Low)

DefineBit       PPCA, rIP, 7            ; Programmable Counter Array
DefineBit       PLVD, rIP, 6            ; Low Voltage Detect
DefineBit       PADC, rIP, 5            ; Analog-Digital Converter
DefineBit       PS,   rIP, 4            ; Serial
DefineBit       PT1,  rIP, 3            ; Timer 1
DefineBit       PX1,  rIP, 2            ; eXternal Interrupt 1
DefineBit       PT0,  rIP, 1            ; Timer 0
DefineBit       PX0,  rIP, 0            ; eXternal Interrupt 0

SetPriority     MACRO           Shift, Priority
IF (Priority AND 10b)
                ORL             rIPH, #    ((Priority AND 10b) SHR 1 SHL Shift)
ELSE
;               ANL             rIPH, #NOT ((Priority AND 10b) SHR 1 SHL Shift)
ENDIF
IF (Priority AND 01b)
                ORL             rIP,  #    ((Priority AND 01b) SHR 0 SHL Shift)
ELSE
;               ANL             rIP,  #NOT ((Priority AND 01b) SHR 0 SHL Shift)
ENDIF
                ENDM

; Interrupt Enable 2 register
                SFR   rIE2   = 0AFh

DefineBit       ESPI, rIE2, 1
DefineBit       ES2,  rIE2, 0

                SFR   rIP2H  = 0B6h     ; Interrupt Priority 2 High
                SFR   rIP2   = 0B5h     ; Interrupt Priority 2 (Low)

DefineBit       PSPI,  rIP2,  1         ; No need to define High versions
DefineBit       PS2,   rIP2,  0

SetPriority2    MACRO           Shift, Priority
IF (Priority AND 10b)
                ORL             rIP2H, #    ((Priority AND 10b) SHR 1 SHL Shift)
ELSE
;               ANL             rIP2H, #NOT ((Priority AND 10b) SHR 1 SHL Shift)
ENDIF
IF (Priority AND 01b)
                ORL             rIP2,  #    ((Priority AND 01b) SHR 0 SHL Shift)
ELSE
;               ANL             rIP2,  #NOT ((Priority AND 01b) SHR 0 SHL Shift)
ENDIF
                ENDM
