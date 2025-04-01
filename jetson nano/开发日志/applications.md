# Jetson Nano B01 应用开发指南

本文档提供在Jetson Nano B01上开发各种应用的详细指南，包括计算机视觉、机器学习、机器人控制等领域的示例和最佳实践。

## 计算机视觉应用

### 配置摄像头

Jetson Nano B01支持多种类型的摄像头：

#### USB摄像头

最简单的视频输入方式是使用USB摄像头：

```bash
# 安装所需包
sudo apt install -y v4l-utils

# 检查已连接的USB摄像头
ls /dev/video*
v4l2-ctl --list-devices

# 查看摄像头支持的格式和分辨率
v4l2-ctl --device=/dev/video0 --list-formats-ext
```

使用OpenCV读取USB摄像头：

```python
import cv2

# 打开摄像头（通常/dev/video0是第一个USB摄像头）
cap = cv2.VideoCapture(0)

# 设置分辨率
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# 读取和显示视频流
while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # 在这里处理帧
    cv2.imshow('USB Camera', frame)
    
    # 按'q'退出
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# 释放资源
cap.release()
cv2.destroyAllWindows()
```

#### CSI摄像头

Jetson Nano B01有一个MIPI CSI-2摄像头接口，可连接诸如树莓派摄像头模块V2或IMX219等兼容的摄像头模块：

```bash
# 检查CSI摄像头是否已识别
ls /dev/video*

# 列出设备信息
v4l2-ctl --list-devices
```

使用GStreamer访问CSI摄像头：

```python
import cv2

# 使用GStreamer后端打开CSI摄像头
gst_str = "nvarguscamerasrc ! video/x-raw(memory:NVMM), width=(int)1920, height=(int)1080, format=(string)NV12, framerate=(fraction)30/1 ! nvvidconv ! video/x-raw, format=(string)BGRx ! videoconvert ! video/x-raw, format=(string)BGR ! appsink"
cap = cv2.VideoCapture(gst_str, cv2.CAP_GSTREAMER)

# 读取和显示视频流
while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # 在这里处理帧
    cv2.imshow('CSI Camera', frame)
    
    # 按'q'退出
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# 释放资源
cap.release()
cv2.destroyAllWindows()
```

### 实时目标检测

使用YOLO模型进行实时目标检测：

```python
import cv2
import numpy as np

# 加载YOLO模型
net = cv2.dnn.readNet('yolov3-tiny.weights', 'yolov3-tiny.cfg')
# 使用GPU加速（CUDA）
net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)

# 加载类别名称
with open('coco.names', 'r') as f:
    classes = [line.strip() for line in f.readlines()]

# 获取输出层名称
layer_names = net.getLayerNames()
output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]

# 打开摄像头
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    height, width, _ = frame.shape
    
    # 准备输入数据
    blob = cv2.dnn.blobFromImage(frame, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    net.setInput(blob)
    
    # 前向传播
    outs = net.forward(output_layers)
    
    # 处理检测结果
    class_ids = []
    confidences = []
    boxes = []
    
    for out in outs:
        for detection in out:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            
            if confidence > 0.5:
                # 目标坐标
                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                w = int(detection[2] * width)
                h = int(detection[3] * height)
                
                # 矩形坐标
                x = int(center_x - w / 2)
                y = int(center_y - h / 2)
                
                boxes.append([x, y, w, h])
                confidences.append(float(confidence))
                class_ids.append(class_id)
    
    # 非极大值抑制
    indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)
    
    # 绘制检测结果
    colors = np.random.uniform(0, 255, size=(len(classes), 3))
    for i in range(len(boxes)):
        if i in indexes:
            x, y, w, h = boxes[i]
            label = str(classes[class_ids[i]])
            confidence = confidences[i]
            color = colors[class_ids[i]]
            
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            cv2.putText(frame, f"{label} {confidence:.2f}", (x, y - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    
    # 显示结果
    cv2.imshow("Object Detection", frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

### 使用TensorRT优化视觉模型

将ONNX模型转换为TensorRT：

```python
import tensorrt as trt
import numpy as np
import pycuda.driver as cuda
import pycuda.autoinit

