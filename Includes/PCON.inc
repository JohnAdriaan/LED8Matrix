;
; PCON.inc
;
; This file defines the PCON SFR and its fields
;

                SFR    PCON  =  087h    ; Power CONtrol

bSMOD           EQU             7       ; UART1 Double speed
mSMOD           EQU             1 shl bSMOD

bSMOD0          EQU             6       ; UART1 Set Frame Error detect
mSMOD0          EQU             1 shl bSMOD0

bLVDF           EQU             5       ; Low Voltage Detect Flag
mLVDF           EQU             1 shl bLVDF

bPOF            EQU             4       ; Power Off Flag
mPOF            EQU             1 shl bPOF

bGF1            EQU             3       ; General Flag 1
mGF1            EQU             1 shl bGF1

bGF0            EQU             2       ; General Flag 0
mGF0            EQU             1 shl bGF0

bPD             EQU             1       ; Power Down
mPD             EQU             1 shl bPD

bIDL            EQU             0       ; IDLe mode
mIDL            EQU             1 shl bIDL
