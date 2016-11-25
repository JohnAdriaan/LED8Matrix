;
; Flash.a51
;

                NAME            Flash

                $INCLUDE        (Options.inc)

$IF (FLASH_Enable)

                PUBLIC          Flash_Init

;===============================================================================
Flash           SEGMENT         CODE
                RSEG            Flash

Flash_Init:
                RET
;===============================================================================
$ENDIF
                END
