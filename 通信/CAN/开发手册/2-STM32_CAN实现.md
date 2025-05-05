# STM32的CAN实现

<div align="center">

![STM32 CAN](https://via.placeholder.com/600x150/4CAF50/FFFFFF?text=STM32%20CAN%E5%AE%9E%E7%8E%B0)

</div>

---

## 📑 目录

- [STM32的CAN实现](#stm32的can实现)
  - [📑 目录](#-目录)
  - [STM32 CAN控制器特点](#stm32-can控制器特点)
  - [STM32 CAN位时序配置](#stm32-can位时序配置)
    - [主要参数](#主要参数)
    - [配置计算公式](#配置计算公式)
    - [配置示例](#配置示例)
  - [STM32与CAN总线的连接方式](#stm32与can总线的连接方式)
    - [不同STM32系列CAN接口对比](#不同stm32系列can接口对比)
  - [STM32 CAN过滤器配置](#stm32-can过滤器配置)
    - [过滤器基本概念](#过滤器基本概念)
    - [过滤器内部结构](#过滤器内部结构)
    - [过滤器工作模式详解](#过滤器工作模式详解)
      - [1. 掩码模式 (Mask Mode)](#1-掩码模式-mask-mode)
      - [2. 列表模式 (List Mode)](#2-列表模式-list-mode)
    - [过滤器配置详解](#过滤器配置详解)
      - [标准帧与扩展帧的区别](#标准帧与扩展帧的区别)
      - [实例解析：标准帧配置](#实例解析标准帧配置)
      - [实例解析：扩展帧配置](#实例解析扩展帧配置)
    - [高级应用场景](#高级应用场景)
      - [1. 多过滤器组合使用](#1-多过滤器组合使用)
      - [2. 双CAN控制器过滤器分配（适用于F4/F7等双CAN系列）](#2-双can控制器过滤器分配适用于f4f7等双can系列)
      - [3. 接收所有报文(调试用)](#3-接收所有报文调试用)
    - [常见问题与解决方案](#常见问题与解决方案)
    - [快速参考表](#快速参考表)
  - [STM32 CAN邮箱机制](#stm32-can邮箱机制)
    - [邮箱基本概念](#邮箱基本概念)
    - [发送邮箱详解](#发送邮箱详解)
      - [发送流程概述](#发送流程概述)
      - [发送优先级管理](#发送优先级管理)
    - [接收FIFO详解](#接收fifo详解)
      - [接收流程概述](#接收流程概述)
      - [发送完成状态检查](#发送完成状态检查)
      - [在发送邮箱之间选择](#在发送邮箱之间选择)
      - [发送超时处理](#发送超时处理)
      - [动态优先级管理](#动态优先级管理)
      - [1. 高效处理多报文接收](#1-高效处理多报文接收)
      - [2. 优先级反转问题](#2-优先级反转问题)
      - [3. FIFO溢出防范策略](#3-fifo溢出防范策略)
      - [4. 调试邮箱问题](#4-调试邮箱问题)
  - [CAN收发器模块](#can收发器模块)
  - [CAN通信基本流程](#can通信基本流程)
    - [初始化流程](#初始化流程)
    - [发送报文](#发送报文)
    - [接收报文（中断方式）](#接收报文中断方式)
    - [错误处理](#错误处理)
  - [常见问题与解决方案](#常见问题与解决方案-1)
    - [1. 无法发送/接收报文](#1-无法发送接收报文)
    - [2. 频繁出现总线关闭状态](#2-频繁出现总线关闭状态)
    - [3. 高负载情况下丢失报文](#3-高负载情况下丢失报文)
    - [4. 时间戳不准确](#4-时间戳不准确)

---

## STM32 CAN控制器特点

<div class="stm32-features" style="background-color:#e8f4ff;padding:15px;border-radius:5px;border-left:5px solid #0078D7;margin:10px 0;">

STM32的CAN控制器集成了以下特性：
- 完全符合CAN协议2.0A和2.0B（主动）
- 位时序可编程
- 三个发送邮箱
- 两个接收FIFO，每个可存储3条消息
- 高级筛选器组，最多28个过滤器（根据STM32型号不同会有差异）
- 中断功能：发送完成、接收FIFO、错误等
- 支持时间触发通信模式（Time Triggered Communication）
- 支持睡眠模式和唤醒功能
- 内置时间戳计数器，便于实现同步通信

</div>

## STM32 CAN位时序配置

<div class="bit-timing-config" style="background-color:#fff8e1;padding:15px;border-radius:5px;border-left:5px solid #FFA000;margin:10px 0;">

STM32 CAN控制器的位时序设置是实现稳定通信的关键，需要配置以下参数：

### 主要参数

- **预分频器（Prescaler）**：决定时间量子（TQ）的长度
- **BS1**：对应PROP_SEG + PHASE_SEG1，范围1-16个TQ
- **BS2**：对应PHASE_SEG2，范围1-8个TQ
- **SJW**：同步跳跃宽度，范围1-4个TQ

### 配置计算公式

```
波特率 = APB1时钟频率 ÷ (预分频器 × (1 + BS1 + BS2))
```

### 配置示例

<table style="width:100%;border-collapse:collapse;margin:10px 0;text-align:center;">
<tr style="background-color:#FFA000;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">波特率</th>
  <th style="padding:8px;border:1px solid #ddd;">时钟</th>
  <th style="padding:8px;border:1px solid #ddd;">预分频器</th>
  <th style="padding:8px;border:1px solid #ddd;">BS1</th>
  <th style="padding:8px;border:1px solid #ddd;">BS2</th>
  <th style="padding:8px;border:1px solid #ddd;">SJW</th>
  <th style="padding:8px;border:1px solid #ddd;">采样点</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">1Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">36MHz</td>
  <td style="padding:8px;border:1px solid #ddd;">4</td>
  <td style="padding:8px;border:1px solid #ddd;">5</td>
  <td style="padding:8px;border:1px solid #ddd;">2</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">75%</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">500kbps</td>
  <td style="padding:8px;border:1px solid #ddd;">36MHz</td>
  <td style="padding:8px;border:1px solid #ddd;">9</td>
  <td style="padding:8px;border:1px solid #ddd;">5</td>
  <td style="padding:8px;border:1px solid #ddd;">2</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">75%</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">250kbps</td>
  <td style="padding:8px;border:1px solid #ddd;">36MHz</td>
  <td style="padding:8px;border:1px solid #ddd;">18</td>
  <td style="padding:8px;border:1px solid #ddd;">5</td>
  <td style="padding:8px;border:1px solid #ddd;">2</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">75%</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">125kbps</td>
  <td style="padding:8px;border:1px solid #ddd;">36MHz</td>
  <td style="padding:8px;border:1px solid #ddd;">36</td>
  <td style="padding:8px;border:1px solid #ddd;">5</td>
  <td style="padding:8px;border:1px solid #ddd;">2</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">75%</td>
</tr>
</table>

> 💡 **注意**：网络中所有节点的波特率必须相同，采样点尽量保持一致（通常为70%-80%）。选择SJW参数需考虑网络规模和时钟精度。

</div>

## STM32与CAN总线的连接方式

STM32与CAN总线之间是通过**CAN总线收发器**连接的。收发器的作用是：
1. 将单片机发出的数字信号(0和1)转换为CAN总线上的差分信号(CAN-H和CAN-L)
2. 将CAN总线上的差分信号转换为单片机能够识别的数字信号(0和1)

```
+----------+          +------------+          +-----------+
|          |   TXD    |            |  CAN_H   |           |
|  STM32   |--------->| CAN收发器  |--------->|  CAN总线  |
| 控制器   |   RXD    |            |  CAN_L   |           |
|          |<---------|            |<---------|           |
+----------+          +------------+          +-----------+
```

对于STM32F103系列，CAN收发引脚如下：
- PA11 - CAN_RX
- PA12 - CAN_TX

注意：在STM32F103系列中，CAN和USB引脚复用，不能同时使用。

### 不同STM32系列CAN接口对比

<table style="width:100%;border-collapse:collapse;margin:10px 0;">
<tr style="background-color:#0078D7;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">STM32系列</th>
  <th style="padding:8px;border:1px solid #ddd;">CAN控制器数量</th>
  <th style="padding:8px;border:1px solid #ddd;">过滤器数量</th>
  <th style="padding:8px;border:1px solid #ddd;">常用引脚</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">F1系列</td>
  <td style="padding:8px;border:1px solid #ddd;">1个</td>
  <td style="padding:8px;border:1px solid #ddd;">14个</td>
  <td style="padding:8px;border:1px solid #ddd;">PA11/PA12 或 PB8/PB9</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">F4系列</td>
  <td style="padding:8px;border:1px solid #ddd;">2个</td>
  <td style="padding:8px;border:1px solid #ddd;">28个</td>
  <td style="padding:8px;border:1px solid #ddd;">PA11/PA12, PB12/PB13等</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">F7系列</td>
  <td style="padding:8px;border:1px solid #ddd;">2-3个</td>
  <td style="padding:8px;border:1px solid #ddd;">28个</td>
  <td style="padding:8px;border:1px solid #ddd;">PA11/PA12, PB12/PB13等</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">H7系列</td>
  <td style="padding:8px;border:1px solid #ddd;">2-3个</td>
  <td style="padding:8px;border:1px solid #ddd;">28个</td>
  <td style="padding:8px;border:1px solid #ddd;">多种组合，参考数据手册</td>
</tr>
</table>

## STM32 CAN过滤器配置

<div class="filter-overview" style="background-color:#e3f2fd;padding:15px;border-radius:5px;border-left:5px solid #2196F3;margin:10px 0;">

### 过滤器基本概念

STM32的CAN过滤器是一个强大的硬件机制，用于筛选接收的CAN报文，减轻CPU处理负担。过滤器可以配置为只接收特定ID或ID范围的报文，不符合条件的报文会被自动丢弃，不会占用系统资源。

**关键特性**：
- STM32 F1系列提供14个过滤器组（F4/F7等高端系列可达28个）
- 支持标准帧(11位)和扩展帧(29位)ID过滤
- 可同时过滤ID和数据帧/远程帧(RTR)类型
- 过滤后的报文可被定向到两个接收FIFO中的任一个

</div>

<div class="filter-structure" style="background-color:#e8eaf6;padding:15px;border-radius:5px;margin:10px 0;">

### 过滤器内部结构

每个过滤器组由两个32位寄存器组成，可灵活配置为不同工作模式：

<table style="width:100%;border-collapse:collapse;margin:15px 0;text-align:center;">
<tr style="background-color:#3f51b5;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">过滤器模式</th>
  <th style="padding:8px;border:1px solid #ddd;">过滤器位宽</th>
  <th style="padding:8px;border:1px solid #ddd;">组成</th>
  <th style="padding:8px;border:1px solid #ddd;">最大过滤数量</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">掩码模式</td>
  <td style="padding:8px;border:1px solid #ddd;">32位</td>
  <td style="padding:8px;border:1px solid #ddd;">1个ID + 1个掩码</td>
  <td style="padding:8px;border:1px solid #ddd;">1组</td>
</tr>
<tr style="background-color:#f5f5f5;">
  <td style="padding:8px;border:1px solid #ddd;">掩码模式</td>
  <td style="padding:8px;border:1px solid #ddd;">16位</td>
  <td style="padding:8px;border:1px solid #ddd;">2个ID + 2个掩码</td>
  <td style="padding:8px;border:1px solid #ddd;">2组</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">列表模式</td>
  <td style="padding:8px;border:1px solid #ddd;">32位</td>
  <td style="padding:8px;border:1px solid #ddd;">2个精确ID</td>
  <td style="padding:8px;border:1px solid #ddd;">2个ID</td>
</tr>
<tr style="background-color:#f5f5f5;">
  <td style="padding:8px;border:1px solid #ddd;">列表模式</td>
  <td style="padding:8px;border:1px solid #ddd;">16位</td>
  <td style="padding:8px;border:1px solid #ddd;">4个精确ID</td>
  <td style="padding:8px;border:1px solid #ddd;">4个ID</td>
</tr>
</table>

**过滤器寄存器分配**:

```
┌───────────────────────────────┬───────────────────────────────┐
│      过滤器寄存器 FR1         │      过滤器寄存器 FR2         │
├───────────────────────────────┴───────────────────────────────┤
│                        32位掩码模式                           │
├───────────────────────────────┬───────────────────────────────┤
│        ID (32位)              │       掩码 (32位)             │
├───────────────────────────────┴───────────────────────────────┤
│                        16位掩码模式                           │
├───────────────┬───────────────┬───────────────┬───────────────┤
│   ID1 (16位)  │ ID2 (16位)    │ 掩码1 (16位)  │ 掩码2 (16位)  │
├───────────────┴───────────────┴───────────────┴───────────────┤
│                        32位列表模式                           │
├───────────────────────────────┬───────────────────────────────┤
│        ID1 (32位)             │       ID2 (32位)              │
├───────────────────────────────┴───────────────────────────────┤
│                        16位列表模式                           │
├───────────────┬───────────────┬───────────────┬───────────────┤
│   ID1 (16位)  │ ID2 (16位)    │   ID3 (16位)  │ ID4 (16位)    │
└───────────────┴───────────────┴───────────────┴───────────────┘
```

</div>

<div class="filter-modes" style="background-color:#e0f7fa;padding:15px;border-radius:5px;margin:10px 0;">

### 过滤器工作模式详解

#### 1. 掩码模式 (Mask Mode)

掩码模式允许过滤一个ID范围，而不仅仅是单个ID。工作原理是：

```
如果 (收到的ID & 掩码) == (配置的ID & 掩码)，则接收该报文
```

- 掩码中的**0位**表示"必须匹配"
- 掩码中的**1位**表示"不关心"（可以是0或1）

**图形化解释**:

```
例如：要接收ID范围0x100-0x10F (即0x100到0x10F之间的所有ID)

ID:    0001 0000 0000  (0x100)
掩码:  1111 0000 1111  (0xF0F)
            ↑↑↑↑
            这4位为0，表示必须匹配
            其余位为1，表示不关心
            
匹配范围：0001 0000 xxxx  (其中x可以是0或1，即0x100-0x10F)
```

#### 2. 列表模式 (List Mode)

列表模式设置精确的ID值，只接收完全匹配的报文。

- 16位列表模式可以同时接收4个不同ID的报文
- 32位列表模式可以同时接收2个不同ID的报文

**优缺点比较**:
- **掩码模式**：适合连续或有规律的ID范围，配置简单
- **列表模式**：适合分散的、不连续的ID，可精确控制

</div>

<div class="filter-config" style="background-color:#f9fbe7;padding:15px;border-radius:5px;border-left:5px solid #cddc39;margin:10px 0;">

### 过滤器配置详解

#### 标准帧与扩展帧的区别

CAN ID在过滤器寄存器中的位置排布不同：

**标准帧(11位ID)**:
```
┌───┬───┬───┬────────┬───┬───┬─────────────────┐
│IDE│RTR│ 0 │   STID  │ 0 │ 0 │       0        │
└───┴───┴───┴────────┴───┴───┴─────────────────┘
  31  30  29  28...18   17  16  15...........0
```

**扩展帧(29位ID)**:
```
┌───┬───┬───────────────────────┬───────────────┐
│IDE│RTR│        EXID[28:13]    │  EXID[12:0]   │
└───┴───┴───────────────────────┴───────────────┘
  31  30  29...............13    12...........0
```

其中：
- **IDE**: 0=标准帧, 1=扩展帧
- **RTR**: 0=数据帧, 1=远程帧
- **STID**: 11位标准ID
- **EXID**: 29位扩展ID

#### 实例解析：标准帧配置

1. **单个精确ID过滤 (列表模式)**

```c
// 接收标准ID为0x123的报文
CAN_FilterTypeDef filter;
filter.FilterBank = 0;                        // 使用过滤器0
filter.FilterMode = CAN_FILTERMODE_IDLIST;    // 列表模式
filter.FilterScale = CAN_FILTERSCALE_16BIT;   // 16位过滤器
filter.FilterIdHigh = 0x123 << 5;             // ID左移5位
filter.FilterIdLow = 0x234 << 5;              // 另一个ID (如果需要)
filter.FilterMaskIdHigh = 0x345 << 5;         // 第三个ID (如果需要)
filter.FilterMaskIdLow = 0x456 << 5;          // 第四个ID (如果需要)
filter.FilterFIFOAssignment = CAN_FILTER_FIFO0; // 存入FIFO0
filter.FilterActivation = ENABLE;             // 激活过滤器
HAL_CAN_ConfigFilter(&hcan, &filter);
```

2. **ID范围过滤 (掩码模式)**

```c
// 接收ID范围0x100-0x1FF的报文
CAN_FilterTypeDef filter;
filter.FilterBank = 1;                        // 使用过滤器1
filter.FilterMode = CAN_FILTERMODE_IDMASK;    // 掩码模式
filter.FilterScale = CAN_FILTERSCALE_16BIT;   // 16位过滤器
filter.FilterIdHigh = 0x100 << 5;             // 基准ID左移5位
filter.FilterMaskIdHigh = 0x700 << 5;         // 掩码(前8位必须匹配)
filter.FilterIdLow = 0;                       // 不使用
filter.FilterMaskIdLow = 0;                   // 不使用
filter.FilterFIFOAssignment = CAN_FILTER_FIFO1; // 存入FIFO1
filter.FilterActivation = ENABLE;             // 激活过滤器
HAL_CAN_ConfigFilter(&hcan, &filter);
```

#### 实例解析：扩展帧配置

1. **扩展帧单ID过滤**

```c
// 接收扩展ID为0x12345678的报文
CAN_FilterTypeDef filter;
filter.FilterBank = 2;                        // 使用过滤器2
filter.FilterMode = CAN_FILTERMODE_IDLIST;    // 列表模式
filter.FilterScale = CAN_FILTERSCALE_32BIT;   // 32位过滤器
// 扩展ID需要按特定格式存储
filter.FilterIdHigh = (0x12345678 >> 13) | (1 << 2); // 高16位含IDE=1
filter.FilterIdLow = (0x12345678 << 3) & 0xFFFF;     // 低16位
filter.FilterMaskIdHigh = 0;                  // 不使用
filter.FilterMaskIdLow = 0;                   // 不使用
filter.FilterFIFOAssignment = CAN_FILTER_FIFO0; // 存入FIFO0
filter.FilterActivation = ENABLE;             // 激活过滤器
HAL_CAN_ConfigFilter(&hcan, &filter);
```

2. **同时过滤标准帧和扩展帧**

```c
// 接收标准ID为0x123和扩展ID为0x12345678的报文
CAN_FilterTypeDef filter;
filter.FilterBank = 3;                        // 使用过滤器3
filter.FilterMode = CAN_FILTERMODE_IDLIST;    // 列表模式
filter.FilterScale = CAN_FILTERSCALE_32BIT;   // 32位过滤器
// 标准帧配置
filter.FilterIdHigh = 0x123 << 5;             // 标准ID左移5位
filter.FilterIdLow = 0;                       // 低16位为0
// 扩展帧配置
filter.FilterMaskIdHigh = (0x12345678 >> 13) | (1 << 2); // 高16位含IDE=1
filter.FilterMaskIdLow = (0x12345678 << 3) & 0xFFFF;     // 低16位
filter.FilterFIFOAssignment = CAN_FILTER_FIFO0; // 存入FIFO0
filter.FilterActivation = ENABLE;             // 激活过滤器
HAL_CAN_ConfigFilter(&hcan, &filter);
```

</div>

<div class="filter-advanced" style="background-color:#fff3e0;padding:15px;border-radius:5px;margin:10px 0;">

### 高级应用场景

#### 1. 多过滤器组合使用

对于复杂的通信协议，可能需要同时使用多个过滤器：

```c
// 设置多个过滤器的示例
void ConfigureCANFilters(void)
{
    CAN_FilterTypeDef filter;
    
    // 过滤器1：接收所有紧急消息(ID: 0x000-0x0FF)
    filter.FilterBank = 0;
    filter.FilterMode = CAN_FILTERMODE_IDMASK;
    filter.FilterScale = CAN_FILTERSCALE_16BIT;
    filter.FilterIdHigh = 0x000 << 5;
    filter.FilterMaskIdHigh = 0xF00 << 5;  // 高字节必须为0
    filter.FilterIdLow = 0;
    filter.FilterMaskIdLow = 0;
    filter.FilterFIFOAssignment = CAN_FILTER_FIFO0; // 紧急消息进入FIFO0
    filter.FilterActivation = ENABLE;
    HAL_CAN_ConfigFilter(&hcan, &filter);
    
    // 过滤器2：接收特定功能ID(0x300, 0x301, 0x302, 0x303)
    filter.FilterBank = 1;
    filter.FilterMode = CAN_FILTERMODE_IDLIST;
    filter.FilterScale = CAN_FILTERSCALE_16BIT;
    filter.FilterIdHigh = 0x300 << 5;
    filter.FilterIdLow = 0x301 << 5;
    filter.FilterMaskIdHigh = 0x302 << 5;
    filter.FilterMaskIdLow = 0x303 << 5;
    filter.FilterFIFOAssignment = CAN_FILTER_FIFO1; // 功能消息进入FIFO1
    filter.FilterActivation = ENABLE;
    HAL_CAN_ConfigFilter(&hcan, &filter);
    
    // 过滤器3：接收特定扩展ID报文
    filter.FilterBank = 2;
    filter.FilterMode = CAN_FILTERMODE_IDLIST;
    filter.FilterScale = CAN_FILTERSCALE_32BIT;
    filter.FilterIdHigh = (0x18FF50E5 >> 13) | (1 << 2);
    filter.FilterIdLow = (0x18FF50E5 << 3) & 0xFFFF;
    filter.FilterMaskIdHigh = 0;
    filter.FilterMaskIdLow = 0;
    filter.FilterFIFOAssignment = CAN_FILTER_FIFO0;
    filter.FilterActivation = ENABLE;
    HAL_CAN_ConfigFilter(&hcan, &filter);
}
```

#### 2. 双CAN控制器过滤器分配（适用于F4/F7等双CAN系列）

在双CAN控制器的STM32中，CAN1和CAN2共享过滤器组，但有特定分配规则：

```c
// 针对STM32F4/F7系列的双CAN配置
void ConfigureDualCANFilters(void)
{
    // 重要：初始化CAN1过滤器组(0-13)可以路由到CAN1
    // CAN2使用过滤器组(14-27)
    
    CAN_FilterTypeDef filter;
    
    // CAN1过滤器配置
    filter.FilterBank = 0;  // CAN1使用过滤器0
    // ...其他过滤器配置...
    filter.SlaveStartFilterBank = 14; // 设置CAN2过滤器起始编号
    HAL_CAN_ConfigFilter(&hcan1, &filter);
    
    // CAN2过滤器配置
    filter.FilterBank = 14; // CAN2从过滤器14开始
    // ...其他过滤器配置...
    HAL_CAN_ConfigFilter(&hcan2, &filter);
}
```

#### 3. 接收所有报文(调试用)

在开发调试阶段，通常需要接收所有报文：

```c
// 配置为接收所有报文
CAN_FilterTypeDef filter;
filter.FilterBank = 0;
filter.FilterMode = CAN_FILTERMODE_IDMASK;
filter.FilterScale = CAN_FILTERSCALE_32BIT;
filter.FilterIdHigh = 0x0000;
filter.FilterIdLow = 0x0000;
filter.FilterMaskIdHigh = 0x0000; // 所有位都不关心(全1)
filter.FilterMaskIdLow = 0x0000;  // 所有位都不关心(全1)
filter.FilterFIFOAssignment = CAN_FILTER_FIFO0;
filter.FilterActivation = ENABLE;
HAL_CAN_ConfigFilter(&hcan, &filter);
```

</div>

<div class="filter-tips" style="background-color:#ffebee;padding:15px;border-radius:5px;border-left:5px solid #f44336;margin:10px 0;">

### 常见问题与解决方案

1. **过滤器看起来配置正确，但无法接收报文**
   - 检查IDE位设置是否正确（标准帧/扩展帧）
   - 验证ID是否按规定左移了正确的位数
   - 确认过滤器已激活(FilterActivation = ENABLE)
   - 确认过滤器分配了正确的FIFO

2. **掩码计算错误**
   - 记住：掩码中的0表示"必须匹配"，1表示"不关心"
   - 编写小工具函数验证ID是否会被过滤器接受
   ```c
   bool IsIdAccepted(uint32_t id, uint32_t filter_id, uint32_t filter_mask) {
       return ((id & (~filter_mask)) == (filter_id & (~filter_mask)));
   }
   ```

3. **无法同时过滤多个不连续ID**
   - 对于不连续ID，使用列表模式而非掩码模式
   - 如果ID数量超过单个过滤器能处理的数量，使用多个过滤器

4. **高优先级消息处理延迟**
   - 将高优先级ID的过滤器分配到相对空闲的FIFO
   - 考虑根据优先级将不同ID分配到不同FIFO

</div>

<div class="filter-cheatsheet" style="background-color:#e8eaf6;padding:15px;border-radius:5px;margin:10px 0;">

### 快速参考表

**过滤器配置关键参数**:

| 参数 | 选项 | 说明 |
|------|------|------|
| FilterBank | 0-13 (F1系列) | 选择过滤器组编号 |
| FilterMode | CAN_FILTERMODE_IDMASK<br>CAN_FILTERMODE_IDLIST | 掩码模式<br>列表模式 |
| FilterScale | CAN_FILTERSCALE_16BIT<br>CAN_FILTERSCALE_32BIT | 16位过滤器<br>32位过滤器 |
| FilterIdHigh/Low | 根据ID计算 | 过滤器ID的高/低16位 |
| FilterMaskIdHigh/Low | 根据需求计算 | 掩码的高/低16位或额外ID |
| FilterFIFOAssignment | CAN_FILTER_FIFO0<br>CAN_FILTER_FIFO1 | 分配到FIFO0<br>分配到FIFO1 |
| FilterActivation | ENABLE<br>DISABLE | 激活过滤器<br>禁用过滤器 |

**计算表**:

| 帧类型 | ID计算方法 | 掩码计算方法 |
|--------|------------|--------------|
| 标准帧(16位) | ID << 5 | 掩码 << 5 |
| 标准帧(32位) | ID << 21 | 掩码 << 21 |
| 扩展帧(32位) | (ID >> 13) \| (1 << 2) [高16位]<br>(ID << 3) & 0xFFFF [低16位] | 同ID计算方法 |

</div>

## STM32 CAN邮箱机制

<div class="mailbox-overview" style="background-color:#e8f5e9;padding:15px;border-radius:5px;border-left:5px solid #4CAF50;margin:10px 0;">

### 邮箱基本概念

STM32 CAN控制器使用"邮箱"机制管理报文的发送和接收。这种设计能够高效地处理CAN通信的异步特性，并减轻CPU负担。

**核心组件**：
- **发送邮箱(Transmit Mailboxes)**：3个独立邮箱，用于存放待发送的报文
- **接收FIFO(Receive FIFOs)**：2个FIFO队列，每个队列可存储3个接收到的报文
- **状态和控制寄存器**：管理邮箱状态、中断和优先级

邮箱机制的优势在于允许软件"排队"多条待发送的报文，并在后台自动处理发送过程，同时接收FIFO可以缓存接收到的报文，等待CPU处理。

</div>

<div class="tx-mailboxes" style="background-color:#e3f2fd;padding:15px;border-radius:5px;margin:10px 0;">

### 发送邮箱详解

STM32提供的3个发送邮箱允许同时排队最多3条待发送的CAN报文。

<details>
<summary><b>📊 邮箱内部结构</b>（点击展开）</summary>

每个发送邮箱包含以下寄存器：
- **TIxR**: 标识符寄存器(ID, IDE, RTR等)
- **TDTxR**: 数据长度寄存器(DLC)
- **TDLxR**: 低位数据寄存器(DATA[3:0])
- **TDHxR**: 高位数据寄存器(DATA[7:4])

<div style="text-align:center;margin:15px 0;">
<pre style="display:inline-block;text-align:left;">
┌─────────────────────────────────────────────────────┐
│                   发送邮箱结构                        │
├─────────────┬─────────────┬───────────┬─────────────┤
│    TIxR     │    TDTxR    │   TDLxR   │    TDHxR    │
│  标识符寄存器 │ 数据长度寄存器 │ 低位数据寄存器 │ 高位数据寄存器 │
├─────────────┴─────────────┴───────────┴─────────────┤
│             STM32 CAN控制器内部结构                   │
├─────────────┬─────────────┬───────────────────────────
│   邮箱 0    │   邮箱 1    │    邮箱 2   │    
│  (最高优先级) │             │             │    
└─────────────┴─────────────┴─────────────┘
</pre>
</div>

</details>

<details>
<summary><b>📝 发送邮箱状态</b>（点击展开）</summary>

发送邮箱的状态可通过TSR寄存器(Transmit Status Register)查询：

| 状态标志 | 描述 | 用途 |
|---------|------|------|
| TMEx | Transmit Mailbox Empty | 邮箱空闲，可用于新报文 |
| TAKRx | Transmit Acknowledge | 报文已被接受，等待发送 |
| TSRQx | Transmit Request | 邮箱中有报文等待发送 |
| TERRx | Transmit Error | 发送过程中发生错误 |
| ABRRQx | Abort Request | 发送中止请求标志 |

</details>

#### 发送流程概述

1. 准备CAN报文（配置ID、数据长度、数据内容等）
2. 调用`HAL_CAN_AddTxMessage()`请求发送
3. 处理发送请求结果（成功加入队列或所有邮箱已满）
4. 等待发送完成（可通过中断或轮询方式）

<details>
<summary><b>💻 详细代码示例</b>（点击展开）</summary>

```c
// 发送一条CAN报文的完整过程

// 1. 准备CAN报文
CAN_TxHeaderTypeDef TxHeader;
uint8_t TxData[8];
uint32_t TxMailbox;

// 配置报文头
TxHeader.StdId = 0x123;            // 设置ID
TxHeader.ExtId = 0;                // 不使用扩展ID
TxHeader.IDE = CAN_ID_STD;         // 标准帧
TxHeader.RTR = CAN_RTR_DATA;       // 数据帧
TxHeader.DLC = 8;                  // 数据长度为8字节
TxHeader.TransmitGlobalTime = DISABLE; // 不传输时间戳

// 准备数据
TxData[0] = 0x11;
TxData[1] = 0x22;
TxData[2] = 0x33;
TxData[3] = 0x44;
TxData[4] = 0x55;
TxData[5] = 0x66;
TxData[6] = 0x77;
TxData[7] = 0x88;

// 2. 请求发送并获取邮箱号
HAL_StatusTypeDef status = HAL_CAN_AddTxMessage(&hcan, &TxHeader, TxData, &TxMailbox);

// 3. 处理发送请求结果
if (status == HAL_OK) {
    // 成功将报文加入发送队列
    
    // 选择性等待发送完成
    while (HAL_CAN_GetTxMailboxesFreeLevel(&hcan) != 3) {
        // 等待所有邮箱变为空闲
        // 注意：在实际应用中应设置超时或使用中断
    }
} else {
    // 无法发送报文(所有邮箱已满)
    // 可以尝试中止某个低优先级报文
    // 或者等待某个邮箱变为空闲
}
```

</details>

#### 发送优先级管理

当多个邮箱同时请求发送时，CAN控制器根据以下规则决定优先级：

1. **CAN ID优先级**：低ID值的报文优先级更高
2. **邮箱固有优先级**：相同ID的情况下，邮箱0 > 邮箱1 > 邮箱2

<details>
<summary><b>🔄 中止发送请求</b>（点击展开）</summary>

在某些情况下，可能需要中止已经请求发送但尚未实际发送的报文：

```c
// 中止特定邮箱中的发送请求
HAL_StatusTypeDef HAL_CAN_AbortTxRequest(CAN_HandleTypeDef *hcan, uint32_t TxMailboxes)
{
    // TxMailboxes可以是:
    // CAN_TX_MAILBOX0, CAN_TX_MAILBOX1, CAN_TX_MAILBOX2
    // 或者它们的组合(按位或)
}

// 使用示例：中止邮箱0和邮箱1中的发送请求
HAL_CAN_AbortTxRequest(&hcan, CAN_TX_MAILBOX0 | CAN_TX_MAILBOX1);
```

</details>

</div>

<div class="rx-fifos" style="background-color:#fff8e1;padding:15px;border-radius:5px;margin:10px 0;">

### 接收FIFO详解

STM32 CAN控制器具有2个接收FIFO，每个都能存储最多3条接收到的报文。过滤器可以将不同的报文分配到这两个FIFO中。

<details>
<summary><b>📊 FIFO内部结构</b>（点击展开）</summary>

每个FIFO包含3个邮箱位置，每个包含以下寄存器：
- **RIxR**: 接收标识符寄存器
- **RDTxR**: 接收数据长度和时间戳寄存器
- **RDLxR**: 接收低位数据寄存器
- **RDHxR**: 接收高位数据寄存器

<div style="text-align:center;margin:15px 0;">
<pre style="display:inline-block;text-align:left;">
┌────────────────────────────────────────────┐
│              接收FIFO结构                   │
├────────────┬────────────┬────────────┬────┘
│   FIFO邮箱0  │  FIFO邮箱1  │  FIFO邮箱2  │
│  (最新接收)  │            │            │
└────────────┴────────────┴────────────┘
     ↑
  新报文
</pre>
</div>

</details>

<details>
<summary><b>📝 FIFO状态标志</b>（点击展开）</summary>

| 标志 | 描述 | 含义 |
|------|------|------|
| FMP0/1 | FIFO Message Pending | FIFO中待处理的报文数量(0-3) |
| FULL0/1 | FIFO Full | FIFO已满(包含3条报文) |
| FOVR0/1 | FIFO Overrun | FIFO溢出(新报文覆盖了未读报文) |
| RFOM0/1 | Release FIFO | 软件已读取FIFO数据，可以释放 |

</details>

#### 接收流程概述

1. 配置过滤器（决定哪些ID的报文被接收到哪个FIFO）
2. 配置接收FIFO中断或定期轮询FIFO状态
3. 在中断回调或轮询函数中读取接收到的报文
4. 处理接收到的数据

<details>
<summary><b>💻 中断方式接收代码示例</b>（点击展开）</summary>

```c
// 接收CAN报文的完整过程

// 1. 配置接收FIFO中断(在初始化时)
HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_MSG_PENDING);

// 2. 在中断回调函数中处理接收到的报文
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
    CAN_RxHeaderTypeDef RxHeader;
    uint8_t RxData[8];
    
    // 从FIFO中读取报文
    if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &RxHeader, RxData) == HAL_OK)
    {
        // 检查报文ID
        if (RxHeader.StdId == 0x123)
        {
            // 处理0x123 ID的报文
            ProcessMessage0x123(RxData);
        }
        else if (RxHeader.StdId == 0x456)
        {
            // 处理0x456 ID的报文
            ProcessMessage0x456(RxData);
        }
        
        // 可以检查FIFO状态，看是否还有更多报文
        uint32_t pending = HAL_CAN_GetRxFifoFillLevel(hcan, CAN_RX_FIFO0);
        if (pending > 0) {
            // 还有更多报文等待处理
            // 可以继续处理或设置标志通知主循环
        }
    }
}
```

</details>

<details>
<summary><b>💻 轮询方式接收代码示例</b>（点击展开）</summary>

```c
// 轮询方式接收报文
void PollCANMessages(void)
{
    CAN_RxHeaderTypeDef RxHeader;
    uint8_t RxData[8];
    
    // 检查FIFO0是否有待处理的报文
    while (HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO0) > 0)
    {
        // 读取一条报文
        if (HAL_CAN_GetRxMessage(&hcan, CAN_RX_FIFO0, &RxHeader, RxData) == HAL_OK)
        {
            // 处理报文
            ProcessCANMessage(&RxHeader, RxData);
        }
    }
    
    // 同样处理FIFO1
    while (HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO1) > 0)
    {
        if (HAL_CAN_GetRxMessage(&hcan, CAN_RX_FIFO1, &RxHeader, RxData) == HAL_OK)
        {
            ProcessCANMessage(&RxHeader, RxData);
        }
    }
}
```

</details>

<details>
<summary><b>⚠️ FIFO溢出处理</b>（点击展开）</summary>

当FIFO已满(3条报文)且新报文到达时，根据配置会有两种行为：
1. **覆盖最旧报文**：默认行为，新报文会覆盖最早接收的报文
2. **丢弃新报文**：如果设置了FIFO锁定模式，新报文会被丢弃

```c
// 配置FIFO锁定模式(在CAN初始化时)
hcan.Init.ReceiveFifoLocked = ENABLE;  // 启用FIFO锁定(不覆盖旧报文)
// 或
hcan.Init.ReceiveFifoLocked = DISABLE; // 禁用FIFO锁定(允许覆盖旧报文)
```

对于高速率接收场景，应监控FIFO溢出状态并处理：

```c
// 激活FIFO溢出中断
HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_OVERRUN);

// FIFO溢出中断处理
void HAL_CAN_ErrorCallback(CAN_HandleTypeDef *hcan)
{
    uint32_t errorCode = HAL_CAN_GetError(hcan);
    
    if (errorCode & HAL_CAN_ERROR_RX_FOV0)
    {
        // FIFO0溢出处理
        // 可能需要重置一些状态或记录错误
        OverrunCounter++;
    }
    
    if (errorCode & HAL_CAN_ERROR_RX_FOV1)
    {
        // FIFO1溢出处理
        OverrunCounter++;
    }
}
```

</details>

</div>

<details>
<summary><div class="mailbox-advanced" style="background-color:#e0f7fa;padding:15px;border-radius:5px;margin:10px 0;cursor:pointer;">
<h3>🔍 高级邮箱操作（点击展开）</h3>
</div></summary>

<div style="background-color:#e0f7fa;padding:15px;border-radius:5px;margin:10px 0;">

#### 发送完成状态检查

除了中断方式外，可以直接查询邮箱状态：

```c
// 查询特定邮箱状态
uint32_t mailboxStatus = HAL_CAN_IsTxMessagePending(&hcan, CAN_TX_MAILBOX0);
if (mailboxStatus == 0) {
    // 邮箱0已完成发送
}

// 获取所有空闲邮箱数量
uint32_t freeMailboxes = HAL_CAN_GetTxMailboxesFreeLevel(&hcan);
if (freeMailboxes == 3) {
    // 所有邮箱都空闲
}
```

#### 在发送邮箱之间选择

在某些情况下，可能需要手动选择使用哪个发送邮箱，特别是进行优先级控制时：

```c
// 手动选择发送邮箱的低级函数示例
HAL_StatusTypeDef ManualSelectTxMailbox(CAN_HandleTypeDef *hcan, 
                                        CAN_TxHeaderTypeDef *pHeader,
                                        uint8_t *pData, 
                                        uint8_t preferredMailbox)
{
    uint32_t mailboxes = 0;
    uint32_t tsrflags = READ_REG(hcan->Instance->TSR);
    
    // 检查首选邮箱是否空闲
    if (preferredMailbox == 0 && ((tsrflags & CAN_TSR_TME0) != 0)) {
        mailboxes = CAN_TX_MAILBOX0;
    }
    else if (preferredMailbox == 1 && ((tsrflags & CAN_TSR_TME1) != 0)) {
        mailboxes = CAN_TX_MAILBOX1;
    }
    else if (preferredMailbox == 2 && ((tsrflags & CAN_TSR_TME2) != 0)) {
        mailboxes = CAN_TX_MAILBOX2;
    }
    else {
        // 首选邮箱不可用，选择任何空闲邮箱
        if ((tsrflags & CAN_TSR_TME0) != 0) {
            mailboxes = CAN_TX_MAILBOX0;
        }
        else if ((tsrflags & CAN_TSR_TME1) != 0) {
            mailboxes = CAN_TX_MAILBOX1;
        }
        else if ((tsrflags & CAN_TSR_TME2) != 0) {
            mailboxes = CAN_TX_MAILBOX2;
        }
        else {
            return HAL_ERROR; // 所有邮箱都满
        }
    }
    
    // 发送报文
    return HAL_CAN_AddTxMessage(hcan, pHeader, pData, &mailboxes);
}
```

#### 发送超时处理

在关键应用中，应该实现发送超时检测：

```c
// 带超时的发送函数
HAL_StatusTypeDef CAN_TransmitWithTimeout(CAN_HandleTypeDef *hcan, 
                                         CAN_TxHeaderTypeDef *pHeader,
                                         uint8_t *pData, 
                                         uint32_t *pTxMailbox,
                                         uint32_t timeoutMs)
{
    HAL_StatusTypeDef status;
    uint32_t tickstart;
    
    // 尝试添加到发送邮箱
    status = HAL_CAN_AddTxMessage(hcan, pHeader, pData, pTxMailbox);
    if (status != HAL_OK) {
        return status;
    }
    
    // 等待发送完成或超时
    tickstart = HAL_GetTick();
    while (HAL_CAN_IsTxMessagePending(hcan, *pTxMailbox)) {
        if ((HAL_GetTick() - tickstart) > timeoutMs) {
            // 超时，尝试中止发送
            HAL_CAN_AbortTxRequest(hcan, *pTxMailbox);
            return HAL_TIMEOUT;
        }
    }
    
    return HAL_OK;
}
```

#### 动态优先级管理

在复杂的CAN网络中，可能需要根据系统状态动态调整报文优先级：

```c
// 根据系统状态选择发送邮箱和ID
void SendPrioritizedMessage(uint8_t *data, uint8_t systemState)
{
    CAN_TxHeaderTypeDef TxHeader;
    uint32_t TxMailbox;
    
    // 根据系统状态调整报文优先级
    if (systemState == SYSTEM_EMERGENCY) {
        // 紧急消息使用较低ID(高优先级)并优先使用邮箱0
        TxHeader.StdId = 0x100;
        
        // 检查邮箱0是否可用
        if ((hcan.Instance->TSR & CAN_TSR_TME0) != 0) {
            // 使用邮箱0发送
            TxMailbox = CAN_TX_MAILBOX0;
        } else {
            // 中止邮箱0中的发送，强制使用
            HAL_CAN_AbortTxRequest(&hcan, CAN_TX_MAILBOX0);
            TxMailbox = CAN_TX_MAILBOX0;
        }
    }
    else {
        // 普通消息使用较高ID(低优先级)
        TxHeader.StdId = 0x300;
        
        // 让硬件自动选择邮箱
        TxMailbox = 0;
    }
    
    // 设置其他报文头参数
    TxHeader.IDE = CAN_ID_STD;
    TxHeader.RTR = CAN_RTR_DATA;
    TxHeader.DLC = 8;
    
    // 发送报文
    HAL_CAN_AddTxMessage(&hcan, &TxHeader, data, &TxMailbox);
}
```

</div>
</details>

<details>
<summary><div class="mailbox-tips" style="background-color:#f9fbe7;padding:15px;border-radius:5px;border-left:5px solid #cddc39;margin:10px 0;cursor:pointer;">
<h3>💡 实用技巧与常见问题（点击展开）</h3>
</div></summary>

<div style="background-color:#f9fbe7;padding:15px;border-radius:5px;margin:10px 0;">

#### 1. 高效处理多报文接收

在高负载系统中，FIFO处理应快速高效：

```c
// 高效的FIFO处理
void OptimizedRxFifoProcessing(CAN_HandleTypeDef *hcan, uint32_t RxFifo)
{
    CAN_RxHeaderTypeDef RxHeader;
    uint8_t RxData[8];
    
    // 一次性处理FIFO中的所有报文
    uint32_t fillLevel = HAL_CAN_GetRxFifoFillLevel(hcan, RxFifo);
    for (uint32_t i = 0; i < fillLevel; i++)
    {
        if (HAL_CAN_GetRxMessage(hcan, RxFifo, &RxHeader, RxData) == HAL_OK)
        {
            // 快速处理报文 - 避免在中断中做复杂操作
            // 只复制数据到缓冲区，留待主循环处理
            StoreMessageForLaterProcessing(&RxHeader, RxData);
        }
    }
}
```

#### 2. 优先级反转问题

CAN优先级是基于ID的，但在某些情况下可能出现意外的优先级反转：

**问题**：低优先级报文已加载到邮箱0，但高优先级报文随后加载到邮箱1。由于邮箱0有更高的内部优先级，可能在总线仲裁中先于更重要的报文发送。

**解决方案**：
1. 确保重要报文先添加到发送队列
2. 在添加高优先级报文前，检查并清空所有邮箱
3. 使用中止请求功能

```c
// 发送高优先级报文前确保邮箱清空
void SendHighPriorityMessage(uint8_t *data)
{
    // 先中止所有待发送的报文
    HAL_CAN_AbortTxRequest(&hcan, CAN_TX_MAILBOX0 | CAN_TX_MAILBOX1 | CAN_TX_MAILBOX2);
    
    // 等待邮箱实际空闲
    while (HAL_CAN_GetTxMailboxesFreeLevel(&hcan) != 3) {
        // 短暂等待
    }
    
    // 现在发送高优先级报文
    CAN_TxHeaderTypeDef TxHeader;
    uint32_t TxMailbox;
    
    TxHeader.StdId = 0x050;  // 低ID = 高优先级
    TxHeader.IDE = CAN_ID_STD;
    TxHeader.RTR = CAN_RTR_DATA;
    TxHeader.DLC = 8;
    
    HAL_CAN_AddTxMessage(&hcan, &TxHeader, data, &TxMailbox);
}
```

#### 3. FIFO溢出防范策略

防止FIFO溢出的最佳实践：

1. **合理分配过滤器**：将高频率报文和低频率报文分配到不同FIFO
2. **优化中断处理**：减少中断回调函数中的处理时间
3. **使用双缓冲技术**：维护两个软件缓冲区，交替使用
4. **监控填充水平**：定期检查FIFO填充率，根据需要调整处理逻辑

```c
// 监控FIFO填充率
void MonitorFifoFillLevel(void)
{
    uint32_t fifo0Level = HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO0);
    uint32_t fifo1Level = HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO1);
    
    // 如果任一FIFO填充率过高，增加处理频率
    if (fifo0Level >= 2 || fifo1Level >= 2) {
        // FIFO接近满，增加处理频率
        SetCANProcessingFrequency(HIGH_FREQUENCY);
    } else {
        // FIFO负载较低，可以降低处理频率
        SetCANProcessingFrequency(NORMAL_FREQUENCY);
    }
}
```

#### 4. 调试邮箱问题

当出现邮箱相关问题时，这些调试技巧可能有用：

- 启用所有邮箱相关的中断，便于跟踪每个事件
- 使用LED或调试端口输出邮箱状态变化
- 实现邮箱统计计数器，记录满/空/溢出等状态

```c
// 邮箱状态监控结构体
typedef struct {
    uint32_t tx_requested;   // 发送请求次数
    uint32_t tx_completed;   // 发送完成次数
    uint32_t tx_aborted;     // 发送中止次数
    uint32_t tx_errors;      // 发送错误次数
    uint32_t rx_received;    // 接收报文次数
    uint32_t rx_overruns;    // 接收溢出次数
    uint32_t last_error_code; // 最后的错误代码
} CAN_Stats_t;

CAN_Stats_t can_stats = {0};

// 在中断或轮询中更新统计信息
void UpdateCANStats(void)
{
    // 示例：更新发送完成计数
    if ((hcan.Instance->TSR & CAN_TSR_TXOK0) != 0) {
        can_stats.tx_completed++;
    }
    
    // 可以添加更多统计项...
}
```

</div>
</details>

<details>
<summary><div class="mailbox-vs" style="background-color:#f3e5f5;padding:15px;border-radius:5px;margin:10px 0;cursor:pointer;">
<h3>📊 邮箱vs FIFO：区别与联系（点击展开）</h3>
</div></summary>

<div style="background-color:#f3e5f5;padding:15px;border-radius:5px;margin:10px 0;">

STM32的发送邮箱和接收FIFO在设计和使用上存在一些重要区别：

<table style="width:100%;border-collapse:collapse;margin:15px 0;text-align:center;">
<tr style="background-color:#9c27b0;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">特性</th>
  <th style="padding:8px;border:1px solid #ddd;">发送邮箱</th>
  <th style="padding:8px;border:1px solid #ddd;">接收FIFO</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:left;">数量</td>
  <td style="padding:8px;border:1px solid #ddd;">3个独立邮箱</td>
  <td style="padding:8px;border:1px solid #ddd;">2个FIFO，每个含3个邮箱</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:left;">优先级处理</td>
  <td style="padding:8px;border:1px solid #ddd;">基于ID和邮箱编号的双层优先级</td>
  <td style="padding:8px;border:1px solid #ddd;">先进先出，无内部优先级</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:left;">满状态行为</td>
  <td style="padding:8px;border:1px solid #ddd;">返回错误，需软件处理</td>
  <td style="padding:8px;border:1px solid #ddd;">可配置为覆盖或丢弃</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:left;">中断类型</td>
  <td style="padding:8px;border:1px solid #ddd;">发送完成、发送中止、错误</td>
  <td style="padding:8px;border:1px solid #ddd;">报文挂起、FIFO满、FIFO溢出</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:left;">手动控制</td>
  <td style="padding:8px;border:1px solid #ddd;">可主动中止、查询状态</td>
  <td style="padding:8px;border:1px solid #ddd;">只能读取和释放</td>
</tr>
</table>

</div>
</details>

## CAN收发器模块

<div style="background-color:#f0f8ff;padding:15px;border-radius:5px;margin:10px 0;">

常用的CAN收发器芯片包括：
- TJA1050/1051
- MCP2551
- SN65HVD230

这些收发器通常具有以下特性：
- 支持高达1Mbps的通信速率
- 保护功能：短路保护、过热保护
- 低功耗模式
- 高抗干扰能力

典型连接示例（以TJA1050为例）：
```
STM32   TJA1050   CAN总线
PA11 -----> RXD
PA12 <----- TXD
         --- CANH ----- CAN_H
         --- CANL ----- CAN_L
```

注意：
- 需要在CAN总线两端增加120Ω终端电阻
- 收发器通常需要5V供电，而STM32是3.3V，但大多数收发器RXD/TXD引脚兼容3.3V电平
- 对于长距离通信，建议使用双绞线并添加共模扼流圈

</div>

## CAN通信基本流程

<div class="can-flow" style="background-color:#e8f5e9;padding:15px;border-radius:5px;border-left:5px solid #4CAF50;margin:10px 0;">

### 初始化流程

```c
// 1. 初始化GPIO引脚
// 配置PA11为输入，PA12为推挽输出

// 2. 初始化CAN参数
hcan.Instance = CAN1;
hcan.Init.Prescaler = 9;         // 分频系数
hcan.Init.Mode = CAN_MODE_NORMAL; // 模式：普通、回环、静默等
hcan.Init.SyncJumpWidth = CAN_SJW_1TQ;
hcan.Init.TimeSeg1 = CAN_BS1_5TQ;
hcan.Init.TimeSeg2 = CAN_BS2_2TQ;
hcan.Init.TimeTriggeredMode = DISABLE;
hcan.Init.AutoBusOff = ENABLE;   // 自动管理总线关闭恢复
hcan.Init.AutoWakeUp = DISABLE;
hcan.Init.AutoRetransmission = ENABLE; // 自动重发
hcan.Init.ReceiveFifoLocked = DISABLE;
hcan.Init.TransmitFifoPriority = DISABLE;
HAL_CAN_Init(&hcan);

// 3. 配置过滤器
// 见前面的过滤器配置示例

// 4. 启动CAN
HAL_CAN_Start(&hcan);

// 5. 激活需要的中断
HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_MSG_PENDING);
```

### 发送报文

```c
// 发送一条CAN报文
CAN_TxHeaderTypeDef TxHeader;
uint8_t TxData[8];
uint32_t TxMailbox;

TxHeader.StdId = 0x123;             // 标准ID
TxHeader.ExtId = 0;                 // 扩展ID（不使用）
TxHeader.RTR = CAN_RTR_DATA;        // 数据帧
TxHeader.IDE = CAN_ID_STD;          // 标准帧
TxHeader.DLC = 8;                   // 数据长度

TxData[0] = 0x11;                   // 数据内容
TxData[1] = 0x22;
// ...填充其他数据...

// 发送报文
if (HAL_CAN_AddTxMessage(&hcan, &TxHeader, TxData, &TxMailbox) == HAL_OK) {
    // 发送请求成功，等待发送完成中断
} else {
    // 所有邮箱都被占用，需要等待或重试
}
```

### 接收报文（中断方式）

```c
// 在初始化中打开中断
HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_MSG_PENDING);

// 中断回调函数
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
    CAN_RxHeaderTypeDef RxHeader;
    uint8_t RxData[8];
    
    // 读取FIFO中的报文
    if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &RxHeader, RxData) == HAL_OK) {
        // 处理接收到的数据
        if (RxHeader.StdId == 0x123) {
            // 特定ID的处理逻辑
        }
    }
}
```

### 错误处理

```c
// 激活错误中断
HAL_CAN_ActivateNotification(&hcan, CAN_IT_ERROR);

// 错误处理回调
void HAL_CAN_ErrorCallback(CAN_HandleTypeDef *hcan)
{
    uint32_t errorCode = HAL_CAN_GetError(hcan);
    
    if (errorCode & HAL_CAN_ERROR_BOF) {
        // 总线关闭错误处理
    }
    if (errorCode & HAL_CAN_ERROR_STF) {
        // 位填充错误处理
    }
    // 处理其他错误...
}
```

</div>

## 常见问题与解决方案

<div style="background-color:#fce4ec;padding:15px;border-radius:5px;border-left:5px solid #E91E63;margin:10px 0;">

### 1. 无法发送/接收报文

**可能原因**：
- 位时序参数配置不当，通信各方波特率不一致
- 接线错误，CAN_H/CAN_L接反或未正确连接
- 终端电阻缺失或不正确（应为120Ω）
- 过滤器配置错误，过滤掉了目标报文

**解决方案**：
- 确认所有节点的波特率和位时序参数一致
- 检查CAN_H/CAN_L连接，确保差分信号正确
- 检查总线两端是否各有一个120Ω终端电阻
- 临时关闭过滤器（接收所有报文）进行测试

### 2. 频繁出现总线关闭状态

**可能原因**：
- 信号质量差，导致错误率高
- 波特率设置过高，超出物理条件限制
- 存在干扰源靠近CAN总线
- 总线上存在故障节点持续发送错误帧

**解决方案**：
- 降低波特率，提高系统容错能力
- 使用双绞线减少外部干扰
- 增加总线隔离器或采用光耦隔离
- 检查是否有节点发生故障，临时断开可疑节点

### 3. 高负载情况下丢失报文

**可能原因**：
- 接收FIFO溢出，新报文覆盖旧报文
- 处理中断的时间过长，无法及时取出FIFO中的报文
- 过滤器配置不当，多个ID映射到同一FIFO

**解决方案**：
- 优化中断处理函数，减少处理时间
- 合理分配过滤器，将高频率报文分配到不同FIFO
- 考虑使用CAN_FIFO_LOCKED模式避免覆盖
- 增加缓冲区，在中断中只进行数据复制，推迟处理

### 4. 时间戳不准确

**可能原因**：
- 未正确配置时间戳预分频器
- 系统时钟源不稳定
- 时间戳溢出处理不当

**解决方案**：
- 正确配置时间戳预分频值
- 使用稳定的外部时钟源
- 实现时间戳溢出处理逻辑
- 考虑使用硬件时间同步机制（如果支持）

</div> 