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

## 💢 最常见且棘手的问题

以下是开发过程中最常遇到且最难解决的问题，提前了解这些问题可以节约大量开发时间：

<details>
<summary><b>1. USB网络连接不稳定问题</b></summary>
<p>
<b>问题：</b>通过USB连接电脑时，连接经常断开或不稳定。<br>
<b>解决方案：</b>在Windows上设置USB网络的静态IP：<br>
1. 控制面板 → 网络连接<br>
2. 右键点击"Remote NDIS Compatible Device"<br>
3. 选择"属性" → 双击"Internet协议版本4(TCP/IPv4)"<br>
4. 设置IP地址：192.168.55.100，子网掩码：255.255.255.0，网关：192.168.55.1<br>
详细步骤请参考<a href="network-configuration.md#设置静态ip解决连接不稳定问题">网络配置文档</a>。
</p>
</details>

<details>
<summary><b>2. WiFi网卡无法识别或连接失败</b></summary>
<p>
<b>问题：</b>安装WiFi网卡后无法识别或无法正常连接无线网络。<br>
<b>解决方案：</b><br>
1. 确保使用兼容的WiFi网卡（推荐Intel AC8265/9260）<br>
2. 检查驱动是否正确加载：<code>lspci | grep Network</code><br>
3. 解除无线网卡阻止：<code>sudo rfkill unblock all</code><br>
4. 手动连接WiFi：<code>sudo nmcli dev wifi connect "WiFi名称" password "密码"</code><br>
详情参考<a href="network-configuration.md#无线网络配置">无线网络配置</a>。
</p>
</details>

<details>
<summary><b>3. Ubuntu 20.04系统烧录问题</b></summary>
<p>
<b>问题：</b>官方JetPack基于Ubuntu 18.04，但许多用户需要Ubuntu 20.04。<br>
<b>解决方案：</b><br>
1. 下载社区版Ubuntu 20.04镜像，如<a href="https://github.com/Qengineering/Jetson-Nano-Ubuntu-20-image">QEngineering镜像</a><br>
2. 解压.xz格式文件得到.img文件<br>
3. 使用专业烧录工具(如balenaEtcher)将镜像写入SD卡<br>
4. 默认登录凭据通常为：用户名：<code>jetson</code> 密码：<code>jetson</code><br>
详情请参考<a href="system-installation.md#系统版本选择">系统安装指南</a>和<a href="system-management.md#下载与烧录系统">系统管理文档</a>。
</p>
</details>

<details>
<summary><b>4. 风扇自启动配置</b></summary>
<p>
<b>问题：</b>重启后风扇设置丢失，需要手动启动风扇控制。<br>
<b>解决方案：</b><br>
1. 创建开机自启动脚本：<code>sudo gedit /etc/rc.local</code><br>
2. 添加以下命令：<code>sudo sh -c 'echo 100 > /sys/devices/pwm-fan/target_pwm'</code><br>
3. 确保文件具有执行权限：<code>sudo chmod 755 /etc/rc.local</code><br>
或者安装自动风扇控制工具：<code>git clone https://github.com/Pyrestone/jetson-fan-ctl.git</code><br>
详情请参考<a href="initial-setup.md#风扇开机自启动设置">初始配置文档</a>。
</p>
</details>

<details>
<summary><b>5. Jupyter Notebook配置</b></summary>
<p>
<b>问题：</b>远程访问Jupyter Notebook服务失败或配置复杂。<br>
<b>解决方案：</b><br>
1. 安装Jupyter：<code>pip3 install jupyter jupyterlab</code><br>
2. 生成配置文件：<code>jupyter notebook --generate-config</code><br>
3. 设置远程访问密码：<code>jupyter notebook password</code><br>
4. 配置允许远程访问：<br>
   <code>echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py</code><br>
   <code>echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py</code><br>
5. 启动服务：<code>jupyter notebook</code><br>
详情请参考<a href="development-environment.md#配置jupyter-notebook">开发环境配置文档</a>。
</p>
</details>

<details>
<summary><b>6. 多SSH密钥冲突问题</b></summary>
<p>
<b>问题：</b>Jetson SSH连接覆盖了GitHub SSH配置，导致无法向GitHub提交代码。<br>
<b>解决方案：</b><br>
1. 为Git创建独立的SSH密钥目录：<code>mkdir -p C:\Users\用户名\.ssh\git</code><br>
2. 生成新的SSH密钥对：<code>ssh-keygen -t rsa -C "你的邮箱地址"</code>（保存到刚创建的目录）<br>
3. 创建SSH配置文件(<code>C:\Users\用户名\.ssh\config</code>)：<br>
   ```
   Host github.com
     HostName github.com
     User git
     IdentityFile C:\Users\用户名\.ssh\git\id_rsa
     IdentitiesOnly yes
   ```
4. 测试连接：<code>ssh -T -v git@github.com</code><br>
详情请参考<a href="system-management.md#git与jetson的ssh配置冲突解决">系统管理文档</a>。
</p>
</details>

<details>
<summary><b>7. 键盘按键映射错误问题</b></summary>
<p>
<b>问题：</b>系统启动后键盘方向键变成了ABCD字母，无法正常使用。<br>
<b>解决方案：</b><br>
1. 编辑Vim配置文件：<code>sudo vi /etc/vim/vimrc.tiny</code><br>
2. 将<code>set compatible</code>改为<code>set nocompatible</code><br>
3. 添加一行<code>set backspace=2</code><br>
4. 保存并退出<br>
这是Vi/Vim配置问题导致的，修改后方向键将正常工作。<br>
详情请参考<a href="system-management.md#键盘映射问题修复">系统管理文档</a>。
</p>
</details>

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




正常使用
1.配置烧录系统
2.配置网络
3.配置远程连接
4.配置风扇控制

开发配置
1.配置开发环境(python,jupyter)

jetson硬件库
1.配置gpio
2.配置pwm
3.配置adc
4.配置i2c
5.摄像头
6.传感器

linux的cuda,opencv,tensorflow,pytorch,等
1.cuda
2.opencv
3.tensorflow
4.pytorch



