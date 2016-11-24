;
; UART1.a51
;
; This file defines the UART1 ISR, and some useful functiona.
;

                NAME            UART1

                $INCLUDE        (Options.inc)

$IF (UART1_Enable)
                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (AUXR.inc)

                PUBLIC          UART1_Init
                PUBLIC          UART1_RXed

                PUBLIC          UART1_RX
                PUBLIC          UART1_TX_Num
                PUBLIC          UART1_TX_Char
                PUBLIC          UART1_TX_Code

                PUBLIC          UART1_ISR

$ENDIF
                END
