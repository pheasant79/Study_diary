# STM32的CAN实现

<div align="center">

![STM32 CAN](https://via.placeholder.com/600x150/4CAF50/FFFFFF?text=STM32%20CAN%E5%AE%9E%E7%8E%B0)

</div>

---

## 📑 目录

- [STM32的CAN实现](#stm32的can实现)
  - [STM32 CAN控制器特点](#stm32-can控制器特点)
  - [STM32与CAN总线的连接方式](#stm32与can总线的连接方式)
  - [STM32 CAN过滤器配置](#stm32-can过滤器配置)
  - [STM32 CAN邮箱机制](#stm32-can邮箱机制)
  - [CAN收发器模块](#can收发器模块)

---

## STM32 CAN控制器特点

<div class="stm32-features" style="background-color:#e8f4ff;padding:15px;border-radius:5px;border-left:5px solid #0078D7;margin:10px 0;">

STM32的CAN控制器集成了以下特性：
- 完全符合CAN协议2.0A和2.0B（主动）
- 位时序可编程
- 三个发送邮箱
- 两个接收FIFO，每个可存储3条消息
- 高级筛选器组，最多28个过滤器
- 中断功能：发送完成、接收FIFO、错误等
- 支持时间触发通信模式
- 支持睡眠模式和唤醒功能

</div>

## STM32与CAN总线的连接方式

STM32与CAN总线之间是通过CAN总线收发器连接的。收发器的作用是：
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

## STM32 CAN过滤器配置

<details>
<summary>📋 CAN过滤器详细说明</summary>

STM32的CAN模块提供了14个过滤器组(F1系列)，用于筛选接收的报文：

- 每个过滤器可以配置为标识符掩码模式或标识符列表模式
- 可以对标准帧ID或扩展帧ID进行筛选
- 过滤后的报文可以被发送到FIFO0或FIFO1

**过滤器模式**：
1. **掩码模式**：配置一个ID和一个掩码，掩码中的0表示"必须匹配"，1表示"可以不匹配"
2. **列表模式**：直接配置1-4个精确的ID，只接收完全匹配的报文

**过滤器配置步骤**：
1. 启用过滤器初始化模式
2. 设置过滤器类型、ID、掩码等参数
3. 指定过滤后的报文进入FIFO0或FIFO1
4. 使能过滤器
5. 退出过滤器初始化模式

```c
// 示例：配置过滤器0，接收标准ID为0x123的报文
CAN_FilterTypeDef canFilter;
canFilter.FilterBank = 0;                 // 使用过滤器0
canFilter.FilterMode = CAN_FILTERMODE_IDLIST;  // 列表模式
canFilter.FilterScale = CAN_FILTERSCALE_16BIT; // 16位过滤器
canFilter.FilterIdHigh = 0x123 << 5;      // 标准ID左移5位
canFilter.FilterIdLow = 0;
canFilter.FilterMaskIdHigh = 0;
canFilter.FilterMaskIdLow = 0;
canFilter.FilterFIFOAssignment = CAN_FILTER_FIFO0; // 过滤的报文存入FIFO0
canFilter.FilterActivation = ENABLE;      // 使能过滤器
HAL_CAN_ConfigFilter(&hcan, &canFilter);
```

</details>

## STM32 CAN邮箱机制

STM32 CAN控制器使用邮箱（Mailbox）机制管理报文的发送和接收：

**发送邮箱**：
- STM32有3个发送邮箱
- 当程序请求发送报文时，会根据优先级依次占用空闲的邮箱
- 已占用的邮箱会自动处理仲裁、位填充、CRC计算等过程
- 发送成功后会触发中断，邮箱变为空闲状态

**接收FIFO**：
- STM32有2个接收FIFO，每个FIFO可存储3个报文
- 过滤器可将报文分配到不同的FIFO
- 当FIFO满时，根据设置决定是否覆盖旧报文
- 接收到新报文或FIFO状态变化会触发中断

```
发送流程：
1. 检查是否有空闲邮箱
2. 将待发送数据填入空闲邮箱
3. 请求发送
4. 等待发送完成中断

接收流程：
1. 配置过滤器
2. 使能接收中断
3. 在中断处理函数中读取FIFO中的数据
```

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