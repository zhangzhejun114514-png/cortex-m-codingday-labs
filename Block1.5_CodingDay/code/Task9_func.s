; =====================================================================
; Block 1.5 Coding Day  Task 9 : Calling assembly function in C
; 要求 :
;   func1 : result1 = arg1 + func2(arg1, arg2)
;   func2 : result2 = arg1 - arg2
; AAPCS : 参数顺序 r0=arg1, r1=arg2 ; 返回值 r0 ;
;         必须保持 r4-r11(被调用者保存), 调用其他函数前要保存 lr。
; 验证 : main 中 arg1=8, arg2=4
;         func2 -> 8-4 = 4 ; func1 -> 8+4 = 12  => result = 12
; =====================================================================
        AREA    |.text|, CODE, READONLY

        EXPORT  func1
        EXPORT  func2
        ALIGN

; ---------------------------------------------------------------------
; int func1(int arg1, int arg2)   ; r0=arg1 , r1=arg2 , 返回 r0
; ---------------------------------------------------------------------
func1   PROC
        PUSH    {r4, lr}            ; 保存 r4(被调用者保存) 与返回地址
        MOV     r4, r0              ; r4 = arg1 (跨 BL 保留)
        BL      func2               ; r0=arg1, r1=arg2 未变 -> 调用 func2(arg1,arg2)
        ADD     r0, r4, r0          ; result1 = arg1 + func2(...)
        POP     {r4, pc}            ; 恢复 r4 并返回 (pc 出栈 == BX lr)
        ENDP

; ---------------------------------------------------------------------
; int func2(int arg1, int arg2)   ; r0=arg1 , r1=arg2 , 返回 r0
; ---------------------------------------------------------------------
func2   PROC
        SUB     r0, r0, r1          ; result2 = arg1 - arg2
        BX      lr                  ; 返回
        ENDP

        END
