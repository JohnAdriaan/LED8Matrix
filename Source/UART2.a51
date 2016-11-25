;
; UART2.a51
;
; This file defines the UART2 ISR, and some useful functiona.
;

                NAME            UART2

                $INCLUDE        (Options.inc)

$IF (UART2_Enable)

UART            LIT             'UART2'

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (P4.inc)
                $INCLUDE        (AUXR.inc)
                $INCLUDE        (AUXR1.inc)       ; Need AUX R1 SFRs

                PUBLIC          {UART}_Init
                PUBLIC          {UART}_RXed

                PUBLIC          {UART}_RX
                PUBLIC          {UART}_TX_Num
                PUBLIC          {UART}_TX_Char
                PUBLIC          {UART}_TX_Code

                PUBLIC          {UART}_ISR

EOL             EQU             13      ; Carriage return is end-of-line

                SFR  rS2SBUF =  09Bh    ; Serial 2 Buffer (RX and TX)

                SFR  rS2CON  =  09Ah    ; Serial 2 Control
DefineBit       S2SM0, rS2CON, 7        ; Serial 2 Mode 0
DefineBit       S2SM1, rS2CON, 6        ; Serial 2 Mode 1
DefineBit       S2SM2, rS2CON, 5        ; Serial 2 Mode 2
bS2SM           EQU            bS2SM2
mS2SM           EQU            (mS2SM2 + mS2SM1 + mS2SM0)
DefineBit       S2REN, rS2CON, 4        ; Serial 2 RX Enable
DefineBit       S2TB8, rS2CON, 3        ; Serial 2 TX Bit 8
DefineBit       S2RB8, rS2CON, 2        ; Serial 2 RX Bit 8
DefineBit       S2TI,  rS2CON, 1        ; Serial 2 Transmit Interrupt Flag
DefineBit       S2RI,  rS2CON, 0        ; Serial 2 Receive Interrupt Flag

                SFR  rBRT   =   09Ch

UART_BRT        EQU             256 - (CPU_Freq/BAUD_Rate/32)

$IF (UART2_Alt)
                SFR  pS2    =   pP1
                SFR  rS2M0  =   rP1M0
                SFR  rS2M1  =   rP1M1
$ELSE
                SFR  pS2    =   pP4
                SFR  rS2M0  =   rP4M0
                SFR  rS2M1  =   rP4M1
$ENDIF
DefineBit       TxD2, pS2, 3
DefineBit       RxD2, pS2, 2

;===============================================================================
{UART}Bits      SEGMENT         BIT
                RSEG            {UART}Bits

{UART}_RXed:    DBIT            1                 ; Set when data received
;-------------------------------------------------------------------------------
TXEmpty:        DBIT            1                 ; Set when TX buffer empty
;===============================================================================
{UART}Data      SEGMENT         DATA
                RSEG            {UART}Data

RXHead:         DSB             1                 ; In at the Head
RXTail:         DSB             1
TXHead:         DSB             1
TXTail:         DSB             1                 ; Out at the Tail
;===============================================================================
BuffersHigh     EQU             003h

Buffers         SEGMENT         XDATA AT BuffersHigh * 100h
                RSEG            Buffers

BufferSize      EQU             080h ; Sized to allow bit manipulation for wrap

aRXBuff         EQU             000h
                DSB             BufferSize
aTXBuff         EQU             BufferSize
                DSB             BufferSize

WrapRX          MACRO           Reg
                INC             Reg               ; Zero high bit
                ANL             Reg, #NOT BufferSize
                ENDM

; ONLY WrapTX a register (not a variable) when interrupts can happen!
; This is non-atomic, so there'd be a (small) chance of failure!
WrapTX          MACRO           Reg
                INC             Reg               ; Set high bit
                ORL             Reg, #BufferSize
                ENDM
;===============================================================================
{UART}          SEGMENT         CODE
                RSEG            {UART}

