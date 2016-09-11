;
; LED.a51
;

LEDColours      EQU             3
LEDCols         EQU             8
LEDRows         EQU             8
LEDs            EQU             LEDColours * LEDCols * LEDRows

                PUBLIC          InitLED
                PUBLIC          CopyFrame

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
                ACALL           InitFrame
                RET

;-------------------------------------------------------------------------------
InitFrame:
                CLR             A                 ; Zero bytes
                MOV             R0, #PWM          ; In the PWM area
                MOV             DPTR, #Frame      ; In the Frame area

                MOV             R7, #LEDs         ; Number to zero
InitFrameLoop:
                MOVX            @R0, A
                MOVX            @DPTR, A
                INC             DPTR
                INC             R0
                DJNZ            R7, InitFrameLoop

                RET

;-------------------------------------------------------------------------------
CopyFrame:
                MOV             DPTR, #Frame      ; Source area
                MOV             R0, #PWM          ; Destination area

                MOV             R7, #LEDs         ; This many LEDs
CopyFrameLoop:
                MOVX            A, @DPTR
                MOVX            @R0, A
                INC             DPTR
                INC             R0
                DJNZ            R7, CopyFrameLoop

                RET

;===============================================================================
                END
