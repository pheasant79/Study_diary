# Jetson Nano B01 故障排除指南

本文档提供Jetson Nano B01开发板使用过程中可能遇到的常见问题和详细解决方案。无论是系统启动问题、网络连接问题、性能问题还是开发环境配置问题，本指南都将提供实用的排障步骤和解决方法。

## 系统启动问题

### 系统无法启动

**现象**：接通电源后，Jetson Nano B01没有任何反应，指示灯不亮或不正常闪烁。

**解决方案**：

1. 检查电源
   ```bash
   # 使用万用表检查电源输出
   # 确保使用符合要求的电源适配器：5V/4A DC电源或支持5V/2A的Micro-USB电源
   ```

2. 检查SD卡
   ```bash
   # 使用另一台计算机检查SD卡是否正常工作
   # 重新烧录系统镜像
   sudo dd if=jetson-nano-sd-card-image.img of=/dev/sdX bs=1M status=progress
   ```

3. 重置设备
   ```bash
   # 断开所有电源和外围设备
   # 按住恢复模式按钮（RECOVERY按钮）
   # 接通电源，继续按住按钮5秒后释放
   ```

4. 检查跳线帽配置
   ```bash
   # 检查J48跳线帽设置是否正确（针对某些批次的Nano B01）
   # 确保J48已正确连接（对于SD卡启动模式）
   ```

### 系统启动后卡在NVIDIA标志

**现象**：系统只显示NVIDIA标志，无法进入系统。

**解决方案**：

1. 尝试强制关机后重启
   ```bash
   # 长按电源按钮或直接断开电源
   # 等待10秒后重新接通电源
   ```

2. 检查镜像完整性
   ```bash
   # 重新下载官方镜像并验证校验和
   sha256sum jetson-nano-sd-card-image.img
   # 比对下载页面提供的校验和
   ```

3. 使用串口调试
   ```bash
   # 连接串口调试器到J44引脚
   # 使用串口终端软件（如PuTTY），配置为115200-8-N-1
   # 查看启动日志以确定问题
   ```

### 系统随机重启

**现象**：Jetson Nano B01在使用过程中不定时重启。

**解决方案**：

1. 排查电源问题
   ```bash
   # 确保使用足够功率的电源适配器
   # 推荐使用原装5V/4A DC电源
   # 避免使用低质量USB集线器供电
   ```

2. 监控温度
   ```bash
   # 安装温度监控工具
   sudo pip3 install jetson-stats
   # 使用jtop监控温度
   sudo jtop
   # 如果温度过高，改善散热条件
   ```

3. 检查系统日志
   ```bash
   # 查看系统日志
   sudo dmesg
   # 或
   sudo journalctl -b -1
   # 寻找关键错误信息
   ```

## 网络连接问题

### 无线网络不可用

**现象**：无法连接Wi-Fi网络或Wi-Fi适配器不被识别。

**解决方案**：

1. 检查无线网卡是否被识别
   ```bash
   # 列出网络接口
   ifconfig -a
   # 或
   ip addr show
   
   # 检查无线网卡是否识别
   sudo lshw -C network
   ```

2. 重新加载Wi-Fi驱动
   ```bash
   # 对于使用RTL8822CE等常见网卡
   sudo modprobe -r rtw_8822ce
   sudo modprobe rtw_8822ce
   ```

3. 检查无线网络服务
   ```bash
   # 重启网络管理服务
   sudo systemctl restart NetworkManager
   
   # 检查网络管理服务状态
   sudo systemctl status NetworkManager
   ```

4. 配置地区设置（解决某些区域监管问题）
   ```bash
   # 设置正确的国家/地区代码
   sudo iw reg set CN  # 以中国为例
   ```

### 有线网络连接失败

**现象**：有线网络接口无法获取IP地址或无法访问互联网。

**解决方案**：

1. 检查物理连接
   ```bash
   # 确认网线已正确连接，检查指示灯状态
   
   # 检查网络接口
   ip link show eth0
   ```

