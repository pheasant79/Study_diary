# Jetson Nano B01 远程访问指南

本文档详细介绍如何远程访问和控制Jetson Nano B01开发板，包括SSH、VNC和串口连接等方式，让您无需直接连接显示器和键盘鼠标即可操作设备。

## 为什么需要远程访问？

远程访问Jetson Nano B01具有以下优势：

1. **无需外设**：不需要额外的显示器、键盘和鼠标
2. **便捷操作**：可以从笔记本电脑或台式机直接控制Jetson Nano
3. **资源共享**：便于在开发机和Jetson之间传输文件
4. **远程开发**：支持在远程位置进行开发和调试
5. **显存优化**：不使用图形界面时，可以释放更多显存用于AI任务

## SSH远程连接

### 准备工作

确保Jetson Nano B01已经：
1. 完成系统初始化设置
2. 连接到网络（有线或无线）
3. SSH服务已启用（默认已启用）

### 查找Jetson Nano的IP地址

有多种方法可以查找Jetson Nano的IP地址：

1. **在Jetson Nano上运行**（如果有显示器）：
   ```bash
   ifconfig
   # 或
   ip addr
   ```

2. **通过路由器管理界面**查看连接的设备列表

3. **使用网络扫描工具**（在另一台电脑上）：
   ```bash
   # Linux/macOS
   nmap -sn 192.168.1.0/24
   
   # Windows
   # 使用高级IP扫描器等工具
   ```

### 使用SSH客户端连接

#### Windows系统

