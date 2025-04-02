# Jetson Nano 初始配置与环境搭建

## 目录
- [📌 主要内容](#-主要内容)
- [🌐 网络配置](#-网络配置)
  - [WiFi连接设置](#wifi连接设置)
- [🔄 系统优化与软件源配置](#-系统优化与软件源配置)
  - [更换系统软件源](#更换系统软件源)
  - [配置pip镜像源](#配置pip镜像源)
  - [中文输入法安装](#中文输入法安装)
- [🧪 开发环境验证与性能测试](#-开发环境验证与性能测试)
  - [Python环境检查](#python环境检查)
  - [Jetson系统监控工具](#jetson系统监控工具)
  - [性能模式配置](#性能模式配置)
  - [GPU性能测试](#gpu性能测试)
- [🌡️ 散热方案配置](#️-散热方案配置)
  - [PWM风扇控制](#pwm风扇控制)
  - [风扇开机自启动设置](#风扇开机自启动设置)
- [🖥️ 图形界面管理](#️-图形界面管理)
- [📡 远程访问配置](#-远程访问配置)
  - [SSH远程连接](#ssh远程连接)
  - [VNC远程桌面设置](#vnc远程桌面设置)

<div align="center">
    <img src="https://developer.nvidia.com/sites/default/files/akamai/embedded/images/jetsonNano/JetsonNano-DevKit_Front-Top_Right_trimmed.jpg" alt="Jetson Nano B01" width="400"/>
</div>

## 📌 主要内容

- 网络配置与WiFi连接
- 系统优化与软件源配置
- 开发环境与性能测试
- 风扇控制与散热方案
- 远程访问设置（SSH与VNC）

---

## 🌐 网络配置

### WiFi连接设置

1. 连接硬件：插入兼容的WiFi网卡
2. 查看网络状态：
   ```bash
   # 查看IP地址
   ifconfig
   
   # 扫描可用WiFi网络
   nmcli dev wifi
   ```

3. 连接WiFi网络：
   ```bash
   # 连接到指定WiFi
   sudo nmcli dev wifi connect "WiFi名称" password "密码"
   ```

4. 网络调试工具：
   ```bash
   # 扫描局域网内设备
   nmap -sn 192.168.1.0/24
   ```

> 📝 **注意**：如果遇到DHCP无法分配IP的情况，可能需要检查路由器设置或配置静态IP。

---

## 🔄 系统优化与软件源配置

### 更换系统软件源

1. 备份原始软件源配置：
   ```bash
   # 备份系统软件源配置
   sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
   
   # 编辑软件源配置
   sudo gedit /etc/apt/sources.list
   ```

2. 更新软件包索引：
   ```bash
   sudo apt-get update
   ```

3. 安装Python开发包：
   ```bash
   # Python 3
   sudo apt-get install python3-pip python3-dev
   
   # Python 2（如需要）
   sudo apt-get install python-pip python-dev
   ```

### 配置pip镜像源

1. 创建pip配置目录：
   ```bash
   sudo mkdir ~/.pip
   cd ~/.pip
   ```

2. 创建并编辑配置文件：
   ```bash
   sudo touch pip.conf
   sudo gedit pip.conf
   ```

3. 添加国内镜像源配置（如清华、阿里等）

### 中文输入法安装

```bash
# 安装iBus拼音输入法
sudo apt-get install ibus ibus-clutter ibus-gtk ibus-gtk3 ibus-qt4 ibus-pinyin

# 配置输入法
im-config -s ibus
```

---

## 🧪 开发环境验证与性能测试

### Python环境检查

```bash
# 检查Python版本
python --version
python3 --version

# 验证OpenCV安装
python3
>>> import cv2
>>> cv2.__version__
>>> quit()
```

### Jetson系统监控工具

```bash
# 安装Jetson系统监控工具
sudo pip3 install jetson-stats

# 启动监控界面
sudo jtop
```

### 性能模式配置

```bash
# 查询当前性能模式
sudo nvpmodel -q

# 设置节能模式（5W）
sudo nvpmodel -m 1

# 设置最高性能模式（10W）
sudo nvpmodel -m 0

# 显示当前时钟频率
sudo jetson_clocks --show
```

### GPU性能测试

1. 查询GPU信息：
   ```bash
   # 编译并运行设备查询程序
   cd /usr/local/cuda-10.2/samples/1_Utilities/deviceQuery
   sudo make
   ./deviceQuery
   ```

2. N体模拟性能对比：
   ```bash
   # 编译N体模拟示例
   cd /usr/local/cuda-10.2/samples/5_Simulations/nbody
   sudo make
   
   # GPU运行模式
   ./nbody
   
   # CPU运行模式（对比）
   ./nbody -cpu
   ```

3. TensorRT推理测试：
   ```bash
   cd /usr/src/tensorrt/samples/
   sudo make
   ../bin/sample_mnist
   ```
   > ⚠️ **注意**：请确保`/usr/src/tensorrt/data/mnist`目录中有测试图片文件

---

## 🌡️ 散热方案配置

### PWM风扇控制

使用[jetson-fan-ctl](https://github.com/Pyrestone/jetson-fan-ctl)实现自动风扇控制：

```bash
# 克隆项目
git clone https://github.com/Pyrestone/jetson-fan-ctl.git
cd jetson-fan-ctl

# 添加执行权限
sudo chmod 777 ./install.sh

# 安装
./install.sh

# 检查风扇服务状态
sudo service automagic-fan status
```

自定义风扇控制参数：
```bash
sudo nano /etc/automagic-fan/config.json
```

### 风扇开机自启动设置

编辑开机自启动脚本：
```bash
sudo gedit /etc/rc.local
```

添加以下命令（设置风扇转速为100/255）：
```bash
#!/bin/bash
sudo sh -c 'echo 100 > /sys/devices/pwm-fan/target_pwm'
```

设置脚本执行权限：
```bash
sudo chmod 755 /etc/rc.local
```

---

## 🖥️ 图形界面管理

为节省内存（大约1.1GB），可以关闭图形界面：

```bash
# 关闭图形界面（重启生效）
sudo systemctl set-default multi-user.target 
sudo reboot

# 重新启用图形界面（重启生效）
sudo systemctl set-default graphical.target 
sudo reboot
```

---

## 📡 远程访问配置

### SSH远程连接

Jetson Nano默认已启用SSH服务，主要需配置静态IP和免密登录。

### VNC远程桌面设置

1. 修改VNC配置：
   ```bash
   sudo nano /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
   ```

2. 在文件末尾`</key>`之后，`</schema>`之前添加：
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

3. 编译配置：
   ```bash
   sudo glib-compile-schemas /usr/share/glib-2.0/schemas
   ```

4. 创建VNC启动脚本：
   ```bash
   nano ~/openvino
   ```

5. 添加以下内容：
   ```bash
   #!/bin/bash
   export DISPLAY=:0
   gsettings set org.gnome.Vino enabled true
   gsettings set org.gnome.Vino prompt-enabled false
   gsettings set org.gnome.Vino require-encryption false
   /usr/lib/vino/vino-server &
   ```

6. 设置执行权限：
   ```bash
   chmod +x ~/openvino
   ```

7. 调整屏幕分辨率（可选）：
   ```bash
   xrandr --fb 1920x1080
   ```

---

## 📚 Jetson Inference 安装与测试

Jetson Inference是NVIDIA官方提供的深度学习推理示例：

```bash
# 克隆仓库
git clone --recursive https://github.com/dusty-nv/jetson-inference
cd jetson-inference

# 配置构建环境
mkdir build
cd build
cmake ../

# 编译并安装
make -j$(nproc)
sudo make install
sudo ldconfig
```

安装过程中会提示下载预训练模型，可根据需要选择。

主要示例包括：
- 图像分类（ImageNet）
- 目标检测（DetectNet）
- 语义分割（SegNet）

---

## 📝 参考资料

- [Jetson Nano风扇配置教程](https://blog.csdn.net/djj199301111/article/details/107589906)
- [Jetson官方文档](https://developer.nvidia.com/embedded/jetson-nano-developer-kit)
- [Hello AI World教程](https://github.com/dusty-nv/jetson-inference) 