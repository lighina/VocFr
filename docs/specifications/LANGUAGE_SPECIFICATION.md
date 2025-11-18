# VocFr语言规范文档

> **创建日期**: 2025-11-17
> **版本**: 1.0
> **维护者**: Development Team

## 📋 目录

- [概述](#概述)
- [支持的语言](#支持的语言)
- [本地化架构](#本地化架构)
- [翻译规范](#翻译规范)
- [图标规范](#图标规范)
- [UI文本规范](#ui文本规范)
- [更新流程](#更新流程)

---

## 概述

VocFr是一个多语言法语学习应用，支持7种界面语言。本文档定义了应用中所有语言相关的规范和标准。

### 设计原则

1. **一致性** - 所有语言版本的UI和功能保持一致
2. **可维护性** - 使用自动化工具管理翻译
3. **可扩展性** - 易于添加新语言和新功能
4. **质量保证** - 所有翻译经过验证和测试

---

## 支持的语言

| 语言代码 | 语言名称 | 本地名称 | 状态 | 翻译完成度 |
|---------|---------|---------|------|----------|
| `en` | English | English | ✅ 完整 | 100% (307 keys) |
| `zh-Hans` | Chinese (Simplified) | 简体中文 | ✅ 完整 | 100% (307 keys) |
| `fr` | French | Français | ✅ 完整 | 100% (307 keys) |
| `es` | Spanish | Español | ✅ 完整 | 100% (307 keys) |
| `de` | German | Deutsch | ✅ 完整 | 100% (307 keys) |
| `it` | Italian | Italiano | ✅ 完整 | 100% (307 keys) |
| `pt` | Portuguese | Português | ✅ 完整 | 100% (307 keys) |

### 文件结构

```
VocFr/
├── en.lproj/
│   └── Localizable.strings       # 英语翻译
├── zh-Hans.lproj/
│   └── Localizable.strings       # 简体中文翻译
├── fr.lproj/
│   └── Localizable.strings       # 法语翻译
├── es.lproj/
│   └── Localizable.strings       # 西班牙语翻译
├── de.lproj/
│   └── Localizable.strings       # 德语翻译
├── it.lproj/
│   └── Localizable.strings       # 意大利语翻译
└── pt.lproj/
    └── Localizable.strings       # 葡萄牙语翻译
```

---

## 本地化架构

### 命名约定

所有本地化key遵循以下命名规范：

```
<功能模块>.<具体页面/组件>.<描述>
```

**示例**:
- `main.study.title` - 主页面的学习模式标题
- `test.result.score` - 测试结果页面的分数
- `menu.games.description` - 菜单中游戏的描述

### Key分类

| 前缀 | 用途 | 示例 |
|------|------|------|
| `main.*` | 主页面 | `main.select.mode` |
| `menu.*` | 菜单系统 | `menu.settings.title` |
| `test.*` | 测试模式 | `test.question.imageToWord` |
| `game.mode.*` | 游戏模式 | `game.mode.choose.game` |
| `games.*` | 游戏列表 | `games.unlock.message` |
| `storybooks.*` | 故事书 | `storybooks.subtitle` |
| `hangman.*` | 吊人游戏 | `hangman.remaining.tries` |
| `matching.*` | 配对游戏 | `matching.game.instruction` |
| `progress.*` | 进度追踪 | `progress.total.stars` |
| `settings.*` | 设置 | `settings.language` |
| `common.*` | 通用文本 | `common.done`, `common.cancel` |

---

## 翻译规范

### 占位符

翻译中必须保持占位符不变：

| 占位符 | 类型 | 示例 |
|--------|------|------|
| `%@` | 字符串 | `"Unité %@"` → `"Unité 1"` |
| `%d` | 整数 | `"%d stars"` → `"5 stars"` |
| `%1$@` | 位置参数 (字符串) | `"Unlock \"%1$@\" for %2$d gems?"` |
| `%2$d` | 位置参数 (整数) | 同上 |
| `%%` | 百分号转义 | `"%d%%"` → `"80%"` |

**重要**: 位置参数 (`%1$@`, `%2$d`) 用于可能需要调整参数顺序的语言。

### 语言特定规则

#### 法语 (fr)
- **标点符号前空格**: 冒号、分号、问号、感叹号前需要空格
  - ✅ 正确: `"Quel est le mot ?"`
  - ❌ 错误: `"Quel est le mot?"`
- **引号**: 使用guillemets `« »` 或普通引号 `" "`
  - 示例: `"Dépenser 50 💎 pour déverrouiller « Hangman » ?"`

#### 西班牙语 (es)
- **倒置标点**: 问号和感叹号需要开闭符号
  - ✅ 正确: `"¿Cuál es la palabra?"`, `"¡Perfecto!"`
  - ❌ 错误: `"Cuál es la palabra?"`, `"Perfecto!"`

#### 德语 (de)
- **名词大写**: 所有名词首字母必须大写
  - ✅ 正确: `"Französisch lernen"`
  - ❌ 错误: `"französisch lernen"`
- **复合词**: 德语常用复合词，UI需要考虑较长的文本
  - 示例: `"Rechtschreibung"` (拼写), `"Ausgezeichnet"` (优秀)

#### 葡萄牙语 (pt)
- **变音符号**: 正确使用 ã, õ, ç, á, é, í, ó, ú 等
  - 示例: `"Precisão"` (精度), `"Ortografia"` (拼写)

#### 意大利语 (it)
- **撇号**: 正确使用缩写撇号
  - 示例: `"un'unità"`, `"l'ortografia"`

---

## 图标规范

### 主页面图标规范

主页面（MainAppView）使用**非填充版本**的图标：

| 功能 | 图标名称 | 颜色 |
|------|---------|------|
| 学习 (Study) | `book.closed` | 蓝色 (.blue) |
| 测试 (Test) | `doc.text` | 绿色 (.green) |
| 游戏 (Game) | `gamecontroller` | 紫色 (.purple) |
| 故事书 (Storybooks) | `book.vertical` | 橙色 (.orange) |

### 内容页面图标规范

内容页面（选择/列表页面）使用**填充版本**的图标：

| 功能 | 图标名称 | 颜色 |
|------|---------|------|
| 测试选择 (TestSelectionView) | `doc.text.fill` | 蓝色 (.blue) |
| 游戏模式 (GameModeView) | `gamecontroller.fill` | 紫色 (.purple) |
| 故事书列表 (StorybooksListView) | `book.vertical.fill` | 橙色 (.orange) |

### 菜单图标规范

菜单（MenuView）使用**非填充版本**：

| 功能 | 图标名称 |
|------|---------|
| 成就 | `trophy.fill` |
| 进度 | `chart.line.uptrend.xyaxis` |
| 游戏 | `gamecontroller` |
| 故事书 | `book.vertical` |
| 设置 | `gearshape` |
| 关于 | `info.circle` |
| 帮助 | `questionmark.circle` |

### 图标使用原则

1. **主页面** - 使用普通图标（非.fill），让用户快速识别功能
2. **内容页面** - 使用填充图标（.fill），表示已进入该功能区域
3. **一致性** - 同一功能在不同位置使用相同的图标名称（除了fill变体）

---

## UI文本规范

### 标题层级

| 层级 | 字体 | 用途 | 示例位置 |
|------|------|------|---------|
| 大标题 | `.title` + `.bold` | 欢迎页面主标题 | WelcomeView |
| 页面标题 | `.title2` | 功能入口卡片标题 | MainModeButton |
| 导航栏标题 | `.inline` | 导航栏显示 | navigationBarTitleDisplayMode |
| 副标题 | `.subheadline` | 页面说明文字 | 所有内容页面的提示文本 |
| 正文 | `.headline` | 卡片标题 | GameCard, TestUnitCard |
| 辅助文本 | `.caption` | 小字说明 | 词数统计、最佳分数 |

### 内容页面布局规范

**已删除**: 从2025-11-17起，所有内容页面不再显示大标题

**修改前**:
```swift
// ❌ 旧版本 - 显示大标题
VStack(spacing: 8) {
    Image(systemName: "gamecontroller.fill")
    Text("game.mode.title".localized)  // "Game Mode"
    Text("game.mode.subtitle".localized)
}
```

**修改后**:
```swift
// ✅ 新版本 - 只显示图标和副标题
VStack(spacing: 8) {
    Image(systemName: "gamecontroller.fill")
    Text("game.mode.subtitle".localized)  // "Choose a game to play"
}
```

**受影响的页面**:
- GameModeView: 删除 `"game.mode.title"` 显示
- GamesListView: 删除 `"games.title"` 显示
- StorybooksListView: 删除 `"storybooks.title"` 显示
- TestSelectionView: 保持简洁，只显示 `"test.select.unite"`

### 提示文字统一规范

所有选择页面的提示文字使用 `.subheadline` + `.secondary` 颜色：

```swift
Text("game.mode.choose.game".localized)  // "Choose a game to play"
    .font(.subheadline)
    .foregroundColor(.secondary)
```

**修改历史**:
- `"game.mode.games.list"` (❌ 旧版) → `"game.mode.choose.game"` (✅ 新版)
  - 英语: "Games List" → "Choose a game to play"
  - 中文: "游戏列表" → "选择游戏开始玩"
  - 法语: "Liste des jeux" → "Choisissez un jeu pour jouer"

---

## 更新流程

### 添加新功能的翻译

1. **定义key**: 根据命名约定创建新的key
2. **添加英文**: 使用 `add_new_strings.py` 脚本
   ```bash
   python Scripts/add_new_strings.py \
     --key "feature.name.description" \
     --en "Feature Description" \
     --category "Feature Name"
   ```
3. **翻译其他语言**:
   - 创建翻译JSON文件
   - 使用 `import_translations.py` 导入
4. **验证**: 运行 `validate_localizations.py`
5. **测试**: 在所有语言中测试UI显示

### 修改现有翻译

1. **直接编辑**: 修改对应语言的 `.lproj/Localizable.strings` 文件
2. **或使用导入**: 准备JSON文件后使用import脚本
3. **验证**: 确保占位符一致
4. **测试UI**: 检查文本长度是否适合

### 删除废弃的翻译

**注意**: 通常不需要删除旧的key，即使某些功能已移除。保留它们不会影响应用性能，并且有助于：
- 回退到旧版本
- 代码重构时的兼容性

**确需删除时**:
1. 搜索代码确认key未被使用
2. 从所有7个语言文件中删除
3. 验证应用仍可正常编译

### 版本控制

- 所有 `.lproj/Localizable.strings` 文件纳入git版本控制
- 每次翻译更新应包含：
  - 更改的文件
  - 更改原因的commit message
  - 验证脚本的输出日志

---

## 最佳实践

### 1. 翻译质量

- ✅ 使用自然流畅的表达，避免逐字翻译
- ✅ 保持专业术语一致 (例如: "Unite" 统一翻译)
- ✅ 考虑UI空间限制，德语和法语通常比英语长15-30%
- ✅ 使用正确的语法和标点符号

### 2. 测试覆盖

发布前必须测试：
1. 切换到每种语言
2. 遍历所有主要功能
3. 检查文本显示是否完整（无截断）
4. 验证占位符正确替换

### 3. 持续维护

- 每次添加新功能时同步更新所有语言
- 定期运行验证脚本检查一致性
- 收集用户反馈改进翻译质量

---

## 工具和脚本

详见 [Scripts/README.md](../Scripts/README.md)

- `add_new_strings.py` - 添加新翻译
- `validate_localizations.py` - 验证翻译完整性
- `export_base_strings.py` - 导出基准翻译
- `import_translations.py` - 导入外部翻译

---

## 变更日志

### 2025-11-17

**图标规范更新**:
- 统一主页面图标为非填充版本
- 统一内容页面图标为填充版本
- Test: `questionmark.circle` → `doc.text`
- Storybook: `book.fill` → `book.vertical`

**UI文本规范更新**:
- 删除所有内容页面的大标题显示
- 统一提示文字为 `.subheadline` + `.secondary`
- 更新游戏选择提示文字

**删除功能**:
- 移除 MenuView 中的 `"menu.section.entertainment"` 分组
- 保留该key在翻译文件中以保持兼容性

**新增翻译**:
- `game.mode.choose.game` - 游戏选择提示文字

**完成翻译**:
- 完成所有231个 TODO 标记的翻译
- 所有7种语言达到100%翻译覆盖

---

## 联系方式

如有翻译问题或建议，请：
1. 提交 GitHub Issue
2. 标记为 `i18n` 或 `translation` 标签
3. 提供具体的key和建议翻译

---

**文档版本**: 1.0
**最后更新**: 2025-11-17
**维护者**: VocFr Development Team
