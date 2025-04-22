#爬虫介绍
##爬虫概念
网络请求:比如访问www.baidu.com,--url,统一资源定位符
通常会带有hhtps/http

请求过程:

1.浏览器(客户端)向服务器发送请求

请求:
请求网址: --request url
请求方法: --request method
请求头: --request headers
请求体: --request body

F12查看请求相应

爬虫的作用
1.获取数据
2.软件测试
3.抢票
4.网络安全

#爬虫概念
模拟浏览器,发送请求,获取相应

只能获取客户端所展示出来的数据

特点:知识碎片化
在写爬虫的时候会面对各种各样的网站,每个网站都是有区别的

模拟客户端,操作者是正常用户
作为一个爬虫身份,服务器不欢迎我们的,尽可能的去模拟正常用户发送请求

爬虫 -- 模拟客户端访问,抓取数据
反爬 -- 保护重要数据,组织恶意网络攻击
反反爬 -- 针对反爬做的措施

爬虫的分类
通过爬取网站的数量,可以分为:
1.通用爬虫
2.聚焦爬虫

可以通过爬虫的目的,可以分为:
1.功能性爬虫
2.数据增量爬虫

爬虫的基本流程
流程:确认目标:url(网址资源定位符) --> 对url发送网络请求,获取网络请求的响应 --> 解析响应,提取数据 --> 保存数据
提取目标: 目标url:www.baidu.com
发送请求: 发送网络请求,获取到特定服务端给你的响应
提取数据: 从响应中提取特定的数据 jsonpath/xpath/re
保存数据: 本地(html,json,txt),数据库

获取到的响应中,有可能会提取到还需要继续发送请求的url,可以拿着解析到的url继续发送请求

#robts协议
robots协议并不是一个规范,知识约定俗成

robots协议是网站的根目录下的一个robots.txt文件,约定哪些可以爬,哪些不能爬

1.网络通信
电脑(浏览器): url -- www.baidu.com
dns服务器:ip地址标注服务器 -- 1.1.1.1 IP地址
dns服务器会返回url的ip地址
浏览器拿到ip地址去访问服务器,返回响应
服务器返回给我们的响应数据,html/css/js/jpg....

如:
百度首页:实际上由很多部分组成起来
html:文本
css:样式,控制文字大小,颜色
js:行为,包括鼠标点击
jpg:图片

#网络通信的实际原理:
一个请求只能对应一个数据包(文件)
之后抓包可能会有很多个数据包,共同组成了这个页面

#http协议和https协议
http协议:规定了服务器和客户端互相通信的规则

http协议: 超文本传输协议,默认端口号是80
超文本: 不仅仅限于文本,还包括图片,音频,视频
传输协议: 指使用公共约定的固定格式来船体转换成字符串的超文本内容

https协议: http + ssl(安全套接字层) 默认端口号是443
ssl: 对传输的内容进行加密

http请求/响应的步骤
1.客户端连接到web服务器
2.发送http请求
3.服务器接收请求,返回响应
4.释放连接tcp连接
5.客户端解析html内容

鼠标右键 --> 检查
F12

network
浏览器里的抓包工具

请求头
请求行:"请求方法" + "请求url" + "http协议版本"+"回车符"+"换行符"
{
"头部字段名" + "值" + "回车符" + "换行符"

"头部字段名" + "值" + "回车符" + "换行符"
}请求头部

"回车符" + "换行符"
""请求数据

#请求头
请求方式:get 和 post
get像服务器要资源
post向服务器提交数据

响应状态码:
200: 请求成功
301: 永久重定向
302: 临时重定向
404: 资源未找到
500: 服务器内部错误

user-agent:模拟正常用户
cookie:登陆保持
referer:当前这一次请求是由哪个请求过来的

抓包得到的响应内容才是判断依据,element中的源吗是渲染之后的源码,这个不能作为判断标准

#requests库
requests库是python中一个非常著名的第三方库,专门用于发送网络请求

基本使用 -- 百度
1.安装requests库
pip install requests

导入模块
import requests

找到目标url: www.baidu.com
在网页F12 --> network --> 刷新 --> headers --> url

发送请求
在网页F12 --> network --> 刷新 --> headers --> get
response = requests.get(url)

保存响应
print(response.text) 响应内容有乱码,requests模块会自动寻找一种给编码方式去解码

print(response.content.decode()) 响应内容是二进制,requests模块会自动解码

使用requests库保存图片
确定url
右键新窗口打开图片
F12 --> network --> 刷新 --> 图片 --> 图片url

发送请求,获取响应
res = requests.get(url)

保存响应
with open('图片名.jpg', 'wb') as f:
    f.write(res.content)


其他属性

response.txt 和 response.content的区别:
response.txt: 是response自动解码后的内容,是字符串类型
requests模块自动根据http头部对相应的编码做出有根据的推测
response.content: 是response的二进制内容,是bytes类型,可以通过decode()解码

response.encoding: 是response的编码方式

response.url: 是请求的url

response.status_code: 是响应的状态码

response.headers: 是响应的头

response.cookies: 是响应的cookie



用户代理

百度手写代码爬取到的比较少,比F12看到的要少
请求头中的user-agent字段必不可少,表示客户端的操作系统以及浏览器的信息

构建请求头
字典类型
headers = {
    'user-agent': "复制浏览器中的user-agent"
    }

发送请求
response = requests.get(url, headers=headers)