2. 手动配置IP地址
   ```bash
   # 手动分配IP地址
   sudo ip addr add 192.168.1.100/24 dev eth0
   sudo ip route add default via 192.168.1.1
   
   # 配置DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

3. 检查网络服务
   ```bash
   # 重启网络服务
   sudo systemctl restart networking
   # 或
   sudo service networking restart
   ```

4. 永久配置网络（通过Netplan，适用于Ubuntu 18.04及更高版本）
   ```bash
   # 创建/编辑网络配置文件
   sudo nano /etc/netplan/01-network-manager-all.yaml
   
   # 添加配置：
   # network:
   #   version: 2
   #   renderer: NetworkManager
   #   ethernets:
   #     eth0:
   #       dhcp4: true
   
   # 应用配置
   sudo netplan apply
   ```

### SSH连接被拒绝

**现象**：无法通过SSH连接到Jetson Nano B01。

**解决方案**：

1. 检查SSH服务是否运行
   ```bash
   # 检查SSH服务状态
   sudo systemctl status ssh
   
   # 如果未运行，启动并启用SSH服务
   sudo systemctl start ssh
   sudo systemctl enable ssh
   ```

2. 确认SSH服务配置
   ```bash
   # 检查SSH配置
   sudo nano /etc/ssh/sshd_config
   
   # 确保包含以下行（取消注释）：
   # PasswordAuthentication yes
   # PermitRootLogin yes
   
   # 重启SSH服务
   sudo systemctl restart ssh
   ```

3. 检查防火墙设置
   ```bash
   # 检查是否有防火墙规则拦截SSH
   sudo iptables -L
   
   # 添加SSH允许规则（如有必要）
   sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
   ```

4. 确认网络连接
   ```bash
   # 在Jetson上查看IP地址
   ip addr show
   
   # 从客户端测试网络连接
   ping <jetson_ip_address>
   ```

## 性能问题

### 系统运行缓慢

**现象**：系统响应慢，应用程序启动和运行速度明显下降。

**解决方案**：

1. 检查CPU/GPU使用率和温度
   ```bash
   # 安装Jetson专用系统监控工具
   sudo pip3 install jetson-stats
   
   # 查看系统资源使用情况
   sudo jtop
   ```

2. 调整电源模式
   ```bash
   # 切换到高性能模式
   sudo nvpmodel -m 0
   sudo jetson_clocks
   ```

3. 释放内存
   ```bash
   # 清理缓存
   sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
   
   # 查看内存使用情况
   free -h
   ```

4. 检查并终止占用资源的进程
   ```bash
   # 查看占用资源最多的进程
   top
   # 或
   htop
   
   # 终止不需要的进程
   sudo kill <pid>
   ```

### 过热问题

**现象**：系统在运行高负载任务时温度过高，可能导致性能下降或自动关机。

**解决方案**：

1. 监控温度
   ```bash
   # 查看CPU温度
   cat /sys/devices/virtual/thermal/thermal_zone*/temp
   
   # 使用jtop监控温度
   sudo jtop
   ```

2. 改善散热
   ```bash
   # 安装风扇并配置风扇控制
   sudo sh -c 'echo 200 > /sys/devices/pwm-fan/target_pwm'
   
   # 或使用自动风扇控制脚本（参见性能优化文档）
   ```

3. 降低功耗
   ```bash
   # 切换到低功耗模式
   sudo nvpmodel -m 1
   
   # 设置CPU为powersave模式
   echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

4. 限制应用程序资源使用
   ```bash
   # 使用nice命令降低进程优先级
   nice -n 19 ./your_application
   
   # 使用cpulimit限制CPU使用率
   sudo apt install cpulimit
   cpulimit -e application_name -l 50  # 限制在50%
   ```

### SD卡性能下降

**现象**：文件读写速度下降，系统响应变慢。

**解决方案**：

1. 检查SD卡速度
   ```bash
   # 安装测试工具
   sudo apt install hdparm
   
   # 测试读取速度
   sudo hdparm -t /dev/mmcblk0
   
   # 测试写入速度
   dd if=/dev/zero of=test.file bs=1G count=1 oflag=direct
   ```

