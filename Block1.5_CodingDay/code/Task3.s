; =====================================================================
; Block 1.5 Coding Day  Task 3 : Experimenting Addressing Modes (1)
; 目标 : 观察三种变址寻址方式对 r0 的影响
;   LDR r1, [r0, #4]   偏移(offset)      : r0 不变
;   LDR r1, [r0, #4]!  前索引(pre-index) : r0 = r0 + 4
;   LDR r1, [r0], #4   后索引(post-index) : 先用 r0, 之后 r0 = r0 + 4
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        ; ---- 初始化两块内存 ----
        LDR     r0, =0x20000000
        LDR     r1, =0x1F2E3D4C
        STR     r1, [r0]                    ; mem[0x20000000..03] = 4C 3D 2E 1F
        LDR     r0, =0x20000004
        LDR     r1, =0x5B6A7888
        STR     r1, [r0]                    ; mem[0x20000004..07] = 88 78 6A 5B

        ; ---- 偏移寻址 ----
        LDR     r0, =0x20000000
        LDR     r1, [r0, #4]                ; r1 = 0x5B6A7888 ; r0 = 0x20000000(不变)

        ; ---- 前索引寻址 ----
        LDR     r0, =0x20000000
        LDR     r1, [r0, #4]!               ; r0 = 0x20000004 ; r1 = 0x5B6A7888

        ; ---- 后索引寻址 ----
        LDR     r0, =0x20000000
        LDR     r1, [r0], #4                ; r1 = 0x1F2E3D4C ; r0 = 0x20000004
loop    B       loop
        ENDP

        ALIGN

        END