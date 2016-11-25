;
; UART2.a51
;
; This file defines the UART2 definitions and some useful functions.
; Those functions are actually defined in UART.inc - to commonalise the code.
;

                NAME            UART2

                $INCLUDE        (Options.inc)

$IF (UART2_Enable)

U               LIT             '2'               ; UART2

                $INCLUDE        (P1.inc)
                $INCLUDE        (P4.inc)
                $INCLUDE        (AUXR1.inc)       ; Need AUX R1 SFRs

                SFR  rS2BUF  =  09Bh    ; Serial 2 Buffer (RX and TX)

                SFR  rS2CON  =  09Ah    ; Serial 2 Control

$IF (UART2_Alt)
                SFR  pS2    =   pP1
                SFR  rS2M0  =   rP1M0
                SFR  rS2M1  =   rP1M1
$ELSE
                SFR  pS2    =   pP4
                SFR  rS2M0  =   rP4M0
                SFR  rS2M1  =   rP4M1
$ENDIF
DefineBit       TxD2, pS2, 3
DefineBit       RxD2, pS2, 2

;===============================================================================
BuffersHigh     EQU             003h

UART2_Move      MACRO
$IF (UART2_Alt)
                ORL             rAUXR1, #mS2_P4   ; Move UART to P4
$ENDIF
                ENDM

                $INCLUDE        (UART.inc)
;===============================================================================
$ENDIF
                END
