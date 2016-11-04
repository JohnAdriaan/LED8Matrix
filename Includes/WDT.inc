;
; WDT.inc
;
; This file defines the WatchDog Timer SFRs and their fields
;

                $INCLUDE        (John.inc)

; WatchDog Timer CONTrol Register
                SFR rWDT_CONTR = 0C1h

DefineBit       WDT_FLAG, rWDT_CONTR, 7 ; Did Watchdog fire?
DefineBit       EN_WDT,   rWDT_CONTR, 5 ; Enable WatchDog Timer
DefineBit       CLR_WDT,  rWDT_CONTR, 4 ; Clear WatchDog Timer (nice doggy!)
DefineBit       IDLE_WDT, rWDT_CONTR, 3 ; Enable WatchDog Timer during IDLE
DefineBit       PS2,      rWDT_CONTR, 2 ; Watchdog frequency selector mask
DefineBit       PS1,      rWDT_CONTR, 1
DefineBit       PS0,      rWDT_CONTR, 0

bPS210          EQU       bPS0
mPS210          EQU       mPS2 + mPS1 + mPS0
