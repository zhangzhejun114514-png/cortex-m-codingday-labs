; =====================================================================
; Block 1.5 Coding Day  Task 10 : A more challenging AAPCS
; 要求 : 补全两个空 (从栈上访问第 5、第 6 个参数 B 和 G), 并推导实现的
;        数学表达式。
; AAPCS : 前 4 个参数放 r0-r3 ; 第 5 个参数在 [sp] , 第 6 个在 [sp+4]
;         (进入函数那一瞬间, 即 push 之前)。
; 本题 : process_sensor(w0,x0,w1,x1,B,G)
;         进入时 [sp+0]=B , [sp+4]=G
;         执行 PUSH {r4,r5,r6,lr} 后 SP 下移 16 字节
;         => [sp+16]=B   [sp+20]=G
; 表达式: output = ((w0*x0 + w1*x1) - B) * G
; 数值  : s = 10*2 + 20*3 = 80 ; (80 - 10) * 2 = 140
; =====================================================================
        AREA    |.text|, CODE, READONLY

        EXPORT  process_sensor
        EXPORT  calibrate
        ALIGN

; ---------------------------------------------------------------------
; int calibrate(int s, int B, int G)   ; r0=s , r1=B , r2=G
;   返回 : (s - B) * G
; ---------------------------------------------------------------------
calibrate PROC
        PUSH    {r4, lr}
        SUB     r4, r0, r1          ; r4 = s - B
        MUL     r0, r4, r2          ; r0 = (s - B) * G
        POP     {r4, pc}
        ENDP

; ---------------------------------------------------------------------
; int process_sensor(int w0,int x0,int w1,int x1,int B,int G)
;   r0=w0 r1=x0 r2=w1 r3=x1 ; 栈: [sp]=B [sp+4]=G
; ---------------------------------------------------------------------
process_sensor PROC
        PUSH    {r4, r5, r6, lr}    ; SP -= 16 -> 原 [sp+0]->[sp+16]
        MUL     r4, r0, r1          ; r4 = w0 * x0
        MLA     r4, r2, r3, r4      ; r4 = w1 * x1 + r4   (= s)
        LDR     r1, [sp, #16]       ; <<< 空 1 : r1 = B  (第 5 个参数)
        LDR     r2, [sp, #20]       ; <<< 空 2 : r2 = G  (第 6 个参数)
        MOV     r0, r4              ; r0 = s
        BL      calibrate           ; calibrate(s, B, G)
        POP     {r4, r5, r6, pc}
        ENDP

        END
