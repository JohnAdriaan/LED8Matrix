;
; Timer.a51
;
; This file defines the Timer interrupt ISRs, and some useful functions.
;

                NAME            Timer

                $INCLUDE        (TCON.inc)

                PUBLIC          InitTimer

;               PUBLIC          Timer0ISR
;               PUBLIC          Timer1ISR

;===============================================================================
Timer           SEGMENT         CODE
                RSEG            Timer

InitTimer:
                RET

;-------------------------------------------------------------------------------
;Timer0ISR:
;               RETI

;-------------------------------------------------------------------------------
;Timer1ISR:
;               RETI

;===============================================================================
                END
