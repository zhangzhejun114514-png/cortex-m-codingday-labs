; =====================================================================
; Block 1.5 Coding Day  Task 7 : PUSH / POP   --- Code 2 (修正版)
; 目的 : 让 Code 2 得到与 Code 1 相同的效果 (r5=1 r6=2 r7=3 r8=4)
; 做法 : 把压栈顺序反转 (先压 r4 ... 最后压 r1), 弹出顺序不变。
;   压栈: r4 r3 r2 r1 -> 内存(低->高): [sp]=1 , [sp+4]=2 , [sp+8]=3 , [sp+12]=4
;   出栈: r5 r6 r7 r8 -> r5=1 r6=2 r7=3 r8=4   (与 Code 1 一致)
; (等价做法: 压栈顺序不变, 改为逆序弹出 r8,r7,r6,r5)
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        MOV     r1, #1
        MOV     r2, #2
        MOV     r3, #3
        MOV     r4, #4
        PUSH    {r4}                ; 先压 4
        PUSH    {r3}                ;      3
        PUSH    {r2}                ;      2
        PUSH    {r1}                ; 再压 1
        POP     {r5}                ; r5 = 1
        POP     {r6}                ; r6 = 2
        POP     {r7}                ; r7 = 3
        POP     {r8}                ; r8 = 4
loop    B       loop
        ENDP

        ALIGN

        END