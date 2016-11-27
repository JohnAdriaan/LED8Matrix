;
; UART.inc
;
; This file defines generic UART routines to $INCLUDE into UART modules.
; First define the U LITeral, then the required variables and ports,
; then the generic versions required by this file;
;
; U           : The LITeral to allow UART{U}_RXed etc. to be defined.
; pUART{U}    : The Port containing the UART pins
;   mS{U}REN  ; The Receive Enable mask
; rS{U}M[01]  : The M1 and M0 registers for defining UART pin directions
;   m[RT]xD{U}: The masks for the RxD and TxD pins on the UART Port
; rS{U}CON    : The UART CONtrol register
; rS{U}BUF    : The buffer register for the RX/TX byte
; BuffersHigh : The high byte of the XDATA pointer for the RX and TX Buffers.
; UART{U}_Move: A (possibly empty) macro to implement UART{U}_Alt
;

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (PCON.inc)
                $INCLUDE        (AUXR.inc)
                $INCLUDE        (AUXR1.inc)       ; Need AUX R1 SFRs

                PUBLIC          UART{U}_Init
                PUBLIC          UART{U}_RXed

                PUBLIC          UART{U}_RX
                PUBLIC          UART{U}_TX_Num
                PUBLIC          UART{U}_TX_Char
                PUBLIC          UART{U}_TX_Code

                PUBLIC          UART{U}_ISR

EOL             EQU             13      ; Carriage return is end-of-line

DefineBit       S{U}M0, rS{U}CON, 7     ; Serial Mode 0
DefineBit       S{U}M1, rS{U}CON, 6     ; Serial Mode 1
DefineBit       S{U}M2, rS{U}CON, 5     ; Serial Mode 2
   bS{U}M       EQU             bS{U}M2 ; Bit shift number
   mS{U}M       EQU            (mS{U}M0 + mS{U}M1 + mS{U}M2)
DefineBit       S{U}REN,rS{U}CON, 4     ; Serial RX Enable
DefineBit       S{U}TB8,rS{U}CON, 3     ; Serial TX Bit 8
DefineBit       S{U}RB8,rS{U}CON, 2     ; Serial RX Bit 8
DefineBit       S{U}TI, rS{U}CON, 1     ; Serial Transmit Interrupt Flag
DefineBit       S{U}RI, rS{U}CON, 0     ; Serial Receive Interrupt Flag

;===============================================================================
UART{U}_Bits    SEGMENT         BIT
                RSEG            UART{U}_Bits

UART{U}_RXed:   DBIT            1                 ; Set when data received
;-------------------------------------------------------------------------------
TXEmpty:        DBIT            1                 ; Set when TX buffer empty
;===============================================================================
UART{U}_Data    SEGMENT         DATA
                RSEG            UART{U}_Data

RXHead:         DSB             1                 ; In at the Head
RXTail:         DSB             1
TXHead:         DSB             1
TXTail:         DSB             1                 ; Out at the Tail
;===============================================================================
UART{U}_Buffs   SEGMENT         XDATA AT BuffersHigh * 100h
                RSEG            UART{U}_Buffs

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
UART{U}         SEGMENT         CODE
                RSEG            UART{U}

UART{U}_Init:
                CLR             UART{U}_RXed      ; No data received
                MOV             RXHead, #aRXBuff
                MOV             RXTail, #aRXBuff
                MOV             TXHead, #aTXBuff
                MOV             TXTail, #aTXBuff
                SETB            TXEmpty           ; TX Buffer is empty

                UART{U}_Move

                ; Push/Pull (TX) is rPxM1=0 and rPxM0=1
                ; Input (RX) is the exact opposite
;               ANL             rS{U}M1, #NOT mTxD{U}
                ORL             rS{U}M1, #    mRxD{U}
;               ANL             rS{U}M0, #NOT mRxD{U}
                ORL             rS{U}M0, #    mTxD{U}

                ; Establish UART{U}_Mode
