;
; John.inc
;
; This file holds support definitions for standardisation.
;

$IF  (NOT JOHN_INC)
$SET (JOHN_INC)

$GEN                            ; Enable macro expansions in listings

; This macro defines symbols for all forms of a bit.
; It takes the bit name, the register it's a member of, and the bit position.
; It defines 2 or 3 symbols:
;    bName is the bit position (0-7)
;    Name  is the BIT Reg.bName definition (if bit is addressable)
;    mName is the mask (01b shl bName)
DefineBit       MACRO           Name, Reg, BitNum
b&Name          EQU             BitNum
IF ((Reg AND 007h)=000h) ; Bit directly addressable?
Name            BIT             Reg.b&Name
ENDIF
m&Name          EQU             1b shl b&Name
                ENDM

$ENDIF ; JOHN_INC
