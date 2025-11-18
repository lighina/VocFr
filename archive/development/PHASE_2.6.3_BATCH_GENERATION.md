# Phase 2.6.3: 批量音频生成指南

## 概述

使用 `batch_generate_audio.py` 脚本为所有 3 个 Unités 的所有单词批量生成音频文件。

---

## 📊 当前状态

### 已生成
- ✅ Unite 1, Section 1: 23 个单词

### 待生成
- ⏳ Unite 1, Section 2-5
- ⏳ Unite 2, 所有 sections (5 个)
- ⏳ Unite 3, 所有 sections (5 个)

**总计**: ~228 个单词

---

## 🚀 使用方法

### 基本用法

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr

# 激活虚拟环境
source .venv/bin/activate

# 设置 API Key
export OPENAI_API_KEY="sk-your-api-key"

# 运行批量生成（使用默认设置）
python batch_generate_audio.py
```

### 自定义选项

```bash
# 使用特定语音
python batch_generate_audio.py --voice nova

# 使用不同速度
python batch_generate_audio.py --speed 0.7

# 使用高质量模型
python batch_generate_audio.py --model tts-1-hd

# 组合使用
python batch_generate_audio.py --voice nova --speed 0.8 --model gpt-4o-mini-tts
```

### Dry Run（预览）

在实际生成前查看会生成什么：

```bash
python batch_generate_audio.py --dry-run
```

**输出示例**：
```
📚 Found 15 sections across 3 Unités
📝 Total words to generate: 228

  📖 Unite 1: 5 sections, 77 words
     • Section 1: à l'école (23 words)
     • Section 2: à l'école (16 words)
     ...
  📖 Unite 2: 5 sections, 88 words
  📖 Unite 3: 5 sections, 63 words

💰 Cost Estimate:
   Total characters: ~5,244
   Estimated cost: $0.079 USD
```

---

## 💰 成本估算

### 价格（2025-11）
- **gpt-4o-mini-tts**: $0.015 / 1K 字符（推荐）
- **tts-1**: $0.015 / 1K 字符
- **tts-1-hd**: $0.030 / 1K 字符

### 全部 228 个单词
- **字符数**: ~5,244 字符
- **gpt-4o-mini-tts**: ~$0.08 USD
- **tts-1-hd**: ~$0.16 USD

💡 **结论**: 成本非常低，推荐使用 gpt-4o-mini-tts（质量好且便宜）。

---

## 📋 命令行参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--api-key` | 环境变量 | OpenAI API Key |
| `--voice` | `alloy` | 语音选择（alloy, nova, coral, etc.） |
| `--model` | `gpt-4o-mini-tts` | TTS 模型 |
| `--speed` | `0.8` | 语速（0.25-4.0） |
| `--instructions` | 默认法语指令 | gpt-4o-mini-tts 的指令 |
| `--output-dir` | `VocFr/Resources/Audio/Words` | 输出目录 |
| `--dry-run` | False | 预览模式（不生成音频） |
| `--skip-existing` | True | 跳过已存在的文件 |

---

## 🔍 脚本功能

### 自动扫描
- ✅ 自动读取所有 Unite JSON 文件
- ✅ 自动识别所有 Sections
- ✅ 统计总单词数

### 智能跳过
- ✅ 检测已生成的音频文件
- ✅ 跳过已有完整音频的 Section
- ✅ 避免重复生成（节省成本）

### 进度跟踪
- ✅ 显示当前进度（[1/15], [2/15], ...）
- ✅ 显示每个 Section 的生成结果
- ✅ 统计成功/跳过/失败数量

### 成本估算
- ✅ 生成前显示预估成本
- ✅ 精确计算字符数
- ✅ 支持不同模型的价格

### 错误处理
- ✅ 捕获并报告错误
- ✅ 失败后可重新运行（跳过成功的）
- ✅ 详细的错误信息

---

## 📖 完整执行示例

### 第一次运行（全部生成）

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
source .venv/bin/activate
export OPENAI_API_KEY="sk-your-key"

python batch_generate_audio.py --voice nova
```

**输出**：
```
======================================================================
🎵 VocFr Batch Audio Generator
======================================================================
📊 Scanning vocabulary data...

📚 Found 15 sections across 3 Unités
📝 Total words to generate: 228

  📖 Unite 1: 5 sections, 77 words
     • Section 1: à l'école (23 words)
     • Section 2: à l'école (16 words)
     • Section 3: Les nombres (15 words)
     • Section 4: Les couleurs (12 words)
     • Section 5: La famille (11 words)
  📖 Unite 2: 5 sections, 88 words
  📖 Unite 3: 5 sections, 63 words

======================================================================
⚙️  Configuration:
   Model: gpt-4o-mini-tts
   Voice: nova
   Speed: 0.8x
   Instructions: Speak français in a clear, slow, educational...
   Output: VocFr/Resources/Audio/Words

💰 Cost Estimate:
   Total characters: ~5,244
   Estimated cost: $0.079 USD
======================================================================

⚠️  Proceed with audio generation? (yes/no): yes

======================================================================
🎙️  Starting batch generation...
======================================================================

[1/15] Unite 1, Section 1: à l'école
   Words: 23
   ⏭️  Skipping (already has 23 audio files)

[2/15] Unite 1, Section 2: à l'école
   Words: 16
📖 Loading Unite 1 data...
📚 Unite 1: À l'école
📑 Section 2: à l'école
📝 Total words: 16