# 创建TensorRT logger和builder
TRT_LOGGER = trt.Logger(trt.Logger.WARNING)
builder = trt.Builder(TRT_LOGGER)
network = builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH))
parser = trt.OnnxParser(network, TRT_LOGGER)

# 加载ONNX模型
with open('model.onnx', 'rb') as model:
    parser.parse(model.read())

# 配置builder
config = builder.create_builder_config()
config.max_workspace_size = 1 << 28  # 256MiB

# 设置精度（FP16可用于Jetson Nano）
config.set_flag(trt.BuilderFlag.FP16)

# 构建并序列化引擎
serialized_engine = builder.build_serialized_network(network, config)

# 保存引擎
with open('model.trt', 'wb') as f:
    f.write(serialized_engine)
```

使用TensorRT引擎进行推理：

```python
import tensorrt as trt
import pycuda.driver as cuda
import pycuda.autoinit
import numpy as np
import cv2

# 加载TensorRT引擎
TRT_LOGGER = trt.Logger(trt.Logger.WARNING)
runtime = trt.Runtime(TRT_LOGGER)

with open('model.trt', 'rb') as f:
    serialized_engine = f.read()
    
engine = runtime.deserialize_cuda_engine(serialized_engine)
context = engine.create_execution_context()

# 分配内存
h_input = cuda.pagelocked_empty(trt.volume(engine.get_binding_shape(0)), dtype=np.float32)
h_output = cuda.pagelocked_empty(trt.volume(engine.get_binding_shape(1)), dtype=np.float32)
d_input = cuda.mem_alloc(h_input.nbytes)
d_output = cuda.mem_alloc(h_output.nbytes)
stream = cuda.Stream()

# 预处理图像
def preprocess_image(image_path, input_shape):
    image = cv2.imread(image_path)
    image = cv2.resize(image, (input_shape[2], input_shape[3]))
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = image.transpose((2, 0, 1))  # HWC to CHW
    image = image.astype(np.float32) / 255.0
    return image

# 执行推理
def infer(image):
    # 预处理
    np.copyto(h_input, image.ravel())
    
    # 传输数据到GPU
    cuda.memcpy_htod_async(d_input, h_input, stream)
    
    # 执行推理
    context.execute_async_v2(bindings=[int(d_input), int(d_output)], stream_handle=stream.handle)
    
    # 传输结果回CPU
    cuda.memcpy_dtoh_async(h_output, d_output, stream)
    stream.synchronize()
    
    return h_output

# 使用示例
input_shape = engine.get_binding_shape(0)  # NCHW
image = preprocess_image('test.jpg', input_shape)
result = infer(image)
print(result)
```

## 机器学习应用

### 部署TensorFlow Lite模型

Jetson Nano B01可以高效运行TensorFlow Lite模型：

```python
import numpy as np
import tensorflow as tf
import cv2

# 加载TF Lite模型
interpreter = tf.lite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()

# 获取输入和输出张量
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# 获取输入格式
input_shape = input_details[0]['shape']
input_dtype = input_details[0]['dtype']

# 预处理图像
def preprocess_image(image_path, input_shape):
    image = cv2.imread(image_path)
    image = cv2.resize(image, (input_shape[1], input_shape[2]))
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = image.astype(np.float32) / 255.0
    image = np.expand_dims(image, axis=0)
    return image

# 执行推理
def infer(image):
    interpreter.set_tensor(input_details[0]['index'], image)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    return output

# 使用示例
image = preprocess_image('test.jpg', input_shape)
result = infer(image)
print(result)
```

### 部署PyTorch模型

在Jetson Nano B01上使用PyTorch：

```python
import torch
import torchvision.transforms as transforms
from PIL import Image

# 加载预训练模型
model = torch.load('model.pth')
model.eval()

# 如果可用，使用CUDA
device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
model = model.to(device)

# 预处理
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

