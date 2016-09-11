;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                PUBLIC          InitUART

                PUBLIC          UART1ISR
                PUBLIC          UART2ISR

;===============================================================================

UART            SEGMENT         CODE
                RSEG            UART

InitUART:
                RET

                USING           1

;-------------------------------------------------------------------------------

UART1ISR:
                SJMP            UARTISR

;-------------------------------------------------------------------------------

UART2ISR:
;               SJMP            UARTISR

UARTISR:
                RETI

                END
