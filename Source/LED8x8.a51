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
;   interrupt to interrupt. Cute - I just need to remember to zero the variables
;   when changing UPDATE.
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

LEDPtr          EQU             R0 ; Pointer into decrement area

LEDBGRPtr       EQU             R1 ; Pointer to LED Color bit registers
                SFR rBGRStart = LEDBank*8 + 2
LEDBlue         EQU             R2
LEDGreen        EQU             R3
LEDRed          EQU             R4
                SFR rBGREnd   = LEDBank*8 + 5

LEDAnode        EQU             R5 ; Current Anode
                SFR rLEDAnode = LEDBank*8 + 5

LEDMask         EQU             R6 ; Current LED Mask to set
LEDIndex        EQU             R7 ; Index of row into decrement area

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
__ERROR__       "BOARD not defined!"
ENDIF

                PUBLIC          LED_Init
                PUBLIC          LED_Reset
                PUBLIC          LED_Frame
                PUBLIC          LED_Update
                PUBLIC          Timer0_Handler

;===============================================================================
LEDBits         SEGMENT         BIT
                RSEG            LEDBits

LED_Frame:      DBIT            1                 ; Set when Frame buffer ready

;===============================================================================
LEDData         SEGMENT         DATA
                RSEG            LEDData

LED_Update:     DSB             1
;-------------------------------------------------------------------------------
LEDCycle:       DSB             1                 ; Where we are in the countdown
;===============================================================================
LEDPWM          SEGMENT         XDATA AT 00000h
                RSEG            LEDPWM

aPWM:           DSB             nLEDs

;-------------------------------------------------------------------------------
LEDFrame        SEGMENT         XDATA AT 00100h
                RSEG            LEDFrame

aFrame:         DSB             nLEDs

;===============================================================================
LED             SEGMENT         CODE
                RSEG            LED

LED_Init:
                ACALL           InitFrame
                MOV             LED_Update, #UPDATE ; Which mechanism to use
LED_Reset:
                ACALL           InitVars
                ACALL           InitIO
                RET

;-------------------------------------------------------------------------------
InitFrame:
                MOV             DPTR, #aFrame     ; Store in the Frame area

                MOV             R6, #Logo - LogoOffset ; Start offset
                MOV             R7, #nLogoSize    ; Number of Logo bytes
InitFrameLoop:
                MOV             A, R6             ; Get current offset
                MOVC            A, @A+PC          ; Weird PC-relative indexing
LogoOffset:                                       ; (Base to offset from)

                SETB            F0                ; Flag which nibble to do
InitNibbleLoop:
                RLC             A                 ; Get Intensity bit into Carry
                MOV             R2, A             ; Save value away
                MOV             A, #0FFh          ; Full intensity
                RRC             A                 ; Half intensity?
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

                INC             R6                ; Next byte in Logo
                DJNZ            R7, InitFrameLoop

                RET

; Bitmap:
; * Top to bottom;
; * 4 bits per pixel (IBGR);
; * MSn to LSn=left to right
Logo:
                DB              044h, 044h, 0D0h, 0D4h
                DB              044h, 0DDh, 000h, 00Dh
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              0D0h, 000h, 000h, 0D4h
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              044h, 0DDh, 000h, 00Dh
                DB              044h, 044h, 04Dh, 044h
nLogoSize       EQU             $-Logo

;...............................................................................
InitVars:
                CLR             LED_Frame         ; Can't generate new frame yet
                MOV             LEDCycle, #1      ; Pretend at end of Frame
                MOV             rLEDAnode, #080h  ; Pretend at last Anode
                RET

;...............................................................................
InitIO:
                CLR             A               ; 000h
                MOV             pAnode, A       ; Anodes off

                ; Push/Pull is rPxM1=0 and rPxM0=1
;               MOV             rP0M1, A
;               MOV             rP2M1, A
IF (BOARD!=BOARD_PLCC40)
;               MOV             rP1M1, A
;               MOV             rP3M1, A
ENDIF

                CPL             A               ; 0FFh
                MOV             rP0M0, A
                MOV             rP2M0, A
IF (BOARD!=BOARD_PLCC40)
                MOV             rP1M0, A
                MOV             rP3M0, A
ENDIF

                ; Set all Cathodes high (LEDs off)
                MOV             pRed,   A
                MOV             pGreen, A
                MOV             pBlue,  A

                RET
;-------------------------------------------------------------------------------
Timer0_Handler:                                   ; PSW and ACC saved
                SetBank         LEDBank           ; Use this register bank
                PUSH            DPL               ; Need these registers too...
                PUSH            DPH

