;
; PSW.inc
;
; This file defines the PSW SFR and its fields
;

; Program Status Word
                SFR   rPSW   =  0D0h

; CarrY flag
bCY             EQU             7
CY              BIT             rPSW.bCY
mCY             EQU             1 shl bCY

; Auxiliary Carry flag (for BCD)
bAC             EQU             6
AC              BIT             rPSW.bAC
mAC             EQU             1 shl bAC

; (User) Flag 0
bF0             EQU             5
F0              BIT             rPSW.bF0
mF0             EQU             1 shl bF0

; Register bank Select 1
bRS1            EQU             4
RS1             BIT             rPSW.bRS1
mRS1            EQU             1 shl bRS1

; Register bank Select 0
bRS0            EQU             3
RS0             BIT             rPSW.bRS0
mRS0            EQU             1 shl bRS0

; Register bank Select
bRS             EQU             bRS0
mRS             EQU             mRS1 + mRS0

; OVerflow flag
bOV             EQU             2
OV              BIT             rPSW.bOV
;mOV            EQU             1 shl bOV

; (User) Flag 1
bF1             EQU             1
F1              BIT             rPSW.bF1
mF1             EQU             1 shl bF1

; Parity Flag
bP              EQU             0
P               BIT             rPSW.bP
mP              EQU             1 shl bP
