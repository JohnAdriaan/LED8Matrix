;
; UART.a51
;
; This file defines the UART interrupt ISRs, and some useful functiona.
;

                NAME            UART

                $INCLUDE        (Options.inc)

                $INCLUDE        (IE.inc)
                $INCLUDE        (PSW.inc)
                $INCLUDE        (AUXR.inc)
                $INCLUDE        (AUXR1.inc)       ; Need AUX R1 SFRs

                PUBLIC          UART_1_Init
                PUBLIC          UART_2_Init

                PUBLIC          UART_RX
                PUBLIC          UART_TX_Hex
                PUBLIC          UART_TX_Char
                PUBLIC          UART_TX_Code

                PUBLIC          UART_1_ISR
                PUBLIC          UART_2_ISR

                PUBLIC          UART_RXed

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

;===============================================================================
UARTBits        SEGMENT         BIT
                RSEG            UARTBits

UART_RXed:      DBIT            1                 ; Set when Command received
;-------------------------------------------------------------------------------
TXEmpty:        DBIT            1                 ; Set when TX buffer empty
;===============================================================================
UARTData        SEGMENT         DATA
                RSEG            UARTData

RXHead:         DSB             1                 ; In at the Head
RXTail:         DSB             1
TXHead:         DSB             1
TXTail:         DSB             1                 ; Out at the Tail
;===============================================================================
BuffersHigh     EQU             003h

Buffers         SEGMENT         XDATA AT BuffersHigh * 100h
                RSEG            Buffers

BufferSize      EQU             080h ; Set to allow bit manipulation for wrap

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
UART            SEGMENT         CODE
                RSEG            UART

UART_1_Init:
                RET

UART_2_Init:
                JZ              UART2NoMove
                ORL             rAUXR1, #mS2_P4   ; Move UART2 to P4
UART2NoMove:
                CLR             UART_RXed         ; No command received
                MOV             RXHead, #aRXBuff
                MOV             RXTail, #aRXBuff
                MOV             TXHead, #aTXBuff
                MOV             TXTail, #aTXBuff
                SETB            TXEmpty           ; TX Buffer is empty

                MOV             rBRT, #UART_BRT   ; Baud Rate Timer value

                ANL             rAUXR, #NOT mBRTx12  ; Don't multiply by 12
                ORL             rAUXR, #mBRTR        ; Start Buad rate timer

                ORL             rS2CON, #mS2REN   ; Enable Receive

                ORL             rIP2H, #mPS2H     ; Set S2 int to priority 10b
                ANL             rIP2,  #NOT mPS2

                ORL             rIE2, #mES2       ; Enable Serial 2 interrupts

                RET
;===============================================================================
; Call when UART_RXed indicates something to receive.        (Use JBC UART_RXed)
; Assigns DPTR to buffer in XRAM, and R7 as # bytes to process. (Could be zero!)
UART_RX: ; ***
                RET
;===============================================================================
; Call with A holding Hex byte to transmit
UART_TX_Hex: ; ***
                RET
;===============================================================================
; Call with A holding character to transmit
UART_TX_Char:
                MOV             DPH, #BuffersHigh ; Point to TX Buffer
                MOV             DPL, TXHead       ; With both halves

                MOVX            @DPTR, A          ; Store character

; DO NOT WrapTX TXHead! It's non-atomic...
                WrapTX          DPL               ; Move to next TX position
                MOV             TXHead, DPL       ; Save back

; This should only called when TXEmpty is known to be set (but cleared with JBC)
TXChar:
                MOV             DPL, TXTail       ; Get Tail
                MOVX            A, @DPTR          ; Get char to TX

                WrapTX          TXTail            ; Move to next TX position

                MOV             rS2SBUF, A        ; And transmit it
                RET
;===============================================================================
; Call with DPTR pointing to ASCIIZ string (in CODE) to buffer for transmission
; Modifies A, R7 and DPTR1
UART_TX_Code:
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

TXCodeEndLoop:                                    ; At this point, DPTR is back
                MOV             DPH, #BuffersHigh ; Point to TXBuffer
                JBC             TXEmpty, TXChar   ; Start TX if Empty (& clear)
                RET
;===============================================================================
UART_1_ISR:
;                PUSH            ACC
;                MOV             A, #
;                SJMP            UARTISR
UART_2_ISR:
                PUSH            ACC
;                MOV             A, #
;               SJMP            UARTISR

;-------------------------------------------------------------------------------
UARTISR:
                PUSH            PSW
                PUSH            DPL
                PUSH            DPH

                MOV             DPH, #BuffersHigh
ISRLoop:
                MOV             A, rS2CON
                JB              ACC.bS2RI, RXInt  ; Receive interrupt?
                JB              ACC.bS2TI, TXInt  ; Transmit interrupt?

                POP             DPH
                POP             DPL
                POP             PSW
                POP             ACC
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
                SETB            UART_RXed          ; Yes, so mark for attention
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
                END
