# VocFr 图片自动生成指南

## 📋 概述

本指南介绍如何使用 OpenAI DALL-E API 为法语词汇自动生成教育插图。

**脚本位置**：`Scripts/Vocabulary/image_dalle/`

**相关脚本**：
- `generate_image_dalle.py` - 单个/单节生成
- `batch_generate_images.py` - 批量生成
- `generate_image.py` - 旧版脚本（已弃用）

## 🎨 生成流程

### 两步生成过程

1. **生成场景描述**：使用 GPT 模型生成简短的英文场景描述
2. **生成图片**：使用 DALL-E 结合场景描述和固定风格提示生成图片

### 图片风格

- **风格**：Studio Ghibli 水彩风格
- **特点**：柔和、温暖、儿童友好
- **背景**：透明背景
- **尺寸**：1024×1024 (可配置)
- **居中**：对象/角色居中，四周留白

## 🛠️ 工具脚本

### 1. `generate_image_dalle.py` - 单个/单节生成

为指定 Unite 和 Section 的所有单词生成图片。

#### 基本用法

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 使用默认设置 (Unite 1, Section 1)
python generate_image_dalle.py

# 指定 Unite 和 Section
python generate_image_dalle.py --unite 2 --section 3

# 指定 API key
python generate_image_dalle.py --api-key sk-xxx

# 使用 DALL-E 2 (更便宜)
python generate_image_dalle.py --model dall-e-2 --size 512x512
```

#### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--unite, -u` | Unite 编号 | 1 |
| `--section, -s` | Section 编号 | 1 |
| `--api-key, -k` | OpenAI API key | 环境变量 OPENAI_API_KEY |
| `--model, -m` | DALL-E 模型 | dall-e-3 |
| `--size` | 图片尺寸 | 1024x1024 |
| `--gpt-model` | GPT 模型 | gpt-4o-mini |
| `--output-dir, -o` | 输出目录 | /Volumes/DevSSD/.../tempVocPic/ |
| `--delay` | API 调用间隔(秒) | 1.0 |

#### DALL-E 模型对比

| 模型 | 质量 | 成本 | 支持尺寸 |
|------|------|------|----------|
| **dall-e-3** | ⭐⭐⭐⭐⭐ | 1024x1024: $0.040/张 | 1024x1024, 1024x1792, 1792x1024 |
| **dall-e-2** | ⭐⭐⭐ | 512x512: $0.018/张 | 256x256, 512x512, 1024x1024 |

### 2. `batch_generate_images.py` - 批量生成

为所有 Unite 和 Section 批量生成图片。

#### 基本用法

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 预览模式（不实际生成）
python batch_generate_images.py --dry-run

# 批量生成所有图片
python batch_generate_images.py

# 使用 DALL-E 2 节省成本
python batch_generate_images.py --model dall-e-2 --size 512x512

# 自定义输出目录
python batch_generate_images.py --output-dir /path/to/output
```

#### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--api-key, -k` | OpenAI API key | 环境变量 OPENAI_API_KEY |
| `--model, -m` | DALL-E 模型 | dall-e-3 |
| `--size` | 图片尺寸 | 1024x1024 |
| `--gpt-model` | GPT 模型 | gpt-4o-mini |
| `--output-dir, -o` | 输出目录 | /Volumes/DevSSD/.../tempVocPic/ |
| `--dry-run` | 预览模式 | False |
| `--skip-existing` | 跳过已存在文件 | True |
| `--delay` | API 调用间隔(秒) | 1.0 |

## 📝 使用示例

### 示例 1: 为 Unite 1 Section 1 生成图片

```bash
# 设置 API key
export OPENAI_API_KEY=sk-your-api-key-here

# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 生成图片
python generate_image_dalle.py --unite 1 --section 1
```

**输出示例：**
```
🎨 VocFr Image Generator (OpenAI DALL-E)
⚙️  DALL-E Model: dall-e-3
🖼️  Image Size: 1024x1024
🤖 GPT Model: gpt-4o-mini
📂 Output: /Volumes/DevSSD/.../tempVocPic/

[1/15]
  🎨 Generating: 'bureau' (桌子)
      🤖 Generating scene description for 'bureau'...
      📝 Description: A simple wooden desk with a smooth surface...
      🖼️  Generating image with DALL-E (dall-e-3)...
      ✅ Saved: bureau_image.png
```

### 示例 2: 批量生成所有图片（预览）

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 先预览一下
python batch_generate_images.py --dry-run

# 确认后正式生成
python batch_generate_images.py
```

### 示例 3: 节省成本 - 使用 DALL-E 2

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# DALL-E 2 成本约为 DALL-E 3 的一半
python batch_generate_images.py --model dall-e-2 --size 512x512
```

## 💰 成本估算

### DALL-E 3 定价（2025年1月）

| 尺寸 | 价格 |
|------|------|
| 1024×1024 | $0.040/张 |
| 1024×1792 | $0.080/张 |
| 1792×1024 | $0.080/张 |

### DALL-E 2 定价

| 尺寸 | 价格 |
|------|------|
| 256×256 | $0.016/张 |
| 512×512 | $0.018/张 |
| 1024×1024 | $0.020/张 |

### 项目估算

假设 Unite 1-6 共有约 **400 个单词**：

- **DALL-E 3 (1024×1024)**: 400 × $0.040 = **$16.00**
- **DALL-E 2 (512×512)**: 400 × $0.018 = **$7.20**

## 📁 文件命名规则

### 自动 ASCII 转换

脚本会自动将法语单词转换为 ASCII-safe 文件名：

| 法语单词 | 文件名 |
|----------|--------|
| `école` | `ecole_image.png` |
| `fenêtre` | `fenetre_image.png` |
| `salle de classe` | `salle_de_classe_image.png` |
| `après-midi` | `apres_midi_image.png` |

