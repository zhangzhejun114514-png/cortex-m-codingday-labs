; =====================================================================
; Block 1.5 Coding Day  Task 7  —— 演示用工程文件 (Code 1)
; 说明 : 在交付版 Task7_Code1.s 的任务代码前，加了一张最小向量表(RESET 段)，
;        让 Keil 模拟器复位时能取到正确的 初始 SP 与 复位向量。
;        下方任务代码与交付版 Task7_Code1.s 完全一致。
; 预期 : r5=1  r6=2  r7=3  r8=4
; =====================================================================
        AREA    RESET, DATA, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20008000              ; 初始栈顶(MSP)
        DCD     Reset_Handler           ; 复位向量

        AREA    |.text|, CODE, READONLY
        EXPORT  Reset_Handler
Reset_Handler
        MOV     r1, #1
        MOV     r2, #2
        MOV     r3, #3
        MOV     r4, #4
        PUSH    {r1, r4, r3, r2}        ; 实际压栈顺序: r1 r2 r3 r4
        POP     {r5-r7, r8}             ; r5=1 r6=2 r7=3 r8=4
loop    B       loop
        ALIGN
        END
