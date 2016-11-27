;
; Options.inc
; This file defines which way the code should operate:
; * Which modules to Enable
; * How different BOARDs work - and the resultant constants
; * How different UPDATEs work - and the resultant constants
;

$IF  (NOT OPTIONS_INC)
$SET (OPTIONS_INC)

                $INCLUDE        (John.inc)

;$SET (INT0_Enable)             ; Set to enable Externel Int 0 code
;$SET (INT1_Enable)             ; Set to enable External Int 1 code
$SET (TIMER0_Enable)            ; Set to enable Timer0 code
;$SET (TIMER1_Enable)           ; Set to enable Timer1 code
$SET (BAUD_Enable)              ; Set to enable Baud Rate Generator
;$SET (UART_Enable)             ; Set to enable UART code
;$SET (UART2_Enable)            ; Set to enable UART2 code
;   $SET (UART2_Alt)            ; Set to move UART2 to alternate pins
;$SET (ADC_Enable)              ; Set to enable Analog-digital converter code
;$SET (LVD_Enable)              ; Set to enable Low-Voltage Detect code
;$SET (PCA_Enable)              ; Set to enable Programmable Counter code
;$SET (SPI_Enable)              ; Set to enable Serial Peripheral Interface code
$SET (FLASH_Enable)             ; Set to enable Flash memory code

;$SET (DIGIPOT_Enable)          ; Set to enable DigiPot code
$SET (LED8X8_Enable)            ; Set to enable LED 8x8 matrix code

; Need to select a CPU Frequency. To avoid 32-bit arithmetic, it's factored down
CPU_11059200    EQU             21600   ; 11.0592 MHz in 512 Hz steps
CPU_33177600    EQU             64800   ; 33.1776 MHz in 512 Hz steps
;CPU_Freq       EQU             CPU_33177600 ; Example

; Different interrups have different priorities
INT_Priority_0  EQU             00b     ; Lowest priority
INT_Priority_1  EQU             01b
INT_Priority_2  EQU             10b
INT_Priority_3  EQU             11b     ; Highest priority
;TIMER0_Priority EQU             INT_Priority_3 ; Examples
;TIMER1_Priority EQU             INT_Priority_0
;UART_Priority   EQU             INT_Priority_2
;UART2_Priority  EQU             INT_Priority_2

; The two Timers can be in different Modes - but if Timer0 is in Timer_Mode_8,
; then so will Timer1! (If only Timer1 is, then it is disabled.)
TIMER_Mode_13   EQU             000b    ; 13-bit timer/counter
TIMER_Mode_16   EQU             001b    ; 16-bit timer/counter
TIMER_Mode_8_Auto EQU           010b    ; 8-bit timer/counter, auto-reloaded
TIMER_Mode_8    EQU             011b    ; 2x8_bit timer/counters
TIMER_Mode_x12  EQU             100b    ; Mask to indicate x12 mode
;TIMER0_Mode    EQU             TIMER_Mode_x12+TIMER_Mode_8_Auto ; Example
;TIMER1_Mode    EQU             TIMER_Mode_16                    ; Example

; This is the rate of the Baud Rate Timer. It's factored down to avoid 32 bits
BAUD_x1         EQU             08000h ; Mask to flag to NOT use x12
BAUD_75         EQU             BAUD_x1 + 75
BAUD_150        EQU             BAUD_x1 + 150
BAUD_300        EQU             BAUD_x1 + 300
BAUD_600        EQU             BAUD_x1 + 600
BAUD_1200       EQU                75 ;   1,200 baud in 16 Hz steps
BAUD_2400       EQU               150 ;   2,400 baud in 16 Hz steps
BAUD_4800       EQU               300 ;   4,800 baud in 16 Hz steps
BAUD_9600       EQU               600 ;   9,600 baud in 16 Hz steps
BAUD_19200      EQU              1200 ;  19,200 baud in 16 Hz steps
BAUD_38400      EQU              2400 ;  38,400 baud in 16 Hz steps
BAUD_57600      EQU              3600 ;  57,600 baud in 16 Hz steps
BAUD_115200     EQU              7200 ; 115,200 baud in 16 Hz steps
BAUD_345600     EQU             21600 ; 345,600 baud in 16 Hz steps
;BAUD_Rate      EQU             BAUD_115200 ; Example

