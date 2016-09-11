;
; Timer.a51
;
; This file defines the Timer interrupt handlers, and some useful functions.
;

                NAME            Timer

                PUBLIC          InitTimer

                PUBLIC          Timer0Handler
                PUBLIC          Timer1Handler

Timer           SEGMENT         CODE
                RSEG            Timer

InitTimer:
                RET

                USING           3

Timer0Handler:
                SJMP            TimerHandler

Timer1Handler:
;               SJMP            TimerHandler

TimerHandler:
                RETI

                END
