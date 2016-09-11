;
; UART.a51
;
; This file defines the UART interrupt handlers, and some useful functiona.
;

                NAME            UART

                PUBLIC          InitUART

                PUBLIC          UART1Handler
                PUBLIC          UART2Handler

UART            SEGMENT         CODE
                RSEG            UART

InitUART:
                RET

                USING           2

UART1Handler:
                SJMP            UARTHandler

UART2Handler:
;               SJMP            UARTHandler

UARTHandler:
                RETI

                END
