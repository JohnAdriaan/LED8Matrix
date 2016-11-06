;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                $INCLUDE        (PSW.inc)

                PUBLIC          UART_Init
                PUBLIC          UART_RXed

                PUBLIC          UART_1ISR
                PUBLIC          UART_2ISR

UARTBank        EQU             1       ; Register bank used in UART interrupt

;===============================================================================
UARTBits        SEGMENT         BIT
                RSEG            UARTBits

UART_RXed:      DBIT            1                 ; Set when Command received

;===============================================================================
Buffers         SEGMENT         XDATA AT 00300h
                RSEG            Buffers

nTXBuff         EQU             128
aTXBuffer:      DSB             nTXBuff
aTXBuffEnd      EQU             $

nRXBuff         EQU             128
aRXBuffer:      DSB             nRXBuff
aRXBuffEnd      EQU             $

;===============================================================================
UART            SEGMENT         CODE
                RSEG            UART

UART_Init:
                RET

;-------------------------------------------------------------------------------
UART_1ISR:
                USING           UARTBank

                SJMP            UARTISR

;-------------------------------------------------------------------------------
UART_2ISR:
                USING           UARTBank

;               SJMP            UARTISR

;-------------------------------------------------------------------------------
UARTISR:
                USING           UARTBank

                RETI

;===============================================================================
                END
