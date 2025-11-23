# VocFr 音频自动生成指南

## 📋 概述

本指南介绍如何使用 OpenAI TTS API 为法语词汇自动生成音频文件。

**脚本位置**：`Scripts/Vocabulary/audio/`

**相关脚本**：
- `generate_audio_tts.py` - 单个/单节生成
- `batch_generate_audio.py` - 批量生成

## 🎵 生成特点

- **真人发音**：使用 OpenAI TTS API 生成自然的法语发音
- **规范格式**：名词包含不定冠词和定冠词形式
- **可配置**：支持多种声音和速度调节
- **批量处理**：支持批量生成所有 Unite 的音频

## 🛠️ 工具脚本

### 1. `generate_audio_tts.py` - 单个/单节生成

为指定 Unite 和 Section 的所有单词生成音频。

#### 基本用法

```bash
# 进入脚本目录
cd Scripts/Vocabulary/audio/

# 使用默认设置 (Unite 1, Section 1)
python generate_audio_tts.py

# 指定 Unite 和 Section
python generate_audio_tts.py --unite 2 --section 3

# 指定 API key
python generate_audio_tts.py --api-key sk-xxx

# 使用不同声音
python generate_audio_tts.py --voice nova
```

#### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--unite, -u` | Unite 编号 | 1 |
| `--section, -s` | Section 编号 | 1 |
| `--api-key, -k` | OpenAI API key | 环境变量 OPENAI_API_KEY |
| `--voice, -v` | TTS 声音 | alloy |
| `--model, -m` | TTS 模型 | gpt-4o-mini-tts |
| `--speed` | 语速 | 1.0 |
| `--instructions` | TTS 指令 | 标准法语、清晰发音 |
| `--output-dir, -o` | 输出目录 | VocFr/Resources/Audio/Words |

#### 可用声音

- `alloy` - 中性、平衡
- `nova` - **推荐** - 清晰、适合法语
- `coral` - **推荐** - 温暖、清晰
- `ash` - 成熟、严肃
- `ballad` - 叙事性
- `echo` - 回声感
- `fable` - 故事性
- `onyx` - 深沉
- `sage` - 智慧感
- `shimmer` - 闪亮

### 2. `batch_generate_audio.py` - 批量生成

为所有 Unite 和 Section 批量生成音频。

#### 基本用法

```bash
# 进入脚本目录
cd Scripts/Vocabulary/audio/

# 预览模式（不实际生成）
python batch_generate_audio.py --dry-run

# 批量生成所有音频
python batch_generate_audio.py

# 使用特定声音
python batch_generate_audio.py --voice nova
```

#### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--api-key, -k` | OpenAI API key | 环境变量 OPENAI_API_KEY |
| `--voice, -v` | TTS 声音 | alloy |
| `--model, -m` | TTS 模型 | gpt-4o-mini-tts |
| `--speed` | 语速 | 1.0 |
| `--instructions` | TTS 指令 | 标准法语发音 |
| `--output-dir, -o` | 输出目录 | VocFr/Resources/Audio/Words |
| `--dry-run` | 预览模式 | False |
| `--skip-existing` | 跳过已存在文件 | True |

## 📝 使用示例

### 示例 1: 为 Unite 1 Section 1 生成音频

```bash
# 设置 API key
export OPENAI_API_KEY=sk-your-api-key-here

# 进入脚本目录
cd Scripts/Vocabulary/audio/

# 生成音频（使用 nova 声音）
python generate_audio_tts.py --unite 1 --section 1 --voice nova
```

### 示例 2: 批量生成所有音频

```bash
# 进入脚本目录
cd Scripts/Vocabulary/audio/

# 先预览一下
python batch_generate_audio.py --dry-run

# 确认后正式生成
python batch_generate_audio.py --voice nova
```

## 💰 成本估算

### TTS 定价（2025年1月）

| 模型 | 价格 |
|------|------|
| gpt-4o-mini-tts | $0.015 / 1K 字符 |
| tts-1 | $0.015 / 1K 字符 |
| tts-1-hd | $0.030 / 1K 字符 |

### 项目估算

假设 Unite 1-6 共有约 **400 个单词**，平均每个单词 23 字符：

- **总字符数**: 400 × 23 = 9,200 字符
- **gpt-4o-mini-tts**: 9.2K × $0.015 = **$0.14**
- **tts-1-hd**: 9.2K × $0.030 = **$0.28**

成本远低于图片生成！

## 📁 文件命名规则

### 格式

```
u{unite}s{section}-{canonical}.mp3
```

### 示例

| 单词 | 文件名 |
|------|--------|
| `école` | `u1s1-ecole.mp3` |
| `bureau` | `u1s1-bureau.mp3` |
| `après-midi` | `u2s3-apres-midi.mp3` |

### ASCII 转换

- 重音符号移除：`é` → `e`, `è` → `e`, `ê` → `e`
- 空格替换为连字符：`salle de classe` → `salle-de-classe`
- 连字符保留：`après-midi` → `apres-midi`

## 🎙️ 音频内容

### 名词

包含不定冠词和定冠词两种形式：

```
"un bureau. le bureau"    # 阳性名词
"une gomme. la gomme"     # 阴性名词
"une heure. l'heure"      # 需要省音的名词
```

### 其他词性

只包含单词本身：

```
"danser"      # 动词
"rouge"       # 形容词
"très"        # 副词
```

## 🎯 最佳实践

### 1. 声音选择

```bash
# 推荐使用 nova 或 coral 获得最佳法语发音
python generate_audio_tts.py --voice nova
```

### 2. 测试先行

```bash
# 先生成 1 个 Section 测试音质
cd Scripts/Vocabulary/audio/
python generate_audio_tts.py --unite 1 --section 1 --voice nova

# 满意后再批量生成
python batch_generate_audio.py --voice nova
```

### 3. 调整语速

```bash
# 语速范围：0.25 - 4.0
# 学习者建议使用 0.9 或 1.0
python generate_audio_tts.py --speed 0.9
```

### 4. 错误恢复

- 脚本会自动跳过已存在文件
- 可以随时中断并重新运行
- 不会重复生成相同音频

## 📚 相关文档

- [OpenAI TTS API 文档](https://platform.openai.com/docs/guides/text-to-speech)
- [VocFr 词汇导入指南](../VOCABULARY_IMPORT_GUIDE.md)
- [VocFr 开发者指南](../../../docs/developer/DEVELOPER_GUIDE.md)

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

### 问题 3: 找不到 Unite 文件

```
❌ Unite file not found
```

**解决方案：**
- 确认 Unite JSON 文件存在于 `VocFr/Data/JSON/`
- 检查文件名格式：`Unite1.json`, `Unite2.json` 等

---

**创建日期**: 2025-11-23
**版本**: 1.0
**维护者**: Claude Code Assistant
