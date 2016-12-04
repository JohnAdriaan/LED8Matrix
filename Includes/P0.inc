;
; P0.inc
;
; This file defines I/O Port P0 and its Configuration ports P0M0 and P0M1
;

$IF  (NOT P0_INC)
$SET (P0_INC)

                SFR     pP0   = 080h

                SFR     rP0M0 = 094h
                SFR     rP0M1 = 093h

$ENDIF ; P0_INC
