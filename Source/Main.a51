;
; Main.a51
;
; This program uses the STC12C5A60S2 to drive an RGB 8x8 LED matrix.
;
; The matrix has 8x anodes (P0), and 3x (P1-P3) 8x cathodes for the different
; colours.
;
; That will use all 32 (standard) pins, P0 & P1-P3, leaving P4 for extra stuff.
; Given that serial comms could be nice, that means putting UART2 onto P4...
;
; The basic design is to store 3x8x8=192 bytes for the colour values in XDATA.
; Every frame, the current block is copied into the decrement area, for display.
; (This means a second 192-byte area - starting at 0, for interrupt access!)
;
; A "cycle" is one count down, in PWM. If we're using 8-bit colour, that's 256
; per frame. 6-bit colour means 64 per frame.
; Every cycle within the frame (depending on colour depth), each byte will be
; decremented to zero, and then the relevant LED will be turned off.
;
; A timer interrupt will fire VERY often, and each interrupt will do one...
; * LED? 192 interrupts per cycle.
; * Pixel? 64 interrupts per cycle.
; * LED Row? 24 interrupts per cycle.
; * Pixel Row? 8 interrupts per cycle.
;
; The compromise is between interrupts per cycle versus power consumption.
; At any one instant, it is possible to have up to 1, 3, 8 or 24 LEDs on.
; Given a 120mA max for the entire chip, and 20 mA for one pin, there are
; tradeoffs...
;
; All of this relies on Persistence of Vision (PoV). The question becomes one of
; whether a Red-then-Green-then-Blue can stil be seen as white, versus having
; all of them on at once. That's what this will test!
;
; Since LED brightness is the key, I have a dev board that uses DigiPots to
; easily change resistance values. The final board has fixed resistors - with a
; fixed algorithm, of course!
;
; The RGB LEDs require different current-limit resistors for the different
; colours - and worse, the fact that zero-to-eight may be lit means that the
; worst-case scenario (eight LEDs lit) needs to be catered for. Green and Blue
; require the same current limit, while Red needs more. So, to minimise the
; number of DigiPots required, I've put one on the common anodes, and one on the
; Red cathodes. Only you can't get octo parts, so I've used two quad parts. That
; suggested paralleling them, so they're each programmed identically. But
; also, I recognise that maybe the resistance for the two banks needs to be
; set differently. So the two different sets are cascaded such that the Red
; cathodes are "further" on the chain than the anodes.

                NAME            Main

                $INCLUDE        (Options.inc)     ; Enabled options

                $INCLUDE        (IE.inc)          ; Need Interrupt Enable SFRs
                $INCLUDE        (PCON.inc)        ; Need Power Control SFRs

                PUBLIC          Reset_ISR         ; Publish this for Vectors

                EXTERN   DATA   (CPU_Stack)
                EXTERN   CODE   (CPU_Init)

                EXTERN   CODE   (Timer0_Init)

                EXTERN   CODE   (Baud_Init)
                EXTERN   CODE   (UART2_Init)
                EXTERN   BIT    (UART2_RXed)
                EXTERN   CODE   (UART2_RX)
                EXTERN   CODE   (UART2_TX_Num)
                EXTERN   CODE   (UART2_TX_Char)
                EXTERN   CODE   (UART2_TX_Code)

                EXTERN   CODE   (Flash_Init)

                EXTERN   CODE   (DigiPot_Init)
                EXTERN   CODE   (DigiPot_Set)

                EXTERN   CODE   (LED_Init)
                EXTERN   CODE   (LED_Reset)
                EXTERN   BIT    (LED_Frame)

;===============================================================================
                USING           3                 ; Inform compiler of Reg Banks
                USING           2
                USING           1
                USING           0
;===============================================================================
Main            SEGMENT         CODE
                RSEG            Main

Prompt:         DB              "LED8x8> ", 0

Reset_ISR:
                MOV             SP, #CPU_Stack-1  ; Better (upgoing) Stack addr
                CALL            CPU_Init          ; Initialise CPU SFRs
                CALL            Baud_Init         ; Initiaise Baud Rate Timer
                CALL            UART2_Init        ; Initialise UART2

                CALL            Timer0_Init       ; Initialise Timer0
                CALL            Flash_Init        ; Initialise Flash
                CALL            DigiPot_Init      ; Initialise Digital Pots
                CALL            LED_Init          ; Initialise LED matrix

                MOV             A, #UPDATE        ; Starting mode

Recycle:
                CALL            DigiPot_Set
                SETB            EA                ; Enable all interrupts
TXPrompt:
                MOV             DPTR, #Prompt
                CALL            UART2_TX_Code
Executive:
                JBC             LED_Frame, NextFrame   ; Next frame flag? Clear!
                JBC             UART2_RXed, ProcessCmd ; Next command flag? Clear!
                GoToSleep               ; Nothing to do until next interrupt
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Called to generate next frame
NextFrame:
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Called to process next received command
ProcessCmd:
                CLR             EA                ; Stop timer (well, everything)
                CALL            LED_Reset         ; Turn off LEDs
                SJMP            Recycle           ; Start again

;===============================================================================
                END