{UART}_Init:
                CLR             {UART}_RXed       ; No data received
                MOV             RXHead, #aRXBuff
                MOV             RXTail, #aRXBuff
                MOV             TXHead, #aTXBuff
                MOV             TXTail, #aTXBuff
                SETB            TXEmpty           ; TX Buffer is empty

$IF ({UART}_Alt)
                ORL             rAUXR1, #mS2_P4   ; Move UART to P4
$ENDIF

                ; Push/Pull (TX) is rPxM1=0 and rPxM0=1
                ; Input (RX) is the exact opposite
;               ANL             rS2M1, #NOT mS2TX
;               ANL             rS2M0, #NOT mS2RX
                ORL             rS2M1, #mRxD2
                ORL             rS2M0, #mTxD2

                MOV             rBRT, #UART_BRT   ; Baud Rate Timer value

;               ANL             rAUXR, #NOT mBRTx12  ; Don't multiply by 12
                ORL             rAUXR, #mBRTR        ; Start Baud rate timer

                ORL             rS2CON, #mS2REN   ; Enable Receive

                ORL             rIP2H, #mPS2H     ; Set S2 int to priority 10b
;               ANL             rIP2,  #NOT mPS2

                ORL             rIE2, #mES2       ; Enable Serial 2 interrupts

                RET
;===============================================================================
; ONLY call when UART_RXed indicates something to receive.  (Use JBC UART_RXed,)
; Returns received byte in A - and could re-set UART_RXed to 1.
; Modifies DPTR.
{UART}_RX:
                MOV             DPH, #BuffersHigh ; Point to RXBuffer
                MOV             A, RXTail         ; Current position
                MOV             DPL, A            ; Into DPTR Low
                WrapRX          A                 ; Move to next byte
                MOV             RXTail, A         ; Save it away

                CJNE            A, RXHead, ReRXed ; Reached end of receive?
                SJMP            RXByte
ReRXed:
                SETB            {UART}_RXed        ; Set flag (might be set!)
RXByte:
                MOVX            A, @DPTR          ; Get received byte
                RET
;===============================================================================
; Call with A holding number to transmit
; Modifies B, F1
{UART}_TX_Num:
                MOV             DPH, #BuffersHigh ; Point to TX Buffer
                MOV             DPL, TXHead       ; With both halves

                CLR             F1                ; Leading zero suppression
;TXDiv100:
                MOV             B, #100           ; Divisor
                DIV             AB                ; A/100->A, A%100->B
;               JB              F1, TXNum100      ; TX regardless of zero
                JZ              TXDiv10           ; Zero? Don't TX

;TXNum100:
                SETB            F1                ; Don't suppress zeroes
                ADD             A, #'0'           ; Convert to ASCII
                MOVX            @DPTR, A          ; Store in TX Buffer
; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DPL               ; Move to next TX position

TXDiv10:
                MOV             A, B              ; Get remainder back into A
                MOV             B, #10            ; Divisor
                DIV             AB                ; A/10->A, A%10->B
                JB              F1, TXNum10       ; Print regardless of zero
                JZ              TXDiv1            ; Zero? Don't print

TXNum10:
;               SETB            F1                ; Don't suppress zeroes
                ADD             A, #'0'           ; Convert to ASCII
                MOVX            @DPTR, A
; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DPL               ; Move to next TX position

TXDiv1:
                MOV             A, B              ; Get remainder back into A
;               MOV             B, #1             ; Divisor
;               DIV             AB                ; Not necessary!
;               JB              F1,               ; Always print final zero
;               JZ              

                ADD             A, #'0'           ; Convert to ASCII
                MOVX            @DPTR, A
; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DPL               ; Move to next TX position
TXNumEnd:
                MOV             TXHead, DPL       ; Save back
                JBC             TXEmpty, TXChar   ; Transmit this if necessary
                RET
