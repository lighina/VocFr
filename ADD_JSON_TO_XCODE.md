# 将 vocabulary.json 添加到 Xcode 项目

## 问题诊断

vocabulary.json 显示为灰色且无法添加，这说明：
- 文件在文件系统中存在
- 但尚未正确添加到 Xcode 项目的 Build Phases 中

## 解决方案 1：直接添加到 Copy Bundle Resources（推荐）

### 步骤 1：打开 Build Phases
1. 在 Xcode 中，点击左侧 Project Navigator 最顶部的项目名称 **VocFr**（蓝色图标）
2. 确保选中了 **TARGETS** 下的 **VocFr**（不是 PROJECT）
3. 点击顶部的 **Build Phases** 标签

### 步骤 2：添加到 Copy Bundle Resources
1. 找到 **Copy Bundle Resources** 部分（可能需要展开）
2. 点击左下角的 **+** 按钮
3. 在弹出的文件选择器中，您会看到项目文件列表
4. **如果看不到 vocabulary.json**：
   - 点击底部的 **Add Other...** 按钮
   - 导航到：`VocFr/VocFr/Data/JSON/vocabulary.json`
   - 选择文件
   - 在弹出的对话框中：
     - ✅ 勾选 **"Added folders: Create groups"**（而不是 Create folder references）
     - ✅ 勾选 **"Add to targets: VocFr"**
   - 点击 **Add**

### 步骤 3：验证文件已添加
1. 回到 **Build Phases** → **Copy Bundle Resources**
2. 确认列表中出现 `vocabulary.json`
3. 确认旁边没有红色或黄色警告图标

## 解决方案 2：通过 Project Navigator 强制添加

### 方法 A：删除文件夹引用并重新添加

1. **删除文件夹引用（不删除实际文件）**
   - 在 Project Navigator 中找到 `Data/JSON` 文件夹
   - 右键点击 → **Delete**
   - 在弹出对话框中选择 **"Remove Reference"**（不要选择 Move to Trash）

2. **重新添加文件夹**
   - 右键点击 `Data` 文件夹
   - 选择 **"Add Files to VocFr..."**
   - 导航到 `VocFr/Data/JSON` 文件夹
   - 选择整个 **JSON 文件夹**
   - 在底部的选项中：
     - ✅ 勾选 **"Copy items if needed"**
     - ✅ 选择 **"Create groups"**（不是 Create folder references）
     - ✅ 勾选 **"Add to targets: VocFr"**
   - 点击 **Add**

### 方法 B：直接拖拽文件

1. **在 Finder 中打开项目文件夹**
   - 在终端中运行：`open VocFr/VocFr/Data/JSON`
   - 或在 Xcode 中右键点击 `FrenchWord.swift` → **Show in Finder**
   - 导航到 `Data/JSON` 文件夹

2. **拖拽到 Xcode**
   - 将 Finder 中的 `vocabulary.json` 文件
   - 拖拽到 Xcode Project Navigator 中的 `Data/JSON` 文件夹位置
   - 在弹出对话框中：
     - ✅ 勾选 **"Copy items if needed"**
     - ✅ 选择 **"Create groups"**
     - ✅ 勾选 **"Add to targets: VocFr"**
   - 点击 **Finish**

## 解决方案 3：手动编辑 project.pbxproj（高级）

如果上述方法都不起作用，我可以帮您直接修改项目文件。

## 验证配置是否成功

### 检查 1：Build Phases
```
Target: VocFr
→ Build Phases
  → Copy Bundle Resources
    → ✅ vocabulary.json 应该在列表中
```

### 检查 2：文件颜色
- 在 Project Navigator 中，`vocabulary.json` 应该显示为**白色或黑色**（正常）
- 不应该是灰色（未添加到 target）
- 不应该是红色（找不到文件）

### 检查 3：文件 Inspector
1. 在 Project Navigator 中选中 `vocabulary.json`
2. 打开右侧的 **File Inspector**（右上角最左边的图标）
3. 在 **Target Membership** 部分
4. 确认 **VocFr** 被勾选 ✅

## 测试配置

配置完成后：
1. **Clean Build Folder**：`Product` → `Clean Build Folder` (Shift+Cmd+K)
2. **Build**：`Product` → `Build` (Cmd+B)
3. 如果构建成功，运行 App
4. 查看控制台输出，应该看到：
   ```
   📖 Loading vocabulary data from JSON...
   ✅ Successfully loaded 3 unités from JSON
   ```

## 如果仍然看到 "File not found" 错误

创建一个测试来验证 Bundle 配置：

在 `VocFr/VocFrApp.swift` 或任何 View 的 `onAppear` 中添加：

```swift
// 测试：检查 JSON 文件是否在 bundle 中
if let jsonURL = Bundle.main.url(forResource: "vocabulary", withExtension: "json") {
    print("✅ vocabulary.json 找到了：\(jsonURL)")
} else {
    print("❌ vocabulary.json 未找到在 bundle 中")

    // 列出 bundle 中所有资源
    if let resourcePath = Bundle.main.resourcePath {
        print("📦 Bundle 资源路径：\(resourcePath)")
        let fileManager = FileManager.default
        if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
            print("📄 Bundle 中的文件：")
            for file in files.prefix(20) {
                print("  - \(file)")
            }
        }
    }
}
```

## 常见错误

### 错误 1：文件夹引用而不是 Group
- **现象**：文件夹是蓝色图标（folder reference）
- **解决**：删除引用，重新添加时选择 "Create groups"

### 错误 2：未添加到 Target
- **现象**：文件是灰色
- **解决**：在 File Inspector 中勾选 "VocFr" target

### 错误 3：文件路径错误
- **现象**：文件是红色
- **解决**：删除引用，重新添加文件

## 需要帮助？

如果以上方法都不起作用，请告诉我：
1. vocabulary.json 在 Project Navigator 中的显示颜色（黑/白/灰/红）
2. File Inspector → Target Membership 的状态
3. Build Phases → Copy Bundle Resources 中是否有 vocabulary.json
4. 运行 App 时控制台的完整错误信息

我可以帮您手动修改项目配置文件。
