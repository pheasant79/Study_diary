# 类与对象
类:对一系列具有相同属性和行为的实物的统称,是一共抽象的概念,不是真实存在的事物
class 类名:
    代码块

对象:是类的具体实例,是真实存在的事物
对象名 = 类名()

类的三要素:
1.类名:类名通常使用大驼峰命名法,首字母大写,每个单词首字母大写,其余字母小写
2.属性:类中定义的变量称为属性(类似于变量)
3.方法:类中定义的函数称为方法(类似于函数)

包,模块,功能,类,对象

类里面的属性和方法外面都无法使用,只用由对象来调用

说实话我感觉类有点像c语言中的结构体,变量可以存储变量,函数指针可以存储函数

方法至少有一个参数,就是self,self代表对象本身
就是把对象传进去,类似于c中的.this

# 实例属性,类属性
self.属性名 = 属性值

实例属性是私有的
类属性是公有的

# 构造函数
__init__(self, 形参1, 形参2, ...)
作用:通常用来做属性初始化或赋值操作

# 析构函数
__del__(self)
作用:通常用来做对象销毁操作

面向对象的三大特性:
1.封装
2.继承
3.多态

# 封装
隐藏对象中一些不希望被外界访问的属性或方法
隐藏属性:仅允许在类的内部使用,无法通过对象访问
__属性名

隐藏方法:仅允许在类的内部使用,无法通过对象访问
__方法名
功能类似于private,但其实只是给这个属性或方法起了个名字,实际上还是可以访问的
_类名__属性名
_类名__方法名

或者在类中定义一个方法,来访问隐藏属性或方法
类似于c里面的get和set函数

私有属性
_属性名

私有方法
_方法名

调用私有属性或方法
对象名._属性/方法名

类似于c语言中的static变量,static函数



1.xxx普通属性或方法
2._xxx私有属性或方法,外部可以使用,子类可以继承,但是在另一个py文件中通过from xxx import * 导入的时候,不会导入私有属性或方法
3.__xxx隐藏属性或方法,无法在外部直接访问,子类不会继承,只能间接访问,另一个py文件中,通过form xxx import * 导入的时候,不会导入隐藏属性或方法


#继承
让类与类之间变成父子关系,子类可以继承父类的属性和方法

class 子类名(父类名):
    代码块


# 单继承
class 子类名(父类名):
    代码块

继承的传递性:
如果一个类继承了另一个类,那么这个类也会继承另一个类的父类
多重继承

# 重写
在子类中重写父类的方法,也就是方法的覆盖
在子类里面再写一遍需要覆盖的函数

#对父类方法的调用/扩展,既有子类的重写方法,也有父类的方法
父类名.方法名(self, 形参1, 形参2, ...)
super().方法名(self, 形参1, 形参2, ...)


# 新式类
class 类名(object):
    代码块

# 经典类
class 类名():
    代码块

class 类名:
    代码块


经典类是不由object继承的类,不是派生类(与父类相同,而非不同)
新式类是由object继承的类,是派生类(与父类不同)

object --对象,是python为所有对象提供的一共基类(夫类),提供了一些内置的属性和方法
可以通过dir()查看

# 多继承
class 子类名(父类名1, 父类名2, ...):
    代码块

python中内置的属性__mro__可以查看方法的搜索顺序
从左到右依次查找

# 多继承的弊端
容易引发冲突

# 多态
同一种行为,具有不同的表现形式

#多态性
定义一个统一的接口,一个接口可以多种实现
def 函数名(obj):
    obj.方法名()

函数名(对象名)
例如:
def 动物(obj):
    obj.叫()

动物(狗)
动物(猫)
都统一调用动物的叫方法,但是狗和猫的叫方法不同,所以会表现出不同的行为

所以封装类似于private,static
继承类似于继承
多态类似于统一接口调用

# 静态方法
@staticmethod
def 方法名(self, 形参1, 形参2, ...):
    代码块

静态方法没有self,cls的限制
静态方法与类无关,与对象无关.可以被转换成函数,使用

注意与c语言中的static的不一样
它是把类里的方法变成了普通函数,不再需要对象

应用场景
不要实例对象时,可以用.取消不必要的参数(self)传递,减少内存占用

# 类方法
@classmethod
def 方法名(cls, 形参1, 形参2, ...):
    代码块

类方法的第一个参数通常为cls,表示类本身
可以访问类属性,或者调用其他的类方法


应用场景
当方法中需要使用到类对象(如访问私有类属性),定义类方法
类方法一般是配合类属性使用

实例方法:可以访问实例属性,类属性
静态方法:不需要访问实例属性,类属性,所以没有self,cls的限制。只能类名.方法名()/属性名访问
类方法:可以访问类属性,不能访问实例属性
普通方法/属性
隐藏方法/属性
私有方法/属性

