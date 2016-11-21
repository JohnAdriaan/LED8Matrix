;
; IE.inc
;
; This file defines the IE SFR and its fields
;

                $INCLUDE        (John.inc)

; Interrupt Enable register
                SFR   rIE    =  0A8h

DefineBit       EA,   rIE, 7            ; Enable All
DefineBit       ELVD, rIE, 6            ; Enable Low Voltage Detect
DefineBit       EADC, rIE, 5            ; Enable Analog-Digital Converter
DefineBit       ES,   rIE, 4            ; Enable Serial
DefineBit       ET1,  rIE, 3            ; Enable Timer 1
DefineBit       EX1,  rIE, 2            ; Enable eXternal 1
DefineBit       ET0,  rIE, 1            ; Enable Timer 0
DefineBit       EX0,  rIE, 0            ; Enable eXternal 0

                SFR   rIP    =  0B8h    ; Interrupt Priority (Low)
                SFR   rIPH   =  0B7h    ; Interrupt Priority High

DefineBit       PPCA,  rIP,  7          ; Programmable Counter Array
DefineBit       PPCAH, rIPH, 7
DefineBit       PLVD,  rIP,  6          ; Low Voltage Detect
DefineBit       PLVDH, rIPH, 6
DefineBit       PADC,  rIP,  5          ; Analog-Digital Converter
DefineBit       PADCH, rIPH, 5
DefineBit       PS,    rIP,  4          ; Serial
DefineBit       PSH,   rIPH, 4
DefineBit       PT1,   rIP,  3          ; Timer 1
DefineBit       PT1H,  rIPH, 3
DefineBit       PX1,   rIP,  2          ; eXternal Interrupt 1
DefineBit       PX1H,  rIPH, 2
DefineBit       PT0,   rIP,  1          ; Timer 0
DefineBit       PT0H,  rIPH, 1
DefineBit       PX0,   rIP,  0          ; eXternal Interrupt 0
DefineBit       PX0H,  rIPH, 0

; Interrupt Enable 2 register
                SFR   rIE2   = 0AFh

DefineBit       ESPI, rIE2, 1
DefineBit       ES2,  rIE2, 0

                SFR   rIP2   = 0B5h     ; Interrupt Priority 2 (Low)
                SFR   rIP2H  = 0B6h     ; Interrupt Priority 2 High

DefineBit       PSPI,  rIP2,  1
DefineBit       PSPIH, rIP2H, 1
DefineBit       PS2,   rIP2,  0
DefineBit       PS2H,  rIP2H, 0