2. 减少日志写入
   ```bash
   # 将日志定向到内存（详见性能优化文档）
   
   # 调整日志级别
   sudo nano /etc/systemd/journald.conf
   # 设置 Storage=volatile
   # 设置 SystemMaxUse=50M
   
   # 重启日志服务
   sudo systemctl restart systemd-journald
   ```

3. 使用noatime挂载选项
   ```bash
   # 编辑fstab
   sudo nano /etc/fstab
   
   # 为根分区添加noatime选项
   # UUID=xxx / ext4 defaults,noatime 0 1
   
   # 重新挂载
   sudo mount -o remount /
   ```

4. 考虑迁移到USB SSD
   ```bash
   # 参考NVIDIA官方文档迁移系统到USB SSD
   # https://developer.nvidia.com/embedded/learn/jetson-nano-2gb-devkit-user-guide
   ```

## 软件和开发问题

### 安装包失败

**现象**：使用apt安装软件包时出错。

**解决方案**：

1. 更新软件源
   ```bash
   # 更新软件包列表
   sudo apt update
   
   # 尝试修复损坏的依赖关系
   sudo apt --fix-broken install
   ```

2. 检查软件包版本兼容性
   ```bash
   # 对于Jetson Nano，确保使用armhf或arm64架构的包
   dpkg --print-architecture
   
   # 查看软件包详细信息
   apt show package_name
   ```

3. 使用清华源或中科大源（国内用户）
   ```bash
   # 备份原配置
   sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
   
   # 编辑软件源
   sudo nano /etc/apt/sources.list
   
   # 替换为国内源，例如：
   # deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse
   # deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
   # deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse
   
   # 更新
   sudo apt update
   ```

### CUDA相关错误

**现象**：CUDA应用程序无法运行或报错。

**解决方案**：

1. 检查CUDA版本
   ```bash
   # 检查CUDA版本
   nvcc --version
   
   # 检查NVIDIA驱动版本
   cat /proc/driver/nvidia/version
   ```

