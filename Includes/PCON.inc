;
; PCON.inc
;
; This file defines the PCON SFR and its fields
;

                $INCLUDE        (Options.inc)

GoToSleep       MACRO
                ORL             rPCON, #mIDL
                ENDM

; Power CONtrol
                SFR   rPCON  =  087h

DefineBit       SMOD,  rPCON, 7         ; UART Double speed
DefineBit       SMOD0, rPCON, 6         ; UART Set Frame Error detect
IF (CPU=CPU_STC12)
DefineBit       LVDF,  rPCON, 5         ; Low Voltage Detect Flag
ENDIF
DefineBit       POF,   rPCON, 4         ; Power Off Flag
DefineBit       GF1,   rPCON, 3         ; General Flag 1
DefineBit       GF0,   rPCON, 2         ; General Flag 0
DefineBit       PD,    rPCON, 1         ; Power Down
DefineBit       IDL,   rPCON, 0         ; IDLe mode
