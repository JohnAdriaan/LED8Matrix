;
; LED8x8.a51
;
; Given that there are multiple UPDATE options (see Options.inc), there are two
; mechanisms that I could use:
; * UPDATE is bit-clever, so the Update routine could test the different bits to
;   decide what to do. The problem is that that uses CPU cycles inside the
;   interrupt to work out what to do (as opposed to cycles to determine which
;   interrupt to vector off) - but the code could be smaller!
; * The alternative is to quickly vector off the current UPDATE to specific
;   routines, written to carefully maintain state within the register bank from
;   interrupt to interrupt. Cute - I just need to remember to initialise the
;   variables when changing UPDATE.
; My concern is that I have a 2,048-byte code limit. When I add a font table I'm
; going to blow that. Of course, there are techniques that I could use to burn
; the font table independent of the code. Hmmm...

                NAME            LED8x8

                $INCLUDE        (Options.inc)

$IF (LED8X8_Enable)

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P0.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (P2.inc)
                $INCLUDE        (P3.inc)

nColours        EQU             3 ; Blue, Green, Red
nColumns        EQU             8
nRows           EQU             8
nPixels         EQU             nColumns * nRows
nLEDsPerRow     EQU             nColours * nColumns
nLEDs           EQU             nLEDsPerRow * nRows

LEDBank         EQU             3  ; Register bank used in LED interrupt

LEDIndex        EQU             R0 ; Current pointer into decrement area
                SFR rLEDIndex = LEDBank*8 + 0

LEDBGRPtr       EQU             R1 ; Pointer to LED Color bit registers
                SFR rLEDBGRPtr = LEDBank*8 + 1
BGR_Blue        EQU             3
BGR_Green       EQU             2
BGR_Red         EQU             1

                SFR rBGRStart = LEDBank*8 + 2
LEDBlueRow      EQU             R2 ; Accumulators when doing RGB simultaneously
LEDGreenRow     EQU             R3
LEDRedRow       EQU             R4
                SFR rBGREnd   = LEDBank*8 + 5

LEDRow          EQU             R4 ; Current LED Row mask
                SFR rLEDRow   = LEDBank*8 + 4

LEDAnode        EQU             R5 ; Current Anode
                SFR rLEDAnode = LEDBank*8 + 5

LEDMask         EQU             R6 ; Current LED Mask to set
                SFR rLEDMask  = LEDBank*8 + 6

LEDCycle        EQU             R7 ; Where we are in the countdown
                SFR rLEDCycle = LEDBank*8 + 7

NumCycles       EQU             CYCLE

; Different PWM algorithms implemented here
LED_DoPWM       MACRO           LEDNext
                MOVX            A, @DPTR          ; Get current LED value
                JZ              LEDNext           ; Zero? Nothing to do.

IF     (CYCLE=CYCLE_Decrement)
                DEC             A                 ; PWM down one (Arithmetic!)
                MOVX            @DPTR, A          ; and store back
ELSEIF (CYCLE=CYCLE_Shift)
;               CLR             C                 ; Need zero here (actually no)
                RRC             A                 ; PWM LED value (Logarithmic!)
                MOVX            @DPTR, A          ; and store back
                JNC             LEDNext           ; Don't display if Carry is 0
ELSE
__ERROR__ "CYCLE unknown!"
ENDIF
                ENDM

IF     (BOARD=BOARD_PLCC40)
                SFR   pAnode  = pP0  ; 080h
                SFR   pBlue   = pP2  ; 0A0h
                SFR   pGreen  = pP2  ; 0A0h
                SFR   pRed    = pP2  ; 0A0h
ELSEIF (BOARD=BOARD_DigiPot)
                SFR   pAnode  = pP0  ; 080h
                SFR   pBlue   = pP3  ; 0B0h
                SFR   pGreen  = pP2  ; 0A0h
                SFR   pRed    = pP1  ; 090h
ELSEIF (BOARD=BOARD_Resistor)
                SFR   pAnode  = pP2  ; 0A0h
                SFR   pBlue   = pP1  ; 090h
                SFR   pGreen  = pP0  ; 080h
                SFR   pRed    = pP3  ; 0B0h
ELSE
__ERROR__       "BOARD unknown!"
ENDIF

                PUBLIC          LED_Init
                PUBLIC          LED_Reset
                PUBLIC          LED_Scroll
                PUBLIC          LED_NewFrame
                PUBLIC          Timer0_Handler

;===============================================================================
LED_Bits        SEGMENT         BIT
                RSEG            LED_Bits

LED_NewFrame:   DBIT            1                 ; Set when Frame buffer ready

;===============================================================================
LED_PWM         SEGMENT         XDATA AT 00000h
                RSEG            LED_PWM

aPWM:           DSB             nLEDs

;-------------------------------------------------------------------------------
LED_Frame       SEGMENT         XDATA AT 00100h
                RSEG            LED_Frame

aFrame:         DSB             nLEDs

