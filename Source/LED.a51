;
; LED.a51
;

                NAME            LED

                $INCLUDE        (Board.inc)

                $INCLUDE        (PSW.inc)
                $INCLUDE        (P0.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (P2.inc)
                $INCLUDE        (P3.inc)

nLEDColours     EQU             3 ; Blue, Green, Red
nLEDCols        EQU             8
nLEDRows        EQU             8
nLEDs           EQU             nLEDColours * nLEDCols * nLEDRows

LEDBank         EQU             3  ; Register bank used in LED interrupt
mLEDBank        EQU             LEDBank shl bBank

LEDIndex        EQU             R1 ; Index of row into decrement area
                SFR rLEDIndex = LEDBank*8 + 1

LEDRow          EQU             R2 ; Which Row, as a set bit
                SFR rLEDRow   = LEDBank*8 + 2

LEDCycle        EQU             R3 ; Where we are in the countdown cycle
                SFR rLEDCycle = LEDBank*8 + 3

LEDBlue         EQU             R4
LEDGreen        EQU             R5
LEDRed          EQU             R6

LEDNum          EQU             R7
                SFR rLEDNum   = LEDBank*8 + 7

$IF (BOARD = 1) ; Static resistor board?
                SFR rLEDAnode = rP2  ; 0A0h
                SFR rLEDBlue  = rP1  ; 090h
                SFR rLEDGreen = rP0  ; 080h
                SFR rLEDRed   = rP3  ; 0B0h
$ELSEIF (BOARD = 2) ; DigiPot board?
                SFR rLEDAnode = rP0  ; 080h
                SFR rLEDBlue  = rP3  ; 0B0h
                SFR rLEDGreen = rP2  ; 0A0h
                SFR rLEDRed   = rP1  ; 090h
$ELSE
__ERROR__ "BOARD not defined!"
$ENDIF

                PUBLIC          InitLED
                PUBLIC          NewFrame
                PUBLIC          Timer0ISR

;===============================================================================
LEDBits         SEGMENT         BIT
                RSEG            LEDBits

NewFrame:       DBIT            1                 ; Set when Frame buffer ready

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

InitLED:
                ACALL           InitLEDFrame
                ACALL           InitLEDVars
                ACALL           InitLEDIO
                RET

;-------------------------------------------------------------------------------
InitLEDFrame:
                CLR             A                 ; Zero bytes...
                MOV             LEDIndex, #aPWM   ; ...in the PWM area
                MOV             DPTR, #aFrame     ; ...in the Frame area

                MOV             LEDNum, #nLEDs    ; Number to zero
InitFrameLoop:
                MOVX            @LEDIndex, A
                MOVX            @DPTR, A
                INC             DPTR
                INC             LEDIndex
                DJNZ            LEDNum, InitFrameLoop

                RET

;...............................................................................
InitLEDVars:
                SETB            NewFrame          ; Can generate a new Frame!

                MOV             rLEDIndex, #aPWM
                MOV             rLEDRow, #00000001b
                MOV             rLEDCycle, #0
                MOV             rLEDNum, #0

                RET

;...............................................................................
InitLEDIO:
                CLR             A               ; 000h
                MOV             rLEDAnode, A
                MOV             rLEDRed,   A
                MOV             rLEDGreen, A
                MOV             rLEDBlue,  A

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

                RET

;-------------------------------------------------------------------------------
CopyFrame:
                MOV             DPTR, #aFrame     ; Source area
                MOV             R0, #aPWM         ; Destination area

                MOV             LEDNum, #nLEDs    ; This many LEDs
CopyFrameLoop:
                MOVX            A, @DPTR
                MOVX            @R0, A
                INC             DPTR
                INC             R0
                DJNZ            LEDNum, CopyFrameLoop

                RET

;-------------------------------------------------------------------------------
Timer0ISR:
                PUSH            PSW
                PUSH            ACC
                PUSH            DPL
                PUSH            DPH

                ORL             PSW, #mLEDBank    ; All bits are set
                USING           LEDBank

                POP             DPH
                POP             DPL
                POP             ACC
                POP             PSW
                RETI

;===============================================================================
                END
