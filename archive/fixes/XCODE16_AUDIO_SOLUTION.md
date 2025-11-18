# Xcode 16 音频文件解决方案

## 问题背景

在 Xcode 16.1 中，当多个 Unite 包含相同单词时（如 aimer.mp3 在 Unite2 和 Unite3 中都存在），直接添加音频文件会导致构建错误：

```
error: Multiple commands produce '/Users/.../VocFr.app/aimer.mp3'
    note: from Unite2/Section4/aimer.mp3
    note: from Unite3/Section4/aimer.mp3
```

**根本原因**：
- Xcode 16.1 界面变化，无法轻松创建 folder reference
- 单独添加的文件会被扁平化复制到 app bundle 根目录
- 重复的文件名产生冲突

## 解决方案：扁平化文件命名 + 智能搜索

### 核心思路

在文件名中包含 Unite/Section 信息，确保文件名唯一：

```
旧格式（目录结构）：
  Audio/Words/Unite1/Section1/bureau.mp3
  Audio/Words/Unite2/Section4/aimer.mp3
  Audio/Words/Unite3/Section4/aimer.mp3   ← 冲突

新格式（扁平化）：
  u1s1-bureau.mp3
  u2s4-aimer.mp3
  u3s4-aimer.mp3   ← 文件名唯一，不冲突
```

### 文件命名规则

格式：`u{Unite}s{Section}-{normalized_word}.mp3`

示例：
- `u1s1-bureau.mp3` - Unite 1, Section 1, bureau
- `u1s1-table.mp3` - Unite 1, Section 1, table
- `u2s4-aimer.mp3` - Unite 2, Section 4, aimer
- `u3s4-aimer.mp3` - Unite 3, Section 4, aimer（不同Unite的aimer）
- `u1s3-zero.mp3` - Unite 1, Section 3, zéro
- `u1s1-salle-de-classe.mp3` - Unite 1, Section 1, salle de classe

## 实施步骤

### 步骤 1：Pull 最新代码

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
git pull origin claude/ios-swift-xcode-dev-011CUwzqGLNabBQTyCSfmsuh
```

更新内容：
- ✅ `generate_audio_tts.py` - 支持新的文件命名格式
- ✅ `batch_generate_audio.py` - 批量生成脚本（已更新）
- ✅ `AudioPlayerManager.swift` - 智能搜索支持多种命名格式

### 步骤 2：删除旧的音频文件

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Audio/Words

# 删除所有旧格式的音频文件
rm -rf Unite*/Section*/*.mp3

# 或者删除整个 Words 文件夹重新开始
cd ..
rm -rf Words
mkdir -p Words
```

### 步骤 3：重新生成音频文件（新格式）

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr

# 激活虚拟环境
source .venv/bin/activate

# 设置 API Key
export OPENAI_API_KEY="sk-your-key"

# 批量生成所有音频
python batch_generate_audio.py
```

生成的文件将会是：
```
VocFr/Resources/Audio/Words/
  Unite1/
    Section1/
      u1s1-bureau.mp3
      u1s1-table.mp3
      u1s1-chaise.mp3
      ...
    Section2/
      u1s2-vert.mp3
      u1s2-bleu.mp3
      ...
  Unite2/
    Section4/
      u2s4-aimer.mp3
      u2s4-avoir.mp3
      ...
  Unite3/
    Section4/
      u3s4-aimer.mp3   ← 文件名不同，不冲突！
      u3s4-avoir.mp3
      ...
