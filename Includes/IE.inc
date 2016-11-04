;
; IE.inc
;
; This file defines the IE SFR and its fields
;

; Interrupt Enable register
                SFR   rIE    =  0A8h

; Enable All
bEA             EQU             7
EA              BIT             rIE.bEA
mEA             EQU             1 shl bEA

; Enable Low Voltage Detect
bELVD           EQU             6
ELVD            BIT             rIE.bELVD
mELVD           EQU             1 shl bELVD

; Enable Analog-Digital Converter
bEADC           EQU             5
EADC            BIT             rIE.bEADC
mEADC           EQU             1 shl bEADC

; Enable Serial
bES             EQU             4
ES              BIT             rIE.bES
mES             EQU             1 shl bES

; Enable Timer 1
bET1            EQU             3
ET1             BIT             rIE.bET1
mET1            EQU             1 shl bET1

; Enable eXternal 1
bEX1            EQU             2
EX1             BIT             rIE.bEX1
mEX1            EQU             1 shl bEX1

; Enable Timer 0
bET0            EQU             1
ET0             BIT             rIE.bET0
mET0            EQU             1 shl bET0

; Enable eXternal 0
bEX0            EQU             0
EX0             BIT             rIE.bEX0
mEX0            EQU             1 shl bEX0
