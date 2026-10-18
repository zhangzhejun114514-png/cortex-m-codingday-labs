; =====================================================================
; Block 1.5 Coding Day  Task 6 : Conditional Branches  --- Code A
; 结构 : 先 B check , 用 BLT 回跳 (先判断后循环 -- while 型, 与汇编的
;        "检查在底部的 do-while" 不同)
; 结果 : r1 = 0+1+2+...+9 = 45
; 分支标志 : 最后一次"跳转成功"的 BLT 发生在 r0=9 时:
;            CMP r0,#10 -> 9-10 = -1 -> N=1 Z=0 C=0 V=0 (BLT: N != V, 成立)
;            结束循环的 CMP 在 r0=10 : 10-10 -> N=0 Z=1 C=1 V=0 (BLT 不成立)
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        MOV     r0, #0
        MOV     r1, #0
        B       check
loop    ADD     r1, r1, r0
        ADD     r0, r0, #1
check   CMP     r0, #10
        BLT     loop
endloop
        B       endloop             ; 幻灯片原码到此结束, 这里补一个死循环便于单步观察
        ENDP

        ALIGN

        END