2. 设置CUDA路径
   ```bash
   # 添加CUDA路径到环境变量
   echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
   echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

3. 验证CUDA功能
   ```bash
   # 运行CUDA样例
   cd /usr/local/cuda/samples/1_Utilities/deviceQuery
   sudo make
   ./deviceQuery
   ```

4. 重新安装JetPack
   ```bash
   # 对于系统级别的CUDA问题，考虑使用SDK Manager重新刷新系统
   # 参考NVIDIA官方JetPack文档
   ```

### Python库安装失败

**现象**：使用pip安装Python库时出错。

**解决方案**：

1. 更新pip和setuptools
   ```bash
   pip3 install --upgrade pip setuptools wheel
   ```

2. 使用--no-cache-dir选项
   ```bash
   # 避免内存不足问题
   pip3 install --no-cache-dir package_name
   ```

3. 为特定架构安装预编译包
   ```bash
   # 查找适合Jetson Nano ARM64架构的预编译包
   # 例如，对TensorFlow：
   pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v45 tensorflow==2.5.0+nv21.5
   ```

4. 增加交换空间（适用于大型包编译）
   ```bash
   # 创建交换文件
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # 永久启用交换
   echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
   ```

### 摄像头问题

**现象**：USB或CSI摄像头无法正常工作。

**解决方案**：

1. 检查USB摄像头
   ```bash
   # 检查设备连接
   lsusb
   
   # 检查视频设备
   ls /dev/video*
   
   # 检查摄像头信息
   v4l2-ctl --list-devices
   v4l2-ctl --device=/dev/video0 --list-formats-ext
   ```

2. 检查CSI摄像头
   ```bash
   # 安装v4l工具
   sudo apt install v4l-utils
   
   # 检查摄像头
   v4l2-ctl --list-devices
   
   # 测试CSI摄像头
   gst-launch-1.0 nvarguscamerasrc ! 'video/x-raw(memory:NVMM),width=1920,height=1080,format=NV12,framerate=30/1' ! nvvidconv ! nvegltransform ! nveglglessink -e
   ```

3. 解决权限问题
   ```bash
   # 添加当前用户到video组
   sudo usermod -a -G video $USER
   
   # 设置设备权限
   sudo chmod 666 /dev/video0
   ```

4. 重新加载内核模块
   ```bash
   # 对于CSI摄像头问题
   sudo systemctl restart nvargus-daemon
   ```

## 文件系统和存储问题

### SD卡文件系统损坏

**现象**：系统报告文件系统错误或挂载只读。

**解决方案**：

1. 在另一台计算机上检查SD卡
   ```bash
   # 在Linux系统上运行fsck
   sudo fsck.ext4 -f /dev/sdX1  # 替换sdX为实际设备
   ```

2. 备份和恢复
   ```bash
   # 备份SD卡数据
   sudo dd if=/dev/mmcblk0 of=sd_backup.img bs=1M status=progress
   
   # 恢复到新SD卡
   sudo dd if=sd_backup.img of=/dev/sdX bs=1M status=progress
   ```

3. 安全扩展分区
   ```bash
   # 使用GParted调整分区大小（在另一台计算机上）
   sudo apt install gparted
   sudo gparted
   ```

### 存储空间不足

**现象**：系统报告磁盘空间不足。

**解决方案**：

1. 清理不必要的文件
   ```bash
   # 清理软件包缓存
   sudo apt clean
   sudo apt autoremove
   
   # 查找大文件
   sudo find / -type f -size +100M -exec ls -lh {} \;
   
   # 清理日志
   sudo journalctl --vacuum-time=3d
   ```

2. 分析磁盘使用情况
   ```bash
   # 安装磁盘使用分析工具
   sudo apt install ncdu
   
   # 分析根目录
   sudo ncdu /
   ```

3. 使用外部存储
   ```bash
   # 挂载USB存储设备
   sudo mkdir -p /mnt/external
   sudo mount /dev/sdX1 /mnt/external
   
   # 设置自动挂载
   echo 'UUID=xxxx /mnt/external ext4 defaults 0 2' | sudo tee -a /etc/fstab
   ```

4. 移动大目录到外部存储
   ```bash
   # 例如移动home目录
   sudo rsync -aXS /home/ /mnt/external/home/
   
   # 添加挂载点
   echo '/mnt/external/home /home none bind 0 0' | sudo tee -a /etc/fstab
   ```

## 外设和接口问题

### GPIO控制失败

**现象**：无法正确控制GPIO引脚或读取状态。

**解决方案**：

1. 检查GPIO权限
   ```bash
   # 添加用户到gpio组
   sudo groupadd -f -r gpio
   sudo usermod -a -G gpio $USER
   
   # 创建udev规则
   echo 'SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c '"'"'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"'"'"' | sudo tee /etc/udev/rules.d/99-gpio.rules
   
   # 重启udev
   sudo udevadm control --reload-rules && sudo udevadm trigger
   ```

2. 使用正确的GPIO库
   ```bash
   # 安装Jetson.GPIO库
   sudo pip3 install Jetson.GPIO
   
   # 测试GPIO
   # 创建test_gpio.py:
   # import Jetson.GPIO as GPIO
   # import time
   # GPIO.setmode(GPIO.BOARD)
   # GPIO.setup(7, GPIO.OUT)
   # while True:
   #     GPIO.output(7, GPIO.HIGH)
   #     time.sleep(1)
   #     GPIO.output(7, GPIO.LOW)
   #     time.sleep(1)
   
   # 运行测试
   sudo python3 test_gpio.py
   ```

3. 检查引脚编号和模式
   ```bash
   # 确认使用正确的引脚编号方式
   # Jetson.GPIO支持GPIO.BOARD和GPIO.BCM两种模式
   ```

### I2C设备不被识别

**现象**：通过I2C总线连接的设备无法被系统识别或读取。

**解决方案**：

1. 检查I2C工具是否安装
   ```bash
   # 安装I2C工具
   sudo apt install i2c-tools
   
   # 检查I2C设备
   sudo i2cdetect -y -r 1  # 1是总线号，可能需要调整
   ```

2. 确认I2C接线
   ```bash
   # 检查接线
   # SDA连接到SDA引脚
   # SCL连接到SCL引脚
   # 确保连接了上拉电阻（如果设备需要）
   ```

3. 加载I2C内核模块
   ```bash
   # 加载I2C模块
   sudo modprobe i2c-dev
   
   # 设置自动加载
   echo 'i2c-dev' | sudo tee -a /etc/modules
   ```

4. 检查用户权限
   ```bash
   # 添加用户到i2c组
   sudo groupadd -f -r i2c
   sudo usermod -a -G i2c $USER
   
   # 设置设备权限
   echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c"' | sudo tee /etc/udev/rules.d/99-i2c.rules
   
   # 重启udev
   sudo udevadm control --reload-rules && sudo udevadm trigger
   ```

### USB设备不被识别

**现象**：USB设备连接后系统无法识别。

**解决方案**：

1. 检查USB设备连接
   ```bash
   # 列出USB设备
   lsusb
   
   # 查看系统日志
   dmesg | grep usb
   ```

2. 检查USB供电
   ```bash
   # 对于高功耗设备，确保有足够的电源
   # 考虑使用带电源的USB集线器
   ```

3. 检查USB驱动
   ```bash
   # 查找相关驱动模块
   lsmod | grep usb
   
   # 加载特定驱动模块
   sudo modprobe module_name
   ```

4. 重置USB总线
   ```bash
   # 重置USB控制器
   echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind
   sleep 2
   echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/bind
   ```

## 系统恢复和备份

### 系统备份

创建完整的系统备份，以便在出现严重问题时恢复：

```bash
# 备份整个SD卡到映像文件
sudo dd if=/dev/mmcblk0 of=~/jetson_backup.img bs=1M status=progress

