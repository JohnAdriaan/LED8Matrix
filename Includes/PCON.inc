;
; PCON.inc
;
; This file defines the PCON SFR and its fields
;

%DEFINE (GoToSleep) (ORL rPCON, #mIDL)


; Power CONtrol
                SFR   rPCON  =  087h

; UART1 Double speed
bSMOD           EQU             7
mSMOD           EQU             1 shl bSMOD

; UART1 Set Frame Error detect
bSMOD0          EQU             6
mSMOD0          EQU             1 shl bSMOD0

; Low Voltage Detect Flag
bLVDF           EQU             5
mLVDF           EQU             1 shl bLVDF

; Power Off Flag
bPOF            EQU             4
mPOF            EQU             1 shl bPOF

; General Flag 1
bGF1            EQU             3
mGF1            EQU             1 shl bGF1

; General Flag 0
bGF0            EQU             2
mGF0            EQU             1 shl bGF0

; Power Down
bPD             EQU             1
mPD             EQU             1 shl bPD

; IDLe mode
bIDL            EQU             0
mIDL            EQU             1 shl bIDL
