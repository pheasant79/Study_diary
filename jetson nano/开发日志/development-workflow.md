# Jetson Nano B01 开发流程指南

## 目录
- [📝 前言](#-前言)
- [🗓️ 开发历程总览](#️-开发历程总览)
- [🚀 Day 1-2: 系统安装与网络配置](#-day-1-2-系统安装与网络配置)
  - [Day 1: 初始配置](#day-1-初始配置)
  - [Day 2: 系统管理与配置](#day-2-系统管理与配置)
- [🔧 Day 3-5: 开发环境构建与性能优化](#-day-3-5-开发环境构建与性能优化)
  - [Day 3: 2025年4月1日](#day-3-2025年4月1日)
  - [Day 4-5: 2025年4月2-3日](#day-4-5-2025年4月2-3日)
- [📷 Day 6-10: 计算机视觉应用开发](#-day-6-10-计算机视觉应用开发)
  - [Day 6-7: 2025年4月4-5日](#day-6-7-2025年4月4-5日)
  - [Day 8-10: 2025年4月6-8日](#day-8-10-2025年4月6-8日)
- [🤖 Day 11-15: 深度学习模型部署与优化](#-day-11-15-深度学习模型部署与优化)
  - [Day 11-12: 2025年4月9-10日](#day-11-12-2025年4月9-10日)

<div align="center">
    <img src="https://developer.nvidia.com/sites/default/files/akamai/embedded/images/jetsonNano/JetsonNano-DevKit_Front-Top_Right_trimmed.jpg" alt="Jetson Nano B01" width="400"/>
    <p><em>从零开始的嵌入式AI开发之旅</em></p>
</div>

## 📝 前言

本文档记录了我使用Jetson Nano B01进行嵌入式AI开发的完整流程。不同于各个专题文档的详细说明，这里更加注重**开发的时间线**和**思考过程**，希望能为其他开发者提供一条清晰的学习路径。

如果您正在寻找某个特定主题的详细指南，请参考相应的专题文档：
- [硬件规格](hardware.md)
- [系统安装](system-installation.md)
- [网络配置](network-configuration.md)
- [远程访问](remote-access.md)
- [开发环境搭建](development-environment.md)
- [性能优化](performance-optimization.md)
- [应用开发](applications.md)
- [故障排除](troubleshooting.md)

---

## 🗓️ 开发历程总览

我的Jetson Nano B01开发之旅大致遵循以下路径：

1. **准备阶段**（Day 0）
   - 硬件选购与配置规划
   - 开发目标确定

2. **基础环境搭建**（Day 1-3）
   - 系统安装与初始配置
   - 网络连接与SSH设置
   - 开发环境配置

3. **性能优化与调试**（Day 4-7）
   - 散热解决方案
   - 功耗与性能平衡
   - 系统监控工具配置

4. **应用开发与测试**（Day 8-15）
   - 计算机视觉应用
   - 深度学习模型部署
   - 性能评测与优化

5. **项目实战**（Day 15+）
   - 实际应用场景开发
   - 系统集成与部署
   - 持续优化与改进

下面将按照时间顺序记录每个开发阶段的具体内容、遇到的问题以及解决方案。

---

## 🚀 Day 1-2: 系统安装与网络配置

### Day 1: 初始配置

> 📔 [详细文档](initial-setup.md)

#### 今日目标

- 安装操作系统
- 配置基本网络连接
- 设置中文环境
- 测试基本功能

#### 实际操作与思考

系统选择是个重要决定。官方提供的JetPack基于Ubuntu 18.04，但考虑到长期支持和兼容性，我最终选择了社区版的Ubuntu 20.04镜像。

网络配置过程中遇到了DHCP获取IP失败的问题，花了一些时间排查。最后发现在系统初始化前安装无线网卡，选择wlan0作为连接接口可以解决问题。

基本性能测试显示，Nano在默认5W功耗模式下性能受限，切换到10W模式后有明显提升：

```bash
# 设置最高性能模式（10W）
sudo nvpmodel -m 0
sudo jetson_clocks
```

第一天最大的收获是理解了Jetson Nano的电源管理和温度控制的重要性。为了更好的散热，安装了PWM风扇并配置了自动调速脚本。

### Day 2: 系统管理与配置

> 📔 [详细文档](system-management.md)

#### 今日目标

- 解决SSH连接冲突问题
- 熟悉Linux系统管理命令
- 配置远程访问环境

#### 实际操作与思考

今天面临的主要挑战是Git SSH与Jetson SSH密钥的冲突问题。这两个服务默认使用相同的密钥路径，导致互相覆盖。通过创建独立的密钥目录和配置SSH config文件成功解决：

```bash
# 在config文件中配置不同服务的密钥
Host github.com
  HostName github.com
  User git
  IdentityFile C:\Users\用户名\.ssh\git\id_rsa
  IdentitiesOnly yes
```

在远程访问方面，除了SSH外，还配置了VNC远程桌面，以便在需要图形界面时使用。这里有个小技巧是通过自动启动脚本方便地开启VNC服务。

今天还花时间学习了Linux系统管理的常用命令，特别是进程监控、文件管理和系统性能分析工具。这些基础知识在后续开发中非常有用。

---

## 🔧 Day 3-5: 开发环境构建与性能优化

### Day 3: 2025年4月1日

> 📔 [详细日志待完成]

#### 今日目标

- 安装开发所需的编程工具
- 配置Python开发环境
- 安装深度学习框架
- 测试GPU加速功能

#### 实际操作与思考

今天重点是构建开发环境。考虑到Jetson Nano的资源限制，决定采用轻量级的开发工具和针对Jetson优化的深度学习库。

首先安装了基本的开发工具：

```bash
sudo apt install build-essential cmake git vim
```

然后配置Python环境。这里有个重要发现：pip安装包时添加`--no-deps`选项可以避免不必要的依赖，节省宝贵的存储空间。

```bash
# 安装JetPack优化的PyTorch
wget https://nvidia.box.com/shared/static/p57jwntv436lfrd78inwl7iml6p13fzh.whl -O torch-1.8.0-cp36-cp36m-linux_aarch64.whl
pip3 install torch-1.8.0-cp36-cp36m-linux_aarch64.whl
```

TensorFlow安装是个挑战，由于版本兼容性问题，最终选择了TensorFlow Lite作为替代，它更适合资源受限的Jetson Nano。

安装完成后，运行了简单的GPU加速测试，确认CUDA和cuDNN正常工作。最大的惊喜是发现Jetson Nano在某些轻量级模型上的推理性能出人意料地好。

### Day 4-5: 2025年4月2-3日

> 📔 [详细日志待完成]

#### 目标

- 优化系统性能
- 建立性能基准测试
- 解决温度控制问题
- 配置远程开发工具

#### 实际操作与思考

这两天主要关注系统优化。首先是分析内存使用：Jetson Nano共享CPU和GPU内存，需要合理分配。

```bash
# 监控内存使用
free -h

# 系统监控
sudo jtop
```

通过`nvpmodel`和`jetson_clocks`命令，可以根据不同场景动态调整性能和功耗。创建了几个脚本来快速切换不同的性能配置。

温度是个持续挑战。实测在室温环境下，满负载运行时温度可达80°C以上，影响稳定性。优化了风扇控制脚本，并在外壳上增加了额外的散热孔。

IDE选择上，考虑到资源限制，放弃了重量级的IDE，转而使用VSCode的远程开发功能，从主机远程连接Jetson Nano进行开发，这样既保留了IDE的便利性，又不占用Nano的资源。

---

## 📷 Day 6-10: 计算机视觉应用开发

### Day 6-7: 2025年4月4-5日

> 📔 [详细日志待完成]

#### 目标

- 配置摄像头
- 测试基本图像处理功能
- 构建简单的目标检测应用

#### 实际操作与思考

开始实际的应用开发。首先连接了两种摄像头：USB网络摄像头和IMX219 CSI摄像头模块。CSI摄像头因为直接连接到GPU的ISP，性能更好，但配置略复杂。

通过OpenCV和GStreamer成功调用两种摄像头：

```python
# USB摄像头
cap = cv2.VideoCapture(0)

# CSI摄像头
gst_str = "nvarguscamerasrc ! video/x-raw(memory:NVMM), width=(int)1920, height=(int)1080, format=(string)NV12, framerate=(fraction)30/1 ! nvvidconv ! video/x-raw, format=(string)BGRx ! videoconvert ! video/x-raw, format=(string)BGR ! appsink"
cap = cv2.VideoCapture(gst_str, cv2.CAP_GSTREAMER)
```

使用NVIDIA提供的`jetson-inference`库实现了实时目标检测，这个库针对Jetson优化，性能比纯PyTorch实现好很多。最让我惊喜的是能够达到约20FPS的检测速度，足够大多数实时应用场景。

在这个过程中，发现一个重要优化点：通过减小输入分辨率并使用TensorRT优化模型，可以显著提高推理速度。

### Day 8-10: 2025年4月6-8日

> 📔 [详细日志待完成]

#### 目标

- 实现多模型串联处理
- 优化图像处理管道
- 测试边缘计算场景

#### 实际操作与思考

这几天的重点是构建完整的视觉处理管道。将目标检测与分类模型串联，实现了先检测后分类的处理流程。

过程中发现，模型间数据传递是个性能瓶颈。通过在GPU内存中直接传递数据，避免CPU与GPU间的数据复制，实现了约30%的性能提升。

针对边缘计算场景，测试了低功耗模式下的持续运行能力。在5W模式下，系统可以稳定运行超过24小时而不出现明显的性能衰减，这对实际部署非常重要。

同时，发现了一个有趣的现象：某些操作在CPU上运行反而比GPU快。这提醒我们在优化时需要测量实际性能，而不是简单假设GPU总是更快。

---

## 🤖 Day 11-15: 深度学习模型部署与优化

### Day 11-12: 2025年4月9-10日

> 📔 [详细日志待完成]

#### 目标

- 理解TensorRT优化流程
- 转换模型为TensorRT格式
- 测量优化前后的性能差异

#### 实际操作与思考

TensorRT是Jetson平台上的重要优化工具。通过将PyTorch或TensorFlow模型转换为TensorRT格式，可以获得显著的性能提升。

模型转换流程总结：
1. 从PyTorch/TensorFlow模型导出ONNX格式
2. 使用TensorRT转换ONNX模型
3. 在应用中加载TensorRT引擎

实测表明，TensorRT优化后的MobileNetV2模型推理速度提升了3倍以上。这个优化对于实时应用至关重要。

不过，也发现TensorRT并非万能：某些复杂操作可能不被支持，需要在模型设计时考虑兼容性。另外，量化虽然可以进一步提高性能，但会带来一定程度的精度损失，需要在特定应用场景中权衡。

### Day 13-15: 2025年4月11-13日

> 📔 [详细日志待完成]

#### 目标

- 实现模型量化
- 开发部署脚本
- 构建自动化测试流程

#### 实际操作与思考

这几天专注于模型部署的实际问题。量化是个强大的优化手段：将FP32模型转换为INT8可以获得2-4倍的速度提升，同时只损失很小的精度。

设计了自动化部署脚本，实现从模型训练到Jetson部署的端到端流程。这大大简化了迭代开发过程。

```bash
# 自动化部署脚本流程
1. 导出ONNX模型
2. 转换为TensorRT引擎
3. 生成配置文件
4. 部署到目标设备
5. 运行验证测试
```

通过自动化测试，系统地评估了各种优化手段的效果。得出的结论是：对于Jetson Nano，模型设计和TensorRT优化对性能的影响远大于代码级优化。

---

## 🔮 未来计划

在完成基础开发后，计划在以下方向继续探索：

1. **多模型并行处理**：利用多线程实现多任务并行
2. **低功耗长时间运行优化**：进一步降低能耗，提高系统稳定性
3. **边缘-云协同系统**：实现边缘设备与云服务的协同工作
4. **集成更多传感器**：添加音频、IMU等传感器，实现多模态感知

## 📚 学习资源推荐

在Jetson Nano开发过程中，以下资源对我帮助极大：

1. [NVIDIA Jetson官方文档](https://docs.nvidia.com/jetson/)
2. [JetsonHacks博客](https://www.jetsonhacks.com/)
3. [Dusty-nv GitHub仓库](https://github.com/dusty-nv)
4. [PyImageSearch Jetson Nano教程](https://www.pyimagesearch.com/category/jetson-nano/)
5. [TensorRT文档](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/index.html)

---

<div align="center">
    <p>📝 持续更新中 | 最后更新: 2025年4月13日</p>
</div> 