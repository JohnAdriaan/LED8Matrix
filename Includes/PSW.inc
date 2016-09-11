;
; PSW.inc
;
; This file defines the PSW SFR and its fields
;

                SFR    PSW   =  0D0h    ; Program Status Word

bCY             EQU             7
CY              BIT             PSW.bCY
mCY             EQU             1 shl bCY

bAC             EQU             6
AC              BIT             PSW.bAC
mAC             EQU             1 shl bAC

bF0             EQU             5
F0              BIT             PSW.bF0
mF0             EQU             1 shl bF0

bRS1            EQU             4
RS1             BIT             PSW.bRS1
mRS1            EQU             1 shl bRS1

bRS0            EQU             3
RS0             BIT             PSW.bRS0
mRS0            EQU             1 shl bRS0

bOV             EQU             2
OV              BIT             PSW.bOV
;mOV            EQU             1 shl bOV

bF1             EQU             1
F1              BIT             PSW.bF1
mF1             EQU             1 shl bF1

bP              EQU             0
P               BIT             PSW.bP
mP              EQU             1 shl bP
