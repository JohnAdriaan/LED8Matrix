;
; Baud.a51
;
; This file defines the Baud Rate Timer definitions, and some useful functiona.
;

                NAME            Baud

                $INCLUDE        (Options.inc)

$IF (Baud_Enable)

                $INCLUDE        (AUXR.inc)

                PUBLIC          Baud_Init

                SFR  rBRT   =   09Ch

;                                      /512 Hz  /128 Hz
Baud_BRT        EQU             256 - (CPU_Freq/BAUD_Rate*4/32)

;===============================================================================
Baud            SEGMENT         CODE
                RSEG            Baud

Baud_Init:
                MOV             rBRT, #Baud_BRT   ; Baud Rate Timer value

;               ANL             rAUXR, #NOT mBRTx12 ; Don't multiply by 12
                ORL             rAUXR, #mBRTR       ; Start Baud rate timer

                RET
;===============================================================================
$ENDIF
                END
