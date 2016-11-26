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
                ORL             rAUXR, #(mBRTx12+mBRTR) ; x12, and start BRT

                RET
;===============================================================================
$ENDIF
                END
