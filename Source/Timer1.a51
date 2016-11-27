;
; Timer1.a51
;
; This file defines the Timer0 symbols and some useful functions.
; Those functions are actually defined in Timer.inc - to commonalise the code.
;

                NAME            Timer1

                $INCLUDE        (Options.inc)

$IF (TIMER1_Enable)

T               LIT             '1'               ; Timer1

                SFR    TL1  =   08Bh
                SFR    TH1  =   08Dh

                $INCLUDE        (Timer.inc)
;===============================================================================
$ENDIF
                END
