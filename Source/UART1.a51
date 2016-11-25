;
; UART.a51
;
; This file defines the UART ISR, and some useful functiona.
;

                NAME            UART

                $INCLUDE        (Options.inc)

$IF (UART_Enable)

U               LIT             ''                ; UART

                $INCLUDE        (P3.inc)

                SFR  rSBUF  =  099h     ; Serial Buffer (RX and TX)

                SFR  rSCON  =  098h     ; Serial Control

                SFR  pS     =   pP3
                SFR  rSM0   =   rP3M0
                SFR  rSM1   =   rP3M1
DefineBit       TxD, pS, 1
DefineBit       RxD, pS, 0

;===============================================================================
BuffersHigh     EQU             002h

UART_Move       MACRO
                ENDM

                $INCLUDE        (UART.inc)
;===============================================================================
$ENDIF
                END
