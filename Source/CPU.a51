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

                PUBLIC          CPU_Stack
                PUBLIC          CPU_Init

;===============================================================================
StackSegment    SEGMENT         DATA AT 00030h
                RSEG            StackSegment

CPU_Stack:      DSB             32      ; How big should this be?

;===============================================================================
CPUData         SEGMENT         XDATA AT 000F0h
                RSEG            CPUData

aPower:         DSB             1
aID:            DSB             7                 ; Put here at power-on
aFreqLast:      DSD             1                 ; Put here at power-on
aFreqFactory:   DSD             1                 ; Put here at power-on

;-------------------------------------------------------------------------------
ExternalRAM     SEGMENT         XDATA AT 00400h
                RSEG            ExternalRAM

NonExistent:    DSB             0FC00h            ; Force "overlay" error

;===============================================================================
CPU             SEGMENT         CODE
                RSEG            CPU

CPU_Init:
                MOV             A, rPCON          ; Read Power Control
                MOV             R0, #aPower       ; Index
                MOVX            @R0, A            ; Save in CPUData
                ANL             A, #NOT (mLVDF+mPOF); Now turn off these bits
                MOV             rPCON, A

                MOV             A, rWDT_CONTR     ; Get WatchDog timer
                ANL             A, mWDT_FLAG      ; Did it fire?

                RET

;===============================================================================
                END
