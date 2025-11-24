# VocFr 图片自动生成指南

本工具集用于批量生成 **Studio Ghibli 水彩风、透明背景** 的法语词汇插画。

**脚本位置**: `Scripts/Vocabulary/image/`

**相关脚本**:
- `generate_image.py` - 单个/单 Unite 生成
- `batch_generate_images.py` - 批量生成所有 Unite
- `tools/check_images.py` - 图片质量检查
- `tools/make_grid.py` - 拼图生成

## 🎨 生成特点

- **Studio Ghibli 水彩风格**: 温暖、柔和的手绘水彩插画
- **透明背景**: 纯透明 PNG，无背景色
- **双风格支持**:
  - **icon** 风格: 干净直边、图标化、适合物体和人物
  - **scene** 风格: 场景式水彩、适合地点和环境
- **自动风格识别**: 根据词性和单词类型自动选择合适风格
- **可配置**: 支持自定义提示词、尺寸、背景处理等

---

# 🌟 功能概览

## ✔ 模式 1 — 从 Unite 编号生成（推荐）

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image/

# 生成 Unite 4 的所有图片
python generate_image.py --unite 4

# 生成 Unite 2 的所有图片，指定输出目录
python generate_image.py --unite 2 --outdir custom_output
```

自动从 `VocFr/Data/JSON/Unite4.json` 加载数据并生成所有带 `nameOfImage` 的词条插画。

---

## ✔ 模式 2 — 从 Unite 中只生成一个单词

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image/

# 只生成 Unite 4 中的 "chemin" 这个单词
python generate_image.py --unite 4 --only-word chemin
```

当需要补图、修改部分词时非常方便。

---

## ✔ 模式 3 — 不依赖 JSON，单独生成任意一个词

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image/

# 生成一个独立的单词
python generate_image.py --plain-word bateau
```

特点：
- 你想生成的单词**不需要存在 JSON 中**
- 自动生成文件名：`bateau_image.png`
- 默认风格：**icon（直边图标）**
- 可通过 `--prompt-type` 切换场景模式

生成场景类图：

```bash
python generate_image.py --plain-word jardin --prompt-type scene
```

# 🎨 Prompt 风格说明（自动适配）

脚本提供两套 Ghibli 水彩风 Prompt：

| **类型**         | **用途**             | **特点**                             |
| ---------------- | -------------------- | ------------------------------------ |
| **icon（默认）** | 动词动作、人物、物体 | 透明背景、干净直边、图标风、主体居中 |
| **scene**        | 房间、风景、地方     | 场景式水彩画、保留适度水彩边缘       |

### 自动风格识别

脚本会自动识别以下单词并使用 **scene** 风格：
- village, rue, trottoir, coin, chemin
- parc, aire de jeux, arrêt de bus
- école, classe, chambre, cuisine, salon, jardin
- salle de bain, salle de classe

其他单词默认使用 **icon** 风格。

### 手动指定风格

在 JSON 中添加 `promptType` 字段：

```json
{
  "canonical": "bateau",
  "nameOfImage": "bateau_image.png",
  "category": "transportation",
  "promptType": "icon"
}
```

或在命令行中指定（仅限 plain-word 模式）：

```bash
python generate_image.py --plain-word jardin --prompt-type scene
```

---

# 🚀 批量生成所有 Unite

使用 `batch_generate_images.py` 可以一次性生成所有 Unite 的图片：

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image/

# 预览模式（查看将生成哪些图片）
python batch_generate_images.py --dry-run

# 批量生成所有 Unite
python batch_generate_images.py

# 生成指定的 Unite（例如 Unite 1-3）
python batch_generate_images.py --unites 1,2,3

# 强制重新生成所有图片（包括已存在的）
python batch_generate_images.py --no-skip-existing
```

### 批量生成参数

| 参数 | 说明 |
|------|------|
| `--dry-run` | 预览模式，不实际生成 |
| `--unites` | 指定要生成的 Unite 编号（逗号分隔）|
| `--no-skip-existing` | 重新生成已存在的图片 |
| `--outdir, -o` | 输出目录（默认：VocFr/Resources/Images/tempVocPic）|
| `--size` | OpenAI 生成尺寸 |
| `--target` | 最终输出尺寸（默认：512）|
| `--remove-background` | 应用背景移除 |

