# Modbus_RS485基础知识

<div align="center">

![Modbus_RS485](https://via.placeholder.com/600x150/4CAF50/FFFFFF?text=Modbus_RS485%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)

</div>

---

## 📑 目录

- [Modbus\_RS485基础知识](#modbus_rs485基础知识)
  - [📑 目录](#-目录)
  - [Modbus协议基本概念](#modbus协议基本概念)
  - [RS485总线电平特性](#rs485总线电平特性)
  - [Modbus报文格式](#modbus报文格式)
    - [Modbus RTU模式与ASCII模式](#modbus-rtu模式与ascii模式)
    - [报文结构详解](#报文结构详解)
    - [地址映射规则](#地址映射规则)
      - [数据类型详解](#数据类型详解)
      - [重要概念解释](#重要概念解释)
      - [实际应用示例](#实际应用示例)
  - [Modbus功能码详解](#modbus功能码详解)
  - [RS485通信原理](#rs485通信原理)
    - [半双工通信](#半双工通信)
    - [差分信号传输](#差分信号传输)
    - [多点网络拓扑](#多点网络拓扑)
  - [Modbus错误检测与处理](#modbus错误检测与处理)

---

## Modbus协议基本概念

<details>
<summary>📖 点击展开详细介绍</summary>

Modbus是一种串行通信协议，最初由Modicon公司（现为施耐德电气的一部分）于1979年开发，用于工业自动化领域的可编程逻辑控制器（PLC）之间的通信。

> 💡 **知识要点**: Modbus是一种主-从/客户端-服务器架构的通信协议，主要用于工业自动化设备间的数据交换。

Modbus协议的主要特点：
- 主从通信架构（一个主机，多个从机）
- 简单易实现，通信开销小
- 开放标准，免版税使用
- 通用性强，适用于各种工业控制设备
- 支持多种传输媒介（RS232、RS485、TCP/IP等）
- 多种数据结构：线圈（单个位）、寄存器（16位字）
- 最多支持247个从站（RTU/ASCII模式）
- 成熟可靠，在工业控制领域被广泛应用

</details>

## RS485总线电平特性

<div class="rs485-levels" style="background-color:#f8f9fa;padding:15px;border-radius:5px;margin:10px 0;">

- **差分电压定义**：
  - 发送方 A-B > +200mV 表示逻辑"1"
  - 发送方 A-B < -200mV 表示逻辑"0"
  - 接收方 A-B > +200mV 识别为逻辑"1"
  - 接收方 A-B < -200mV 识别为逻辑"0"
  - 接收方 -200mV < A-B < +200mV 为未定义区域

- **电平范围**：
  - 发送方差分输出电压范围：±1.5V至±6V
  - 接收方差分输入电压范围：±200mV
  - 共模电压范围：-7V至+12V

```
电平
 │
高│     B       A       B       A       B
 │   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
 │   │   │   │   │   │   │   │   │   │   │
 │   │   │   │   │   │   │   │   │   │   │
 │   │   │   │   │   │   │   │   │   │   │
 │   │   │   │   │   │   │   │   │   │   │
 │ A │   │ B │   │ A │   │ B │   │ A │   │
 │ ┌─┘   └─┐ │   │ ┌─┘   └─┐ │   │ ┌─┘   └─┐
 │ │       │ │   │ │       │ │   │ │       │
低│ │       │ └───┘ │       │ └───┘ │       │
 │ │       │       │       │       │       │
 └─┴───────┴───────┴───────┴───────┴───────┴─────>
    逻辑"1"  逻辑"0"  逻辑"1"  逻辑"0"  逻辑"1"
    (A<B)    (A>B)    (A<B)    (A>B)    (A<B)
```

注意：
- RS485是**差分信号**系统，通过A和B两线间的电位差而非绝对电平表示逻辑状态
- 逻辑"1"：B线电平高于A线（A<B，差分电压为负）
- 逻辑"0"：A线电平高于B线（A>B，差分电压为正）
- 差分电压一般在0.2V以上才能被可靠识别
- 实际使用时，A、B线的电平通常在0-5V范围内摆动

- **传输特性**：
  - 最大通信距离：1200米（低速）
  - 最大传输速率：10Mbps（短距离）
  - 支持的节点数：最多32个标准负载单元
  - 通信方式：半双工（同一时间只能发送或接收）

</div>

## Modbus报文格式

<div class="frame-structure-box" style="background-color:#e8f4f8;padding:20px;border-radius:8px;border-left:5px solid #4CAF50;margin:15px 0;">

### Modbus RTU模式与ASCII模式

<div style="display:flex;margin:15px 0;">
<div style="flex:1;background-color:#e1f5fe;padding:15px;border-radius:5px;margin-right:10px;">
<h4 style="margin-top:0;">1️⃣ RTU模式</h4>

- **特点**：
  - 高效的二进制编码
  - 更少的数据量和更快的传输速度
  - 使用CRC-16校验
  - 消息帧之间使用至少3.5个字符时间的静默间隔
  
- **适用场景**：
  - 对实时性要求较高的应用
  - 带宽受限的通信网络
  - 现代工业控制系统的首选
</div>

<div style="flex:1;background-color:#fff8e1;padding:15px;border-radius:5px;">
<h4 style="margin-top:0;">2️⃣ ASCII模式</h4>

- **特点**：
  - 使用ASCII可读字符编码
  - 使用LRC校验
  - 消息起始用':'，结束用CR/LF
  - 易于人工读取和调试
  
- **适用场景**：
  - 调试与测试环境
  - 对可读性要求高的应用
  - 与一些早期或专用设备兼容
</div>
</div>

### 报文结构详解

<table style="width:100%;border-collapse:collapse;margin:15px 0;text-align:center;">
<tr style="background-color:#4CAF50;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">字段名</th>
  <th style="padding:8px;border:1px solid #ddd;">长度(字节)</th>
  <th style="padding:8px;border:1px solid #ddd;">描述</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">从站地址</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">目标从站地址(1-247),0为广播地址</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">功能码</td>
  <td style="padding:8px;border:1px solid #ddd;">1</td>
  <td style="padding:8px;border:1px solid #ddd;">指定操作类型,如读/写线圈或寄存器</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">数据</td>
  <td style="padding:8px;border:1px solid #ddd;">N</td>
  <td style="padding:8px;border:1px solid #ddd;">请求的参数或响应的数据</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;font-weight:bold;">错误校验</td>
  <td style="padding:8px;border:1px solid #ddd;">2</td>
  <td style="padding:8px;border:1px solid #ddd;">RTU模式使用CRC-16,ASCII模式使用LRC</td>
</tr>
</table>

**RTU帧格式示例**：
```
┌─────────┬────────┬─────────┬─────────┐
│ 从站地址 │ 功能码  │  数据    │  CRC校验 │
└─────────┴────────┴─────────┴─────────┘
    1字节    1字节    N字节      2字节
```

**ASCII帧格式示例**：
```
┌────┬─────────┬────────┬─────────┬─────┬──────┐
│ :  │ 从站地址 │ 功能码  │  数据    │ LRC │ CR/LF│
└────┴─────────┴────────┴─────────┴─────┴──────┘
  1字符   2字符    2字符    2N字符   2字符  2字符
```

### 地址映射规则

Modbus协议定义了四种主要的数据类型，每种类型都有特定的地址范围。这些数据类型反映了工业自动化系统中常见的数据特征（位值/字值）和访问需求（读/写）：

<table style="width:100%;border-collapse:collapse;margin:15px 0;">
<tr style="background-color:#4CAF50;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">数据类型</th>
  <th style="padding:8px;border:1px solid #ddd;">对象类型</th>
  <th style="padding:8px;border:1px solid #ddd;">访问</th>
  <th style="padding:8px;border:1px solid #ddd;">地址范围<br>(参考地址)</th>
  <th style="padding:8px;border:1px solid #ddd;">PDU地址<br>(实际地址)</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">线圈<br>(Coil)</td>
  <td style="padding:8px;border:1px solid #ddd;">单个位<br>(开/关)</td>
  <td style="padding:8px;border:1px solid #ddd;">读写</td>
  <td style="padding:8px;border:1px solid #ddd;">1-9999</td>
  <td style="padding:8px;border:1px solid #ddd;">0000-270E</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">离散输入<br>(Discrete Input)</td>
  <td style="padding:8px;border:1px solid #ddd;">单个位<br>(开/关)</td>
  <td style="padding:8px;border:1px solid #ddd;">只读</td>
  <td style="padding:8px;border:1px solid #ddd;">10001-19999</td>
  <td style="padding:8px;border:1px solid #ddd;">0000-270E</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;">输入寄存器<br>(Input Register)</td>
  <td style="padding:8px;border:1px solid #ddd;">16位字<br>(数值)</td>
  <td style="padding:8px;border:1px solid #ddd;">只读</td>
  <td style="padding:8px;border:1px solid #ddd;">30001-39999</td>
  <td style="padding:8px;border:1px solid #ddd;">0000-270E</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;">保持寄存器<br>(Holding Register)</td>
  <td style="padding:8px;border:1px solid #ddd;">16位字<br>(数值)</td>
  <td style="padding:8px;border:1px solid #ddd;">读写</td>
  <td style="padding:8px;border:1px solid #ddd;">40001-49999</td>
  <td style="padding:8px;border:1px solid #ddd;">0000-270E</td>
</tr>
</table>

<details>
<summary>📚 <b>数据类型详细说明</b> (点击展开)</summary>

<div style="background-color:#e8f5e9;padding:15px;border-radius:5px;margin:10px 0;">

#### 数据类型详解

1. **线圈(Coil)**
   - **注意**：这里的"线圈"**不是**物理电线圈，而是一种数据类型名称，源于早期PLC控制继电器线圈的应用
   - **数据性质**：单个位(bit)，表示ON/OFF状态的**可读写**数字量
   - **典型用途**：控制输出、开关状态、布尔标志
   - **实际应用**：电机启停控制、阀门开关、指示灯、各种开关量输出
   - **功能码**：01(读)、05(写单个)、15(写多个)

2. **离散输入(Discrete Input)**
   - **数据性质**：单个位(bit)，表示ON/OFF状态的**只读**数字量
   - **典型用途**：状态输入、传感器开关量状态
   - **实际应用**：限位开关状态、按钮按下检测、故障指示、各种开关量输入
   - **功能码**：02(读)

3. **输入寄存器(Input Register)**
   - **数据性质**：16位字(word)，表示数值的**只读**模拟量
   - **典型用途**：测量值、传感器读数
   - **实际应用**：温度、压力、流量、电压、电流测量值、各种模拟量输入
   - **功能码**：04(读)

4. **保持寄存器(Holding Register)**
   - **数据性质**：16位字(word)，表示数值的**可读写**模拟量
   - **典型用途**：设定值、参数配置、控制数值
   - **实际应用**：速度设定点、温度阈值设置、PID参数配置、系统参数
   - **功能码**：03(读)、06(写单个)、16(写多个)

</div>
</details>

<details>
<summary>🔍 <b>地址映射概念解析</b> (点击展开)</summary>

<div style="background-color:#fff8e1;padding:15px;border-radius:5px;margin:10px 0;">

#### 重要概念解释

- **参考地址与PDU地址的关系**：
  - **参考地址**：用户手册中常见的地址表示方式，如40001表示第一个保持寄存器
  - **PDU地址**：实际Modbus报文中使用的地址，等于参考地址减1
  - **例如**：读取保持寄存器40001，在报文中使用PDU地址0x0000

- **地址计算示例**：
  - 线圈100 → PDU地址 = 100 - 1 = 99 (0x0063)
  - 离散输入10100 → PDU地址 = 10100 - 10001 = 99 (0x0063)
  - 输入寄存器30050 → PDU地址 = 30050 - 30001 = 49 (0x0031)
  - 保持寄存器40200 → PDU地址 = 40200 - 40001 = 199 (0x00C7)

- **PDU地址重叠**：
  - 四种类型的PDU地址范围都是0000-270E
  - 功能码决定访问的是哪种数据类型
  - 如：功能码01访问线圈，功能码03访问保持寄存器

</div>
</details>

<details>
<summary>🏭 <b>实际应用示例</b> (点击展开)</summary>

<div style="background-color:#e1f5fe;padding:15px;border-radius:5px;margin:10px 0;">

#### 实际应用示例

**场景1：电机控制与监测**
- 线圈1 (PDU地址0): 电机启停控制
- 离散输入10001 (PDU地址0): 电机运行状态反馈
- 保持寄存器40001 (PDU地址0): 电机速度设定值
- 输入寄存器30001 (PDU地址0): 电机实际速度读数

**场景2：温度控制系统**
- 保持寄存器40020 (PDU地址19): 温度设定点
- 输入寄存器30020 (PDU地址19): 当前温度读数
- 线圈20 (PDU地址19): 加热器开关控制
- 离散输入10020 (PDU地址19): 过热报警状态

</div>
</details>

> **小贴士**：在实际应用中，不同设备厂商可能采用不同的地址表示方式。有些可能直接使用PDU地址，有些可能使用带偏移的参考地址。阅读设备手册时需特别注意地址的表示方法。

</div>

## Modbus功能码详解

<div class="function-codes" style="background-color:#f5f5f5;padding:15px;border-radius:5px;margin:10px 0;">

Modbus功能码定义了主站请求从站执行的具体操作。标准功能码范围是1-127，错误响应会在功能码的最高位置1（功能码+128）。

**常用功能码**：

<table style="width:100%;border-collapse:collapse;margin:10px 0;">
<tr style="background-color:#4CAF50;color:white;">
  <th style="padding:8px;border:1px solid #ddd;">功能码</th>
  <th style="padding:8px;border:1px solid #ddd;">名称</th>
  <th style="padding:8px;border:1px solid #ddd;">操作</th>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">01</td>
  <td style="padding:8px;border:1px solid #ddd;">读线圈</td>
  <td style="padding:8px;border:1px solid #ddd;">读取1到2000个连续线圈的状态</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">02</td>
  <td style="padding:8px;border:1px solid #ddd;">读离散输入</td>
  <td style="padding:8px;border:1px solid #ddd;">读取1到2000个连续离散输入的状态</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">03</td>
  <td style="padding:8px;border:1px solid #ddd;">读保持寄存器</td>
  <td style="padding:8px;border:1px solid #ddd;">读取1到125个连续保持寄存器的值</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">04</td>
  <td style="padding:8px;border:1px solid #ddd;">读输入寄存器</td>
  <td style="padding:8px;border:1px solid #ddd;">读取1到125个连续输入寄存器的值</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">05</td>
  <td style="padding:8px;border:1px solid #ddd;">写单个线圈</td>
  <td style="padding:8px;border:1px solid #ddd;">强制单个线圈为ON或OFF状态</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">06</td>
  <td style="padding:8px;border:1px solid #ddd;">写单个寄存器</td>
  <td style="padding:8px;border:1px solid #ddd;">写入单个保持寄存器的值</td>
</tr>
<tr>
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">15</td>
  <td style="padding:8px;border:1px solid #ddd;">写多个线圈</td>
  <td style="padding:8px;border:1px solid #ddd;">强制多个连续线圈的状态</td>
</tr>
<tr style="background-color:#f2f2f2;">
  <td style="padding:8px;border:1px solid #ddd;text-align:center;">16</td>
  <td style="padding:8px;border:1px solid #ddd;">写多个寄存器</td>
  <td style="padding:8px;border:1px solid #ddd;">写入多个连续保持寄存器的值</td>
</tr>
</table>

**功能码使用示例**：

- **读保持寄存器(03)**:
  ```
  请求: 01 03 00 6B 00 03 xx xx   (从地址01的从站读取地址0x006B的3个寄存器)
  响应: 01 03 06 xx xx xx xx xx xx xx xx (返回6个字节的数据)
  ```

- **写单个线圈(05)**:
  ```
  请求: 01 05 00 AC FF 00 xx xx   (向地址01的从站写入地址0x00AC的线圈为ON)
  响应: 01 05 00 AC FF 00 xx xx   (成功响应与请求相同)
  ```

</div>

## RS485通信原理

<div class="rs485-principles" style="background-color:#fff8e1;padding:15px;border-radius:5px;border-left:5px solid #FFA000;margin:10px 0;">

### 半双工通信

RS485采用半双工通信方式，即：
- 任何时刻只允许一个设备发送数据
- 通信方向需要切换（发送→接收或接收→发送）
- 需要软件或硬件控制发送/接收切换
- 适用于主从通信模式，避免总线冲突

```
┌─────┐                      ┌─────┐
│     │◄───────RS485────────►│     │
│主站  │                      │从站  │
└─────┘                      └─────┘
  ↑↓                           ↑↓
 发送                          发送
  或                           或
 接收                          接收
```

### 差分信号传输

RS485的核心技术是差分信号传输:
- 使用两根信号线(A/B)传输互补信号
- 接收方检测两线间的电压差而非绝对电压
- 共模干扰同时影响两根线，不改变差值
- 提供极强的抗干扰能力与较远传输距离
- 适合在恶劣工业环境下使用

```
    A线 ─────┐       ┌──── 噪声 ────┐       ┌───── A线+噪声
            │       │               │       │
            ▼       ▼               ▼       ▼
电压  ─── ─────────────────────────────────────────▶ 时间
            ▲       ▲               ▲       ▲
            │       │               │       │
    B线 ─────┘       └──── 噪声 ────┘       └───── B线+噪声
    
                    接收方只检测A与B的差值
```

### 多点网络拓扑

RS485支持多点连接:
- 最多支持32个标准负载设备
- 使用增强型收发器可达到256个设备
- 必须采用总线拓扑结构（不支持星型或环型）
- 总线两端需要接入120Ω终端电阻

```
┌─────┐    ┌─────┐    ┌─────┐         ┌─────┐
│设备1 │    │设备2 │    │设备3 │    ...  │设备n │
└──┬──┘    └──┬──┘    └──┬──┘         └──┬──┘
   │          │          │               │
   └──────────┴──────────┴───────...─────┘
   │                                      │
 120Ω                                   120Ω
   │                                      │
  GND                                    GND
```

</div>

## Modbus错误检测与处理

<details>
<summary>🔍 Modbus错误检测与处理机制</summary>

Modbus协议提供了两个错误检测层级：

1. **通信错误检测**:
   - RTU模式使用CRC-16循环冗余校验
   - ASCII模式使用LRC纵向冗余校验
   - 检测数据传输过程中的位错误
   - 校验失败的报文将被丢弃，无响应

2. **应用层错误处理**:
   - 从站在收到有效请求后，检查是否可以执行
   - 如有错误，返回异常响应：功能码+0x80和异常码
   - 主站通过检查响应的功能码判断是否有异常

**常见异常码**:

| 异常码 | 名称 | 含义 |
|:-----:|:-----|:-----|
| 0x01 | 非法功能 | 从站不支持请求的功能码 |
| 0x02 | 非法数据地址 | 请求的数据地址不可用 |
| 0x03 | 非法数据值 | 请求的数据值超出范围 |
| 0x04 | 从站设备故障 | 从站试图执行操作时发生不可恢复的错误 |
| 0x05 | 确认 | 请求已接受，但需要较长处理时间 |
| 0x06 | 从站设备忙 | 从站正在处理长时间命令，请稍后重试 |
| 0x08 | 内存奇偶校验错误 | 请求的扩展文件区域发生内存奇偶校验错误 |

**错误处理策略**:
- 主站应设置适当的超时时间等待响应
- 对无响应的请求应实施重试机制
- 应用层应处理异常响应并采取相应措施
- 对于连续多次失败的通信，应通知操作员或记录日志

</details> 