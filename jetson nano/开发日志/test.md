# NVIDIA Jetson Nano B01开发板配置完全指南

## Jetson Nano B01硬件介绍

NVIDIA Jetson Nano B01是一款专为AI和计算机视觉应用设计的入门级嵌入式系统：

- 搭载四核ARM Cortex-A57 CPU (1.43 GHz)
- 配备4GB LPDDR4内存
- 集成128核NVIDIA Maxwell GPU
- 支持SD卡启动系统
- 提供40针GPIO接口
- 具有4个USB 3.0接口和1个HDMI输出
- 支持5W-10W可调节功耗模式

本指南专注于Jetson Nano B01型号的配置方法和使用技巧。

## Jetson Nano系统烧录

### 系统版本选择

Jetson Nano B01采用4GB内存版本，性能足以支持多数AI开发场景和并行任务处理。

### 社区版和官方版的区别

Jetson Nano B01的系统镜像分为两种版本：

- **官方版**：由NVIDIA官方提供，只包含基本系统和驱动，系统纯净稳定
- **社区版**：基于官方版进行二次开发，预装了常用库和开发工具

为了获得最佳稳定性和可控性，我们建议使用官方版系统镜像，按需安装所需组件。

### 系统烧录步骤

1. **准备工作**：
   - 一张高速SD卡（推荐64GB或以上，建议选择Class 10或UHS-I级别）
   - 一台运行Windows的电脑
   - 下载Jetson Nano B01的[系统镜像](https://developer.nvidia.com/embedded/downloads)
   - 下载[Jetson Nano Developer Kit SD Card Image](https://developer.nvidia.com/embedded/downloads)

2. **格式化SD卡**：
   - 使用SD卡管理工具格式化SD卡
   - 选择文件系统类型为NTFS或FAT32

3. **系统烧录**：
   - 下载并安装[balenaEtcher](https://etcher.balena.io/)烧录工具
   - 打开balenaEtcher，选择下载好的系统镜像
   - 选择已格式化的SD卡作为目标设备
   - 点击"Flash!"开始烧录过程（大约需要10-20分钟）

### 检验烧录是否成功

1. 将烧录完成的SD卡插入Jetson Nano B01的SD卡插槽
2. 连接电源适配器并开机
3. 观察指示灯：
   - 电源指示灯亮起且系统指示灯有闪烁表示系统启动正常
   - 如果指示灯不亮或异常，可能是烧录失败或电源供电不稳定

### Jetson Nano B01电源供电说明

Jetson Nano B01有两种供电方式：

1. **Micro-USB供电**（默认）：
   - 便捷但功率有限（最大5V/2A）
   - 运行AI应用时可能不稳定，导致系统重启

2. **DC电源接口供电**（强烈推荐）：
   - 需要短接J48引脚启用（在板子边缘，使用跳线帽短接）
   - 使用5V/4A直流电源适配器
   - 提供稳定电源，适合长时间运行或训练AI模型

## Jetson系统初始化

### 初始化准备工作

Jetson Nano B01运行的是Ubuntu 18.04 LTS系统，首次启动需要进行以下设置：

- 设置用户名和密码
- 配置系统语言和地区
- 连接WiFi或有线网络
- 设置系统时区

如果没有额外的显示器和键盘，可通过串口连接完成初始化。

### 串口连接设置

1. **硬件准备**：
   - USB转TTL串口线（3.3V逻辑电平）
   - 连接Jetson Nano B01的J44引脚组（位于板子边缘）

2. **接线方法**：
   - 将串口线的GND连接到J44的Pin 6（GND）
   - TX连接到J44的Pin 8（UART_TXD）
   - RX连接到J44的Pin 10（UART_RXD）

3. **软件配置**：
   - 在电脑上安装[PuTTY](https://www.putty.org/)串口终端软件
   - 打开设备管理器查看串口号（如COM3）
   - 配置PuTTY参数：串口号、波特率115200、数据位8、停止位1、无奇偶校验
   - 连接后，可在终端窗口中看到启动信息并登录系统

4. **系统设置**：
   - 按照提示创建用户（建议使用默认用户名nvidia）
   - 设置安全密码
   - 完成系统配置

## Jetson Nano B01的SSH连接

### 为什么需要SSH连接？

SSH（Secure Shell）连接让我们可以从电脑远程操控Jetson Nano B01，具有以下优势：

- 无需连接额外的显示器和键盘
- 可以远程执行命令、传输文件
- 连接稳定且安全加密

### 通过USB实现SSH连接

Jetson Nano B01支持通过USB数据线直接与电脑建立网络连接：

1. **连接设备**：
   - 使用Micro-USB数据线连接Jetson Nano B01和电脑
   - 确保使用的是数据线而非仅充电线缆

2. **识别设备**：
   - Windows设备管理器中会出现"Remote NDIS Compatible Device"网络设备

### Windows系统网络共享配置

为使Jetson Nano B01通过电脑连接互联网，需设置网络共享：

1. 打开控制面板 → 网络和Internet → 网络连接
2. 右键点击已连接互联网的网络（通常是WiFi）
3. 选择"属性" → "共享"选项卡
4. 勾选"允许其他网络用户通过此计算机的Internet连接来连接"
5. 在下拉菜单中选择"Remote NDIS Compatible Device"
6. 点击"确定"保存设置

### 设置静态IP（解决连接不稳定）

如果USB连接经常断开，可尝试设置静态IP：

1. 打开控制面板 → 网络连接
2. 右键点击"Remote NDIS Compatible Device"
3. 选择"属性" → 双击"Internet协议版本4(TCP/IPv4)"
4. 选择"使用下面的IP地址"并填写：
   - IP地址：192.168.55.100
   - 子网掩码：255.255.255.0
   - 默认网关：192.168.55.1
5. 点击"确定"保存设置

详细解决方案可参考：[解决Jetson Nano USB连接Windows电脑频繁断连的问题](https://www.patzer0.com/archives/jetson-frequently-lost-connection-to-windows-computers-via-usb-rndis)

### 建立SSH连接

1. **安装SSH客户端**：
   - 推荐使用[XShell](https://www.netsarang.com/en/xshell/)或[PuTTY](https://www.putty.org/)
   - Windows 10也可使用内置的SSH客户端（PowerShell或命令提示符）

2. **配置连接**：
   - 主机地址：192.168.55.1（Jetson Nano B01的默认USB连接IP）
   - 端口：22
   - 用户名：nvidia（或您设置的用户名）
   - 认证方式：密码

3. **连接步骤**：
   - 首次连接会提示接受主机密钥
   - 输入密码后即可成功连接到Jetson Nano B01

## Jetson Nano B01开发环境配置

### 系统更新与基础软件安装

首次连接到Jetson Nano B01后，建议执行以下命令更新系统并安装基础开发工具：

```bash
# 更新软件源和系统
sudo apt update
sudo apt upgrade -y

# 安装基础开发工具
sudo apt install build-essential cmake git python3-dev python3-pip -y
```

### 安装AI开发库

Jetson Nano B01专为AI和视觉处理而设计，可安装以下库：

```bash
# 安装科学计算库
sudo apt install libopenblas-dev liblapack-dev -y

# 安装CUDA相关工具（通常预装）
# 检查CUDA版本
nvcc --version

# 注意：PyTorch、TensorFlow等深度学习框架需要安装特定版本
# 请参考NVIDIA官方文档安装适合Jetson Nano B01的版本
```

### 配置Python开发环境

```bash
# 创建Python虚拟环境
pip3 install virtualenv
virtualenv -p python3 ~/nano_env
source ~/nano_env/bin/activate

# 安装常用数据科学和开发库
pip install numpy matplotlib jupyter pandas
```

## Jetson Nano B01性能优化与故障排除

### 性能优化

Jetson Nano B01支持两种功耗模式，可根据需求切换：

```bash
# 查看当前功耗模式
sudo nvpmodel -q

# 设置高性能模式（10W）
sudo nvpmodel -m 0

# 设置节能模式（5W）
sudo nvpmodel -m 1

# 设置最大时钟频率
sudo jetson_clocks
```

### 散热管理

Jetson Nano B01在高负载下易发热，建议：

- 安装散热风扇（建议40mm）
- 避免在密闭环境使用
- 使用下列命令监控温度：
  ```bash
  # 实时查看温度、功耗等参数
  tegrastats
  ```

### 常见问题解决

1. **启动问题**：
   - 如系统无法启动，检查SD卡接触是否良好
   - 确认电源适配器输出足够（建议5V/4A）

2. **连接问题**：
   - SSH连接失败：确认IP地址和网络设置
   - USB连接不稳定：尝试使用质量更好的USB线缆

3. **性能问题**：
   - 运行缓慢：检查是否处于节能模式（5W）
   - 自动降频：监控温度，改善散热

### 系统备份

当配置好Jetson Nano B01后，建议创建备份：

```bash
# 创建SD卡镜像备份
sudo dd if=/dev/mmcblk0 of=/path/to/backup.img bs=1M status=progress

# 恢复系统时，使用balenaEtcher将备份镜像写入新SD卡
```

## 结论

Jetson Nano B01是一款功能强大的AI开发平台，通过本指南的配置，您可以顺利开始AI和计算机视觉的开发工作。建议定期关注NVIDIA官方更新，获取最新的驱动和软件支持。