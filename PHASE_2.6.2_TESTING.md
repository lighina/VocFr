# Phase 2.6.2 测试指南 - 独立音频文件播放

## 问题诊断

如果看到类似这样的日志：
```
🔊 播放单词 'bureau' 的音频片段:
   文件: alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z
```

说明**还在使用旧的时间戳音频**，没有使用新生成的独立音频文件。

---

## ✅ 完整测试步骤

### 步骤 1：确认最新代码已拉取

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
git pull origin claude/ios-swift-xcode-dev-011CUwzqGLNabBQTyCSfmsuh
```

**验证**：确认看到类似输出：
```
Already up to date.
```
或者显示更新了文件。

---

### 步骤 2：验证代码更改

打开 `VocFr/Services/Audio/AudioPlayerManager.swift`，确认包含以下方法：

```swift
// 应该在第 68 行附近
func playWordAudio(for word: Word, completion: @escaping (Bool) -> Void) {
    print("🎵 Playing audio for word: '\(word.canonical)'")
    // ...
}
```

**关键**：日志应该是 `🎵 Playing audio for word`，不是 `🔊 播放单词`。

---

### 步骤 3：清理并重新编译项目

在 Xcode 中：

1. **清理构建文件夹**：
   - 按 `⌘⇧K` (Cmd+Shift+K)
   - 或者菜单：Product → Clean Build Folder

2. **清理 Derived Data**（可选，但推荐）：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/VocFr-*
   ```

3. **重新构建**：
   - 按 `⌘B` (Cmd+B)

---

### 步骤 4：添加音频文件到 Xcode 项目

**非常重要**：音频文件必须添加到 Xcode 项目才能被 app 访问。

#### 方法 1：通过 Xcode GUI 添加

1. 在 Xcode Project Navigator 中，找到并展开：
   ```
   VocFr/
   └── Resources/
       └── Audio/
   ```

2. 右键点击 `Audio` 文件夹

3. 选择 "Add Files to 'VocFr'..."

4. 导航到：
   ```
   /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Audio/
   ```

