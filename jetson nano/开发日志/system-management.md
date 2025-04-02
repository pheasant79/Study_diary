# Jetson Nano 系统管理与SSH配置

## 目录
- [📌 主要内容](#-主要内容)
- [🔒 Git与Jetson的SSH配置冲突解决](#-git与jetson的ssh配置冲突解决)
  - [解决方案：配置多SSH密钥](#解决方案配置多ssh密钥)
- [💾 系统镜像烧录与初始设置](#-系统镜像烧录与初始设置)
  - [下载与烧录系统](#下载与烧录系统)
- [⌨️ 键盘映射问题修复](#️-键盘映射问题修复)
  - [修复方法](#修复方法)
- [🖥️ 软件管理与系统技巧](#️-软件管理与系统技巧)
  - [查看已安装软件的方法](#查看已安装软件的方法)
  - [实用Linux命令速查表](#实用linux命令速查表)
- [🌡️ 风扇控制与散热管理](#️-风扇控制与散热管理)
  - [手动风扇控制](#手动风扇控制)
  - [自动风扇控制](#自动风扇控制)
  - [电源模式设置](#电源模式设置)
- [📡 远程桌面配置](#-远程桌面配置)
- [🔄 系统自启动配置](#-系统自启动配置)
  - [方法一：非特权命令自启动](#方法一非特权命令自启动)
  - [方法二：通过脚本实现自启动](#方法二通过脚本实现自启动)
  - [方法三：需要sudo权限的命令自启动](#方法三需要sudo权限的命令自启动)

<div align="center">
    <img src="https://developer.nvidia.com/sites/default/files/akamai/embedded/images/jetsonNano/JetsonNano-DevKit_Front-Top_Right_trimmed.jpg" alt="Jetson Nano B01" width="400"/>
</div>

## 📌 主要内容

- 解决Git SSH与Jetson SSH冲突问题
- 系统镜像烧录与初始设置
- 修复键盘按键映射错误
- Linux系统软件管理与命令行技巧
- 风扇控制和温度管理

---

## 🔒 Git与Jetson的SSH配置冲突解决

在使用多个需要SSH密钥的服务时，我遇到了冲突问题：Jetson的SSH连接覆盖了我的GitHub SSH配置（它们默认都存储在`C:\Users\用户名\.ssh`目录）。这导致我无法向GitHub提交代码。

### 解决方案：配置多SSH密钥

1. 为Git创建独立的SSH密钥：
   ```bash
   # 在.ssh文件夹下创建git子文件夹
   mkdir -p C:\Users\用户名\.ssh\git

   # 生成新的SSH密钥对
   ssh-keygen -t rsa -C "你的邮箱地址"
   
   # 提示保存位置时输入：C:\Users\用户名\.ssh\git\id_rsa
   # 密码可以留空，直接回车
   ```

2. 创建SSH配置文件：
   创建`C:\Users\用户名\.ssh\config`文件（无扩展名），内容如下：
   ```
   Host github.com
     HostName github.com
     User git
     IdentityFile C:\Users\用户名\.ssh\git\id_rsa
     IdentitiesOnly yes
   ```

3. 测试连接：
   ```bash
   ssh -T -v git@github.com
   ```

> 💡 **提示**：每增加一个需要SSH的服务，都可以按照这个模式添加新的配置项到config文件中。

---

## 💾 系统镜像烧录与初始设置

### 下载与烧录系统

今天完成了Jetson Nano社区版系统的下载和烧录：

1. **下载选择**：有三种文件可选 - 完整版整文件、完整版分卷文件、精简版文件。我选择了完整版整文件（.xz格式）。

2. **SD卡准备**：
   - 使用分区助手格式化SD卡为FAT32格式
   - 确保分配了所有可用空间

3. **镜像处理**：
   - 解压.xz文件得到.img_2格式文件
   - 将文件扩展名改为.img

4. **烧录过程**：
   - 使用Jetson专用烧录软件将镜像写入SD卡

5. **默认登录信息**：
   - 用户名：`jetson`
   - 密码：`jetson`

---

## ⌨️ 键盘映射问题修复

系统启动后发现键盘方向键变成了ABCD字母，这是Vi/Vim配置问题导致的。

### 修复方法

1. 编辑Vim配置文件：
   ```bash
   sudo vi /etc/vim/vimrc.tiny
   ```

2. 修改配置：
   - 将`set compatible`改为`set nocompatible`
   - 添加一行`set backspace=2`
   - 最终配置应类似：
     ```
     set nocompatible
     set backspace=2
     ```

3. 如果仍有问题：
   - 可以暂时通过SSH从另一台电脑远程操作
   - 或逐个测试键盘按键，找出错误的映射

---

## 🖥️ 软件管理与系统技巧

### 查看已安装软件的方法

#### 命令行方式：

```bash
# 列出所有通过APT安装的软件包
apt list --installed

# 使用dpkg列出所有已安装的Debian包
dpkg -l

# 查看Python包
pip3 list

# 按名称搜索特定软件
dpkg -l | grep python3
```

#### 图形界面方式（可选）：

```bash
# 安装Synaptic包管理器
sudo apt install synaptic

# 启动Synaptic
sudo synaptic
```

### 实用Linux命令速查表

| 类别 | 命令/快捷键 | 说明 |
|------|------------|------|
| **基础操作** | `Ctrl + L` 或 `clear` | 清空终端 |
|  | `Ctrl + R` → 关键词 | 搜索历史命令 |
|  | `Ctrl + C` | 终止前台进程 |
| **文件管理** | `find /path -name "*.txt"` | 递归查找文件 |
|  | `du -sh <目录>` | 查看目录总大小 |
|  | `rename 's/old/new/' *.txt` | 批量重命名文件 |
| **系统监控** | `htop` 或 `top` | 进程监控 |
|  | `df -h` | 查看磁盘空间 |
|  | `tegrastats` | Jetson硬件状态监控 |
| **开发工具** | `git` + SSH密钥 | 代码版本控制 |
|  | `ssh -X user@jetson` | 启用X11转发的SSH |

> 完整的命令行技巧参考：[Linux命令行艺术](https://github.com/jlevy/the-art-of-command-line/blob/master/README-zh.md)

---

## 🌡️ 风扇控制与散热管理

### 手动风扇控制

控制Jetson Nano风扇的PWM值（0-255）：
```bash
sudo sh -c 'echo 255 > /sys/devices/pwm-fan/target_pwm'
```

### 自动风扇控制

推荐使用`jetson-fan-ctl`项目实现自动温控风扇调速：
https://github.com/Pyrestone/jetson-fan-ctl

#### 硬件连接

1. 建议使用5V PWM风扇（如Noctua NF-A4x20 5V PWM）
2. 将风扇连接到Jetson Nano的4针风扇接口（位于40-pin GPIO接口附近）

#### 温度管理建议

- 日常使用时保持风扇自动控制
- 高负载计算前主动提高风扇转速
- 监控`tegrastats`输出的温度信息
- 确保散热器正确安装并与SoC良好接触

### 电源模式设置

配置Jetson Nano的功耗模式：
```bash
# 高性能模式（10W）
sudo nvpmodel -m 0

# 节能模式（5W）
sudo nvpmodel -m 1
```

> ⚠️ **注意**：高性能模式下请确保散热良好，并使用DC供电而非USB供电。

---

## 📡 远程桌面配置

安装VNC服务器以实现远程桌面访问：
```bash
sudo apt-get install vino-server
```

> 详细配置步骤请参考[远程访问配置](remote-access.md)文档。

---

## 🔄 系统自启动配置

### 方法一：非特权命令自启动

1. 通过GNOME会话属性配置：
   ```bash
   gnome-session-properties
   ```
   点击"添加"按钮，设置名称和命令，例如VNC服务器启动：
   ```
   /usr/lib/vino/vino-server
   ```

### 方法二：通过脚本实现自启动

1. 创建启动脚本：
   ```bash
   touch startvino
   sudo vim startvino
   ```

2. 添加脚本内容：
   ```bash
   #!/bin/bash
   /usr/lib/vino/vino-server
   ```

3. 设置权限并移动到系统目录：
   ```bash
   sudo chmod 777 startvino
   # 移动到初始化目录
   sudo mv startvino /etc/init.d/
   ```

4. 配置为系统服务：
   ```bash
   sudo update-rc.d startvino defaults 90
   ```

### 方法三：需要sudo权限的命令自启动

1. 配置rc-local服务：
   检查并编辑`/lib/systemd/system/rc-local.service`文件，确保包含：
   ```
   [Install]
   WantedBy=multi-user.target
   Alias=rc-local.service
   ```

2. 创建/编辑rc.local文件：
   ```bash
   sudo nano /etc/rc.local
   ```
   
   添加启动命令，例如：
   ```bash
   #!/bin/bash
   echo "Startup script running" > /usr/local/temp/startup.log
   ```

3. 启用rc-local服务：
   ```bash
   sudo chmod +x /etc/rc.local
   sudo systemctl enable rc-local
   sudo systemctl start rc-local.service
   ```

---

## 📝 参考资料

- [SSH配置](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh)
- [Vim键盘修复](http://www.cnblogs.com/wjvzbr)
- [风扇控制](https://zhuanlan.zhihu.com/p/141936448)
- [Jetson自动风扇控制](https://github.com/Pyrestone/jetson-fan-ctl)
- [Ubuntu自启动配置](https://blog.csdn.net/t624124600/article/details/111085234) 