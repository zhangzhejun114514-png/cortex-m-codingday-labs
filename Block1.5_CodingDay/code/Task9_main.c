/* =====================================================================
 * Block 1.5 Coding Day  Task 9 : 主程序 (调用汇编实现的 func1 / func2)
 * 与 Task9_func.s 一起加入同一个 Keil 工程。
 * 期望 : func1(8,4) = 8 + (8 - 4) = 12 , 结果放在 r0 / result 变量中。
 * 观察 : 单步进入 func1 / func2, 在 Registers 窗口看 r0-r4、lr、pc、sp。
 * ===================================================================== */
#include <stdio.h>

extern int func1(int arg1, int arg2);
extern int func2(int arg1, int arg2);

volatile int g_result = 0;          /* volatile: 防止优化把调用删掉 */

int main(void)
{
    int arg1 = 8;
    int arg2 = 4;
    int result = func1(arg1, arg2); /* 期望 12 */
    g_result = result;             /* 可在 Watch/Memory 窗口查看 */

    return 0;
}
