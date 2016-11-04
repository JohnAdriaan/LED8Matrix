;
; Board.inc
;

; There are two boards:
; * BOARD #1 has fixed resistors.
; * BOARD #2 has digital potentiometers.
;
; The two are almost identical - except that for architecture reasons,
; they use different I/O ports.

;$SET  (BOARD = 1)
$SET  (BOARD = 2)
