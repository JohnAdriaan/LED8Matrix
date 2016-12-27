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
                EXTERN   DATA   (LED_Update)
                EXTERN   BIT    (LED_NewFrame)

;===============================================================================
                USING           3                 ; Inform compiler of Reg Banks
                USING           2
                USING           1
                USING           0

MainData        SEGMENT         DATA
                RSEG            MainData

ScrollDelay     EQU             6

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
$IF     (SERIAL_Enable)
$IF     (BAUD_Enable)
                CALL            Baud_Init         ; Initiaise Baud Rate Timer
$ENDIF ; BAUD_Enable
                CALL            {SERIAL}_Init     ; Initialise Serial port
$ENDIF ; SERIAL_Enable

                CALL            Timer0_Init       ; Initialise Timer0
$IF     (FLASH_Enable)
                CALL            Flash_Init        ; Initialise Flash
$ENDIF ; FLASH_Enable
$IF     (DIGIPOT_Enable)
                CALL            DigiPot_Init      ; Initialise Digital Pots
$ENDIF ; DIGIPOT_Enable
                CALL            LED_Init          ; Initialise LED matrix

                MOV             ScrollWait, #ScrollDelay
                MOV             A, #UPDATE        ; Starting mode
                ACALL           SetUpdate
                SETB            EA                ; Enable all interrupts

                CALL            Timer0_Start
$IF     (SERIAL_Enable)
TXPrompt:
                MOV             DPTR, #cPrompt
                CALL            {SERIAL}_TX_Code
$ENDIF ; SERIAL_Enable
                SetBank         1
                MOV             R2, #0000h        ; Text address low
                MOV             R3, #0000h        ; Text address high
                MOV             R7, #1            ; Number of cols left in char
                SetBank         0
                MOV             R2, #0FFh         ; Default to white (blue)
                MOV             R3, #0FFh         ; (green)
                MOV             R4, #0FFh         ; (red)
Executive:
                JBC             LED_NewFrame, NextFrame   ; Next frame flag? Clear!
$IF     (SERIAL_Enable)
                JBC             {SERIAL}_RXed, ProcessCmd ; Next command flag? Clear!
$ENDIF ; SERIAL_Enable
                GoToSleep               ; Nothing to do until next interrupt
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Called to generate next frame
NextFrame:
                DJNZ            ScrollWait, Executive
                MOV             ScrollWait, #ScrollDelay

                SetBank         1

                DJNZ            R7, NextFrame_Col ; End of columns?
                MOV             DPH, R3           ; Yes, so get address of text
                MOV             DPL, R2
NextFrame_Read:
                CALL            Flash_Read        ; Get byte
                JNZ             NextFrame_Ctrl    ; Check not NUL
                MOV             DPTR, #00000h     ; Restart Text
                AJMP            NextFrame_Read    ; Try again
NextFrame_Ctrl:
                INC             DPTR              ; Next byte
                JNB             ACC.7, NextFrame_Text ; Not a control byte?

; At the moment, the only control byte is for colour selection.
; Others could include invert or flash - but until then...
; Colour is stored in four nybbles:
;    <#0Fh><B><G><R>
; #0Fh is the Ctrl code for Colour;
; B, G and R have the values 0-8: the number of bits set in the colour byte.
                ANL             A, #00Fh          ; Isolate Blue
                ADD             A, #NextFrame_Map-NextFrame_Blue
                MOVC            A, @A+PC          ; Map number to bit pattern
NextFrame_Blue:

                MOV             2, A              ; Save in Bank 0's R2 (Blue)

                CALL            Flash_Read        ; Get next colour byte
                INC             DPTR              ; Next byte
                MOV             B, A              ; Save for later
                SWAP            A                 ; Get upper nybble down
                ANL             A, #00Fh          ; Isolate (now) Green
                ADD             A, #NextFrame_Map-NextFrame_Green
                MOVC            A, @A+PC          ; Map number to bit pattern
NextFrame_Green:

                MOV             3, A              ; Save to Bank 0's R3 (Green)
                MOV             A, B              ; Restore saved value
                ANL             A, #00Fh          ; Isolate Red
                ADD             A, #NextFrame_Map-NextFrame_Red
                MOVC            A, @A+PC          ; Map number to bit pattern
NextFrame_Red:

                MOV             4, A              ; Save to Bank 0's R4 (Red)

                AJMP            NextFrame_Read    ; Go back to read next byte
NextFrame_Map:
                DB              000h, 001h, 044h, 094h, 055h, 06Bh, 077h, 0FEh, 0FFh

NextFrame_Text:
                MOV             R3, DPH           ; Save away
                MOV             R2, DPL
$IF     (SERIAL_Enable)
                CALL            {SERIAL}_TX_Char
$ENDIF ; SERIAL_Enable

                MOV             R1, #HIGH(aFONT_Table)
;               SUBB            A, #' '           ; Requires C to be clear!
                ADD             A, #-' '          ; First 020h chars not tabled
                JNC             NextFrame_Read
                ADD             A, ACC            ; No carry-in shift left
;               JNC             NextFrame_FontHi
;               INC             R1
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
                MOV             R7, #8            ; Restart columns

NextFrame_Col:
                MOV             DPH, R1           ; Next column from font
                MOV             DPL, R0
                INC             R0                ; Column for next time
                CLR             A                 ; No offset required
                MOVC            A, @A+DPTR        ; Get next column from font

                SetBank         0
                CALL            LED_Scroll
                SJMP            Executive         ; Start again

$IF    (SERIAL_Enable)
;-------------------------------------------------------------------------------
; Called to process next received command
ProcessCmd:
                CALL            {SERIAL}_RX       ; Get received byte
                CJNE            A, #13, CmdByte
                SJMP            TXPrompt
CmdByte:
;               SUBB            A, #'0'           ; Needs C flag clear!
                ADD             A, #-'0'          ; Convert ASCII to byte
                JNC             Executive         ; Underflow!
;               SUBB            A, #UPDATE_Row_Frame ; Needs C flag clear!
                ADD             A, #-UPDATE_Row_Frame
                JC              Executive         ; Too big!
                ADD             A, #UPDATE_Row_Frame
                ACALL           SetUpdate
                SJMP            Executive
$ENDIF ; SERIAL_Enable
;===============================================================================
SetUpdate:
                MOV             LED_Update, A
                ADD             A, #cTimer_Table - TimerOffset
                MOVC            A, @A+PC          ; Weird PC-relative index
TimerOffset:

                CALL            Timer0_Set
                RET

;                                      /512        /256 = *2
%*DEFINE        (Timer(Rate))   (256 - CPU_Freq/FPS*2/%Rate)
cTimer_Table:
cTimer_Pixel:      DB           %Timer(FPS_Rate_Pixel)  ; 8*8
cTimer_LED_Pixel:  DB           %Timer(FPS_Rate_LED)    ; 8*8*3
cTimer_LED_Colour: DB           %Timer(FPS_Rate_LED)    ; 8*8*3
cTimer_LED_Row:    DB           %Timer(FPS_Rate_LED)    ; 8*8*3
cTimer_Row_Pixel:  DB           %Timer(FPS_Rate_Row)    ; 8
cTimer_Row_LED:    DB           %Timer(FPS_Rate_Colour) ; 8*3
cTimer_Row_Colour: DB           %Timer(FPS_Rate_Colour) ; 8*3

;===============================================================================
                END
