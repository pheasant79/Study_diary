# CAN总线基础知识

<div align="center">

![CAN总线](https://via.placeholder.com/600x150/0078D7/FFFFFF?text=CAN%E6%80%BB%E7%BA%BF%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)

</div>

---

## 📑 目录

- [CAN总线基础知识](#can总线基础知识)
  - [CAN总线基本概念](#can总线基本概念)
  - [CAN总线电平特性](#can总线电平特性)
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

## CAN总线协议帧类型

<div style="overflow-x:auto;">

| 标准帧: | 起始位 | 仲裁场 (ID + RTR) | 控制场 (IDE + RTR + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |
| :-------: | :------: | :----------------: | :----------------------: | :----------------: | :----------------------: | :-----: | :----: | :--------: |
| 扩展帧: | 起始位 | 仲裁场 (ID(29位) + RTR) | 控制场 (IDE + r1 + r0 + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |

</div>

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