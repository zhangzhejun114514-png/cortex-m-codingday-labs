# Block 4.5 Coding Day —— 在本机完成方案（实施计划）

## 一、背景与目标（Context）

本次任务来自 `Block4.5-CodingDay.pptx`（FreeRTOS LiDAR Data Pipeline）。课件要求：把已有的
“RPLidar C1 + UART + DMA 读取”扩展成一条 **FreeRTOS 软件流水线**：

```
UART + DMA → ISR → Queue 1 → LiDAR 解析任务 → Queue 2 → 输出/调试任务
```

必须演示：2 个任务、2 个队列、DMA 半区/整块就绪中断、ISR 保持精简、队列 1 只传“小块描述符”、
解析任务直接从 DMA 缓冲区读取整块、结果经队列 2 交给输出任务；并提交**简要分析报告**。

**本机现状（已实地核查）：**
- 课程平台可确定：**ARM Cortex-M4 / STM32F401（Nucleo-64）**，工具链 **Keil uVision5(MDK)**，Block 4 = FreeRTOS（依据桌面 `新建文件夹` 的 Block1 系列讲义与 Downloads 里的 MDK536 安装包）。
- 本机**没有** Block 4 的既有 RPLidar 代码（全盘检索 `*.uvprojx/*.ioc/FreeRTOSConfig.h` 无结果）。
- 本机**没有** Keil/ARM 工具链，也没有 `gcc/clang/make/cmake`；仅 `Python 3.15` 与 `dotnet` 可用。
- **没有**连接任何调试器/串口设备（仅有蓝牙 COM3/COM4）。

**结论：** 本机无法编译 ARM 固件、也无法连接硬件跑板级演示。因此“在本机完成任务”的可落地形态 =
**① 交付可直接提交的 FreeRTOS 固件源码 + ② 交付一份本机可真实运行的流水线仿真（用来“演示”架构行为） + ③ 交付课件要求的简要分析报告**。

## 二、关键前提与假设（请在批准时确认或修改）

| # | 假设 | 备选 |
|---|------|------|
| A1 | 目标板 = **STM32F401RE / Nucleo-64**，Keil MDK5 + **STM32 HAL** 库 | 若课程用“寄存器版(正点原子)”，仅需替换 HAL 层，流水线核心不动 |
| A2 | C1 采用 **SCAN 标准模式**（传统/标准协议，5 字节/点） | 课件允许 SCAN 或 EXPRESS，选用 SCAN 更简单且可确定 |
| A3 | 交付目录 = `C:\Users\17129\Documents\Trae-CN\temp_20261016_01\Block4.5_CodingDay\` | 也可复制到桌面 `新建文件夹` 与你的 Block1 讲义并列 |
| A4 | 演示手段 = **Python 仿真**（本机唯一可运行的验证方式） | 如你有开发板，可后续按报告步骤上板验证 |

## 三、交付物结构

```
Block4.5_CodingDay/
├─ firmware/                     # ① 可直接提交的 Keil 工程源码（STM32F401 + FreeRTOS）
│  ├─ Core/Inc/lidar_pipeline.h  #    流水线对外接口：句柄、队列消息结构、结果结构、API
│  ├─ Core/Src/lidar_pipeline.c  #    核心：DMA 乒乓缓冲、ISR、Queue1/2、解析任务、输出任务
│  ├─ Core/Src/main.c            #    初始化(UART1@460800 + DMA 循环)、建队列/任务、vTaskStartScheduler
│  ├─ Core/Inc/FreeRTOSConfig.h  #    FreeRTOS 裁剪配置(含 configASSERT、中断优先级)
│  ├─ Core/Src/stm32f4xx_it.c     #    DMA/USART 中断服务：调用 lidar_pipeline_isr_handler()
│  └─ README.md                  #    接线表、编译步骤、逐条对应 PPT 要求
├─ simulation/
│  └─ lidar_pipeline_sim.py      # ② 本机可运行的确定性仿真（与固件逐行同构）
├─ 分析报告.md                    # ③ 课件要求的简要分析报告
└─ Block4.5_CodingDay_全解.html    # ④(可选) 汇总页，沿用你 Block1 讲义的样式
```

## 四、技术设计

### 4.1 协议层（RPLIDAR C1，已查证官方文档/SDK）
- 串口：**TTL UART，460800 bps**（datasheet: Communication Speed 460800）。
- 启动扫描请求：`A5 20`（SCAN，无载荷）。
- 应答描述符：`A5 5A` + 32bit(LE) `size:30|subtype:2` + `type`；标准扫描 `type = 0x81`。
- 标准测量点（**5 字节/点**，`rplidar_response_measurement_node_t`）：
  - `sync_quality`：bit0=`start_flag`(新一圈)，`quality = sync_quality >> 2`
  - `angle_q6_checkbit`：bit0=`check_bit`，`angle = (angle_q6_checkbit >> 1) / 64.0 (°)`
  - `distance_q2`：`distance_mm = distance_q2 / 4`
- 依据：Slamtec《Interface Protocol (S&C Series)》与 `rplidar_sdk` 头文件常量。

### 4.2 固件架构（STM32F401 + FreeRTOS）
- **DMA 乒乓**：`USART1_RX` 用 DMA2 Stream（循环模式），缓冲 `LIDAR_DMA_BUF_SIZE` 拆成两个等长半区；
  用 **DMA 半传输(HT) + 传输完成(TC)** 两个中断标志“半个缓冲区就绪”。
- **ISR（精简）**：只做两件事——计算刚填满半区的 `{offset,length,block_id,event_cnt}`，`xQueueSendFromISR` 入 **Queue1**，
  并 `portYIELD_FROM_ISR`。**不做任何解析**。
- **LiDAR 解析任务（Task1，优先级高）**：`xQueueReceive(Queue1, portMAX_DELAY)` 阻塞；被唤醒后
  **直接用 offset/length 从 DMA 原始缓冲读取整块**，按 5 字节/点解析 → 组装结果结构 → `xQueueSend(Queue2)`。
- **输出/调试任务（Task2，优先级低）**：`xQueueReceive(Queue2, portMAX_DELAY)` 阻塞；打印/上报（UART 终端 / ITM-SWV）。
- 解析输出（课件未固定，按可论证方案取）：有效点数、无效点数、每块节点数、**观测最小距离(mm)**、8 扇区障碍最小距离。

### 4.3 队列消息与结果结构（在报告中论证）
```c
typedef struct { uint16_t offset; uint16_t length; uint8_t block_id; uint16_t event_cnt; } lidar_block_desc_t; // Queue1, 仅“小块描述符”
typedef struct { uint16_t valid_cnt; uint16_t invalid_cnt; uint16_t min_dist_mm; uint16_t sector_min_mm[8];
                 uint8_t block_id; uint8_t new_scan; } lidar_result_t;                                       // Queue2