类属性是公共的,所有方法都能访问的到
但是静态方法不需要访问类属性
实例属性是私有的


__new__():object基类提供的内置的静态方法
1.在内存中为对象分配空间
2.返回对象的引用

def __new__(cls, *args, **kwargs):
    代码块
    res = super().__new__(cls)
    return res

一个是创建对象,一个是初始化对象

# 单例模式
软件的设计模式
可以节省内存的空间

一个类只能存在一个对象

弊端:多线程访问的时候容易引发线程安全问题

实现
1.通过@classmethod实现
2.通过装饰器实现
3.通过__new__重写实现
4.通过导入模块实现

应用场景
同一个时间,只能存在一个对象的时候,如回收站,qq音乐没有多开
数据库配置,数据库连接池的设计

魔法方法__new__()
等，具有下划线的函数
也是具有特殊作用的函数

__new__
__init__
__doc__魔法属性
类的描述信息
__module__
表示当前操作对象所在的模块
__str__对象的描述信息
__del__
__call__使一个实例对象，成为一个可调用对象，如函数那样
callable()查看是否是可调用对象
其实可调用这个词挺有误导性的。其实也就是可以当做函数使用(后面加小括号)
也就是调用__call__方法


#文件操作
#文件基础操作
open()打开文件
read(n)读n数据的
write()
close()

使用

属性
文件名.name
文件名.module
文件名.closed

#读写方法
read(n)
readline()
readlines()
write()

#访问模式
r

tell()和seek()

with open

#编码格式
encodeing参数
gbk，utf-8

#目录常用操作
导入os模块
import os
重命名os.rename
删除os.remove
创建os.mkdir
获取当前目录os.getcwd
获取目录列表os.listdir
删除文件夹os.rmdir


可迭代对象:可以通过for...in...这类语句遍历读取数据的对象
数值类型如int,flot都不是可迭代对象
str,列表,元组,集合,字典是可迭代对象
俩个条件:
1.对象实现了__iter__()方法
2.__iter()__返回了迭代器对象

from collections.abc import Iterable
isinstance()判断一共对象是否为可迭代对象或一个已知的数据类型
isinstance(0,t) o:对象,t:类型
如isinstance(str,Iterable) 返回:True


#迭代器 interator
迭代器是记住遍历位置的对象:在上次停留住的位置继续做一些事情

通过iter():获取可迭代对象的迭代器
通过next():获取迭代器中的下一个数据,取完元素会触发一个StopIteration异常

li = [1,2,3,4,5]
li_iter = iter(li)
print(next(li_iter))
print(next(li_iter))
print(next(li_iter))
print(next(li_iter))
print(next(li_iter))

#迭代器对象iterable和迭代器iterator
反是可以作用于for循环的,都是可迭代对象
反是可以作用于next()的,都是迭代器
可迭代对象并不一定就是迭代器对象
迭代器对象一定是可迭代对象

也就是一个对象,如果实现了__iter__()方法,那么它就是可迭代对象,如果实现了__next__()方法,那么它就是迭代器对象

dir()查看一个对象的属性和方法

自定义迭代器
俩个特性:iter()和next()
class 类名:
    def __iter__(self):
        代码块
    def __next__(self):
        raise StopIteration("停止迭代")
        num += 1
        return 

for i in 可迭代对象:
    代码块

for i in 自定义迭代器:
    代码块


# 生成器 generator
python中一边循环一边计算的机制,称为生成器

生成器表达式
for i in range(10):
    print(i*5)

li = [i*5 for i in range(10)]
print(li)

li = (i*5 for i in range(10))
print(li)   生成器表达式
可以用next()获取下一个数据,next(li)

生成器表达式可以转换成列表
list(生成器表达式)

生成器函数
def 函数名():
    代码块
    yield 数据

python中,使用了yield关键字的函数就叫做生成器函数
yield的作用:类似于return
yield语句一次返回一个结果,在每个结果中间,挂起函数,并保存当前的运行状态,等待下一次的调用
是函数中断,并保存中断状态,给下一次调用使用


可迭代对象,迭代器,生成器三者之间的关系
可迭代对象里包含了迭代器
迭代器里包含了生成器

可迭代对象:指实现了python迭代协议,可以通过for循环遍历读取的对象
迭代器:指实现了__iter__()和__next__()方法的对象
生成器:是特殊的迭代器,指使用了yield关键字的函数,它是python通过渐变的方法写出迭代器的一种手段
包含关系:可迭代对象包含迭代器,迭代器包含生成器

模块

#进程
线程之间是无序的,是并发的
线程之间是共享资源
资源竞争

