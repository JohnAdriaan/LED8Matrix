;
; LED.a51
;

                NAME            LED

                $INCLUDE        (Options.inc)

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P0.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (P2.inc)
                $INCLUDE        (P3.inc)

nLEDColours     EQU             3 ; Blue, Green, Red
nLEDCols        EQU             8
nLEDsPerRow     EQU             nLEDColours * nLEDCols
nLEDRows        EQU             8
nLEDs           EQU             nLEDsPerRow * nLEDRows

LEDBank         EQU             3  ; Register bank used in LED interrupt

LEDIndex        EQU             R1 ; Index of row into decrement area
                SFR rLEDIndex = LEDBank*8 + 1

LEDCycle        EQU             R2 ; Where we are in the countdown cycle
                SFR rLEDCycle = LEDBank*8 + 2

LEDMask         EQU             R4 ; Current LED Mask to set
LEDBlue         EQU             R5
LEDGreen        EQU             R6
LEDRed          EQU             R7

$IF (BOARD=BOARD_Resistor)
                SFR   pAnode  = pP2  ; 0A0h
                SFR   pBlue   = pP1  ; 090h
                SFR   pGreen  = pP0  ; 080h
                SFR   pRed    = pP3  ; 0B0h
$ELSEIF (BOARD=BOARD_DigiPot)
                SFR   pAnode  = pP0  ; 080h
                SFR   pBlue   = pP3  ; 0B0h
                SFR   pGreen  = pP2  ; 0A0h
                SFR   pRed    = pP1  ; 090h
$ELSE
__ERROR__ "BOARD not defined!"
$ENDIF

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
                MOV             LED_Update, #0    ; Which mechanism to use
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

                MOV             R5, #nLEDColours  ; Number of colours
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
                MOV             rLEDCycle, #1     ; Simulate new Frame
                RET

;...............................................................................
InitIO:
                CLR             A               ; 000h
                MOV             pAnode, A       ; Anodes off

                ; Push/Pull is rPxM1=0 and rPxM0=1
                MOV             rP0M1, A
                MOV             rP1M1, A
                MOV             rP2M1, A
                MOV             rP3M1, A

                CPL             A               ; 0FFh
                MOV             rP0M0, A
                MOV             rP1M0, A
                MOV             rP2M0, A
                MOV             rP3M0, A

                ; Set all Cathodes high (LEDs off)
                MOV             pRed,   A
                MOV             pGreen, A
                MOV             pBlue,  A

                RET
;-------------------------------------------------------------------------------
CopyFrame       MACRO
                LOCAL           CopyLoop
                MOV             DPTR, #aFrame     ; Source area
                MOV             R0, #aPWM         ; Destination area

                MOV             R7, #nLEDs        ; This many LEDs
CopyLoop:
                MOVX            A, @DPTR
                MOVX            @R0, A
                INC             DPTR
                INC             R0
                DJNZ            R7, CopyLoop
                ENDM

Timer0_Handler:
                SetBank         LEDBank

; ***UPDATE
                DJNZ            LEDCycle, Cycle   ; Still in current cycle?

                ; New row started!
                MOV             A, #0FFh          ; Set all Cathodes high
                MOV             pRed,   A
                MOV             pGreen, A
                MOV             pBlue,  A

                CLR             C                 ; Need zero Carry
                MOV             A, pAnode         ; Current Anode (init 000h)
                RLC             A                 ; Change which Anode
                JNZ             NewRow            ; A not zero (yet)

                ; New frame started! Copy frame across
                SETB            EA                ; Enable ints during copy
                PUSH            DPL               ; Need these registers now...
                PUSH            DPH
                CopyFrame
                POP             DPH               ; Don't need these anymore
                POP             DPL
                CLR             EA                ; Disable ints again

                MOV             LEDIndex, #aPWM
                SETB            LED_Frame
                MOV             pAnode, #00000001b ; Restart Anode
                SJMP            Cycle

NewRow:
                MOV             pAnode, A         ; Save new Row mask back
                MOV             A, LEDIndex       ; Current row
                ADD             A, #nLEDsPerRow   ; New position
                MOV             LEDIndex, A       ; Into index

Cycle:
                MOV             A, #0FFh           ; All bits off (Cathode!)
                MOV             LEDBlue,  A
                MOV             LEDGreen, A
                MOV             LEDRed,   A

                MOV             A, LEDIndex       ; Current Row index
                MOV             R0, A             ; Into index register

                MOV             A, #00000001b     ; Start LEDMask value
RowLoop:
                MOV             LEDMask, A
; *** Initialise which colour register
CellLoop: ; One cell is ether an LED or a Pixel
                MOVX            A, @R0            ; Get current LED value
                JZ              CellNext          ; Jump if A is Zero
                DEC             A                 ; PWM LED value
                MOVX            @R0, A            ; and store back
; *** Zero bit indicated by LEDMask in current colour register
CellNext:
; *** Go to next colour register
                JNZ             CellLoop          ; *** or whatever
RowNext:
                CLR             C                 ; Need zero in Carry
                MOV             A, LEDMask        ; Where are we in the mask?
                RLC             A
                JNZ             RowLoop           ; Still more to do

                MOV             pBlue,  LEDBlue
                MOV             pGreen, LEDGreen
                MOV             pRed,   LEDRed

                RET

;===============================================================================
                END
