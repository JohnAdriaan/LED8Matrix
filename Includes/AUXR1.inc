;
; AUXR1.inc
;
; This file defines the AUXR1 SFR, its fields, and some useful definitions
;

                $INCLUDE        (John.inc)

DPTR0           EQU             DPTR    ; They're the same SFR - change DPS!
DP0H            EQU             DPH     ; They're the same SFR - change DPS!
DP0L            EQU             DPL     ; They're the same SFR - change DPS!

DPTR1           EQU             DPTR    ; They're the same SFR - change DPS!
DP1H            EQU             DPH     ; They're the same SFR - change DPS!
DP1L            EQU             DPL     ; They're the same SFR - change DPS!

UseDPTR0        MACRO
                ANL             rAUXR1, #NOT mDPS ; Use DPTR0
                ENDM

UseDPTR1        MACRO
                ORL             rAUXR1, #    mDPS ; Use DPTR1
                ENDM

ToggleDPS       MACRO
                INC             rAUXR1            ; Bit 1 is always 0
                ENDM

; AUXiliary1 Register
                SFR   rAUXR1  =  0A2h

DefineBit       PCA_P4, rAUXR1, 6       ; Move PCA from P1[4:2] to P4[3:1]
DefineBit       SPI_P4, rAUXR1, 5       ; Move SPI from P1[7:4] to P4[3:0]
DefineBit       S2_P4,  rAUXR1, 4       ; Move UART2(S2) from P1[3:2] to P4[3:2]
DefineBit       GF2,    rAUXR1, 3       ; General Flag 2
DefineBit       ADRJ,   rAUXR1, 2       ; Move ADC from [7:0][1:0] to [1:0][7:0]
; Note that bit 1 is defined to always be 0. Thus INC rAUXR1 merely toggles DPS!
DefineBit       DPS,    rAUXR1, 0       ; Use DPTR1 instead of DPTR0
