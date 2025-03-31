# Jetson Nano B01 开发环境配置

本文档详细介绍如何在Jetson Nano B01上配置各种开发环境，包括系统更新、基础开发工具安装、AI和计算机视觉库配置，以及各种编程语言的支持。

## 系统更新与基础软件安装

在开始配置开发环境前，首先确保系统是最新的状态：

```bash
# 更新软件包列表
sudo apt update

# 升级已安装的软件包
sudo apt upgrade -y

# 安装开发必备工具
sudo apt install -y build-essential cmake git pkg-config
sudo apt install -y curl wget unzip
```

### 常用系统工具

```bash
# 安装系统监控和分析工具
sudo apt install -y htop iotop
sudo apt install -y lm-sensors
sudo apt install -y vim nano
```

### 安装Jetson系统监控工具

```bash
# 安装Jetson专用系统监控工具
sudo pip3 install jetson-stats

# 使用jtop命令监控系统状态
sudo jtop
```

## AI与计算机视觉库安装

### CUDA和cuDNN

Jetson Nano B01通常已预装CUDA和cuDNN。检查安装版本：

```bash
# 检查CUDA版本
nvcc --version

# 检查cuDNN版本
cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
```

如果需要重新安装或更新，建议使用NVIDIA官方的JetPack SDK。

### 安装OpenCV

官方镜像通常已包含OpenCV，但可能需要额外的模块：

```bash
# 检查OpenCV版本
python3 -c "import cv2; print(cv2.__version__)"

# 安装OpenCV依赖
sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
sudo apt install -y libgtk-3-dev

# 如需从源码编译OpenCV（可选）
# 请参考：https://github.com/mdegans/nano_build_opencv
```

### 安装TensorFlow

Jetson Nano需要特定版本的TensorFlow：

```bash
# 安装TensorFlow依赖
sudo apt install -y libhdf5-serial-dev hdf5-tools
sudo apt install -y libjpeg-dev liblapack-dev libopenblas-dev
sudo apt install -y python3-pip

# 安装特定版本的相关Python包
pip3 install -U pip testresources setuptools
pip3 install -U numpy==1.19.4 future==0.18.2 mock==3.0.5 
pip3 install -U keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0
pip3 install -U protobuf==3.13.0 cython pybind11

# 安装TensorFlow（Jetson Nano兼容版本）
pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v461 tensorflow==2.7.0+nv22.1
```

### 安装PyTorch

Jetson Nano同样需要特定版本的PyTorch：

```bash
# 安装PyTorch（选择适合你的JetPack版本）
wget https://developer.download.nvidia.com/compute/redist/jp/v46/pytorch/torch-1.9.0a0+gitd69c22d.nv21.5-cp36-cp36m-linux_aarch64.whl

# 安装下载的wheel文件
pip3 install torch-1.9.0a0+gitd69c22d.nv21.5-cp36-cp36m-linux_aarch64.whl

# 安装torchvision
sudo apt install -y libjpeg-dev zlib1g-dev
git clone --branch v0.10.0 https://github.com/pytorch/vision.git
cd vision
python3 setup.py install --user
```

### 安装特定版本的深度学习框架

