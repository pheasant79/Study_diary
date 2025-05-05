# Zotero 使用指南 📚

---

[参考教程](https://www.bilibili.com/video/BV13X9yY9EEH/?spm_id_from=333.337.search-card.all.click&vd_source=60fccd43626413093269dbf5a9459d33)

<div class="section" id="initial-setup">

## 📌 初始配置

1. 在官网下载好 Zotero，选择手动安装，设置安装路径并完成安装
2. 在 `编辑` → `设置` → `高级` 中修改数据存储位置

</div>

---

<div class="section" id="sync-setup">

## 🔄 设置同步

1. 在坚果云注册账号
2. 点击右上角的头像 → 账号信息 → 安全选项 → 右下角添加应用（名字可随意设置）
3. 记录以下信息：

   ```properties
   服务器地址：https://dav.jianguoyun.com/dav/
   账户：******@qq.com
   密码：（应用密码）
   ```

4. 配置 Zotero：
   - 打开 Zotero
   - `编辑` → `设置` → `同步`
   - 注册账号并登录
   - 文件同步选择 WebDAV
   - 填入上述信息
   - 点击验证服务器（显示成功即可）

> 📝 [详细参考教程](https://b23.tv/CKzzmL2)

</div>

---

<div class="section" id="plugins">

## 🔌 插件安装

在 [Zotero 中文社区](https://zotero-chinese.com/) 下载插件：
1. 搜索插件中心
2. 下载所需插件
3. 导入 Zotero

### 🌸 jasminum 茉莉花

| 步骤 | 操作 |
|------|------|
| 1 | 下载插件 |
| 2 | `编辑` → `设置` → `茉莉花` |
| 3 | 勾选"添加中文 PDF/CAJ 时自动从知网抓取元数据" |

**作用**：自动从知网获取中文文献的元数据

</div>

---

<div class="section" id="citation">

## 📖 引用文献

1. `编辑` → `设置` → `引用` → `获取更多样式`
2. 选择并下载 `gb2312`
3. 勾选"使用经典版'添加引注'对话框"
4. 在 Word 中插入 Zotero 进行引用

</div>

---

<div class="section" id="translation">

## 🌍 translate for zotero 翻译插件

1. 下载并安装插件
2. `设置` → `翻译`
3. 翻译服务选择 Gemini
4. 获取 API：
   - 访问 [Gemini API 官网](https://ai.google.dev/gemini-api/docs?hl=zh-cn)
   - 获取密钥 API (格式：AIza********Le8pKU)
5. 配置：
   - `设置` → `翻译` → 填入密钥
   - `配置` → 修改接口名为模型名称

**功能**：提供划词翻译功能

</div>

---

<div class="section" id="ethereal">

## 🔑 ethereal style 钥匙插件

### 主要功能：

- 📊 状态与阅读时间跟踪
- 🏷️ 标签管理（支持颜色标记）
- 🔄 翻译插件联动 (快捷键：`Shift + P`)
- 📝 文献处理：
  - 标题翻译
  - 摘要翻译
  - 内容标注
  - 阅读进度
  - 期刊标签

**核心价值**：提供全面的分类、评级、时间追踪和翻译功能

</div>

---

<div class="section" id="actions-tags">

## 🏷️ Actions and Tags for Zotero 自动

1. 与 style 插件配合使用
2. 自动添加已读/未读标签
3. 配置：`设置` → `选择插件` → `添加动作`

**作用**：实现标签管理自动化

</div>

---

<div class="section" id="pdf2zh">

## 📄 pdf2zh

### 安装配置

1. 安装 Zotero pdf2zh 插件
2. 参考资料：
   - [详细教程](https://rosetears.cn/index.php/archives/42/)
   - [视频指南](https://b23.tv/DFl4sj7)

### 基础配置

1. 修改 `config.json`
2. 修改 `server.py`
3. Zotero 配置：
   - `编辑` → `设置` → `pdf2zh`
   - 更改保存路径
   - 勾选"重命名条目为短标题"（如'dual'，'mono'）

### 环境设置

```bash
# 1. 激活环境
conda activate pdfmath1

# 2. 安装依赖
pip install flask
pip install pypdf

# 3. 启动服务
python server.py
```

### 使用方法

1. `编辑` → `设置` → `pdf2zh`
2. 选择对应模型
3. 右键文件选择翻译

</div>

---

> 💡 **提示**：请确保按照顺序完成配置，以确保所有功能正常运行。

