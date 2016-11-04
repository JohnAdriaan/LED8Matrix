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

LEDColours      EQU             3
LEDCols         EQU             8
LEDRows         EQU             8
LEDs            EQU             LEDColours * LEDCols * LEDRows

LEDBank         EQU             3

LEDIndex        EQU             R0
                SFR rLEDIndex = LEDBank*8 + 0

LEDNum          EQU             R7
                SFR rLEDNum   = LEDBank*8 + 7

$IF (BOARD = 1) ; Static resistor board?
                SFR rLEDAnode = rP2  ; 0xA0
                SFR rLEDRed   = rP3  ; 0xB0
                SFR rLEDGreen = rP0  ; 0x80
                SFR rLEDBlue  = rP1  ; 0x90
$ELSEIF (BOARD = 2) ; DigiPot board?
                SFR rLEDAnode = rP0  ; 0x80
                SFR rLEDRed   = rP1  ; 0x90
                SFR rLEDGreen = rP2  ; 0xA0
                SFR rLEDBlue  = rP3  ; 0xB0
$ELSE
__ERROR__ "BOARD not defined!"
$ENDIF

                PUBLIC          InitLED
                PUBLIC          CopyFrame
                PUBLIC          Timer0ISR

;===============================================================================
LEDPWM          SEGMENT         XDATA AT 0000h
                RSEG            LEDPWM

PWM:            DSB             LEDs

;-------------------------------------------------------------------------------
LEDFrame        SEGMENT         XDATA AT 0100h
                RSEG            LEDFrame

Frame:          DSB             LEDs

;===============================================================================
LED             SEGMENT         CODE
                RSEG            LED

InitLED:
;                ACALL           InitLEDFrame
;                ACALL           InitLEDVars
;                ACALL           InitLEDIO
                RET

;-------------------------------------------------------------------------------
InitLEDFrame:
                CLR             A                 ; Zero bytes
                MOV             LEDIndex, #PWM    ; In the PWM area
                MOV             DPTR, #Frame      ; In the Frame area

                MOV             LEDNum, #LEDs     ; Number to zero
InitFrameLoop:
                MOVX            @LEDIndex, A
                MOVX            @DPTR, A
                INC             DPTR
                INC             LEDIndex
                DJNZ            LEDNum, InitFrameLoop

                RET

;...............................................................................
InitLEDVars:
                MOV             rLEDIndex, #PWM
                MOV             rLEDNum,   #0

                RET

;...............................................................................
InitLEDIO:
                CLR             A               ; 0x00
                MOV             rLEDAnode, A
                MOV             rLEDRed,   A
                MOV             rLEDGreen, A
                MOV             rLEDBlue,  A

                ; Push/Pull is PxM1=0 and PxM0=1
                MOV             rP0M1, A
                MOV             rP1M1, A
                MOV             rP2M1, A
                MOV             rP3M1, A

                CPL             A               ; 0xFF
                MOV             rP0M0, A
                MOV             rP1M0, A
                MOV             rP2M0, A
                MOV             rP3M0, A

                RET

;-------------------------------------------------------------------------------
CopyFrame:
                MOV             DPTR, #Frame      ; Source area
                MOV             R0, #PWM          ; Destination area

                MOV             LEDNum, #LEDs     ; This many LEDs
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

                ORL             PSW, #mRS1+mRS0   ; Bank 3
                USING           LEDBank

                POP             DPH
                POP             DPL
                POP             ACC
                POP             PSW
                RETI

;===============================================================================
                END
