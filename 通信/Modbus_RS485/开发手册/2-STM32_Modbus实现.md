# STM32 Modbus实现

<div align="center">

![STM32 Modbus实现](https://via.placeholder.com/600x150/2196F3/FFFFFF?text=STM32%20Modbus%E5%AE%9E%E7%8E%B0)

</div>

---

## 📑 目录

- [STM32 Modbus实现](#stm32-modbus实现)
  - [STM32 UART控制器特点](#stm32-uart控制器特点)
  - [STM32与RS485总线的连接方式](#stm32与rs485总线的连接方式)
  - [STM32实现Modbus协议栈](#stm32实现modbus协议栈)
  - [RS485收发器选型与配置](#rs485收发器选型与配置)
  - [半双工通信控制](#半双工通信控制)

---

## STM32 UART控制器特点

<div style="background-color:#e1f5fe;padding:15px;border-radius:5px;margin:10px 0;">

STM32系列微控制器的UART/USART控制器具有以下特点，使其非常适合Modbus-RTU通信：

1. **灵活的波特率生成**
   - 内部波特率发生器，支持多种标准波特率（2400到115200 bps）
   - 误差控制在±2%以内，满足Modbus通信要求
   - 支持小数波特率生成，可以实现更精确的时序控制

2. **多种帧格式支持**
   - 可配置数据位：8或9位
   - 可配置停止位：1或2位
   - 可配置奇偶校验
   - 支持LSB或MSB优先传输

3. **中断功能**
   - 接收完成中断
   - 发送完成中断
   - 发送数据寄存器空中断
   - 空闲线检测中断（**特别适合Modbus-RTU的帧结束检测**）
   - 奇偶校验错误中断

4. **DMA支持**
   - 接收和发送都支持DMA传输
   - 减少CPU占用，提高通信效率
   - 特别适合批量接收和发送Modbus数据帧

5. **硬件流控制**
   - RTS/CTS流控制（对于RS485通信，可利用RTS信号控制收发方向）
   - 智能卡接口支持

6. **错误检测**
   - 硬件奇偶校验错误检测
   - 帧错误检测
   - 噪声检测
   - 溢出错误检测

7. **多UART外设**
   - 根据不同型号，可能有2-8个独立UART/USART
   - 支持多串口同时工作

</div>

## STM32与RS485总线的连接方式

<div style="background-color:#fff8e1;padding:15px;border-radius:5px;margin:10px 0;">

STM32与RS485总线连接需要通过RS485收发器芯片实现，常见连接方式如下：

### 标准连接方式

```
   STM32                     RS485收发器                RS485总线
┌─────────┐               ┌────────────┐             ┌───────────┐
│         │──── TX ─────→│ DI          │             │           │
│         │               │            │──── A ─────→│    A      │
│ UART Tx │               │ DE         │             │           │
│         │               │            │             │ RS485总线 │
│ UART Rx │               │ RE         │             │           │
│         │               │            │──── B ─────→│    B      │
│         │←─── RX ─────→│ RO          │             │           │
│         │               └────────────┘             └───────────┘
│  GPIO   │──── DE/RE ──→│ DE/RE       │
└─────────┘               │            │
                          │            │
                          │ GND  VCC   │
                          └─────┬──────┘
                                │
                                ▼
                          电源和接地连接
```

### 功能描述

- **UART Tx** - STM32的UART发送引脚，连接到RS485收发器的DI（Driver Input）引脚
- **UART Rx** - STM32的UART接收引脚，连接到RS485收发器的RO（Receiver Output）引脚
- **GPIO** - STM32的GPIO引脚，用于控制RS485收发器的方向（发送/接收）
  - 连接到DE（Driver Enable，驱动使能）
  - 在许多RS485芯片中，RE（Receiver Enable，接收使能）是DE的反相输入，可以一起控制
- **A/B线** - RS485差分信号线，连接到RS485总线

### 注意事项

1. **电平匹配**
   - STM32的UART使用TTL电平（0-3.3V）
   - RS485使用差分电平（典型值±2V~±6V）
   - RS485收发器负责电平转换

2. **方向控制**
   - RS485是半双工通信，必须通过DE/RE引脚控制数据方向
   - 发送时：DE=1, RE=0（有些芯片RE为低电平有效，此时为RE=1）
   - 接收时：DE=0, RE=1（有些芯片RE为低电平有效，此时为RE=0）

3. **电源与接地**
   - RS485收发器通常需要3.3V或5V电源
   - 必须保证良好的接地连接，减少共模干扰

4. **多机互联**
   - 多机通信时需要使用总线拓扑结构
   - 总线两端需要接120Ω终端电阻

</div>

## STM32实现Modbus协议栈

<div style="background-color:#e8f5e9;padding:15px;border-radius:5px;margin:10px 0;">

在STM32上实现一个完整的Modbus协议栈，可以采用分层设计方法：

### 1. 物理层

负责RS485信号收发和电平转换：

<details>
<summary>📌 <b>RS485基本控制函数</b> (点击展开查看代码)</summary>

```c
// 方向控制宏定义
#define RS485_RX_MODE()  HAL_GPIO_WritePin(DE_RE_GPIO_Port, DE_RE_Pin, GPIO_PIN_RESET)
#define RS485_TX_MODE()  HAL_GPIO_WritePin(DE_RE_GPIO_Port, DE_RE_Pin, GPIO_PIN_SET)

// 单字节发送函数
void RS485_SendByte(uint8_t data)
{
  RS485_TX_MODE();  // 切换为发送模式
  HAL_UART_Transmit(&huart1, &data, 1, 100);
  // 需要等待发送完成
  while(!(huart1.Instance->SR & UART_FLAG_TC));
  RS485_RX_MODE();  // 切换为接收模式
}

// 多字节发送函数
void RS485_SendBytes(uint8_t *data, uint16_t size)
{
  RS485_TX_MODE();  // 切换为发送模式
  HAL_UART_Transmit(&huart1, data, size, 1000);
  // 需要等待发送完成
  while(!(huart1.Instance->SR & UART_FLAG_TC));
  RS485_RX_MODE();  // 切换为接收模式
}

// 接收配置 - 采用中断方式接收
void RS485_StartReceive(void)
{
  RS485_RX_MODE();  // 确保处于接收模式
  HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
}
```
</details>

### 2. 数据链路层

负责帧格式管理、错误检测和超时控制：

<details>
<summary>📌 <b>CRC校验和帧处理函数</b> (点击展开查看代码)</summary>

```c
// CRC16计算函数
uint16_t ModbusCRC16(uint8_t *buffer, uint16_t length)
{
  uint16_t crc = 0xFFFF;
  
  while (length--)
  {
    crc ^= *buffer++;
    for (uint8_t i = 0; i < 8; i++)
    {
      if (crc & 0x0001)
      {
        crc >>= 1;
        crc ^= 0xA001;
      }
      else
      {
        crc >>= 1;
      }
    }
  }
  
  return crc;
}

// RTU帧接收处理
void Modbus_ReceiveFrame(void)
{
  // 启动帧接收定时器 (3.5个字符时间)
  __HAL_TIM_SET_COUNTER(&htim2, 0);
  HAL_TIM_Base_Start_IT(&htim2);
  
  // 将接收到的字节存入缓冲区
  ModbusRxBuffer[ModbusRxCount++] = RxTemp;
  
  // 防止缓冲区溢出
  if (ModbusRxCount >= MODBUS_BUFFER_SIZE)
  {
    ModbusRxCount = 0;
  }
  
  // 继续接收下一个字节
  HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
}

// 帧超时处理 - 在定时器中断中调用
void Modbus_FrameTimeout(void)
{
  HAL_TIM_Base_Stop_IT(&htim2);
  
  // 至少收到4个字节才可能是有效帧
  if (ModbusRxCount >= 4)
  {
    // 验证CRC
    uint16_t receivedCRC = (ModbusRxBuffer[ModbusRxCount-1] << 8) | ModbusRxBuffer[ModbusRxCount-2];
    uint16_t calculatedCRC = ModbusCRC16(ModbusRxBuffer, ModbusRxCount-2);
    
    if (receivedCRC == calculatedCRC)
    {
      // CRC验证通过，处理有效帧
      ModbusFrameReady = 1;
    }
    else
    {
      // CRC错误，放弃该帧
      ModbusRxCount = 0;
    }
  }
  else
  {
    // 太短的帧视为无效
    ModbusRxCount = 0;
  }
}
```
</details>

### 3. 应用层

实现Modbus协议的功能码处理：

<details>
<summary>📌 <b>Modbus功能码处理</b> (点击展开查看代码)</summary>

```c
// Modbus功能码处理
void Modbus_ProcessFrame(void)
{
  uint8_t slaveAddress = ModbusRxBuffer[0];
  uint8_t functionCode = ModbusRxBuffer[1];
  uint16_t startAddress, quantity;
  uint16_t responseLength = 0;
  
  // 检查地址是否匹配
  if (slaveAddress != ModbusSlaveAddress && slaveAddress != 0)
  {
    // 不是发给本机的，忽略
    ModbusRxCount = 0;
    return;
  }
  
  // 解析起始地址和数量
  startAddress = (ModbusRxBuffer[2] << 8) | ModbusRxBuffer[3];
  quantity = (ModbusRxBuffer[4] << 8) | ModbusRxBuffer[5];
  
  // 根据功能码处理
  switch (functionCode)
  {
    case 0x01:  // 读线圈
      responseLength = Modbus_ReadCoils(startAddress, quantity);
      break;
      
    case 0x03:  // 读保持寄存器
      responseLength = Modbus_ReadHoldingRegisters(startAddress, quantity);
      break;
      
    case 0x06:  // 写单个寄存器
      responseLength = Modbus_WriteSingleRegister(startAddress, quantity);
      break;
      
    case 0x10:  // 写多个寄存器
      responseLength = Modbus_WriteMultipleRegisters(startAddress, quantity);
      break;
      
    default:  // 不支持的功能码
      responseLength = Modbus_GenerateException(functionCode, 0x01);
      break;
  }
  
  // 如果需要响应（非广播地址）
  if (slaveAddress != 0 && responseLength > 0)
  {
    // 添加CRC校验
    uint16_t crc = ModbusCRC16(ModbusTxBuffer, responseLength);
    ModbusTxBuffer[responseLength++] = crc & 0xFF;
    ModbusTxBuffer[responseLength++] = (crc >> 8) & 0xFF;
    
    // 发送响应
    RS485_SendBytes(ModbusTxBuffer, responseLength);
  }
  
  // 重置接收计数
  ModbusRxCount = 0;
}
```
</details>

### 4. 用户层接口

提供Modbus数据存取和操作接口：

<details>
<summary>📌 <b>Modbus用户接口函数</b> (点击展开查看代码)</summary>

```c
// 初始化Modbus寄存器/线圈存储区
void Modbus_Init(void)
{
  // 初始化寄存器/线圈存储区
  memset(HoldingRegisters, 0, sizeof(HoldingRegisters));
  memset(InputRegisters, 0, sizeof(InputRegisters));
  memset(Coils, 0, sizeof(Coils));
  memset(DiscreteInputs, 0, sizeof(DiscreteInputs));
  
  // 配置定时器用于帧结束检测
  // 定时时间 = 3.5 * 字符时间
  // 例如9600波特率，1个字符约1.042ms (11位，包括起始位和停止位)
  // 因此3.5个字符约3.647ms
  TimerPeriod = (3.5 * 11 * 1000) / Baudrate;  // 毫秒
  
  // 配置RS485方向控制引脚
  HAL_GPIO_WritePin(DE_RE_GPIO_Port, DE_RE_Pin, GPIO_PIN_RESET);  // 默认接收模式
  
  // 启动接收
  RS485_StartReceive();
}

// 用户接口：读保持寄存器
uint16_t Modbus_GetHoldingRegister(uint16_t address)
{
  if (address < MAX_HOLDING_REGISTERS)
  {
    return HoldingRegisters[address];
  }
  return 0;
}

// 用户接口：写保持寄存器
void Modbus_SetHoldingRegister(uint16_t address, uint16_t value)
{
  if (address < MAX_HOLDING_REGISTERS)
  {
    HoldingRegisters[address] = value;
  }
}

// 用户接口：读线圈状态
uint8_t Modbus_GetCoilStatus(uint16_t address)
{
  if (address < MAX_COILS)
  {
    return (Coils[address / 8] >> (address % 8)) & 0x01;
  }
  return 0;
}

// 用户接口：设置线圈状态
void Modbus_SetCoilStatus(uint16_t address, uint8_t status)
{
  if (address < MAX_COILS)
  {
    if (status)
    {
      Coils[address / 8] |= (1 << (address % 8));
    }
    else
    {
      Coils[address / 8] &= ~(1 << (address % 8));
    }
  }
}
```
</details>

### 5. 整合与运行

在主循环中调用Modbus处理函数：

<details>
<summary>📌 <b>主程序代码和中断回调</b> (点击展开查看代码)</summary>

```c
int main(void)
{
  /* MCU初始化代码 */
  
  /* Modbus初始化 */
  Modbus_Init();
  
  while (1)
  {
    /* 检查是否有完整的Modbus帧需要处理 */
    if (ModbusFrameReady)
    {
      ModbusFrameReady = 0;
      Modbus_ProcessFrame();
    }
    
    /* 用户应用代码 */
    // 例如: 更新输入寄存器的值
    InputRegisters[0] = HAL_ADC_GetValue(&hadc1);
    
    /* 其他任务 */
  }
}

/* UART接收中断回调 */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart->Instance == USART1)
  {
    Modbus_ReceiveFrame();
  }
}

/* 定时器中断回调 - 用于帧结束检测 */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  if (htim->Instance == TIM2)
  {
    Modbus_FrameTimeout();
  }
}
```
</details>

### 标准连接方式

<details>
<summary>📌 <b>STM32-RS485接口连接图</b> (点击展开查看)</summary>

```
   STM32                     RS485收发器                RS485总线
┌─────────┐               ┌────────────┐             ┌───────────┐
│         │──── TX ─────→│ DI          │             │           │
│         │               │            │──── A ─────→│    A      │
│ UART Tx │               │ DE         │             │           │
│         │               │            │             │ RS485总线 │
│ UART Rx │               │ RE         │             │           │
│         │               │            │──── B ─────→│    B      │
│         │←─── RX ─────→│ RO          │             │           │
│         │               └────────────┘             └───────────┘
│  GPIO   │──── DE/RE ──→│ DE/RE       │
└─────────┘               │            │
                          │            │
                          │ GND  VCC   │
                          └─────┬──────┘
                                │
                                ▼
                          电源和接地连接
```
</details>

#### 基本接口电路

<details>
<summary>📌 <b>基本RS485接口电路示意图</b> (点击展开查看)</summary>

```
      VCC
       │
       ↓
       R1
       │
       ├─────┐
STM32   │     │    RS485收发器
       │     │
TX ────┤DI   A├────→ 总线A线─┐
       │     │             R3 (120Ω终端电阻)
RX ←───┤RO   B├────→ 总线B线─┘
       │     │
GPIO ──┤DE/RE │
       │     │
      GND    R2    
             │     
             ↓     
            GND    
```
</details>

#### 带保护的增强型接口电路

<details>
<summary>📌 <b>带保护的增强型接口电路</b> (点击展开查看)</summary>

```
      VCC
       │
       ↓
       R1     TVS1
       │       │
       ├─────┐ ┌┤
STM32   │     │ │
       │     │ │
TX ────┤DI   A├─┼──→ 总线A线──┐
       │     │ │            R3 (120Ω终端电阻)
RX ←───┤RO   B├─┼──→ 总线B线──┘
       │     │ │
GPIO ──┤DE/RE │ └┤
       │     │   TVS2
      GND    R2    
             │     
             ↓     
            GND    
```
</details>

### 发送/接收切换的时序控制

<details>
<summary>📌 <b>RS485发送/接收切换时序图</b> (点击展开查看)</summary>

```
             ┌───────┐            ┌───────┐
发送使能 DE   │       │            │       │
          ───┘       └────────────┘       └──────
             ▲       ▲            ▲       ▲
             │       │            │       │
             │       │            │       │
             │       │            │       │
数据传输    ──┐   ┌───┐   ┌─────┐   ┌───┐   ┌─────
             │Tx1│   │Tx2│     │Rx1│   │Rx2│
             └───┘   └───┘     └───┘   └───┘
             ▲       ▲            ▲       ▲
             │       │            │       │
             │A      │B           │C      │D
```
</details>

#### 方法一：查询方式

<details>
<summary>📌 <b>查询方式实现代码</b> (点击展开查看)</summary>

```c
// 发送数据（查询方式）
void RS485_SendData(uint8_t *data, uint16_t size)
{
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 延时确保DE信号稳定（微秒级）
  delayMicroseconds(5);
  
  // 发送数据
  HAL_UART_Transmit(&huart1, data, size, HAL_MAX_DELAY);
  
  // 等待发送完成 - 检查TC标志
  while (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_TC) == RESET);
  
  // 延时确保最后一个位发送完成
  delayMicroseconds(5);
  
  // 切换回接收模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
}
```
</details>

#### 方法二：中断方式

<details>
<summary>📌 <b>中断方式实现代码</b> (点击展开查看)</summary>

```c
// 发送状态标志
volatile uint8_t RS485_Transmitting = 0;

// 开始发送数据（中断方式）
void RS485_StartTransmit(uint8_t *data, uint16_t size)
{
  // 标记为发送状态
  RS485_Transmitting = 1;
  
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 延时确保DE信号稳定
  delayMicroseconds(5);
  
  // 启动UART发送（中断方式）
  HAL_UART_Transmit_IT(&huart1, data, size);
}

// UART发送完成回调
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart->Instance == USART1 && RS485_Transmitting)
  {
    // 发送完成，延时一小段时间，确保最后一个位发送完成
    delayMicroseconds(5);
    
    // 切换回接收模式
    HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
    
    // 清除发送状态
    RS485_Transmitting = 0;
    
    // 重新启动接收
    HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
  }
}
```
</details>

#### 方法三：DMA方式

<details>
<summary>📌 <b>DMA方式实现代码</b> (点击展开查看)</summary>

```c
// 使用DMA发送
void RS485_SendDMA(uint8_t *data, uint16_t size)
{
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 启动DMA发送
  HAL_UART_Transmit_DMA(&huart1, data, size);
  
  // 注意：发送完成处理在DMA完成回调函数中
}

// DMA发送完成回调
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart->Instance == USART1)
  {
    // 发送完成后等待TC标志，确保所有数据都已发送出去
    while (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_TC) == RESET);
    
    // 延时，确保最后一个位发送完成
    delayMicroseconds(5);
    
    // 切换回接收模式
    HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
    
    // 重新启动接收
    HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
  }
}
```
</details>

#### USART_CR3寄存器的DEM位（STM32F4/F7/H7等系列）

<details>
<summary>📌 <b>硬件自动控制方向代码</b> (点击展开查看)</summary>

```c
// 启用硬件自动控制RS485方向
void RS485_EnableHardwareControl(void)
{
  // 使能UART的DE功能（要求RTS引脚）
  huart1.Instance->CR3 |= USART_CR3_DEM;
  
  // 配置DE有效极性（高电平有效）
  huart1.Instance->CR3 |= USART_CR3_DEP;
  
  // 配置DE断言时间（相对于数据起始位）
  huart1.Instance->CR1 |= (2 << USART_CR1_DEAT_Pos);
  
  // 配置DE取消断言时间（相对于数据结束位）
  huart1.Instance->CR1 |= (2 << USART_CR1_DEDT_Pos);
}
```
</details>

## RS485收发器选型与配置

<div style="background-color:#f3e5f5;padding:15px;border-radius:5px;margin:10px 0;">

RS485收发器是连接STM32与RS485总线的关键硬件，选型需要考虑以下因素：

### 1. 常用芯片选型

<table style="width:100%;border-collapse:collapse;margin:10px 0;">
<tr style="background-color:#673AB7;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">芯片型号</th>
  <th style="padding:8px;border:1px solid #ddd;">速率</th>
  <th style="padding:8px;border:1px solid #ddd;">负载能力</th>
  <th style="padding:8px;border:1px solid #ddd;">特性</th>
  <th style="padding:8px;border:1px solid #ddd;">应用场景</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">MAX485</td>
  <td style="padding:8px;border:1px solid #ddd;">2.5Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">32个单元负载</td>
  <td style="padding:8px;border:1px solid #ddd;">经典型号，低功耗，8针DIP封装</td>
  <td style="padding:8px;border:1px solid #ddd;">一般工业控制应用</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">MAX3485</td>
  <td style="padding:8px;border:1px solid #ddd;">10Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">32个单元负载</td>
  <td style="padding:8px;border:1px solid #ddd;">高速版本，低功耗</td>
  <td style="padding:8px;border:1px solid #ddd;">对速率要求较高的场合</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">SN75176</td>
  <td style="padding:8px;border:1px solid #ddd;">10Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">32个单元负载</td>
  <td style="padding:8px;border:1px solid #ddd;">TI产品，工业标准</td>
  <td style="padding:8px;border:1px solid #ddd;">工业自动化，分布式控制</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">SP3485</td>
  <td style="padding:8px;border:1px solid #ddd;">10Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">32个单元负载</td>
  <td style="padding:8px;border:1px solid #ddd;">低功耗，防静电保护</td>
  <td style="padding:8px;border:1px solid #ddd;">电磁干扰较强环境</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">MAX13487E</td>
  <td style="padding:8px;border:1px solid #ddd;">16Mbps</td>
  <td style="padding:8px;border:1px solid #ddd;">256个单元负载</td>
  <td style="padding:8px;border:1px solid #ddd;">增强型，高抗干扰能力，内置隔离</td>
  <td style="padding:8px;border:1px solid #ddd;">恶劣环境，长距离通信</td>
</tr>
</table>

### 2. 关键参数

1. **传输速率**：
   - 根据通信波特率选择，通常Modbus用2400~115200bps
   - 对于近距离短线缆，普通收发器已足够
   - 高速场合选择10Mbps以上速率的收发器

2. **电气特性**：
   - 工作电压兼容性（3.3V或5V）
   - 驱动能力（负载单元数）
   - 隔离与保护要求

3. **收发器负载能力**：
   - 标准RS485收发器支持32个标准负载单元(UL)
   - 增强型收发器可支持128或256个单元负载
   - 实际负载数 = 总线上设备数 × 每设备负载单元

4. **保护功能**：
   - ESD保护（静电放电防护）
   - 过流/过压保护
   - 热关断保护
   - 针对工业环境可考虑带有这些保护的型号

### 3. 接口电路设计

#### 基本接口电路

```
      VCC
       │
       ↓
       R1
       │
       ├─────┐
STM32   │     │    RS485收发器
       │     │
TX ────┤DI   A├────→ 总线A线─┐
       │     │             R3 (120Ω终端电阻)
RX ←───┤RO   B├────→ 总线B线─┘
       │     │
GPIO ──┤DE/RE │
       │     │
      GND    R2    
             │     
             ↓     
            GND    
```

其中：
- R1: 上拉电阻（可选，某些场合需要）
- R2: 下拉电阻（可选，某些场合需要）
- R3: 终端电阻（总线两端各一个，通常为120Ω）

#### 带保护的增强型接口电路

```
      VCC
       │
       ↓
       R1     TVS1
       │       │
       ├─────┐ ┌┤
STM32   │     │ │
       │     │ │
TX ────┤DI   A├─┼──→ 总线A线──┐
       │     │ │            R3 (120Ω终端电阻)
RX ←───┤RO   B├─┼──→ 总线B线──┘
       │     │ │
GPIO ──┤DE/RE │ └┤
       │     │   TVS2
      GND    R2    
             │     
             ↓     
            GND    
```

增强型方案添加：
- TVS1/TVS2: 瞬态电压抑制二极管，用于抑制静电和浪涌
- 也可添加共模扼流圈，进一步提高抗干扰能力

### 4. 实际应用配置建议

1. **近距离通信**（<10米）:
   - 芯片: MAX485或类似品
   - 波特率: 9600~115200bps
   - 终端电阻: 可选
   - 特殊保护: 通常不需要

2. **中距离通信**（10~100米）:
   - 芯片: MAX3485, SP3485等
   - 波特率: 2400~38400bps
   - 终端电阻: 必需(120Ω)
   - 特殊保护: 考虑基本的TVS保护

3. **长距离通信**（100~1000米）:
   - 芯片: MAX13487E等增强型
   - 波特率: 2400~9600bps
   - 终端电阻: 必需(120Ω)
   - 特殊保护: 必需，包括TVS、共模扼流圈等
   - 考虑使用光电隔离型收发器

</div>

## 半双工通信控制

<div style="background-color:#ffebee;padding:15px;border-radius:5px;margin:10px 0;">

RS485采用半双工通信方式，需要正确控制发送和接收状态的切换：

### 1. 发送/接收切换的时序控制

发送/接收切换是RS485通信最关键的环节之一：

```
             ┌───────┐            ┌───────┐
发送使能 DE   │       │            │       │
          ───┘       └────────────┘       └──────
             ▲       ▲            ▲       ▲
             │       │            │       │
             │       │            │       │
             │       │            │       │
数据传输    ──┐   ┌───┐   ┌─────┐   ┌───┐   ┌─────
             │Tx1│   │Tx2│     │Rx1│   │Rx2│
             └───┘   └───┘     └───┘   └───┘
             ▲       ▲            ▲       ▲
             │       │            │       │
             │A      │B           │C      │D
```

关键时刻点：
- **A点**: 发送前，先将DE设为高电平，切换为发送模式
- **B点**: 发送完成后，等待最后一个字节完全发送出去，再将DE设为低电平
- **C点**: 切换到接收模式后，才能接收数据
- **D点**: 完成接收后，可能需要再次切换为发送模式

### 2. 软件实现方法

#### 方法一：查询方式

```c
// 发送数据（查询方式）
void RS485_SendData(uint8_t *data, uint16_t size)
{
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 延时确保DE信号稳定（微秒级）
  delayMicroseconds(5);
  
  // 发送数据
  HAL_UART_Transmit(&huart1, data, size, HAL_MAX_DELAY);
  
  // 等待发送完成 - 检查TC标志
  while (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_TC) == RESET);
  
  // 延时确保最后一个位发送完成
  delayMicroseconds(5);
  
  // 切换回接收模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
}
```

#### 方法二：中断方式

```c
// 发送状态标志
volatile uint8_t RS485_Transmitting = 0;

// 开始发送数据（中断方式）
void RS485_StartTransmit(uint8_t *data, uint16_t size)
{
  // 标记为发送状态
  RS485_Transmitting = 1;
  
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 延时确保DE信号稳定
  delayMicroseconds(5);
  
  // 启动UART发送（中断方式）
  HAL_UART_Transmit_IT(&huart1, data, size);
}

// UART发送完成回调
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart->Instance == USART1 && RS485_Transmitting)
  {
    // 发送完成，延时一小段时间，确保最后一个位发送完成
    delayMicroseconds(5);
    
    // 切换回接收模式
    HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
    
    // 清除发送状态
    RS485_Transmitting = 0;
    
    // 重新启动接收
    HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
  }
}
```

#### 方法三：DMA方式

```c
// 使用DMA发送
void RS485_SendDMA(uint8_t *data, uint16_t size)
{
  // 切换为发送模式
  HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_SET);
  
  // 启动DMA发送
  HAL_UART_Transmit_DMA(&huart1, data, size);
  
  // 注意：发送完成处理在DMA完成回调函数中
}

// DMA发送完成回调
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart->Instance == USART1)
  {
    // 发送完成后等待TC标志，确保所有数据都已发送出去
    while (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_TC) == RESET);
    
    // 延时，确保最后一个位发送完成
    delayMicroseconds(5);
    
    // 切换回接收模式
    HAL_GPIO_WritePin(RS485_DE_GPIO_Port, RS485_DE_Pin, GPIO_PIN_RESET);
    
    // 重新启动接收
    HAL_UART_Receive_IT(&huart1, &RxTemp, 1);
  }
}
```

### 3. 硬件自动控制方法

某些STM32型号允许使用硬件自动控制RS485的方向：

#### USART_CR3寄存器的DEM位（STM32F4/F7/H7等系列）

```c
// 启用硬件自动控制RS485方向
void RS485_EnableHardwareControl(void)
{
  // 使能UART的DE功能（要求RTS引脚）
  huart1.Instance->CR3 |= USART_CR3_DEM;
  
  // 配置DE有效极性（高电平有效）
  huart1.Instance->CR3 |= USART_CR3_DEP;
  
  // 配置DE断言时间（相对于数据起始位）
  huart1.Instance->CR1 |= (2 << USART_CR1_DEAT_Pos);
  
  // 配置DE取消断言时间（相对于数据结束位）
  huart1.Instance->CR1 |= (2 << USART_CR1_DEDT_Pos);
}
```

使用硬件控制的优势：
- 精确的时序控制，硬件会自动处理DE信号
- 减少对CPU的占用
- 减少由于软件延迟导致的数据丢失

注意：
- 不是所有STM32型号都支持硬件DE控制
- 需要将DE信号连接到UART的RTS引脚
- 使用CubeMX配置时，需要启用RS485 DE功能

### 4. 时序相关问题及解决方案

#### 问题1：数据发送不完整

**原因**：DE信号提前变为低电平，最后几个位未发送完成。

**解决方案**：
- 确保在TC标志置位后再切换DE
- 增加额外延时，确保最后一个位完全发送

#### 问题2：首个接收字节错误

**原因**：从发送模式切换到接收模式的延迟不足。

**解决方案**：
- 在切换完成后增加短延时
- 检查线缆质量和终端电阻是否正确

#### 问题3：总线冲突（多设备通信）

**原因**：多个设备同时发送数据。

**解决方案**：
- 严格遵循主从通信规则，从设备只在收到主设备请求后发送
- 增加通信超时处理，超时自动恢复为接收模式
- 数据发送前先检测总线上是否有数据传输
- 考虑使用带冲突检测功能的收发器

</div> 