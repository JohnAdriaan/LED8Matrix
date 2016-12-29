;
; LED8x8.a51
;
; Given that there are multiple UPDATE options (see Options.inc), there are two
; mechanisms that I could use:
; * UPDATE is bit-clever, so the Update routine could test the different bits to
;   decide what to do. The problem is that that uses CPU cycles inside the
;   interrupt to work out what to do (as opposed to cycles to determine which
;   interrupt to vector off) - but the code could be smaller!
; * The alternative is to quickly vector off the current UPDATE to specific
;   routines, written to carefully maintain state within the register bank from
;   interrupt to interrupt. Cute - I just need to remember to initialise the
;   variables when changing UPDATE.
; My concern is that I have a 2,048-byte code limit. When I add a font table I'm
; going to blow that. Of course, there are techniques that I could use to burn
; the font table independent of the code. Hmmm...
;

                NAME            LED8x8

                $INCLUDE        (Options.inc)

$IF (LED8X8_Enable)

                $INCLUDE        (PSW.inc)
                $INCLUDE        (IE.inc)
                $INCLUDE        (P0.inc)
                $INCLUDE        (P1.inc)
                $INCLUDE        (P2.inc)
                $INCLUDE        (P3.inc)
                $INCLUDE        (AUXR1.inc)       ; For DPTR1

nBytesPerPixel  EQU             2
nColours        EQU             3 ; Blue, Green, Red
nColumns        EQU             8
nRows           EQU             8
nBytesPerRow    EQU             nColumns * nBytesPerPixel
nLEDsPerRow     EQU             nColumns * nColours
nPixels         EQU             nColumns * nRows
nLEDs           EQU             nLEDsPerRow * nRows
nBytes          EQU             nBytesPerRow * nRows

LEDBank         EQU             3  ; Register bank used in LED interrupt

LEDIndex        EQU             R0 ; Current pointer into PWM area
                SFR rLEDIndex = LEDBank*8 + 0

LEDMask         EQU             R2 ; Current mask value

LEDColour       EQU             R3 ; Current LED colour
                SFR rLEDColour = LEDBank*8 + 3
   LEDBlue      EQU             0
   LEDGreen     EQU             1
   LEDRed       EQU             2

LEDIntense      EQU             R4 ; Current intensity value
                SFR rLEDIntense = LEDBank*8 + 4

LEDRow          EQU             R5 ; Current LED Row mask
                SFR rLEDRow   = LEDBank*8 + 5

LEDAnode        EQU             R6 ; Current Anode
                SFR rLEDAnode = LEDBank*8 + 6

LEDCycle        EQU             R7 ; Where we are in the countdown
                SFR rLEDCycle = LEDBank*8 + 7

NumCycles       EQU             16

IF     (BOARD=BOARD_PLCC40)
                SFR   pAnode  = pP2  ; 0A0h
                SFR   pBlue   = pP1  ; 090h
                SFR   pGreen  = pP0  ; 080h
                SFR   pRed    = pP3  ; 0B0h
ELSEIF (BOARD=BOARD_DigiPot)
                SFR   pAnode  = pP0  ; 080h
                SFR   pBlue   = pP3  ; 0B0h
                SFR   pGreen  = pP2  ; 0A0h
                SFR   pRed    = pP1  ; 090h
ELSEIF (BOARD=BOARD_Resistor)
                SFR   pAnode  = pP2  ; 0A0h
                SFR   pBlue   = pP1  ; 090h
                SFR   pGreen  = pP0  ; 080h
                SFR   pRed    = pP3  ; 0B0h
ELSE
__ERROR__       "BOARD unknown!"
ENDIF

                PUBLIC          LED_Init
                PUBLIC          LED_Reset
                PUBLIC          LED_Scroll
                PUBLIC          LED_NewFrame
                PUBLIC          Timer0_Handler

;===============================================================================
LED_Bits        SEGMENT         BIT
                RSEG            LED_Bits

LED_NewFrame:   DBIT            1                 ; Set when Frame buffer ready
LED_FrameDone:  DBIT            1                 ; Set when Frame buffer done

;===============================================================================
LED_PWM         SEGMENT         XDATA AT 00000h
                RSEG            LED_PWM