;===============================================================================
LED_Code        SEGMENT         CODE
                RSEG            LED_Code

LED_Init:
                ACALL           InitPWM
                ACALL           InitFrame
LED_Reset:
                ACALL           InitVars
                ACALL           InitIO
                RET

;-------------------------------------------------------------------------------
InitPWM:
                CLR             A
                MOV             DPTR, #aPWM
                MOV             R7, #nLEDs
InitPWMLoop:
                MOVX            @DPTR, A
                INC             DPTR
                DJNZ            R7, InitPWMLoop
                RET
;-------------------------------------------------------------------------------
InitFrame:
                MOV             DPTR, #aFrame     ; Store in the Frame area

                MOV             R0, #cLogo - LogoOffset ; Start offset
                MOV             R7, #nLogoSize    ; Number of Logo bytes
InitFrameLoop:
                MOV             A, R0             ; Get current offset
                MOVC            A, @A+PC          ; Weird PC-relative indexing
LogoOffset:                                       ; (Base to offset from)

                SETB            F0                ; Flag which nibble to do
InitNibbleLoop:
                RLC             A                 ; Get Intensity bit into Carry
                MOV             R2, A             ; Save value away
                MOV             A, #0FFh          ; Full intensity
                JC              InitSetNibble     ; Yes!
IF     (CYCLE=CYCLE_Decrement)
                RRC             A                 ; Half intensity
ELSEIF (CYCLE=CYCLE_Shift)
                MOV             A, #00Fh          ; Half intensity
ELSE
__ERROR__ "CYCLE unknown!"
ENDIF
InitSetNibble:
                XCH             A, R2             ; Swap back, and save intensity

                MOV             R5, #nColours     ; Number of colours
InitColourLoop:
                RLC             A                 ; Get top bit into Carry
                MOV             R1, A             ; Save away - need A!

                MOV             A, R2             ; Get intensity
                JC              InitColour
                CLR             A                 ; Nope: LED is off!
InitColour:
                MOVX            @DPTR, A          ; Store Colour
                INC             DPTR
                MOV             A, R1             ; Restore current value into A
                DJNZ            R5, InitColourLoop

                JBC             F0, InitNibbleLoop ; Go around for next nibble?

                INC             R0                ; Next byte in Logo
                DJNZ            R7, InitFrameLoop

                RET

; Bitmap:
; * Top to bottom;
; * 4 bits per pixel (IBGR);
; * MSn to LSn=left to right
cLogo:
                DB              044h, 044h, 0D9h, 0D4h
                DB              044h, 0DDh, 000h, 00Dh
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              0D0h, 000h, 000h, 0D4h
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              044h, 0DDh, 000h, 00Dh
                DB              044h, 044h, 0D9h, 0D4h
                DB              044h, 044h, 044h, 044h
nLogoSize       EQU             $-cLogo

;...............................................................................
InitVars:
                CLR             LED_NewFrame      ; Can't generate new frame yet
                MOV             rLEDIndex, #aPWM  ; Start at first byte
                MOV             rLEDBGRPtr, #BGR_Blue ; Start with Blue
                MOV             rLEDRow,   #00000001b ; Start at first Cathode
                MOV             rLEDAnode, #00000001b ; Start at first Anode
                MOV             rLEDCycle, #NumCycles ; Number of cycles
                RET

;...............................................................................
InitIO:
                CLR             A               ; 000h
                MOV             pAnode, A       ; Anodes off

                ; Push/Pull is rPxM1=0...
;               MOV             rP0M1, A
;               MOV             rP2M1, A
IF (BOARD!=BOARD_PLCC40)
;               MOV             rP1M1, A
;               MOV             rP3M1, A
ENDIF

                ; ...and rPxM0=1
                CPL             A               ; 0FFh
                MOV             rP0M0, A
                MOV             rP2M0, A
IF (BOARD!=BOARD_PLCC40)
                MOV             rP1M0, A
                MOV             rP3M0, A
ENDIF

                ; Set all Cathodes high (LEDs off)
;               MOV             pRed,   A
;               MOV             pGreen, A
;               MOV             pBlue,  A

                RET
;-------------------------------------------------------------------------------
LED_Scroll:
; Scroll Frame buffer one pixel left.
; Fill new column with bits in A (LSb on top).
; If bit is a 1, use colour bytes in R2 (blue), R3 (green) and R4 (red)
; Modifies A, DPTR, R0, R1, R5, R6, R7
                MOV             DPTR, #aFrame     ; Start of Frame buffer

                MOV             R5, A             ; Save bits to scroll in
                MOV             R7, #nRows        ; Number of rows to scroll
LED_ScrollRow:
                MOV             R0, DPL           ; Destination
                INC             DPTR
                INC             DPTR
                INC             DPTR
                MOV             R1, DPL           ; Source

                MOV             R6, #(nColumns-1)*nColours ; Number of raw bytes
