;
; Timer0.a51
;
; This file defines the Timer0 symbols and some useful functions.
; Those functions are actually defined in Timer.inc - to commonalise the code.
;

                NAME            Timer0

                $INCLUDE        (Options.inc)

$IF (TIMER0_Enable)

T               LIT             '0'               ; Timer0

                SFR   rTL0  =   08Ah
                SFR   rTH0  =   08Ch

                $INCLUDE        (Timer.inc)
;===============================================================================
$ENDIF
                END
