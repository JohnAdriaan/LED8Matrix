;
; Timer.a51
;
; This file defines the Timer interrupt ISRs, and some useful functions.
;

                NAME            Timer

                $INCLUDE        (IE.inc)
                $INCLUDE        (TCON.inc)

                EXTERN   CODE   (Timer0_Handler)
;               EXTERN   CODE   (Timer1_Handler)

                PUBLIC          Timer_0_Init
                PUBLIC          Timer_1_Init

                PUBLIC          Timer_0_ISR
;               PUBLIC          Timer_1_ISR

;===============================================================================
Timer           SEGMENT         CODE
                RSEG            Timer

Timer_0_Init:
                ORL             rIPH, #mPT0H      ; Set T0 int to priority 11b
                oRL             rIP,  #mPT0
                RET

;-------------------------------------------------------------------------------
Timer_1_Init:
                RET

;===============================================================================
Timer_0_ISR:
                PUSH            PSW
                PUSH            ACC
                ACALL           Timer0_Handler
                POP             ACC
                POP             PSW
                RETI

;-------------------------------------------------------------------------------
;Timer_1_ISR:
;               PUSH            PSW
;               PUSH            ACC
;               ACALL           Timer1_Handler
;               POP             ACC
;               POP             PSW
;               RETI

;===============================================================================
                END
