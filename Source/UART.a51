;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                $INCLUDE        (PSW.inc)
                $INCLUDE        (AUXR1.inc)       ; Need AUX R1 SFRs

                PUBLIC          UART_1_Init
                PUBLIC          UART_2_Init
                PUBLIC          UART_RXed

                PUBLIC          UART_1_ISR
                PUBLIC          UART_2_ISR

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

UART_1_Init:
; ***               MOV             R0,
                AJMP            UART_Init

UART_2_Init:
; ***                MOV             R0,
                JZ              UART_Init

                MOV             A, rAUXR1
                ORL             A, #mS2_P4        ; Move UART2 to P4
                MOV             rAUXR1, A

; ***                MOV             R0,
UART_Init:
                RET

;-------------------------------------------------------------------------------
UART_1_ISR:
                USING           UARTBank

                SJMP            UARTISR

;-------------------------------------------------------------------------------
UART_2_ISR:
                USING           UARTBank

;               SJMP            UARTISR

;-------------------------------------------------------------------------------
UARTISR:
                USING           UARTBank

                RETI

;===============================================================================
                END