5. 选择 **整个 `Words` 文件夹**（包含 Unite1/Section1/*.mp3）

6. **确保勾选**：
   - ✅ "Copy items if needed"
   - ✅ "Create groups"（不是 "Create folder references"）
   - ✅ "Add to targets: VocFr"

7. 点击 "Add"

#### 方法 2：通过拖放添加

1. 在 Finder 中打开：
   ```
   /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Audio/Words/
   ```

2. 将 `Words` 文件夹拖到 Xcode 的 `Resources/Audio/` 下

3. 在弹出对话框中：
   - ✅ "Copy items if needed"
   - ✅ "Create groups"
   - ✅ "Add to targets: VocFr"

---

### 步骤 5：验证文件已添加

1. 在 Xcode 中，选择项目根节点（蓝色图标）
2. 选择 **VocFr** target
3. 点击 **Build Phases** 标签页
4. 展开 **Copy Bundle Resources**
5. 搜索 `bureau.mp3`

**预期结果**：应该看到：
```
Words/Unite1/Section1/bureau.mp3
Words/Unite1/Section1/table.mp3
Words/Unite1/Section1/chaise.mp3
...
```

如果**没有看到**这些文件，说明文件没有被正确添加，需要重复步骤 4。

---

### 步骤 6：检查音频文件路径

在终端运行：

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
ls -la VocFr/Resources/Audio/Words/Unite1/Section1/
```

**预期输出**：
```
bureau.mp3
table.mp3
chaise.mp3
cahier.mp3
livre.mp3
feuille.mp3
...
```

如果文件不存在，需要重新生成：

```bash
source .venv/bin/activate
export OPENAI_API_KEY="sk-your-key"
python generate_audio_tts.py
```

---

### 步骤 7：运行 App 并测试

1. **完全删除模拟器中的 App**：
   - 在模拟器中，长按 VocFr app 图标
   - 点击删除 app
   - 确认删除

2. **在 Xcode 中重新运行**：
   - 按 `⌘R`

3. **导航并测试**：
   - 打开 Unite 1
   - 打开 Section 1（à l'école）
   - 点击 "bureau" 单词卡片
   - 点击蓝色播放按钮

---

## 🔍 预期结果

### 正确的控制台日志

```
🎵 Playing audio for word: 'bureau'
  📁 Found audio at: Audio/Words/Unite1/Section1/bureau.mp3
🎧 播放完整音频文件: bureau.mp3
```

**关键点**：
- ✅ 第一行：`🎵 Playing audio for word` (新代码)
- ✅ 第二行：`📁 Found audio at` (找到独立音频)
- ✅ 文件路径：`Audio/Words/Unite1/Section1/bureau.mp3`

### 错误的控制台日志（需要修复）

```
🔊 播放单词 'bureau' 的音频片段:
   文件: alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z
```

**问题**：
- ❌ 显示 `🔊 播放单词` (旧代码)
- ❌ 使用时间戳音频文件

---

## 🐛 故障排查

### 问题 1：控制台显示旧日志（🔊 播放单词）

**原因**：代码没有更新或没有重新编译

**解决方案**：
1. 确认 git pull 成功
2. Clean Build Folder (⌘⇧K)
3. 重新编译 (⌘B)
4. 完全删除模拟器 app，重新运行

---

### 问题 2：日志显示 "❌ No audio found for word"

**原因**：音频文件没有添加到 Xcode 项目

**解决方案**：
1. 重新执行步骤 4（添加音频文件）
2. 验证步骤 5（检查 Copy Bundle Resources）
3. Clean Build (⌘⇧K) 然后重新运行

---

### 问题 3：日志显示 "Using timestamp-based audio"

**原因**：独立音频文件未找到，fallback 到旧格式

这是**正常的 fallback 行为**，但说明 Strategy 1 失败了。

**调试步骤**：

1. **检查文件是否存在**：
   ```bash
   ls -la VocFr/Resources/Audio/Words/Unite1/Section1/bureau.mp3
   ```

2. **检查 Bundle Resources**：
   在 Xcode Build Phases 中确认文件已添加

3. **在 app 中测试文件是否可访问**：
   添加调试代码（临时）：
   ```swift
   // 在 AudioPlayerManager.swift 的 findIndependentAudioFile 中
   print("🔍 Searching for: \(normalizedName)")
   print("🔍 Unite: \(uniteNumber), Section: \(sectionIndex)")
   ```

---

### 问题 4：编译错误

**可能错误**：`Value of optional type 'Unite?' must be unwrapped`

**解决方案**：已在最新代码中修复 (commit cd94d34)，pull 最新代码即可。

---

## 📊 测试清单

使用以下清单确保所有步骤完成：

- [ ] 1. Git pull 最新代码
- [ ] 2. 验证 AudioPlayerManager.swift 包含 `playWordAudio` 方法
- [ ] 3. Clean Build Folder (⌘⇧K)
- [ ] 4. 将音频文件添加到 Xcode 项目
- [ ] 5. 在 Build Phases 中确认文件存在
- [ ] 6. 验证本地音频文件存在
- [ ] 7. 删除模拟器中的旧 app
- [ ] 8. 重新运行 app (⌘R)
- [ ] 9. 测试 bureau 单词
- [ ] 10. 确认控制台显示 `🎵 Playing audio for word`

---

## 🎯 成功标准

### 音频播放

- ✅ 听到："un bureau [停顿] le bureau"
- ✅ 法语发音清晰准确
- ✅ 速度适中（0.8x）
- ✅ 停顿自然

### 控制台输出

```
🎵 Playing audio for word: 'bureau'
  📁 Found audio at: Audio/Words/Unite1/Section1/bureau.mp3
🎧 播放完整音频文件: bureau.mp3
```

### 多个单词测试

测试以下单词，确保都能正常播放：

- [ ] bureau (普通单词)
- [ ] table (feminine)
- [ ] éponge (带重音 + 省音)
- [ ] salle de classe (带空格，文件名：salle-de-classe.mp3)
- [ ] ordinateur (省音：l'ordinateur)

---

## 📞 仍然有问题？

如果完成所有步骤后仍然有问题，提供以下信息：

1. **控制台完整日志**（点击单词时的输出）
2. **Build Phases 截图**（Copy Bundle Resources 部分）
3. **文件列表**：
   ```bash
   ls -la VocFr/Resources/Audio/Words/Unite1/Section1/
   ```
4. **Git 状态**：
   ```bash
   git log -1 --oneline
   ```

---

**最后更新**: 2025-11-12
**对应代码**: commit cd94d34
