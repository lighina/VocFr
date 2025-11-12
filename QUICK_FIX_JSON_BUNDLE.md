# 快速修复：vocabulary.json 未找到错误

## 错误原因

```
Thread 1: Fatal error: 模型容器创建失败: fileNotFound("vocabulary.json not found in bundle")
```

**原因**：`vocabulary.json` 文件在文件系统中存在，但没有被添加到 Xcode 项目的 App Bundle 中。

## 修复步骤（详细图解）

### 第 1 步：拉取最新代码

```bash
cd VocFr
git pull origin refactor/phase-2-data-layer
```

### 第 2 步：在 Xcode 中打开项目

打开 `VocFr.xcodeproj`

### 第 3 步：添加 vocabulary.json 到 Bundle Resources

#### 选项 A：通过 Build Phases（推荐）

1. **点击左侧 Project Navigator 最顶部的蓝色 VocFr 图标**
   ```
   📁 VocFr (最顶部，蓝色项目图标)
   ```

2. **确保选中了正确的 Target**
   - 在中间区域，看到 PROJECT 和 TARGETS 两个部分
   - 点击 **TARGETS** 下的 **VocFr** (不是 VocFrTests 或 VocFrUITests)

3. **点击顶部的 "Build Phases" 标签**
   ```
   General | Signing & Capabilities | Resource Tags | Info | Build Settings | [Build Phases] | Build Rules
                                                                               ^^^^^^^^^^^
                                                                               点击这个
   ```

4. **找到 "Copy Bundle Resources" 部分**
   - 如果它是折叠的，点击左边的三角形展开
   - 您会看到一个文件列表（可能包含 Assets.xcassets, alloy_gpt-4o-mini-tts...wav 等）

5. **点击 "Copy Bundle Resources" 左下角的 + 按钮**
   ```
   ▼ Copy Bundle Resources (X items)
     ├─ Assets.xcassets
     ├─ alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z.wav
     └─ ...
                                                             [+] [-]
                                                              ↑
                                                           点击这里
   ```

6. **在弹出的文件选择器中**：

   **方式 1：如果看到 vocabulary.json**
   - 直接选中它
   - 点击 "Add" 按钮

   **方式 2：如果看不到 vocabulary.json**（最常见）
   - 点击底部的 "Add Other..." 按钮
   - 在文件浏览器中，导航到项目文件夹内的：
     ```
     VocFr/VocFr/Data/JSON/vocabulary.json
     ```
   - 选中 `vocabulary.json` 文件
   - **重要**：在底部的选项中：
     - ✅ 勾选 **"Added folders: Create groups"** (不是 Create folder references)
     - ✅ 勾选 **"Add to targets: VocFr"**
   - 点击 "Add"

7. **验证文件已添加**
   - 返回 "Copy Bundle Resources" 列表
   - 确认 `vocabulary.json` 现在在列表中
   - 确保旁边没有红色或黄色警告图标

#### 选项 B：通过拖拽（更简单但容易出错）

1. **在 Finder 中打开 JSON 文件夹**
   ```bash
   open VocFr/Data/JSON
   ```

2. **准备 Xcode 窗口**
   - 在 Xcode 左侧 Project Navigator 中
   - 找到 `Data/JSON` 文件夹
   - 确保它是展开的

3. **从 Finder 拖拽到 Xcode**
   - 从 Finder 窗口中拖拽 `vocabulary.json` 文件
   - 放到 Xcode Project Navigator 中的 `Data/JSON` 文件夹位置
   - 看到一个绿色的 + 号时松开鼠标

4. **在弹出的对话框中**：
   - ✅ **勾选** "Copy items if needed"
   - ✅ **选择** "Create groups" (单选按钮)
   - ✅ **勾选** "Add to targets: VocFr"
   - 点击 "Finish"

### 第 4 步：验证文件已正确添加

#### 验证 1：检查文件颜色
- 在 Project Navigator 中找到 `vocabulary.json`
- 文件名应该是 **黑色或白色**（正常）
- 如果是 **灰色** → 没有添加到 target，重新执行步骤 3
- 如果是 **红色** → 文件路径错误，删除引用后重新添加

#### 验证 2：检查 Target Membership
1. 在 Project Navigator 中选中 `vocabulary.json`
2. 打开右侧的 **File Inspector** (右上角第一个图标 📄)
3. 向下滚动找到 **Target Membership** 部分
4. 确认 **VocFr** 被勾选 ✅
5. 如果没有勾选，勾选它

