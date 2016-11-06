;
; Board.inc
; This file defines which way around the code should operate.
;

; There are two boards:
; * BOARD_Resistor has fixed resistors.
; * BOARD_DigiPot has digital potentiometers.
;
; The two are almost identical - except that for board layout reasons,
; they use different I/O ports. Oh, and the DigiPots need to be programmed!

$RESET (BOARD_Resistor)
$SET   (BOARD_DigiPot)
