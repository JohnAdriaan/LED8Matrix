;
; P1.inc
;
; This file defines I/O Port P1 and its Configuration ports P1M0 and P1M1
;

$IF  (NOT P1_INC)
$SET (P1_INC)

                SFR     pP1   = 090h

                SFR     rP1M0 = 092h
                SFR     rP1M1 = 091h

$ENDIF ; P1_INC
