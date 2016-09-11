;
; CPU.a51
;
; This module provides some CPU-specific functions.
;

                NAME            CPU

                PUBLIC          Stack
                PUBLIC          InitCPU

                SFR    PCON  =  087h    ; Power CONtrol
SMOD            EQU             80h     ; UART1 Double speed
SMOD0           EQU             40h     ; UART1 Set Frame Error detect
LVDF            EQU             20h     ; Low Voltage Detect Flag
POF             EQU             10h     ; Power Off Flag
GF1             EQU             08h     ; General Flag 1
GF0             EQU             04h     ; General Flag 0
PD              EQU             02h     ; Power Down
IDL             EQU             01h     ; IDLe mode

                SFR    AUXR  =  08Eh    ; AUXiliary Register
T0x12           EQU             80h     ; Timer 0 x12 speed
T1x12           EQU             40h     ; Timer 1 x12 speed
UART_M0x6       EQU             20h     ; UART Mode 0 x6 rate
BRTR            EQU             10h     ; Baud Rate Timer Run
S2SMOD          EQU             08h     ; UART2 Double speed
BRTx12          EQU             04h     ; Baud Rate Timer x12 speed
EXTRAM          EQU             02h     ; External RAM only
S1BRS           EQU             01h     ; UART1 Use Baud Rate Timer (not Timer1)

                SFR WDT_CONTR = 0C1h    ; WatchDog Timer CONTrol Register
WDT_FLAG        EQU             80h     ; Did Watchdog fire?
EN_WDT          EQU             20h     ; Enable WatchDog Timer
CLR_WDT         EQU             10h     ; Clear WatchDog Timer (nice doggy!)
IDLE_WDT        EQU             08h     ; Enable WatchDog Timer during IDLE
PS2             EQU             04h
PS1             EQU             02h
PS0             EQU             01h
PS210           EQU             07h     ; Watchdog frequency selector mask

StackSegment    SEGMENT         DATA AT 0030h
                RSEG            StackSegment

Stack:          DS              32      ; I don't know how big this needs to be!

CPUData         SEGMENT         XDATA AT 00F0h
                RSEG            CPUData

Power:          DS              1
ID:             DS              7
FreqLast:       DS              4
FreqFactory:    DS              4

CPU             SEGMENT         CODE
                RSEG            CPU

InitCPU:
;               MOV             A, PCON           ; Read Power Control
;               MOV             R0, #Power        ; Index
;               MOVX            @R0, A            ; Save in CPUData
;               ANL             A, #NOT (LVDF+POF); Now turn off these bits
;               MOV             PCON, A

;               MOV             A, WDT_CONTR      ; Get WatchDog timer
;               ANL             A, WDT_FLAG       ; Did it fire?

                RET

                END