aPWM:           DSB             nBytes            ; Pixel: XXXXBBBBGGGGRRRR
aFrame:         DSB             nBytes

;===============================================================================
LED_Code        SEGMENT         CODE
                RSEG            LED_Code

LED_Init:
                ACALL           InitFrame
LED_Reset:
                ACALL           InitVars
                ACALL           InitIO
                RET

;-------------------------------------------------------------------------------
InitFrame:
                MOV             DPTR, #aFrame     ; Store in the Frame area

                MOV             R0, #cLogo - LogoOffset ; Start offset
                MOV             R7, #nLogoSize    ; Number of Logo bytes
InitFrameLoop:
                MOV             A, R0             ; Get current offset
                MOVC            A, @A+PC          ; Weird PC-relative indexing
LogoOffset:                                       ; (Base to offset from)

                SETB            F0                ; Flag which nybble to do
InitNybbleLoop:
                RLC             A                 ; Get Intensity bit into Carry
                MOV             R2, A             ; Save value away
                MOV             A, #00Fh          ; Full intensity
                JC              InitSetNybble     ; Yes!
                RRC             A                 ; Half intensity (C is 0...)
InitSetNybble:
                XCH             A, R2             ; Swap back, and save intensity

                RLC             A                 ; Get Blue bit into Carry
                MOV             R1, A             ; Save away - need A!

                MOV             A, R2             ; Get intensity
                JC              InitBlue
                CLR             A                 ; Nope! Blue is off!
InitBlue:
                MOVX            @DPTR, A          ; Store Blue
                INC             DPTR

                MOV             A, R1             ; Restore current bit value
                RLC             A                 ; Get Green bit into Carry
                MOV             R1, A             ; Save away - need A!

                MOV             A, R2             ; Get intensity
                JC              InitGreen
                CLR             A                 ; Nope! Green is off!
InitGreen:
                SWAP            A                 ; Get nybble high
                MOV             R3, A             ; Save Green

                MOV             A, R1             ; Restore current bit value
                RLC             A                 ; Get Red bit into Carry
                MOV             R1, A             ; Save away - need A!

                MOV             A, R2             ; Get intensity
                JC              InitRed
                CLR             A                 ; Nope! Red is off!
InitRed:
                ORL             A, R3             ; Or in Green
                MOVX            @DPTR, A          ; Store Green and Red
                INC             DPTR

                MOV             A, R1
                JBC             F0, InitNybbleLoop ; Go around for next nybble?

                INC             R0                ; Next byte in Logo
                DJNZ            R7, InitFrameLoop

                RET

; Bitmap:
; * Top to bottom;
; * 4 bits per pixel (IBGR);
; * MSn to LSn=left to right
cLogo:
                DB              044h, 044h, 0D9h, 0D4h
                DB              044h, 0DDh, 000h, 00Dh
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              0D0h, 000h, 000h, 0D4h
                DB              04Dh, 00Dh, 000h, 00Dh
                DB              044h, 0DDh, 000h, 00Dh
                DB              044h, 044h, 0D9h, 0D4h
                DB              044h, 044h, 044h, 044h
nLogoSize       EQU             $-cLogo

;...............................................................................
InitVars:
                CLR             LED_NewFrame          ; Can't generate new frame yet
                SETB            LED_FrameDone         ; But Logo has been set
                MOV             rLEDColour, #LEDBlue  ; Start with Blue
                MOV             rLEDAnode, #00000001b ; Start at first Anode
                MOV             rLEDIndex, #nBytes    ; Pretend finished frame
                MOV             rLEDCycle, #1         ; Pretend at last cycle
                RET

;...............................................................................
InitIO:
                CLR             A               ; 000h
                MOV             pAnode, A       ; Anodes off

                ; Push/Pull is rPxM1=0...
;               MOV             rP0M1, A
;               MOV             rP2M1, A
;               MOV             rP1M1, A
;               MOV             rP3M1, A

                ; ...and rPxM0=1
                CPL             A               ; 0FFh
                MOV             rP0M0, A
                MOV             rP2M0, A
                MOV             rP1M0, A
                MOV             rP3M0, A

                ; Set all Cathodes high (LEDs off)
;               MOV             pRed,   A
;               MOV             pGreen, A
;               MOV             pBlue,  A

                RET
