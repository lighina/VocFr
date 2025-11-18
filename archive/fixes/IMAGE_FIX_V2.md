# 图片显示问题 - 最终解决方案

## 问题现状

✅ **已解决**: Xcode 中的 25 个图片错误消失
❌ **待解决**: App 运行时，带重音字符的单词图片不显示

## 根本原因分析

之前的 Unicode 修复脚本只修复了 **PNG 文件名**，但实际上：

1. **SwiftUI 如何加载图片**:
   ```swift
   Image("mère_image")  // 查找 mère_image.imageset 目录
   ```
   SwiftUI 通过 **Image Set 的目录名**来查找，不是里面的 PNG 文件名。

2. **跨平台兼容性问题**:
   - macOS 文件系统使用 NFD 编码
   - Linux/Windows/Git 使用 NFC 编码
   - 即使文件存在，运行时查找可能失败

3. **最佳实践**:
   - **Asset 名称应该只使用 ASCII 字符**
   - 避免所有重音符号、空格、特殊字符
   - 这是 Apple 推荐的做法

## 解决方案

### 新策略：将所有 Image Set 重命名为 ASCII

不再尝试处理 Unicode 规范化问题，而是直接使用纯 ASCII 名称：

| 原名称 | 新名称 |
|--------|--------|
| mère_image | mere_image |
| père_image | pere_image |
| grand-mère_image | grand_mere_image |
| grand-père_image | grand_pere_image |
| frère_image | frere_image |
| derrière_image | derriere_image |
| fenêtre_image | fenetre_image |
| école_image | ecole_image |
| écouter_image | ecouter_image |
| éponge_image | eponge_image |
| zéro_image | zero_image |
| garçon_image | garcon_image |

### 新修复脚本：`fix_image_names.py`

这个脚本会：
1. ✅ 重命名 Image Set 目录（去掉重音）
2. ✅ 更新 Contents.json 中的 PNG 文件名引用
3. ✅ 重命名 Image Set 内的 PNG 文件
4. ✅ 更新 `FrenchWord.swift` 中的所有 imageName 字符串

## 执行步骤

### 1. 暂停推送之前的更改

如果您还没有推送 Python 脚本修改的文件名，现在**不要推送**。我们将用新的修复覆盖它。

如果已经推送了，也没关系，继续执行下面的步骤。

### 2. 拉取新的修复脚本

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
git pull origin claude/ios-swift-xcode-dev-011CUwzqGLNabBQTyCSfmsuh
```

您会看到新文件：
- `fix_image_names.py` - 新的修复脚本
- `IMAGE_FIX_V2.md` - 本文档

### 3. 关闭 Xcode

在运行脚本前关闭 Xcode，避免文件冲突。

```bash
# 如果 Xcode 正在运行，关闭它
killall Xcode 2>/dev/null || true
```

### 4. 运行新的修复脚本

```bash
python3 fix_image_names.py
```

**预期输出**：
```
🛠️  VocFr Image Asset ASCII Name Converter

📁 Renaming Image Set directories...

  ✏️  mère_image.imageset → mere_image.imageset
  ✏️  père_image.imageset → pere_image.imageset
  ... (更多)

📋 Updating Contents.json files...

  ✅ Updated mere_image.imageset/Contents.json
  ✅ Renamed PNG: mère_image.png → mere_image.png
  ... (更多)

📝 Updating VocFr/Data/Seeds/FrenchWord.swift...

  ✅ Replaced 'mère_image' → 'mere_image' (1 occurrences)
  ✅ Replaced 'père_image' → 'pere_image' (1 occurrences)
  ... (更多)

  💾 Saved 12 replacements

✨ Summary:
   Renamed: 12 Image Sets
   Updated: FrenchWord.swift
```

### 5. 删除应用数据

因为数据库中存储了旧的 imageName，需要删除应用重新安装：

**在模拟器中**：
1. 长按 VocFr 应用图标
2. 点击"移除 App" → "删除 App"

或使用命令行：
```bash
xcrun simctl uninstall booted com.yourcompany.VocFr
```

### 6. 在 Xcode 中重建

```bash
# 打开项目
open VocFr.xcodeproj
```

在 Xcode 中：
1. **Clean Build Folder**: `Product` → `Clean Build Folder` (Shift+Cmd+K)
2. **Build**: `Product` → `Build` (Cmd+B)
3. **Run**: `Product` → `Run` (Cmd+R)

### 7. 验证

在模拟器中：
1. 启动应用（会重新生成数据库）
2. 导航到任意单元 → 章节 → 单词详情
3. 检查带重音字符的单词：
   - mère (母亲)
   - père (父亲)
   - école (学校)
   - garçon (男孩)

**所有图片应该正常显示** ✅

### 8. 提交更改到 Git

```bash
git add -A
git status  # 检查更改

git commit -m "fix: Rename Image Sets to ASCII-safe names for cross-platform compatibility"

git push origin claude/ios-swift-xcode-dev-011CUwzqGLNabBQTyCSfmsuh
```

## 技术说明

### 为什么这个方案更好？

1. **完全兼容**：ASCII 名称在所有平台上都一致
2. **无需规范化**：避免 NFC/NFD 转换问题
3. **Apple 最佳实践**：符合官方推荐
4. **易于维护**：未来不会再有类似问题

### 对用户的影响

- ✅ **无影响**：用户看到的仍然是法语原文（数据库中的 `canonical` 和 `chinese` 字段）
- ✅ **仅内部改变**：只是 Asset 的内部名称变了
- ✅ **性能提升**：字符串匹配更快（ASCII vs Unicode）

### Contents.json 示例

**修改前**：
```json
{
  "images" : [
    {
      "filename" : "mère_image.png",
      "idiom" : "universal",
      "scale" : "1x"
    }
  ]
}
```

**修改后**：
```json
{
  "images" : [
    {
      "filename" : "mere_image.png",
      "idiom" : "universal",
      "scale" : "1x"
    }
  ]
}
```

### FrenchWord.swift 示例

**修改前**：
```swift
let unite2Words = [
    "père_image", "mère_image", "frère_image"
]
```

**修改后**：
```swift
let unite2Words = [
    "pere_image", "mere_image", "frere_image"
]
```

## 故障排除

### 问题：脚本报错 "Image Set not found"

**原因**：文件名可能已经被修改过

**解决**：检查 `VocFr/Assets.xcassets/` 目录，看实际的文件夹名称

### 问题：图片仍然不显示

**原因**：数据库中仍保存着旧的 imageName

**解决**：
1. 完全删除应用（不是只关闭）
2. 在 Xcode 中 Clean Build Folder
3. 重新运行应用

### 问题：Xcode 仍显示图片错误

**原因**：Xcode 缓存未清理

**解决**：
```bash
# 清理所有缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# 重启 Xcode
```

## 参考资料

- [Asset Catalog Format Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
- [Unicode Normalization in Swift](https://developer.apple.com/documentation/foundation/nsstring/1413653-decomposedstringwithcanonicalmap)
- [Best Practices for Naming Assets](https://developer.apple.com/design/human-interface-guidelines/foundations/images)

---

**更新日志**

| 日期 | 版本 | 变更 |
|------|------|------|
| 2025-11-11 | 2.0 | 新方案：重命名为 ASCII 名称 |
| 2025-11-11 | 1.0 | 初始 Unicode 规范化方案 |
