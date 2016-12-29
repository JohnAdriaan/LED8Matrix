;
; Font7x6.a51
;

                NAME            Font7x6

                $INCLUDE        (Options.inc)

$IF (FONT7x6_Enable)

Font7x6_Code    SEGMENT         CODE AT aFONT_Table
                RSEG            Font7x6_Code

                ORG             aFONT_Table

; The layout of this table is as follows:
; 1) Every character from ASCII ' ' (020h) to '~'+1 (07Fh) has eight bytes:
;    a) 1 length byte (with a special encoding);
;    b) 1 to 7 column bit patterns;
;    c) 6 to 0 padding bytes (ignored, so set to 0FFh for Flash nicety);
; 2) The first byte is the number of following significant bytes.
;    a) If that first byte is non-zero, then it itself also represents a space
;       column with a value of 000h (not part of the count).
;    b) If that first byte is zero, then it represents no pattern - but a value
;       of 7.
; 3) The subsequent bytes represent column bit patterns for the character. The
;    LSb is the top bit, while the MSb is the bottom bit.
;
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 00h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 01h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 02h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 03h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 04h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 05h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 06h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 07h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 08h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 09h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Ah
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Bh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Ch
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Dh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Eh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 0Fh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 10h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 11h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 12h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 13h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 14h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 15h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 16h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 17h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 18h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 19h
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Ah
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Bh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Ch
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Dh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Eh
;               DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 1Fh
                DB              6, 000h, 000h, 000h, 000h, 000h, 000h, 0FFh ; ' '
                DB              2, 06Fh, 06Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; '!'
                DB              3, 006h, 000h, 006h, 0FFh, 0FFh, 0FFh, 0FFh ; '"'
                DB              5, 014h, 07Fh, 014h, 07Fh, 014h, 0FFh, 0FFh ; '#'
                DB              6, 024h, 02Ah, 07Fh, 07Fh, 02Ah, 012h, 0FFh ; '$'
                DB              7, 042h, 025h, 012h, 008h, 024h, 052h, 021h ; 'Percent'
                DB              6, 036h, 07Fh, 049h, 05Fh, 036h, 050h, 0FFh ; '&'
                DB              3, 004h, 007h, 003h, 0FFh, 0FFh, 0FFh, 0FFh ; '''
                DB              3, 03Ch, 07Eh, 042h, 0FFh, 0FFh, 0FFh, 0FFh ; '('
                DB              3, 042h, 07Eh, 03Ch, 0FFh, 0FFh, 0FFh, 0FFh ; ')'
                DB              7, 049h, 02Ah, 01Ch, 07Fh, 01Ch, 02Ah, 049h ; '*'
                DB              6, 018h, 018h, 07Eh, 07Eh, 018h, 018h, 0FFh ; '+'
                DB              3, 080h, 0E0h, 060h, 0FFh, 0FFh, 0FFh, 0FFh ; ','
                DB              6, 018h, 018h, 018h, 018h, 018h, 018h, 0FFh ; '-'
                DB              2, 060h, 060h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; '.'
                DB              7, 040h, 060h, 030h, 018h, 00Ch, 006h, 003h ; '/'
                DB              6, 03Eh, 07Fh, 051h, 045h, 07Fh, 03Eh, 0FFh ; '0'
                DB              3, 002h, 07Fh, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh ; '1'
                DB              6, 072h, 079h, 049h, 049h, 04Fh, 046h, 0FFh ; '2'
                DB              6, 049h, 049h, 049h, 049h, 07Fh, 036h, 0FFh ; '3'
                DB              6, 00Fh, 00Fh, 008h, 008h, 07Fh, 07Fh, 0FFh ; '4'
                DB              6, 04Fh, 04Fh, 049h, 049h, 079h, 031h, 0FFh ; '5'
                DB              6, 03Eh, 07Fh, 049h, 049h, 079h, 031h, 0FFh ; '6'
                DB              6, 001h, 001h, 079h, 07Dh, 007h, 003h, 0FFh ; '7'
                DB              6, 036h, 07Fh, 049h, 049h, 07Fh, 036h, 0FFh ; '8'
                DB              6, 026h, 06Fh, 049h, 049h, 07Fh, 03Eh, 0FFh ; '9'
                DB              2, 036h, 036h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; ':'
                DB              3, 040h, 076h, 036h, 0FFh, 0FFh, 0FFh, 0FFh ; ';'
                DB              4, 008h, 01Ch, 036h, 022h, 0FFh, 0FFh, 0FFh ; '<'
                DB              6, 036h, 036h, 036h, 036h, 036h, 036h, 0FFh ; '='
                DB              4, 022h, 036h, 01Ch, 008h, 0FFh, 0FFh, 0FFh ; '>'
                DB              6, 004h, 002h, 053h, 05Bh, 00Eh, 004h, 0FFh ; '?'
                DB              6, 03Ch, 042h, 05Ah, 05Ah, 052h, 01Ch, 0FFh ; '@'
                DB              6, 07Eh, 07Fh, 009h, 009h, 07Fh, 07Eh, 0FFh ; 'A'
                DB              6, 07Fh, 07Fh, 049h, 049h, 07Fh, 036h, 0FFh ; 'B'
                DB              6, 03Eh, 07Fh, 041h, 041h, 063h, 022h, 0FFh ; 'C'
                DB              6, 07Fh, 07Fh, 041h, 041h, 07Fh, 03Eh, 0FFh ; 'D'
                DB              6, 07Fh, 07Fh, 049h, 049h, 049h, 041h, 0FFh ; 'E'
                DB              6, 07Fh, 07Fh, 009h, 009h, 001h, 001h, 0FFh ; 'F'
                DB              6, 03Eh, 07Fh, 041h, 049h, 07Bh, 03Ah, 0FFh ; 'G'
                DB              6, 07Fh, 07Fh, 008h, 008h, 07Fh, 07Fh, 0FFh ; 'H'
                DB              4, 041h, 07Fh, 07Fh, 041h, 0FFh, 0FFh, 0FFh ; 'I'
                DB              6, 020h, 060h, 040h, 040h, 07Fh, 03Fh, 0FFh ; 'J'
                DB              6, 07Fh, 07Fh, 01Ch, 036h, 063h, 041h, 0FFh ; 'K'
                DB              6, 07Fh, 07Fh, 040h, 040h, 040h, 040h, 0FFh ; 'L'
                DB              7, 07Fh, 07Fh, 006h, 00Ch, 006h, 07Fh, 07Fh ; 'M'
                DB              6, 07Fh, 07Fh, 006h, 00Ch, 07Fh, 07Fh, 0FFh ; 'N'
                DB              6, 03Eh, 07Fh, 041h, 041h, 07Fh, 03Eh, 0FFh ; 'O'
                DB              6, 07Fh, 07Fh, 009h, 009h, 00Fh, 006h, 0FFh ; 'P'
                DB              6, 03Eh, 07Fh, 041h, 021h, 07Fh, 05Eh, 0FFh ; 'Q'
                DB              6, 07Fh, 07Fh, 019h, 039h, 06Fh, 046h, 0FFh ; 'R'
                DB              6, 026h, 06Fh, 049h, 049h, 07Bh, 032h, 0FFh ; 'S'
                DB              6, 001h, 001h, 07Fh, 07Fh, 001h, 001h, 0FFh ; 'T'
                DB              6, 03Fh, 07Fh, 040h, 040h, 07Fh, 03Fh, 0FFh ; 'U'
                DB              6, 01Fh, 03Fh, 060h, 060h, 03Fh, 01Fh, 0FFh ; 'V'
                DB              7, 03Fh, 07Fh, 060h, 038h, 060h, 07Fh, 07Fh ; 'W'
                DB              6, 063h, 077h, 01Ch, 01Ch, 077h, 063h, 0FFh ; 'X'
                DB              6, 007h, 00Fh, 078h, 078h, 00Fh, 007h, 0FFh ; 'Y'
                DB              6, 061h, 071h, 059h, 04Dh, 047h, 043h, 0FFh ; 'Z'
                DB              4, 07Fh, 07Fh, 041h, 041h, 0FFh, 0FFh, 0FFh ; '['
                DB              7, 003h, 006h, 00Ch, 018h, 030h, 060h, 040h ; '\'
                DB              6, 041h, 041h, 07Fh, 07Fh, 0FFh, 0FFh, 0FFh ; ']'
                DB              5, 004h, 006h, 003h, 006h, 004h, 0FFh, 0FFh ; '^'
                DB              0, 080h, 080h, 080h, 080h, 080h, 080h, 080h ; '_'
                DB              3, 003h, 007h, 004h, 0FFh, 0FFh, 0FFh, 0FFh ; '`'
                DB              6, 020h, 074h, 054h, 054h, 07Ch, 078h, 0FFh ; 'a'
                DB              6, 07Fh, 07Fh, 048h, 048h, 078h, 030h, 0FFh ; 'b'
                DB              6, 038h, 07Ch, 044h, 044h, 06Ch, 028h, 0FFh ; 'c'
                DB              6, 030h, 078h, 048h, 048h, 07Fh, 07Fh, 0FFh ; 'd'
                DB              6, 038h, 07Ch, 054h, 054h, 054h, 058h, 0FFh ; 'e'
                DB              5, 07Eh, 07Fh, 009h, 009h, 001h, 0FFh, 0FFh ; 'f'
                DB              6, 098h, 0BCh, 0A4h, 0A4h, 0FCh, 07Ch, 0FFh ; 'g'
                DB              6, 07Fh, 07Fh, 008h, 008h, 078h, 070h, 0FFh ; 'h'
                DB              2, 07Ah, 07Ah, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 'i'
                DB              5, 060h, 0C0h, 0C0h, 0FAh, 07Ah, 0FFh, 0FFh ; 'j'
                DB              6, 07Fh, 07Fh, 018h, 038h, 06Ch, 044h, 0FFh ; 'k'
                DB              2, 07Fh, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; 'l'
                DB              7, 078h, 07Ch, 00Ch, 078h, 00Ch, 07Ch, 078h ; 'm'
                DB              6, 07Ch, 07Ch, 004h, 004h, 07Ch, 078h, 0FFh ; 'n'
                DB              6, 038h, 07Ch, 044h, 044h, 07Ch, 038h, 0FFh ; 'o'
                DB              6, 0FCh, 0FCh, 024h, 024h, 03Ch, 018h, 0FFh ; 'p'
                DB              6, 018h, 03Ch, 024h, 024h, 0FCh, 0FCh, 0FFh ; 'q'
                DB              6, 07Ch, 07Ch, 018h, 00Ch, 00Ch, 018h, 0FFh ; 'r'
                DB              6, 058h, 05Ch, 054h, 054h, 074h, 034h, 0FFh ; 's'
                DB              4, 008h, 03Eh, 07Eh, 048h, 0FFh, 0FFh, 0FFh ; 't'
                DB              6, 03Ch, 07Ch, 040h, 040h, 07Ch, 07Ch, 0FFh ; 'u'
                DB              6, 01Ch, 03Ch, 060h, 060h, 03Ch, 01Ch, 0FFh ; 'v'
                DB              7, 03Ch, 07Ch, 060h, 078h, 060h, 07Ch, 03Ch ; 'w'
                DB              6, 044h, 06Ch, 038h, 038h, 06Ch, 044h, 0FFh ; 'x'
                DB              6, 04Ch, 09Ch, 0B0h, 0A0h, 0FCh, 07Ch, 0FFh ; 'y'
                DB              6, 044h, 064h, 074h, 05Ch, 04Ch, 044h, 0FFh ; 'z'
                DB              6, 008h, 008h, 03Eh, 077h, 041h, 041h, 0FFh ; '{'
                DB              2, 077h, 077h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; '|'
                DB              6, 041h, 041h, 077h, 03Eh, 008h, 008h, 0FFh ; '}'
                DB              6, 00Ch, 006h, 006h, 00Ch, 00Ch, 006h, 0FFh ; '~'
                DB              0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; ' '
$ENDIF
                END
