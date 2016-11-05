;
; DigiPot.a51
;
; This file defines the Digital Potentiometer, and gives some useful functions.
;
; The DigiPot used is the Analog Devices AD8403: quad; 256-step; 10kOhm max.
;
; All timings are provided as "settle times" - don't do the next step until the
; indicated time has elapsed. But also note that a 33.1776 MHz processor does
; the simplest instruction in 30 ns...
;
; The DigiPot command word is sent MSb first:
;  A1 A0 D7 D6 D5 D4 D3 D2 D1 D0
; 
; A DigiPot is commanded by:
; * Pulling down CLK (P4.5)                   ( 0ns);
; * Pulling down CS (P4.0)                    (10ns);
; * Repeat for 10n bits (n=#DigiPots in chain)
;   - Setting SDI (P4.1)                      ( 5ns);
;   - Raising CLK (P4.5)                      (10ns);
;   - Lowering CLK (P4.5)                     (10ns, 25ns if chained);
; * Raising CS (P4.0)                         (10ns)
;
; Note that pulling SHDN (P4.4) low open-circuits the DigiPot.
;

                NAME            DigiPot

                $INCLUDE        (John.inc)
                $INCLUDE        (Board.inc)
                $INCLUDE        (P4.inc)

                PUBLIC          InitDigiPot

                SFR  rDigiPot   = rP4
                SFR  rDigiPotM0 = rP4M0
                SFR  rDigiPotM1 = rP4M1

DefineBit       ShDn, rDigiPot, 4
DefineBit       CS,   rDigiPot, 0
DefineBit       Clk,  rDigiPot, 5
DefineBit       SDI,  rDigiPot, 1

mDigiPot        EQU             mShDn + mCS + mClk + mSDI

nDigiPots       EQU             4

;===============================================================================
DigiPot         SEGMENT         CODE
                RSEG            DigiPot

InitDigiPot:
                MOV             A, #mDigiPot  ; Pins to change
                ORL             rDigiPotM0, A ; Push/Pull needs 1 in M0...
                CPL             A             ; (toggle all bits)
                ANL             rDigiPotM1, A ; ...and 0 in M1

                MOV             R3, #25       ; Approx 1000 Ohms for all Anodes
                MOV             R2, #25       ; Approx 1000 Ohms for Red Cathode
                ACALL           SetDigiPots
;***                SETB            ShDn          ; Turn on DigiPots
                RET

;-------------------------------------------------------------------------------
; Call with R3 set to Anode value, and R2 set to Red Cathode value
; Modifies: A, R0, R1, R7
SetDigiPots:
                MOV             R1, #nDigiPots; DigiPot to set (0, 3, 2, 1)
                CLR             Clk           ; Set Clk low
SetDigiPotsLoop:
                CLR             CS            ; Set CS low
                MOV             A, R2         ; Send Red Cathode first
                ACALL           SendDigiPot   ; Send data to this DigiPot
                MOV             A, R3         ; Send Anode next
                ACALL           SendDigiPot   ; Send data to this DigiPot
                SETB            CS            ; Set CS high again
                DJNZ            R1, SetDigiPotsLoop ; One less DigiPot
                RET
SendDigiPot:
                MOV             R0, A         ; Save value to set for now
                MOV             A, R1         ; DigiPot to set
                RR              A             ; Need bottom two bits up high
                RR              A             ; (since MSb is sent first)
                MOV             R7, #2        ; Number of bits to send
                ACALL           SendDigiPotBits
                MOV             A, R0         ; Get value to set back
                MOV             R7, #8        ; Number of bits to send
SendDigiPotBits:
                RLC             A             ; Get high bit in Carry
                MOV             SDI, C        ; Write Carry to data bit
                SETB            Clk           ; Raise Clk
                CLR             Clk           ; Lower Clk
                DJNZ            R7, SendDigiPotBits
                RET
;===============================================================================
                END
