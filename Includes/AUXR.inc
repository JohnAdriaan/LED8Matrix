;
; AUXR.inc
;
; This file defines the AUXR SFR and its fields
;

                $INCLUDE        (John.inc)

; AUXiliary Register
                SFR   rAUXR  =  08Eh

DefineBit       T0x12,     rAUXR, 7     ; Timer 0 x12 speed
DefineBit       T1x12,     rAUXR, 6     ; Timer 1 x12 speed
DefineBit       UART_M0x6, rAUXR, 5     ; UART Mode 0 x6 rate
DefineBit       BRTR,      rAUXR, 4     ; Baud Rate Timer Run
DefineBit       S2SMOD,    rAUXR, 3     ; UART2 Double speed
DefineBit       BRTx12,    rAUXR, 2     ; Baud Rate Timer x12 speed
DefineBit       EXTRAM,    rAUXR, 1     ; External RAM only
DefineBit       S1BRS,     rAUXR, 0     ; Serial 1 use Baud Rate Timer (not Timer1)
