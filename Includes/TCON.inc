;
; TCON.inc
;
; This file defines the TCON SFR and its fields
;

                $INCLUDE        (John.inc)

; Timer CONtrol
                SFR  rTCON   =  088h

DefineBit       TF1, rTCON, 7           ; Timer Flag 1
DefineBit       TR1, rTCON, 6           ; Timer Run 1
DefineBit       TF0, rTCON, 5           ; Timer Flag 0
DefineBit       TR0, rTCON, 4           ; Timer Run 0
DefineBit       IE1, rTCON, 3           ; Interrupt External 1
DefineBit       IT1, rTCON, 2           ; /Level vs Edge triggered 1
DefineBit       IE0, rTCON, 1           ; Interrupt External 0
DefineBit       IT0, rTCON, 0           ; /Level vs Edge triggered 0
