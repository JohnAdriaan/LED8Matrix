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

IF (BAUD_Rate AND BAUD_x1)
;                                      /512 Hz   /1 Hz  (512/1=16*32
Baud_BRT        EQU             256 - (CPU_Freq/(BAUD_Rate AND NOT BAUD_x1)*16/12)
ELSE
;                                      /512 Hz  /16 Hz  (512/16=32)
Baud_BRT        EQU             256 - (CPU_Freq/BAUD_Rate)
ENDIF

;===============================================================================
Baud_Code       SEGMENT         CODE
                RSEG            Baud_Code

Baud_Init:
                MOV             rBRT,  #Baud_BRT        ; Baud Rate Timer value
IF (BAUD_Rate AND BAUD_x1)
                ORL             rAUXR, #mBRTR           ; Start BRT
ELSE
                ORL             rAUXR, #(mBRTx12+mBRTR) ; x12, and start BRT
ENDIF

                RET
;===============================================================================
$ENDIF
                END
