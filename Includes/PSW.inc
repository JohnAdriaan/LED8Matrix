;
; PSW.inc
;
; This file defines the PSW SFR and its fields
;

                $INCLUDE        (John.inc)

SetBank         MACRO           Bank
IF (Bank=0)
                ANL             PSW, #NOT (mRS1+mRS0)
ELSEIF (Bank=1)
                ORL             PSW, #mRS0
                ANL             PSW, #NOT mRS1
ELSEIF (Bank=2)
                ANL             PSW, #NOT mRS0
                ORL             PSW, #mRS1
ELSEIF (Bank=3)
                ORL             PSW, #mRS1+mRS0
ELSE
__ERROR__       "Invalid Bank!"
ENDIF
                USING           Bank
                ENDM

; Program Status Word
                SFR   rPSW   =  0D0h

DefineBit       CY,  rPSW, 7            ; CarrY flag
DefineBit       AC,  rPSW, 6            ; Auxiliary Carry flag (for BCD)
DefineBit       F0,  rPSW, 5            ; (User) Flag 0
DefineBit       RS1, rPSW, 4            ; Register bank Select 1
DefineBit       RS0, rPSW, 3            ; Register bank Select 0

;DefineBit      OV,  rPSW, 2            ; OVerflow flag
bOV             EQU             2
OV              BIT             rPSW.bOV
;mOV            EQU             1b shl bOV  ; Naming convention collision!

DefineBit       F1,  rPSW, 1            ; (User) Flag 1
DefineBit       P,   rPSW, 0            ; Parity Flag
