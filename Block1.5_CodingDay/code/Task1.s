; =====================================================================
; Block 1.5 Coding Day  Task 1 : Experimenting Load/Store (1)
; 目标 : 观察 LDRB / LDRH / LDR / LDRSB / LDRSH 与 STRB / STRH 的影响
; 要点 : ARM 为小端 (Little Endian)。运行后用 Keil Memory 窗口看 0x20000000
;        显示格式可切 Unsigned->Char(字节) / Short(半字) / Int(字)
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        LDR     r0, =0x20000000
        LDR     r1, =0x12345678
        STR     r1, [r0]            ; mem[0x20000000..03] = 78 56 34 12
        LDRB    r2, [r0]            ; r2 = 0x00000078
        LDRH    r3, [r0]            ; r3 = 0x00005678
        LDR     r4, [r0]            ; r4 = 0x12345678

        LDR     r1, =0xE2E4E8       ; r1 = 0x00E2E4E8
        STR     r1, [r0]            ; mem[0x20000000..03] = E8 E4 E2 00
        LDRSB   r5, [r0]            ; r5 = 0xFFFFFFE8  ( = -24 )
        LDRSH   r6, [r0]            ; r6 = 0xFFFFE4E8  ( = -6936 )

        LDR     r0, =0x20000004
        STRB    r5, [r0]            ; mem[0x20000004]     = E8
        STRH    r6, [r0]            ; mem[0x20000004..05] = E8 E4
loop    B       loop
        ENDP

        ALIGN

        END