LED_ScrollCol:
                MOV             DPL, R1           ; Source
                MOVX            A, @DPTR          ; Get colour value
                MOV             DPL, R0           ; Destination
                MOVX            @DPTR, A          ; Store colour value
                INC             R1                ; Next source
                INC             R0                ; Next destination
                DJNZ            R6, LED_ScrollCol ; Next column

                MOV             DPL, R0
                MOV             A, R5             ; Restore bits to scroll in
                RRC             A                 ; Get bit into Carry
                MOV             R5, A             ; Save for next time

                CLR             A
                JNC             LED_ScrollBlue
                MOV             A, R2
LED_ScrollBlue:
                MOVX            @DPTR, A
                INC             DPTR

                CLR             A
                JNC             LED_ScrollGreen
                MOV             A, R3
LED_ScrollGreen:
                MOVX            @DPTR, A
                INC             DPTR

                CLR             A
                JNC             LED_ScrollRed
                MOV             A, R4
LED_ScrollRed:
                MOVX            @DPTR, A
                INC             DPTR

                DJNZ            R7, LED_ScrollRow ; Next row
                RET
;-------------------------------------------------------------------------------
Timer0_Handler:                                   ; PSW and ACC saved
                SetBank         LEDBank           ; Use this register bank
                PUSH            DPL               ; Need these registers too...
                PUSH            DPH
                MOV             DPH, #000h        ; PWM area

; UpdateRowLED (URL_)
; One Colour each Row changes per cycle (B0.0-7,G0.0-7,) (8)
                CJNE            LEDIndex, #nLEDs, URL_Cycle ; Past LEDs?
                MOV             LEDIndex, #aPWM             ; Restart LEDIndex
                DJNZ            LEDCycle, URL_Cycle   ; Still in current cycle?

                ; New frame started! Copy frame across
                ACALL           CopyFrame
;               SJMP            URL_Cycle
URL_Cycle:
                MOV             LEDRow, #0FFh     ; All bits off (Cathode!)
                MOV             DPL, LEDIndex     ; Current index into pointer

                MOV             A, #00000001b     ; Start LEDMask value
URL_LEDLoop:
                MOV             LEDMask, A

                LED_DoPWM       URL_LEDNext

                MOV             A, LEDMask        ; Where are we in the mask?
                XRL             rLEDRow, A        ; Illuminate this LED in Row
URL_LEDNext:
                INC             DPTR              ; Move to next colour byte
                INC             DPTR              ; of the same colour. This is
                INC             DPTR              ; smaller/easier than DPTR+3

                MOV             A, LEDMask        ; Where are we in the mask?
                ADD             A, ACC            ; A no-carry-in shift left
                JNC             URL_LEDLoop       ; Still more to do

                MOV             A, LEDIndex       ; Index into colour bytes
                JBC             ACC.1, URL_SetRed ; Use LEDIndex bit pattern
                INC             LEDIndex          ; Not Red, so next byte
                JB              ACC.0, URL_SetGreen ; as selector into action
URL_SetBlue:
                MOV             A, LEDAnode       ; Get current LEDAnode
                MOV             pRed, #0FFh       ; Need to clear Red before anode
                MOV             pAnode, A         ; Set new anode
                MOV             pBlue, LEDRow     ; Set Blue row
                RL              A                 ; Change which Anode
                MOV             LEDAnode, A       ; Remember for next time
                AJMP            Timer0_Exit
URL_SetGreen:
                MOV             pBlue, #0FFh      ; Clear Blue row
                MOV             pGreen, LEDRow    ; Set Green row
                AJMP            Timer0_Exit
URL_SetRed:
                ADD             A, #nLEDsPerRow   ; Next block of bytes
                MOV             LEDIndex, A       ; Back into LEDIndex
                MOV             pGreen, #0FFh     ; Clear Green row
                MOV             pRed, LEDRow      ; Set Red row
Timer0_Exit:
                POP             DPH               ; Restore these
                POP             DPL
                RET                               ; And finished!
;...............................................................................
; This function copies the Frame buffer into the Decrement Area.
; It modifies A, DPTR and LEDCycle (reinitialisng the latter to start again).
; It also sets the LED_NewFrame flag.
CopyFrame:
;               SETB            EA                ; Allow interrupts during copy
                MOV             DPTR, #aFrame     ; Source area

                MOV             LEDCycle, #nLEDs  ; This many LEDs
CopyLoop:
                MOVX            A, @DPTR          ; Get byte to copy
                DEC             DPH               ; Destination area
                MOVX            @DPTR, A          ; Store in decrement area
                INC             DPH               ; Back to Source area
                INC             DPTR              ; Next byte
                DJNZ            LEDCycle, CopyLoop
;               CLR             EA                ; That's enough!

                SETB            LED_NewFrame      ; Set NewFrame flag
                MOV             LEDCycle, #NumCycles ; Next cycle
                RET
;===============================================================================
$ENDIF
                END
