# Phase 2.6: 音频架构重构 - TTS 音频生成

## 目标

从单一音频文件 + 时间戳架构迁移到独立音频文件架构，使用 OpenAI TTS API 为每个单词生成高质量法语发音。

## 音频格式设计

### 当前格式（Phase 2.0-2.5）
- **单一音频文件**: `audioWithTimestamps.m4a`
- **时间戳数据**: `audio_segments.json`
- **格式**: 只读不定冠词单数形式（例如："un bureau"）

### 新格式（Phase 2.6）
- **独立音频文件**: 每个单词一个 MP3 文件
- **文件位置**: `VocFr/Resources/Audio/Words/Unite{N}/Section{N}/`
- **格式**: 读两种形式，中间有自然停顿
  - 不定冠词单数 + 单词
  - 定冠词单数 + 单词
  - 例如："un bureau, le bureau"
  - 例如（省音）："une éponge, l'éponge"

### 文件命名规则

使用规范化的单词名称（去除重音符号，空格改为连字符）：

| 原单词 | 文件名 |
|--------|--------|
| bureau | `bureau.mp3` |
| éponge | `eponge.mp3` |
| fenêtre | `fenetre.mp3` |
| salle de classe | `salle-de-classe.mp3` |

## 使用工具：`generate_audio_tts.py`

### 功能特性

✅ 自动读取 Unite JSON 文件
✅ 正确处理性别（masculine/feminine）
✅ 正确处理省音（elision）：l'éponge, l'ordinateur
✅ 自动创建输出目录结构
✅ 跳过已存在的文件（避免重复生成）
✅ 详细的进度提示和错误处理

### 安装依赖

```bash
pip install openai
```

### 准备 API Key

**方法 1**: 设置环境变量（推荐）
```bash
export OPENAI_API_KEY="sk-your-api-key-here"
```

**方法 2**: 命令行参数
```bash
python generate_audio_tts.py --api-key "sk-your-api-key-here"
```

### 基本用法

#### 1. 为 Unite 1 Section 1 生成音频（默认）

```bash
cd /path/to/VocFr
python generate_audio_tts.py
```

这将为 Unite 1, Section 1（à l'école）的所有单词生成音频文件。

#### 2. 指定不同的 Unite 和 Section

```bash
# Unite 2, Section 1
python generate_audio_tts.py --unite 2 --section 1

# Unite 3, Section 2
python generate_audio_tts.py --unite 3 --section 2
```

#### 3. 选择不同的语音

OpenAI TTS 支持 6 种语音，推荐用于法语的有：
- `alloy` - 中性，清晰（默认）
- `nova` - 女声，温暖
- `shimmer` - 女声，柔和

```bash
# 使用 nova 语音
python generate_audio_tts.py --voice nova

# 使用 shimmer 语音
python generate_audio_tts.py --voice shimmer
```

#### 4. 使用高质量模型

```bash
# 使用 tts-1-hd（高质量，但更慢更贵）
python generate_audio_tts.py --model tts-1-hd
```

#### 5. 自定义输出目录

```bash
python generate_audio_tts.py --output-dir /custom/path/audio
```

### 完整示例

为 Unite 1 Section 1 生成高质量音频，使用 nova 语音：

```bash
export OPENAI_API_KEY="sk-your-api-key-here"
cd /path/to/ClaudeCodeTest/VocFr
python generate_audio_tts.py --unite 1 --section 1 --model tts-1-hd --voice nova
```

### 输出示例

```
============================================================
🎵 VocFr Audio Generator (OpenAI TTS)
============================================================
⚙️  Model: tts-1
🎤 Voice: alloy
📂 Output: VocFr/Resources/Audio/Words
============================================================

📖 Loading Unite 1 data...
📚 Unite 1: À l'école
📑 Section 1: à l'école
📝 Total words: 23

📁 Output directory: VocFr/Resources/Audio/Words/Unite1/Section1

[1/23]
  🎙️  Generating: 'bureau' (课桌)
      Text: un bureau, le bureau
      ✅ Saved: bureau.mp3

[2/23]
  🎙️  Generating: 'table' (桌子)
      Text: une table, la table
      ✅ Saved: table.mp3

[3/23]
  🎙️  Generating: 'éponge' (海绵)
      Text: une éponge, l'éponge
      ✅ Saved: eponge.mp3

...

============================================================
✅ Generation complete: 23/23 files
============================================================
```

## 输出目录结构

```
VocFr/Resources/Audio/Words/
├── Unite1/
│   ├── Section1/
│   │   ├── bureau.mp3
│   │   ├── table.mp3
│   │   ├── chaise.mp3
│   │   ├── cahier.mp3
│   │   ├── livre.mp3
│   │   ├── eponge.mp3          # éponge (normalized)
│   │   ├── fenetre.mp3         # fenêtre (normalized)
│   │   ├── salle-de-classe.mp3 # salle de classe (normalized)
│   │   └── ...
│   ├── Section2/
│   │   └── ...
│   └── ...
├── Unite2/
│   └── ...
└── Unite3/
    └── ...
```