```

### 4.4 本机可运行的 Python 仿真（演示手段）
与固件**同构**：内置一个 C1 标准帧字节流发生器（含 `A5 5A` 描述符与 5 字节点）→ 字节喂入模拟 UART+DMA 乒乓缓冲 →
在“半区满”处触发 HT/TC 回调（即 ISR）→ 入 Queue1 → 解析任务读 DMA 缓冲解析 → 入 Queue2 → 输出任务打印。
确定性输出，打印每块描述符、解析结果与任务状态迁移，作为“架构正确性”的运行证据。

### 4.5 分析报告（`分析报告.md`，覆盖课件全部“must justify/explain”点）
1. 背景与数据流图；2. DMA 块大小选择与论证（采样率/带宽估算）；3. 为何 ISR 精简；
4. Queue1 只传描述符的理由 + 字段取舍；5. 解析任务如何处理“连续字节流”（跨块续接点、同步/校验）；
6. 中断上下文↔任务上下文的安全交接论证；7. 任务优先级与 BLOCKED/READY/RUNNING 迁移；
8. 创建的 FreeRTOS 内存对象（队列存储、任务栈、TCB）；9. 关键学习要点；10. 上板验证步骤与分工建议。

## 五、实施步骤

1. 建目录与骨架；编写 `lidar_pipeline.h`（结构体 + API）。
2. 编写 `lidar_pipeline.c`：DMA 乒乓缓冲管理、ISR 入队、解析任务（5 字节点解析 + 结果组装）、输出任务。
3. 编写 `main.c` / `FreeRTOSConfig.h` / `stm32f4xx_it.c` 片段：USART1+DMA 初始化（460800）、建队列/任务、启动调度器。
4. 编写 `simulation/lidar_pipeline_sim.py`（与固件同构的确定性仿真）。
5. **在本机运行仿真**并保存输出日志作为演示证据。
6. 撰写 `分析报告.md`（中文），逐条回答课件要求。
7. （可选）生成 `Block4.5_CodingDay_全解.html` 汇总页（沿用 Block1 讲义样式，内嵌代码与报告）。

## 六、验证方式

- **可运行验证（本机）**：`python simulation/lidar_pipeline_sim.py`
  —— 期望：完整跑完 ≥1 圈（360°），输出每块的描述符/解析结果；日志体现 2 队列阻塞-唤醒、2 任务优先级、
  DMA 半区/整块事件交替；解析出的角度/距离与发生器真值一致（含校验位、新圈标志）。
- **静态核对**：固件与仿真逐条对照 PPT 第 6 页“必须演示/必须能解释”清单，在报告中给出对应位置。
- **（可选/本机无工具链，默认不做）**：安装 `arm-none-eabi-gcc` 仅做编译检查；上板演示需你的开发板与 C1。

## 七、风险与待确认

- **A1 库风格**（HAL vs 寄存器版）会影响 `main.c` 外观；核心流水线模块不受影响。
- **A2 模式**：若你的 Block4 代码用的是 EXPRESS 模式，解析层需另写 capsule/dense 解码（工作量更大）。
- 无硬件/无工具链 → 固件**无法在本机编译或上板**；本机验证以“同构仿真运行”为准，报告给出上板步骤。
- 若你其实**已有 Block4 的 RPLidar 代码**（不在本机），把它发我即可直接在其之上扩展，而非从零编写。
