;
; CPU.a51
;
; This module provides some CPU-specific functions.
;

                NAME            CPU

                $INCLUDE        (AUXR.inc)
                $INCLUDE        (PCON.inc)
                $INCLUDE        (PSW.inc)
                $INCLUDE        (WDT.inc)

                PUBLIC          Stack
                PUBLIC          InitCPU

;===============================================================================

StackSegment    SEGMENT         DATA AT 0030h
                RSEG            StackSegment

Stack:          DSB             32      ; I don't know how big this needs to be!

;===============================================================================

CPUData         SEGMENT         XDATA AT 00F0h
                RSEG            CPUData

Power:          DSB             1
ID:             DSB             7                 ; Put here at power-on
FreqLast:       DSD             1                 ; Put here at power-on
FreqFactory:    DSD             1                 ; Put here at power-on

;===============================================================================

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
