# 软件安装和环境配置
pycharm和ancondo
python建议3.8
在cmd里面输入python，进入且显示版本号，输入exiti()退出

# 基础语法
print(value=多个值，step=默认空格，end=结尾)
## 注释
单行注释#
多行注释三个单引号或三个双引号
## 变量
变量名=变量值
## 数值类型
整数 int
浮点数 float
布尔型 bool
复数型 complx
# 检测数据类型
type()
# 字符串
# 占位符
%
format()
格式化f

输入函数
input()

运算符
三目运算

循环
while，for
break，continue
range(start，stop，step)

字符串编码
encode()
decode()
字符串与字节之间的转换
字符串的常见操作
+连接，*重复输出，[]索引字符
[:]截取，in成员运算符，not in
r/R，
find，count，replace，split，index

列表(类似数组)
里面的类型可以不一样，可以添加删除
列表名=[1，2，3]
列表可以作为迭代对象用于in
append()，extend，insert
in ，not in，index，count
del，pop，remove
sort，reveres

显而易见的规律，in在其他地方是是否包含，返回的值是true或false，在for里面是迭代

列表表达式:[表达式 for 变量 in 列表]
for 变量 in 列表
列表嵌套

元组
变量名 = (1，2，3)
也可以是不同类型，如果只有一个元素，后面要加逗号
元组只支持查询不支持增删改，有点类似于c的count
其余，如查询与列表用法相同
应用场景

字典
变量名=｛'name'=123，'age'=18｝
我个人感觉它像c里面的枚举，可以输入name，输出123，但是与枚举不同的是，它的存储类型可以是任意
键名重复会覆盖，不会报错
增
删
改
查

求长度，返回字典里包含所以健名的列表，返回字典里包含所有值的列表，返回字典里包含的所有键值对

#集合
s1=｛1，2，3｝
无序，字母无序，数字有序
唯一

增删add，updata

交集与并集

#类型转换
int(x)
eval
tuple
list
chr

#深浅拷贝
有点类似于c里的普通赋值和赋值地址
对于列表集合字典，赋值就类似于赋值地址

##浅拷贝
数据半共享
本身不共享，但内部的数组集合字典共享
copy.copy(li)
id()查看内存地址

#深拷贝
数据不共享
copy.deepcopy

#可变对象
含义:存储空间保存的数据运行被修改，这种数据类型就是可变类型
如列表，字典，集合

#不可变类型
int，flot
str
元组


深浅拷贝只支持可变对象


#函数基础
调用
return返回
定义
函数嵌套
参数

作用域
global，nonlocal
匿名函数
内置函数
import builtins
print(dir(builtins))展示所有内置函数
map()reduce()
from functools import reduce导包
其中大写字母开头是内置常量名
小写是内置函数名
拆包

#异常模块与包
raise exception('xxx')
捕获异常(使代码可以继续执行
try:

exCept exception as a:

#模块，包
模块本质上就是一个py文件
模块名.功能名
from 模块名 import 功能
import 模块名
import 模块名 as 别名
from 模块名 import 功能 as 别名
包:项目文件夹
包是含有__init__.py的文件夹
import导入包时，首先执行__init__.py文件
导包:
improt 包名
form 包 import 模块
__all__变量
包可以包含包

闭包
有点像函数指针
装饰器
本质也是个闭包
标准装饰器
有点像函数指针

不同的是闭包是return 内函数，供外部调用内函数
装饰器也是return 内函数
不同的是，装饰器的内函数的形参是其他函数，就是在内函数里调用其他函数
内函数就相当于一个中转站，return 内函数
去调用内函数，实际是调用其他函数

语法糖
@装饰器名称


被装饰的函数有参数