线程之间共享资源(全局变量)
1.阻塞线程(防止资源竞争)
线程名.start()启动
线程名.join()阻塞,等待线程执行完毕

2.睡眠
time.sleep(秒数)等待前面的线程运行完,再start启动第二个线程

资源竞争
比如俩个线程都在循环给同一个全局变量加1,那么最后的结果是1,而不是2

线程同步
1.线程等待
阻塞:延迟等待,join()

2.互斥锁
定义互斥锁
lock = Lock()

在对应的函数里写,对应加锁和释放锁
lock.acquire()加锁
lock.release()释放锁

与rtthread差别还是挺大的,rtt是给自己禁止,等待别人给自己解锁
python是直接给其他人上锁,自己进去了,等到解锁房子,别人才能进去

导入模块
from threading import Thread
创建线程
t = Thread(target=函数名,args=(参数1,参数2,...))
启动线程
t.start()




进程介绍
是操作系统进行资源分配和调度的基本单位
一个正在运行的程序或者软件就是一个进程
一个进程可以包含多个线程
多进程也可以完成多任务

进程状态
1.就绪状态:等待cpu调度
2.运行状态:cpu正在执行其功能
3.等待(阻塞)状态:等待某些条件满足,如等待io操作完成




multiprocessing模块提供了process类代表进程对象
process类参数
target:指定进程执行的函数名
args:元组,给target指定的函数传递参数
kwargs:字典,给target指定的函数传递参数
方法
start():启动进程
is_alive():判断进程是否存活
join():阻塞进程,主进程等待子进程执行完毕
常用的属性
name:进程名
pid:进程id

from multiprocessing import Process

创建进程
p = Process(target=函数名,args=(参数1,参数2,...))
启动进程
p.start()

multiprocessing与threading的差别
1.线程是cpu调度的最小单位,进程是操作系统调度的最小单位
2.线程共享进程的资源,进程不共享线程的资源
3.线程的创建和销毁比进程快,进程的创建和销毁比线程慢
4.线程的切换比进程的切换快,进程的切换比线程的切换慢


进程之间不共享全局变量

#进程间的通信
Queue(队列)
from queue import Queue
from multiprocessing import Process,Queue

创建队列
q = Queue(最大容量),没写就是无限大
q.put(数据)放入数据
q.get()获取数据
q.empty()判断队列是否为空
q.full()判断队列是否满了
q.qsize()获取队列的大小


线程和进程
进程:是操作系统进行资源分配的基本单位,每打开一个程序至少就有一个进程
线程:是cpu调度的基本单位,每一个进程至少有一个线程,这个线程通常就是主线程

因为进程是资源分配的基本单位,所以全局变量等不共享
线程共享

守护线程
必须放在start()之前
t1.setDaemon(True)
t2.setDaemon(True)
作用:主线程执行结束,守护线程也会跟着结束

协程
协程,又称微线程,纤程,是一种用户态的轻量级线程
单线程下的开发,又称微线程
注:线程二号进程的操作是由程序触发系统的接口,最后的执行者是系统,协程的操作则是程序员
有点像中断,单线程,但是可以保存上下文,从而调用回来继续执行

简单实现:
def task1():
    for i in range(5):
        print("task1...")
        yield

def task2():
    for i in range(5):
        print("task2...")
        yield

t1 = task1()
t2 = task2()
next(t1)
next(t2)


greenlet
pip install greenlet第三方协程简便模块,手动切换
from greenlet import greenlet

创建协程
g1 = greenlet(func)
g2 = greenlet(func)

切换到g1协程执行
g1.switch()

gevent 自动切换的第三方模块
遇到io操作自动切换
pip install gevent

import gevent

gevent.spawn(函数名,参数1,参数2,...)创建协程对象
gevent.sleep(秒数)模拟io操作
gevent.join() 阻塞某个协程
gevent.joinall() 阻塞所有协程

使用
#创建协程
g1 = gevent.spawn(t1)
g2 = gevent.spawn(t2)

#阻塞协程
g1.join()
g2.join()
没有阻塞,不会运行

协程里面time.sleep(秒数)也可以切换

joinall(g1,g2)阻塞所有协程,并发执行

monket补丁
from gevent import monkey
monkey.patch_all() #将用到的time.sleep()替换为gevent.sleep(),遇到io操作自动切换
必须放在被打补丁之前

总结
线程是cpu调度的最小单位,进程是操作系统调度的最小单位
进程,线程,协程对比
进程:切换需要的资源最大,效率最低
线程:切换需要的资源一般,效率一般
协程:切换需要的资源最小,效率最高
多线程适合io密集型操作(文件操作,爬虫),多进程适合cpu密集型操作(计算,视频解码)
进程,线程,协程都可以完成多任务,可以自行选择


