; =====================================================================
; Block 1.5 Coding Day  Task 8 : Experimenting PC, SP, LR
; 步骤 :
;  1) 新建纯汇编工程(或把原工程里无关的数据段注释掉 / 另建 *.s)
;  2) 进入 Debug, 在 Memory 窗口写入:
;         0x2000600 = 11 11 11 11
;         0x2000604 = 22 22 22 22
;     (确保 SP 指向 0x2000600, 见下)
;  3) 观察 Registers 窗口的 PC / SP / LR 三个值。
; 说明 : 纯汇编工程 SP 初值由启动文件的栈设置决定, 需让栈顶落在 0x2000600
;        (0x2000600 为 8 字节对齐, 符合 AAPCS 对栈对齐的要求)。
;        本文件放一个 BL 调用, 便于观察 LR = 返回地址(here 的地址)。
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        BL      myfunc              ; 执行后 LR = here 的地址
here    B       here                ; <-- 观察 PC(应指向此处) 与 LR(=here 地址)
        ENDP

myfunc                              ; 普通子函数: 直接 BX lr 返回
        MOV     r0, #0
        BX      lr

        ALIGN

        END