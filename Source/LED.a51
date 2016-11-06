;
; LED.a51
;

                NAME            LED

; There are two ways to program individual RGB pixels:
; * The whole pixel (all B, G, R LEDs every cycle);
; * Only one LED (B, G, or R) every cycle.
; The former allows for longer latency - but requires each LED to be dimmer.
; The latter requires more interrupts - but each LED can be brighter.
$RESET (PIXELvsLED)
$SET   (LEDvsPIXEL)

                $INCLUDE        (Board.inc)

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

$IF (BOARD_Resistor)
                SFR pLEDAnode = pP2  ; 0A0h
                SFR pLEDBlue  = pP1  ; 090h
                SFR pLEDGreen = pP0  ; 080h
                SFR pLEDRed   = pP3  ; 0B0h
$ELSEIF (BOARD_DigiPot)
                SFR pLEDAnode = pP0  ; 080h
                SFR pLEDBlue  = pP3  ; 0B0h
                SFR pLEDGreen = pP2  ; 0A0h
                SFR pLEDRed   = pP1  ; 090h
$ELSE
__ERROR__ "BOARD not defined!"
$ENDIF

                PUBLIC          LED_Init
                PUBLIC          LED_Frame
                PUBLIC          Timer0_Handler

;===============================================================================
LEDBits         SEGMENT         BIT
                RSEG            LEDBits

LED_Frame:      DBIT            1                 ; Set when Frame buffer ready

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
                ACALL           InitVars
                ACALL           InitIO
                RET

;-------------------------------------------------------------------------------
InitFrame:
                MOV             R0, #0            ; Need a zero for SUBB
                MOV             DPTR, #aFrame     ; Store in the Frame area

                MOV             R6, #Mandelbrot - MandelOffset ; Start offset
                MOV             R7, #nLEDRows     ; Number of Logo Rows
InitFrameLoop:
                MOV             A, R6             ; Get current offset
                MOVC            A, @A+PC          ; Weird PC-relative indexing
MandelOffset:                                     ; (Base to calculate from)

                MOV             R5, #nLEDCols     ; Number of bits in bitmap row
InitColLoop:
                RLC             A                 ; Get top bit into Carry
                MOV             R1, A             ; Save away - need A!

                CLR             A                 ; Need zero in A
                SUBB            A, R0             ; Turn Carry into 000h or 0FFh
                MOVX            @DPTR, A          ; Store Blue
                INC             DPTR
                MOVX            @DPTR, A          ; Store Green
                INC             DPTR
                CLR             A                 ; Cyan!
                MOVX            @DPTR, A          ; Store Red
                INC             DPTR

                MOV             A, R1             ; Restore Row bitmap into A
                DJNZ            R5, InitColLoop

                INC             R6                ; Next Row in Logo
                DJNZ            R7, InitFrameLoop

                RET

Mandelbrot:                     ; Bitmap top to bottom, MSb to LSb=left to right
                DB              00001000b, 00011100b, 01011111b, 11111110b
                DB              11111110b, 01011111b, 00011100b, 00001000b
;...............................................................................
InitVars:
                CLR             LED_Frame         ; Can't generate new frame yet

                MOV             rLEDCycle, #1     ; Simulate new Frame

                RET

;...............................................................................
InitIO:
                CLR             A               ; 000h
                MOV             pLEDAnode, A    ; Anodes off

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
                MOV             pLEDRed,   A
                MOV             pLEDGreen, A
                MOV             pLEDBlue,  A

                RET
;-------------------------------------------------------------------------------
Timer0_Handler  :
                SetBank         LEDBank

$IF (LEDvsPIXEL)
$ELSEIF (PIXELvsLED)
$ELSE
__ERROR__ "LED vs PIXEL not defined!"
$ENDIF
                DJNZ            LEDCycle, Cycle   ; Still in current cycle?

                ; New row started!
                MOV             A, 0FFh           ; Set all Cathodes high
                MOV             pLEDRed,   A
                MOV             pLEDGreen, A
                MOV             pLEDBlue,  A

                CLR             C                 ; Need zero Carry
                MOV             A, pLEDAnode      ; Current Anode (init 000h)
                RLC             A                 ; Change which Anode
                JNZ             NewRow            ; A not zero (yet)

                ; New frame started! Copy frame across
                SETB            EA                ; Enable ints during copy
                PUSH            DPL               ; Need these registers now...
                PUSH            DPH

                MOV             DPTR, #aFrame     ; Source area
                MOV             R0, #aPWM         ; Destination area

                MOV             R7, #nLEDs        ; This many LEDs
CopyFrame:
                MOVX            A, @DPTR
                MOVX            @R0, A
                INC             DPTR
                INC             R0
                DJNZ            R7, CopyFrame
                POP             DPH               ; Don't need these anymore
                POP             DPL
                CLR             EA                ; Disable ints again

                MOV             LEDIndex, #aPWM
                SETB            LED_Frame
                MOV             pLEDAnode, #00000001b ; Restart Anode
                SJMP            Cycle

NewRow:
                MOV             pLEDAnode, A      ; Save new Row mask back
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
$IF (LEDvsPIXEL)
$ELSEIF (PIXELvsLED)
$ELSE
__ERROR__ "LED vs PIXEL not defined!"
$ENDIF
LEDLoop:
                MOVX            A, @R0            ; Get current LED value
                JZ              LEDNext           ; Jump if A is Zero
                DEC             A                 ; PWM LED value
                MOVX            @R0, A            ; and store back
; *** Zero bit indicated by LEDMask in current colour register
$IF (LEDvsPIXEL)
$ELSEIF (PIXELvsLED)
$ELSE
__ERROR__ "LED vs PIXEL not defined!"
$ENDIF
LEDNext:
                INC             R0
; *** Go to next colour register
$IF (LEDvsPIXEL)
$ELSEIF (PIXELvsLED)
$ELSE
__ERROR__ "LED vs PIXEL not defined!"
$ENDIF
                JNZ             LEDLoop           ; *** or whatever
RowNext:
                CLR             C                 ; Need zero in Carry
                MOV             A, LEDMask        ; Where are we in the mask?
                RLC             A
                JNZ             RowLoop           ; Still more to do

$IF (LEDvsPIXEL)
$ELSEIF (PIXELvsLED)
$ELSE
__ERROR__ "LED vs PIXEL not defined!"
$ENDIF
                MOV             pLEDBlue,  LEDBlue
                MOV             pLEDGreen, LEDGreen
                MOV             pLEDRed,   LEDRed

                RET

;===============================================================================
                END
