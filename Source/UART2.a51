;
; UART2.a51
;
; This file defines the UART2 symbols and some useful functions.
; Those functions are actually defined in UART.inc - to commonalise the code.
;

                NAME            UART2

                $INCLUDE        (Options.inc)

$IF (UART2_Enable)

U               LIT             '2'               ; UART2

                SFR  rS2BUF  =  09Bh    ; Serial 2 Buffer (RX and TX)

                SFR  rS2CON  =  09Ah    ; Serial 2 Control

$IF (UART2_Alt)
                $INCLUDE        (P1.inc)
                SFR  pUART2 =   pP1
                SFR  rS2M0  =   rP1M0
                SFR  rS2M1  =   rP1M1
$ELSE
                $INCLUDE        (P4.inc)
                SFR  pUART2 =   pP4
                SFR  rS2M0  =   rP4M0
                SFR  rS2M1  =   rP4M1
$ENDIF
DefineBit       TxD2, pUART2, 3
DefineBit       RxD2, pUART2, 2

;===============================================================================
BuffersHigh     EQU             003h

UART2_Move      MACRO
$IF (UART2_Alt)
                ORL             rAUXR1, #mS2_P4   ; Move UART to P4
$ENDIF
                ENDM

                $INCLUDE        (UART.inc)        ; Include generic code
;===============================================================================
$ENDIF
                END
