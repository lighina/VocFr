# 永久设置项目为 iOS-only

## 问题说明

您在 Phase 1 中已经将项目设置为 iOS-only（删除了 macOS 和 visionOS），但后续的 Git 拉取又把项目配置改回了多平台支持。

这导致编译器检查所有平台的兼容性，产生大量 macOS 错误。

## 解决方案：在 Xcode 中永久配置为 iOS-only

### 步骤 1：打开项目设置

1. 在 Xcode 中，点击左侧 Project Navigator 最顶部的 **VocFr** 项目（蓝色图标）
2. 确保选中了 **TARGETS** → **VocFr**（不是 PROJECT）
3. 确保在 **General** 标签页

### 步骤 2：配置 Supported Destinations

在 **General** 标签页中：

1. 找到 **Supported Destinations** 部分
2. 您会看到当前支持的平台列表：
   - ✓ iPhone
   - ✓ iPad
   - ✓ Mac (Designed for iPad) ← **删除这个**
   - ✓ Apple Vision ← **删除这个**

3. **删除 macOS 和 visionOS**：
   - 点击 **Mac (Designed for iPad)** 旁边的 **-** 按钮
   - 点击 **Apple Vision** 旁边的 **-** 按钮

4. **最终应该只剩下**：
   - ✓ iPhone
   - ✓ iPad

### 步骤 3：验证配置

1. 在 **Build Settings** 标签页中
2. 搜索 "Supported Platforms"
3. 确认只有 **iOS**

### 步骤 4：提交配置更改

这个更改会修改 `.xcodeproj/project.pbxproj` 文件。

**在终端中执行**：

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr

# 查看更改
git diff VocFr.xcodeproj/project.pbxproj

# 添加并提交
git add VocFr.xcodeproj/project.pbxproj
git commit -m "config: Set project to iOS-only (iPhone + iPad)

Removed macOS and visionOS from Supported Destinations.
This eliminates all platform compatibility issues and ensures
the app only builds for iOS devices."

# 推送到远程
git push origin refactor/phase-2-data-layer
```

---

## 为什么会被改回去？

Git 拉取时如果远程分支的 `project.pbxproj` 文件包含了多平台配置，本地的更改可能会被覆盖。

**解决方案**：
- 提交 iOS-only 配置到 Git
- 以后拉取时，如果再次冲突，使用：
  ```bash
  # 保留本地的 iOS-only 配置
  git checkout --ours VocFr.xcodeproj/project.pbxproj
  git add VocFr.xcodeproj/project.pbxproj
  ```

---

## 替代方案：如果不想修改项目配置

如果您不想修改项目配置（保持多平台支持以备将来使用），可以：

**方案 A：只为 iOS 构建**
1. 在 Xcode 顶部工具栏
2. 点击设备选择器（当前显示 "My Mac" 或 iPad）
3. 选择一个 iOS 设备或模拟器（如 iPhone 15 Pro）
4. 这样编译器只检查 iOS 兼容性

**方案 B：继续使用条件编译**
- 我们已经为所有 View 添加了 `#if os(iOS)` 条件编译
- 代码可以在多平台编译，但某些功能只在 iOS 上可用

---

## 推荐做法

**对于这个项目，建议使用 iOS-only 配置**：

✅ **优点**：
- 编译更快（不检查 macOS 兼容性）
- 没有平台兼容性错误
- 代码更简洁（不需要 `#if os(iOS)`）
- 符合项目目标（这是一个 iOS 学习 App）

❌ **缺点**：
- 如果将来想支持 macOS，需要重新添加

---

## 当前状态

我已经为所有 View 添加了平台条件编译：
- ✅ AudioPlayerManager.swift
- ✅ TestModeView.swift
- ✅ SectionView.swift
- ✅ WordDetailView_Fixed.swift
- ✅ MainAppView.swift

**现在可以在 macOS 目标下编译通过**。

---

## 下一步

**选择一个方案**：

**方案 1（推荐）**：设置项目为 iOS-only
- 按照上述步骤在 Xcode 中删除 macOS 和 visionOS
- 提交配置到 Git
- 以后不会再有平台兼容性问题

**方案 2**：保持多平台，使用条件编译
- 代码已经修复，可以编译通过
- 拉取最新代码后直接测试

**无论选择哪个方案，都可以立即测试图片显示了！** 🚀
