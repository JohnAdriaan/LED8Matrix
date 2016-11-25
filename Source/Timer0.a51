;
; Timer0.a51
;
; This file defines the Timer0 ISR, and some useful functions.
;

                NAME            Timer0

                $INCLUDE        (Options.inc)

$IF (TIMER0_Enable)

                $INCLUDE        (IE.inc)
                $INCLUDE        (TCON.inc)

                EXTERN   CODE   (Timer0_Handler)

                PUBLIC          Timer0_Init
                PUBLIC          Timer0_ISR

;===============================================================================
Timer0          SEGMENT         CODE
                RSEG            Timer0

Timer0_Init:
                ORL             rIPH, #mPT0H      ; Set T0 int to priority 11b
                ORL             rIP,  #mPT0
                RET
;===============================================================================
Timer0_ISR:
                PUSH            PSW
                PUSH            ACC
                ACALL           Timer0_Handler
                POP             ACC
                POP             PSW
                RETI
;===============================================================================
$ENDIF
                END
