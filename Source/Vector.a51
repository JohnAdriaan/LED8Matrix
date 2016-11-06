;
; Vector.a51
;
; This file defines the interrupt vectors at the beginning of the memory map.
; Not all will be defined, so they're commented out and replaced by RETIs.
;
; It is, of course, possible to remove even these - to save space in the code
; memory - but I don't think that's going to be an issue...
;

                NAME            Vector

                EXTRN   CODE   (Reset_ISR)
;               EXTRN   CODE   (Int_0ISR)
                EXTRN   CODE   (Timer_0ISR)
;               EXTRN   CODE   (Int_1ISR)
;               EXTRN   CODE   (Timer_1ISR)
;               EXTRN   CODE   (UART_1ISR)
;               EXTRN   CODE   (LVD_ISR)
;               EXTRN   CODE   (ADC_ISR)
;               EXTRN   CODE   (PCA_ISR)
                EXTRN   CODE   (UART_2ISR)
;               EXTRN   CODE   (SPI_ISR)

;===============================================================================
Vector          SEGMENT         CODE AT 00000h
                RSEG            Vector

                ORG             00000h
ResetVector:    JMP             Reset_ISR

;-------------------------------------------------------------------------------
                ORG             00003h
;Int0Vector:    JMP             Int_0ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0000Bh
Timer0Vector:   JMP             Timer_0ISR

;-------------------------------------------------------------------------------
                ORG             00013h
;Int1Vector:    JMP             Int_1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0001Bh
;Timer1Vector:  JMP             Timer_1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00023h
;UART1Vector:   JMP             UART_1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0002Bh
;ADCVector:     JMP             ADC_ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00033h
;LVDVector:     JMP             LVD_ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0003Bh
;PCAVector:     JMP             PCA_ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00043h
UART2Vector:    JMP             UART_2ISR

;-------------------------------------------------------------------------------
                ORG             0004Bh
;SPIVector:     JMP             SPI_ISR
                RETI

;===============================================================================
                END
