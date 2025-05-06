# Modbus_RS485应用实例

<div align="center">

![Modbus应用实例](https://via.placeholder.com/600x150/FF5722/FFFFFF?text=Modbus_RS485%E5%BA%94%E7%94%A8%E5%AE%9E%E4%BE%8B)

</div>

---

## 📑 目录

- [Modbus_RS485应用实例](#modbus_rs485应用实例)
  - [Modbus_RS485的应用场景](#modbus_rs485的应用场景)
  - [STM32 UART与RS485初始化](#stm32-uart与rs485初始化)
  - [Modbus主机通信示例](#modbus主机通信示例)
  - [Modbus从机通信示例](#modbus从机通信示例)
  - [Modbus功能码实现示例](#modbus功能码实现示例)
  - [常见问题与解决方案](#常见问题与解决方案)

---

## Modbus_RS485的应用场景

<div style="background-color:#f5f5f5;padding:15px;border-radius:5px;margin:10px 0;">

Modbus_RS485在以下领域有广泛应用：

1. **工业自动化**
   - 可编程逻辑控制器(PLC)
   - 分布式控制系统(DCS)
   - 工业传感器和执行器
   - 运动控制系统
   - 工业机器人

2. **楼宇自动化**
   - 暖通空调(HVAC)控制系统
   - 照明控制系统
   - 能源管理系统
   - 安防系统

3. **能源管理**
   - 智能电表系统
   - 太阳能发电监控
   - 电池管理系统
   - 电力监测设备

4. **智能农业**
   - 灌溉控制系统
   - 温室环境监控
   - 农场设备自动化

5. **水处理系统**
   - 水泵控制
   - 水质监测
   - 污水处理过程控制

</div>

## STM32 UART与RS485初始化

以STM32F103系列为例，初始化UART和RS485的步骤如下：

```c
// RS485方向控制引脚定义
#define RS485_DE_GPIO_PORT     GPIOA
#define RS485_DE_GPIO_PIN      GPIO_PIN_8
#define RS485_DE_GPIO_CLK      RCC_APB2Periph_GPIOA

// RS485方向控制宏定义
#define RS485_RX_MODE()        HAL_GPIO_WritePin(RS485_DE_GPIO_PORT, RS485_DE_GPIO_PIN, GPIO_PIN_RESET)
#define RS485_TX_MODE()        HAL_GPIO_WritePin(RS485_DE_GPIO_PORT, RS485_DE_GPIO_PIN, GPIO_PIN_SET)

// 串口和RS485初始化函数
void RS485_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  UART_HandleTypeDef huart1;
  
  // 1. 使能时钟
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_USART1_CLK_ENABLE();
  
  // 2. 初始化RS485方向控制引脚
  GPIO_InitStruct.Pin = RS485_DE_GPIO_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(RS485_DE_GPIO_PORT, &GPIO_InitStruct);
  
  // 默认为接收模式
  RS485_RX_MODE();
  
  // 3. 初始化UART引脚
  GPIO_InitStruct.Pin = GPIO_PIN_9;  // TX
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  
  GPIO_InitStruct.Pin = GPIO_PIN_10;  // RX
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  
  // 4. 配置UART参数
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 9600;                  // 常用波特率：9600, 19200, 38400, 115200
  huart1.Init.WordLength = UART_WORDLENGTH_8B;  // 8位数据位
  huart1.Init.StopBits = UART_STOPBITS_1;       // 1位停止位
  huart1.Init.Parity = UART_PARITY_NONE;        // 无校验
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  
  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
  
  // 5. 使能接收中断
  HAL_UART_Receive_IT(&huart1, &Rx_Byte, 1);
  
  // 6. 设置UART接收超时，对于Modbus非常重要
  SET_BIT(huart1.Instance->CR1, USART_CR1_IDLEIE);  // 空闲中断，用于帧结束检测
}
```

## Modbus主机通信示例

实现Modbus主机（Master）发送请求和接收响应的基本功能：

```c
// 定义全局变量
uint8_t ModbusRxBuffer[256];      // 接收缓冲区
uint16_t ModbusRxCount = 0;       // 接收计数
uint8_t ModbusTxBuffer[256];      // 发送缓冲区
uint8_t ModbusResponseTimeout = 0; // 响应超时标志

// CRC16校验计算函数
uint16_t ModbusCRC16(uint8_t *buffer, uint16_t length)
{
  uint16_t crc = 0xFFFF;
  
  for (uint16_t i = 0; i < length; i++)
  {
    crc ^= buffer[i];
    for (uint8_t j = 0; j < 8; j++)
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

// 发送Modbus请求
void ModbusMaster_SendRequest(uint8_t slaveAddr, uint8_t functionCode, uint16_t startAddr, uint16_t quantity)
{
  uint16_t index = 0;
  uint16_t crc;
  
  // 构建请求报文
  ModbusTxBuffer[index++] = slaveAddr;       // 从站地址
  ModbusTxBuffer[index++] = functionCode;    // 功能码
  ModbusTxBuffer[index++] = (startAddr >> 8) & 0xFF;  // 起始地址高字节
  ModbusTxBuffer[index++] = startAddr & 0xFF;        // 起始地址低字节
  ModbusTxBuffer[index++] = (quantity >> 8) & 0xFF;  // 数量高字节
  ModbusTxBuffer[index++] = quantity & 0xFF;        // 数量低字节
  
  // 计算CRC校验
  crc = ModbusCRC16(ModbusTxBuffer, index);
  ModbusTxBuffer[index++] = crc & 0xFF;        // CRC低字节
  ModbusTxBuffer[index++] = (crc >> 8) & 0xFF; // CRC高字节
  
  // 清空接收缓冲区和计数器
  ModbusRxCount = 0;
  memset(ModbusRxBuffer, 0, sizeof(ModbusRxBuffer));
  
  // 切换为发送模式
  RS485_TX_MODE();
  
  // 发送数据
  HAL_UART_Transmit(&huart1, ModbusTxBuffer, index, 100);
  
  // 等待发送完成（必要的）
  while(!(huart1.Instance->SR & UART_FLAG_TC));
  
  // 切换为接收模式
  RS485_RX_MODE();
  
  // 开始接收响应，使用中断方式
  ModbusResponseTimeout = 0;
  HAL_UART_Receive_IT(&huart1, &ModbusRxBuffer[ModbusRxCount], 1);
  
  // 启动超时定时器（建议使用硬件定时器）
  StartTimeoutTimer(500); // 500ms超时
}

// 处理Modbus响应
uint8_t ModbusMaster_ProcessResponse(uint8_t expectedSlaveAddr, uint8_t expectedFunctionCode)
{
  uint16_t receivedCRC, calculatedCRC;
  
  // 检查是否接收到足够的数据
  if (ModbusRxCount < 5) // 最小响应长度：地址(1) + 功能码(1) + 数据(1) + CRC(2)
  {
    return MODBUS_ERROR_RESPONSE_SHORT;
  }
  
  // 检查从站地址是否匹配
  if (ModbusRxBuffer[0] != expectedSlaveAddr)
  {
    return MODBUS_ERROR_WRONG_SLAVE_ID;
  }
  
  // 检查是否有异常响应
  if (ModbusRxBuffer[1] == (expectedFunctionCode | 0x80))
  {
    return ModbusRxBuffer[2]; // 返回异常码
  }
  
  // 检查功能码是否匹配
  if (ModbusRxBuffer[1] != expectedFunctionCode)
  {
    return MODBUS_ERROR_WRONG_FUNCTION_CODE;
  }
  
  // 检查CRC校验
  receivedCRC = (ModbusRxBuffer[ModbusRxCount - 1] << 8) | ModbusRxBuffer[ModbusRxCount - 2];
  calculatedCRC = ModbusCRC16(ModbusRxBuffer, ModbusRxCount - 2);
  
  if (receivedCRC != calculatedCRC)
  {
    return MODBUS_ERROR_CRC;
  }
  
  // 响应有效
  return MODBUS_SUCCESS;
}

// 读取保持寄存器的便捷函数
uint8_t ModbusMaster_ReadHoldingRegisters(uint8_t slaveAddr, uint16_t startAddr, uint16_t quantity, uint16_t* data)
{
  uint8_t status;
  uint8_t bytesCount;
  
  // 发送读保持寄存器请求
  ModbusMaster_SendRequest(slaveAddr, 0x03, startAddr, quantity);
  
  // 等待响应或超时
  while (!ModbusResponseTimeout && ModbusRxCount < (5 + quantity * 2));
  
  if (ModbusResponseTimeout)
  {
    return MODBUS_ERROR_TIMEOUT;
  }
  
  // 处理响应
  status = ModbusMaster_ProcessResponse(slaveAddr, 0x03);
  
  if (status != MODBUS_SUCCESS)
  {
    return status;
  }
  
  // 解析数据
  bytesCount = ModbusRxBuffer[2];
  
  if (bytesCount != quantity * 2)
  {
    return MODBUS_ERROR_DATA_LENGTH;
  }
  
  for (uint16_t i = 0; i < quantity; i++)
  {
    data[i] = (ModbusRxBuffer[3 + i * 2] << 8) | ModbusRxBuffer[4 + i * 2];
  }
  
  return MODBUS_SUCCESS;
}
```

## Modbus从机通信示例

实现Modbus从机（Slave）的通信处理和响应生成：

```c
// 定义寄存器和线圈存储区
#define MAX_COILS               1000
#define MAX_DISCRETE_INPUTS     1000
#define MAX_HOLDING_REGISTERS   1000
#define MAX_INPUT_REGISTERS     1000

// 存储区定义
static uint8_t Coils[MAX_COILS / 8];                    // 线圈状态，按位存储
static uint8_t DiscreteInputs[MAX_DISCRETE_INPUTS / 8]; // 离散输入状态，按位存储
static uint16_t HoldingRegisters[MAX_HOLDING_REGISTERS]; // 保持寄存器
static uint16_t InputRegisters[MAX_INPUT_REGISTERS];     // 输入寄存器

// 设备地址
static uint8_t ModbusSlaveAddress = 1;

// 处理接收到的Modbus请求
void ModbusSlave_ProcessRequest(void)
{
  uint16_t receivedCRC, calculatedCRC;
  uint8_t functionCode;
  uint16_t startAddress, quantity;
  uint16_t responseLength = 0;
  
  // 检查是否接收到足够的数据
  if (ModbusRxCount < 8) // 最小请求长度：地址(1) + 功能码(1) + 数据(4) + CRC(2)
  {
    return;
  }
  
  // 验证CRC
  receivedCRC = (ModbusRxBuffer[ModbusRxCount - 1] << 8) | ModbusRxBuffer[ModbusRxCount - 2];
  calculatedCRC = ModbusCRC16(ModbusRxBuffer, ModbusRxCount - 2);
  
  if (receivedCRC != calculatedCRC)
  {
    return; // CRC错误，丢弃报文
  }
  
  // 检查从站地址
  if (ModbusRxBuffer[0] != ModbusSlaveAddress && ModbusRxBuffer[0] != 0) // 0是广播地址
  {
    return; // 不是发给本机的报文
  }
  
  // 解析功能码和地址
  functionCode = ModbusRxBuffer[1];
  startAddress = (ModbusRxBuffer[2] << 8) | ModbusRxBuffer[3];
  quantity = (ModbusRxBuffer[4] << 8) | ModbusRxBuffer[5];
  
  // 根据功能码处理请求
  switch (functionCode)
  {
    case 0x01: // 读线圈
      responseLength = ModbusSlave_ReadCoils(startAddress, quantity);
      break;
      
    case 0x03: // 读保持寄存器
      responseLength = ModbusSlave_ReadHoldingRegisters(startAddress, quantity);
      break;
      
    case 0x05: // 写单个线圈
      responseLength = ModbusSlave_WriteSingleCoil(startAddress, (ModbusRxBuffer[4] << 8) | ModbusRxBuffer[5]);
      break;
      
    case 0x06: // 写单个寄存器
      responseLength = ModbusSlave_WriteSingleRegister(startAddress, (ModbusRxBuffer[4] << 8) | ModbusRxBuffer[5]);
      break;
      
    case 0x10: // 写多个寄存器
      responseLength = ModbusSlave_WriteMultipleRegisters(startAddress, quantity);
      break;
      
    default: // 不支持的功能码
      responseLength = ModbusSlave_GenerateExceptionResponse(functionCode, 0x01); // 非法功能
      break;
  }
  
  // 如果不是广播请求，发送响应
  if (ModbusRxBuffer[0] != 0 && responseLength > 0)
  {
    // 计算响应的CRC
    calculatedCRC = ModbusCRC16(ModbusTxBuffer, responseLength);
    ModbusTxBuffer[responseLength++] = calculatedCRC & 0xFF;        // CRC低字节
    ModbusTxBuffer[responseLength++] = (calculatedCRC >> 8) & 0xFF; // CRC高字节
    
    // 切换为发送模式
    RS485_TX_MODE();
    
    // 发送响应
    HAL_UART_Transmit(&huart1, ModbusTxBuffer, responseLength, 100);
    
    // 等待发送完成
    while(!(huart1.Instance->SR & UART_FLAG_TC));
    
    // 切换为接收模式
    RS485_RX_MODE();
  }
  
  // 清空接收缓冲区，准备接收下一个请求
  ModbusRxCount = 0;
  memset(ModbusRxBuffer, 0, sizeof(ModbusRxBuffer));
}

// 处理读保持寄存器请求
uint16_t ModbusSlave_ReadHoldingRegisters(uint16_t startAddress, uint16_t quantity)
{
  uint16_t responseLength = 0;
  
  // 检查地址和数量是否有效
  if (startAddress + quantity > MAX_HOLDING_REGISTERS || quantity > 125)
  {
    return ModbusSlave_GenerateExceptionResponse(0x03, 0x02); // 非法数据地址
  }
  
  // 生成响应头
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;  // 从站地址
  ModbusTxBuffer[responseLength++] = 0x03;               // 功能码
  ModbusTxBuffer[responseLength++] = quantity * 2;       // 数据字节数
  
  // 填充寄存器数据
  for (uint16_t i = 0; i < quantity; i++)
  {
    ModbusTxBuffer[responseLength++] = (HoldingRegisters[startAddress + i] >> 8) & 0xFF; // 高字节
    ModbusTxBuffer[responseLength++] = HoldingRegisters[startAddress + i] & 0xFF;       // 低字节
  }
  
  return responseLength;
}

// 生成异常响应
uint16_t ModbusSlave_GenerateExceptionResponse(uint8_t functionCode, uint8_t exceptionCode)
{
  uint16_t responseLength = 0;
  
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;       // 从站地址
  ModbusTxBuffer[responseLength++] = functionCode | 0x80;      // 功能码 + 0x80表示异常
  ModbusTxBuffer[responseLength++] = exceptionCode;            // 异常码
  
  return responseLength;
}
```

## Modbus功能码实现示例

下面实现一些常用的Modbus功能码处理函数：

```c
// 处理读线圈请求（功能码 0x01）
uint16_t ModbusSlave_ReadCoils(uint16_t startAddress, uint16_t quantity)
{
  uint16_t responseLength = 0;
  uint8_t byteCount;
  uint8_t temp;
  uint16_t i, j;
  
  // 检查地址和数量是否有效
  if (startAddress + quantity > MAX_COILS || quantity > 2000)
  {
    return ModbusSlave_GenerateExceptionResponse(0x01, 0x02); // 非法数据地址
  }
  
  // 计算需要的字节数 (向上取整)
  byteCount = (quantity + 7) / 8;
  
  // 生成响应头
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;  // 从站地址
  ModbusTxBuffer[responseLength++] = 0x01;               // 功能码
  ModbusTxBuffer[responseLength++] = byteCount;          // 数据字节数
  
  // 填充线圈状态数据
  for (i = 0; i < byteCount; i++)
  {
    temp = 0;
    for (j = 0; j < 8; j++)
    {
      if ((i * 8 + j) < quantity) // 确保不超出请求的数量
      {
        // 获取指定线圈的状态
        if ((Coils[(startAddress + i * 8 + j) / 8] >> ((startAddress + i * 8 + j) % 8)) & 0x01)
        {
          temp |= (1 << j);
        }
      }
    }
    ModbusTxBuffer[responseLength++] = temp;
  }
  
  return responseLength;
}

// 处理写单个线圈请求（功能码 0x05）
uint16_t ModbusSlave_WriteSingleCoil(uint16_t address, uint16_t value)
{
  uint16_t responseLength = 0;
  
  // 检查地址是否有效
  if (address >= MAX_COILS)
  {
    return ModbusSlave_GenerateExceptionResponse(0x05, 0x02); // 非法数据地址
  }
  
  // 检查值是否有效 (0x0000表示OFF, 0xFF00表示ON)
  if (value != 0x0000 && value != 0xFF00)
  {
    return ModbusSlave_GenerateExceptionResponse(0x05, 0x03); // 非法数据值
  }
  
  // 设置线圈状态
  if (value == 0xFF00)
  {
    // 设置为ON
    Coils[address / 8] |= (1 << (address % 8));
  }
  else
  {
    // 设置为OFF
    Coils[address / 8] &= ~(1 << (address % 8));
  }
  
  // 生成响应（与请求相同）
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;  // 从站地址
  ModbusTxBuffer[responseLength++] = 0x05;               // 功能码
  ModbusTxBuffer[responseLength++] = (address >> 8) & 0xFF; // 地址高字节
  ModbusTxBuffer[responseLength++] = address & 0xFF;       // 地址低字节
  ModbusTxBuffer[responseLength++] = (value >> 8) & 0xFF;  // 值高字节
  ModbusTxBuffer[responseLength++] = value & 0xFF;        // 值低字节
  
  return responseLength;
}

// 处理写单个寄存器请求（功能码 0x06）
uint16_t ModbusSlave_WriteSingleRegister(uint16_t address, uint16_t value)
{
  uint16_t responseLength = 0;
  
  // 检查地址是否有效
  if (address >= MAX_HOLDING_REGISTERS)
  {
    return ModbusSlave_GenerateExceptionResponse(0x06, 0x02); // 非法数据地址
  }
  
  // 写入寄存器值
  HoldingRegisters[address] = value;
  
  // 生成响应（与请求相同）
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;  // 从站地址
  ModbusTxBuffer[responseLength++] = 0x06;               // 功能码
  ModbusTxBuffer[responseLength++] = (address >> 8) & 0xFF; // 地址高字节
  ModbusTxBuffer[responseLength++] = address & 0xFF;       // 地址低字节
  ModbusTxBuffer[responseLength++] = (value >> 8) & 0xFF;  // 值高字节
  ModbusTxBuffer[responseLength++] = value & 0xFF;        // 值低字节
  
  return responseLength;
}

// 处理写多个寄存器请求（功能码 0x10）
uint16_t ModbusSlave_WriteMultipleRegisters(uint16_t startAddress, uint16_t quantity)
{
  uint16_t responseLength = 0;
  uint8_t byteCount;
  uint16_t i;
  
  // 检查地址和数量是否有效
  if (startAddress + quantity > MAX_HOLDING_REGISTERS || quantity > 123)
  {
    return ModbusSlave_GenerateExceptionResponse(0x10, 0x02); // 非法数据地址
  }
  
  // 检查字节数是否正确
  byteCount = ModbusRxBuffer[6];
  if (byteCount != quantity * 2)
  {
    return ModbusSlave_GenerateExceptionResponse(0x10, 0x03); // 非法数据值
  }
  
  // 写入多个寄存器
  for (i = 0; i < quantity; i++)
  {
    HoldingRegisters[startAddress + i] = (ModbusRxBuffer[7 + i * 2] << 8) | ModbusRxBuffer[8 + i * 2];
  }
  
  // 生成响应
  ModbusTxBuffer[responseLength++] = ModbusSlaveAddress;  // 从站地址
  ModbusTxBuffer[responseLength++] = 0x10;               // 功能码
  ModbusTxBuffer[responseLength++] = (startAddress >> 8) & 0xFF; // 起始地址高字节
  ModbusTxBuffer[responseLength++] = startAddress & 0xFF;       // 起始地址低字节
  ModbusTxBuffer[responseLength++] = (quantity >> 8) & 0xFF;   // 寄存器数量高字节
  ModbusTxBuffer[responseLength++] = quantity & 0xFF;         // 寄存器数量低字节
  
  return responseLength;
}
```

## 常见问题与解决方案

<details>
<summary>💡 通信不稳定</summary>

如果Modbus_RS485通信不稳定，可能的原因和解决方法：

1. **总线终端电阻问题**
   - 确保RS485总线两端都有120Ω终端电阻
   - 使用万用表测量A和B线之间的电阻，应该约为60Ω（两个120Ω并联）
   - 对于短距离或低速通信，可以考虑使用更大阻值如180Ω-240Ω的终端电阻

2. **波特率与距离不匹配**
   - 长距离通信应降低波特率
   - 确保所有设备使用相同的波特率和格式参数

3. **信号质量问题**
   - 使用屏蔽双绞线以减少干扰
   - 避免与电源线或其他高压线并行布线
   - 考虑增加光电隔离或共模扼流圈

4. **接地问题**
   - 确保良好的接地连接但避免地环路
   - 对于长距离通信，考虑使用三线制连接（A、B和GND）
   - 在有潜在电气噪声的环境中，考虑使用光电隔离

5. **软件时序问题**
   - 检查发送/接收切换时序
   - 确保在最后一个字节发送完成后再切换到接收模式
   - 使用适当的帧间延时

6. **字节超时设置**
   - 确保使用合适的空闲检测机制判断帧结束
   - 对于RTU模式，3.5个字符时间的间隔表示帧结束

</details>

<details>
<summary>💡 总线冲突</summary>

如果发生总线冲突：

1. **多主机拓扑问题**
   - Modbus是主从架构，确保网络中只有一个主机
   - 检查所有从机是否只在收到请求时才发送响应

2. **发送/接收切换时序问题**
   - 确保发送完成后立即切换为接收模式
   - 在收到请求并需要响应时，确保等待一定时间（约3.5个字符时间）后再发送响应

3. **从机地址冲突**
   - 确保网络中所有从机都有唯一的地址
   - 检查是否有设备使用了广播地址(0)作为从机地址

4. **通信超时设置不当**
   - 主机应等待足够长的时间收取从机响应
   - 设置合理的重试次数和重试间隔

</details>

<details>
<summary>💡 数据错误</summary>

如果接收到的数据有错误：

1. **CRC校验失败**
   - 确认CRC计算算法是否正确
   - 检查数据位顺序是否正确（小端字节序）
   - 检查是否存在电气噪声干扰

2. **帧格式错误**
   - 确保所有设备使用相同的通信参数（波特率、校验位、停止位）
   - RTU模式下检查帧间间隔是否正确

3. **异常响应**
   - 检查异常码含义，针对不同问题调整请求参数
   - 确认所请求的功能码和地址是否被从机支持

4. **数据解析错误**
   - 确认寄存器值的字节顺序是否正确（高字节在前）
   - 对于多寄存器数据类型（如浮点数、长整型），检查字顺序

</details> 