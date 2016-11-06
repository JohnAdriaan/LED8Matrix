;
; Timer.a51
;
; This file defines the Timer interrupt ISRs, and some useful functions.
;

                NAME            Timer

                $INCLUDE        (TCON.inc)

                EXTERN   CODE   (Timer0_Handler)
;               EXTERN   CODE   (Timer1_Handler)

                PUBLIC          Timer_Init

                PUBLIC          Timer_0ISR
;               PUBLIC          Timer_1ISR

;===============================================================================
Timer           SEGMENT         CODE
                RSEG            Timer

Timer_Init:
                RET

;-------------------------------------------------------------------------------
Timer_0ISR:
                PUSH            PSW
                PUSH            ACC
                ACALL           Timer0_Handler
                POP             ACC
                POP             PSW
                RETI

;-------------------------------------------------------------------------------
;Timer_1ISR:
;               PUSH            PSW
;               PUSH            ACC
;               ACALL           Timer1_Handler
;               POP             ACC
;               POP             PSW
;               RETI

;===============================================================================
                END