# 加载和处理图像
input_image = Image.open('test.jpg')
input_tensor = preprocess(input_image)
input_batch = input_tensor.unsqueeze(0)  # 添加批次维度
input_batch = input_batch.to(device)

# 进行推理
with torch.no_grad():
    output = model(input_batch)

# 处理结果
probabilities = torch.nn.functional.softmax(output[0], dim=0)
print(probabilities)
```

## 机器人与控制应用

### GPIO控制

Jetson Nano B01有多个GPIO引脚可用于控制外部设备：

```python
import Jetson.GPIO as GPIO
import time

# 设置引脚模式
GPIO.setmode(GPIO.BOARD)  # 使用物理引脚编号

# 配置输出引脚
led_pin = 11  # 物理引脚编号
GPIO.setup(led_pin, GPIO.OUT)

# LED闪烁示例
try:
    while True:
        GPIO.output(led_pin, GPIO.HIGH)  # LED开
        print("LED ON")
        time.sleep(1)
        GPIO.output(led_pin, GPIO.LOW)   # LED关
        print("LED OFF")
        time.sleep(1)
except KeyboardInterrupt:
    # 清理GPIO资源
    GPIO.cleanup()
```

### 使用I2C连接传感器

连接I2C传感器（例如MPU6050加速度计）：

```python
import smbus
import time

# 创建I2C总线对象
bus = smbus.SMBus(1)  # 使用I2C-1总线

# MPU6050地址
MPU6050_ADDR = 0x68

# MPU6050寄存器地址
PWR_MGMT_1 = 0x6B
ACCEL_XOUT_H = 0x3B

# 初始化MPU6050
bus.write_byte_data(MPU6050_ADDR, PWR_MGMT_1, 0)

# 读取传感器数据
def read_raw_data(addr):
    # 读取两个字节的数据
    high = bus.read_byte_data(MPU6050_ADDR, addr)
    low = bus.read_byte_data(MPU6050_ADDR, addr+1)
    
    # 合并两个字节
    value = ((high << 8) | low)
    
    # 处理有符号整数
    if value > 32767:
        value -= 65536
    
    return value

# 读取加速度数据
def read_accel():
    x = read_raw_data(ACCEL_XOUT_H)
    y = read_raw_data(ACCEL_XOUT_H + 2)
    z = read_raw_data(ACCEL_XOUT_H + 4)
    
    # 转换为g单位（根据传感器设置调整）
    ax = x / 16384.0
    ay = y / 16384.0
    az = z / 16384.0
    
    return {'x': ax, 'y': ay, 'z': az}

# 使用示例
try:
    while True:
        accel_data = read_accel()
        print(f"Accel: X={accel_data['x']:.2f}g, Y={accel_data['y']:.2f}g, Z={accel_data['z']:.2f}g")
        time.sleep(0.5)
except KeyboardInterrupt:
    print("程序已停止")
```

### 机器人控制（ROS集成）

在Jetson Nano B01上使用ROS（机器人操作系统）：

```bash
# 安装ROS Melodic（Ubuntu 18.04）
sudo apt update
sudo apt install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential cmake

# 初始化rosdep
sudo rosdep init
rosdep update

# 创建catkin工作空间
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/
catkin_make

# 设置环境变量
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

创建一个简单的ROS节点来控制机器人：

