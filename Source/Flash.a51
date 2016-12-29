;
; Flash.a51
;

                NAME            Flash

                $INCLUDE        (Options.inc)

$IF (FLASH_Enable)

                PUBLIC          Flash_Init
                PUBLIC          Flash_Read
                PUBLIC          Flash_Write
                PUBLIC          Flash_Erase

IF     (CPU=CPU_STC12)
IAP_Base        EQU             0C0h
ELSEIF (CPU=CPU_STC89)
IAP_Base        EQU             0E0h
ELSE
__ERROR__ "CPU unknown!"
ENDIF

                SFR rIAP_DATA  = IAP_Base + 02h
                SFR rIAP_ADDRH = IAP_Base + 03h
                SFR rIAP_ADDRL = IAP_Base + 04h

                SFR rIAP_CMD   = IAP_Base + 05h
DefineBit       MS2, rIAP_CMD, 2
DefineBit       MS1, rIAP_CMD, 1
DefineBit       MS0, rIAP_CMD, 0
   bMS          EQU             bMS0    ; Mode shift number
   mMS          EQU            (mMS2 + mMS1 + mMS0) ; Mode mask
IAP_CMD_Standby EQU             000b SHL bMS
IAP_CMD_Read    EQU             001b SHL bMS
IAP_CMD_Write   EQU             010b SHL bMS
IAP_CMD_Erase   EQU             011b SHL bMS

                SFR rIAP_TRIG  = IAP_Base + 06h
IF     (CPU=CPU_STC12)
IAP_Trig0       EQU             046h
IAP_Trig1       EQU             0B9h
ELSEIF (CPU=CPU_STC89)
IAP_Trig0       EQU             05Ah
IAP_Trig1       EQU             0A5h
ELSE
__ERROR__ "CPU unknown!"
ENDIF

                SFR rIAP_CONTR = IAP_Base + 07h
DefineBit       IAPEN,    rIAP_CONTR, 7           ; Global /disable, enable
DefineBit       SWBS,     rIAP_CONTR, 6           ; Boot /memory, ISP
DefineBit       SWRST,    rIAP_CONTR, 5           ; Reset MCU
DefineBit       CMD_FAIL, rIAP_CONTR, 4           ; Command /succeeded, failed
DefineBit       WT2,      rIAP_CONTR, 2
DefineBit       WT1,      rIAP_CONTR, 1
DefineBit       WT0,      rIAP_CONTR, 0
   bWT          EQU             bWT0
   mWT          EQU            (mWT2 + mWT1 + mWT0)

IF     (CPU=CPU_STC12)
IAP_WT_30MHz    EQU             000b SHL bWT
IAP_WT_24MHz    EQU             001b SHL bWT
IAP_WT_20MHz    EQU             010b SHL bWT
IAP_WT_12MHz    EQU             011b SHL bWT
IAP_WT_6MHz     EQU             100b SHL bWT
IAP_WT_3MHz     EQU             101b SHL bWT
IAP_WT_2MHz     EQU             110b SHL bWT
IAP_WT_1MHz     EQU             111b SHL bWT

IAP_WT_11059200Hz EQU           IAP_WT_12MHz
IAP_WT_33177600Hz EQU           IAP_WT_30MHz
ELSEIF (CPU=CPU_STC89)
IAP_WT_40MHz    EQU             000b SHL bWT
IAP_WT_20MHz    EQU             001b SHL bWT
IAP_WT_10MHz    EQU             010b SHL bWT
IAP_WT_5MHz     EQU             011b SHL bWT

IAP_WT_11059200Hz EQU           IAP_WT_20MHz
IAP_WT_33177600Hz EQU           IAP_WT_40MHz
ELSE
__ERROR__ "CPU unknown!"
ENDIF

IF     (Clock_Freq=Clock_11059200)
IAP_WT          EQU             IAP_WT_11059200Hz
ELSEIF (Clock_Freq=Clock_33177600)
IAP_WT          EQU             IAP_WT_33177600MHz
ELSE
__ERROR__ "Clock_Freq unknown!"
ENDIF

;===============================================================================
Flash_Code      SEGMENT         CODE
                RSEG            Flash_Code

Flash_Init:
                MOV             rIAP_CONTR, #IAP_WT
                RET
;===============================================================================
Flash_Read:
; This function reads the Flash byte at DPTR, and returns it in A
                MOV             rIAP_CONTR, #(mIAPEN + IAP_WT) ; Enable flash
                MOV             A, DPH
                MOV             rIAP_ADDRH, A
                MOV             A, DPL
                MOV             rIAP_ADDRL, A
                MOV             rIAP_CMD, #IAP_CMD_Read
                MOV             rIAP_TRIG, #IAP_Trig0
                MOV             rIAP_TRIG, #IAP_Trig1
                NOP                               ; 1 SYSCLK
                NOP                               ; 2 SYSCLKs
                MOV             A, rIAP_DATA
                MOV             rIAP_CONTR, #IAP_WT ; Disable flash
                RET
;===============================================================================
Flash_Write:
                RET
;===============================================================================
Flash_Erase:
                RET
;===============================================================================
$ENDIF
                END
