# Jetson Nano B01 网络配置指南

## 目录
- [硬件准备](#硬件准备)
  - [无线网卡选择](#无线网卡选择)
- [有线网络配置](#有线网络配置)
  - [通过GUI配置（有显示器）](#通过gui配置有显示器)
  - [通过命令行配置（无显示器）](#通过命令行配置无显示器)
- [无线网络配置](#无线网络配置)
  - [安装无线网卡](#安装无线网卡)
  - [通过GUI配置WiFi（有显示器）](#通过gui配置wifi有显示器)
  - [通过命令行配置WiFi（无显示器）](#通过命令行配置wifi无显示器)
  - [使用配置文件连接WiFi](#使用配置文件连接wifi)
- [配置静态IP地址](#配置静态ip地址)
  - [有线网络静态IP](#有线网络静态ip)
  - [无线网络静态IP](#无线网络静态ip)
- [网络共享设置（通过USB）](#网络共享设置通过usb)
  - [Jetson Nano端配置](#jetson-nano端配置)
  - [Windows主机配置](#windows主机配置)
  - [设置静态IP解决连接不稳定问题](#设置静态ip解决连接不稳定问题)
  - [Linux主机配置](#linux主机配置)
- [网络测试和问题排查](#网络测试和问题排查)

网络配置是Jetson Nano B01使用过程中的重要环节，本文档详细介绍有线网络和无线网络的配置方法，以及常见网络问题的解决方案。

## 硬件准备

Jetson Nano B01 支持以下网络连接方式：

1. **有线网络**：通过板载的RJ45以太网接口直接连接
2. **无线网络**：有两种实现方式
   - 通过M.2插槽安装无线网卡（推荐）
   - 通过USB接口连接外置无线网卡

### 无线网卡选择

如果使用M.2插槽安装无线网卡，推荐以下型号：

- Intel AC8265/9260 无线网卡
- Intel AX200/AX201 无线网卡（支持WiFi 6）
- 任何兼容的M.2 Key E接口的无线网卡

## 有线网络配置

### 通过GUI配置（有显示器）

1. 将网线连接到Jetson Nano的RJ45端口
2. 右上角网络图标 → 有线连接
3. 如需静态IP，点击"有线设置" → 选择连接 → "IPv4"选项卡:
   - 选择"手动"
   - 添加地址，填写IP地址、子网掩码和网关
   - 添加DNS服务器（如8.8.8.8和8.8.4.4）
4. 点击"应用"保存设置

### 通过命令行配置（无显示器）

1. 检查网络接口名称：

```bash
ip addr
```

通常有线网络接口名为`eth0`。

2. 编辑网络配置文件：

```bash
sudo nano /etc/netplan/01-network-manager-all.yaml
```

3. 添加或修改有线网络配置：

```yaml
# 使用DHCP自动获取IP地址
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      dhcp4: true

# 或使用静态IP地址
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

4. 应用网络配置：

```bash
sudo netplan apply
```

## 无线网络配置

### 安装无线网卡

如果使用M.2无线网卡：

1. 断开Jetson Nano电源
2. 将无线网卡插入M.2插槽（位于开发板的一侧）
3. 连接天线到网卡的天线接口
4. 重新连接电源启动系统

### 通过GUI配置WiFi（有显示器）

1. 右上角网络图标 → WiFi列表 → 选择要连接的WiFi
2. 输入密码，点击"连接"

### 通过命令行配置WiFi（无显示器）

1. 扫描可用WiFi网络：

```bash
nmcli dev wifi
```

2. 连接到WiFi网络：

```bash
sudo nmcli dev wifi connect "WIFI_NAME" password "PASSWORD"
```

替换`WIFI_NAME`和`PASSWORD`为实际的WiFi名称和密码。

3. 检查连接状态：

```bash
nmcli connection show
```

### 使用配置文件连接WiFi

也可以通过创建配置文件来连接WiFi：

1. 创建一个新的连接文件：

```bash
sudo nano /etc/NetworkManager/system-connections/my-wifi.nmconnection
```

2. 添加以下内容：

```
[connection]
id=my-wifi
type=wifi
interface-name=wlan0

[wifi]
mode=infrastructure
ssid=WIFI_NAME

[wifi-security]
key-mgmt=wpa-psk
psk=PASSWORD

[ipv4]
method=auto

[ipv6]
method=auto
```

3. 修改文件权限：

```bash
sudo chmod 600 /etc/NetworkManager/system-connections/my-wifi.nmconnection
```

4. 重启网络服务：

```bash
sudo systemctl restart NetworkManager
```

## 配置静态IP地址

### 有线网络静态IP

编辑配置文件：

```bash
sudo nano /etc/netplan/01-network-manager-all.yaml
```

添加如下配置：

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

应用配置：

```bash
sudo netplan apply
```

### 无线网络静态IP

使用NetworkManager命令行工具：

```bash
sudo nmcli connection modify "WIFI_NAME" ipv4.method manual ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli connection up "WIFI_NAME"
```

## 网络共享设置（通过USB）

Jetson Nano支持通过USB数据线与电脑连接并共享网络：

### Jetson Nano端配置

默认情况下，系统已配置为通过USB支持网络共享，无需额外设置。

### Windows主机配置

1. 通过USB线连接Jetson Nano和Windows电脑
2. 在Windows设备管理器中，确认出现"Remote NDIS Compatible Device"
3. 控制面板 → 网络和Internet → 网络连接
4. 右键点击已连接互联网的网络（如WiFi）
5. 选择"属性" → "共享"选项卡
6. 勾选"允许其他网络用户通过此计算机的Internet连接来连接"
7. 在下拉菜单中选择"Remote NDIS Compatible Device"
8. 点击"确定"保存设置

### 设置静态IP解决连接不稳定问题

如果USB连接经常断开，设置静态IP可能有帮助：

1. 控制面板 → 网络连接
2. 右键点击"Remote NDIS Compatible Device"
3. 选择"属性" → 双击"Internet协议版本4(TCP/IPv4)"
4. 选择"使用下面的IP地址"并填写：
   - IP地址：192.168.55.100
   - 子网掩码：255.255.255.0
   - 默认网关：192.168.55.1
5. 点击"确定"保存设置
[参考教程](https://www.patzer0.com/archives/jetson-frequently-lost-connection-to-windows-computers-via-usb-rndis)

### Linux主机配置

如果使用Linux电脑连接Jetson Nano：

```bash
# 假设usb0是计算机端的USB网络接口
sudo ip addr add 192.168.55.100/24 dev usb0
sudo ip link set usb0 up
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i usb0 -o wlan0 -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o usb0 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

## 网络测试和问题排查

### 基本连接测试

```bash
# 测试本地连接
ping 127.0.0.1

# 测试网关连接
ping 192.168.1.1  # 替换为实际网关地址

# 测试互联网连接
ping 8.8.8.8
ping www.baidu.com
```

### 常见问题诊断

#### 无法连接到无线网络

1. 检查网卡是否被识别：

```bash
lspci | grep Network
lsusb | grep Wireless
```

2. 检查驱动是否加载：

```bash
dmesg | grep wifi
```

3. 检查无线网络接口是否启用：

```bash
rfkill list all
# 如果被阻止，解除阻止
sudo rfkill unblock all
```

#### DHCP无法获取IP地址

1. 重启网络服务：

```bash
sudo systemctl restart NetworkManager
```

2. 尝试手动获取IP地址：

```bash
sudo dhclient wlan0  # 或 eth0，取决于使用的接口
```

#### 网络速度慢或不稳定

1. 检查信号强度（无线网络）：

```bash
nmcli dev wifi
```

2. 检查网络接口性能：

```bash
sudo ethtool eth0  # 有线网络
```

## 镜像源配置

默认的软件源可能连接速度较慢，建议更换为国内镜像源：

1. 备份原有源配置：

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
```

2. 编辑源配置文件：

```bash
sudo nano /etc/apt/sources.list
```

3. 替换为阿里云、清华或中科大源（以阿里云为例）：

```
deb http://mirrors.aliyun.com/ubuntu-ports/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ bionic-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ bionic-security main restricted universe multiverse
```

4. 更新软件源：

```bash
sudo apt update
```

## 配置PIP镜像源

同样建议配置pip镜像源以加速Python包下载：

1. 创建配置目录：

```bash
mkdir -p ~/.pip
```

2. 创建配置文件：

```bash
nano ~/.pip/pip.conf
```

3. 添加以下内容（以阿里云为例）：

```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
```

## 结语

完成网络配置后，您的Jetson Nano B01可以正常访问互联网，获取更新和下载必要的开发工具。下一步可以进行[远程访问配置](remote-access.md)或[开发环境搭建](development-environment.md)。 