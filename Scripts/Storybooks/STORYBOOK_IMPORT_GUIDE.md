# Storybook 资源导入指南

> **版本**: 1.0
> **更新日期**: 2025-11-18

---

## 📋 目录

1. [准备工作](#准备工作)
2. [资源组织](#资源组织)
3. [导入步骤](#导入步骤)
4. [Xcode集成](#xcode集成)
5. [常见问题](#常见问题)

---

## 准备工作

### 1. 所需资源

为导入一本故事书，您需要准备以下资源：

| 资源类型 | 文件名格式 | 数量 | 说明 |
|---------|-----------|------|------|
| 封面图片 | `cover.png` | 1个 | 故事书封面 |
| 页面插图 | `page1.png`, `page2.png`, ... | 4-10个 | 每页的插图 |
| 页面音频 | `story_unite{N}_page{M}.mp3` | 4-10个 | 每页的法语朗读音频 |
| 文本内容 | `transcript.txt` | 1个 | 包含所有页面的法语和中文文本 |

### 2. transcript.txt 格式

`transcript.txt` 文件包含所有页面的文本内容，支持两种格式：

#### 格式 A：标记格式（推荐）

```text
=== Page 1 ===
[FR] Bonjour ! Je m'appelle Sophie. Aujourd'hui, c'est mon premier jour à l'école.
[ZH] 你好！我叫索菲。今天是我在学校的第一天。

=== Page 2 ===
[FR] Voici ma classe. Je vois un bureau, une chaise et un tableau noir.
[ZH] 这是我的教室。我看到一张课桌、一把椅子和一块黑板。

=== Page 3 ===
[FR] Dans mon sac, j'ai un cahier, un stylo, un crayon et une gomme.
[ZH] 在我的书包里，我有一个笔记本、一支钢笔、一支铅笔和一块橡皮。
```

#### 格式 B：简单格式

```text
=== Page 1 ===
Bonjour ! Je m'appelle Sophie. Aujourd'hui, c'est mon premier jour à l'école.
你好！我叫索菲。今天是我在学校的第一天。

=== Page 2 ===
Voici ma classe. Je vois un bureau, une chaise et un tableau noir.
这是我的教室。我看到一张课桌、一把椅子和一块黑板。
```

**规则**：
- 每页以 `=== Page N ===` 标记开始
- 法语文本在前，中文翻译在后
- 空行自动忽略

---

## 资源组织

### 创建资源文件夹

为每本故事书创建一个独立的文件夹，包含所有资源：

```
storybook_unite1_book1/
├── cover.png                      # 封面
├── page1.png                      # 第1页插图
├── page2.png                      # 第2页插图
├── page3.png
├── page4.png
├── page5.png
├── page6.png
├── story_unite1_page1.mp3         # 第1页音频
├── story_unite1_page2.mp3         # 第2页音频
├── story_unite1_page3.mp3
├── story_unite1_page4.mp3
├── story_unite1_page5.mp3
├── story_unite1_page6.mp3
└── transcript.txt                 # 文本内容
```

### 文件命名规范

#### 图片文件

- **封面**: `cover.png`
- **页面插图**: `page1.png`, `page2.png`, `page3.png`, ...
- **格式**: PNG
- **建议尺寸**: 800x600 或 1024x768

#### 音频文件

- **命名格式**: `story_unite{N}_page{M}.mp3`
  - `{N}`: Unite编号（1, 2, 3...）
  - `{M}`: 页码（1, 2, 3...）
- **示例**:
  - Unite 1, Page 1: `story_unite1_page1.mp3`
  - Unite 2, Page 3: `story_unite2_page3.mp3`
- **格式**: MP3
- **建议参数**: 128kbps, 44.1kHz, Mono

---

## 导入步骤

### 步骤 1: 准备资源文件夹

```bash
# 示例：准备Unite 1的第1本书（默认故事书）
mkdir -p ~/Desktop/storybook_unite1_book1

# 将所有资源文件复制到这个文件夹
# - cover.png
# - page1.png ~ page6.png
# - story_unite1_page1.mp3 ~ story_unite1_page6.mp3
# - transcript.txt
```

### 步骤 2: 运行导入脚本

#### 导入默认故事书（Test解锁）

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr

python import_storybook.py \
    --source ~/Desktop/storybook_unite1_book1 \
    --unite 1 \
    --book 1 \
    --title-fr "À l'école - Mon premier jour" \
    --title-zh "在学校 - 我的第一天" \
    --default
```

#### 导入额外故事书（10💎解锁）

```bash
python import_storybook.py \
    --source ~/Desktop/storybook_unite1_book2 \
    --unite 1 \
    --book 2 \
    --title-fr "Les couleurs de ma classe" \
    --title-zh "我的教室的颜色" \
    --gems 10
```

### 步骤 3: 预览模式（可选）

在正式导入前，可以使用 `--dry-run` 参数预览导入结果：

```bash
python import_storybook.py \
    --source ~/Desktop/storybook_unite1_book1 \
    --unite 1 \
    --book 1 \
    --title-fr "À l'école - Mon premier jour" \
    --title-zh "在学校 - 我的第一天" \
    --default \
    --dry-run
```

### 命令行参数说明

| 参数 | 简写 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| `--source` | `-s` | ✅ | 源资源目录路径 | `~/Desktop/storybook_unite1_book1` |
| `--unite` | `-u` | ✅ | Unite编号 (1-6) | `1` |
| `--book` | `-b` | ✅ | Book编号 (1, 2, 3...) | `1` |
| `--title-fr` | - | ✅ | 法语标题 | `"À l'école"` |
| `--title-zh` | - | ✅ | 中文标题 | `"在学校"` |
| `--default` | - | ❌ | 是否为默认故事书 | - |
| `--gems` | - | ❌ | 所需宝石数量（默认10） | `10` |
| `--project` | `-p` | ❌ | 项目根目录（默认当前目录） | `.` |
| `--dry-run` | - | ❌ | 预览模式，不实际导入 | - |

---

## Xcode集成

导入脚本会自动复制资源文件到正确的位置，但仍需手动在Xcode中添加这些文件到项目。

### 步骤 1: 添加图片到 Assets.xcassets

1. 打开 Xcode，选择项目中的 `Assets.xcassets`
2. 右键点击空白处，选择 "New Image Set"
3. 按照以下命名规范创建图片集：
   - 封面：`storybook_unite{N}_book{M}_cover`
   - 页面：`storybook_unite{N}_book{M}_page{N}`

**示例（Unite 1, Book 1）**：

| 图片集名称 | 源文件 | 存储位置 |
|-----------|--------|----------|
| `storybook_unite1_book1_cover` | `VocFr/Resources/Images/Storybooks/Unite1/Book1/cover.png` | Assets.xcassets |
| `storybook_unite1_book1_page1` | `VocFr/Resources/Images/Storybooks/Unite1/Book1/page1.png` | Assets.xcassets |
| `storybook_unite1_book1_page2` | `VocFr/Resources/Images/Storybooks/Unite1/Book1/page2.png` | Assets.xcassets |
| ... | ... | ... |

### 步骤 2: 添加音频文件到项目

1. 在Xcode中，右键点击 `VocFr/Resources/Audio/Storybooks/` 文件夹
2. 选择 "Add Files to VocFr..."
3. 导航到 `VocFr/Resources/Audio/Storybooks/Unite{N}/Book{M}/`
4. 选择所有音频文件
5. 确保勾选：
   - ✅ "Copy items if needed"
   - ✅ "Create groups"
   - ✅ Target: VocFr

### 步骤 3: 验证 JSON 数据

1. 打开 `VocFr/Data/JSON/Storybooks.json`
2. 确认新故事书已添加到 `storybooks` 数组
3. 检查数据格式是否正确

### 步骤 4: 测试应用

1. 构建并运行应用
2. 导航到 Storybooks 列表
3. 验证：
   - ✅ 故事书显示在列表中
   - ✅ 封面图片正确显示
   - ✅ 点击进入阅读界面
   - ✅ 页面插图正确显示
   - ✅ 音频播放正常
   - ✅ 法语文本正确显示
   - ✅ 解锁机制工作正常

---

## 常见问题

### Q1: 导入后图片不显示？

**原因**: 图片未添加到 Assets.xcassets

**解决方案**:
1. 检查图片是否已复制到 `VocFr/Resources/Images/Storybooks/` 目录
2. 在Xcode中手动添加图片到 Assets.xcassets
3. 确保图片集名称与JSON中的 `imageName` 字段匹配

### Q2: 音频无法播放？

**原因**: 音频文件未添加到Xcode项目或路径不正确

**解决方案**:
1. 检查音频文件是否在 `VocFr/Resources/Audio/Storybooks/` 目录
2. 在Xcode中确认音频文件已添加到项目且关联到正确的target
3. 确保音频文件名与JSON中的 `audioFileName` 字段匹配
4. 检查音频文件格式是否为MP3

### Q3: transcript.txt 解析错误？

**原因**: 文件格式不正确或编码问题

**解决方案**:
1. 确保文件使用UTF-8编码
2. 确保每页使用 `=== Page N ===` 标记
3. 确保法语文本在前，中文翻译在后
4. 检查是否有多余的空行或特殊字符

### Q4: 如何更新已存在的故事书？

直接运行导入脚本，脚本会自动检测并替换现有数据：

```bash
python import_storybook.py \
    --source ~/Desktop/storybook_unite1_book1_updated \
    --unite 1 \
    --book 1 \
    --title-fr "À l'école - Mon premier jour (修订版)" \
    --title-zh "在学校 - 我的第一天 (修订版)" \
    --default
```

### Q5: 如何删除故事书？

1. 手动编辑 `VocFr/Data/JSON/Storybooks.json`
2. 从 `storybooks` 数组中删除对应的故事书对象
3. 在Xcode中删除相关的图片和音频文件
4. 删除 `VocFr/Resources/Images/Storybooks/` 和 `VocFr/Resources/Audio/Storybooks/` 中对应的文件夹

---

## 完整示例

### 示例：导入 Unite 1 的两本故事书

#### 第1本书（默认，Test解锁）

```bash
# 1. 准备资源
mkdir -p ~/Desktop/storybooks/unite1_book1
# 复制资源文件到 ~/Desktop/storybooks/unite1_book1/

# 2. 运行导入
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
python import_storybook.py \
    --source ~/Desktop/storybooks/unite1_book1 \
    --unite 1 \
    --book 1 \
    --title-fr "À l'école - Mon premier jour" \
    --title-zh "在学校 - 我的第一天" \
    --default
```

#### 第2本书（额外，10💎解锁）

```bash
# 1. 准备资源
mkdir -p ~/Desktop/storybooks/unite1_book2
# 复制资源文件到 ~/Desktop/storybooks/unite1_book2/

# 2. 运行导入
python import_storybook.py \
    --source ~/Desktop/storybooks/unite1_book2 \
    --unite 1 \
    --book 2 \
    --title-fr "Les couleurs de ma classe" \
    --title-zh "我的教室的颜色" \
    --gems 10
```

#### 在Xcode中集成

1. 打开Xcode项目
2. 添加图片到 Assets.xcassets:
   - `storybook_unite1_book1_cover`
   - `storybook_unite1_book1_page1` ~ `page6`
   - `storybook_unite1_book2_cover`
   - `storybook_unite1_book2_page1` ~ `page5`
3. 添加音频文件到项目（确保target正确）
4. 运行应用测试

---

## 附录：资源创作建议

### 图片创作

1. **封面设计**:
   - 尺寸：800x600 或 1024x768
   - 风格：儿童插画风格，色彩鲜艳
   - 内容：反映故事主题
   - 工具：Canva, Figma, 或 AI工具（Midjourney, DALL-E）

2. **页面插图**:
   - 尺寸：与封面一致
   - 内容：与该页文本内容相关
   - 风格：保持全书统一
   - 细节：突出关键词汇对应的物品

### 音频录制

1. **录音设备**:
   - 专业麦克风或高质量手机
   - 安静环境，无回声
   - 使用Audacity等软件后期处理

2. **朗读要求**:
   - 标准法语发音
   - 语速：100-120 词/分钟（适合初学者）
   - 吐字清晰，情感适度
   - 每句话之间有0.5-1秒停顿

3. **后期处理**:
   - 降噪处理
   - 音量标准化（-3dB）
   - 导出为MP3（128kbps, 44.1kHz）

### 文本创作

1. **词汇选择**:
   - 使用该Unite 80%以上的核心词汇
   - 避免超纲词汇
   - 重复使用关键词加强记忆

2. **句子结构**:
   - 简单句为主
   - 5-10个单词/句
   - 现在时为主
   - 避免复杂从句

3. **故事情节**:
   - 4-10页为宜
   - 有起承转合
   - 适合儿童/初学者
   - 贴近日常生活场景

---

**最后更新**: 2025-11-18
**维护者**: VocFr开发团队
