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

Stack:          DSB             32      ; How big should this be?

;===============================================================================
CPUData         SEGMENT         XDATA AT 00F0h
                RSEG            CPUData

Power:          DSB             1
ID:             DSB             7                 ; Put here at power-on
FreqLast:       DSD             1                 ; Put here at power-on
FreqFactory:    DSD             1                 ; Put here at power-on

;-------------------------------------------------------------------------------
ExternalRAM     SEGMENT         XDATA AT 0400h
                RSEG            ExternalRAM

NonExistent:    DSB             0FC00h            ; Force "overlay" error

;===============================================================================
CPU             SEGMENT         CODE
                RSEG            CPU

InitCPU:
                MOV             A, rPCON          ; Read Power Control
                MOV             R0, #Power        ; Index
                MOVX            @R0, A            ; Save in CPUData
                ANL             A, #NOT (mLVDF+mPOF); Now turn off these bits
                MOV             rPCON, A

                MOV             A, rWDT_CONTR     ; Get WatchDog timer
                ANL             A, mWDT_FLAG      ; Did it fire?

                RET

;===============================================================================
                END