---

# 💡 可选功能：额外 prompt（仅 plain-word 模式）

用于临时给一个词添加提示：

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image/

python generate_image.py \
  --plain-word bateau \
  --prompt-type icon \
  --extra-prompt "make the boat yellow"
```

**注意**: JSON 模式不允许使用 `--extra-prompt`（安全保护机制）。如需自定义提示词，应在 JSON 中添加 `imagePrompt` 字段。

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

# 📁 输出文件命名规则

### JSON 模式

脚本使用 JSON 中的 `nameOfImage` 字段：

```json
{
  "canonical": "chemin",
  "nameOfImage": "chemin_image.png",
  "category": "places"
}
```

输出文件：

```
VocFr/Resources/Images/tempVocPic/chemin_image.png
```

### 单词模式（plain-word）

自动生成文件名格式：`{word}_image.png`

```bash
cd Scripts/Vocabulary/image/
python generate_image.py --plain-word bateau
```

输出：

```
VocFr/Resources/Images/tempVocPic/bateau_image.png
```

### 命名规范

- 使用下划线连接多个单词：`aire_de_jeux_image.png`
- 保留法语重音符号：`arrêt_de_bus_image.png`
- 统一后缀：`_image.png`

# 🔧 命令行参数一览

## generate_image.py 参数

| **参数**                 | **简写** | **用途**                              |
| ------------------------ | -------- | ------------------------------------- |
| --unite NUM              | -u       | Unite 编号（1-6）                     |
| --json PATH              |          | 指定 Unite JSON 文件（完整路径）       |
| --outdir DIR             | -o       | 输出目录（默认：tempVocPic）           |
| --only-word WORD         |          | JSON 模式中只生成某一个词             |
| --plain-word WORD        |          | 不依赖 JSON，生成一个单词             |
| --prompt-type icon/scene |          | 指定单词模式下的图像风格              |
| --extra-prompt TEXT      |          | 单词模式下追加 prompt                 |
| --remove-background      |          | 对最终图像执行简单抠背景              |
| --save-raw               |          | 保存模型原始输出到 _raw 子目录        |
| --size                   |          | OpenAI 图像生成尺寸（默认 1024x1024） |
| --target                 |          | 最终输出尺寸（默认 512）              |

---

# 🧪 推荐使用方式（高频工作流）

### 1. 批量生成整个 Unite

```bash
cd Scripts/Vocabulary/image/

# 使用 Unite 编号（推荐）
python generate_image.py --unite 4

# 或使用完整路径
python generate_image.py --json ../../VocFr/Data/JSON/Unite4.json
```

### 2. 补充或修复单个单词

```bash
cd Scripts/Vocabulary/image/

# 重新生成 Unite 4 中的 "chemin"
python generate_image.py --unite 4 --only-word chemin
```

### 3. 批量生成所有 Unite

```bash
cd Scripts/Vocabulary/image/

# 预览
python batch_generate_images.py --dry-run

# 生成
python batch_generate_images.py
```

### 4. 生成 JSON 里没有的新单词

```bash
cd Scripts/Vocabulary/image/

python generate_image.py --plain-word papillon
```

### 5. 生成场景风格图片

```bash
cd Scripts/Vocabulary/image/

python generate_image.py --plain-word jardin --prompt-type scene
```

### 6. 生成时增加特定艺术指令

```bash
cd Scripts/Vocabulary/image/

