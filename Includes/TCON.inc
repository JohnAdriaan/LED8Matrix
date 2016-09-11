;
; TCON.inc
;
; This file defines the TCON SFR and its fields
;

                SFR   TCON   =  088h    ; Timer CONtrol

bTF1            EQU             7       ; Timer Flag 1
TF1             BIT             TCON.bTF1
mTF1            EQU             1 shl bTF1

bTR1            EQU             6       ; Timer Run 1
TR1             BIT             TCON.bTR1
mTR1            EQU             1 shl bTR1

bTF0            EQU             5       ; Timer Flag 0
TF0             BIT             TCON.bTF0
mTF0            EQU             1 shl bTF0

bTR0            EQU             4       ; Timer Run 0
TR0             BIT             TCON.bTR0
mTR0            EQU             1 shl bTR0

bIE1            EQU             3       ; Interrupt External 1
IE1             BIT             TCON.bIE1
mIE1            EQU             1 shl bIE1

bIT1            EQU             2       ; /Level vs Edge triggered
IT1             BIT             TCON.bIT1
mIT1            EQU             1 shl bIT1

bIE0            EQU             1       ; Interrupt External 0
IE0             BIT             TCON.bIE0
mIE0            EQU             1 shl bIE0

bIT0            EQU             0       ; /Level vs Edge triggered
IT0             BIT             TCON.bIT0
mIT0            EQU             1 shl bIT0
