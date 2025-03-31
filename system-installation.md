# Jetson Nano B01 系统安装指南

本文档详细介绍 Jetson Nano B01 开发板的系统选择、烧录和初始化过程。正确的系统安装是开发工作的基础，请按照以下步骤操作以确保顺利完成设置。

## 系统版本选择

### 官方版与社区版对比

Jetson Nano B01 的系统镜像主要分为两种版本：

| 特性 | 官方版 | 社区版 |
|------|--------|--------|
| 提供方 | NVIDIA官方 | 社区开发者或第三方 |
| 系统基础 | Ubuntu 18.04 LTS | 通常基于Ubuntu 18.04/20.04 |
| 预装软件 | 基本驱动和工具 | 常用库和开发工具 |
| 稳定性 | 较高 | 视开发者而定 |
| 适用场景 | 需要高度稳定、自定义安装 | 快速开始、预装常用工具 |

推荐下载链接：

- **官方版**：[NVIDIA Jetson Nano 开发者套件](https://developer.nvidia.com/embedded/downloads)
- **推荐社区版**：[QEngineering Ubuntu 20.04镜像](https://github.com/Qengineering/Jetson-Nano-Ubuntu-20-image)

### 系统版本推荐

初学者建议选择：

- 如果希望快速上手并使用深度学习框架：选择预装OpenCV、TensorFlow和PyTorch的社区版
- 如果希望从基础开始学习和构建系统：选择官方版

进阶用户建议选择：

- 官方版，并按需安装所需组件，以获得最佳的系统稳定性和控制能力

## 系统烧录步骤

### 准备工作

需要准备以下物品：

- Jetson Nano B01开发板
- 高速SD卡（推荐64GB或以上，Class 10或UHS-I级别）
- 读卡器
- 电源适配器（5V/4A推荐）
- 一台运行Windows、Linux或macOS的电脑

### 下载系统镜像

1. 访问[NVIDIA官方下载页面](https://developer.nvidia.com/embedded/downloads)
2. 选择"Jetson Nano Developer Kit SD Card Image"
3. 下载最新版本的镜像文件（约6GB，文件名类似于`nv-jetson-nano-sd-card-image-r32.x.x.zip`）

### 烧录系统镜像

#### 使用balenaEtcher（推荐）

1. 下载并安装[balenaEtcher](https://www.balena.io/etcher/)
2. 将SD卡通过读卡器连接到电脑
3. 打开balenaEtcher
4. 点击"Flash from file"选择下载的镜像文件
5. 点击"Select target"选择SD卡
6. 点击"Flash!"开始烧录过程
7. 等待烧录和验证完成（大约需要10-20分钟）

#### 使用SD Card Formatter和Win32DiskImager（Windows替代方案）

1. 使用[SD Card Formatter](https://www.sdcard.org/downloads/formatter/)格式化SD卡
2. 使用[Win32DiskImager](https://sourceforge.net/projects/win32diskimager/)将镜像写入SD卡

### 验证烧录结果

烧录完成后，可以：

1. 将SD卡插入Jetson Nano B01的SD卡插槽
2. 连接显示器（HDMI）、键盘和鼠标
3. 连接电源，开机启动
4. 观察系统是否正常启动（约1-2分钟）

如果系统能正常启动到Ubuntu桌面，则烧录成功。

## 系统初始化设置

首次启动系统时，需要完成以下初始化设置：

### 使用显示器和键盘进行设置（推荐）

1. 按照屏幕提示完成语言选择
2. 选择时区和键盘布局
3. 创建用户账户（建议使用默认用户名`nvidia`）和密码
4. 连接到无线网络（如果已安装无线网卡）
5. 完成系统更新

### 使用串口进行无显示器设置（Headless）

如果没有显示器，可以通过串口连接进行设置：

#### 准备工作
- USB转TTL串口线（3.3V逻辑电平）
- 串口终端软件（如PuTTY）

#### 连接方法
1. 将串口线连接到Jetson Nano的J44引脚组：
   - GND连接到Pin 6（GND）
   - TX连接到Pin 8（UART_TXD）
   - RX连接到Pin 10（UART_RXD）

2. 软件设置：
   - 波特率：115200
   - 数据位：8
   - 停止位：1
   - 奇偶校验：无
   - 流控制：无

3. 插入SD卡并连接电源，通过串口完成初始化设置

## 系统设置验证

完成初始化后，建议执行以下检查确保系统正常：

```bash
# 检查系统版本
cat /etc/os-release

# 检查CUDA版本
nvcc --version

# 检查GPU状态
sudo jetson_clocks --show

# 检查可用磁盘空间
df -h

# 检查系统负载和内存使用
free -h
```

## JetPack组件验证

NVIDIA JetPack SDK是Jetson平台的软件开发包。验证其关键组件：

```bash
# 检查CUDA示例
cd /usr/local/cuda/samples/1_Utilities/deviceQuery
sudo make
./deviceQuery

# 查看cuDNN版本
cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
```

## 常见问题

1. **系统无法启动**
   - 检查SD卡是否正确插入
   - 尝试重新烧录SD卡
   - 确认电源供应稳定（建议使用5V/4A适配器）

2. **初始化过程中断**
   - 记录错误信息
   - 尝试重新启动系统
   - 如问题持续，尝试重新烧录系统

3. **无法识别SD卡**
   - 尝试其他格式化工具，如[SD Memory Card Formatter](https://www.sdcard.org/downloads/formatter/)
   - 更换SD卡（部分老旧或低质量SD卡可能不兼容）

## 结语

完成上述步骤后，您的Jetson Nano B01已完成基本系统安装。下一步可以进行[网络配置](network-configuration.md)或[开发环境搭建](development-environment.md)。 