# 压缩备份文件以节省空间
sudo apt install pv
sudo dd if=/dev/mmcblk0 bs=1M | pv | gzip > ~/jetson_backup.img.gz

# 备份关键配置文件
sudo tar -czvf ~/config_backup.tar.gz /etc /home /root /usr/local

# 备份到外部USB存储
sudo dd if=/dev/mmcblk0 of=/media/ubuntu/usb_drive/jetson_backup.img bs=1M status=progress
```

### 系统恢复

当系统出现严重问题需要恢复时：

```bash
# 在另一台计算机上将备份映像恢复到SD卡
sudo dd if=jetson_backup.img of=/dev/sdX bs=1M status=progress

# 从压缩备份恢复
gunzip -c jetson_backup.img.gz | sudo dd of=/dev/sdX bs=1M status=progress

# 重新烧录官方系统镜像（最后的解决方案）
# 从NVIDIA开发者网站下载最新的Jetson Nano系统镜像
# 使用Etcher或dd命令烧录到SD卡
```

## 联系支持

如果以上故障排除方法无法解决您遇到的问题，可以通过以下渠道获取更多支持：

1. NVIDIA开发者论坛：https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/67
2. Jetson项目GitHub：https://github.com/NVIDIA-AI-IOT/
3. NVIDIA开发者支持：https://developer.nvidia.com/embedded/support

## 常见错误代码解析

| 错误代码/消息 | 可能原因 | 解决方法 |
|--------------|---------|---------|
| "No space left on device" | 存储空间不足 | 清理不必要文件或扩展存储 |
| "Could not get lock /var/lib/dpkg/lock" | apt进程已在运行或之前被中断 | 删除锁文件或等待其他进程完成 |
| "Failed to start nvargus-daemon.service" | CSI摄像头服务故障 | 重启服务或检查硬件连接 |
| "CUDA driver version is insufficient" | CUDA驱动版本不匹配 | 更新驱动或使用兼容版本的CUDA库 |
| "Temperature too high" | 设备过热 | 改善散热或降低性能模式 |

## 诊断检查表

遇到问题时，可以按照以下检查表进行系统诊断：

1. 电源供应正常？（检查指示灯）
2. 网络连接正常？（ping测试）
3. 存储空间充足？（df -h）
4. 系统温度正常？（jtop）
5. 最近是否有软件更新？（检查apt日志）
6. 硬件连接牢固？（检查接口）
7. 系统日志是否有错误？（dmesg）

通过系统性地检查这些项目，可以快速定位大多数问题的根源。 