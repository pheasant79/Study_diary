.6# CAN总线基础知识

<div align="center">

![CAN总线](https://via.placeholder.com/600x150/0078D7/FFFFFF?text=CAN%E6%80%BB%E7%BA%BF%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)

</div>

---

## 📑 目录

- [📑 目录](#-目录)
- [CAN总线基本概念](#can总线基本概念)
- [CAN总线电平特性](#can总线电平特性)
- [CAN总线位同步机制](#can总线位同步机制)
  - [为什么需要位同步？](#为什么需要位同步)
  - [位时序结构](#位时序结构)
  - [同步机制详解](#同步机制详解)
  - [采样点](#采样点)
  - [应用实例](#应用实例)
- [CAN总线协议帧类型](#can总线协议帧类型)
- [CAN总线仲裁机制](#can总线仲裁机制)
- [CAN总线错误处理](#can总线错误处理)

---

## CAN总线基本概念

<details>
<summary>📖 点击展开详细介绍</summary>

CAN总线（Controller Area Network）是一种差分信号通信协议，它与RS-232、RS-485、RS-422不同，不是串口通信(UART)的点对点通信，而是采用差分电平的多主机通信网络。

> 💡 **知识要点**: CAN总线是一种多主方式的串行通信总线，最初是由德国BOSCH公司为汽车行业开发的。

CAN协议的主要特点：
- 多主控制器网络
- 非破坏性总线仲裁
- 消息的优先级管理
- 多接收器广播通信
- 错误检测与错误处理机制
- 通信速度快（最高可达1Mbps）
- 抗干扰能力强，适合在汽车环境、恶劣电磁辐射环境中使用
- 可靠性高，具有完善的错误检测和处理机制

</details>

## CAN总线电平特性

<div class="can-levels" style="background-color:#f8f9fa;padding:15px;border-radius:5px;margin:10px 0;">

- **显性状态**（逻辑0）：
  - CAN_H = 3.5V
  - CAN_L = 1.5V
  - 差分电压约2V

- **隐性状态**（逻辑1）：
  - CAN_H ≈ CAN_L ≈ 2.5V
  - 差分电压约0V

```
     电压(V)
     ^
3.5V |    CAN_H (显性)
     |    *-----------*
     |    |           |
2.5V |----*           *----  CAN_H/CAN_L (隐性)
     |    |           |
     |    |           |
1.5V |    *-----------*      CAN_L (显性)
     |
     +----------------------> 时间
        隐性    显性    隐性
```

</div>

## CAN总线位同步机制

<div class="bit-timing-box" style="background-color:#e8f4f8;padding:20px;border-radius:8px;border-left:5px solid #0078D7;margin:15px 0;">

> **核心概念**：CAN网络没有单独的时钟线，各节点必须通过位同步机制确保在正确的时刻采样位值。

### 为什么需要位同步？

<div style="background-color:#f5f5f5;padding:10px;border-radius:5px;margin:10px 0;">
CAN总线采用<b>NRZ</b>（非归零）编码方式，不同节点间存在时钟偏差和信号传播延迟，使得：

- 发送节点与接收节点的时钟不完全同步
- 信号在线缆中传播需要时间
- 不同的接收节点距离发送节点的距离不同
- 电子元件的温度变化会引起时钟漂移

如果没有位同步机制，长时间传输将导致位错位，使接收方在错误的时间点采样。
</div>

### 位时序结构

CAN协议将每个位时间划分为四个关键段落：

<table style="width:100%;border-collapse:collapse;margin:15px 0;text-align:center;">
<tr style="background-color:#0078D7;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">段名</th>
  <th style="padding:8px;border:1px solid #ddd;">长度(TQ)</th>
  <th style="padding:8px;border:1px solid #ddd;">可调整性</th>
  <th style="padding:8px;border:1px solid #ddd;">功能</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">同步段<br>(SYNC_SEG)</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">固定</td>
  <td style="padding:8px;border:1px solid #ddd;">预期发生边沿跳变的区域</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">传播段<br>(PROP_SEG)</td>
  <td style="padding:8px;border:1px solid #ddd;">1-8</td>
  <td style="padding:8px;border:1px solid #ddd;">配置固定</td>
  <td style="padding:8px;border:1px solid #ddd;">补偿网络物理延迟</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">相位段1<br>(PHASE_SEG1)</td>
  <td style="padding:8px;border:1px solid #ddd;">1-8</td>
  <td style="padding:8px;border:1px solid #ddd;">可延长</td>
  <td style="padding:8px;border:1px solid #ddd;">补偿边沿延迟，可调整</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">相位段2<br>(PHASE_SEG2)</td>
  <td style="padding:8px;border:1px solid #ddd;">1-8</td>
  <td style="padding:8px;border:1px solid #ddd;">可缩短</td>
  <td style="padding:8px;border:1px solid #ddd;">处理早到边沿，可调整</td>
</tr>
</table>

```
┌─────────────────────── 1个位时间 ──────────────────────┐
┌────┬──────────────┬──────────────┬──────────────┐
│SYNC│   PROP_SEG   │  PHASE_SEG1  │  PHASE_SEG2  │
└────┴──────────────┴──────────────┴──────────────┘
       ↑                            ↑
    边沿检测点                     采样点
```

> 💡 **TQ（Time Quantum）**：时间量子，是CAN总线位时序的基本时间单位，由CAN控制器的输入时钟分频得到。

### 同步机制详解

CAN总线使用两种同步技术确保所有节点协调一致：

<div style="display:flex;margin:15px 0;">
<div style="flex:1;background-color:#e1f5fe;padding:15px;border-radius:5px;margin-right:10px;">
<h4 style="margin-top:0;">1️⃣ 硬同步（Hard Synchronization）</h4>

- **触发条件**：
  - 总线空闲状态到数据传输的转换
  - 每个帧的起始位（SOF）

- **工作原理**：
  - 检测到隐性→显性跳变时
  - 立即重置所有节点的位时序计数器
  - 所有节点重新从SYNC_SEG开始计时

- **适用场景**：
  - 帧的开始
  - 长时间总线空闲后的首次通信
  
- **总结**
  - 在**帧开始**时,对所有设备的位时序计数器进行重置,并从SYNC_SEG开始计时
</div>

<div style="flex:1;background-color:#fff8e1;padding:15px;border-radius:5px;">
<h4 style="margin-top:0;">2️⃣ 再同步（Resynchronization）</h4>

- **触发条件**：
  - 位传输过程中的边沿跳变
  - 隐性→显性的转换（只有这种跳变可被可靠检测）

- **工作原理**：
  - **边沿提前**：减少PHASE_SEG2长度
  - **边沿延迟**：增加PHASE_SEG1长度
  - 调整量受SJW限制（Synchronization Jump Width）

- **适用场景**：
  - 帧传输期间的连续位同步
  - 补偿时钟漂移和相位错误
  
- **总结**
  - 在**位传输过程**中,如果检测到边沿跳变,则根据跳变方向调整PHASE_SEG1或PHASE_SEG2的长度,以补偿时钟漂移和相位错误
</div>
</div>

<div style="background-color:#f3e5f5;padding:15px;border-radius:5px;margin:15px 0;">
<h4 style="margin-top:0;">同步跳跃宽度（SJW）</h4>

- **定义**：再同步过程中允许的最大调整量，以TQ为单位
- **范围**：1-4个TQ
- **作用**：限制单次同步调整的幅度，避免过度校正
- **配置**：在初始化CAN控制器时设置，需根据网络拓扑和物理特性选择适当值
</div>

### 采样点

<div style="background-color:#fce4ec;padding:15px;border-radius:5px;margin:15px 0;">
采样点位于PHASE_SEG1和PHASE_SEG2之间，是CAN控制器读取总线电平以确定位值的精确时刻。

- **单点采样**：在采样点进行一次采样
- **三点采样**：在采样点及其前后各进行一次采样，采用多数投票法决定位值
- **典型位置**：通常位于位时间的70%-80%处，可根据总线长度和波特率进行优化
</div>

### 应用实例

<div style="background-color:#e8f5e9;padding:15px;border-radius:5px;margin:15px 0;">
<h4 style="margin-top:0;">🚗 汽车CAN网络配置示例</h4>

| 参数 | 高速CAN (500kbps) | 低速CAN (125kbps) |
|------|-------------------|-------------------|
| TQ | 125ns | 500ns |
| SYNC_SEG | 1 TQ | 1 TQ |
| PROP_SEG | 3 TQ | 3 TQ |
| PHASE_SEG1 | 3 TQ | 3 TQ |
| PHASE_SEG2 | 3 TQ | 3 TQ |
| SJW | 2 TQ | 2 TQ |
| 采样点位置 | 75% | 75% |
| 总位时间 | 10 TQ (2μs) | 10 TQ (8μs) |

这种配置能够容忍最大40米的网络长度（高速CAN）和160米（低速CAN）。
</div>

</div>

## CAN总线协议帧类型

<div style="overflow-x:auto;">

| 标准帧: | 起始位 | 仲裁场 (ID + RTR) | 控制场 (IDE + RTR + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |
| :-------: | :------: | :----------------: | :----------------------: | :----------------: | :----------------------: | :-----: | :----: | :--------: |
| 扩展帧: | 起始位 | 仲裁场 (ID(29位) + RTR) | 控制场 (IDE + r1 + r0 + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |

</div>

<details>
<summary>📋 各种位的详细说明</summary>

- **ID**: 11位ID(0-7FF) 或 29位ID(0-7FFFFFFF)
- **RTR**: 0-数据帧, 1-远程帧
- **IDE**: 0-标准帧, 1-扩展帧
- **r1**: 保留位，固定为0（仅在扩展帧中使用）
- **r0**: 保留位，固定为0（仅在扩展帧中使用）
- **DLC**: 数据长度代码，0-8字节
- **数据**: 0-8字节的数据内容
- **CRC**: 15位循环冗余校验码，用于检测传输错误
- **ACK**: 应答位，接收节点正确接收后置为显性(0)
- **结束符**: 7个连续的隐性位(1)
- **帧间间隔**: 至少3个隐性位，表示两帧之间的最小间隔

</details>

<details>
<summary>📋 各种帧类型的详细说明</summary>

- **数据帧**：用于发送节点向接收节点传送数据的帧
  ```
  +-----+--------+--------+------+-----+-----+-------+----------+
  |起始位|  仲裁场 |  控制场 | 数据场| CRC场| ACK场 | 结束符 | 帧间间隔 |
  +-----+--------+--------+------+-----+-----+-------+----------+
  ```

- **远程帧**：用于接收节点向具有相同ID的发送节点请求数据的帧
  - 与数据帧格式相同，但无数据场，且RTR位为隐性（1）

- **错误帧**：任何节点检测到总线错误时发送的帧
  - 由错误标志和错误界定符组成

- **过载帧**：接收节点通知它还没有准备好接收数据时发送的帧
  - 结构类似于错误帧

</details>

## CAN总线仲裁机制

<div class="arbitration" style="background-color:#fff8e1;padding:15px;border-radius:5px;border-left:5px solid #ffa000;margin:10px 0;">

CAN总线采用**CSMA/CD+AMP**（带有仲裁的载波侦听多路访问/冲突检测）机制：

1. 当总线空闲时，任何节点都可以发送消息
2. 当多个节点同时发送时，通过ID仲裁决定优先级：
   - ID值较低的节点获得总线访问权
   - 其他节点自动变为接收者，等待下一次机会
3. 这种仲裁过程是非破坏性的，不会影响总线效率

仲裁机制图示：
```
节点A (ID:15)  1 0 0 0 1 1 1 1... ←停止发送，变为接收者
节点B (ID:10)  1 0 1 0 1 0 1 0... ←继续发送，获得总线访问权
总线实际状态   1 0 0 0 1 0 1 0...
                     ↑
                 仲裁点(显性胜出)
```

注：CAN总线上的显性状态（0）会覆盖隐性状态（1）

</div>

## CAN总线错误处理

<details>
<summary>🔍 CAN总线错误检测与处理机制</summary>

CAN协议定义了5种错误检测机制：

1. **位错误**：节点发送位后监听总线，若检测到的值与发送值不同（非仲裁期间），则报错
2. **填充错误**：连续5个相同位后，发送方自动插入一个相反值位，接收方检测不符合此规则时报错
3. **CRC错误**：接收方计算的CRC与发送方提供的不一致时报错
4. **帧格式错误**：收到的帧在固定格式字段有错误时报错
5. **应答错误**：发送方在ACK槽没有检测到显性位时报错

**错误处理流程**：
1. 检测到错误的节点发送错误帧
2. 其他节点检测到错误帧也发送错误帧
3. 原始消息被丢弃，发送方尝试重新发送

**错误计数与错误状态**：
- 每个节点维护发送错误计数器(TEC)和接收错误计数器(REC)
- 根据计数值，节点可处于三种状态：
  - **错误活动**：0-127，正常参与总线通信
  - **错误被动**：128-255，仍可通信但有限制
  - **总线关闭**：>255，节点自动从总线断开

</details> 