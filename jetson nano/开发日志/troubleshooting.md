# Jetson Nano B01 故障排除指南

<div align="center">
    <img src="https://developer.nvidia.com/sites/default/files/akamai/embedded/images/jetsonNano/JetsonNano-DevKit_3-4-Front_trimmed.jpg" alt="Jetson Nano B01" width="350"/>
    <p><em>解决Jetson Nano开发过程中的常见问题</em></p>
</div>

## 📋 目录

- [系统启动问题](#系统启动问题)
- [网络连接问题](#网络连接问题)
- [性能与散热问题](#性能与散热问题)
- [软件安装与开发环境问题](#软件安装与开发环境问题)
- [外设连接问题](#外设连接问题)
- [远程访问问题](#远程访问问题)
- [AI与深度学习问题](#ai与深度学习问题)
- [电源管理问题](#电源管理问题)
- [系统恢复与重置](#系统恢复与重置)

---

## 系统启动问题

### 🔴 系统无法启动

**现象**：接通电源后，Jetson Nano B01没有任何反应，指示灯不亮或不正常闪烁。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查电源**
   - 确保使用符合要求的电源适配器：5V/4A DC电源或支持5V/2A的Micro-USB电源
   - 使用万用表测量电源输出电压是否在规格范围内
   - 尝试更换电源适配器或电源线

2. **检查SD卡**
   ```bash
   # 在另一台计算机上检查SD卡
   # 重新格式化SD卡（建议使用专业工具如SD Card Formatter）
   # 重新烧录系统镜像
   sudo dd if=jetson-nano-sd-card-image.img of=/dev/sdX bs=1M status=progress
   ```

3. **重置设备**
   - 断开所有电源和外围设备
   - 按住RECOVERY按钮（位于开发板边缘）
   - 接通电源，继续按住按钮5秒后释放

4. **检查跳线帽配置**
   - 检查J48跳线帽设置（当使用DC电源时需短接）
   - 确保选择了正确的启动模式

5. **硬件检查**
   - 检查开发板是否有明显物理损坏
   - 检查接口是否有异物或氧化
   - 尝试轻轻清洁SD卡插槽和电源接口
</details>

### 🟠 系统启动后卡在NVIDIA标志

**现象**：系统只显示NVIDIA标志，无法进入登录界面或命令行。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **强制重启**
   - 长按电源按钮或直接断开电源
   - 等待10秒后重新接通电源

2. **检查镜像完整性**
   ```bash
   # 验证下载的镜像校验和
   sha256sum jetson-nano-sd-card-image.img
   # 比对官方提供的校验和
   ```

3. **使用串口调试**
   ```bash
   # 连接串口调试器到J44引脚
   # 终端软件配置：115200-8-N-1
   # 查看启动日志定位问题
   ```

4. **尝试恢复模式**
   - 按住RECOVERY按钮启动
   - 使用NVIDIA SDK Manager尝试恢复系统

5. **检查SD卡文件系统**
   - 将SD卡连接到其他计算机
   - 检查文件系统完整性
   - 确保boot分区未损坏
</details>

### 🟠 系统随机重启

**现象**：Jetson Nano在使用过程中不定时重启，无明显触发条件。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **排查电源问题**
   - 确保使用足够功率的电源适配器（推荐5V/4A）
   - 避免使用低质量USB集线器供电
   - 检查电源线是否牢固连接

2. **监控温度**
   ```bash
   # 安装温度监控工具
   sudo pip3 install jetson-stats
   
   # 监控温度和性能
   sudo jtop
   ```
   - 如果温度超过85°C，改善散热条件
   - 安装或升级散热器和风扇

3. **检查系统日志**
   ```bash
   # 查看最近的系统日志
   sudo dmesg | tail -n 100
   
   # 或查看上次崩溃前的日志
   sudo journalctl -b -1
   ```

4. **检查硬件过载情况**
   - 监控CPU和GPU使用率
   - 降低系统负载或优化应用程序
   - 尝试降低功耗模式：`sudo nvpmodel -m 1`
</details>

---

## 网络连接问题

### 🔴 无线网络不可用

**现象**：无法连接Wi-Fi网络或Wi-Fi适配器不被识别。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查硬件兼容性**
   - 确保使用的是兼容的Wi-Fi适配器
   - 推荐Intel 8265/9260或兼容Jetson Nano的USB Wi-Fi适配器

2. **检查无线网卡识别状态**
   ```bash
   # 列出网络接口
   ifconfig -a
   
   # 查看无线网卡详细信息
   sudo lshw -C network
   
   # 检查已加载的无线驱动
   lsmod | grep 'rtw\|88\|wl'
   ```

3. **重新加载无线驱动**
   ```bash
   # 以RTL8822CE为例
   sudo modprobe -r rtw_8822ce
   sudo modprobe rtw_8822ce
   ```

4. **配置区域设置**
   ```bash
   # 设置无线区域代码（以中国为例）
   sudo iw reg set CN
   ```

5. **重启网络服务**
   ```bash
   sudo systemctl restart NetworkManager
   ```

6. **手动连接网络**
   ```bash
   # 扫描可用Wi-Fi网络
   sudo nmcli dev wifi list
   
   # 连接网络
   sudo nmcli dev wifi connect "网络名称" password "密码"
   ```

7. **安装缺失的固件**
   ```bash
   # 更新软件包索引
   sudo apt update
   
   # 安装额外的固件包
   sudo apt install linux-firmware
   ```
</details>

### 🟠 有线网络连接失败

**现象**：有线网络接口无法获取IP地址或无法访问互联网。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查物理连接**
   - 确认网线已正确连接，检查RJ45接口指示灯
   - 尝试更换网线或网络端口

2. **检查网络接口状态**
   ```bash
   # 查看网络接口状态
   ip link show eth0
   
   # 启用网络接口（如果状态为DOWN）
   sudo ip link set eth0 up
   ```

3. **手动配置IP地址**
   ```bash
   # 分配静态IP
   sudo ip addr add 192.168.1.100/24 dev eth0
   sudo ip route add default via 192.168.1.1
   
   # 配置DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

4. **配置永久静态IP（Netplan）**
   ```bash
   # 编辑配置文件
   sudo nano /etc/netplan/01-network-manager-all.yaml
   ```
   
   添加以下配置：
   ```yaml
   network:
     version: 2
     renderer: NetworkManager
     ethernets:
       eth0:
         dhcp4: no
         addresses: [192.168.1.100/24]
         gateway4: 192.168.1.1
         nameservers:
           addresses: [8.8.8.8, 8.8.4.4]
   ```
   
   ```bash
   # 应用配置
   sudo netplan apply
   ```

5. **检查DHCP客户端服务**
   ```bash
   # 重启DHCP客户端
   sudo dhclient -r eth0
   sudo dhclient eth0
   ```
</details>

### 🟠 SSH连接被拒绝

**现象**：无法通过SSH连接到Jetson Nano B01。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查SSH服务状态**
   ```bash
   # 确认SSH服务是否运行
   sudo systemctl status ssh
   
   # 如果未运行，启动服务
   sudo systemctl start ssh
   sudo systemctl enable ssh
   ```

2. **检查防火墙配置**
   ```bash
   # 确认SSH端口（通常是22）没有被防火墙阻止
   sudo ufw status
   
   # 如需要，允许SSH连接
   sudo ufw allow ssh
   ```

3. **验证网络连接**
   ```bash
   # 在Jetson上检查IP地址
   ifconfig
   
   # 从客户端测试连接
   ping <jetson-ip-address>
   ```

4. **检查SSH配置**
   ```bash
   # 检查SSH配置是否正确
   sudo nano /etc/ssh/sshd_config
   
   # 确保包含以下配置
   PermitRootLogin no
   PasswordAuthentication yes
   ```
   
   ```bash
   # 重启SSH服务应用更改
   sudo systemctl restart ssh
   ```

5. **检查客户端SSH密钥问题**
   - 如果使用SSH密钥认证，确保密钥正确配置
   - 检查`~/.ssh/authorized_keys`文件权限：`chmod 600 ~/.ssh/authorized_keys`
</details>

---

## 性能与散热问题

### 🟠 系统性能低下

**现象**：Jetson Nano运行缓慢，应用程序响应迟钝，推理或处理速度不达预期。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查当前功耗模式**
   ```bash
   # 查看当前功耗模式
   sudo nvpmodel -q
   
   # 切换到高性能模式（10W）
   sudo nvpmodel -m 0
   
   # 最大化时钟频率
   sudo jetson_clocks
   ```

2. **监控系统资源使用情况**
   ```bash
   # 安装监控工具
   sudo apt install htop
   sudo pip3 install jetson-stats
   
   # 监控CPU、GPU、内存使用
   htop
   sudo jtop
   ```

3. **检查温度问题**
   ```bash
   # 监控温度
   cat /sys/devices/virtual/thermal/thermal_zone*/temp
   ```
   - 如果温度持续高于80°C，可能导致性能降低（热节流）

4. **清理系统资源**
   ```bash
   # 清理不必要的后台进程
   ps aux | sort -nrk 3,3 | head -n 10
   
   # 清理缓存
   sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
   ```

5. **优化存储性能**
   - 使用高速SD卡（UHS-I或更高级别）
   - 考虑使用外接SSD提升存储性能：
     ```bash
     # 将应用移至SSD
     sudo mv /opt/application /path/to/ssd/application
     sudo ln -s /path/to/ssd/application /opt/application
     ```
</details>

### 🔴 过热与散热问题

**现象**：Jetson Nano温度过高，可能导致性能降低或随机重启。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **监控温度**
   ```bash
   # 实时监控温度
   sudo tegrastats
   sudo jtop
   ```

2. **改善硬件散热方案**
   - 安装适合的散热器和风扇
   - 确保设备周围有足够的散热空间
   - 避免在密闭环境中使用

3. **配置风扇控制**
   ```bash
   # 手动控制风扇转速（0-255）
   sudo sh -c 'echo 255 > /sys/devices/pwm-fan/target_pwm'
   ```

4. **设置自动风扇控制**
   ```bash
   # 安装自动控制脚本
   git clone https://github.com/Pyrestone/jetson-fan-ctl.git
   cd jetson-fan-ctl
   sudo ./install.sh
   
   # 检查服务状态
   sudo service automagic-fan status
   ```

5. **控制功耗和时钟频率**
   ```bash
   # 切换到低功耗模式（5W）
   sudo nvpmodel -m 1
   
   # 避免使用最大时钟频率
   # 如果已经运行jetson_clocks，可以恢复默认设置
   sudo jetson_clocks --restore
   ```

6. **如果使用自定义外壳**
   - 确保外壳有足够的通风孔
   - 考虑修改外壳以提供更好的散热条件
</details>

---

## 软件安装与开发环境问题

### 🟠 软件包安装失败

**现象**：通过apt或pip安装软件包时出现错误，无法完成安装。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **更新软件源**
   ```bash
   # 更新软件包索引
   sudo apt update
   
   # 修复可能的损坏依赖
   sudo apt --fix-broken install
   ```

2. **确保系统时间正确**
   ```bash
   # 检查当前系统时间
   date
   
   # 同步时间
   sudo apt install ntpdate
   sudo ntpdate time.windows.com
   ```

3. **清理APT缓存**
   ```bash
   sudo apt clean
   sudo apt autoclean
   ```

4. **检查存储空间**
   ```bash
   # 检查可用空间
   df -h
   
   # 清理旧内核和不需要的包
   sudo apt autoremove
   ```

5. **使用国内镜像源**
   ```bash
   # 备份原始软件源配置
   sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
   
   # 修改软件源
   sudo nano /etc/apt/sources.list
   ```
   - 替换为国内镜像源（如清华、阿里云等）
   
   ```bash
   # 更新索引
   sudo apt update
   ```

6. **针对pip安装问题**
   ```bash
   # 升级pip
   python3 -m pip install --upgrade pip
   
   # 使用国内镜像
   pip3 install 包名 -i https://pypi.tuna.tsinghua.edu.cn/simple
   ```
</details>

### 🟠 CUDA/cuDNN相关问题

**现象**：CUDA应用无法正常运行，出现CUDA错误或找不到相关库。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查CUDA安装**
   ```bash
   # 检查CUDA版本
   nvcc --version
   
   # 查看CUDA库路径
   ls -l /usr/local/cuda
   ```

2. **确认环境变量配置**
   ```bash
   # 检查CUDA相关环境变量
   echo $PATH | grep cuda
   echo $LD_LIBRARY_PATH | grep cuda
   
   # 如果未设置，添加以下内容到~/.bashrc
   echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
   echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **验证GPU状态**
   ```bash
   # 运行GPU测试示例
   cd /usr/local/cuda/samples/1_Utilities/deviceQuery
   sudo make
   ./deviceQuery
   ```

4. **针对特定深度学习框架**
   - TensorFlow相关：
     ```bash
     # 确认TensorFlow安装正确
     python3 -c "import tensorflow as tf; print(tf.test.is_gpu_available())"
     ```
   - PyTorch相关：
     ```bash
     # 检查PyTorch是否能识别CUDA
     python3 -c "import torch; print(torch.cuda.is_available())"
     ```

5. **特定于Jetson的CUDA问题**
   ```bash
   # 查看Jetson系统信息
   sudo apt install -y python3-pip
   sudo pip3 install -U jetson-stats
   sudo jtop
   ```
   - 注意Jetson平台使用特定版本的CUDA，与标准PC版本不同
</details>

---

## 外设连接问题

### 🟠 摄像头不工作

**现象**：系统无法识别或使用USB或CSI摄像头。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查USB摄像头识别**
   ```bash
   # 检查USB设备列表
   lsusb
   
   # 检查视频设备
   ls /dev/video*
   
   # 查看摄像头详细信息
   v4l2-ctl --list-devices
   ```

2. **测试USB摄像头功能**
   ```bash
   # 安装测试工具
   sudo apt install v4l-utils cheese
   
   # 使用Cheese测试
   cheese
   
   # 命令行测试
   v4l2-ctl --device=/dev/video0 --stream-mmap --stream-count=100
   ```

3. **CSI摄像头问题**
   - 确认CSI摄像头正确连接（引脚方向、接触良好）
   - 确认使用兼容的摄像头模块（如树莓派官方摄像头或IMX219）
   
   ```bash
   # 测试CSI摄像头
   gst-launch-1.0 nvarguscamerasrc ! 'video/x-raw(memory:NVMM),width=1920,height=1080,format=NV12,framerate=30/1' ! nvvidconv flip-method=0 ! 'video/x-raw,width=960,height=540' ! nvvidconv ! nvegltransform ! nveglglessink -e
   ```

4. **常见摄像头库问题**
   ```bash
   # 安装/更新OpenCV
   sudo apt install python3-opencv
   
   # 测试OpenCV摄像头访问
   python3 -c "import cv2; cap = cv2.VideoCapture(0); print(cap.isOpened())"
   ```

5. **检查权限问题**
   ```bash
   # 检查视频设备权限
   ls -la /dev/video*
   
   # 添加当前用户到video组
   sudo usermod -a -G video $USER
   # 需要重新登录生效
   ```
</details>

### 🟠 GPIO接口问题

**现象**：无法正确控制或读取GPIO引脚。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **安装GPIO库**
   ```bash
   # 安装Jetson GPIO Python库
   sudo pip3 install Jetson.GPIO
   ```

2. **检查用户权限**
   ```bash
   # 添加用户到gpio组
   sudo groupadd -f -r gpio
   sudo usermod -a -G gpio $USER
   ```

3. **创建udev规则**
   ```bash
   sudo nano /etc/udev/rules.d/99-gpio.rules
   ```
   
   添加以下内容：
   ```
   SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
   SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
   ```

4. **重启udev或系统**
   ```bash
   sudo udevadm control --reload-rules && sudo udevadm trigger
   # 或完全重启
   sudo reboot
   ```

5. **测试GPIO功能**
   ```python
   import Jetson.GPIO as GPIO
   import time

   # 设置模式
   GPIO.setmode(GPIO.BOARD)
   
   # 配置引脚为输出
   output_pin = 12
   GPIO.setup(output_pin, GPIO.OUT, initial=GPIO.LOW)
   
   try:
       # 闪烁LED
       for _ in range(10):
           GPIO.output(output_pin, GPIO.HIGH)
           time.sleep(1)
           GPIO.output(output_pin, GPIO.LOW)
           time.sleep(1)
   finally:
       # 清理资源
       GPIO.cleanup()
   ```
</details>

---

## 远程访问问题

### 🟠 VNC/远程桌面连接失败

**现象**：无法通过VNC或其他远程桌面工具访问Jetson Nano。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查VNC服务器安装**
   ```bash
   # 安装VNC服务器（如果未安装）
   sudo apt install vino
   # 或
   sudo apt install x11vnc
   ```

2. **配置Vino VNC服务器**
   ```bash
   # 配置VNC
   gsettings set org.gnome.Vino prompt-enabled false
   gsettings set org.gnome.Vino require-encryption false
   ```

3. **创建VNC启动脚本**
   ```bash
   # 创建启动脚本
   nano ~/start-vnc.sh
   ```
   
   添加以下内容：
   ```bash
   #!/bin/bash
   export DISPLAY=:0
   gsettings set org.gnome.Vino enabled true
   /usr/lib/vino/vino-server &
   ```
   
   ```bash
   # 设置执行权限
   chmod +x ~/start-vnc.sh
   
   # 运行脚本
   ~/start-vnc.sh
   ```

4. **配置x11vnc服务器**
   ```bash
   # 设置VNC密码
   x11vnc -storepasswd
   
   # 启动VNC服务器
   x11vnc -display :0 -auth guess -forever -loop -noxdamage -repeat -rfbauth $HOME/.vnc/passwd -rfbport 5900 -shared
   ```

5. **防火墙配置**
   ```bash
   # 确保VNC端口开放
   sudo ufw allow 5900
   ```

6. **创建自启动服务**
   ```bash
   # 创建systemd服务
   sudo nano /etc/systemd/system/x11vnc.service
   ```
   
   添加以下内容：
   ```
   [Unit]
   Description=Start x11vnc at startup.
   After=multi-user.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/x11vnc -display :0 -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/USERNAME/.vnc/passwd -rfbport 5900 -shared
   User=USERNAME

   [Install]
   WantedBy=multi-user.target
   ```
   
   将USERNAME替换为实际用户名
   
   ```bash
   # 启用服务
   sudo systemctl enable x11vnc.service
   sudo systemctl start x11vnc.service
   ```
</details>

---

## AI与深度学习问题

### 🟠 TensorRT模型转换失败

**现象**：无法将模型转换为TensorRT格式，或转换后的模型运行出错。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **检查TensorRT版本兼容性**
   ```bash
   # 查看TensorRT版本
   dpkg -l | grep nvinfer
   python3 -c "import tensorrt as trt; print(trt.__version__)"
   ```

2. **检查模型操作兼容性**
   - 确保模型只使用TensorRT支持的操作
   - 考虑简化模型或替换不支持的操作

3. **确保ONNX模型有效**
   ```bash
   # 安装onnx工具
   pip3 install onnx
   
   # 检查ONNX模型有效性
   python3 -c "import onnx; model = onnx.load('model.onnx'); onnx.checker.check_model(model)"
   ```

4. **分析模型转换日志**
   ```bash
   # 启用详细日志
   export TRT_LOG_VERBOSE=1
   
   # 运行转换代码
   python3 convert_model.py
   ```

5. **考虑降级模型复杂度**
   - 减少模型输入分辨率
   - 简化网络结构
   - 减少算子种类
</details>

### 🟠 深度学习推理速度慢

**现象**：在Jetson Nano上运行的深度学习模型比预期速度慢很多。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **优化模型推理方式**
   ```python
   # 使用TensorRT优化模型
   import tensorrt as trt
   # TensorRT优化代码
   ```

2. **检查是否使用GPU加速**
   ```python
   # PyTorch检查
   import torch
   print("CUDA可用:", torch.cuda.is_available())
   print("设备:", torch.cuda.get_device_name(0))
   
   # 确保模型和数据在GPU上
   model = model.cuda()
   input_data = input_data.cuda()
   ```

3. **减少输入数据复制**
   - 避免频繁的CPU和GPU之间数据传输
   - 尽可能多地在GPU上处理数据

4. **使用模型量化**
   - 将FP32模型量化为FP16或INT8
   ```python
   # TensorRT量化示例
   config = builder.create_builder_config()
   config.set_flag(trt.BuilderFlag.FP16)
   # 或INT8
   config.set_flag(trt.BuilderFlag.INT8)
   ```

5. **优化批处理大小**
   - 尝试不同的批处理大小找到最佳平衡点
   - Jetson Nano通常在较小批量下性能更佳

6. **减少模型复杂度**
   - 使用轻量级模型（如MobileNet系列）
   - 剪枝或蒸馏模型
</details>

---

## 电源管理问题

### 🔴 不稳定电源导致系统问题

**现象**：系统运行一段时间后自动关机，或在高负载时重启。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **确认电源规格**
   - 确保使用5V/4A DC电源
   - 避免使用USB电源（除非在低功耗场景）

2. **配置电源模式**
   ```bash
   # 检查当前电源模式
   sudo nvpmodel -q
   
   # 设置低功耗模式（如果电源不稳定）
   sudo nvpmodel -m 1
   ```

3. **监控供电情况**
   ```bash
   # 使用tegrastats监控
   sudo tegrastats
   ```
   - 观察电压是否正常（PWR字段）

4. **配置电源监控警告**
   - 创建监控脚本，在检测到电源不稳定时，自动降低系统负载

5. **改进供电设置**
   - 短接J48跳线，使用DC电源接口
   - 使用更短、质量更好的电源线减少电压降
   - 考虑添加外部稳压电源模块
</details>

---

## 系统恢复与重置

### 🔴 系统损坏需要重置

**现象**：系统严重损坏，无法正常启动或工作，需要重置系统。

<details>
<summary><strong>详细解决步骤</strong></summary>

1. **备份重要数据**
   ```bash
   # 如果系统还能进入，备份用户数据
   rsync -avz /home/username/ /path/to/backup/
   ```

2. **完全重新烧录系统**
   - 下载最新的Jetson Nano系统镜像
   - 使用SD卡烧录工具（如balenaEtcher）烧录镜像
   - 将烧录好的SD卡插入Jetson Nano

3. **使用恢复模式**
   - 按住RECOVERY按钮并开机
   - 使用NVIDIA SDK Manager尝试恢复系统

4. **在新系统上恢复配置**
   ```bash
   # 创建自动恢复脚本
   nano restore.sh
   ```
   
   ```bash
   #!/bin/bash
   # 安装必要软件
   sudo apt update
   sudo apt install -y package1 package2
   
   # 恢复配置文件
   cp /path/to/backup/config ~/.config/
   
   # 恢复用户数据
   cp -r /path/to/backup/data ~/data/
   
   echo "恢复完成"
   ```
   
   ```bash
   # 设置执行权限
   chmod +x restore.sh
   
   # 运行恢复脚本
   ./restore.sh
   ```

5. **创建系统备份**
   - 在系统恢复后，创建备份镜像以备将来使用
   ```bash
   sudo dd if=/dev/mmcblk0 of=/path/to/backup.img bs=1M status=progress
   ```
</details>

---

<div align="center">
    <p>📋 本文档不断更新中 | <a href="https://developer.nvidia.com/embedded/community/support-resources">NVIDIA Jetson支持资源</a></p>
    <p>最后更新: 2025年3月31日</p>
</div> 