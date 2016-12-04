;
; P2.inc
;
; This file defines I/O Port P2 and its Configuration ports P2M0 and P2M1
;

$IF  (NOT P2_INC)
$SET (P2_INC)

                SFR     pP2   = 0A0h

                SFR     rP2M0 = 096h
                SFR     rP2M1 = 095h

$ENDIF ; P2_INC
