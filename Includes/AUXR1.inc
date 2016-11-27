;
; AUXR1.inc
;
; This file defines the AUXR1 SFR, its fields, and some useful definitions
;

                $INCLUDE        (John.inc)

DPTR1           EQU             DPTR    ; They're the same SFR - change DPS!
DP1H            EQU             DPH     ; They're the same SFR - change DPS!
DP1L            EQU             DPL     ; They're the same SFR - change DPS!

UseDPTR         MACRO
                ANL             rAUXR1, #NOT mDPS ; Use DPTR0
                ENDM

UseDPTR1        MACRO
                ORL             rAUXR1, #    mDPS ; Use DPTR1
                ENDM

; AUXiliary1 Register
                SFR   rAUXR1  =  0A2h

DefineBit       PCA_P4, rAUXR1, 6       ; Move PCA from P1[4:2] to P4[3:1]
DefineBit       SPI_P4, rAUXR1, 5       ; Move SPI from P1[7:4] to P4[3:0]
DefineBit       S2_P4,  rAUXR1, 4       ; Move UART2(S2) from P1[3:2] to P4[3:2]
DefineBit       GF2,    rAUXR1, 3       ; General Flag 2
DefineBit       ADRJ,   rAUXR1, 2       ; Move ADC from [7:0][1:0] to [1:0][7:0]
DefineBit       DPS,    rAUXR1, 0       ; Use DPTR1 instead of DPTR0
