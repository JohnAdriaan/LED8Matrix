;
; AUXR.inc
;
; This file defines the AUXR SFR and its fields
;

; AUXiliary Register
                SFR    AUXR  =  08Eh

; Timer 0 x12 speed
bT0x12          EQU             7
mT0x12          EQU             1 shl bT0x12

; Timer 1 x12 speed
bT1x12          EQU             6
mT1x12          EQU             1 shl bT1x12

; UART Mode 0 x6 rate
bUART_M0x6      EQU             5
mUART_M0x6      EQU             1 shl bUART_M0x6

; Baud Rate Timer Run
bBRTR           EQU             4
mBRTR           EQU             1 shl bBRTR

; UART2 Double speed
bS2SMOD         EQU             3
mS2SMOD         EQU             1 shl bS2SMOD

; Baud Rate Timer x12 speed
bBRTx12         EQU             2
mBRTx12         EQU             1 shl bBRTx12

; External RAM only
bEXTRAM         EQU             1
mEXTRAM         EQU             1 shl bEXTRAM

; UART1 Use Baud Rate Timer (not Timer1)
bS1BRS          EQU             0
mS1BRS          EQU             1 shl bS1BRS
