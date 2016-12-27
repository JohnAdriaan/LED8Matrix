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

                SFR rIAP_DATA  = 0C2h
                SFR rIAP_ADDRH = 0C3h
                SFR rIAP_ADDRL = 0C4h

                SFR rIAP_CMD   = 0C5h
DefineBit       MS1, rIAP_CMD, 1
DefineBit       MS0, rIAP_CMD, 0
   bMS          EQU             bMS0    ; Mode shift number
   mMS          EQU            (mMS1 + mMS0) ; Mode mask
IAP_CMD_Standby EQU             00b SHL bMS
IAP_CMD_Read    EQU             01b SHL bMS
IAP_CMD_Write   EQU             10b SHL bMS
IAP_CMD_Erase   EQU             11b SHL bMS

                SFR rIAP_TRIG  = 0C6h
IAP_Trig0       EQU             05Ah
IAP_Trig1       EQU             0A5h

                SFR rIAP_CONTR = 0C7h
DefineBit       IAPEN,    rIAP_CONTR, 7           ; Global /disable, enable
DefineBit       SWBS,     rIAP_CONTR, 6           ; Boot /memory, ISP
DefineBit       SWRST,    rIAP_CONTR, 5           ; Reset MCU
DefineBit       CMD_FAIL, rIAP_CONTR, 4           ; Command /succeeded, failed
DefineBit       WT2,      rIAP_CONTR, 2
DefineBit       WT1,      rIAP_CONTR, 1
DefineBit       WT0,      rIAP_CONTR, 0
   bWT          EQU             bWT0
   mWT          EQU            (mWT2 + mWT1 + mWT0)
IAP_WT_30MHz    EQU             000b SHL bWT
IAP_WT_24MHz    EQU             001b SHL bWT
IAP_WT_20MHz    EQU             010b SHL bWT
IAP_WT_12MHz    EQU             011b SHL bWT
IAP_WT_6MHz     EQU             100b SHL bWT
IAP_WT_3MHz     EQU             101b SHL bWT
IAP_WT_2MHz     EQU             110b SHL bWT
IAP_WT_1MHz     EQU             111b SHL bWT

IF     (CPU_Freq=CPU_11059200)
IAP_WT          EQU             IAP_WT_12MHz
ELSEIF (CPU_Freq=CPU_33177600)
IAP_WT          EQU             IAP_WT_30MHz
ELSE
__ERROR__ "CPU_Freq unknown!"
ENDIF

;===============================================================================
Flash_Code      SEGMENT         CODE
                RSEG            Flash_Code

Flash_Init:
                MOV             rIAP_CONTR, #(mIAPEN + IAP_WT)
                RET
;===============================================================================
Flash_Read:
; This function reads the Flash byte at DPTR, and returns it in A
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