;-------------------------------------------------------------------------------
LED_Scroll:
; Scroll Frame buffer one pixel left.
; Fill new column with bits in A (LSb on top).
; If bit is a 1, use colour bytes in R2 (blue) and R3 (green/red)
; Modifies A, DPTR, R0, R1, R5, R6, R7
                MOV             DPTR, #aFrame     ; Start of Frame buffer

                MOV             R5, A             ; Save bits to scroll in
                MOV             R7, #nRows        ; Number of rows to scroll
LED_ScrollRow:
                MOV             R0, DPL           ; Destination
                INC             DPTR
                INC             DPTR
                MOV             R1, DPL           ; Source

                MOV             R6, #(nColumns-1)*2 ; Number of raw bytes
LED_ScrollCol:
                MOV             DPL, R1           ; Source
                MOVX            A, @DPTR          ; Get colour value
                MOV             DPL, R0           ; Destination
                MOVX            @DPTR, A          ; Store colour value
                INC             R1                ; Next source
                INC             R0                ; Next destination
                DJNZ            R6, LED_ScrollCol ; Next column

                MOV             DPL, R0           ; Now to fill last column
                MOV             A, R5             ; Restore bits to scroll in
                RRC             A                 ; Get bit into Carry
                MOV             R5, A             ; Save for next time

                CLR             A                 ; Assume storing zero
                JNC             LED_ScrollBlue
                MOV             A, R2             ; Nope: storing colour
LED_ScrollBlue:
                MOVX            @DPTR, A
                INC             DPTR

                JNC             LED_ScrollGR
                MOV             A, R3             ; Store colour
LED_ScrollGR:
                MOVX            @DPTR, A
                INC             DPTR

                DJNZ            R7, LED_ScrollRow ; Next row
                SETB            LED_FrameDone     ; Mark for copying
                RET
;-------------------------------------------------------------------------------
Timer0_Handler:                                   ; PSW and ACC saved
                SetBank         LEDBank           ; Use this register bank
                PUSH            DPL               ; Need these registers too...
                PUSH            DPH
                MOV             DPH, #000h        ; PWM area

; UpdateRowLED (URL_)
; One Colour each Row changes per cycle (B0.0-7,G0.0-7,) (8)
                CJNE            LEDIndex, #nBytes, URL_Cycle ; End PWM buffer?
                MOV             LEDIndex, #aPWM             ; Restart LEDIndex

                DJNZ            LEDCycle, URL_Cycle   ; Still in current cycle?
                MOV             LEDCycle, #NumCycles        ; Next cycle

                ; New frame started! Copy frame across?
                JNB             LED_FrameDone, URL_Cycle    ; New frame to copy?
                ACALL           CopyFrame                   ; Yes, so copy it

URL_Cycle:
                MOV             DPL, LEDIndex     ; Current index into PWM
                MOV             LEDRow, #0FFh     ; All bits off (Cathode!)

                MOV             A, #00000001b     ; Start LEDMask value
URL_LEDLoop:
                MOV             LEDMask, A        ; Save shifted value

                MOV             A, LEDCycle       ; Use LEDCycle for Intensity
                ADD             A, #cIntensity-IntenseOffset-1 ; -1 because 1-16
                MOVC            A, @A+PC          ; Weird PC-relative indexing
IntenseOffset:                                    ; (Base to Offset from)

                MOV             LEDIntense, A     ; Save away

                MOVX            A, @DPTR          ; Get current LED value
                CJNE            LEDColour, #LEDGreen, URL_NotGreen
                SWAP            A                 ; Only Green is high nybble
URL_NotGreen:
                ANL             A, #00Fh          ; Isolate intensity nybble
                JNB             ACC.3, URL_Low    ; Intensity > 7?
                XRL             A, #00Fh          ; Yes, so 15-Intensity
                XRL             rLEDIntense, #0FFh; And complement mask

URL_Low:
                ADD             A, #cShift-ShiftOffset
                MOVC            A, @A+PC          ; Weird PC-relative indexing
ShiftOffset:                                      ; (Base to Offset from)

                ANL             A, LEDIntense     ; Test bit in LEDIntense
                JZ              URL_LEDNext       ; After all that, no LED!

                MOV             A, LEDMask        ; Where are we in the mask?
                XRL             rLEDRow, A        ; Illuminate this LED in Row
