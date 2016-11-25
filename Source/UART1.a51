;
; UART1.a51
;
; This file defines the UART1 ISR, and some useful functiona.
;

                NAME            UART1

                $INCLUDE        (Options.inc)

$IF (UART1_Enable)

UART            LIT             'UART1'

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (AUXR.inc)

                PUBLIC          {UART}_Init
                PUBLIC          {UART}_RXed

                PUBLIC          {UART}_RX
                PUBLIC          {UART}_TX_Num
                PUBLIC          {UART}_TX_Char
                PUBLIC          {UART}_TX_Code

                PUBLIC          {UART}_ISR

;===============================================================================
$ENDIF
                END