#### 验证 3：检查 Copy Bundle Resources
1. 回到 Target → Build Phases → Copy Bundle Resources
2. 确认列表中有 `vocabulary.json`
3. 文件路径应该显示为 `vocabulary.json` 或 `Data/JSON/vocabulary.json`

### 第 5 步：Clean Build 并运行

1. **Clean Build Folder**
   ```
   菜单栏: Product → Clean Build Folder
   快捷键: Shift + Cmd + K
   ```

2. **删除模拟器中的旧 App**
   - 在模拟器中，长按 VocFr App 图标
   - 选择 "Remove App" 并确认
   - 或者在 Xcode 中: Product → Clean Build Folder 后会自动删除

3. **Build 项目**
   ```
   菜单栏: Product → Build
   快捷键: Cmd + B
   ```

4. **运行 App**
   ```
   菜单栏: Product → Run
   快捷键: Cmd + R
   ```

### 第 6 步：查看诊断输出

运行 App 后，打开 Xcode 底部的控制台（Console），您应该看到：

#### 成功的输出（✅ 期望看到这个）：
```
============================================================
🔍 检查 vocabulary.json Bundle 配置
============================================================
✅ vocabulary.json 找到了！
   路径：/Users/.../VocFr.app/vocabulary.json
============================================================

📖 Loading vocabulary data from JSON...
📖 Loaded vocabulary data version: 1.0
📅 Last updated: 2025-11-11
✅ Successfully loaded 3 unités with 228 unique words
✅ Successfully loaded 3 unités from JSON
✅ 成功导入 3 个单元的数据到 SwiftData
成功导入 3 个单元的数据
```

#### 失败的输出（❌ 如果还是这个，说明文件没有正确添加）：
```
============================================================
🔍 检查 vocabulary.json Bundle 配置
============================================================
❌ vocabulary.json 未找到在 bundle 中

📦 尝试查找 bundle 中的所有 JSON 文件：
   ❌ Bundle 中没有任何 .json 文件
============================================================

Thread 1: Fatal error: 模型容器创建失败: fileNotFound("vocabulary.json not found in bundle")
```

## 故障排除

### 问题 1：文件仍然显示为灰色

**解决方案**：
1. 选中 `vocabulary.json` 文件
2. 打开 File Inspector (右侧面板)
3. 找到 Target Membership
4. 勾选 VocFr ✅

### 问题 2：拖拽时没有弹出对话框

**原因**：文件可能已经在项目中但没有添加到 target

**解决方案**：
1. 右键点击 `vocabulary.json` → Delete
2. 选择 "Remove Reference"（不是 Move to Trash）
3. 重新使用选项 A 的方法添加

### 问题 3：Build Phases 中有 vocabulary.json 但还是报错

**检查点**：
1. 文件路径是否正确（不是红色）
2. 文件是否有错误图标
3. 尝试删除后重新添加

### 问题 4：Bundle 中找到了其他 JSON 文件但没有 vocabulary.json

**可能原因**：
- 文件被添加到错误的 target (如 VocFrTests)
- 文件在 "Compile Sources" 而不是 "Copy Bundle Resources"

**解决方案**：
1. Build Phases → Compile Sources → 检查是否错误地添加了 vocabulary.json
2. 如果在，删除它（JSON 文件不应该在 Compile Sources）
3. 重新添加到 Copy Bundle Resources

## 成功的标志

✅ vocabulary.json 文件是黑色/白色（不是灰色）
✅ File Inspector → Target Membership → VocFr 被勾选
✅ Build Phases → Copy Bundle Resources → 包含 vocabulary.json
✅ 控制台输出 "✅ vocabulary.json 找到了！"
✅ App 正常启动，显示所有词汇

## 下一步

一旦看到成功输出：
1. 测试 App 所有功能
2. 验证所有 228 个单词正确加载
3. 确认图片显示正常
4. 报告测试结果

## 需要帮助？

如果完成上述所有步骤后仍然失败，请提供：
1. File Inspector 中 Target Membership 的截图
2. Build Phases → Copy Bundle Resources 的截图
3. 完整的控制台输出（从 🔍 检查 vocabulary.json 开始）
4. vocabulary.json 文件在 Project Navigator 中的显示颜色

---

**最关键的步骤**：将 vocabulary.json 添加到 **Copy Bundle Resources**，并确保 **Target Membership** 勾选了 **VocFr**。
