;
; Options.inc
; This file defines which way the code should operate:
; * How different BOARDs work - and the resultant constants
; * How different UPDATEs work - and the resultant constants
;

; There are two boards:
; * BOARD_Resistor has fixed resistors.
; * BOARD_DigiPot has digital potentiometers.
; Other than the obvious, the differences are:
; * For board layout reasons, Cathodes and Anodes are on different I/O ports;
; * The two boards use different clocks (CPU_Freq, in 512*Hz).
$SET (BOARD_Resistor=1)
$SET (BOARD_DigiPot=2)

$SET (BOARD=2)

$IF (BOARD=BOARD_Resistor)
   $SET (CPU_Freq=21600)
$ELSEIF (BOARD=BOARD_DigiPot)
   $SET (CPU_Freq=64800)
$ELSE
   __ERROR__ "BOARD not set!"
$ENDIF

; * A "cycle" is a single count downwards of the LED value(s) - one PWM cycle.
;   - This is embodied in a single interrupt - whatever the interrupt does.
; * A "frame" is an update of the entire matrix.
;   - For persistence of vision, there have to be many frames per second (FPS).
;   - Depending on colour depth (bits per colour(LED): 1/2/4/6/8), that could be
;     1, 4, 16, 64 or 256 cycles (interrupts) per LED per frame (grouped as
;     configured).

$SET (FPS=24)       ; Frames per second. This will dictate the interrupt rate

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
__ERROR__ "UPDATE not set!"
ENDIF