```python
#!/usr/bin/env python
# 保存为~/catkin_ws/src/my_robot/scripts/motor_controller.py

import rospy
from geometry_msgs.msg import Twist
import Jetson.GPIO as GPIO

# 设置GPIO
GPIO.setmode(GPIO.BOARD)

# 定义电机引脚
MOTOR_LEFT_FORWARD = 11
MOTOR_LEFT_BACKWARD = 12
MOTOR_RIGHT_FORWARD = 15
MOTOR_RIGHT_BACKWARD = 16

# 设置引脚为输出
GPIO.setup(MOTOR_LEFT_FORWARD, GPIO.OUT)
GPIO.setup(MOTOR_LEFT_BACKWARD, GPIO.OUT)
GPIO.setup(MOTOR_RIGHT_FORWARD, GPIO.OUT)
GPIO.setup(MOTOR_RIGHT_BACKWARD, GPIO.OUT)

# 创建PWM对象
pwm_left_forward = GPIO.PWM(MOTOR_LEFT_FORWARD, 100)
pwm_left_backward = GPIO.PWM(MOTOR_LEFT_BACKWARD, 100)
pwm_right_forward = GPIO.PWM(MOTOR_RIGHT_FORWARD, 100)
pwm_right_backward = GPIO.PWM(MOTOR_RIGHT_BACKWARD, 100)

# 启动PWM
pwm_left_forward.start(0)
pwm_left_backward.start(0)
pwm_right_forward.start(0)
pwm_right_backward.start(0)

def callback(data):
    # 获取线速度和角速度
    linear_x = data.linear.x
    angular_z = data.angular.z
    
    # 计算左右轮速度
    left_speed = 100 * (linear_x - angular_z * 0.1)
    right_speed = 100 * (linear_x + angular_z * 0.1)
    
    # 限制速度范围
    left_speed = max(-100, min(100, left_speed))
    right_speed = max(-100, min(100, right_speed))
    
    # 控制电机
    if left_speed > 0:
        pwm_left_forward.ChangeDutyCycle(left_speed)
        pwm_left_backward.ChangeDutyCycle(0)
    else:
        pwm_left_forward.ChangeDutyCycle(0)
        pwm_left_backward.ChangeDutyCycle(-left_speed)
        
    if right_speed > 0:
        pwm_right_forward.ChangeDutyCycle(right_speed)
        pwm_right_backward.ChangeDutyCycle(0)
    else:
        pwm_right_forward.ChangeDutyCycle(0)
        pwm_right_backward.ChangeDutyCycle(-right_speed)

def shutdown():
    # 停止电机
    pwm_left_forward.stop()
    pwm_left_backward.stop()
    pwm_right_forward.stop()
    pwm_right_backward.stop()
    GPIO.cleanup()
    
def motor_controller():
    # 初始化ROS节点
    rospy.init_node('motor_controller', anonymous=True)
    
    # 订阅cmd_vel话题
    rospy.Subscriber('cmd_vel', Twist, callback)
    
    # 注册关闭函数
    rospy.on_shutdown(shutdown)
    
    # 保持节点运行
    rospy.spin()

if __name__ == '__main__':
    try:
        motor_controller()
    except rospy.ROSInterruptException:
        pass
```

## 音频处理应用

### 音频录制与播放

使用PyAudio进行音频处理：

```python
import pyaudio
import wave

# 录制参数
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
CHUNK = 1024
RECORD_SECONDS = 5
WAVE_OUTPUT_FILENAME = "output.wav"

# 初始化PyAudio
audio = pyaudio.PyAudio()

# 开始录制
print("开始录制...")

stream = audio.open(format=FORMAT, channels=CHANNELS,
                    rate=RATE, input=True,
                    frames_per_buffer=CHUNK)

frames = []

for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
    data = stream.read(CHUNK)
    frames.append(data)

print("录制完成")

# 停止录制
stream.stop_stream()
stream.close()
audio.terminate()

# 保存录音
wf = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
wf.setnchannels(CHANNELS)
wf.setsampwidth(audio.get_sample_size(FORMAT))
wf.setframerate(RATE)
wf.writeframes(b''.join(frames))
wf.close()

print(f"音频已保存为 {WAVE_OUTPUT_FILENAME}")
```

### 语音识别

使用Google Speech Recognition进行语音识别：

```python
import speech_recognition as sr

# 初始化recognizer
r = sr.Recognizer()

# 从麦克风获取音频
with sr.Microphone() as source:
    print("请说话...")
    # 调整环境噪声阈值
    r.adjust_for_ambient_noise(source)
    audio = r.listen(source)
    print("处理中...")

try:
    # 使用Google语音识别API
    text = r.recognize_google(audio, language='zh-CN')
    print(f"您说的是: {text}")
except sr.UnknownValueError:
    print("Google Speech Recognition无法识别音频")
except sr.RequestError as e:
    print(f"无法从Google Speech Recognition获取结果; {e}")
```

