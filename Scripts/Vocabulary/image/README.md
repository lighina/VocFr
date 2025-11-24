# French Cards Toolkit

本工具集用于批量生成 **Studio Ghibli 水彩风、透明背景** 的法语词汇插画，并提供：

- 主生成脚本：`generate_image.py`
- 图片质量检查脚本：`tools/check_images.py`
- 拼图生成脚本：`tools/make_grid.py`



本脚本用于从 **Unite JSON 文件** 或 **单独单词** 生成符合**Studio Ghibli 水彩风 · 透明背景 · 直边/场景双风格**的 PNG 插画。

适用于词汇教学卡片、插画教材、儿童图卡、法语课堂视觉辅助等场景。

------

# **🌟 功能概览**

generate_image.py 支持三种模式：

## **✔ 模式 1 — 从 JSON 批量生成词汇插画**

```bash
python generate_image.py --json Unite4.json --outdir output_unite4
```

自动从 JSON 中寻找带 nameOfImage 的词条并生成对应的插画。

------

## **✔ 模式 2 — 从 JSON 中只生成一个单词**

```bash
python generate_image.py --json Unite4.json --only-word chemin --outdir output_unite4
```

当需要补图、修改部分词时非常方便。

------

## **✔ 模式 3 — 不依赖 JSON，单独生成任意一个词**

```bash
python generate_image.py --plain-word bateau --outdir output_single
```

特点：

- 你想生成的单词**不需要存在 JSON 中**
- 自动生成文件名：bateau_image.png
- 默认风格：**icon（直边图标）**
- 可通过 --prompt-type 切换场景模式

例如生成场景类图：

```bash
python generate_image.py --plain-word chemin --prompt-type scene --outdir output_single
```

# **🎨 Prompt 风格说明（自动适配）**

脚本提供两套 Ghibli 水彩风 Prompt：

| **类型**         | **用途**             | **特点**                             |
| ---------------- | -------------------- | ------------------------------------ |
| **icon（默认）** | 动词动作、人物、物体 | 透明背景、干净直边、图标风、主体居中 |
| **scene**        | 房间、风景、地方     | 场景式水彩画、保留适度水彩边缘       |

启用方式：

- JSON 模式：根据 promptType 或自动识别
- 单词模式：--prompt-type icon/scene

------

# **💡 可选功能：额外 prompt（仅 plain-word 模式）**

用于临时给一个词添加提示：

```bash
python generate_image.py \
  --plain-word bateau \
  --prompt-type icon \
  --extra-prompt "make the boat yellow" \
  --outdir output_single
```

JSON 模式不允许使用 --extra-prompt（安全保护机制）。

------

# **🖼 输出尺寸与裁切说明（新版）**

所有生成的图像遵循如下流程：

1. OpenAI 生成：**1024×1024**
2. 脚本执行：
   - **等比缩放使最短边 = 512**
   - **再从中心裁切为 512×512**

好处：

- **绝不裁掉主体**
- **画面完整、居中、可控**
- 与 Ghibli 图标风显著适配

可通过 --target 修改输出尺寸：

```bash
python generate_image.py --plain-word bateau --target 400 --outdir out
```

------

# **🪄 可选：去背景处理（避免模型输出纯色背景）**

当模型偶尔输出非透明背景时：

```bash
python generate_image.py --plain-word bateau --remove-background --outdir out
```

采用简单的颜色检测抠图，透明度更统一。

------

# **📁 输出文件命名规则**

### **JSON 模式**

使用 JSON 中的字段：

```
"nameOfImage": "chemin_image.png"
```

脚本会输出：

```
output_unite4/chemin_image.png
```

------

### **单词模式（plain-word）**

自动生成：

```
{word}_image.png
```

例如：

```bash
python generate_image.py --plain-word bateau
```

输出：

```
output_single/bateau_image.png
```

# **🔧 命令行参数一览**

