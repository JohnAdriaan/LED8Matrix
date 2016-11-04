;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                PUBLIC          InitUART

                PUBLIC          UART1ISR
                PUBLIC          UART2ISR

UARTBank        EQU             1

;===============================================================================
Buffers         SEGMENT         XDATA AT 0300h
                RSEG            Buffers

TXBuffer:       DSB             128
TXBuffEnd       EQU             $-TXBuffer

RXBuffer:       DSB             128
RXBuffEnd       EQU             $-RXBuffer

;===============================================================================
UART            SEGMENT         CODE
                RSEG            UART

InitUART:
                RET

;-------------------------------------------------------------------------------
UART1ISR:
                USING           UARTBank

                SJMP            UARTISR

;-------------------------------------------------------------------------------
UART2ISR:
                USING           UARTBank

;               SJMP            UARTISR

;-------------------------------------------------------------------------------
UARTISR:
                USING           UARTBank

                RETI

;===============================================================================
                END
