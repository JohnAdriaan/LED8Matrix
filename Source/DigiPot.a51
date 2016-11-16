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
; * Lower CLK   (P4.5)                ( 0ns);
; * Lower CS    (P4.0)                (10ns);
; * Repeat for 10n bits (n=#DigiPots in chain):
;   - Set SDI     (P4.1)                ( 5ns);
;   - Raise CLK   (P4.5)                (10ns);
;   - Lower CLK   (P4.5)                (10ns, 25ns if chained);
; * Raise CS    (P4.0)                (10ns)
;
; Note that lowering SHDN (P4.4) open-circuits the DigiPot.
;

                NAME            DigiPot

                $INCLUDE        (John.inc)
                $INCLUDE        (Options.inc)
                $INCLUDE        (P4.inc)

                PUBLIC          DigiPot_Init
IF (BOARD=BOARD_DigiPot)
                PUBLIC          DigiPot_Set

                SFR  pDigiPot   = pP4
                SFR  rDigiPotM0 = rP4M0
                SFR  rDigiPotM1 = rP4M1

DefineBit       ShDn, pDigiPot, 4
DefineBit       CS,   pDigiPot, 0
DefineBit       Clk,  pDigiPot, 5
DefineBit       SDI,  pDigiPot, 1

mDigiPot        EQU             mShDn + mCS + mClk + mSDI

nDigiPots       EQU             4

DigiPotOhms     EQU             49 ; This is the wiper resistance (note min val)
ENDIF
;===============================================================================
DigiPot         SEGMENT         CODE
                RSEG            DigiPot

DigiPot_Init:
IF     (BOARD=BOARD_Resistor)
                RET
ELSEIF (BOARD=BOARD_DigiPot)
                MOV             A, #mDigiPot  ; Pins to change
                ORL             rDigiPotM0, A ; Push/Pull needs 1 in M0...
                CPL             A             ; (toggle all bits)
                ANL             rDigiPotM1, A ; ...and 0 in M1
                RET

;-------------------------------------------------------------------------------
; Call with A set to desired mode
; Modifies: A, R0, R1, R2, R7
DigiPot_Set:
                CLR             ShDn          ; Open-circuit DigiPots
                CLR             C             ; Need zero here
                RLC             A             ; Two entries per table row
                MOV             R2, A         ; Save table offset away
                ADD             A, #Set_Table-AnodeOffset ; Offset for Anode
                MOVC            A, @A+PC      ; Weird PC-relative index
AnodeOffset:

                XCH             A, R2         ; Save, and restore table offset
                ADD             A, #Set_Table-RedOffset+1 ; Offset for Red
                MOVC            A, @A+PC      ; Weird PC-relative index
RedOffset:

                MOV             R1, #nDigiPots; DigiPot to set (0, 3, 2, 1)
                CLR             Clk           ; Set Clk low
SetLoop:
                CLR             CS            ; Set CS low
                ACALL           SetSend       ; Send Red Cathode to this DigiPot
                MOV             A, R2         ; Restore saved value
                ACALL           SetSend       ; Send Anode to this DigiPot
                SETB            CS            ; Set CS high again
                DJNZ            R1, SetLoop   ; One less DigiPot

                SETB            ShDn          ; Turn on DigiPots
                RET

SetSend:
                MOV             R0, A         ; Save value to set for now
                MOV             A, R1         ; DigiPot to set
                RR              A             ; Need bottom two bits up high
                RR              A             ; (since MSb is sent first)
                MOV             R7, #2        ; Number of bits to send
                ACALL           SetBits
                MOV             A, R0         ; Get value to set back
                MOV             R7, #8        ; Number of bits to send
SetBits:
                RLC             A             ; Get high bit in Carry
                MOV             SDI, C        ; Write Carry to data bit
                SETB            Clk           ; Raise Clk
;               NOP                           ; Not required
                CLR             Clk           ; Lower Clk
                DJNZ            R7, SetBits
                RET
;===============================================================================

PORT_mA         EQU              20
BOARD_mA        EQU             120

; 3*8 LEDs / 6 (Shared Anode+3xCathodes)
PORT_uA_Row     EQU             PORT_mA*100/3*10/8    ; 833
BOARD_uA_Row    EQU             BOARD_mA*100/3*10/8/6 ; 833

; 8 LEDs / 6 (Shared Anode+3xCathodes)
PORT_uA_Colour  EQU             PORT_mA*100/8*10      ; 2500
BOARD_uA_Colour EQU             BOARD_mA*100/8*10/6   ; 2500

; 3 LEDs (Shared Anode+3xCathodes)
PORT_uA_Pixel   EQU             PORT_mA*1000/3        ; 6666
BOARD_uA_Pixel  EQU             BOARD_mA*100/6*10     ; 20000

; 1 LED  (Anode+Cathode)
PORT_uA_LED     EQU             PORT_mA*1000          ; 20000
BOARD_uA_LED    EQU             BOARD_mA*100/2*10     ; 60000

; Millivolts for different components
mV_Red          EQU             1720
mV_Green        EQU             2300
mV_Blue         EQU             2484
mV_Anode        EQU             2300 ; *MIN*imum of mV_Blue and mV_Green
mV_CPU          EQU             5000

; Convert uA to Ohms for the two resistor locations
%*DEFINE       (OHMS_Anode(uA)) ((mV_CPU-mV_Anode)*10 / (%uA/100))
%*DEFINE       (OHMS_Red(uA))   ((mV_CPU-mV_Anode-mV_Red)*10 / (%uA/100))

; Convert Ohms to DigiPot setting
%*DEFINE         (Setting(O))  ((%O-DigiPotOhms)*4/10*64/1000) ; *Steps/MaxOhms

; Create Entry in Table from uA with Anode, Red settings
%*DEFINE         (Entry(uA))    (%Setting(%OHMS_Anode(%uA)), %Setting(%OHMS_Red(%uA)))

Set_Table:
Set_Pixel:       DB             %Entry(Port_uA_Pixel)
Set_LED_Pixel:   DB             %Entry(Port_uA_LED)
Set_LED_Colour:  DB             %Entry(Port_uA_LED)
Set_LED_Row:     DB             %Entry(Port_uA_LED)
Set_Row_Pixel:   DB             %Entry(Port_uA_Row)
Set_Row_LED:     DB             %Entry(Port_uA_Colour)
Set_Row_Colour:  DB             %Entry(Port_uA_Colour)

ELSE
__ERROR__       "BOARD not defined!"
ENDIF
                END
