;
; Main.a51
;
; This program uses the STC12C5A60S2 to drive an RGB 8x8 LED matrix.
;
; The matrix has 8x anodes, and 3x 8x cathodes for the different colours.
;
; That will use all 32 (standard) pins, P0 & P1-P3, leaving P4 for extra stuff.
; Given that serial comms could be nice, that means putting UART2 onto P4...
;
; The basic design is to store 3x8x8=192 bytes for the colour values in XDATA.
; Every frame, the current block is copied into the decrement area, for display.
; (This means a second 192-byte area - starting at 0, for interrupt access!)
;
; Every cycle within the frame (depending on colour depth), each byte will be
; decremented to zero, and then the relevant LED will be turned off.
; A "cycle" is one count down, in PWM. If we're using 8-bit colour, that's 256
; per frame. 6-bit colour means 64 per frame.
;
; A timer interrupt will fire VERY often, and each interrupt will do one...
; * LED? 192 interrupts per cycle. (I can't see an advantage here)
; * Pixel? 64 interrupts per cycle. (Ditto)
; * LED Column? 24 interrupts per cycle. (Each LED can then be 15 mA)
; * Pixel Column? 8 interrupts per cycle. (Each LED can then only be 5mA)
;
; The compromise is between interrupts per cycle versus power consumption.
; At any one instant, it is possible to have up to either 8 LEDs on or 24.
; Given a 120mA max for the entire chip, that's either 15mA x 8 or 5mA x 24 LEDs
; simultaneously. The former is brighter, while the latter has better latency.
;
; All of this relies on Persistence of Vision (PoV). The question becomes one of
; whether a Red-then-Green-then-Blue can stil be seen as white, versus having
; all of them on at once. That's what this will test!
;

                NAME            Main

                $INCLUDE        (IE.inc)

                PUBLIC          ResetISR
                PUBLIC          Timer1Hook

                EXTERN          DATA(Stack)
                EXTERN          CODE(InitCPU)
                EXTERN          CODE(InitUART)
                EXTERN          CODE(InitTimer)
                EXTERN          CODE(InitLED)

;===============================================================================

Main            SEGMENT         CODE
                RSEG            Main

ResetISR:
                MOV             SP, #Stack-1      ; Better pos for the Stack!
                CALL            InitCPU           ; Initialise CPU SFRs
                CALL            InitUART          ; Initialise UART2
                CALL            InitTimer         ; Initialise Timer1
                CALL            InitLED           ; Initialise LED matrix

                SETB            EA                ; Enable all interrupts

                SJMP            $

;-------------------------------------------------------------------------------

Timer1Hook:
                RET

                END