URL_LEDNext:
                INC             DPTR              ; Move to next colour byte
                INC             DPTR              ; of the same colour

                MOV             A, LEDMask        ; Where are we in the mask?
                ADD             A, ACC            ; A no-carry-in shift left
                JNC             URL_LEDLoop       ; Still more to do

                CJNE            LEDColour, #LEDRed, URL_TestGreen
URL_SetRed:
                MOV             A, LEDIndex       ; Need to go to next row
                ADD             A, #nBytesPerRow-1; Next block of bytes
                MOV             LEDIndex, A       ; Back into LEDIndex
                MOV             pGreen, #0FFh     ; Clear Green row
                MOV             pRed, LEDRow      ; Set Red row
                MOV             LEDColour, #LEDBlue ; Restart at Blue
                SJMP            Timer0_Exit

URL_TestGreen:
                INC             LEDColour         ; Next colour - watch out!
                CJNE            LEDColour, #LEDGreen+1, URL_SetBlue ; Incremented
URL_SetGreen:
                MOV             pBlue, #0FFh      ; Clear Blue row
                MOV             pGreen, LEDRow    ; Set Green row
                SJMP            Timer0_Exit
URL_SetBlue:
                INC             LEDIndex          ; Next time use next byte
                MOV             A, LEDAnode       ; Get new LEDAnode
                MOV             pRed, #0FFh       ; Need to clear Red before anode
                MOV             pAnode, A         ; Set new anode
                MOV             pBlue, LEDRow     ; Set Blue row
                RL              A                 ; Change which Anode
                MOV             LEDAnode, A       ; Remember for next time
;               SJMP            Timer0_Exit
Timer0_Exit:
                POP             DPH               ; Restore these
                POP             DPL
                RET                               ; And finished!

; Since there's no barrel shifter, counted rotates are expensive!
; Use a lookup table instead to get the mask
cShift:
                DB              00000001b, 00000010b, 00000100b, 00001000b
                DB              00010000b, 00100000b, 01000000b, 10000000b
cIntensity:
; This table maps current LEDCycle (16-1) to Intensity (0-F).
; If Intensity is >7, use (15-Intensity) and complement the value.
; Bit #Intensity is whether to illuminate the LED or not
                DB              00000000b ; # 1
                DB              00000000b ; # 2
                DB              11000000b ; # 3
                DB              00110000b ; # 4
                DB              10000000b ; # 5
                DB              01001000b ; # 6
                DB              10100000b ; # 7
                DB              01010100b ; # 8
                DB              10000000b ; # 9
                DB              00100000b ; #10
                DB              01001000b ; #11
                DB              10010000b ; #12
                DB              00100000b ; #13
                DB              11000000b ; #14
                DB              00000000b ; #15
                DB              11111110b ; #16
;     LEDCycle
;     123456789ABCDEF0
; I
; n 0 0000000000000000
; t 1 0000000000000001
; e 2 0000000100000001
; n 3 0000010000100001
; s 4 0001000100010001
; i 5 0001001001001001
; t 6 0010010100100101
; y 7 0010101010010101
; F-8 are simply the NOT of 0-7

;...............................................................................
; This function copies the Build buffer into the PWM buffer.
; It modifies A, DPTR and R3.
; It also sets the LED_NewFrame flag.
CopyFrame:
;               SETB            EA                ; Allow interrupts during copy
                MOV             DPTR0, #aFrame    ; Source area
                ToggleDPS
                MOV             DPTR1, #aPWM      ; Destination area
                ToggleDPS

                MOV             R3, #nBytes       ; This many bytes
CopyLoop:
                MOVX            A, @DPTR0         ; Get byte to copy
                INC             DPTR0             ; Next source byte
                ToggleDPS
                MOVX            @DPTR1, A         ; Store in PWM area
                INC             DPTR1             ; Next destination byte
                ToggleDPS
                DJNZ            R3, CopyLoop
;               CLR             EA                ; That's enough!

                SETB            LED_NewFrame      ; Set NewFrame flag
                RET
;===============================================================================
$ENDIF
                END