UART_Mode_x2     EQU            080h  ; Mask to double UART baud rate (not 000b)
UART_Mode_BRG    EQU            040h  ; Mask to use BRG, not Timer1  (not UART2)
UART_Mode_8Shift EQU            0000b
UART_Mode_8Var   EQU            0010b
UART_Mode_9Shift EQU            0100b
UART_Mode_9Var   EQU            0110b
UART_Mode_Frame  EQU            0001b ; Mask to enable Frame Error Checking
UART_Mode_Mask   EQU            0111b
;UART_Mode       EQU            UART_Mode_BRG+UART_Mode_8Var ; Examples
;UART2_Mode      EQU            UART_Mode_x2+UART_Mode_8Var+UART_Mode_Frame

; There are three boards:
; * BOARD_PLCC40 has no LED, and only one single DigiPot;
; * BOARD_DigiPot has digital potentiometers;
; * BOARD_Resistor has fixed resistors.
; Other than the obvious, the differences are:
; * For testing purposes, spare Ports on the PLCC40 version are used for LEDs;
; * For board layout reasons, Cathodes and Anodes are on different I/O ports;
; * The boards boards use different clocks (CPU_Freq, in 512*Hz).
BOARD_PLCC40    EQU             0
BOARD_DigiPot   EQU             1
BOARD_Resistor  EQU             2

BOARD           EQU             BOARD_PLCC40
TIMER0_Mode     EQU             TIMER_Mode_x12+TIMER_Mode_8_Auto
TIMER0_Priority EQU             INT_Priority_3
BAUD_Rate       EQU             BAUD_115200

IF     (BOARD=BOARD_PLCC40)
   SERIAL       LIT             'UART2'
   $SET     (UART2_Enable)
   ;$SET    (UART2_Alt)
   $SET     (DIGIPOT_Enable)
   CPU_Freq          EQU        CPU_11059200
   {SERIAL}_Priority EQU        INT_Priority_2
   UART2_Mode        EQU        UART_Mode_x2 + UART_Mode_8Var
ELSEIF (BOARD=BOARD_DigiPot)
   SERIAL       LIT             'UART2'
   $SET     (UART2_Enable)
   $SET     (UART2_Alt)
   $SET     (DIGIPOT_Enable)
   CPU_Freq          EQU        CPU_33177600
   {SERIAL}_Priority EQU        INT_Priority_2
   UART2_Mode        EQU        UART_Mode_8Var
ELSEIF (BOARD=BOARD_Resistor)
   SERIAL       LIT             'UART'
   $SET     (UART_Enable)
   CPU_Freq          EQU        CPU_11059200
   {SERIAL}_Priority EQU        INT_Priority_2
   UART_Mode         EQU        UART_Mode_BRG + UART_Mode_8Var
ELSE
   __ERROR__       "BOARD unknown!"
ENDIF

; * A "cycle" is a single count downwards of the LED value(s) - one PWM cycle.
;   - This is embodied in a single interrupt - whatever the interrupt does.
; * A "frame" is an update of the entire matrix.
;   - For persistence of vision, there have to be many Frames Per Second (FPS).
;   - Depending on colour depth (bits per colour(LED): 1/2/4/6/8), that could be
;     1, 4, 16, 64 or 256 cycles (interrupts) per LED per frame (grouped as
;     configured).
FPS             EQU             24 ; Frames Per Second. Sets the interrupt rate.
                                   ; Note that the timer could use x12 mode...

; There are five ways to update the individual RGB pixels (some with options):
; 0) Each cycle, update the whole frame.
;    * There aren't enough individual I/Os for that - there'd need to be 192!
;    * And, the LED Matrix isn't designed that way.
;    * There would need to be FPS*Cycle interrupts per second.
; 1) Each cycle, update one whole row (All the colours of each pixel).
;    * This would have up to 24 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 0.833 mA.
;    * There needs to be FPS*Cycle*8 interrupts per second.
;      Assuming 24 FPS and 256 colours, that's 49,152 interrupts per second!
; 2) Each cycle, update one colour in each row (All the Blues, Greens or Reds).
;    * This would have up to 8 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 2.5 mA.
;    * There needs to be FPS*Cycle*8*3 interrupts per second.
;      Assuming 24 FPS and 256 colours, that's 147,456 interrupts per second!
;    * Note that either:
;      a) Each colour in one row is updated before the next row is started;
;      b) Each colour in all rows is updated before the next colour is started.
; 3) Each cycle, update one pixel in each row (Its Blue, Green and Red).
;    * This would have up to 3 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 6.66 mA.
;    * There needs to be FPS*Cycle*8*8 interrupts per second.
;      Assuming 24 FPS and 256 colours, that's 393,216 interrupts per second!
; 4) Each cycle, update one LED in each row.
;    * This would have up to 1 LED lit at once.
;      Given a 120mA chip maximum with a per-pin 20 mA, each LED can use a
;      maximum of 20 mA.
;    * There needs to be FPS*Cycle*8*8*3 interrupts per second.
;      Assuming 24 FPS and 256 colours, that's 1,179,648 interrupts per second!
;    * Note that either:
;      a) Each colour in one pixel is updated before the next pixel is started;
;      b) Each colour in one row of pixels is updated before the next row is
;         started;
;      c) One colour in all the pixels is updated before the next colour is
;         started.
;
; Since different options require different LED currents, each option defines
; its own OHMS, for both Anode and Red - Green and Blue have similar voltage
; drops, while Red has less.

