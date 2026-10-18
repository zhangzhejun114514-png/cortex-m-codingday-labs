; =====================================================================
; Block 1.5 Coding Day  Task 7 : PUSH / POP   --- Code 1
; PUSH {r1,r4,r3,r2} : 汇编器忽略书写顺序, 一律按"寄存器号升序"压栈,
;                      且低编号寄存器放在低地址。
;   内存(低->高): [sp]=r1=1 , [sp+4]=r2=2 , [sp+8]=r3=3 , [sp+12]=r4=4
; POP  {r5-r7,r8}    : 按升序出栈
;   r5=1  r6=2  r7=3  r8=4
; =====================================================================
        AREA    |.text|, CODE, READONLY

__main  PROC
        MOV     r1, #1
        MOV     r2, #2
        MOV     r3, #3
        MOV     r4, #4
        PUSH    {r1, r4, r3, r2}    ; 实际压栈顺序: r1 r2 r3 r4
        POP     {r5-r7, r8}         ; r5=1 r6=2 r7=3 r8=4
loop    B       loop
        ENDP

        ALIGN

        END