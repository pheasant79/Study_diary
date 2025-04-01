# Jetson Nano B01 开发板配置与应用指南

<div align="center">
    <img src="https://developer.nvidia.com/sites/default/files/akamai/embedded/images/jetsonNano/JetsonNano-DevKit_Front-Top_Right_trimmed.jpg" alt="Jetson Nano B01" width="400"/>
    <p><em>NVIDIA Jetson Nano B01 - 边缘AI计算平台</em></p>
</div>

## 📚 文档导航

本项目记录了使用Jetson Nano B01进行AI和嵌入式开发的完整历程。无论您是初学者还是有经验的开发者，都能从中获取有价值的信息与经验。

### 🔰 核心文档

按照以下推荐顺序阅读，可以从零开始快速掌握Jetson Nano的配置与使用：

1. [**硬件了解**](hardware.md) - 详细了解Jetson Nano B01的硬件规格和接口布局
2. [**系统安装**](system-installation.md) - 从系统镜像烧录到首次启动配置的完整指南
3. [**网络配置**](network-configuration.md) - 有线和无线网络设置方法详解
4. [**远程访问**](remote-access.md) - SSH、VNC和串口连接的配置步骤
5. [**开发环境**](development-environment.md) - 搭建AI和机器视觉开发所需的软件环境
6. [**性能优化**](performance-optimization.md) - 让您的Jetson Nano发挥最佳性能
7. [**应用开发**](applications.md) - 计算机视觉、机器学习和IoT应用开发实例

### 📋 实用操作指南

这些文档包含了实际开发过程中积累的经验和解决方案：

- [**初始配置与环境搭建**](initial-setup.md) - 网络设置、系统优化与软件配置
- [**系统管理与SSH配置**](system-management.md) - SSH多账户管理、软件管理与风扇控制
- [**开发流程指南**](development-workflow.md) - 完整的开发时间线与方法论
- [**故障排除**](troubleshooting.md) - 常见问题的解决方案

### 📊 项目概览

- [**项目总结**](project-summary.md) - Jetson Nano项目的整体架构和成果概述

---

## ⚡ 快速入门

### 硬件准备清单

- Jetson Nano B01开发板
- 高质量电源（建议5V/4A DC电源适配器）
- 16GB或更大的microSD卡（Class 10或UHS-I速度等级）
- 有线网络或兼容的WiFi适配器
- HDMI显示器、USB键盘和鼠标
- 散热器和风扇（强烈推荐）

### 首次启动流程

1. **准备SD卡**
   ```bash
   # 使用balenaEtcher或DD命令烧录系统镜像
   sudo dd if=jetson-nano-sd-card-image.img of=/dev/sdX bs=1M status=progress
   ```

2. **连接必要设备**
   - 将SD卡插入设备底部
   - 连接显示器、键盘、鼠标和网线
   - 连接电源适配器

3. **初始化设置**
   - 设置用户名密码（默认: jetson/jetson）
   - 配置时区和语言
   - 更新系统软件包

4. **开发环境配置**
   ```bash
   # 系统更新
   sudo apt update && sudo apt upgrade -y
   
   # 安装基本开发工具
   sudo apt install -y build-essential cmake git python3-pip
   ```

---

## 💡 常见问题解答

<details>
<summary><b>系统无法启动怎么办？</b></summary>
<p>
检查电源是否稳定供电，SD卡是否正确插入。如果问题依旧，可能需要重新烧录系统镜像或参考<a href="troubleshooting.md#系统启动问题">故障排除指南</a>。
</p>
</details>

<details>
<summary><b>如何优化系统性能？</b></summary>
<p>
Jetson Nano支持多种功耗模式，可通过<code>sudo nvpmodel -m 0</code>命令切换到高性能模式。更多优化方法请参考<a href="performance-optimization.md">性能优化指南</a>。
</p>
</details>

<details>
<summary><b>远程开发如何配置？</b></summary>
<p>
推荐使用SSH和VNC进行远程访问。配置方法：<br>
- SSH: <code>sudo apt install openssh-server</code><br>
- VNC: <code>sudo apt install vino</code><br>
详细步骤请查看<a href="remote-access.md">远程访问配置</a>。
</p>
</details>

<details>
<summary><b>摄像头不工作？</b></summary>
<p>
USB摄像头应自动识别。CSI摄像头需确保连接正确并运行<code>v4l2-ctl --list-devices</code>检查识别情况。详见<a href="applications.md#配置摄像头">应用开发指南</a>。
</p>
</details>

---

## 📚 参考资源

- [NVIDIA Jetson Nano官方文档](https://developer.nvidia.com/embedded/jetson-nano-developer-kit)
- [JetsonHacks教程和指南](https://www.jetsonhacks.com/category/jetson-nano/)
- [NVIDIA开发者论坛](https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/jetson-nano/76)
- [PyImageSearch Jetson Nano教程](https://www.pyimagesearch.com/category/jetson-nano/)
- [Jetson AI Certification项目](https://developer.nvidia.com/embedded/learn/jetson-ai-certification-programs)

---

<div align="center">
    <p>📝 本文档不断完善中 | 欢迎提出建议和改进意见</p>
    <p>最后更新: 2025年3月31日</p>
</div> 