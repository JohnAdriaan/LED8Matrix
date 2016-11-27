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
                $INCLUDE        (PCON.inc)        ; Need Power Control SFRs

                PUBLIC          Reset_ISR         ; Publish this for Vectors

                EXTERN   DATA   (CPU_Stack_Top)
                EXTERN   CODE   (CPU_Init)

                EXTERN   CODE   (Timer0_Init)
                EXTERN   CODE   (Timer0_Set)
                EXTERN   CODE   (Timer0_Start)

                EXTERN   CODE   (Baud_Init)
                EXTERN   CODE   ({SERIAL}_Init)
                EXTERN   BIT    ({SERIAL}_RXed)
                EXTERN   CODE   ({SERIAL}_RX)
                EXTERN   CODE   ({SERIAL}_TX_Num)
                EXTERN   CODE   ({SERIAL}_TX_Char)
                EXTERN   CODE   ({SERIAL}_TX_Code)

                EXTERN   CODE   (Flash_Init)

$IF (DIGIPOT_Enable)
                EXTERN   CODE   (DigiPot_Init)
$ENDIF

                EXTERN   CODE   (LED_Init)
                EXTERN   CODE   (LED_Reset)
                EXTERN   DATA   (LED_Update)
                EXTERN   BIT    (LED_NewFrame)

IF (BOARD=BOARD_PLCC40)
                SFR  pSleep  =  pP1
DefineBit       Eyes, pSleep, 7
ENDIF

;===============================================================================
                USING           3                 ; Inform compiler of Reg Banks
                USING           2
                USING           1
                USING           0
;===============================================================================
Main            SEGMENT         CODE
                RSEG            Main

cPrompt:        DB              "LED8x8> ", 0

Reset_ISR:
                MOV             SP, #CPU_Stack_Top-1 ; Better (upgoing) Stack addr
                CALL            CPU_Init          ; Initialise CPU SFRs
                CALL            Baud_Init         ; Initiaise Baud Rate Timer
                CALL            {SERIAL}_Init     ; Initialise Serial port

                CALL            Timer0_Init       ; Initialise Timer0
                CALL            Flash_Init        ; Initialise Flash
$IF (DIGIPOT_Enable)
                CALL            DigiPot_Init      ; Initialise Digital Pots
$ENDIF
                CALL            LED_Init          ; Initialise LED matrix

                MOV             A, #UPDATE        ; Starting mode
                ACALL           SetUpdate
                CALL            Timer0_Start
                SETB            EA                ; Enable all interrupts
TXPrompt:
                MOV             DPTR, #cPrompt
                CALL            {SERIAL}_TX_Code
Executive:
                JBC             LED_NewFrame, NextFrame   ; Next frame flag? Clear!
                JBC             {SERIAL}_RXed, ProcessCmd ; Next command flag? Clear!
IF (BOARD=BOARD_PLCC40)
                CLR             Eyes              ; Close eyes
ENDIF
                GoToSleep               ; Nothing to do until next interrupt
IF (BOARD=BOARD_PLCC40)
                SETB            Eyes              ; Open eyes
ENDIF
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Called to generate next frame
NextFrame:
                SJMP            Executive         ; Start again

;-------------------------------------------------------------------------------
; Called to process next received command
ProcessCmd:
                CALL            {SERIAL}_RX       ; Get received byte
                CJNE            A, #13, CmdByte
                SJMP            TXPrompt
CmdByte:
                CLR             C                 ; Need zero here
                SUBB            A, #'0'           ; Convert ASCII to byte
                JC              Executive         ; Underflow!
                SUBB            A, #UPDATE_Row_Frame
                JNC             Executive         ; Too big!
                ADD             A, #UPDATE_Row_Frame
                ACALL           SetUpdate
                SJMP            Executive
;===============================================================================
SetUpdate:
                MOV             LED_Update, A
                ADD             A, #cTimer_Table - TimerOffset
                MOVC            A, @A+PC          ; Weird PC-relative index
TimerOffset:

                CALL            Timer0_Set
                RET

; Assumes pixel depth (thus cycle) of 256
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