保存响应
with open('baidu.html', 'w', encoding='utf-8') as f:
    f.write(response.text)

添加user-agent的目的是为了让服务器认为是浏览器在发送请求,而不俗爬虫程序在发送请求

user-agent池 -- 防止反爬
user-agent是为了模仿浏览器,但如果同一个user-agent发送请求过多,服务器会认为这是爬虫程序,会进行反爬

user-agent池: 一个列表,里面存放了多个user-agent

UAlist = [
    'F12复制一个,
    '浏览器转换系统,刷新,如linux',
    '浏览器转换系统,刷新,如mac',
]

UA = random.choice(UAlist) 随机选取里面的某个元素

2.若是嫌麻烦,不想构建这么多的池,可以用第三方库

from fake_useragent import UserAgent
UA = UserAgent().random


浏览器发送请求的原理
构建请求
查找缓存 --> 拦截请求(若本地有缓存,则拦截请求,若本地没有缓存,则发送请求)
准本ip地址和端口 --> DNS解析
等待tcp连接
建立tcp连接
发送(http)请求

浏览器会像服务器发送请求行,包括了请求方法,请求url,http协议



带参数的url
url = 'https://www.baidu.com/s?wd=python'

字符串被当作url提奖是,会被自动进行url编码处理,也就不再是中文字符串,而是%E6%96%87%E6%9C%AC等

输入 -- 学习  明文
发送请求的时候 -- %E5%AD%A6%E4%B9%A0 密文

from urllib.parse import quote
quote('学习') 明文 --> 密文
unquote('%E5%AD%A6%E4%B9%A0') 密文 --> 明文


发送带参数的url请求
把浏览器里的一些干扰url信息去掉,如?后面的参数
import requests

url = 'https://www.baidu.com/s?wd=python'

headers = {
    'user-agent': '浏览器复制的user-agent'
}

response = requests.get(url, headers=headers)

print(response.content.decode())

通过params携带参数字典
构建请求参数字典
发送请求的时候带上请求参数字典

url = 'https://www.baidu.com/s'

params = {'wd': 'python'}

headers = {
    'user-agent': '浏览器复制的user-agent'
}

response = requests.get(url, params=params, headers=headers)

print(response.content.decode())


post请求: 登陆注册,传输大文本内容

post请求的url通常是固定的,不需要携带参数

requests.post(url, data=data, headers=headers)
data参数接收一个字典

get和post区别
get请求直接向服务器发送请求,获取响应内容
post请求是献给服务器一些数据,然后再获取响应内容

get请求携带参数 -- params
post请求携带参数 -- data

cookie 模拟登陆
它是存储在浏览器中的一段纯文本信息

cookie记录了客户端跟服务端的交互记录,最主要的是有登陆信息

cookie
F12 --> network --> 刷新 --> 登陆后的url --> 复制cookie

找到登陆后的url
url = 'https://www.baidu.com/"

headers = {
    'user-agent': '浏览器复制的user-agent',
    'cookie': '复制cookie'
}

response = requests.get(url, headers=headers)

print(response.content.decode())

post请求
url = 'https://www.baidu.com/s'

headers = {
    'user-agent': '浏览器复制的user-agent'
}

data = {
    'from': 'zh',
    'to': 'en',
    'query': '学习'
}

这个data需要从抓包里获取

response = requests.post(url, data=data, headers=headers)

print(response.text)

解析数据
将json数据转换成python字典

import json

dic = json.loads(response.text)

print(dic['data'])


session
可以自动去处理发送请求,获取响应过程中产生的cookie,到达状态保持
自动处理cookie

session =   requests.session() #实例化session对象

res = session.post(url, data=data, headers=headers)

使用session访问登陆以后的页面
session.get(url.text)


1.对访问登陆后才能访问的页面进行抓包
2.确定登陆请求的utl地址,请求方法和所需的参数
3.确定登陆后才能访问的页面url和请求方法
4.利用requests.session()完成代码


cookie池:
cookie池: 一个列表,里面存放了多个cookie
每一个cookie就代表一个账号,

cookie有有效期
而session不用担心有效期

cookie跟session的区别
cookie数据放在客户的浏览器上, session数据放在服务器上
cookie不是很安全,别人可以分析存放在本地的cookie并进行cookie欺骗,考虑到安全应该使用session
session会在一定时间内保存在服务器上,考虑到减轻服务器性能方面,应当使用cookie
可以考虑将登陆信息等重要信息存放在sessin,其他信息如过需要保留,可以存放在cookie中


代理ip介绍
代理就是一个ip,指向的是一个代理服务器
代理服务器能够帮我们向目标服务器转发请求

ip地址:精准定位

正向代理
反向代理

正向代理:给客户端做代理,让服务器不知道客户端的真实身份
保护自己的ip不会被封,要封也是封代理ip

反向代理:给服务器做代理,让浏览器不知道服务器的真实地址


实际上理论来说分为三类
透明代理: 服务器知道外面使用了代理ip,也知道真实ip
匿名代理:服务器能够检测到使用了代理ip,但是不知道真实ip
高匿代理:服务器不知道外面使用了代理ip,也不知道真实ip


proxies代理参数

用法:
proxies的形式:字典

proxies = {
    "http":"http://12.34.56.79:9527",
    "https":"https://12.34.56.79:9527"
}

response = requests.get(url, proxies=proxies)