### 命名格式

```
{canonical}_image.png
```

- 所有字母小写
- 重音符号移除
- 空格替换为下划线
- 连字符替换为下划线

## 🤖 GPT 场景描述生成

### System Prompt

脚本使用以下 system prompt 生成场景描述：

```
You are a prompt designer for child-friendly educational illustrations.

For each French vocabulary word, you will create a short English description
of a simple scene that clearly shows the meaning of the word.

Requirements:
- 1–2 short sentences in English.
- Very concrete and visual.
- Only describe what should be drawn, no camera words, no style words.
- No text, no labels, no words inside the image.
- Suitable for primary school children.
- Keep the number of characters small (1–2 people at most).
- If it is a verb, show a character performing the action.
- If it is a noun, draw the object clearly and simply.

Return only the English description.
```

### 示例输入输出

**输入：**
```
French word: "danser" (verb, to dance)
Chinese meaning: 跳舞
```

**GPT 输出：**
```
A little girl dancing happily with one leg lifted and arms open,
eyes closed and smiling.
```

## 🎨 DALL-E 风格提示

### 固定风格 Prompt

脚本会将 GPT 生成的场景描述与以下风格提示结合：

```
Studio Ghibli–inspired watercolor illustration, soft warm tones,
gentle shading, tender hand-painted feeling. Characters/objects with
volume, subtle shadows and rounded shapes. Cute, warm, child-friendly.
Transparent background ONLY, no paper texture, no gradient, no halo,
no glow, no vignette, no noise. Object or character perfectly centered
in a 512×512 canvas, with clean margins and no cropping of limbs or props.
No text, no handwriting.
```

### 最终 Prompt 示例

```
A little girl dancing happily with one leg lifted and arms open,
eyes closed and smiling. Studio Ghibli–inspired watercolor illustration,
soft warm tones, gentle shading, tender hand-painted feeling...
```

## 🚫 无图片单词过滤

### 自动跳过

脚本会自动跳过以下单词：

```json
{
  "canonical": "Bon appétit",
  "type": "expression",
  "nameOfImage": "none"
}
```

或

```json
{
  "canonical": "Comment allez-vous?",
  "type": "sentence",
  "nameOfImage": "null"
}
```

### 判断逻辑

如果 `nameOfImage` 字段为以下任一值，则跳过：
- `"none"`
- `"null"`
- (大小写不敏感)

## ⚠️ 注意事项

### 1. API Rate Limiting

- DALL-E API 有速率限制
- 脚本默认在每次请求间延迟 1 秒
- 可通过 `--delay` 参数调整

### 2. 成本控制

- **先使用 `--dry-run` 预览**
- 建议先测试少量单词
- DALL-E 2 更经济，适合大批量生成

### 3. 文件覆盖

- 默认跳过已存在的文件
- 如需重新生成，手动删除旧文件

### 4. 透明背景

- DALL-E 3 支持透明背景
- 需要在 prompt 中明确指定
- 使用 `b64_json` 格式返回以保留透明度

## 🔧 故障排除

### 问题 1: API Key 错误

```
❌ Error: OpenAI API key not provided.
```

**解决方案：**
```bash
export OPENAI_API_KEY=sk-your-api-key-here
```

### 问题 2: 模块未安装

```
❌ Error: OpenAI library not installed.
```

**解决方案：**
```bash
pip install openai
```

### 问题 3: Rate Limit 错误

```
❌ Error: Rate limit exceeded
```

**解决方案：**
- 增加 `--delay` 参数值
- 等待几分钟后重试
- 检查 API 配额

### 问题 4: 找不到 Unite 文件

```
❌ Unite file not found
```

**解决方案：**
- 确认 Unite JSON 文件存在于 `VocFr/Data/JSON/`
- 检查文件名格式：`Unite1.json`, `Unite2.json` 等

## 📊 进度跟踪

### 实时输出

脚本会实时显示进度：

```
[3/15]
  🎨 Generating: 'chaise' (椅子)
      🤖 Generating scene description for 'chaise'...
      📝 Description: A simple wooden chair with four legs...
      🖼️  Generating image with DALL-E (dall-e-3)...
      ✅ Saved: chaise_image.png

[4/15]
  ⏭️  Skipping 'Bon appétit' (nameOfImage is 'none')
```

### 完成总结

```
✅ Generation complete: 12/15 images
💰 Estimated cost: $0.48 USD
```

## 📚 相关文档

- [OpenAI DALL-E API 文档](https://platform.openai.com/docs/guides/images)
- [OpenAI GPT API 文档](https://platform.openai.com/docs/guides/text-generation)
- [VocFr 词汇导入指南](Scripts/Vocabulary/VOCABULARY_IMPORT_GUIDE.md)
- [VocFr 开发者指南](docs/developer/DEVELOPER_GUIDE.md)

## 🎯 最佳实践

### 1. 分批生成

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 一次生成一个 Unite
for i in {1..6}; do
  python generate_image_dalle.py --unite $i --section 1
  sleep 5  # 批次间延迟
done
```

### 2. 测试先行

```bash
# 进入脚本目录
cd Scripts/Vocabulary/image_dalle/

# 先生成 1 个 Section 测试
python generate_image_dalle.py --unite 1 --section 1

# 检查质量后再批量生成
python batch_generate_images.py
```

### 3. 成本优化

- 使用 DALL-E 2 降低成本
- 选择较小尺寸（512x512）
- 先预览再确认

### 4. 错误恢复

- 脚本会自动跳过已存在文件
- 可以随时中断并重新运行
- 不会重复生成相同图片

---

**创建日期**: 2025-11-23
**版本**: 1.0
**维护者**: Claude Code Assistant
