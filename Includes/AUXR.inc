;
; AUXR.inc
;
; This file defines the AUXR SFR and its fields
;

                $INCLUDE        (Options.inc)

; AUXiliary Register
                SFR   rAUXR  =  08Eh

IF     (CPU=CPU_STC12)
DefineBit       T0x12,     rAUXR, 7     ; Timer 0 x12 speed
DefineBit       T1x12,     rAUXR, 6     ; Timer 1 x12 speed
DefineBit       UART_M0x6, rAUXR, 5     ; UART Mode 0 x6 rate
DefineBit       BRTR,      rAUXR, 4     ; Baud Rate Timer Run
DefineBit       S2SMOD,    rAUXR, 3     ; UART2 Double speed
DefineBit       BRTx12,    rAUXR, 2     ; Baud Rate Timer x12 speed
DefineBit       EXTRAM,    rAUXR, 1     ; External RAM only
DefineBit       S1BRS,     rAUXR, 0     ; Serial 1 use Baud Rate Timer (not Timer1)
ELSEIF (CPU=CPU_STC89)
DefineBit       EXTRAM,    rAUXR, 1     ; External RAM only
DefineBit       ALEOFF,    rAUXR, 0     ; Disable ALE unless MOVX or MOVC
ELSE
__ERROR__ "CPU unknown!"
ENDIF