```

### 步骤 4：在 Xcode 中添加音频文件

**方案 A：直接添加所有文件（推荐）**

1. 在 Xcode Project Navigator 中，右键点击 `VocFr/Resources`
2. 选择 "Add Files to VocFr..."
3. 导航到 `VocFr/Resources/Audio/Words`
4. **展开所有 Unite 和 Section 文件夹**
5. **全选所有 .mp3 文件**（Cmd+A）
6. 在对话框中：
   - Action: **Copy files to destination**
   - Target: 勾选 **VocFr**
7. 点击 **Finish**

**方案 B：只添加顶层 Words 文件夹**

如果 Xcode 支持：
1. 右键点击 `VocFr/Resources`
2. "Add Files to VocFr..."
3. 选择整个 `Audio/Words` 文件夹
4. Action: **Copy files to destination**
5. 点击 Finish

### 步骤 5：验证构建

```
Xcode → Product → Clean Build Folder (Shift + Cmd + K)
删除模拟器上的 VocFr app
Xcode → Product → Run (Cmd + R)
```

构建应该成功，不会有重复文件名错误！

### 步骤 6：验证运行

在 app 中播放音频，检查日志：

```
🎵 Playing audio for word: 'bureau'
  📁 Found audio at: u1s1-bureau.mp3.mp3
  ✅ Found independent audio: u1s1-bureau.mp3

🎵 Playing audio for word: 'aimer' (Unite 2)
  📁 Found audio at: u2s4-aimer.mp3.mp3
  ✅ Found independent audio: u2s4-aimer.mp3

🎵 Playing audio for word: 'aimer' (Unite 3)
  📁 Found audio at: u3s4-aimer.mp3.mp3
  ✅ Found independent audio: u3s4-aimer.mp3
```

## AudioPlayerManager 搜索策略

`AudioPlayerManager.swift` 会按以下顺序搜索音频文件：

```swift
let searchPaths = [
    // 1. 扁平化文件（新格式 - Xcode 16）
    "u\(unite)s\(section)-\(word)",  // u1s1-bureau.mp3

    // 2. 目录结构（旧格式 - 如果 folder reference 可用）
    "Audio/Words/Unite\(unite)/Section\(section)/\(word)",

    // 3. 根目录（向后兼容）
    "Audio/\(word)",
    word
]
```

这样可以同时支持：
- ✅ 新的扁平化命名（解决 Xcode 16 冲突问题）
- ✅ 旧的目录结构（如果之前已经配置好）
- ✅ 向后兼容

## 优势

### ✅ 解决问题
- **不会有重复文件名冲突** - 每个文件名都包含位置信息
- **不依赖 Xcode folder reference** - 适配 Xcode 16.1
- **易于管理** - 文件名包含完整信息，易于查找

### ✅ 向后兼容
- AudioPlayerManager 支持多种命名格式
- 自动降级到旧格式（如果找不到新格式）

### ✅ 便于调试
- 文件名清晰：`u2s4-aimer.mp3` 一眼就知道是 Unite 2, Section 4
- 日志清晰：`Found audio at: u1s1-bureau.mp3`

### ✅ 可扩展
- 添加新的 Unite/Section 不需要修改代码
- 文件名自动唯一

## 成本估算

重新生成所有音频：
- 总单词数：228
- 估计成本：~$0.08 USD
- 估计时间：4-6 分钟

## 手动修复

如果需要手动修复个别单词（如 parents → des parents）：

1. 找到文件：`VocFr/Resources/Audio/Words/Unite{N}/Section{M}/u{N}s{M}-parents.mp3`
2. 删除该文件
3. 单独生成：
   ```bash
   python generate_audio_tts.py --unite {N} --section {M}
   ```
4. 在 Xcode 中重新添加该文件

## 总结

| 项目 | 旧方案（目录结构） | 新方案（扁平化命名） |
|------|-------------------|---------------------|
| 文件名 | `bureau.mp3` | `u1s1-bureau.mp3` |
| 重复单词 | ❌ 冲突 | ✅ 不冲突 |
| Xcode 16 | ❌ 需要 folder reference | ✅ 直接添加即可 |
| 维护性 | ⚠️ 依赖目录结构 | ✅ 文件名包含信息 |
| 向后兼容 | - | ✅ 自动降级 |

新方案完美解决了 Xcode 16.1 的限制，同时保持了代码的灵活性和可维护性！
