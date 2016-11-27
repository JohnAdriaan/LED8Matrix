;
; Timer.inc
;
; This file defines generic Timer routines to $INCLUDE into Timer modules.
; First define the T LITeral, then the required ports and bits,
; then the generic versions required by this file;
;
; T             : The LITeral to allow Timer{T}_ISR etc. to be defined.
; rTL{T},rTH{T} : The Timer{T} Low and High count/reload registers
;

                $INCLUDE        (IE.inc)
                $INCLUDE        (AUXR.inc)
                $INCLUDE        (TCON.inc)
                $INCLUDE        (TMOD.inc)

                EXTERN   CODE   (Timer{T}_Handler)

                PUBLIC          Timer{T}_Init
                PUBLIC          Timer{T}_Set
                PUBLIC          Timer{T}_Start
                PUBLIC          Timer{T}_Stop
                PUBLIC          Timer{T}_ISR

;===============================================================================
Timer{T}        SEGMENT         CODE
                RSEG            Timer{T}

Timer{T}_Init:
                ; Set Timer mode
;               ANL             rTMOD, #NOT ((TIMER{T}_Mode AND TIMER_Mode_Mask) SHL bM{T})
                ORL             rTMOD, #    ((TIMER{T}_Mode AND TIMER_Mode_Mask) SHL bM{T})

IF (TIMER{T}_Mode AND TIMER_Mode_x12)
                ORL             rAUXR, #mT{T}x12
ENDIF

                ; Set interrupt priority
                SetPriority     bPT{T}, TIMER{T}_Priority

                ; Enable Timer{T} interrupt
                SETB            IE{T}
                RET
;===============================================================================
; Call with A (or BA for >8-bit values) set with desired value
Timer{T}_Set:
IF     ((TIMER{T}_Mode AND TIMER_Mode_Mask)=TIMER_Mode_8)
   IF ({T}=0)
                MOV             TL0, A
   ELSE
                MOV             TH0, A
   ENDIF
ELSEIF ((TIMER{T}_Mode AND TIMER_Mode_Mask)=TIMER_Mode_8_Auto)
                MOV             TH{T}, A          ; Program reload value
                MOV             TL{T}, A          ; Program current value
ELSEIF ((TIMER{T}_Mode AND TIMER_Mode_Mask)=TIMER_Mode_13)
                ANL             A, #1Fh           ; Lower 5 bits of TL!
                MOV             TH{T}, B
                MOV             TL{T}, A
ELSEIF ((TIMER{T}_Mode AND TIMER_Mode_Mask)=TIMER_Mode_16)
                MOV             TH{T}, B
                MOV             TL{T}, A
ELSE
__ERROR__ "TIMER_Mode unknown!"
ENDIF
                RET
;===============================================================================
Timer{T}_Start:
                SETB            TR{T}
                RET
;===============================================================================
Timer{T}_Stop:
                CLR             TR{T}
                RET
;===============================================================================
Timer{T}_ISR:
                PUSH            PSW
                PUSH            ACC
                ACALL           Timer{T}_Handler
                POP             ACC
                POP             PSW
                RETI
