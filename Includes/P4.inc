;
; P4.inc
;
; This file defines I/O Port P4 and its Configuration ports P4M0 and P4M1
;

$IF  (NOT P4_INC)
$SET (P4_INC)

                SFR     pP4   = 0C0h

                SFR     rP4M0 = 0B4h
                SFR     rP4M1 = 0B3h

$ENDIF ; P4_INC
