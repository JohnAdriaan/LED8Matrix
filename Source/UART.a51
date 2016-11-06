;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                $INCLUDE        (PSW.inc)

                PUBLIC          InitUART
                PUBLIC          CmdRXed

                PUBLIC          UART1ISR
                PUBLIC          UART2ISR

UARTBank        EQU             1       ; Register bank used in UART interrupt

;===============================================================================
UARTBits        SEGMENT         BIT
                RSEG            UARTBits

CmdRXed:        DBIT            1                 ; Set when Command received

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
