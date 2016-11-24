;
; Timer1.a51
;
; This file defines the Timer1 ISR, and some useful functions.
;

                NAME            Timer1

                $INCLUDE        (Options.inc)

$IF (TIMER1_Enable)
                $INCLUDE        (IE.inc)
                $INCLUDE        (TCON.inc)

                EXTERN   CODE   (Timer1_Handler)

                PUBLIC          Timer1_Init
                PUBLIC          Timer1_ISR

;===============================================================================
Timer1          SEGMENT         CODE
                RSEG            Timer1

Timer1_Init:
                ORL             rIPH, #mPT1H      ; Set T1 int to priority 11b
                oRL             rIP,  #mPT1
                RET
;===============================================================================
Timer1_ISR:
                PUSH            PSW
                PUSH            ACC
                ACALL           Timer1_Handler
                POP             ACC
                POP             PSW
                RETI
;===============================================================================
$ENDIF
                END
