# CAN总线高级主题

<div align="center">

![CAN高级主题](https://via.placeholder.com/600x150/9C27B0/FFFFFF?text=CAN%E9%AB%98%E7%BA%A7%E4%B8%BB%E9%A2%98)

</div>

---

## 📑 目录

- [CAN总线高级主题](#can总线高级主题)
  - [📑 目录](#-目录)
  - [CAN特殊功能概述](#can特殊功能概述)
  - [时间触发通信模式](#时间触发通信模式)
  - [CAN FD协议](#can-fd协议)
  - [自动离线恢复与自动唤醒](#自动离线恢复与自动唤醒)
  - [禁止自动重传模式](#禁止自动重传模式)
  - [接收FIFO锁定模式](#接收fifo锁定模式)

---

## CAN特殊功能概述

<div style="background-color:#f0f0f0;padding:15px;border-radius:5px;margin:10px 0;">

STM32的CAN控制器除了标准的CAN功能外，还提供了一些特殊功能，可以满足特定应用场景的需求：

- **时间触发通信模式**：适用于需要精确时序控制的应用
- **自动离线恢复**：当CAN控制器进入Bus-Off状态时自动恢复
- **自动唤醒**：在睡眠模式下检测到总线活动时自动唤醒
- **禁止自动重传（NART）**：每条报文只发送一次，失败不重试
- **接收FIFO锁定模式**：控制FIFO满时的处理方式
- **发送优先级配置**：决定多个报文同时发送时的顺序
- **静默模式**：仅接收，不影响总线状态
- **环回模式**：用于内部测试，不需要外部连接

这些特殊功能使CAN控制器能够更灵活地应对各种应用场景，尤其是在对实时性、可靠性和功耗有特殊要求的场合。

</div>

## 时间触发通信模式

<details>
<summary>📡 时间触发通信模式（TTCM）详解</summary>

时间触发通信模式（Time Triggered Communication Mode）是一种严格基于时间的通信方式，主要用于需要精确时间控制的应用。

**主要特点**：
- 在每个CAN报文中添加时间戳
- 基于全局时间基准进行同步
- 适用于周期性数据交换的实时系统

**STM32中的TTCM**：
- 发送时，当设置了TransmitGlobalTime标志，时间戳会自动插入到报文中
- 接收时，控制器会记录报文接收的时间戳
- 时间戳的内容是自由运行的16位计数器的值

**配置示例**：
```c
// 启用时间触发通信模式
hcan.Init.TimeTriggeredMode = ENABLE;

// 发送报文时启用时间戳
TxHeader.TransmitGlobalTime = ENABLE;
```

**应用场景**：
- 汽车电子稳定系统（ESP）
- 分布式控制系统
- 要求严格时间同步的测量系统

**优势**：
- 更高的确定性和实时性
- 减少总线上的冲突
- 提高系统的可预测性

</details>

## CAN FD协议

<div class="can-fd" style="background-color:#e8f5e9;padding:15px;border-radius:5px;border-left:5px solid #4CAF50;margin:10px 0;">

CAN FD（CAN with Flexible Data-rate）是CAN协议的扩展版本，具有以下特点：

1. **更大的数据载荷**
   - 传统CAN: 最多8字节
   - CAN FD: 最多64字节

2. **更高的数据传输速率**
   - 仲裁阶段使用标准CAN速率（最高1Mbps）
   - 数据阶段可提高至8Mbps甚至更高

3. **更高效的CRC校验**
   - 改进的CRC算法，提高错误检测能力

4. **向后兼容性**
   - CAN FD节点可以在传统CAN网络中工作（以传统模式）
   - 传统CAN节点可以接收CAN FD报文的仲裁字段，但会将数据字段视为错误

**STM32中的CAN FD支持**：
- 部分新型STM32系列（如STM32G4、STM32H7等）支持CAN FD
- STM32F1系列不支持CAN FD

**使用CAN FD的优势**：
- 减少大数据量传输时的总线负载
- 提高系统响应速度
- 适用于需要传输较大数据块的应用（如软件更新）

</div>

## 自动离线恢复与自动唤醒

<details>
<summary>🔄 自动离线恢复（ABOM）</summary>

**自动离线恢复**（Automatic Bus-Off Management）是STM32 CAN控制器的一项功能，用于处理总线关闭（Bus-Off）状态。

**背景**：
- 当发送错误计数器超过255时，CAN控制器会进入Bus-Off状态
- 在此状态下，控制器停止参与总线活动

**标准CAN协议要求**：
- 控制器检测到128个连续的11个隐性位序列后才能退出Bus-Off状态
- 这需要软件干预来监控和控制恢复过程

**ABOM功能**：
- 使能后，控制器会自动执行恢复过程
- 无需软件干预，降低CPU负担
- 在检测到规定的隐性位序列后自动恢复正常操作

**配置示例**：
```c
// 启用自动离线恢复
hcan.Init.AutoBusOff = ENABLE;
```

**适用场景**：
- 需要高可靠性的长时间运行系统
- 无法频繁进行软件干预的应用
- 抗干扰要求高的环境

</details>

<details>
<summary>⏰ 自动唤醒（AWUM）</summary>

**自动唤醒**（Automatic Wake-Up Mode）是STM32 CAN控制器的低功耗管理功能。

**工作原理**：
- CAN控制器可以进入睡眠模式以降低功耗
- 在睡眠模式下，大部分CAN电路被关闭
- 当启用自动唤醒时，控制器会保持最小的监控电路活动

**唤醒条件**：
- 检测到CAN总线上的起始位（SOF）
- 软件请求唤醒

**自动唤醒的优势**：
- 无需外部中断唤醒MCU
- 降低系统功耗
- 保持对总线事件的响应能力

**配置示例**：
```c
// 启用自动唤醒
hcan.Init.AutoWakeUp = ENABLE;

// 进入睡眠模式
HAL_CAN_RequestSleep(&hcan);

// 检查是否在睡眠模式
if (HAL_CAN_IsSleepActive(&hcan) == HAL_OK) {
  // CAN控制器已进入睡眠模式
}

// 如果需要手动唤醒
HAL_CAN_WakeUp(&hcan);
```

**适用场景**：
- 电池供电的系统
- 需要长时间待机的设备
- 车载系统中的低功耗模式

</details>

## 禁止自动重传模式

<div style="background-color:#fff3e0;padding:15px;border-radius:5px;margin:10px 0;">

**禁止自动重传模式**（No Automatic Retransmission，NART）是STM32 CAN控制器的一个特殊功能：

1. **标准CAN行为**：
   - 默认情况下，CAN控制器会自动重传失败的报文（因总线仲裁丢失或错误）
   - 重传会一直进行，直到成功发送或发生总线错误

2. **NART模式下的行为**：
   - 每个报文只发送一次
   - 如果发送失败（仲裁丢失或错误），不会自动重试
   - 邮箱会立即被释放，可用于发送新报文

3. **配置方法**：
   ```c
   // 启用禁止自动重传模式
   hcan.Init.AutoRetransmission = DISABLE;
   ```

4. **适用场景**：
   - 实时系统，其中过时的数据没有价值
   - 高周期性更新的数据（如传感器读数）
   - 需要严格控制报文发送时机的应用

5. **优势**：
   - 避免过时数据占用总线带宽
   - 提高时间敏感数据的实时性
   - 可以更精确地控制发送时序

6. **注意事项**：
   - 使用此模式会降低数据传输的可靠性
   - 应用程序需要处理发送失败的情况
   - 不适合对数据完整性要求高的场景

</div>

## 接收FIFO锁定模式

<details>
<summary>🔒 接收FIFO锁定模式（RFLM）详解</summary>

**接收FIFO锁定模式**（Receive FIFO Locked Mode，RFLM）控制CAN控制器在接收FIFO满时的行为：

**标准模式（RFLM禁用）**：
- 当新的报文到达且FIFO已满时，最早接收的报文会被覆盖
- FIFO始终包含最新接收的报文
- 设置溢出标志，但继续接收新报文

**锁定模式（RFLM启用）**：
- 当FIFO满时，拒绝接收新报文
- 已接收的报文被保护，不会被覆盖
- 设置溢出标志，但新报文会被丢弃

**配置方法**：
```c
// 启用接收FIFO锁定模式
hcan.Init.ReceiveFifoLocked = ENABLE;
```

**使用场景**：
- 需要保证已接收数据完整性的系统
- 无法及时处理FIFO中所有报文的应用
- 对丢失新报文比覆盖旧报文更可接受的场景

**处理FIFO溢出**：
```c
// 检查FIFO0溢出
if (HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO0) == 3) {
  // FIFO0已满
  if (__HAL_CAN_GET_FLAG(&hcan, CAN_FLAG_FF0)) {
    // 发生了溢出
    __HAL_CAN_CLEAR_FLAG(&hcan, CAN_FLAG_FF0);
    
    // 处理溢出情况...
  }
}
```

**注意事项**：
- 锁定模式下必须及时处理FIFO中的报文
- 应用程序需要监控溢出标志
- 考虑增加接收处理的优先级或频率

</details> 