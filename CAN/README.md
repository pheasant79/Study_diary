# CAN总线基础知识

<div align="center">

![CAN总线](https://via.placeholder.com/600x150/0078D7/FFFFFF?text=CAN%E6%80%BB%E7%BA%BF%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)

</div>

---

## 📑 目录

- [CAN总线基础知识](#can总线基础知识)
  - [📑 目录](#-目录)
  - [什么是CAN总线？它存在的重要意义是什么？](#什么是can总线它存在的重要意义是什么)
    - [CAN总线电平特性](#can总线电平特性)
  - [CAN总线协议中规定的主要帧类型及构成](#can总线协议中规定的主要帧类型及构成)
    - [帧类型说明](#帧类型说明)
  - [STM32的CAN外设特点](#stm32的can外设特点)
    - [STM32与CAN总线的连接方式](#stm32与can总线的连接方式)
  - [CAN总线的应用场景](#can总线的应用场景)
  - [常见问题](#常见问题)
  - [参考资料](#参考资料)

---

## 什么是CAN总线？它存在的重要意义是什么？

<details>
<summary>📖 点击展开详细介绍</summary>

CAN总线（Controller Area Network）是一种差分信号通信协议，它与RS-232、RS-485、RS-422不同，不是串口通信(UART)的点对点通信，而是采用差分电平的多主机通信网络。

> 💡 **知识要点**: CAN总线是一种多主方式的串行通信总线，最初是由德国BOSCH公司为汽车行业开发的。

差分电平通信具有以下优势：
- 通信速度快（最高可达1Mbps）
- 抗干扰能力强，适合在汽车环境、恶劣电磁辐射环境中使用
- 可靠性高，具有完善的错误检测和处理机制

</details>

### CAN总线电平特性

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

---

## CAN总线协议中规定的主要帧类型及构成

<div style="overflow-x:auto;">

| 标准帧: | 起始位 | 仲裁场 (ID + RTR) | 控制场 (IDE + RTR + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |
| :-------: | :------: | :----------------: | :----------------------: | :----------------: | :----------------------: | :-----: | :----: | :--------: |
| 扩展帧: | 起始位 | 仲裁场 (ID(29位) + RTR) | 控制场 (IDE + r1 + r0 + DLC) | 数据场 (0-8字节) | CRC场 (15位CRC + 分界符) | ACK场 | 结束符 | 帧间间隔 |

</div>

### 帧类型说明

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

---

## STM32的CAN外设特点

<div class="stm32-features" style="background-color:#e8f4ff;padding:15px;border-radius:5px;border-left:5px solid #0078D7;margin:10px 0;">

STM32的CAN控制器集成了以下特性：
- 支持CAN协议2.0A和2.0B（主动）
- 位时序可编程
- 三个发送邮箱
- 接收FIFO，带有筛选器组

</div>

STM32与CAN总线之间是通过CAN总线收发器连接的。收发器的作用是：
1. 将单片机发出的数字信号(0和1)转换为CAN总线上的差分信号(CAN-H和CAN-L)
2. 将CAN总线上的差分信号转换为单片机能够识别的数字信号(0和1)

### STM32与CAN总线的连接方式

```
+----------+          +------------+          +-----------+
|          |   TXD    |            |  CAN_H   |           |
|  STM32   |--------->| CAN收发器  |--------->|  CAN总线  |
| 控制器   |   RXD    |            |  CAN_L   |           |
|          |<---------|            |<---------|           |
+----------+          +------------+          +-----------+
```

STM32只需要两个引脚即可与CAN收发器通信：
- **TXD**：发送引脚，输出0和1信号，经过收发器转换为CAN总线上的差分信号
- **RXD**：接收引脚，CAN总线的差分信号经过收发器转换后输入到此引脚

---

## CAN总线的应用场景

<div class="applications" style="display:flex;flex-wrap:wrap;justify-content:space-around;text-align:center;margin:20px 0;">

<div style="width:150px;margin:10px;padding:15px;background-color:#f0f0f0;border-radius:8px;">
📱<br>汽车内部网络通信
</div>

<div style="width:150px;margin:10px;padding:15px;background-color:#f0f0f0;border-radius:8px;">
🏭<br>工业自动化控制系统
</div>

<div style="width:150px;margin:10px;padding:15px;background-color:#f0f0f0;border-radius:8px;">
🏥<br>医疗设备
</div>

<div style="width:150px;margin:10px;padding:15px;background-color:#f0f0f0;border-radius:8px;">
🏢<br>智能建筑
</div>

<div style="width:150px;margin:10px;padding:15px;background-color:#f0f0f0;border-radius:8px;">
✈️<br>航空电子设备
</div>

</div>

---

## 常见问题

<details>
<summary>CAN总线的最大通信距离是多少？</summary>

CAN总线的通信距离与波特率相关：
- 1Mbps：最大距离约40米
- 500kbps：最大距离约100米
- 125kbps：最大距离约500米
- 10kbps：最大距离可达几公里

通信距离还受到总线拓扑结构、终端电阻和电缆质量的影响。
</details>

<details>
<summary>CAN总线需要终端电阻吗？</summary>

是的，CAN总线两端需要120Ω的终端电阻以防止信号反射。在高速CAN网络中，这些电阻连接在CAN_H和CAN_L线之间。
</details>

<details>
<summary>CAN总线如何处理冲突？</summary>

CAN总线使用CSMA/CD+AMP（带有仲裁的载波侦听多路访问/冲突检测）机制处理冲突。当多个节点同时发送时，通过ID仲裁决定优先级，ID值较低的节点获得总线访问权。
</details>

---

## 参考资料

- [BOSCH CAN规范 2.0](https://www.bosch-semiconductors.com/media/ip_modules/pdf_2/can_literature_and_more/can_specification_2_0.pdf)
- [ISO 11898 标准](https://www.iso.org/standard/63648.html)
- [STM32 CAN外设应用指南](https://www.st.com/resource/en/application_note/an4230-can-protocol-used-in-the-stm32-bootloader-stmicroelectronics.pdf)

---

<div align="center">
<p style="color:#888;">最后更新: 2023年12月</p>
</div>