## 物联网应用

### MQTT通信

使用MQTT协议与IoT设备通信：

```python
import paho.mqtt.client as mqtt
import time
import json
import random

# MQTT回调函数
def on_connect(client, userdata, flags, rc):
    print(f"已连接到MQTT代理，返回码: {rc}")
    # 订阅主题
    client.subscribe("jetson/commands")

def on_message(client, userdata, msg):
    print(f"收到消息: {msg.topic} {str(msg.payload)}")
    payload = json.loads(msg.payload)
    if 'command' in payload:
        if payload['command'] == 'led_on':
            print("打开LED")
            # 这里添加控制LED的代码
        elif payload['command'] == 'led_off':
            print("关闭LED")
            # 这里添加控制LED的代码

# 创建MQTT客户端
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

# 连接到MQTT代理
client.connect("test.mosquitto.org", 1883, 60)

# 启动网络循环
client.loop_start()

try:
    while True:
        # 创建模拟传感器数据
        sensor_data = {
            'temperature': round(random.uniform(20.0, 30.0), 2),
            'humidity': round(random.uniform(40.0, 80.0), 2),
            'timestamp': int(time.time())
        }
        
        # 发布数据
        client.publish("jetson/sensors", json.dumps(sensor_data))
        print(f"已发布数据: {sensor_data}")
        
        time.sleep(5)
except KeyboardInterrupt:
    print("程序已停止")
    client.loop_stop()
    client.disconnect()
```

### 网络服务器（Web Dashboard）

创建一个简单的Flask服务器来显示Jetson Nano的状态：

