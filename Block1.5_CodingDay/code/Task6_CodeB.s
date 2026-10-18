; =====================================================================
; Block 1.5 Coding Day  Task 6 : Conditional Branches  --- Code B
; 结构 : 先判断后循环, 用 BGE 跳出 (while 型)
; 结果 : r1 = 0+1+2+...+9 = 45   (与 Code A 相同)
; 分支标志 : 触发"跳出"的 BGE 在 r0=10 时:
;            CMP r0,#10 -> 10-10 -> N=0 Z=1 C=1 V=0 (BGE: N == V, 成立, 跳出)
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        MOV     r0, #0
        MOV     r1, #0
loop    CMP     r0, #10
        BGE     endloop
        ADD     r1, r1, r0
        ADD     r0, r0, #1
        B       loop
endloop
        B       endloop             ; 便于单步观察
        ENDP

        ALIGN

        END