#正则基础
正则表达式:记录文本规则的代码
需要导入re模块

import re
rs = re.match(正则表达式,字符串)
从字符串开头开始匹配,如果匹配成功,返回匹配对象,否则返回None
print(rs.group())获取匹配到的内容

匹配单个字符
. 匹配任意一个字符
[] 匹配中括号中列举的任意一个字符
\d 匹配数字,0-9
\D 匹配非数字,除0-9以外的字符
\s 匹配空白,即空格,tab键
\S 匹配非空白
\w 匹配单词字符,即a-z,A-Z,0-9,_,除特殊字符外的其他字符
\W 匹配非单词字符

匹配多个字符
* 匹配前一个字符出现0次或无限次
+ 匹配前一个字符出现1次或无限次
? 匹配前一个字符出现0次或1次
{m} 匹配前一个字符出现m次
{m,n} 匹配前一个字符出现m次到n次

^ 匹配字符串开头
$ 匹配字符串结尾

正则进阶
正则分组
| 匹配左右任意一个表达式
(ab) 将括号中的字符作为一个分组
\num 引用分组num匹配到的内容
(?P<name>表达式) 分组起别名
(?P=name) 引用别名为name分组匹配到的内容

原生字符串

贪婪匹配

rs = re.search(正则表达式,字符串)
从字符串中搜索,如果匹配成功,返回匹配对象,否则返回None
print(rs.group())获取匹配到的内容

rs = re.findall(正则表达式,字符串)
返回所有匹配成功的列表

rs = re.sub(正则表达式,替换内容,字符串)
替换字符串中的内容

rs = re.split(正则表达式,字符串)
分割字符串,返回列表


#os模块
用于和操作系统进行交互的模块
import os

os.name 获取操作系统类型
os.getcwd() 获取当前工作目录
os.path.split(文件路径) 分割文件路径,返回元组
os.path.basename(文件路径) 返回文件名
os.path.dirname(文件路径) 返回文件路径
os.path.join(目录1,目录2,...) 将目录和文件名合成一个路径
os.path.exists(文件路径) 判断文件是否存在
os.path.isfile(文件路径) 判断是否为文件
os.path.isdir(文件路径) 判断是否为文件夹

os.rename(源文件名,目标文件名) 重命名文件
os.remove(文件名) 删除文件
os.mkdir(文件夹名) 创建文件夹
os.rmdir(文件夹名) 删除文件夹
os.getcwd() 获取当前工作目录
os.chdir(文件夹名) 切换工作目录

#sys模块
负责跟python解释器进行交互的模块
import sys

sys.getdefaultencoding() 获取系统默认编码
sys.path 获取模块的搜索路径
sys.platform 获取操作系统类型
sys.version 获取python解释器版本


#time模块
时间戳:从1970年1月1日0时0分0秒到现在经历的秒数
import time

time.time() 获取时间戳
time.sleep(秒数) 等待
time.strftime(格式,时间元组) 格式化时间
time.strptime(时间字符串,格式) 将时间字符串转换为时间元组
time.gmtime() 获取时间元组
timestamp时间戳
format time 格式化时间
struct_time 时间元组

time.localtime() 获取本地时间
time.mktime(时间元组) 将时间元组转换为时间戳
time.asctime(时间元组) 将时间元组转换为时间字符串
time.ctime() 获取当前时间
time.strftime(格式,时间元组) 格式化时间
time.strptime(时间字符串,格式) 将时间字符串转换为时间元组

time之三种时间
时间戳:从1970年1月1日0时0分0秒到现在经历的秒数
格式化时间:2025-04-22 10:00:00
时间元组:struct_time

time时间之间的转换
时间戳 -> 格式化时间
time.strftime(格式,time.localtime(时间戳))

格式化时间 -> 时间戳
time.mktime(time.strptime(格式化时间,格式))

时间戳 -> 时间元组
time.localtime(时间戳)

时间元组 -> 时间戳
time.mktime(时间元组)

#logging
记录日志信息
import logging

logging.basicConfig(level=logging.DEBUG,format='%(asctime)s - %(levelname)s - %(message)s')

logging.debug('调试信息')
logging.info('信息')
logging.warning('警告')
logging.error('错误')
logging.critical('严重错误')

级别
DEBUG:调试信息
INFO:信息
WARNING:警告
ERROR:错误
CRITICAL:严重错误

#random
随机数
import random

random.randint(a,b) 生成a到b之间的随机整数
random.randrange(a,b,c) 生成a到b之间的随机整数,步长为c
random.choice(列表) 从列表中随机选择一个元素
random.shuffle(列表) 打乱列表

