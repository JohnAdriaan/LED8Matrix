;
; AUXR.inc
;
; This file defines the SFR AUXR and its bits
;

                SFR    AUXR  =  08Eh    ; AUXiliary Register

bT0x12          EQU             7       ; Timer 0 x12 speed
mT0x12          EQU             1 shl bT0x12

bT1x12          EQU             6       ; Timer 1 x12 speed
mT1x12          EQU             1 shl bT1x12

bUART_M0x6      EQU             5       ; UART Mode 0 x6 rate
mUART_M0x6      EQU             1 shl bUART_M0x6

bBRTR           EQU             4       ; Baud Rate Timer Run
mBRTR           EQU             1 shl bBRTR

bS2SMOD         EQU             3       ; UART2 Double speed
mS2SMOD         EQU             1 shl bS2SMOD

bBRTx12         EQU             2       ; Baud Rate Timer x12 speed
mBRTx12         EQU             1 shl bBRTx12

bEXTRAM         EQU             1       ; External RAM only
mEXTRAM         EQU             1 shl bEXTRAM

bS1BRS          EQU             0       ; UART1 Use Baud Rate Timer (not Timer1)
mS1BRS          EQU             1 shl bS1BRS
