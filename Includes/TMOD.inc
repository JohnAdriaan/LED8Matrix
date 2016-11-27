;
; TMOD.inc
;
; This file defines the TMOD SFR and its fields
;

                $INCLUDE        (John.inc)

; Timer MODe
                SFR  rTMOD   =  089h

DefineBit       GATE1, rTMOD, 7         ; 1 means only run when INT1 high
DefineBit       CT1,   rTMOD, 6         ; Counter or /Timer
DefineBit       M11,   rTMOD, 5         ; Mode 11b=stopped; 10b=8-bit reload
DefineBit       M10,   rTMOD, 4         ; Mode 01b=16-bit; 00b=13-bit
   bM1          EQU             bM10    ; Mode shift number
   mM1          EQU            (mM11 + mM10) ; Mode mask

DefineBit       GATE0, rTMOD, 3         ; 1 means only run when INT1 high
DefineBit       CT0,   rTMOD, 2         ; Counter or /Timer
DefineBit       M01,   rTMOD, 1         ; Mode 11b=2x8-bit; 10b=8-bit reload
DefineBit       M00,   rTMOD, 0         ; Mode 01b=16-bit; 00b=13-bit
   bM0          EQU             bM00    ; Mode shift number
   mM0          EQU            (mM01 + mM00) ; Mode mask
