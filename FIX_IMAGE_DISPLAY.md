# 修复图片显示问题

## 🔍 问题根源

经过诊断，发现：

**✅ Word.imageName 是正确的（ASCII格式）:**
```
éponge → imageName: 'eponge_image'
école → imageName: 'ecole_image'
garçon → imageName: 'garcon_image'
```

**❌ 但 Assets.xcassets 中的 Image Sets 还是带重音的旧名字:**
```
Assets.xcassets/
├── éponge_image.imageset  ← 带重音！
├── école_image.imageset   ← 带重音！
├── garçon_image.imageset  ← 带重音！
```

**结果：**代码查找 `'eponge_image'`，但Assets中只有 `'éponge_image'`，所以图片找不到！

---

## 🔧 解决方案

我已经创建了自动化脚本 `rename_image_assets.sh`，一键重命名所有带重音的 Image Sets。

### 📥 步骤 1：拉取最新代码

在 Mac 终端中执行：

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr
git pull origin refactor/phase-2-data-layer
```

### 🚀 步骤 2：运行重命名脚本

**重要：在运行脚本前，请先关闭 Xcode！**

```bash
# 确保在项目根目录（VocFr/VocFr 的父目录）
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr

# 给脚本执行权限（如果需要）
chmod +x rename_image_assets.sh

# 运行脚本
./rename_image_assets.sh
```

### 📊 期望的脚本输出

```
🔧 开始重命名 Image Sets...
目录: VocFr/Assets.xcassets

✓ 重命名: éponge_image.imageset → eponge_image.imageset
  ✓ 更新 Contents.json
  ✓ 重命名 PNG: éponge_image.png → eponge_image.png
✓ 重命名: école_image.imageset → ecole_image.imageset
  ✓ 更新 Contents.json
  ✓ 重命名 PNG: école_image.png → ecole_image.png
...（共12个）

============================================
✅ 完成！
   重命名: 12 个 Image Sets
   跳过: 0 个 (已重命名或不存在)
============================================
```

### 🔍 步骤 3：在 Xcode 中验证

1. **打开 Xcode**

2. **检查 Assets.xcassets**：
   - 在 Project Navigator 中，点击 `Assets.xcassets`
   - 搜索 "eponge"（不带重音）
   - 应该能找到 `eponge_image`（不是 `éponge_image`）

3. **验证所有重命名的 Image Sets**：
   - eponge_image ✓
   - ecole_image ✓
   - fenetre_image ✓
   - garcon_image ✓
   - mere_image ✓
   - pere_image ✓
   - frere_image ✓
   - grand_mere_image ✓（注意：连字符也变成下划线）
   - grand_pere_image ✓
   - derriere_image ✓
   - zero_image ✓
   - ecouter_image ✓

### 🏗️ 步骤 4：Clean Build 并测试

1. **Clean Build Folder**
   ```
   Product → Clean Build Folder (Shift+Cmd+K)
   ```

2. **删除模拟器中的旧 App**
   - 在模拟器中长按 VocFr App 图标 → Remove App

3. **运行 App**
   ```
   Product → Run (Cmd+R)
   ```

4. **测试图片显示**：
   - 打开 "Unité 1" → "à l'école"
   - 找到以下单词，确认图片显示：
     - ✓ éponge（海绵）
     - ✓ école（学校）
     - ✓ fenêtre（窗户）
     - ✓ garçon（男孩）

---

## ✅ 成功标志

### App 界面中：
- ✅ éponge、école、garçon 等单词的图片正常显示（不是灰色占位符）
- ✅ 所有带重音的法语单词图片都能正常加载
- ✅ 图片清晰，没有错误

### 控制台输出：
```
🔍 诊断：检查单词的 imageName 属性
============================================================
总共加载了 188 个单词

检查带重音的关键单词:
✓ éponge
  - imageName: 'eponge_image'  ← ASCII格式
  - chinese: 海绵
✓ école
  - imageName: 'ecole_image'   ← ASCII格式
  - chinese: 学校
...
```

---

## 🔄 如果脚本运行失败

### 问题 1：Permission denied

**解决方案**：
```bash
chmod +x rename_image_assets.sh
```

### 问题 2：找不到 Assets.xcassets 目录

**原因**：不在项目根目录

**解决方案**：
```bash
# 确保在正确的目录
pwd
# 应该显示：/Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr

# 如果不对，cd 到正确的目录
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr
```

### 问题 3：某些 Image Sets 已经重命名了

**现象**：
```
⊘ 跳过 (不存在): éponge_image.imageset
```

**解决方案**：这是正常的！说明该 Image Set 已经被重命名过了。

---

## 📋 重命名清单

| 原名称（带重音） | 新名称（ASCII） | 状态 |
|----------------|----------------|------|
| éponge_image | eponge_image | ⏳ |
| école_image | ecole_image | ⏳ |
| fenêtre_image | fenetre_image | ⏳ |
| garçon_image | garcon_image | ⏳ |
| mère_image | mere_image | ⏳ |
| père_image | pere_image | ⏳ |
| frère_image | frere_image | ⏳ |
| grand-mère_image | grand_mere_image | ⏳ |
| grand-père_image | grand_pere_image | ⏳ |
| derrière_image | derriere_image | ⏳ |
| zéro_image | zero_image | ⏳ |
| écouter_image | ecouter_image | ⏳ |

运行脚本后，所有状态应该变为 ✅

---

## 🎯 为什么会出现这个问题？

在 Phase 1 中，我们重命名了这些 Image Sets 来避免 Unicode 规范化问题（NFC vs NFD）。

但在当前的 Phase 2 分支中，Assets 可能还没有包含 Phase 1 的这些更改，所以需要重新运行重命名脚本。

---

## 📞 需要帮助？

如果运行脚本后图片还是不显示，请提供：
1. 脚本的完整输出
2. Xcode Assets.xcassets 的截图（显示 eponge_image 等）
3. App 运行时的控制台输出（特别是诊断部分）

我会帮您进一步调试！