| **参数**                 | **用途**                              |
| ------------------------ | ------------------------------------- |
| --json PATH              | 指定 Unite JSON 文件                  |
| --outdir DIR             | 输出目录                              |
| --only-word WORD         | JSON 模式中只生成某一个词             |
| --plain-word WORD        | 不依赖 JSON，生成一个单词             |
| --prompt-type icon/scene | 指定单词模式下的图像风格              |
| --extra-prompt TEXT      | 单词模式下追加 prompt（追加在末尾）   |
| --remove-background      | 对最终图像执行简单抠背景              |
| --save-raw               | 保存模型原始输出到 _raw 子目录        |
| --size                   | OpenAI 图像生成尺寸（默认 1024x1024） |
| --target                 | 最终输出尺寸，默认 512                |

---

# **🧪 推荐使用方式（高频工作流）**

### **1. 批量生成整个 unite**

```bash
python generate_image.py --json Unite6.json --outdir out_unite6
```

### **2. 补充或修复一个单词**

```bash
python generate_image.py --json Unite6.json --only-word chemin --outdir out_unite6
```

### **3. 生成 JSON 里没有的新单词**

```bash
python generate_image.py --plain-word papillon --outdir out_extra
```

### **4. 生成场景风格图片**

```bash
python generate_image.py --plain-word jardin --prompt-type scene --outdir out
```

### **5. 生成时增加特定艺术指令**

```bash
python generate_image.py --plain-word bateau --extra-prompt "make it yellow" --outdir out
```

# **📦 文件结构建议**

```
project/
│
├── generate_image.py
├── Unite4.json
├── Unite5.json
├── Unite6.json
│
└── output/
      ├── Unite4/
      ├── Unite5/
      └── single/
```

# **❗ 注意事项**

### **1. 必须使用 OpenAI 已验证组织账户**

### **2. 建议开启 GPU 加速的环境运行**

大量生成时更稳定。

### **3. 建议所有 JSON 都包含：**

- canonical
- nameOfImage
- promptType（可选）

# **补充**

## **1. 项目模板结构建议**

可以这样组织：

```text
french-cards/
│
├── generate_image.py          # 你现在的主生成脚本
├── README.md                  # 刚写的说明
├── requirements.txt
│
├── data/
│   ├── Unite4.json
│   ├── Unite5.json
│   └── Unite6.json
│
├── outputs/
│   ├── Unite4/
│   ├── Unite5/
│   └── singles/
│
└── tools/
    ├── check_images.py        # 透明度 & 边距校验
    └── make_grid.py           # 拼 3×3 / 4×3 / 4×4 拼图
```

## **2.** **requirements.txt**

放在项目根目录：

```
openai>=1.0.0
Pillow>=10.0.0
numpy>=1.26.0
python-dotenv>=1.0.0
```

> 你可以用 pip install -r requirements.txt 一次装好。

## **3. 工具一：图片透明度 & 边距校验脚本**

文件：tools/check_images.py

功能：

- 扫描一个目录下所有 PNG
- 检查：
  - 是否为 RGBA（有 alpha）
  - 透明背景是否存在
  - 主体是否居中
  - 主体离四边的边距（px）

实现逻辑：

用 alpha 通道算出「非透明区域 bounding box」，再和整图比较。

使用示例：

```bash
python tools/check_images.py --dir outputs/Unite4 --target 512 --min-margin 40 --max-margin 140
```

------

## **4. 工具二：拼 3×3 / 4×3 / 4×4 拼图的脚本**

文件：tools/make_grid.py

功能：

- 从若干单张 512×512 PNG 生成：
  - 3×3、4×3、4×4 等透明背景拼图
- 可设置：
  - cell 大小（默认 512）
  - gutter（格子之间的空隙，默认 64）

**示例：制作数字 0–8 的 3×3 拼图**

假设你已经有：

```
outputs/numbers/
  zero_image.png
  un_image.png
  deux_image.png
  ...
  huit_image.png
```

可以这样：

```
python tools/make_grid.py \
  --images outputs/numbers/*_image.png \
  --rows 3 --cols 3 \
  --cell 512 --gutter 64 \
  --output outputs/grids/numbers_0_8_3x3.png
```

