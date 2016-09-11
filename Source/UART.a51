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
                USING           1

                SJMP            UARTISR

;-------------------------------------------------------------------------------
UART2ISR:
                USING           1

;               SJMP            UARTISR

;-------------------------------------------------------------------------------
UARTISR:
                USING           1

                RETI

;===============================================================================
                END
