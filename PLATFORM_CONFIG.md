# VocFr Platform Configuration Guide

## Issue: macOS Compilation Errors

如果您在编译时遇到与 `AVAudioSession` 相关的 macOS 错误，这是因为项目配置支持多平台（包括 macOS），但 VocFr 是一个 **iOS 专用应用**。

## 已修复的问题

✅ `AudioPlayerManager.swift` 已添加平台条件编译，现在可以在 macOS 目标下编译（虽然不推荐）

## 推荐解决方案：限制项目为 iOS 专用

### 方法 1: 在 Xcode 中选择正确的目标（临时解决方案）

在 Xcode 顶部工具栏中：
1. 点击目标选择器（scheme selector）
2. 选择 **iPhone 模拟器**（如 iPhone 15）或 **真机**
3. **不要**选择 "My Mac" 或 "My Mac (Designed for iPad)"

### 方法 2: 修改项目设置为仅支持 iOS（推荐）

#### 步骤：

1. **在 Xcode 中打开项目**
   ```bash
   open VocFr.xcodeproj
   ```

2. **选择项目设置**
   - 在左侧导航栏点击 "VocFr" 项目（蓝色图标）
   - 选择 "VocFr" target（在 TARGETS 下）

3. **修改 Supported Destinations**
   - 找到 "General" 标签页
   - 在 "Supported Destinations" 部分
   - **取消勾选**：
     - ❌ Mac
     - ❌ Mac Catalyst
     - ❌ Apple Vision
   - **保留勾选**：
     - ✅ iPhone
     - ✅ iPad

4. **修改 Deployment Info**
   - 在 "General" 标签页中找到 "Deployment Info"
   - 设置：
     - **iOS Deployment Target**: 18.0（或更低版本如 17.0）
     - **Devices**: iPhone and iPad

5. **清理构建文件夹**
   - 在 Xcode 菜单中：`Product` → `Clean Build Folder` (Shift+Cmd+K)

6. **重新构建**
   - 按 `Cmd+B` 构建项目
   - 应该不再有 macOS 相关错误

### 方法 3: 手动编辑项目配置（高级用户）

如果您熟悉 Xcode 项目文件，可以直接编辑：

1. 关闭 Xcode
2. 编辑 `VocFr.xcodeproj/project.pbxproj`
3. 查找 `SUPPORTED_PLATFORMS` 并修改为：
   ```
   SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
   ```
   （移除 `macosx xros xrsimulator`）
4. 查找 `TARGETED_DEVICE_FAMILY` 确保为：
   ```
   TARGETED_DEVICE_FAMILY = "1,2";
   ```
   （1=iPhone, 2=iPad）
5. 保存并重新打开 Xcode

## 验证修复

### 编译测试

```bash
# 选择 iOS 模拟器
# 在 Xcode 中按 Cmd+B 构建

# 或使用命令行（需要先安装 xcodebuild）
xcodebuild -scheme VocFr -destination 'platform=iOS Simulator,name=iPhone 15' clean build
```

### 预期结果

- ✅ 无编译错误
- ✅ 所有 25 个 issues 应该消失
- ✅ 应用可以在 iOS 模拟器或真机上运行

## 平台特性说明

### iOS 专用 APIs

VocFr 使用以下 iOS 专用功能：
- **AVAudioSession**: iOS 音频会话管理
- **SwiftData**: 虽然跨平台，但项目针对 iOS 优化
- **SwiftUI**: 针对 iOS 界面设计

### 为什么不支持 macOS？

1. **AVAudioSession 不可用**: 音频管理 API 完全不同
2. **触摸交互**: UI 设计基于触摸手势
3. **设备特性**: 利用了 iPhone/iPad 特有功能
4. **项目目标**: 专为移动学习场景设计

## 常见问题

### Q: 为什么项目配置中有 macOS？

A: 这可能是 Xcode 创建项目时的默认设置。新版 Xcode 会自动添加多平台支持。

### Q: 我需要 Mac Catalyst 版本吗？

A: 目前不需要。VocFr 专注于原生 iOS 体验。

### Q: 可以支持 Apple Vision Pro 吗？

A: 理论上可以，但需要额外的适配工作。目前暂不支持。

## 相关文件

- `AudioPlayerManager.swift`: 已添加平台条件编译
- `VocFr.xcodeproj/project.pbxproj`: 项目配置文件

## 更新日志

| 日期 | 版本 | 变更 |
|------|------|------|
| 2025-11-11 | 1.0 | 初始文档，修复 macOS 编译错误 |

---

**需要帮助？** 如果按照以上步骤仍有问题，请提供：
1. Xcode 版本
2. 完整的错误日志
3. 当前选择的编译目标
