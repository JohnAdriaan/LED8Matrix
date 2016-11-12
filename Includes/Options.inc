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
;
; There are five ways to update the individual RGB pixels:
; 0) Each cycle, update the whole frame.
;    - There aren't enough individual I/Os for that - there'd need to be 192!
;    - And, the LED Matrix isn't designed that way.
;    - There would need to be FPS*Cycle interrupts per second.
; 1) Each cycle, update one whole row (All the colours of each pixel).
;    - This would have up to 24 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 0.833 mA.
;    - There needs to be FPS*Cycle*8 interrupts per second.
; 2) Each cycle, update one colour in each row (All the Blues, Greens or Reds).
;    - This would have up to 8 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 2.5 mA.
;    - There needs to be FPS*Cycle*8*3 interrupts per second.
; 3) Each cycle, update one pixel in each row (Its Blue, Green and Red).
;    - This would have up to 3 LEDs lit at once.
;      Given a 120mA chip maximum (not forgetting that the anode is shared!),
;      with a per-pin 20 mA, each LED can use a maximum of 6.66 mA.
;    - There needs to be FPS*Cycle*8*8 interrupts per second.
; 4) Each cycle, update one LED in each row.
;    - This would have up to 1 LED lit at once.
;      Given a 120mA chip maximum with a per-pin 20 mA, each LED can use a
;      maximum of 20 mA.
;    - There needs to be FPS*Cycle*8*8*3 interrupts per second.
;
; Since different options require different LED currents, each option defines
; its own OHMS, for both Anode and Red - Green and Blue have similar voltage
; drops, while Red has less.

$SET (UPDATE_All   =0) ; Include ALL update mechanisms
$SET (UPDATE_Row   =1)
$SET (UPDATE_Colour=2)
$SET (UPDATE_Pixel =3)
$SET (UPDATE_LED   =4)

$IF (BOARD=BOARD_DigiPot)
   $SET (UPDATE=0) ; Allow all UPDATE mechanisms
$ELSE
   $SET (UPDATE=1) ; Only allow this one (fixed resistor!)
$ENDIF

mV_Red          EQU             1720
mV_Green        EQU             2300
mV_Blue         EQU             2484
mV_Anode        EQU             2300 ; *MIN*imum of mV_Blue and mV_Green
mV_CPU          EQU             5000

; Convert uA to Ohms for the two resistor locations
%*DEFINE (OHMS_Anode(uA)) ((mV_CPU-mV_Anode)*10 / (%uA/100))
%*DEFINE (OHMS_Red(uA))   ((mV_CPU-mV_Anode-mV_Red)*10 / (%uA/100))

PORT_mA         EQU             20
BOARD_mA        EQU             120

; 3*8 LEDs / 6 (Shared Anode+3xCathodes)
PORT_uA_Row     EQU             PORT_mA*100/3/8*10    ; 833
BOARD_uA_Row    EQU             BOARD_mA*100/3/8*10/6 ; 833
OHMS_Anode_Row  EQU             %OHMS_Anode(PORT_uA_Row)
OHMS_Red_Row    EQU             %OHMS_Red(PORT_uA_Row)

; 8 LEDs / 6 (Shared Anode+3xCathodes)
PORT_uA_Colour  EQU             PORT_mA*100/8*10      ; 2500
BOARD_uA_Colour EQU             BOARD_mA*100/8*10/6   ; 2500
OHMS_Anode_Colour EQU           %OHMS_Anode(PORT_uA_Colour)
OHMS_Red_Colour   EQU           %OHMS_Red(PORT_uA_Colour)

; 3 LEDs (Shared Anode+3xCathodes)
PORT_uA_Pixel   EQU             PORT_mA*100*10 /3     ; 6666
BOARD_uA_Pixel  EQU             BOARD_mA*100*10/6     ; 20000
OHMS_Anode_Pixel EQU            %OHMS_Anode(PORT_uA_Pixel)
OHMS_Red_Pixel   EQU            %OHMS_Red(PORT_uA_Pixel)

; 1 LED  (Anode+Cathode)
PORT_uA_LED     EQU             PORT_mA*100*10        ; 20000
BOARD_uA_LED    EQU             BOARD_mA*100*10/2     ; 60000
OHMS_Anode_LED  EQU             %OHMS_Anode(PORT_uA_LED)
OHMS_Red_LED    EQU             %OHMS_Red(PORT_uA_LED)

$IF     (UPDATE=UPDATE_Row)
PORT_uA         EQU             PORT_uA_Row
OHMS_Anode      EQU             OHMS_Anode_Row
OHMS_Red        EQU             OHMS_Red_Row
$ELSEIF (UPDATE=UPDATE_Colour)
PORT_uA         EQU             PORT_uA_Colour
OHMS_Anode      EQU             OHMS_Anode_Colour
OHMS_Red        EQU             OHMS_Red_Colour
$ELSEIF (UPDATE=UPDATE_Pixel)
PORT_uA         EQU             PORT_uA_Pixel
OHMS_Anode      EQU             OHMS_Anode_Pixel
OHMS_Red        EQU             OHMS_Red_Pixel
$ELSEIF (UPDATE=UPDATE_LED)
PORT_uA         EQU             PORT_uA_LED
OHMS_Anode      EQU             OHMS_Anode_LED
OHMS_Red        EQU             OHMS_Red_LED
$ELSEIF (UPDATE=UPDATE_All)
PORT_uA         EQU             PORT_uA_Row       ; Worst-case start value
OHMS_Anode      EQU             OHMS_Anode_Row
OHMS_Red        EQU             OHMS_Red_Row
$ELSE
__ERROR__ "UPDATE not set!"
$ENDIF