IF (BOARD!=BOARD_PLCC40)
                MOV             A, LED_Update     ; Get UPDATE method
                ADD             A, ACC            ; AJMP is a two-byte opcode
                MOV             DPTR, #UpdateTable ; Table of AJMPs
                JMP             @A+DPTR           ; Do it!
ENDIF
Timer0_Exit:
                POP             DPH               ; Restore these
                POP             DPL
                RET                               ; And finished!
;...............................................................................
UpdateTable:
                AJMP            UpdatePixel
                AJMP            UpdateLEDPixel
                AJMP            UpdateLEDColour
                AJMP            UpdateLEDRow
                AJMP            UpdateRowPixel
                AJMP            UpdateRowLED
;               AJMP            UpdateRowColour   ; Just being clever...
;...............................................................................
UpdateRowColour:
; One Colour per Row changes per cycle (B0.0-7,B1.0-7,)  (8)
                AJMP            Timer0_Exit
;...............................................................................
UpdatePixel:
; One Pixel changes per cycle (BGR0.0,BGR0.1,)           (3)
                AJMP            Timer0_Exit
;...............................................................................
UpdateLEDPixel:
; One Colour changes per cycle (B0.0,G0.0,R0.0,B0.1,)    (1)
                AJMP            Timer0_Exit
;...............................................................................
UpdateLEDColour:
; One LED changes per cycle (B0.0,B0.1,..,B1.0,B1.1,)    (1)
                AJMP            Timer0_Exit
;...............................................................................
UpdateLEDRow:
; One LED changes per cycle (B0.0,B0.1,..,G0.0,G0.1,)    (1)
                AJMP            Timer0_Exit
;...............................................................................
UpdateRowPixel:
; One whole Row changes per cycle (BGR0.01234567,)     (8*3)
                CJNE            LEDAnode, #080h, NextRow ; Not at end of Anodes?
                DJNZ            LEDCycle, NextRow ; Still in current cycle?

                ; New frame started! Copy frame across
                ACALL           CopyFrame

                SETB            LED_Frame
                MOV             LEDIndex, #aPWM
                SJMP            Cycle

NextRow:
                MOV             A, LEDIndex       ; Current row
                ADD             A, #nLEDsPerRow   ; New position
                MOV             LEDIndex, A       ; Into index

Cycle:
                MOV             DPH, #000h         ; Decrement area
                MOV             A, #0FFh           ; All bits off (Cathode!)
                MOV             LEDBlue,  A
                MOV             LEDGreen, A
                MOV             LEDRed,   A

                MOV             DPL, LEDIndex     ; Current index into pointer

                MOV             A, #00000001b     ; Start LEDMask value
PixelLoop:
                MOV             LEDMask, A
                MOV             LEDBGRPtr, #rBGRStart
LEDLoop:
                MOVX            A, @DPTR          ; Get current LED value
                JZ              LEDNext           ; Jump if A is Zero
                DEC             A                 ; PWM LED value
                MOVX            @DPTR, A          ; and store back

; Zero bit indicated by LEDMask in current colour register
                MOV             A, LEDMask        ; Get LED Mask
                XRL             A, @LEDBGRPtr     ; XOR with current colour
                MOV             @LEDBGRPtr, A     ; Save back
LEDNext:
                INC             DPTR              ; Next LED value
                INC             LEDBGRPtr         ; Next colour
                CJNE            LEDBGRPtr, #rBGREnd, LEDLoop

                CLR             C                 ; Need zero in Carry
                MOV             A, LEDMask        ; Where are we in the mask?
                RLC             A
                JNC             PixelLoop         ; Still more to do

                MOV             A, LEDAnode       ; Get current LEDAnode
                RL              A                 ; Change which Anode
                MOV             LEDAnode, A       ; Remember for next time
                MOV             pAnode, #0        ; Turn off Anodes
                MOV             pBlue,  LEDBlue
                MOV             pGreen, LEDGreen
                MOV             pRed,   LEDRed
                MOV             pAnode, A         ; Save new Anode back

                AJMP            Timer0_Exit
;...............................................................................
UpdateRowLED:
; One Colour each Row changes per cycle (B0.0-7,G0.0-7,) (8)
                AJMP            Timer0_Exit
;...............................................................................
CopyFrame:
                SETB            EA                ; Allow interrupts during copy
                MOV             DPTR, #aFrame     ; Source area

                MOV             R7, #nLEDs        ; This many LEDs
CopyLoop:
                MOVX            A, @DPTR          ; Get byte to copy
                DEC             DPH               ; Destination area
                MOVX            @DPTR, A          ; Store in decrement area
                INC             DPH               ; Back to Source area
                INC             DPTR              ; Next byte
                DJNZ            R7, CopyLoop

                CLR             EA                ; That's enough!

                RET
;===============================================================================
$ENDIF
                END
