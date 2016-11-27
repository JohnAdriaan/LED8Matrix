;
; UART.a51
;
; This file defines the UART symbols and some useful functions.
; Those functions are actually defined in UART.inc - to commonalise the code.
;

                NAME            UART

                $INCLUDE        (Options.inc)

$IF (UART_Enable)

U               LIT             ''                ; UART

                $INCLUDE        (P3.inc)
                SFR  pUART  =   pP3
                SFR  rSM0   =   rP3M0
                SFR  rSM1   =   rP3M1
DefineBit       TxD, pUART, 1
DefineBit       RxD, pUART, 0

                SFR  rSCON  =   098h     ; Serial Control

                SFR  rSBUF  =   099h     ; Serial Buffer (RX and TX)

;===============================================================================
BuffersHigh     EQU             002h

UART_Move       MACRO                             ; UART can't be moved
                ENDM

                $INCLUDE        (UART.inc)        ; Include generic code
;===============================================================================
$ENDIF
                END
