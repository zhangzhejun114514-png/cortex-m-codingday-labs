; =====================================================================
; Block 1.5 Coding Day  Task 5 : Arithmetic/Logic & APSR
; 每条指令前都重新初始化: r0=0xFFFFFFFE  r1=0x00000001  r2=0xFFFFFFFD
; 逐条单独执行, 在 Keil 的 Registers 窗口读 APSR 的 N Z C V
; 关键点 : 只有带 S 后缀的指令才更新标志位 !
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        ; ---- 1) ADD r3, r0, r1, LSL #4 --------------------------------
        ; 无 S -> 标志不变 ; r3 = 0x0000000E
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        ADD     r3, r0, r1, LSL #4

        ; ---- 2) SUBS r3, r0, r0 ---------------------------------------
        ; 有 S -> N=0 Z=1 C=1 V=0 ; r3 = 0x00000000
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        SUBS    r3, r0, r0

        ; ---- 3) ADDS r3, r0, r2 ---------------------------------------
        ; 有 S -> N=1 Z=0 C=1 V=0 ; r3 = 0xFFFFFFFB
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        ADDS    r3, r0, r2

        ; ---- 4) LSR r3, r0, #1 ----------------------------------------
        ; 无 S -> 标志不变 ; r3 = 0x7FFFFFFF
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        LSR     r3, r0, #1

        ; ---- 5) ASRS r3, r1, #1 ---------------------------------------
        ; 有 S -> N=0 Z=1 C=1 (V 不受影响) ; r3 = 0x00000000
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        ASRS    r3, r1, #1

        ; ---- 6) ANDS r3, r0, r2 ---------------------------------------
        ; 有 S -> N=1 Z=0 (C,V 不变) ; r3 = 0xFFFFFFFC
        LDR     r0, =0xFFFFFFFE
        LDR     r1, =0x00000001
        LDR     r2, =0xFFFFFFFD
        ANDS    r3, r0, r2
loop    B       loop
        ENDP

        ALIGN

        END