;===============================================================================
; Call with A holding character to transmit
{UART}_TX_Char:
                MOV             DPH, #BuffersHigh ; Point to TX Buffer
                MOV             DPL, TXHead       ; With both halves

                MOVX            @DPTR, A          ; Store character

; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DPL               ; Move to next TX position
                MOV             TXHead, DPL       ; Save back
                JBC             TXEmpty, TXChar   ; Transmit this if necessary
                RET

; Jump here if need to set DPH
TXCharDPH:
                MOV             DPH, #BuffersHigh ; Point to TXBuffer
; Only jump here when TXEmpty is known to be set (but already cleared with JBC)
TXChar:
                MOV             DPL, TXTail       ; Get Tail
                MOVX            A, @DPTR          ; Get char to TX

                WrapTX          TXTail            ; Move to next TX position

                MOV             rS2SBUF, A        ; And transmit it
                RET
;===============================================================================
; Call with DPTR pointing to ASCIIZ string (in CODE) to buffer for transmission
; Modifies A, R7 and DPTR1
{UART}_TX_Code:
                UseDPTR1                          ; DPTR1 will point to TX buffer
                MOV             DP1H, #BuffersHigh ; Initialise DPTR1 High
                MOV             DP1L, TXHead      ; Initialise DPTR1 Low
TXCodeLoop:
                UseDPTR                           ; Start with DPTR (into CODE)
                CLR             A                 ; Need zero here
                MOVC            A, @A+DPTR        ; Get byte to store
                JZ              TXCodeEndLoop     ; NUL? Leave!
                INC             DPTR              ; Next source byte

                UseDPTR1                          ; Switch to DPTR1
                MOVX            @DPTR1, A         ; Store in TX buffer

; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DP1L              ; Move to next TX position
                MOV             TXHead, DP1L      ; Save away while available
                SJMP            TXCodeLoop        ; And keep going

TXCodeEndLoop:                                    ; At this point, back to DPTR
                JBC             TXEmpty, TXCharDPH; Start TX if Empty (& clear)
                RET
;===============================================================================
{UART}_ISR:
                PUSH            PSW
                PUSH            ACC
                PUSH            DPL
                PUSH            DPH

                MOV             DPH, #BuffersHigh
ISRLoop:
                MOV             A, rS2CON
                JB              ACC.bS2RI, RXInt  ; Receive interrupt?
                JB              ACC.bS2TI, TXInt  ; Transmit interrupt?

                POP             DPH
                POP             DPL
                POP             ACC
                POP             PSW
                RETI
;-------------------------------------------------------------------------------
RXInt:
                ANL             rS2CON, #NOT mS2RI ; Reset interrupt flag

                MOV             DPL, RXHead        ; Where are we up to?
                WrapRX          RXHead             ; Next RX position

                MOV             A, rS2SBUF         ; Get RXed byte
                MOVX            @DPTR, A           ; Store it away

                CJNE            A, #EOL, RXNotEOL  ; Received end of line?
                SJMP            RXed               ; Yes! Flag main process
RXNotEOL:
                MOV             A, DPL             ; Test for collision
                CJNE            A, RXTail, ISRLoop ; Collided with RXTail?
RXed:
                SETB            {UART}_RXed        ; Yes, so mark for attention
                SJMP            ISRLoop            ; Nothing more to do
;-------------------------------------------------------------------------------
TXInt:
                ANL             rS2CON, #NOT mS2TI ; Reset interrupt flag

                MOV             A, TXTail          ; Where are we up to?
                CJNE            A, TXHead, DoTXInt ; End of TX buffer?
                SETB            TXEmpty            ; Yes! Mark as empty
                SJMP            ISRLoop

DoTXInt:
                WrapTX          TXTail             ; Next TX position
                MOV             DPL, A             ; Pointer to read from

                MOVX            A, @DPTR           ; Byte to transmit
                MOV             rS2SBUF, A         ; Transmit it
                SJMP            ISRLoop
;===============================================================================
$ENDIF
                END
