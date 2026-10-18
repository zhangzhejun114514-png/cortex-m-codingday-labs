; =====================================================================
; Block 1.5 Coding Day  Task 7 : PUSH / POP   --- Code 2 (原始写法)
; 逐个 PUSH 再逐个 POP : 压栈/出栈顺序相反 -> 结果与 Code 1 不同
;   压栈: r1 r2 r3 r4  ->  内存(低->高): [sp]=4 , [sp+4]=3 , [sp+8]=2 , [sp+12]=1
;   出栈: r5 r6 r7 r8  ->  r5=4  r6=3  r7=2  r8=1
; 结论 : Code 2 与 Code 1 行为"不相同"(数值被倒置)。
;        要得到与 Code 1 相同的结果, 需按相反顺序压栈(见 Task7_Code2_fixed.s)。
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        MOV     r1, #1
        MOV     r2, #2
        MOV     r3, #3
        MOV     r4, #4
        PUSH    {r1}
        PUSH    {r2}
        PUSH    {r3}
        PUSH    {r4}
        POP     {r5}                ; r5 = 4
        POP     {r6}                ; r6 = 3
        POP     {r7}                ; r7 = 2
        POP     {r8}                ; r8 = 1
loop    B       loop
        ENDP

        ALIGN

        END