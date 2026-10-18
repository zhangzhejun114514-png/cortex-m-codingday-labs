        AREA    RESET, DATA, READONLY
        EXPORT  __Vectors
        EXPORT  Reset_Handler
        ENTRY

__Vectors
        DCD     0x20006000
        DCD     Reset_Handler

        AREA    myCode, CODE, READONLY
        ALIGN
        EXPORT  __main

Reset_Handler
        LDR     sp, =0x20006000
        B       __main

__main  PROC

        LDR     r0, =0x20006000
        LDR     r1, =0x11111111
        STR     r1, [r0]

        LDR     r1, =0x22222222
        STR     r1, [r0, #4]

        POP     {r0, r1}

        ADD     r2, r0, r1

        BL      Func

        MOV     r0, #0

        B       __main

Func
        PUSH    {r2, LR}

        MOV     r2, r1

        POP     {r2, PC}

        ENDP
        END