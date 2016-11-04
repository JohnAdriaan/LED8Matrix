;
; WDT.inc
;
; This file defines the WatchDog Timer SFRs and their fields
;

; WatchDog Timer CONTrol Register
                SFR rWDT_CONTR = 0C1h

; Did Watchdog fire?
bWDT_FLAG       EQU             7
mWDT_FLAG       EQU             1 shl bWDT_FLAG

; Enable WatchDog Timer
bEN_WDT         EQU             5
mEN_WDT         EQU             1 shl bEN_WDT

; Clear WatchDog Timer (nice doggy!)
bCLR_WDT        EQU             4
mCLR_WDT        EQU             1 shl bCLR_WDT

; Enable WatchDog Timer during IDLE
bIDLE_WDT       EQU             3
mIDLE_WDT       EQU             1 shl bIDLE_WDT

; Watchdog frequency selector mask
bPS2            EQU             2
mPS2            EQU             1 shl bPS2

bPS1            EQU             1
mPS1            EQU             1 shl bPS1

bPS0            EQU             0
mPS0            EQU             1 shl bPS0

bPS210          EQU             bPS0
mPS210          EQU             mPS2+mPS1+mPS0
