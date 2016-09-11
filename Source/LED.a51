;
; LED.a51
;

LEDColours      EQU             3
LEDCols         EQU             8
LEDRows         EQU             8
LEDs            EQU             LEDColours * LEDCols * LEDRows

                PUBLIC          InitLED

LEDPWM          SEGMENT         XDATA AT 0000h
                RSEG            LEDPWM

PWM:            DSB             LEDs

LEDFrame        SEGMENT         XDATA AT 0100h
                RSEG            LEDFrame

Frame:          DSB             LEDs

LED             SEGMENT         CODE
                RSEG            LED

InitLED:
                CLR             A
                MOV             R7, #LEDs
                MOV             DPTR, #LEDPWM
InitPWMLoop:
                MOVX            @DPTR, A
                INC             DPTR
                DJNZ            R7, InitPWMLoop

                MOV             R7, #LEDs
                MOV             DPTR, #LEDFrame
InitFrameLoop:
                MOVX            @DPTR, A
                INC             DPTR
                DJNZ            R7, InitFrameLoop

                RET

                END