📁 Output directory: VocFr/Resources/Audio/Words/Unite1/Section2

[1/16]
  🎙️  Generating: 'stylo' (钢笔)
      Text: un stylo. le stylo
      ✅ Saved: stylo.mp3

[2/16]
  🎙️  Generating: 'gomme' (橡皮)
      Text: une gomme. la gomme
      ✅ Saved: gomme.mp3

...

   ✅ Generated 16/16 files

[3/15] Unite 1, Section 3: Les nombres
...

======================================================================
🎉 Batch Generation Complete!
======================================================================
✅ Successfully generated: 205 files
⏭️  Skipped (existing): 23 files
⏱️  Total time: 245.3 seconds
💰 Estimated cost: $0.079 USD
======================================================================
```

### 第二次运行（只生成失败的）

如果第一次运行有失败的文件：

```bash
# 重新运行，会自动跳过已生成的
python batch_generate_audio.py --voice nova
```

**输出**：
```
[1/15] Unite 1, Section 1: à l'école
   ⏭️  Skipping (already has 23 audio files)

[2/15] Unite 1, Section 2: à l'école
   ⏭️  Skipping (already has 16 audio files)

[3/15] Unite 1, Section 3: Les nombres
   Words: 15
   ... 重新生成失败的文件 ...
```

---

## 🧪 测试流程

### 1. 运行 Dry Run
```bash
python batch_generate_audio.py --dry-run
```

验证：
- ✅ 检测到正确的 Unités 和 Sections
- ✅ 单词数量正确
- ✅ 成本估算合理

### 2. 生成音频
```bash
python batch_generate_audio.py --voice nova
```

观察：
- ✅ 进度显示正常
- ✅ 每个文件成功生成
- ✅ 没有错误

### 3. 验证生成的文件
```bash
# 检查文件结构
ls -R VocFr/Resources/Audio/Words/

# 统计文件数量
find VocFr/Resources/Audio/Words -name "*.mp3" | wc -l
# 应该显示 228 (如果全部生成)
```

### 4. 在 Xcode 中添加文件
1. 打开 Xcode
2. 选择 `VocFr/Resources/Audio/Words` 文件夹
3. 右键 → "Add Files to 'VocFr'..."
4. 选择新生成的 Unite2, Unite3 文件夹
5. 确保 "Add to targets: VocFr" 勾选

### 5. 在 App 中测试
1. Clean Build (⌘⇧K)
2. 运行 App (⌘R)
3. 测试不同 Unités 的单词
4. 验证音频播放正常

---

## 🐛 故障排查

### 问题 1: API Key 错误
```
❌ Error: OpenAI API key not provided.
```

**解决**:
```bash
export OPENAI_API_KEY="sk-your-actual-key"
```

### 问题 2: 部分文件生成失败
```
❌ Failed: 5 files
```

**原因**: API 限流或网络问题

**解决**: 重新运行脚本（会跳过已成功的）
```bash
python batch_generate_audio.py --voice nova
```

### 问题 3: 找不到 Unite 文件
```
❌ No vocabulary data found!
```

**检查**:
```bash
ls VocFr/Data/JSON/
# 应该看到 Unite1.json, Unite2.json, Unite3.json
```

### 问题 4: 速度太快被限流
**症状**: 连续多个 API 错误

**解决**: 脚本已内置 0.5 秒延迟，但如果仍有问题：
- 等待几分钟后重试
- 检查 OpenAI API 配额

---

## 📊 预期结果

### 文件结构
```
VocFr/Resources/Audio/Words/
├── Unite1/
│   ├── Section1/  (23 个 .mp3)
│   ├── Section2/  (16 个 .mp3)
│   ├── Section3/  (15 个 .mp3)
│   ├── Section4/  (12 个 .mp3)
│   └── Section5/  (11 个 .mp3)
├── Unite2/
│   ├── Section1/  (~18 个 .mp3)
│   ├── Section2/  (~17 个 .mp3)
│   ├── Section3/  (~18 个 .mp3)
│   ├── Section4/  (~17 个 .mp3)
│   └── Section5/  (~18 个 .mp3)
└── Unite3/
    ├── Section1/  (~13 个 .mp3)
    ├── Section2/  (~12 个 .mp3)
    ├── Section3/  (~13 个 .mp3)
    ├── Section4/  (~12 个 .mp3)
    └── Section5/  (~13 个 .mp3)
```

### 统计
- **总文件数**: 228 个 .mp3 文件
- **总大小**: 约 10-15 MB
- **总成本**: ~$0.08 USD (gpt-4o-mini-tts)
- **生成时间**: 约 4-6 分钟

---

## ✅ 完成后

### 1. 验证文件
```bash
# 统计总文件数
find VocFr/Resources/Audio/Words -name "*.mp3" | wc -l

# 检查文件大小
du -sh VocFr/Resources/Audio/Words/
```

### 2. 提交到 Git
```bash
# 不要提交音频文件到 Git！
# 确保 .gitignore 包含：
echo "VocFr/Resources/Audio/Words/" >> .gitignore
```

### 3. 在 Xcode 中添加
按照"测试流程"中的步骤 4

### 4. 测试 App
按照"测试流程"中的步骤 5

---

## 🎯 下一步

完成 Phase 2.6.3 后：
- ✅ 所有单词都有独立音频
- ✅ 完整的法语学习体验
- ✅ 可以继续 Phase 3（MVVM 架构）或添加新内容

---

**最后更新**: 2025-11-13
**脚本版本**: 1.0
