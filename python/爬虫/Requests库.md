# Requests库使用指南

## 目录
- [Requests库简介](#requests库简介)
- [安装与导入](#安装与导入)
- [基本请求方法](#基本请求方法)
- [请求参数传递](#请求参数传递)
- [自定义请求头](#自定义请求头)
- [响应对象属性](#响应对象属性)
- [处理响应内容](#处理响应内容)
- [处理JSON数据](#处理json数据)
- [会话与Cookie](#会话与cookie)
- [异常处理](#异常处理)
- [高级用法](#高级用法)

## Requests库简介

Requests是Python中最流行的HTTP客户端库，被称为"人性化的HTTP库"。它比Python内置的urllib库更简单易用，提供了丰富的功能来处理HTTP请求和响应。

根据初始笔记，Requests库是Python中一个非常著名的第三方库，专门用于发送网络请求。

### 主要特点

- 简洁的API设计，使用简单直观
- 自动处理复杂的HTTP细节（如连接池、SSL验证等）
- 支持会话和Cookie
- 自动处理编码、解码和压缩
- 优雅处理各种HTTP请求方法
- 广泛的社区支持和完善的文档

对于爬虫开发而言，Requests库是必不可少的工具，它能够轻松实现与网站的交互，获取所需的网页内容。

## 安装与导入

### 安装Requests库

使用pip安装Requests库：

```bash
pip install requests
```

### 导入Requests模块

在Python代码中导入Requests：

```python
import requests
```

## 基本请求方法

Requests库支持所有主要的HTTP请求方法，最常用的是GET和POST。

### GET请求

GET请求用于从服务器获取资源：

```python
# 基本GET请求
response = requests.get('https://www.baidu.com')
print(response.text)  # 打印响应内容

# 检查响应状态码
if response.status_code == 200:
    print("请求成功")
else:
    print(f"请求失败，状态码：{response.status_code}")
```

### POST请求

POST请求用于向服务器提交数据：

```python
# 基本POST请求，提交表单数据
data = {'username': 'user', 'password': 'pass'}
response = requests.post('https://example.com/login', data=data)
print(response.text)

# 提交JSON数据
json_data = {'name': 'John', 'age': 30}
response = requests.post('https://api.example.com/users', json=json_data)
print(response.json())
```

### 其他请求方法

Requests还支持其他HTTP方法：

```python
# PUT请求
response = requests.put('https://api.example.com/users/1', data={'name': 'New Name'})

# DELETE请求
response = requests.delete('https://api.example.com/users/1')

# HEAD请求（只获取头信息）
response = requests.head('https://www.example.com')

# OPTIONS请求
response = requests.options('https://www.example.com')
```

## 请求参数传递

### GET请求参数

使用`params`参数传递GET请求的查询参数：

```python
# URL: https://www.baidu.com/s?wd=python
params = {'wd': 'python'}
response = requests.get('https://www.baidu.com/s', params=params)
print(response.url)  # 打印完整URL，包含参数
```

根据初始笔记，GET请求可以通过params参数携带参数字典，Requests会自动将参数添加到URL中。

### POST请求参数

POST请求有多种传递数据的方式：

```python
# 表单数据 (application/x-www-form-urlencoded)
form_data = {'username': 'user', 'password': 'pass'}
response = requests.post('https://example.com/login', data=form_data)

# JSON数据 (application/json)
json_data = {'name': 'John', 'items': ['item1', 'item2']}
response = requests.post('https://api.example.com/submit', json=json_data)

# 文件上传 (multipart/form-data)
files = {'file': open('document.txt', 'rb')}
response = requests.post('https://example.com/upload', files=files)
```

根据初始笔记，POST请求使用`data`参数来传递表单数据，POST请求通常用于登录、注册、提交大量文本内容等场景。

## 自定义请求头

自定义请求头对于绕过网站的反爬机制非常重要：

```python
# 设置User-Agent
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}
response = requests.get('https://www.baidu.com', headers=headers)

# 设置多个头部字段
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Referer': 'https://www.google.com',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
}
response = requests.get('https://www.example.com', headers=headers)
```

根据初始笔记，User-Agent字段必不可少，它表示客户端的操作系统以及浏览器的信息，添加User-Agent的目的是为了让服务器认为是浏览器在发送请求，而不是爬虫程序。

### User-Agent池

为避免使用固定的User-Agent被识别为爬虫，可以创建User-Agent池：

```python
import random

# User-Agent池
user_agents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
]

# 随机选择一个User-Agent
headers = {
    'User-Agent': random.choice(user_agents)
}
response = requests.get('https://www.example.com', headers=headers)
```

根据初始笔记，使用User-Agent池的目的是防止被反爬，因为如果同一个User-Agent发送请求过多，服务器会认为这是爬虫程序，可以通过在多个User-Agent之间随机选择来模拟不同用户的访问行为。

### 使用fake-useragent库

也可以使用第三方库生成随机User-Agent：

```python
# 安装: pip install fake-useragent
from fake_useragent import UserAgent

ua = UserAgent()
headers = {
    'User-Agent': ua.random
}
response = requests.get('https://www.example.com', headers=headers)
```

根据初始笔记，可以使用`fake_useragent`库来生成随机User-Agent，避免手动构建User-Agent池。

## 响应对象属性

Requests库的响应对象提供了多种属性和方法来处理服务器响应：

### 常用响应属性

```python
response = requests.get('https://www.baidu.com')

# 响应状态码
print(response.status_code)  # 200表示成功

# 响应内容（自动解码为字符串）
print(response.text)

# 响应内容（原始二进制内容）
print(response.content)

# 服务器返回的头信息
print(response.headers)

# 请求的URL
print(response.url)

# 响应编码方式
print(response.encoding)

# 响应的Cookie信息
print(response.cookies)

# 请求历史（包含重定向信息）
print(response.history)
```

根据初始笔记，响应对象常用的属性包括：
- `response.text`: 是response自动解码后的内容，是字符串类型
- `response.content`: 是response的二进制内容，是bytes类型，可以通过decode()解码
- `response.encoding`: 是response的编码方式
- `response.url`: 是请求的url
- `response.status_code`: 是响应的状态码
- `response.headers`: 是响应的头
- `response.cookies`: 是响应的cookie

### 响应编码设置

有时服务器可能未指定正确的编码，需要手动设置：

```python
response = requests.get('https://www.example.com')
response.encoding = 'utf-8'  # 设置响应编码
print(response.text)
```

## 处理响应内容

### 文本内容

对于HTML、XML、文本等内容，使用`.text`属性：

```python
response = requests.get('https://www.baidu.com')
html_content = response.text
print(html_content)
```

### 二进制内容

对于图片、PDF等二进制内容，使用`.content`属性：

```python
response = requests.get('https://example.com/image.jpg')
with open('image.jpg', 'wb') as f:
    f.write(response.content)
```

根据初始笔记，使用Requests库保存图片的步骤为：
1. 确定URL（如通过右键新窗口打开图片，获取图片URL）
2. 发送请求，获取响应
3. 以二进制写入模式保存响应的content属性

## 处理JSON数据

处理API返回的JSON数据：

```python
response = requests.get('https://api.example.com/data')
json_data = response.json()  # 自动将JSON响应转换为Python字典
print(json_data)

# 访问特定字段
print(json_data['results'][0]['name'])
```

根据初始笔记，可以通过`json.loads(response.text)`将JSON字符串转换为Python字典，但Requests提供了更便捷的`.json()`方法。

## 会话与Cookie

### 使用Cookie

手动添加Cookie：

```python
# 通过cookies参数
cookies = {'sessionid': 'abc123', 'userid': '42'}
response = requests.get('https://www.example.com', cookies=cookies)

# 通过请求头添加
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'Cookie': 'sessionid=abc123; userid=42'
}
response = requests.get('https://www.example.com', headers=headers)
```

从浏览器获取Cookie：

```python
# 从浏览器复制Cookie
# F12 --> network --> 刷新 --> 登录后的url --> 复制cookie
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'Cookie': '从浏览器复制的Cookie'
}
response = requests.get('https://www.example.com', headers=headers)
```

### 使用Session对象

Session对象可以自动处理Cookie，维持会话状态：

```python
# 创建会话
session = requests.Session()

# 登录操作
login_data = {'username': 'user', 'password': 'pass'}
session.post('https://www.example.com/login', data=login_data)

# 访问需要登录的页面（会自动使用之前的Cookie）
response = session.get('https://www.example.com/profile')
print(response.text)
```

根据初始笔记，Session对象可以自动处理发送请求、获取响应过程中产生的Cookie，达到状态保持的效果，使用Session对象的步骤为：
1. 实例化Session对象：`session = requests.session()`
2. 使用Session对象发送请求：`session.post(url, data=data, headers=headers)`
3. 使用Session对象访问登录后的页面：`session.get(url)`

## 异常处理

处理请求过程中可能出现的异常：

```python
import requests
from requests.exceptions import RequestException, Timeout, ConnectionError

try:
    response = requests.get('https://www.example.com', timeout=5)
    response.raise_for_status()  # 如果状态码不是200，将抛出HTTPError
    print(response.text)
except Timeout:
    print("请求超时")
except ConnectionError:
    print("连接错误")
except RequestException as e:
    print(f"请求错误: {e}")
```

## 高级用法

### 超时设置

设置请求超时时间，避免长时间等待：

```python
# 设置超时（单位：秒）
response = requests.get('https://www.example.com', timeout=5)

# 分别设置连接超时和读取超时
response = requests.get('https://www.example.com', timeout=(3, 7))
```

### 重定向处理

控制重定向行为：

```python
# 允许重定向（默认行为）
response = requests.get('https://www.example.com', allow_redirects=True)

# 禁止重定向
response = requests.get('https://www.example.com', allow_redirects=False)

# 查看重定向历史
response = requests.get('https://www.example.com')
print(response.history)  # 包含重定向过程中的Response对象列表
```

### 使用代理

通过代理发送请求，常用于绕过IP限制：

```python
# HTTP代理
proxies = {
    'http': 'http://10.10.10.10:8000',
    'https': 'https://10.10.10.10:8000'
}
response = requests.get('https://www.example.com', proxies=proxies)

# 带身份验证的代理
proxies = {
    'http': 'http://user:password@10.10.10.10:8000',
    'https': 'https://user:password@10.10.10.10:8000'
}
response = requests.get('https://www.example.com', proxies=proxies)
```

根据初始笔记，设置代理的格式为：
```python
proxies = {
    "http": "http://12.34.56.79:9527",
    "https": "https://12.34.56.79:9527"
}
response = requests.get(url, proxies=proxies)
```

### URL编码与解码

处理URL中的非ASCII字符：

```python
from urllib.parse import quote, unquote

# 编码（如中文转为URL编码）
encoded = quote('学习Python')
print(encoded)  # %E5%AD%A6%E4%B9%A0Python

# 解码（URL编码转为原始字符）
decoded = unquote('%E5%AD%A6%E4%B9%A0Python')
print(decoded)  # 学习Python
```

根据初始笔记，可以使用`urllib.parse`模块中的`quote`和`unquote`方法进行URL编码和解码，这样可以处理URL中的中文等非ASCII字符。

---

> **总结**：Requests库是Python爬虫开发的基础工具，提供了简单易用的API来处理HTTP请求和响应。熟练掌握Requests库的各种功能，包括自定义请求头、处理Cookie和Session、处理不同类型的响应数据等，对于开发高效稳定的爬虫程序至关重要。 