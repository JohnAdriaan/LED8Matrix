;
; Timer2.a51
;
; This file defines the Timer2 symbols and some useful functions.
; Those functions are actually defined in Timer.inc - to commonalise the code.
;

                NAME            Timer2

                $INCLUDE        (Options.inc)

$IF (TIMER2_Enable)

T               LIT             '2'               ; Timer2

                SFR   rRCAP2L = 0CAh              ; Reload/Capture Low
                SFR   rRCAP2H = 0CBh              ; Reload/Capture High
                SFR   rTL2  =   0CCh
                SFR   rTH2  =   0CDh

                $INCLUDE        (Timer.inc)
;===============================================================================
$ENDIF
                END