```python
from flask import Flask, render_template, jsonify
import psutil
import os
import time
import threading
import json

app = Flask(__name__)

# 存储系统数据
system_data = {
    'cpu_percent': 0,
    'memory_percent': 0,
    'disk_percent': 0,
    'temperature': 0,
    'history': {
        'cpu': [],
        'memory': [],
        'time': []
    }
}

def get_temperature():
    try:
        with open('/sys/devices/virtual/thermal/thermal_zone1/temp', 'r') as f:
            temp = float(f.read()) / 1000
        return temp
    except:
        return 0

def update_system_data():
    while True:
        # 更新系统数据
        system_data['cpu_percent'] = psutil.cpu_percent()
        system_data['memory_percent'] = psutil.virtual_memory().percent
        system_data['disk_percent'] = psutil.disk_usage('/').percent
        system_data['temperature'] = get_temperature()
        
        # 更新历史数据（保留最新30个数据点）
        system_data['history']['cpu'].append(system_data['cpu_percent'])
        system_data['history']['memory'].append(system_data['memory_percent'])
        system_data['history']['time'].append(time.strftime('%H:%M:%S'))
        
        if len(system_data['history']['cpu']) > 30:
            system_data['history']['cpu'].pop(0)
            system_data['history']['memory'].pop(0)
            system_data['history']['time'].pop(0)
        
        time.sleep(2)

# 在后台线程中更新系统数据
data_thread = threading.Thread(target=update_system_data)
data_thread.daemon = True
data_thread.start()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/system_data')
def get_system_data():
    return jsonify(system_data)

if __name__ == '__main__':
    # 确保templates目录存在
    os.makedirs('templates', exist_ok=True)
    
    # 创建简单的HTML模板
    with open('templates/index.html', 'w') as f:
        f.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Jetson Nano 系统监控</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card { background: #f5f5f5; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .card h2 { margin-top: 0; }
        .meter { height: 20px; background: #e0e0e0; border-radius: 3px; margin-bottom: 10px; }
        .meter-fill { height: 100%; background: #4CAF50; border-radius: 3px; }
        .meter-high { background: #F44336; }
        .meter-warn { background: #FF9800; }
        canvas { width: 100%; height: 200px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Jetson Nano 系统监控</h1>
        
        <div class="card">
            <h2>CPU使用率: <span id="cpu-percent">0</span>%</h2>
            <div class="meter">
                <div id="cpu-meter" class="meter-fill" style="width: 0%"></div>
            </div>
        </div>
        
        <div class="card">
            <h2>内存使用率: <span id="memory-percent">0</span>%</h2>
            <div class="meter">
                <div id="memory-meter" class="meter-fill" style="width: 0%"></div>
            </div>
        </div>
        
        <div class="card">
            <h2>磁盘使用率: <span id="disk-percent">0</span>%</h2>
            <div class="meter">
                <div id="disk-meter" class="meter-fill" style="width: 0%"></div>
            </div>
        </div>
        
        <div class="card">
            <h2>CPU温度: <span id="temperature">0</span>°C</h2>
            <div class="meter">
                <div id="temp-meter" class="meter-fill" style="width: 0%"></div>
            </div>
        </div>
        
        <div class="card">
            <h2>历史数据</h2>
            <canvas id="history-chart"></canvas>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // 创建图表
        var ctx = document.getElementById('history-chart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: 'CPU使用率',
                        borderColor: '#4CAF50',
                        data: []
                    },
                    {
                        label: '内存使用率',
                        borderColor: '#2196F3',
                        data: []
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });
        
        // 更新数据
        function updateData() {
            fetch('/api/system_data')
                .then(response => response.json())
                .then(data => {
                    // 更新仪表盘
                    document.getElementById('cpu-percent').textContent = data.cpu_percent;
                    document.getElementById('memory-percent').textContent = data.memory_percent;
                    document.getElementById('disk-percent').textContent = data.disk_percent;
                    document.getElementById('temperature').textContent = data.temperature;
                    
                    // 更新进度条
                    document.getElementById('cpu-meter').style.width = data.cpu_percent + '%';
                    document.getElementById('memory-meter').style.width = data.memory_percent + '%';
                    document.getElementById('disk-meter').style.width = data.disk_percent + '%';
                    document.getElementById('temp-meter').style.width = (data.temperature / 100 * 100) + '%';
                    
                    // 根据使用率改变颜色
                    document.getElementById('cpu-meter').className = 'meter-fill' + (data.cpu_percent > 80 ? ' meter-high' : data.cpu_percent > 60 ? ' meter-warn' : '');
                    document.getElementById('memory-meter').className = 'meter-fill' + (data.memory_percent > 80 ? ' meter-high' : data.memory_percent > 60 ? ' meter-warn' : '');
                    document.getElementById('disk-meter').className = 'meter-fill' + (data.disk_percent > 80 ? ' meter-high' : data.disk_percent > 60 ? ' meter-warn' : '');
                    document.getElementById('temp-meter').className = 'meter-fill' + (data.temperature > 80 ? ' meter-high' : data.temperature > 60 ? ' meter-warn' : '');
                    
                    // 更新图表
                    chart.data.labels = data.history.time;
                    chart.data.datasets[0].data = data.history.cpu;
                    chart.data.datasets[1].data = data.history.memory;
                    chart.update();
                });
        }
        
        // 定期更新数据
        updateData();
        setInterval(updateData, 2000);
    </script>
</body>
</html>
        ''')
    
    app.run(host='0.0.0.0', port=8080)
```

## 总结

本指南提供了在Jetson Nano B01上开发各种应用的基础和示例代码。根据您的具体需求，可以进一步扩展和优化这些示例：

1. **计算机视觉应用**：利用OpenCV、YOLO等进行目标检测、图像分类等任务。通过TensorRT优化模型以提高性能。

2. **机器学习应用**：部署TensorFlow、PyTorch模型进行推理。利用量化和模型优化技术提高效率。

3. **机器人控制**：使用GPIO、I2C等接口与外部硬件交互。结合ROS构建完整的机器人系统。

4. **物联网应用**：通过MQTT、RESTful API等实现设备互联。创建Web界面提供实时监控和控制。

Jetson Nano B01强大的计算能力和丰富的接口使其成为理想的边缘计算平台，特别适合需要实时处理的视觉和AI应用。 