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

                EXTRN           CODE(ResetHandler)
;               EXTRN           CODE(Int0Handler)
                EXTRN           CODE(Timer0Handler)
;               EXTRN           CODE(Int1Handler)
;               EXTRN           CODE(Timer1Handler)
;               EXTRN           CODE(UART1Handler)
;               EXTRN           CODE(LVDHandler)
;               EXTRN           CODE(ADCHandler)
;               EXTRN           CODE(PCAHandler)
                EXTRN           CODE(UART2Handler)
;               EXTRN           CODE(SPIHandler)

Vector          SEGMENT         CODE AT 0000h
                RSEG            Vector

                ORG             0000h
ResetVector:    JMP             ResetHandler

                ORG             0003h
;Int0Vector:    JMP             Int0Handler
                RETI

                ORG             000Bh
Timer0Vector:   JMP             Timer0Handler

                ORG             0013h
;Int1Vector:    JMP             Int1Handler
                RETI

                ORG             001Bh
;Timer1Vector:  JMP             Timer1Handler
                RETI

                ORG             0023h
;UART1Vector:   JMP             UART1Handler
                RETI

                ORG             002Bh
;ADCVector:     JMP             ADCHandler
                RETI

                ORG             0033h
;LVDVector:     JMP             LVDHandler
                RETI

                ORG             003Bh
;PCAHandler:    JMP             PCAHandler
                RETI

                ORG             0043h
UART2Vector:    JMP             UART2Handler

                ORG             004Bh
;SPIVector:     JMP             SPIHandler
                RETI

                END
