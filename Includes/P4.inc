;
; P4.inc
;
; This file defines I/O Port P4 and its Configuration ports P4M0 and P4M1
;

$IF  (NOT P4_INC)
$SET (P4_INC)

                $INCLUDE        (John.inc)

                SFR     pP4   = 0C0h

                SFR     rP4M0 = 0B4h
                SFR     rP4M1 = 0B3h

                SFR     rP4SW = 0BBh
DefineBit       LVDP46, rP4SW, 6
DefineBit       ALEP45, rP4SW, 5
DefineBit       NAP44,  rP4SW, 4

$ENDIF ; P4_INC
