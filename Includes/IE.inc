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