1. **使用PuTTY**：
   - 下载并安装[PuTTY](https://www.putty.org/)
   - 输入Jetson Nano的IP地址
   - 端口保持默认值22
   - 连接类型选择SSH
   - 点击"打开"建立连接
   - 输入用户名（默认是`nvidia`）和密码

2. **使用Windows PowerShell或命令提示符**（Windows 10及更高版本）：
   ```powershell
   ssh nvidia@192.168.1.xxx  # 替换为实际IP地址
   ```

#### Linux/macOS系统

直接在终端中使用SSH命令：

```bash
ssh nvidia@192.168.1.xxx  # 替换为实际IP地址
```

### 配置SSH密钥认证（可选但推荐）

设置SSH密钥可以避免每次连接都输入密码：

1. **在你的电脑上生成SSH密钥**（如果尚未生成）：
   ```bash
   ssh-keygen -t rsa -b 4096
   # 按照提示完成，默认情况下密钥会保存在~/.ssh/目录下
   ```

2. **将公钥复制到Jetson Nano**：
   ```bash
   # Linux/macOS
   ssh-copy-id nvidia@192.168.1.xxx
   
   # Windows (使用PowerShell)
   type $env:USERPROFILE\.ssh\id_rsa.pub | ssh nvidia@192.168.1.xxx "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   ```

3. **测试免密登录**：
   ```bash
   ssh nvidia@192.168.1.xxx
   ```

### 通过USB连接SSH

Jetson Nano B01支持通过USB数据线直接连接电脑进行SSH：

1. 使用Micro-USB数据线连接Jetson Nano和电脑
2. 在Windows设备管理器中，确认显示"Remote NDIS Compatible Device"
3. 使用SSH客户端连接到`192.168.55.1`（默认IP地址）：
   ```bash
   ssh nvidia@192.168.55.1
   ```

### SSH连接问题排查

如果无法连接，请检查：

1. **网络连接**：确保Jetson Nano和电脑在同一网络
2. **SSH服务状态**：
   ```bash
   sudo systemctl status ssh
   # 如果没有运行，启动服务
   sudo systemctl start ssh
   sudo systemctl enable ssh
   ```
3. **防火墙设置**：
   ```bash
   sudo ufw status
   # 如果防火墙启用，允许SSH
   sudo ufw allow ssh
   ```
4. **SSH密钥问题**：如果使用密钥认证，检查权限：
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

## VNC远程桌面访问

VNC允许您通过网络访问Jetson Nano的完整桌面环境。

### 安装和配置VNC服务器

1. **安装VNC服务器**：
   ```bash
   sudo apt update
   sudo apt install vino
   ```

2. **配置VNC服务器**：
   ```bash
   # 修改VNC配置
   sudo nano /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
   ```

3. **在`</schema>`标签前添加以下内容**：
   ```xml
   <key name='enabled' type='b'>
     <summary>Enable remote access to the desktop</summary>
     <description>
       If true, allows remote access to the desktop via the RFB
       protocol. Users on remote machines may then connect to the
       desktop using a VNC viewer.
     </description>
     <default>false</default>
   </key>
   ```

4. **编译模式**：
   ```bash
   sudo glib-compile-schemas /usr/share/glib-2.0/schemas
   ```

5. **创建启动脚本**：
   ```bash
   nano ~/start-vnc.sh
   ```

6. **向脚本添加以下内容**：
   ```bash
   #!/bin/bash
   export DISPLAY=:0
   gsettings set org.gnome.Vino enabled true
   gsettings set org.gnome.Vino prompt-enabled false
   gsettings set org.gnome.Vino require-encryption false
   /usr/lib/vino/vino-server &
   ```

7. **添加执行权限**：
   ```bash
   chmod +x ~/start-vnc.sh
   ```

8. **运行VNC服务器**：
   ```bash
   ~/start-vnc.sh
   ```

9. **设置开机自启动VNC**（可选）：
   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/vino-server.desktop
   ```

   添加以下内容：
   ```
   [Desktop Entry]
   Type=Application
   Name=Vino VNC Server
   Exec=/home/nvidia/start-vnc.sh
   StartupNotify=false
   Terminal=false
   ```

### 连接到VNC服务器

1. **下载VNC客户端**：
   - Windows: [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) 或 [TightVNC](https://www.tightvnc.com/)
   - macOS: [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) 或内置的"屏幕共享"
   - Linux: [Remmina](https://remmina.org/) 或 [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

2. **连接到Jetson Nano**：
   - 输入Jetson Nano的IP地址加上端口号5900
   - 例如：`192.168.1.xxx:5900` 或简写为 `192.168.1.xxx::5900`

3. **调整分辨率**（可选）：
   如果需要调整屏幕分辨率，在Jetson Nano上运行：
   ```bash
   xrandr --fb 1280x720  # 可以根据需要调整分辨率
   ```

### VNC故障排除

1. **无法连接**：
   - 确认VNC服务器正在运行：`ps aux | grep vino`
   - 检查网络连接和防火墙设置：`sudo ufw allow 5900`

2. **黑屏问题**：
   - 确保Jetson Nano已登录到桌面环境
   - 尝试连接到正确的显示器：`export DISPLAY=:0`

3. **性能问题**：
   - 降低VNC分辨率
   - 减少颜色深度
   - 禁用桌面特效

## 串口连接（UART）

串口连接是一种更基础的连接方式，特别适用于系统初始化阶段或故障排除。

### 硬件连接

1. **准备USB转TTL串口线**（3.3V逻辑电平）

2. **连接到Jetson Nano的J44引脚**：
   - GND连接到Pin 6（GND）
   - TX连接到Pin 8（UART_TXD）
   - RX连接到Pin 10（UART_RXD）

### 软件设置

1. **Windows**：
   - 安装串口驱动（如果需要）
   - 打开设备管理器确认COM端口号
   - 使用PuTTY，选择Serial连接方式
   - 配置COM端口和波特率（115200）

2. **Linux/macOS**：
   ```bash
   # 查找串口设备
   ls /dev/tty*
   
   # 连接（使用screen或minicom）
   screen /dev/ttyUSB0 115200
   # 或
   minicom -D /dev/ttyUSB0 -b 115200
   ```

### 串口连接参数

- 波特率：115200
- 数据位：8
- 停止位：1
- 奇偶校验：无
- 流控制：无

## 文件传输方法

### 使用SCP传输文件

SCP是基于SSH的安全文件复制协议：

1. **从电脑传输到Jetson Nano**：
   ```bash
   # Linux/macOS
   scp /path/to/local/file nvidia@192.168.1.xxx:/path/to/remote/directory
   
   # Windows PowerShell
   scp C:\path\to\local\file nvidia@192.168.1.xxx:/path/to/remote/directory
   ```

2. **从Jetson Nano传输到电脑**：
   ```bash
   # Linux/macOS
   scp nvidia@192.168.1.xxx:/path/to/remote/file /path/to/local/directory
   
   # Windows PowerShell
   scp nvidia@192.168.1.xxx:/path/to/remote/file C:\path\to\local\directory
   ```

### 使用SFTP进行文件管理

SFTP提供更交互式的文件管理体验：

1. **命令行SFTP**：
   ```bash
   sftp nvidia@192.168.1.xxx
   # 连接后使用get/put命令传输文件
   ```

2. **图形化SFTP客户端**：
   - Windows: [WinSCP](https://winscp.net/)、[FileZilla](https://filezilla-project.org/)
   - macOS: [Cyberduck](https://cyberduck.io/)、[FileZilla](https://filezilla-project.org/)
   - Linux: [FileZilla](https://filezilla-project.org/)、文件管理器的SFTP功能

### 使用rsync进行同步

rsync适合大量文件或定期同步：

```bash
# 从本地同步到Jetson Nano
rsync -avz /path/to/local/directory/ nvidia@192.168.1.xxx:/path/to/remote/directory/

# 从Jetson Nano同步到本地
rsync -avz nvidia@192.168.1.xxx:/path/to/remote/directory/ /path/to/local/directory/
```

## 使用VS Code远程开发（推荐）

Visual Studio Code提供了强大的远程开发功能，非常适合Jetson Nano开发：

1. **在VS Code中安装Remote-SSH扩展**

2. **配置远程连接**：
   - 按F1打开命令面板
   - 输入并选择"Remote-SSH: Connect to Host..."
   - 输入`nvidia@192.168.1.xxx`
   - 输入密码（或使用SSH密钥自动认证）

3. **在远程环境中开发**：
   - 可以直接编辑Jetson Nano上的文件
   - 使用集成终端运行命令
   - 安装适用于远程环境的扩展

## 关闭图形界面以节省资源

如果只需要通过SSH访问Jetson Nano，可以关闭图形界面以节省内存和CPU资源：

1. **临时关闭图形界面**：
   ```bash
   sudo systemctl stop gdm
   ```

2. **永久关闭图形界面**：
   ```bash
   sudo systemctl set-default multi-user.target
   sudo reboot
   ```

3. **重新启用图形界面**：
   ```bash
   sudo systemctl set-default graphical.target
   sudo reboot
   ```

## 安全注意事项

远程访问涉及网络安全，请注意以下几点：

1. **更改默认密码**：
   ```bash
   passwd
   ```

2. **限制SSH访问**：
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   修改以下设置：
   ```
   PermitRootLogin no
   PasswordAuthentication no  # 如果使用密钥认证
   ```
   重启SSH服务：
   ```bash
   sudo systemctl restart ssh
   ```

3. **使用防火墙**：
   ```bash
   sudo apt install ufw
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow 5900  # 如果使用VNC
   sudo ufw enable
   ```

4. **定期更新系统**：
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

## 结语

远程访问功能让您可以更灵活地使用Jetson Nano B01开发板，无论是在办公室、家中还是在外出时，都能轻松管理和开发您的项目。

下一步可以[配置开发环境](development-environment.md)或了解[性能优化技巧](performance-optimization.md)。 