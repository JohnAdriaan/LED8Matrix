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

                PUBLIC          CPU_Stack_Top
                PUBLIC          CPU_Init

;===============================================================================
CPU_Stack       SEGMENT         DATA AT 00030h
                RSEG            CPU_Stack

CPU_Stack_Top:  DSB             32      ; How big should this be?

;===============================================================================
CPU_Data        SEGMENT         XDATA AT 000F0h
                RSEG            CPU_Data

aPower:         DSB             1
aID:            DSB             7                 ; Put here at power-on
aFreqLast:      DSD             1                 ; Put here at power-on
aFreqFactory:   DSD             1                 ; Put here at power-on

;-------------------------------------------------------------------------------
RAM_External    SEGMENT         XDATA AT 00400h
                RSEG            RAM_External

NonExistent:    DSB             0FC00h            ; Force "overlay" error

;===============================================================================
CPU             SEGMENT         CODE
                RSEG            CPU

CPU_Init:
                MOV             A, rPCON          ; Read Power Control
                MOV             DPTR, #aPower     ; Index
                MOVX            @DPTR, A          ; Save in CPUData
                ANL             A, #NOT (mLVDF+mPOF); Now turn off these bits
                MOV             rPCON, A

                MOV             A, rWDT_CONTR     ; Get WatchDog timer
                ANL             A, #mWDT_FLAG     ; Did it fire?
                JZ              CPUNoWDT          ; No ***

CPUNoWDT:
                RET

;===============================================================================
                END