由于Jetson Nano的ARM架构和特定的CUDA支持，安装深度学习框架需要特别注意版本兼容性。建议查看NVIDIA的[官方兼容性表格](https://developer.nvidia.com/embedded/jetpack-archive)，选择适合您JetPack版本的框架版本。

## Python开发环境配置

### 创建和使用虚拟环境

```bash
# 安装虚拟环境工具
pip3 install virtualenv

# 创建虚拟环境
virtualenv -p python3 ~/venvs/nano_env

# 激活虚拟环境
source ~/venvs/nano_env/bin/activate

# 使用完毕后退出
deactivate
```

### 安装常用数据科学库

```bash
# 安装常用数据处理和可视化库
pip3 install numpy pandas matplotlib seaborn
pip3 install scikit-learn scikit-image
pip3 install jupyter jupyterlab
```

### 配置Jupyter Notebook

```bash
# 生成配置文件
jupyter notebook --generate-config

# 设置远程访问密码
jupyter notebook password

# 配置允许远程访问
echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py

# 启动Jupyter Notebook
jupyter notebook
```

## 其他编程语言支持

### C/C++开发环境

Jetson Nano原生支持C/C++开发：

```bash
# 安装C/C++相关工具
sudo apt install -y g++ gdb
sudo apt install -y libatlas-base-dev libprotobuf-dev libleveldb-dev libsnappy-dev
sudo apt install -y libhdf5-serial-dev protobuf-compiler

# 安装NVIDIA提供的CUDA样例（如果有需要）
apt search cuda-samples
sudo apt install -y cuda-samples-10-2  # 版本号可能不同
```

### Node.js开发环境

```bash
# 安装Node.js和npm
sudo apt install -y nodejs npm

# 升级到最新LTS版本（可选）
sudo npm install -g n
sudo n lts

# 安装常用工具
sudo npm install -g yarn
```

### Go语言环境

```bash
# 下载适用于ARM64的Go
wget https://golang.org/dl/go1.17.5.linux-arm64.tar.gz

# 解压并安装
sudo tar -C /usr/local -xzf go1.17.5.linux-arm64.tar.gz

# 设置环境变量
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
source ~/.bashrc
```

## 开发工具安装

### 安装和配置VSCode（通过远程开发）

在远程开发模式下，VS Code运行在您的主机上，通过SSH连接访问Jetson Nano：

1. 在您的主机（Windows/Mac/Linux）上安装[Visual Studio Code](https://code.visualstudio.com/)
2. 安装[Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)扩展
3. 使用Remote-SSH连接到您的Jetson Nano
4. 在远程环境中安装扩展（Python、C/C++等）

### 设置交叉编译环境（可选）

如果需要在功能更强大的主机上为Jetson Nano交叉编译：

```bash
# 安装交叉编译工具链
sudo apt install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# 使用交叉编译器编译
aarch64-linux-gnu-gcc -o output_file source_file.c
```

## 安装和配置Git

```bash
# 安装Git
sudo apt install -y git

# 配置Git全局设置
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 生成SSH密钥（可选）
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

## 设置数据库（可选）

### SQLite

```bash
# 安装SQLite
sudo apt install -y sqlite3 libsqlite3-dev
```

### PostgreSQL

```bash
# 安装PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql

# 配置PostgreSQL用户
sudo -u postgres createuser --interactive
```

## 深度学习框架加速技巧

### TensorRT优化

[TensorRT](https://developer.nvidia.com/tensorrt)是NVIDIA的深度学习推理优化器，可显著提高性能：

```bash
# 检查TensorRT是否已安装
dpkg -l | grep TensorRT

# 如未安装，请参考NVIDIA官方文档安装适合您JetPack版本的TensorRT
```

### 使用半精度(FP16)加速

Jetson Nano支持FP16计算，可显著提升性能并降低内存使用：

```python
# PyTorch示例
model = model.half()  # 转换为FP16
input_tensor = input_tensor.half()  # 输入也需要转换为FP16

# TensorFlow示例
# 在模型构建时启用混合精度
from tensorflow.keras.mixed_precision import experimental as mixed_precision
policy = mixed_precision.Policy('mixed_float16')
mixed_precision.set_global_policy(policy)
```

## 常见问题与解决方案

### Python库安装失败

如果安装Python库时遇到内存错误：

```bash
# 增加交换空间
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# 使用--no-cache-dir选项安装
pip3 install --no-cache-dir package_name
```

### CUDA相关错误

如果遇到CUDA相关错误：

```bash
# 检查CUDA设置
echo $LD_LIBRARY_PATH
echo $PATH

# 添加CUDA路径（如果缺失）
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

## 结语

完成上述配置后，您的Jetson Nano B01已经准备好进行各种开发工作了。下一步，您可以查看[应用开发指南](applications.md)学习如何在Jetson Nano上开发实际应用，或参考[性能优化指南](performance-optimization.md)进一步提升系统性能。 