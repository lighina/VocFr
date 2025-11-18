# Xcode Audio Files Setup - 修复重复文件名冲突

## 问题描述

当多个Unite中包含相同单词（如 aimer、avoir 等）时，如果单独添加每个.mp3文件到Xcode项目，在构建时会产生冲突：

```
error: Multiple commands produce '/Users/.../VocFr.app/aimer.mp3'
    note: from Unite2/Section4/aimer.mp3
    note: from Unite3/Section4/aimer.mp3
```

## 根本原因

- 单独添加文件时，Xcode会将所有文件扁平化复制到app bundle的根目录
- 重复的文件名会产生冲突
- AudioPlayerManager需要完整的目录结构来定位正确的文件

## 解决方案：使用 Folder Reference

### 步骤 1: 删除现有的音频文件引用

1. 在Xcode左侧Project Navigator中，找到所有已添加的.mp3文件
2. 选中所有Audio相关的文件和文件夹
3. 右键点击 → Delete → **Remove Reference**（不要选择"Move to Trash"）

### 步骤 2: 以Folder Reference方式添加

1. 在Xcode中，右键点击 `VocFr/Resources` 文件夹
2. 选择 **Add Files to "VocFr"...**
3. 导航到 `VocFr/Resources/Audio/Words` 文件夹
4. **重要**：在对话框底部，找到 "Added folders" 选项：
   - 选择 **"Create folder references"**（蓝色文件夹图标）
   - **不要**选择 "Create groups"（黄色文件夹图标）
5. 确保勾选 **"Copy items if needed"**
6. Target 选择 **VocFr**
7. 点击 **Add**

### 步骤 3: 验证配置

添加后，在Project Navigator中应该看到：

```
VocFr/
  Resources/
    Audio/
      Words/              ← 蓝色文件夹图标（folder reference）
        Unite1/
          Section1/
            bureau.mp3
            table.mp3
            ...
          Section2/
            ...
        Unite2/
          ...
        Unite3/
          ...
```

**关键标志**：
- ✅ `Words` 文件夹显示为**蓝色**图标 = Folder Reference（正确）
- ❌ 文件夹显示为**黄色**图标 = Group（会导致扁平化问题）

### 步骤 4: 验证Build Phases

1. 选择项目 → Target "VocFr" → Build Phases
2. 展开 **Copy Bundle Resources**
3. 应该看到 **一条** `Words` 文件夹引用（蓝色图标）
4. **不应该**看到大量单独的.mp3文件

### 步骤 5: Clean Build

```bash
# 在Xcode中:
Product → Clean Build Folder (Shift + Cmd + K)

# 删除模拟器上的旧app
iOS Simulator → Long press app icon → Delete App

# 重新构建
Product → Run (Cmd + R)
```

## Folder Reference vs Group 的区别

| 特性 | Folder Reference (蓝色) | Group (黄色) |
|------|-------------------------|--------------|
| Bundle结构 | 保持目录结构 | 扁平化所有文件 |
| 文件路径 | `Audio/Words/Unite1/Section1/bureau.mp3` | `bureau.mp3` |
| 重复文件名 | ✅ 允许（在不同目录） | ❌ 冲突 |
| AudioPlayerManager | ✅ 兼容 | ❌ 不兼容 |

## 验证音频文件路径

在app运行时，检查日志输出：

```
🎵 Playing audio for word: 'bureau'
  📁 Found audio at: Audio/Words/Unite1/Section1/bureau.mp3
  ✅ Found independent audio: Audio/Words/Unite1/Section1/bureau.mp3
```

路径应该包含完整的 `Unite{N}/Section{M}` 结构。

## 常见问题

### Q: 构建后仍然报错？
A: 确保执行了Clean Build并删除了模拟器上的旧app。

### Q: 文件夹是黄色的，如何改成蓝色？
A: 删除引用后重新添加，这次选择 "Create folder references"。

### Q: AudioPlayerManager找不到文件？
A: 检查文件夹引用是否正确，路径应该是 `Audio/Words/Unite{N}/Section{M}/{word}.mp3`。

### Q: 为什么不单独添加每个文件？
A: 因为：
1. 重复的文件名会冲突（aimer、avoir等在多个Unite中出现）
2. AudioPlayerManager需要目录结构来区分不同Unite的同名单词
3. 维护困难（228个文件 × 每次更新）

## 验证最终结果

### 1. 构建成功
```
Build succeeded    13/11/2025, 03:00    1.2 seconds
```

### 2. 日志显示正确路径
```
📁 Found audio at: Audio/Words/Unite2/Section4/aimer.mp3    (Unite 2)
📁 Found audio at: Audio/Words/Unite3/Section4/aimer.mp3    (Unite 3)
```

### 3. 播放正确的音频
- Unite 2 Section 4 的 "aimer" 播放对应文件
- Unite 3 Section 4 的 "aimer" 播放对应文件
- 两个文件互不冲突

## 总结

✅ 使用 **Folder Reference** 添加 `Audio/Words` 文件夹
❌ 不要单独添加每个.mp3文件
✅ 保持 `Unite{N}/Section{M}` 目录结构
✅ Clean Build + 删除旧app后测试
