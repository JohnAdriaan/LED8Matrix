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

                EXTRN           CODE(ResetISR)
;               EXTRN           CODE(Int0ISR)
                EXTRN           CODE(Timer0ISR)
;               EXTRN           CODE(Int1ISR)
;               EXTRN           CODE(Timer1ISR)
;               EXTRN           CODE(UART1ISR)
;               EXTRN           CODE(LVDISR)
;               EXTRN           CODE(ADCISR)
;               EXTRN           CODE(PCAISR)
                EXTRN           CODE(UART2ISR)
;               EXTRN           CODE(SPIISR)

;===============================================================================
Vector          SEGMENT         CODE AT 00000h
                RSEG            Vector

                ORG             00000h
ResetVector:    JMP             ResetISR

;-------------------------------------------------------------------------------
                ORG             00003h
;Int0Vector:    JMP             Int0ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0000Bh
Timer0Vector:   JMP             Timer0ISR

;-------------------------------------------------------------------------------
                ORG             00013h
;Int1Vector:    JMP             Int1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0001Bh
;Timer1Vector:  JMP             Timer1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00023h
;UART1Vector:   JMP             UART1ISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0002Bh
;ADCVector:     JMP             ADCISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00033h
;LVDVector:     JMP             LVDISR
                RETI

;-------------------------------------------------------------------------------
                ORG             0003Bh
;PCAVector:     JMP             PCAISR
                RETI

;-------------------------------------------------------------------------------
                ORG             00043h
UART2Vector:    JMP             UART2ISR

;-------------------------------------------------------------------------------
                ORG             0004Bh
;SPIVector:     JMP             SPIISR
                RETI

;===============================================================================
                END
