# CAN总线应用实例

<div align="center">

![CAN应用实例](https://via.placeholder.com/600x150/FF5722/FFFFFF?text=CAN%E5%BA%94%E7%94%A8%E5%AE%9E%E4%BE%8B)

</div>

---

## 📑 目录

- [CAN总线应用实例](#can总线应用实例)
  - [CAN总线的应用场景](#can总线的应用场景)
  - [STM32 CAN通信初始化](#stm32-can通信初始化)
  - [CAN报文发送示例](#can报文发送示例)
  - [CAN报文接收示例](#can报文接收示例)
  - [CAN环回模式测试](#can环回模式测试)
  - [常见问题与解决方案](#常见问题与解决方案)

---

## CAN总线的应用场景

<div style="background-color:#f5f5f5;padding:15px;border-radius:5px;margin:10px 0;">

CAN总线在以下领域有广泛应用：

1. **汽车电子系统**
   - 发动机控制单元(ECU)
   - 防抱死制动系统(ABS)
   - 电子稳定程序(ESP)
   - 车身电子系统
   - 信息娱乐系统

2. **工业自动化**
   - 工业机器人控制
   - 自动化生产线
   - 分布式控制系统

3. **医疗设备**
   - 医疗诊断设备
   - 医疗监控系统

4. **智能建筑**
   - 电梯控制系统
   - 智能照明系统
   - 安防系统

5. **航空航天**
   - 飞行控制系统
   - 导航系统

</div>

## STM32 CAN通信初始化

以STM32F103系列为例，初始化CAN外设的步骤如下：

```c
void CAN_Init(void)
{
  CAN_HandleTypeDef hcan;
  CAN_FilterTypeDef sFilterConfig;
  
  // 1. 初始化CAN外设
  hcan.Instance = CAN1;
  hcan.Init.Prescaler = 4;                  // 分频系数 
  hcan.Init.Mode = CAN_MODE_NORMAL;         // 正常模式
  hcan.Init.SyncJumpWidth = CAN_SJW_1TQ;    // 重同步跳跃宽度
  hcan.Init.TimeSeg1 = CAN_BS1_13TQ;        // 时间段1
  hcan.Init.TimeSeg2 = CAN_BS2_2TQ;         // 时间段2
  hcan.Init.TimeTriggeredMode = DISABLE;    // 禁用时间触发模式
  hcan.Init.AutoBusOff = DISABLE;           // 禁用自动总线关闭
  hcan.Init.AutoWakeUp = DISABLE;           // 禁用自动唤醒
  hcan.Init.AutoRetransmission = ENABLE;    // 启用自动重传
  hcan.Init.ReceiveFifoLocked = DISABLE;    // 禁用接收FIFO锁定模式
  hcan.Init.TransmitFifoPriority = DISABLE; // 禁用发送FIFO优先级
  
  if (HAL_CAN_Init(&hcan) != HAL_OK)
  {
    Error_Handler();
  }
  
  // 2. 配置过滤器
  sFilterConfig.FilterBank = 0;                      // 过滤器0
  sFilterConfig.FilterMode = CAN_FILTERMODE_IDMASK;  // 掩码模式
  sFilterConfig.FilterScale = CAN_FILTERSCALE_32BIT; // 32位过滤器
  sFilterConfig.FilterIdHigh = 0x0000;               // 接收所有ID
  sFilterConfig.FilterIdLow = 0x0000;
  sFilterConfig.FilterMaskIdHigh = 0x0000;           // 不使用掩码
  sFilterConfig.FilterMaskIdLow = 0x0000;
  sFilterConfig.FilterFIFOAssignment = CAN_RX_FIFO0; // 过滤的报文存入FIFO0
  sFilterConfig.FilterActivation = ENABLE;           // 使能过滤器
  
  if (HAL_CAN_ConfigFilter(&hcan, &sFilterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  
  // 3. 启动CAN模块
  if (HAL_CAN_Start(&hcan) != HAL_OK)
  {
    Error_Handler();
  }
  
  // 4. 使能中断
  if (HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_MSG_PENDING) != HAL_OK)
  {
    Error_Handler();
  }
}
```

以上配置将CAN波特率设置为1Mbps（72MHz系统时钟下）。

## CAN报文发送示例

发送CAN报文的简单示例：

```c
void CAN_Send_Message(uint32_t id, uint8_t* data, uint8_t len)
{
  CAN_TxHeaderTypeDef TxHeader;
  uint32_t TxMailbox;
  
  // 配置发送报文头
  if (id <= 0x7FF) { // 标准帧
    TxHeader.StdId = id;
    TxHeader.IDE = CAN_ID_STD;
  } else { // 扩展帧
    TxHeader.ExtId = id;
    TxHeader.IDE = CAN_ID_EXT;
  }
  
  TxHeader.RTR = CAN_RTR_DATA;  // 数据帧
  TxHeader.DLC = len;           // 数据长度
  TxHeader.TransmitGlobalTime = DISABLE;
  
  // 发送报文
  if (HAL_CAN_AddTxMessage(&hcan, &TxHeader, data, &TxMailbox) != HAL_OK)
  {
    Error_Handler();
  }
  
  // 等待发送完成
  while(HAL_CAN_GetTxMailboxesFreeLevel(&hcan) != 3);
}
```

## CAN报文接收示例

接收CAN报文并处理的示例：

```c
// 在main.c中定义回调函数
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
  CAN_RxHeaderTypeDef RxHeader;
  uint8_t RxData[8];
  
  // 接收报文
  if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &RxHeader, RxData) == HAL_OK)
  {
    // 处理接收到的数据
    if (RxHeader.IDE == CAN_ID_STD) // 标准帧
    {
      printf("Received Standard Frame, ID: 0x%03X, DLC: %d\r\n", 
             RxHeader.StdId, RxHeader.DLC);
    }
    else // 扩展帧
    {
      printf("Received Extended Frame, ID: 0x%08X, DLC: %d\r\n", 
             RxHeader.ExtId, RxHeader.DLC);
    }
    
    printf("Data: ");
    for (int i = 0; i < RxHeader.DLC; i++)
    {
      printf("0x%02X ", RxData[i]);
    }
    printf("\r\n");
    
    // 可以在这里根据ID和数据内容进行不同的处理
  }
}
```

## CAN环回模式测试

环回模式是调试CAN通信的有效方法，它允许在不连接外部CAN总线的情况下测试CAN功能：

```c
void CAN_Loopback_Test(void)
{
  CAN_HandleTypeDef hcan;
  
  // CAN初始化配置与正常模式相同，只需修改模式为环回模式
  hcan.Instance = CAN1;
  hcan.Init.Prescaler = 4;
  hcan.Init.Mode = CAN_MODE_LOOPBACK; // 环回模式
  hcan.Init.SyncJumpWidth = CAN_SJW_1TQ;
  hcan.Init.TimeSeg1 = CAN_BS1_13TQ;
  hcan.Init.TimeSeg2 = CAN_BS2_2TQ;
  hcan.Init.TimeTriggeredMode = DISABLE;
  hcan.Init.AutoBusOff = DISABLE;
  hcan.Init.AutoWakeUp = DISABLE;
  hcan.Init.AutoRetransmission = ENABLE;
  hcan.Init.ReceiveFifoLocked = DISABLE;
  hcan.Init.TransmitFifoPriority = DISABLE;
  
  HAL_CAN_Init(&hcan);
  
  // 配置过滤器接收所有报文
  CAN_FilterTypeDef sFilterConfig;
  sFilterConfig.FilterBank = 0;
  sFilterConfig.FilterMode = CAN_FILTERMODE_IDMASK;
  sFilterConfig.FilterScale = CAN_FILTERSCALE_32BIT;
  sFilterConfig.FilterIdHigh = 0x0000;
  sFilterConfig.FilterIdLow = 0x0000;
  sFilterConfig.FilterMaskIdHigh = 0x0000;
  sFilterConfig.FilterMaskIdLow = 0x0000;
  sFilterConfig.FilterFIFOAssignment = CAN_RX_FIFO0;
  sFilterConfig.FilterActivation = ENABLE;
  
  HAL_CAN_ConfigFilter(&hcan, &sFilterConfig);
  HAL_CAN_Start(&hcan);
  
  // 测试发送并接收
  uint8_t TxData[8] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
  CAN_TxHeaderTypeDef TxHeader;
  uint32_t TxMailbox;
  
  TxHeader.StdId = 0x123;
  TxHeader.IDE = CAN_ID_STD;
  TxHeader.RTR = CAN_RTR_DATA;
  TxHeader.DLC = 8;
  TxHeader.TransmitGlobalTime = DISABLE;
  
  // 发送报文
  HAL_CAN_AddTxMessage(&hcan, &TxHeader, TxData, &TxMailbox);
  
  // 等待接收
  while(HAL_CAN_GetRxFifoFillLevel(&hcan, CAN_RX_FIFO0) == 0);
  
  // 接收报文
  CAN_RxHeaderTypeDef RxHeader;
  uint8_t RxData[8];
  HAL_CAN_GetRxMessage(&hcan, CAN_RX_FIFO0, &RxHeader, RxData);
  
  // 验证接收数据是否与发送数据一致
  if (RxHeader.StdId == 0x123 && RxHeader.DLC == 8)
  {
    int match = 1;
    for (int i = 0; i < 8; i++)
    {
      if (RxData[i] != TxData[i])
      {
        match = 0;
        break;
      }
    }
    
    if (match)
    {
      printf("CAN Loopback Test: PASS\r\n");
    }
    else
    {
      printf("CAN Loopback Test: FAIL (Data mismatch)\r\n");
    }
  }
  else
  {
    printf("CAN Loopback Test: FAIL (ID or DLC mismatch)\r\n");
  }
}
```

## 常见问题与解决方案

<details>
<summary>💡 无法通信</summary>

如果CAN设备之间无法正常通信，可能的原因和解决方法：

1. **终端电阻问题**
   - 确保CAN总线两端有120Ω终端电阻
   - 使用万用表测量CANH和CANL之间的电阻，应该约为60Ω（两个120Ω并联）

2. **波特率不匹配**
   - 确保网络中所有设备使用相同的波特率
   - 检查时序参数配置

3. **总线干扰**
   - 使用屏蔽双绞线以减少干扰
   - 检查接地情况

4. **过滤器配置错误**
   - 确保接收设备的过滤器能够接收目标ID的报文

5. **硬件连接问题**
   - 检查CANH和CANL连接是否正确（无交叉、短路）
   - 检查电源和地连接

</details>

<details>
<summary>💡 高错误率</summary>

如果CAN通信存在高错误率：

1. **波特率过高**
   - 对于较长的总线，降低波特率以提高稳定性

2. **时序参数配置**
   - 调整同步跳跃宽度(SJW)和各时间段参数以优化采样点

3. **EMI干扰**
   - 增加共模扼流圈
   - 改善屏蔽接地

4. **总线负载过高**
   - 减少总线上的设备数量或降低消息发送频率

</details>

<details>
<summary>💡 CAN控制器进入总线关闭状态</summary>

如果CAN控制器进入总线关闭状态(Bus-Off)：

1. **硬件问题**
   - 检查CAN_H和CAN_L连接是否正确
   - 检查终端电阻是否匹配

2. **软件处理**
   - 使用AutoBusOff功能自动从总线关闭状态恢复
   - 手动重置CAN控制器

3. **高干扰环境**
   - 降低波特率或使用光电隔离器增强抗干扰能力

</details> 