; The representation of the different modes is expressed in bits as follows:
; * There are three bits: Row, Pixel and LED;
;   * If the Row bit is set, then the whole Row changes (one or all colours);
;   * If neither the Pixel or LED bit is set, then all three colours change;
;   * If the Pixel bit is set, then the Pixel, not Colour, changes per cycle;
;   * If the LED bit is set, then the Colour is changed before the Row is.
;
; The bits are as follows:
; ROW : PIXEL : LED | Interpretation                                    (# LEDs)
;-----+-------+-----+-----------------------------------------------------------
;  0  :   0   :  0  | One Pixel changes per cycle (BGR0.0,BGR0.1,)           (3)
;  0  :   0   :  1  | One Colour changes per cycle (B0.0,G0.0,R0.0,B0.1,)    (1)
;  0  :   1   :  0  | One LED changes per cycle (B0.0,B0.1,..,B1.0,B1.1,)    (1)
;  0  :   1   :  1  | One LED changes per cycle (B0.0,B0.1,..,G0.0,G0.1,)    (1)
;  1  :   0   :  0  | One whole Row changes per cycle (BGR0.01234567,)     (8*3)
;  1  :   0   :  1  | One Colour each Row changes per cycle (B0.0-7,G0.0-7,) (8)
;  1  :   1   :  0  | One Colour per Row changes per cycle (B0.0-7,B1.0-7,)  (8)
;  1  :   1   :  1  | One Frame changes per cycle (not possible!)         (192!)

UPDATE_Pixel      EQU           000b    ; BGR0.0,BGR0.1,BGR0.2,...           (3)
UPDATE_LED_Pixel  EQU           001b    ; B0.0,G0.0,R0.0,...                 (1)
UPDATE_LED_Colour EQU           010b    ; B0.0,B0.1,...,B1.0,B1.1,...        (1)
UPDATE_LED_Row    EQU           011b    ; B0.0,B0.1,...,G0.0,G0.1,...        (1)
UPDATE_Row_Pixel  EQU           100b    ; BGR0.01234567,...                 (24)
UPDATE_Row_LED    EQU           101b    ; B0.01234567,G0.01234567,...        (8)
UPDATE_Row_Colour EQU           110b    ; B0.01234567,B1.01234567,...        (8)
UPDATE_Row_Frame  EQU           111b    ;                                 (192!)

UPDATE          EQU             UPDATE_Row_Pixel

FPS_Rate_Row    EQU             8
FPS_Rate_Colour EQU             8*3
FPS_Rate_Pixel  EQU             8*8
FPS_Rate_LED    EQU             8*8*3

IF     (UPDATE=UPDATE_Pixel)
FPS_Rate        EQU             FPS_Rate_Pixel
ELSEIF (UPDATE=UPDATE_LED_Pixel)
FPS_Rate        EQU             FPS_Rate_LED
ELSEIF (UPDATE=UPDATE_LED_Colour)
FPS_Rate        EQU             FPS_Rate_LED
ELSEIF (UPDATE=UPDATE_LED_Row)
FPS_Rate        EQU             FPS_Rate_LED
ELSEIF (UPDATE=UPDATE_Row_Pixel)
FPS_Rate        EQU             FPS_Rate_Row
ELSEIF (UPDATE=UPDATE_Row_LED)
FPS_Rate        EQU             FPS_Rate_Colour
ELSEIF (UPDATE=UPDATE_Row_Colour)
FPS_Rate        EQU             FPS_Rate_Colour
ELSE
__ERROR__       "UPDATE invalid!"
ENDIF

$ENDIF ; OPTIONS_INC
