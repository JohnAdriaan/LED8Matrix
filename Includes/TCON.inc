;
; TCON.inc
;
; This file defines the TCON SFR and its fields
;

; Timer CONtrol
                SFR   TCON   =  088h

; Timer Flag 1
bTF1            EQU             7
TF1             BIT             TCON.bTF1
mTF1            EQU             1 shl bTF1

; Timer Run 1
bTR1            EQU             6
TR1             BIT             TCON.bTR1
mTR1            EQU             1 shl bTR1

; Timer Flag 0
bTF0            EQU             5
TF0             BIT             TCON.bTF0
mTF0            EQU             1 shl bTF0

; Timer Run 0
bTR0            EQU             4
TR0             BIT             TCON.bTR0
mTR0            EQU             1 shl bTR0

; Interrupt External 1
bIE1            EQU             3
IE1             BIT             TCON.bIE1
mIE1            EQU             1 shl bIE1

; /Level vs Edge triggered 1
bIT1            EQU             2
IT1             BIT             TCON.bIT1
mIT1            EQU             1 shl bIT1

; Interrupt External 0
bIE0            EQU             1
IE0             BIT             TCON.bIE0
mIE0            EQU             1 shl bIE0

; /Level vs Edge triggered 0
bIT0            EQU             0
IT0             BIT             TCON.bIT0
mIT0            EQU             1 shl bIT0
