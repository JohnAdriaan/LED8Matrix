;
; WDT.inc
;
; This file defines the WatchDog Timer SFRs and their fields
;

                SFR WDT_CONTR = 0C1h    ; WatchDog Timer CONTrol Register

bWDT_FLAG       EQU             7       ; Did Watchdog fire?
mWDT_FLAG       EQU             1 shl bWDT_FLAG

bEN_WDT         EQU             5       ; Enable WatchDog Timer
mEN_WDT         EQU             1 shl bEN_WDT

bCLR_WDT        EQU             4       ; Clear WatchDog Timer (nice doggy!)
mCLR_WDT        EQU             1 shl bCLR_WDT

bIDLE_WDT       EQU             3       ; Enable WatchDog Timer during IDLE
mIDLE_WDT       EQU             1 shl bIDLE_WDT

bPS2            EQU             2
mPS2            EQU             1 shl bPS2

bPS1            EQU             1
mPS1            EQU             1 shl bPS1

bPS0            EQU             0
mPS0            EQU             1 shl bPS0

mPS210          EQU             mPS2+mPS1+mPS0 ; Watchdog frequency selector mask
