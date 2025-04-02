# Jetson Nano B01 性能优化指南

## 目录
- [Jetson Nano B01 性能优化指南](#jetson-nano-b01-性能优化指南)
  - [目录](#目录)
  - [电源模式配置](#电源模式配置)
    - [不同电源模式的特点](#不同电源模式的特点)
  - [CPU频率控制](#cpu频率控制)
  - [GPU频率控制](#gpu频率控制)
  - [散热优化](#散热优化)
    - [风扇控制](#风扇控制)
    - [自定义风扇控制脚本](#自定义风扇控制脚本)
    - [被动散热优化](#被动散热优化)
  - [内存管理优化](#内存管理优化)
    - [增加交换空间](#增加交换空间)
    - [释放缓存](#释放缓存)
    - [监控和限制内存使用](#监控和限制内存使用)
  - [存储优化](#存储优化)
    - [使用更快的SD卡或SSD](#使用更快的sd卡或ssd)
    - [文件系统优化](#文件系统优化)
    - [日志管理](#日志管理)
  - [应用优化技巧](#应用优化技巧)
    - [深度学习推理优化](#深度学习推理优化)
      - [使用TensorRT](#使用tensorrt)
      - [模型量化](#模型量化)
    - [并行化与多线程](#并行化与多线程)
    - [图像处理优化](#图像处理优化)
  - [系统服务优化](#系统服务优化)
    - [创建性能模式切换脚本](#创建性能模式切换脚本)
  - [监控系统性能](#监控系统性能)
    - [使用tegrastats解读系统性能](#使用tegrastats解读系统性能)
  - [总结与最佳实践](#总结与最佳实践)

本文档详细介绍Jetson Nano B01的性能优化技巧，包括系统设置调整、功耗管理、散热优化、内存管理以及应用性能提升方法。

## 电源模式配置

Jetson Nano B01有两种主要电源模式，可以根据不同场景进行切换：

```bash
# 查看当前电源模式
sudo nvpmodel -q

# 设置为高性能模式（10W）
sudo nvpmodel -m 0

# 设置为节能模式（5W）
sudo nvpmodel -m 1
```

### 不同电源模式的特点

| 模式 | 功率 | CPU核心 | GPU频率 | 适用场景 |
|------|------|---------|---------|----------|
| 0 (MAXN) | 10W | 全部4核 | 921MHz | 性能要求高的推理和训练 |
| 1 (5W) | 5W | 部分核心 | 640MHz | 电池供电或低功耗场景 |

## CPU频率控制

可以通过调整CPU频率来平衡性能和功耗：

```bash
# 查看当前CPU频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

# 查看可用的CPU频率调节策略
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# 设置为性能模式（最高频率）
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置为节能模式（动态调整频率）
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置为按需调节模式（根据负载调整）
echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## GPU频率控制

调整GPU频率可以显著影响性能和功耗：

```bash
# 查看当前GPU频率
sudo cat /sys/devices/17000000.gp10b/devfreq/17000000.gp10b/cur_freq

# 设置GPU频率为最大值
sudo jetson_clocks
```

## 散热优化

### 风扇控制
[参考文档](https://github.com/Pyrestone/jetson-fan-ctl)(推荐)

如果您的Jetson Nano B01连接了风扇，可以配置风扇控制以优化散热：

```bash
# 安装风扇控制工具
sudo pip3 install jetson-stats

# 设置风扇速度（0-255）
sudo sh -c 'echo 200 > /sys/devices/pwm-fan/target_pwm'

# 使用jtop工具实时调整风扇速度
sudo jtop
```

### 自定义风扇控制脚本

创建根据温度自动调节风扇速度的脚本：

```bash
cat << 'EOF' | sudo tee /usr/local/bin/fan_control.sh
#!/bin/bash

# 定义温度阈值和对应的风扇速度
TEMP_THRESHOLD_1=50
TEMP_THRESHOLD_2=60
TEMP_THRESHOLD_3=70
FAN_SPEED_1=100
FAN_SPEED_2=150
FAN_SPEED_3=200
FAN_SPEED_MAX=255

while true; do
    # 读取CPU温度
    CPU_TEMP=$(cat /sys/devices/virtual/thermal/thermal_zone1/temp)
    CPU_TEMP=$((CPU_TEMP/1000))
    
    # 根据温度设置风扇速度
    if [ $CPU_TEMP -lt $TEMP_THRESHOLD_1 ]; then
        echo 0 | sudo tee /sys/devices/pwm-fan/target_pwm > /dev/null
    elif [ $CPU_TEMP -lt $TEMP_THRESHOLD_2 ]; then
        echo $FAN_SPEED_1 | sudo tee /sys/devices/pwm-fan/target_pwm > /dev/null
    elif [ $CPU_TEMP -lt $TEMP_THRESHOLD_3 ]; then
        echo $FAN_SPEED_2 | sudo tee /sys/devices/pwm-fan/target_pwm > /dev/null
    else
        echo $FAN_SPEED_3 | sudo tee /sys/devices/pwm-fan/target_pwm > /dev/null
    fi
    
    # 每5秒检查一次
    sleep 5
done
EOF

sudo chmod +x /usr/local/bin/fan_control.sh

# 添加到systemd服务
cat << 'EOF' | sudo tee /etc/systemd/system/fan-control.service
[Unit]
Description=Jetson Nano Fan Control
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/fan_control.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable fan-control.service
sudo systemctl start fan-control.service
```

### 被动散热优化

如果使用被动散热方案：

1. 确保散热器紧贴SoC芯片，使用导热硅脂或导热胶提高传热效率
2. 将Jetson Nano B01放置在通风良好的环境中
3. 避免长时间运行高负载任务，或考虑添加主动散热方案

## 内存管理优化

Jetson Nano B01有4GB内存，合理管理内存可以显著提升性能：

### 增加交换空间

```bash
# 创建4GB的交换文件
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 持久化配置
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# 调整交换空间使用策略（0-100，越低越不倾向使用交换）
echo 10 | sudo tee /proc/sys/vm/swappiness
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

### 释放缓存

在运行内存密集型任务前释放缓存：

```bash
# 释放页面缓存
sudo sh -c "sync; echo 1 > /proc/sys/vm/drop_caches"

# 释放页面缓存和inode/dentry缓存
sudo sh -c "sync; echo 2 > /proc/sys/vm/drop_caches"

# 释放所有缓存
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
```

### 监控和限制内存使用

```bash
# 安装内存监控工具
sudo apt install -y htop

# 使用cgroup限制特定进程的内存使用
sudo apt install -y cgroup-tools

# 创建内存限制组
sudo cgcreate -g memory:limited_mem

# 设置内存限制（如1GB）
sudo cgset -r memory.limit_in_bytes=1G limited_mem

# 在限制组中运行程序
sudo cgexec -g memory:limited_mem python3 your_script.py
```

## 存储优化

### 使用更快的SD卡或SSD

将系统迁移到高速SD卡或外置SSD可以显著提升性能：

1. 使用UHS-I或UHS-II规格的高速SD卡
2. 使用USB 3.0外置SSD作为主存储

### 文件系统优化

```bash
# 关闭访问时间记录，减少写入次数
sudo mount -o remount,noatime /

# 在/etc/fstab中持久化配置
# 找到根分区的行，添加noatime选项
# 例如：UUID=xxx / ext4 defaults,noatime 0 1
```

### 日志管理

减少日志写入以延长SD卡寿命：

```bash
# 将日志存储在内存中
sudo mkdir -p /var/log.ram
sudo mount -t tmpfs -o size=100M tmpfs /var/log.ram
sudo rsync -a /var/log/ /var/log.ram/
sudo mount --bind /var/log.ram /var/log

# 限制日志大小
sudo nano /etc/systemd/journald.conf
# 设置 SystemMaxUse=50M
sudo systemctl restart systemd-journald
```

## 应用优化技巧

### 深度学习推理优化

#### 使用TensorRT

TensorRT可以显著提升推理性能：

```bash
# 安装TensorRT（通常在JetPack中已包含）
# 检查是否已安装
dpkg -l | grep tensorrt

# Python示例：将TensorFlow模型转换为TensorRT模型
import tensorflow as tf
from tensorflow.python.compiler.tensorrt import trt_convert as trt

# 转换模型
converter = trt.TrtGraphConverterV2(input_saved_model_dir='saved_model')
converter.convert()
converter.save('tensorrt_model')

# 加载优化后的模型
saved_model_loaded = tf.saved_model.load('tensorrt_model')
```

#### 模型量化

使用INT8或FP16量化可以显著提升性能：

```python
# PyTorch量化示例
import torch

# 转换为FP16
model = model.half()
input_tensor = input_tensor.half()

# TensorFlow量化示例
# 在模型构建时启用量化
converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_quant_model = converter.convert()
```

### 并行化与多线程

合理利用多核CPU和GPU：

```python
# Python多线程示例
import threading
import concurrent.futures

# 使用线程池
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(process_function, input_list))

# 使用多进程
with concurrent.futures.ProcessPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(process_function, input_list))
```

### 图像处理优化

使用GPU加速图像处理：

```python
# 使用cupy加速numpy运算
import cupy as cp

# 将numpy数组转换为cupy数组进行GPU加速
a_gpu = cp.array(a_cpu)
b_gpu = cp.array(b_cpu)
c_gpu = a_gpu + b_gpu
c_cpu = cp.asnumpy(c_gpu)

# 使用OpenCV的CUDA后端
import cv2
if cv2.cuda.getCudaEnabledDeviceCount() > 0:
    gpu_img = cv2.cuda_GpuMat()
    gpu_img.upload(cpu_img)
    
    # GPU加速的高斯模糊
    gpu_result = cv2.cuda.createGaussianFilter(
        cv2.CV_8UC3, cv2.CV_8UC3, (5, 5), 1.0)
        .apply(gpu_img)
    
    cpu_result = gpu_result.download()
```

## 系统服务优化

关闭不必要的服务以减少资源占用：

```bash
# 列出所有运行的服务
systemctl list-units --type=service --state=running

# 停止并禁用不需要的服务，例如：
sudo systemctl stop bluetoothd
sudo systemctl disable bluetoothd

# 常见可以禁用的服务：
# - bluetooth (如不使用蓝牙)
# - cups (如不需要打印)
# - avahi-daemon (如不需要零配置网络)
```

### 创建性能模式切换脚本

创建脚本方便在不同场景快速切换性能配置：

```bash
cat << 'EOF' | sudo tee /usr/local/bin/performance_mode.sh
#!/bin/bash

case "$1" in
    max)
        echo "Setting maximum performance mode"
        sudo nvpmodel -m 0
        sudo jetson_clocks
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        ;;
    balanced)
        echo "Setting balanced mode"
        sudo nvpmodel -m 0
        echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        ;;
    power_save)
        echo "Setting power saving mode"
        sudo nvpmodel -m 1
        echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        ;;
    *)
        echo "Usage: $0 {max|balanced|power_save}"
        exit 1
        ;;
esac
EOF

sudo chmod +x /usr/local/bin/performance_mode.sh

# 使用方法
# sudo /usr/local/bin/performance_mode.sh max
# sudo /usr/local/bin/performance_mode.sh balanced
# sudo /usr/local/bin/performance_mode.sh power_save
```

## 监控系统性能

使用工具实时监控系统性能，识别瓶颈：

```bash
# 安装监控工具
sudo apt install -y htop iotop

# Jetson专用监控工具
sudo pip3 install jetson-stats

# 使用jtop监控
sudo jtop

# 使用tegrastats监控
sudo tegrastats
```

### 使用tegrastats解读系统性能

tegrastats是Jetson平台的专有性能监控工具：

```bash
# 运行tegrastats，每1秒更新一次
sudo tegrastats --interval 1000

# 输出示例解读：
# RAM 1897/3964MB (lfb 227x4MB) SWAP 0/1982MB (cached 0MB)
# 表示：使用了1897MB内存，总共3964MB，有227个4MB大小的连续内存块可用
# 
# CPU [48%@1479,48%@1479,31%@1479,34%@1479]
# 表示：四个CPU核心分别使用了48%, 48%, 31%, 34%，频率都是1479MHz
# 
# EMC_FREQ 1%@1600
# 表示：内存控制器频率为1600MHz，使用率1%
# 
# GR3D_FREQ 29%@921
# 表示：GPU频率为921MHz，使用率29%
```

## 总结与最佳实践

根据不同场景的需求，Jetson Nano B01的性能优化可以从以下几个方面进行：

1. **高性能场景**（如实时推理）
   - 使用10W电源模式（nvpmodel -m 0）
   - 设置CPU为performance模式
   - 启用jetson_clocks锁定最高频率
   - 使用TensorRT优化模型
   - 确保良好的散热条件

2. **持续运行场景**（如24/7服务器）
   - 使用5W电源模式（nvpmodel -m 1）
   - 设置CPU为ondemand模式
   - 配置自动风扇控制
   - 关闭不必要的服务
   - 定期清理日志和临时文件

3. **电池供电场景**（如移动机器人）
   - 使用5W电源模式（nvpmodel -m 1）
   - 设置CPU为powersave模式
   - 减少后台进程
   - 优化应用程序减少处理量
   - 使用休眠模式在不活跃时节能

将这些优化策略结合使用，可以充分发挥Jetson Nano B01的性能潜力，同时平衡功耗和散热需求。 