;
; Vector.a51
;
; This file defines the interrupt vectors at the beginning of the memory map.
; Not all will be defined, so they're replaced by RETIs.
;
; It is, of course, possible to remove even these - to save space in the code
; memory - but I don't think that's going to be an issue...
;

                $INCLUDE       (Options.inc)

                NAME            Vector

Entry           MACRO Enable, Symbol
$IF (Enable)
                EXTRN   CODE   (Symbol)
                JMP             Symbol
$ELSE
                RETI
$ENDIF
                ENDM

                EXTRN   CODE   (Reset_ISR)

;===============================================================================
Vector          SEGMENT         CODE AT 00000h
                RSEG            Vector

                ORG             00000h
                JMP             Reset_ISR

                ORG             00003h
                Entry           INT0_Enable,    Int0_ISR

                ORG             0000Bh
                Entry           TIMER0_Enable,  Timer0_ISR

                ORG             00013h
                Entry           INT1_Enable,    Int1_ISR

                ORG             0001Bh
                Entry           TIMER1_Enable,  Timer1_ISR

                ORG             00023h
                Entry           UART_Enable,    UART_ISR

                ORG             0002Bh
                Entry           ADC_Enable,     ADC_ISR

                ORG             00033h
                Entry           LVD_Enable,     LVD_ISR

                ORG             0003Bh
                Entry           PCA_Enable,     PCA_ISR

                ORG             00043h
                Entry           UART2_Enable,   UART2_ISR

                ORG             0004Bh
                Entry           SPI_Enable,     SPI_ISR

                END