## API 成本估算

### OpenAI TTS 定价（2025-11）
- **tts-1**: $0.015 / 1K 字符
- **tts-1-hd**: $0.030 / 1K 字符

### 成本估算

以 Unite 1 Section 1 为例（23 个单词）：

| 单词 | 文本示例 | 字符数 |
|------|----------|--------|
| bureau | "un bureau, le bureau" | ~22 |
| éponge | "une éponge, l'éponge" | ~24 |
| 平均 | ~23 字符/单词 | 23 |

**Unite 1 Section 1 总计**:
- 字符数: 23 单词 × 23 字符 = ~529 字符
- 成本 (tts-1): $0.015 × 0.529 = **~$0.008**
- 成本 (tts-1-hd): $0.030 × 0.529 = **~$0.016**

**全部 3 个 Unités（228 单词）总计**:
- 字符数: 228 单词 × 23 字符 = ~5,244 字符
- 成本 (tts-1): **~$0.08**
- 成本 (tts-1-hd): **~$0.16**

💡 **结论**: 生成所有单词的音频成本非常低，可以放心使用 tts-1-hd 获得最佳质量。

## 测试计划

### Phase 2.6.1: 小规模测试（当前）

**目标**: 验证 TTS 音质和技术可行性

1. ✅ 创建 `generate_audio_tts.py` 脚本
2. ⏳ 为 Unite 1 Section 1 生成音频（23 个单词）
3. ⏳ 在 Xcode 中测试音频播放
4. ⏳ 验证音质是否满足要求
5. ⏳ 验证停顿效果是否自然

### Phase 2.6.2: AudioManager 更新（下一步）

**目标**: 更新代码支持独立音频文件

1. 更新 `AudioManager.swift` 支持独立音频文件
2. 保持向后兼容（支持时间戳格式作为 fallback）
3. 实现音频文件查找逻辑（使用规范化文件名）
4. 更新音频播放测试

### Phase 2.6.3: 批量生成（最后）

**目标**: 为所有单词生成音频

1. 为所有 3 个 Unités 生成音频
2. 验证所有音频文件正常
3. 更新 git 仓库
4. 移除旧的时间戳音频系统（可选）

## 下一步行动

### 立即执行

```bash
# 1. 安装依赖
pip install openai

# 2. 设置 API Key
export OPENAI_API_KEY="your-api-key"

# 3. 生成 Unite 1 Section 1 音频
cd /path/to/ClaudeCodeTest/VocFr
python generate_audio_tts.py --model tts-1-hd --voice nova

# 4. 在 Xcode 中添加音频文件到项目
# - 右键点击 Resources/Audio/Words
# - 选择 "Add Files to 'VocFr'..."
# - 选择生成的音频文件
# - 确保 "Add to targets: VocFr" 选中

# 5. 测试播放
# - 运行 app
# - 点击单词卡片
# - 验证音频播放正常
```

### 问题排查

**问题 1**: `ModuleNotFoundError: No module named 'openai'`
```bash
pip install openai
```

**问题 2**: `Error: OpenAI API key not provided`
```bash
export OPENAI_API_KEY="sk-your-key"
```

**问题 3**: 音频文件未找到
- 检查文件是否已添加到 Xcode 项目
- 检查 Build Phases → Copy Bundle Resources
- 确认文件名规范化正确

## 技术细节

### 语音选择建议

测试不同语音，选择最适合教学的：

| 语音 | 特点 | 适用场景 |
|------|------|----------|
| **alloy** | 中性，清晰 | 通用，初学者友好 |
| **nova** | 女声，温暖 | 儿童学习，温和氛围 |
| **shimmer** | 女声，柔和 | 舒缓学习环境 |
| echo | 男声，清晰 | 偏好男声 |
| fable | 英音，正式 | 不推荐（非法语口音） |
| onyx | 男声，低沉 | 不推荐（太严肃） |

**推荐**: 先用 `nova` 生成样本，听觉测试后决定。

### 停顿实现

脚本使用逗号 `,` 在两个形式之间创建自然停顿：
```
"un bureau, le bureau"
```

OpenAI TTS 会自动在逗号处添加短暂停顿，效果自然。

如需更长停顿，可以考虑：
- 使用句号 `.` 替代逗号
- 使用 SSML 标记（如果 API 支持）
- 后期处理：在两个片段间插入静音

## 参考资料

- [OpenAI TTS API 文档](https://platform.openai.com/docs/guides/text-to-speech)
- [OpenAI TTS 定价](https://openai.com/pricing)
- [Python OpenAI SDK](https://github.com/openai/openai-python)