python generate_image.py --plain-word bateau --extra-prompt "make it yellow"
```

# 📦 VocFr 项目文件结构

```
VocFr/
│
├── Scripts/
│   └── Vocabulary/
│       ├── image/                          # 图片生成工具（本目录）
│       │   ├── generate_image.py          # 主生成脚本
│       │   ├── batch_generate_images.py   # 批量生成脚本
│       │   ├── README.md                  # 本文档
│       │   ├── requirements.txt           # Python 依赖
│       │   └── tools/
│       │       ├── check_images.py        # 图片质量检查
│       │       └── make_grid.py           # 拼图生成
│       │
│       ├── image_dalle/                    # DALL-E 图片生成（旧版）
│       ├── audio/                          # 音频生成
│       └── import_vocabulary.py
│
├── VocFr/
│   ├── Data/
│   │   └── JSON/
│   │       ├── Unite1.json                # Unite 数据文件
│   │       ├── Unite2.json
│   │       ├── Unite3.json
│   │       ├── Unite4.json
│   │       ├── Unite5.json
│   │       └── Unite6.json
│   │
│   └── Resources/
│       ├── Images/
│       │   └── tempVocPic/                # 生成的图片输出目录
│       │       ├── village_image.png
│       │       ├── rue_image.png
│       │       └── ...
│       │
│       └── Audio/
│           └── Words/
```

# ❗ 注意事项

### 1. OpenAI API 要求

- 需要有效的 OpenAI API key
- 设置环境变量：`export OPENAI_API_KEY=sk-xxx`
- 使用 `gpt-image-1` 模型（需要组织账户）

### 2. Python 依赖

```bash
cd Scripts/Vocabulary/image/
pip install -r requirements.txt
```

必需的包：
- `openai>=1.0.0`
- `Pillow>=10.0.0`
- `numpy>=1.26.0`

### 3. JSON 字段要求

Unite JSON 文件中每个单词需要包含：

**必需字段**：
- `canonical`: 单词的标准形式（例如："village"）
- `nameOfImage`: 图片文件名（例如："village_image.png"）
- `category`: 单词类别（例如："places"）

**可选字段**：
- `promptType`: 风格类型（"icon" 或 "scene"）
- `imagePrompt`: 自定义提示词（例如："make it colorful"）

示例：

```json
{
  "canonical": "village",
  "chinese": "村庄",
  "german": "Dorf",
  "type": "vocabulary",
  "partOfSpeech": "noun",
  "genderOrPos": "masculine",
  "category": "places",
  "elision": false,
  "nameOfImage": "village_image.png",
  "promptType": "scene",
  "imagePrompt": "focus on traditional French architecture"
}
```

# 🔧 故障排除

### 问题 1: OpenAI API Key 未设置

```
Error: OpenAI API key not provided
```

**解决方案**：
```bash
export OPENAI_API_KEY=sk-your-api-key-here
```

### 问题 2: 模块未安装

```
ModuleNotFoundError: No module named 'openai'
```

**解决方案**：
```bash
cd Scripts/Vocabulary/image/
pip install -r requirements.txt
```

### 问题 3: Unite 文件未找到

```
FileNotFoundError: Unite file not found
```

**解决方案**：
- 确认 Unite JSON 文件存在于 `VocFr/Data/JSON/`
- 检查文件名格式：`Unite1.json`, `Unite2.json` 等
- 确认从 `Scripts/Vocabulary/image/` 目录运行脚本

### 问题 4: 图片生成失败

```
Error generating image: Invalid model 'gpt-image-1'
```

**解决方案**：
- 确认使用的是组织账户（gpt-image-1 需要组织账户）
- 或修改代码使用 `dall-e-3` 或 `dall-e-2`

---

# 🛠️ 辅助工具

## 工具一：图片透明度 & 边距校验脚本

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

---

## 工具二：拼 3×3 / 4×3 / 4×4 拼图的脚本

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

```bash
cd Scripts/Vocabulary/image/

python tools/make_grid.py \
  --images ../../VocFr/Resources/Images/tempVocPic/*_image.png \
  --rows 3 --cols 3 \
  --cell 512 --gutter 64 \
  --output grid_output.png
```

---

# 📚 相关文档

- [VocFr 音频生成指南](../audio/README.md) - 使用 OpenAI TTS 生成法语发音
- [VocFr DALL-E 图片生成指南](../image_dalle/IMAGE_GENERATION_GUIDE.md) - 旧版 DALL-E 图片生成工具
- [VocFr 词汇导入指南](../VOCABULARY_IMPORT_GUIDE.md) - 如何导入和管理词汇数据
- [OpenAI Image API 文档](https://platform.openai.com/docs/guides/images) - OpenAI 官方图片生成文档

---

**创建日期**: 2025-11-24
**版本**: 2.0 (VocFr 适配版)
**维护者**: VocFr Development Team

