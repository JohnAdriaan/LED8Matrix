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
; The basic design is to store 8x8 pixel values in XDATA using a double buffer.
; The first 'Build' buffer is where the next frame to be displayed is built.
; The second 'PWM' buffer is what is currently being displayed.
; Every frame, if the Build buffer has been completed it is copied into the PWM
; buffer for display.
;
; A "cycle" is one count down, in PWM. If we're using 8-bit colour, that's 256
; per frame. 6-bit colour means 64 per frame, etc.
; Every cycle within the frame (depending on colour depth), each pixel will be
; visited, and its value will determine the state of the relevant LED.
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
                $INCLUDE        (P1.inc)
                $INCLUDE        (PSW.inc)
                $INCLUDE        (PCON.inc)        ; Need Power Control SFRs

                PUBLIC          Reset_ISR         ; Publish this for Vectors

                EXTERN   DATA   (CPU_Stack_Top)
                EXTERN   CODE   (CPU_Init)

                EXTERN   CODE   (Timer0_Init)
                EXTERN   CODE   (Timer0_Set)
                EXTERN   CODE   (Timer0_Start)

$IF     (SERIAL_Enable)
$IF     (BAUD_Enable)
                EXTERN   CODE   (Baud_Init)
$ENDIF ; BAUD_Enable
                EXTERN   CODE   ({SERIAL}_Init)
                EXTERN   BIT    ({SERIAL}_RXed)
                EXTERN   CODE   ({SERIAL}_RX)
                EXTERN   CODE   ({SERIAL}_TX_Num)
                EXTERN   CODE   ({SERIAL}_TX_Char)
                EXTERN   CODE   ({SERIAL}_TX_Code)
$ENDIF ; SERIAL_Enable

$IF     (FLASH_Enable)
                EXTERN   CODE   (Flash_Init)
                EXTERN   CODE   (Flash_Read)
$ENDIF ; FLASH_Enable

$IF     (DIGIPOT_Enable)
                EXTERN   CODE   (DigiPot_Init)
$ENDIF ; DIGIPOT_Enable

                EXTERN   CODE   (LED_Init)
                EXTERN   CODE   (LED_Reset)
                EXTERN   CODE   (LED_Scroll)
                EXTERN   BIT    (LED_NewFrame)

;===============================================================================
                USING           3                 ; Inform compiler of Reg Banks
                USING           2
                USING           1
                USING           0

MainData        SEGMENT         DATA
                RSEG            MainData

ScrollWait:     DSB             1
;===============================================================================
Main_Code       SEGMENT         CODE
                RSEG            Main_Code

$IF     (SERIAL_Enable)
cPrompt:        DB              "LED8x8> ", 0
$ENDIF ; SERIAL_Enable

Reset_ISR:
                MOV             SP, #CPU_Stack_Top-1 ; Better (upgoing) Stack addr
                CALL            CPU_Init          ; Initialise CPU SFRs
                Eye_Init
$IF     (SERIAL_Enable)
$IF     (BAUD_Enable)
                CALL            Baud_Init         ; Initiaise Baud Rate Timer
$ENDIF ; BAUD_Enable
                CALL            {SERIAL}_Init     ; Initialise Serial port
$ENDIF ; SERIAL_Enable

                CALL            Timer0_Init       ; Initialise Timer0
;                                      /512   =   *8     *16        *4
%*DEFINE        (Timer(Rate))   (256 - CPU_Freq/12*8/nFPS*16/nCycles*4/%Rate)
                MOV             A, #%Timer(FPS_Rate_Colour) ; 8*3
                CALL            Timer0_Set
$IF     (FLASH_Enable)
                CALL            Flash_Init        ; Initialise Flash
$ENDIF ; FLASH_Enable
$IF     (DIGIPOT_Enable)
                CALL            DigiPot_Init      ; Initialise Digital Pots
$ENDIF ; DIGIPOT_Enable
                CALL            LED_Init          ; Initialise LED matrix

                MOV             ScrollWait, #ScrollDelay
                SETB            EA                ; Enable all interrupts

                CALL            Timer0_Start
$IF     (SERIAL_Enable)
TXPrompt:
                MOV             DPTR, #cPrompt
                CALL            {SERIAL}_TX_Code
$ENDIF ; SERIAL_Enable
                SetBank         1
                MOV             R2, #000h         ; Text address low
                MOV             R3, #000h         ; Text address high
                MOV             R7, #1            ; Number of cols left in char
                SetBank         0
                MOV             R2, #00Fh         ; Default to white (Blue)
                MOV             R3, #0FFh         ; (Green/Red)
Executive:
                JBC             LED_NewFrame, NextFrame   ; Next frame flag?
$IF     (SERIAL_Enable)
                JBC             {SERIAL}_RXed, ProcessCmd ; Next command flag? Clear!
