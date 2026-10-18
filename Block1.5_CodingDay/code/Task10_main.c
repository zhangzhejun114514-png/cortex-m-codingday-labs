/* =====================================================================
 * Block 1.5 Coding Day  Task 10 : 主程序 (调用汇编实现的 process_sensor)
 * 与 Task10_func.s 一起加入同一个 Keil 工程。
 * 期望 : output = ((10*2 + 20*3) - 10) * 2 = (80 - 10) * 2 = 140
 * ===================================================================== */
#include <stdio.h>

extern int process_sensor(int w0, int x0, int w1, int x1, int B, int G);

volatile int g_output = 0;          /* 防止优化 */

int main(void)
{
    int w0 = 10;
    int x0 = 2;
    int w1 = 20;
    int x1 = 3;
    int B  = 10;
    int G  = 2;
    int output = process_sensor(w0, x0, w1, x1, B, G);   /* 期望 140 */
    g_output = output;

    /* 幻灯片里用的是 printf("Sensor output: %d\n", output);
       若需真实串口/ITM 输出, 需先做 fputc 重定向(见《全解》附录);
       若要求 0 error/0 warning 且不想重定向, 改为观察 r0/g_output 即可。 */

    while (1) { }
}
