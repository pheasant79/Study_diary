# PDF数学论文翻译工具使用文档

## 一、准备工作

### 1. Python环境要求
- 安装版本大于3.10且小于3.12的Python
- 推荐使用Python 3.11

### 2. 安装/更新工具
```bash
pip install pdf2zh
pip install --upgrade pdf2zh
```

## 二、环境配置（使用Conda）

### 1. 创建并激活虚拟环境
```bash
# 查看现有环境列表
conda env list

# 创建新的Python 3.11环境
conda create --name pdftrans1 python=3.11

# 激活环境
activate pdftrans1

# 查看已安装的包
conda list
```

### 2. 其他环境管理命令
```bash
# 停用环境
conda deactivate

# 删除环境
conda remove -n pdftrans1 --all
```

## 三、配置与使用

### 1. 设置API密钥
```bash
# 激活环境
activate pdftrans1

# 设置API密钥（替换为你的实际密钥）
set SILICON_API_KEY=你的API密钥

# 设置使用的模型名称
set SILICON_MODEL=你要使用的大模型名称
```

### 2. 使用示例
```bash
# 基本用法
pdf2zh 你的PDF文件.pdf -s silicon

# 参数说明
# -s：指定API服务名称，如"silicon"表示硅基流动
```

## 四、常见问题解答

- 如果遇到安装问题，请确保您的Python版本在3.10到3.12之间
- API密钥获取请访问相应服务提供商网站

## 五、参考资源

- [项目GitHub主页](https://github.com/Byaidu/PDFMathTranslate)
- [哔哩哔哩视频教程](https://b23.tv/LE5pqIh)