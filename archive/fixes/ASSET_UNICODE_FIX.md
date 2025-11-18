# VocFr Asset Unicode Issues - 解决方案

## 问题描述

在 Xcode 中看到 25 个关于图片资源的警告/错误，所有都与包含法语重音字符的图片相关：

```
The file "mère_image.png" for the image set "mère_image" does not exist.
The file "père_image.png" for the image set "père_image" does not exist.
... (等等)
```

## 根本原因

这是一个 **Unicode 规范化（Normalization）** 问题：

### Unicode 的两种规范化形式

1. **NFC (Normalization Form Composed)** - 组合形式
   - 使用单个预组合字符
   - 例如：`é` = U+00E9 (1个字符)
   - **Linux、Windows、Git** 默认使用

2. **NFD (Normalization Form Decomposed)** - 分解形式
   - 使用基本字符 + 组合标记
   - 例如：`é` = `e` (U+0065) + `́` (U+0301) (2个字符)
   - **macOS 文件系统 (HFS+/APFS)** 默认使用

### 为什么会出现问题？

1. 图片文件是在 Linux/Windows 上创建或通过 Git 传输的
2. 文件名使用 **NFC** 编码
3. macOS 文件系统期望 **NFD** 编码
4. Xcode 在 macOS 上运行时找不到 NFC 编码的文件名

### 受影响的文件

所有包含以下法语字符的图片：
- `é` (e with acute): école, écouter, éponge, zéro
- `è` (e with grave): mère, père, grand-mère, grand-père, derrière
- `ê` (e with circumflex): fenêtre, frère
- `ç` (c with cedilla): garçon

## 解决方案

### 方法 1: 使用自动修复脚本（推荐） ✅

我已经创建了一个 Python 脚本来自动修复所有文件名。

#### 步骤：

1. **拉取最新代码**（包含修复脚本）
   ```bash
   cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
   git pull origin claude/ios-swift-xcode-dev-011CUwzqGLNabBQTyCSfmsuh
   ```

2. **运行修复脚本**
   ```bash
   python3 fix_asset_unicode.py
   ```

3. **在 Xcode 中清理并重建**
   - 打开 Xcode: `open VocFr.xcodeproj`
   - 清理构建文件夹: `Product` → `Clean Build Folder` (Shift+Cmd+K)
   - 重新构建: `Product` → `Build` (Cmd+B)

4. **验证修复**
   - 所有 25 个图片错误应该消失
   - 在模拟器中运行应用，图片应该正常显示

#### 脚本做什么？

- ✅ 将所有图片文件名从 NFC 转换为 NFD
- ✅ 修复 `derrièr_image.png` → `derrière_image.png` 拼写错误
- ✅ 保留 Contents.json 配置不变
- ✅ 安全处理所有法语重音字符

### 方法 2: 手动修复（不推荐，仅供参考）

如果不想使用脚本，可以手动在 Xcode 中：

1. 在 Xcode 中右键点击每个有问题的 Image Set
2. 选择 "Show in Finder"
3. 删除旧的 PNG 文件
4. 重新拖入相同的图片（让 macOS 使用 NFD 编码保存文件名）

**注意**: 这种方法非常繁琐，需要处理 12+ 个图片。

### 方法 3: Git 配置（预防未来问题）

在 Mac 上配置 Git 以保持 NFD 编码：

```bash
git config core.precomposeunicode true
```

这会让 Git 在 macOS 上始终使用 NFD 编码。

## 技术细节

### 受影响的图片列表

| 图片名称 | 法语意思 | 问题字符 |
|---------|---------|---------|
| mère_image.png | 母亲 | è |
| père_image.png | 父亲 | è |
| grand-mère_image.png | 祖母 | è |
| grand-père_image.png | 祖父 | è |
| frère_image.png | 兄弟 | è |
| derrière_image.png | 后面 | è (+ 拼写错误) |
| fenêtre_image.png | 窗户 | ê |
| école_image.png | 学校 | é |
| écouter_image.png | 听 | é |
| éponge_image.png | 海绵 | é |
| zéro_image.png | 零 | é |
| garçon_image.png | 男孩 | ç |

### 为什么 Contents.json 不需要修改？

`Contents.json` 文件中的 `"filename"` 字段已经正确使用了 NFC 编码：

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

Xcode 会自动将这个字符串转换为 NFD 来匹配 macOS 文件系统。问题是实际的文件名本身需要是 NFD 编码。

## 常见问题 FAQ

### Q: 为什么只在 macOS 上有这个问题？

A: 因为 macOS 是唯一默认使用 NFD 编码的主流操作系统。Linux 和 Windows 使用 NFC。

### Q: 这会影响 Git 提交吗？

A: 不会。一旦文件名在 macOS 文件系统中正确设置为 NFD，Git 会正确处理。

### Q: 未来如何避免这个问题？

A:
1. 在 macOS 上创建所有资源文件
2. 配置 Git: `git config core.precomposeunicode true`
3. 或者避免在资源文件名中使用非 ASCII 字符

### Q: 为什么不直接重命名图片为英文？

A: 可以，但这需要：
1. 修改所有 Image Set 的 Contents.json
2. 修改代码中引用这些图片的地方
3. 重新组织资源
这是一个更大的重构任务，可以在 Phase 2 中考虑。

## 验证清单

运行修复脚本后，检查：

- [ ] Python 脚本成功运行，显示 "Fixed: X files"
- [ ] Xcode 中清理构建文件夹
- [ ] Xcode 重新构建项目无错误
- [ ] 在 Issues 导航器中，25 个图片错误消失
- [ ] 运行应用，所有法语单词的图片正常显示

## 相关文件

- `fix_asset_unicode.py` - 自动修复脚本
- `VocFr/Assets.xcassets/` - 图片资源目录
- `PLATFORM_CONFIG.md` - 平台配置指南

## 参考资料

- [Unicode Normalization Forms (W3C)](https://www.w3.org/TR/charmod-norm/)
- [Apple Technical Q&A QA1173: Text Encodings in VFS](https://developer.apple.com/library/archive/qa/qa1173/_index.html)
- [Git on macOS: Core.precomposeunicode](https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreprecomposeUnicode)

---

**更新日志**

| 日期 | 版本 | 变更 |
|------|------|------|
| 2025-11-11 | 1.0 | 初始文档和修复脚本 |