$ENDIF ; SERIAL_Enable
                GoToSleep               ; Nothing to do until next interrupt
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Call to generate next frame.
; This function:
; 0) Doesn't always do something - ScrollWait has to count down to zero first.
; 1) If in the middle of a character, go to 6)
; 2) Read the next byte from the Text area in Flash.
; 3) If the byte is NUL:
;    a) If the Text table is empty, it does nothing (keeps displaying the logo);
;    b) Otherwise it starts the Text table again.
; 4) If the MSb if the byte is set, it's a Control byte:
;    At the moment, the only control byte is for colour selection.
;    Others could include invert or flash - but until then...
;    a) Colour is stored in four nybbles:
;       <#0Fh><B><G><R>
;       #0Fh is the Ctrl code for Colour, while B, G and R have the values 0-F.
; 5) Otherwise the byte is a Text byte. Use byte to index into Font table.
;    The first byte of each character in the Font is its Length:
;    a) If the Length is non-zero, then that's the number of column patterns.
;       It also means that a Spacer column should be used first.
;    b) If the Length is zero, then no Spacer column should be used.
;       Also, the Length should be considered 7.
; 6) Read next column's bit pattern from the Font table.
; 7) Scroll Matrix left, setting new bit pattern in the vacated column.
NextFrame:
                DJNZ            ScrollWait, Executive
                MOV             ScrollWait, #ScrollDelay

                SetBank         1

                CLR             F0                ; Assume normal column
                DJNZ            R7, NextFrame_Byte; End of columns?
                SETB            F0                ; Yes, so NOT normal column!
                MOV             DPH, R3           ; Get address of text
                MOV             DPL, R2
NextFrame_Read:
                CALL            Flash_Read        ; Get byte
                JNZ             NextFrame_Ctrl    ; Check not NUL
                MOV             A, DPH            ; Test if DPTR is zero...
                ORL             A, DPL
                JNZ             NextFrame_Restart ; Nope, so restart
                MOV             R7, #1            ; Yep, so only show Logo
                SetBank         0

                SJMP            Executive

NextFrame_Restart:
                MOV             DPTR, #00000h     ; Restart Text
                SJMP            NextFrame_Read    ; Try again

NextFrame_Ctrl:
                INC             DPTR              ; Next byte
                JNB             ACC.7, NextFrame_Text ; Not a control byte?

                ANL             A, #00Fh          ; Isolate Blue
                MOV             2, A              ; Save in Bank 0's R2 (Blue)

                CALL            Flash_Read        ; Get next colour byte
                INC             DPTR              ; Next byte
                MOV             3, A              ; Save in Bank 0's R3 (Green/Red)
                SJMP            NextFrame_Read    ; Go back to read next byte

NextFrame_Text:
                MOV             R3, DPH           ; Save away
                MOV             R2, DPL
$IF     (SERIAL_Enable)
                CALL            {SERIAL}_TX_Char
$ENDIF ; SERIAL_Enable

; Convert character in A into offset in Font table. This is effectively a SHL 3,
; but it's a 7-bit quantity so needs some 8-to-16 bit arithmetic.
                MOV             R1, #HIGH(aFONT_Table)
;               SUBB            A, #' '           ; Requires C to be clear!
                ADD             A, #-' '          ; First 020h chars not tabled
                JNC             NextFrame_Read    ; Below space! Retry!
                ADD             A, ACC            ; No carry-in shift left
;               JNC             NextFrame_FontHi  ; Note this code isn't needed
;               INC             R1                ; The original top bit IS zero
;               INC             R1
;               INC             R1
;               INC             R1
;NextFrame_FontHi:
                ADD             A, ACC            ; No carry-in shift left
                JNC             NextFrame_FontMid
                INC             R1
                INC             R1
NextFrame_FontMid:
                ADD             A, ACC            ; No carry-in shift left
                JNC             NextFrame_FontLo
                INC             R1
NextFrame_FontLo:
                MOV             R0, A

NextFrame_Byte:
                MOV             DPH, R1           ; Pointer to Font table
NextFrame_Col:
                MOV             DPL, R0           ; Pointer to Font entry byte
                INC             R0                ; Next byte for next time
                CLR             A                 ; No offset required
                MOVC            A, @A+DPTR        ; Get Length byte from Font
                JNB             F0, NextFrame_Scroll ; Normal column? Use it

                JNZ             NextFrame_Spacer  ; Valid length? Use as Spacer
                MOV             R7, #7            ; Invalid length. No Spacer
                CLR             F0                ; Back to normal column
                SJMP            NextFrame_Col     ; Immediately show next column

NextFrame_Spacer:
                INC             A                 ; Account for Spacer
                MOV             R7, A             ; Save Length byte into R7
                CLR             A                 ; Spacing column
NextFrame_Scroll:
                SetBank         0
                CALL            LED_Scroll

                SJMP            Executive         ; Start again
;===============================================================================
                END