;               ANL             rS{U}CON, #NOT ((UART{U}_Mode AND UART_Mode_Mask) SHL bS{U}M)
                ORL             rS{U}CON, #    ((UART{U}_Mode AND UART_Mode_Mask) SHL bS{U}M)

IF (UART{U}_Mode AND UART_Mode_x2)
   IF   ({U}0=20) ; How to test which register and mask to use!
                ORL             rAUXR, #mS{U}SMOD
   ELSE
                ORL             rPCON, #mS{U}MOD
   ENDIF
ENDIF

IF (UART{U}_Mode AND UART_Mode_BRG)
                ORL             rAUXR, #mS{U}BRS  ; UART2 must error! Always BRG
ENDIF

                ; Enable Receive
                ORL             rS{U}CON, #mS{U}REN

                ; Set int to desired priority
                SetPriority{U}  bPS{U}, UART{U}_Priority

                ; Enable UART interrupts
                ORL             rIE{U}, #mES{U}

                RET
;===============================================================================
; ONLY call when UART_RXed indicates something to receive.  (Use JBC UART_RXed,)
; Returns received byte in A - and could re-set UART_RXed to 1.
; Modifies DPTR.
UART{U}_RX:
                MOV             DPH, #BuffersHigh ; Point to RXBuffer
                MOV             A, RXTail         ; Current position
                MOV             DPL, A            ; Into DPTR Low
                WrapRX          A                 ; Move to next byte
                MOV             RXTail, A         ; Save it away

                CJNE            A, RXHead, ReRXed ; Reached end of receive?
                SJMP            RXByte
ReRXed:
                SETB            UART{U}_RXed      ; Set flag (might be set!)
RXByte:
                MOVX            A, @DPTR          ; Get received byte
                RET
;===============================================================================
; Call with A holding number to transmit
; Modifies B, F1
UART{U}_TX_Num:
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
UART{U}_TX_Char:
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

                MOV             rS{U}BUF, A       ; And transmit it
                RET
;===============================================================================
; Call with DPTR pointing to ASCIIZ string (in CODE) to buffer for transmission
; Modifies A, R7 and DPTR1
UART{U}_TX_Code:
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
UART{U}_ISR:
                PUSH            PSW
                PUSH            ACC
                PUSH            DPL
                PUSH            DPH

                MOV             DPH, #BuffersHigh
ISRLoop:
                MOV             A, rS{U}CON
                JB              ACC.bS{U}RI, RXInt ; Receive interrupt?
                JB              ACC.bS{U}TI, TXInt ; Transmit interrupt?

                POP             DPH
                POP             DPL
                POP             ACC
                POP             PSW
                RETI
;-------------------------------------------------------------------------------
RXInt:
                ANL             rS{U}CON, #NOT mS{U}RI ; Reset interrupt flag

                MOV             DPL, RXHead        ; Where are we up to?
                WrapRX          RXHead             ; Next RX position

                MOV             A, rS{U}BUF        ; Get RXed byte
                MOVX            @DPTR, A           ; Store it away

                CJNE            A, #EOL, RXNotEOL  ; Received end of line?
                SJMP            RXed               ; Yes! Flag main process
RXNotEOL:
                MOV             A, RXHead          ; Test for collision
                CJNE            A, RXTail, ISRLoop ; Collided with RXTail?
RXed:
                SETB            UART{U}_RXed       ; Yes, so mark for attention
                SJMP            ISRLoop            ; Nothing more to do
;-------------------------------------------------------------------------------
TXInt:
                ANL             rS{U}CON, #NOT mS{U}TI ; Reset interrupt flag

                MOV             A, TXTail          ; Where are we up to?
                CJNE            A, TXHead, DoTXInt ; End of TX buffer?
                SETB            TXEmpty            ; Yes! Mark as empty
                SJMP            ISRLoop

DoTXInt:
                WrapTX          TXTail             ; Next TX position
                MOV             DPL, A             ; Pointer to read from

                MOVX            A, @DPTR           ; Byte to transmit
                MOV             rS{U}BUF, A        ; Transmit it
                SJMP            ISRLoop
