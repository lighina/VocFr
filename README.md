# VocFr - 法语学习 App

<div align="center">

**一款基于 SwiftUI 和 SwiftData 的现代化法语学习应用**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-Private-blue.svg)]()

</div>

---

## 📱 功能特色

### 🎓 多模式学习
- **学习模式**：系统化学习法语词汇（Unite → Section → Words）
- **答题模式**：测试法语水平，巩固所学知识
- **游戏模式**：通过游戏化学习提升记忆效果
- **故事书模式**：沉浸式法语阅读体验

### ✨ 核心功能
- **📚 6个主题单元**：从学校到日常生活全面覆盖
- **🎮 多种游戏**：猜词游戏、记忆卡片等
- **📖 互动故事书**：带音频和图片的法语故事
- **💎 宝石系统**：完成任务赚取宝石解锁内容
- **🏆 成就系统**：追踪学习进度和成就

### 🎨 设计亮点
- **日式极简美学**：清新优雅的界面设计
- **原生翻页动画**：流畅的阅读体验
- **iPad 优化**：横屏双页布局，真实书籍体验
- **暗黑模式支持**：舒适的夜间阅读

---

## 🚀 快速开始

### 环境要求

- **Xcode**: 15.0+
- **iOS**: 17.0+
- **macOS**: Sonoma 14.0+
- **Python**: 3.8+ (用于数据导入工具)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/yourusername/VocFr.git
   cd VocFr
   ```

2. **打开项目**
   ```bash
   open VocFr.xcodeproj
   ```

3. **运行项目**
   - 选择目标设备（iPhone 或 iPad）
   - 按 `Cmd + R` 运行

---

## 📂 项目结构

```
VocFr/
├── VocFr/                      # 主应用代码
│   ├── Models/                 # 数据模型（SwiftData）
│   ├── Views/                  # UI 视图（SwiftUI）
│   │   ├── Main/              # 主界面
│   │   ├── Units/             # 学习单元
│   │   ├── Games/             # 游戏模式
│   │   └── Storybooks/        # 故事书
│   ├── Services/              # 业务逻辑
│   ├── Data/                  # 数据资源
│   │   └── JSON/              # JSON 数据文件
│   └── Resources/             # 资源文件
│       ├── Images/            # 图片资源
│       ├── Audio/             # 音频资源
│       └── Localizations/     # 多语言文件
├── Scripts/                    # 自动化脚本
│   ├── Vocabulary/            # 词汇导入工具
│   └── Storybooks/            # 故事书导入工具
└── docs/                       # 项目文档
```

---

## 🛠️ 自动化工具

VocFr 提供了完整的自动化数据导入工具，让你轻松添加新内容。

### 📚 词汇数据导入

**快速开始：**

```bash
# 1. 准备数据（使用 Excel/Google Sheets 编辑 CSV）
cp Scripts/Vocabulary/vocabulary_template.csv my_unite.csv

# 2. 运行导入
python Scripts/Vocabulary/import_vocabulary.py \\
    --source my_unite.csv \\
    --output VocFr/Data/JSON/Unite4.json

# 3. 在 Xcode 中添加 JSON 文件
# 4. 运行 App 测试
```

**详细文档：** [词汇导入指南](Scripts/Vocabulary/VOCABULARY_IMPORT_GUIDE.md)

### 📖 故事书导入

**快速开始：**

```bash
# 1. 准备资源（图片 + 音频 + 文本）
mkdir -p my_storybook
# - cover.png
# - page1.png ~ page10.png
# - story_unite1_page1.mp3 ~ story_unite1_page10.mp3
# - transcript.txt

# 2. 运行导入
python Scripts/Storybooks/import_storybook.py \\
    --source my_storybook \\
    --unite 1 \\
    --book 3 \\
    --title-fr "Le Petit Prince" \\
    --title-zh "小王子"

# 3. 在 Xcode 中添加资源文件
# 4. 运行 App 测试
```

**详细文档：** [故事书导入指南](Scripts/Storybooks/STORYBOOK_IMPORT_GUIDE.md)

---

## 📊 数据格式

### Unite 数据结构

```json
{
  "id": "unite1",
  "number": 1,
  "title": "À l'école",
  "titleInChinese": "在学校",
  "isUnlocked": true,
  "requiredStars": 0,
  "requiredGems": 0,
  "sections": [...]
}
```

### Storybook 数据结构

```json
{
  "id": "storybook_unite1_default",
  "title": "Le Premier Jour d'École",
  "titleInChinese": "第一天上学",
  "uniteId": "unite1",
  "isUnlocked": false,
  "isDefault": true,
  "requiredGems": 0,
  "orderIndex": 1,
  "coverImageName": "storybook_school_cover",
  "pages": [...]
}
```

---

## 🎯 开发指南

### 添加新 Unite

1. 准备 CSV 数据文件
2. 运行导入脚本生成 JSON
3. 在 Xcode 中添加 JSON 文件
4. （可选）添加对应的图片和音频资源

### 添加新 Storybook

1. 准备资源文件（图片、音频、文本）
2. 运行导入脚本
3. 在 Xcode 中添加资源到 Assets
4. 测试新故事书

### 代码规范

- **架构**：MVVM (Model-View-ViewModel)
- **数据持久化**：SwiftData
- **UI 框架**：SwiftUI
- **异步处理**：async/await
- **代码风格**：遵循 Swift API Design Guidelines

---

## 🌍 本地化

支持 7 种语言：
- 🇬🇧 English
- 🇫🇷 Français
- 🇨🇳 简体中文
- 🇪🇸 Español
- 🇩🇪 Deutsch
- 🇮🇹 Italiano
- 🇵🇹 Português

**添加新语言：**
1. 在 Xcode 中添加新的本地化
2. 复制 `en.lproj/Localizable.strings`
3. 翻译字符串
4. 测试

---

## 🧪 测试

### 运行单元测试

```bash
# 在 Xcode 中
Cmd + U
```

### 测试数据导入

```bash
# 词汇导入（预览模式）
python Scripts/Vocabulary/import_vocabulary.py \\
    --source test.csv \\
    --output test.json \\
    --dry-run

# 仅验证数据
python Scripts/Vocabulary/import_vocabulary.py \\
    --source test.csv \\
    --output test.json \\
    --validate-only
```

---

## 📝 待办事项

- [ ] 添加单词发音练习功能
- [ ] 实现离线模式
- [ ] 添加更多游戏类型
- [ ] 支持自定义学习计划
- [ ] 添加社交分享功能

---

## 🤝 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

此项目为私有项目，保留所有权利。

---

## 👤 作者

**Junfeng Wang**

---

## 🙏 致谢

- **SwiftUI** - Apple 的现代化 UI 框架
- **SwiftData** - 强大的数据持久化框架
- **EB Garamond** - 优雅的字体
- **AI 工具** - 辅助开发和内容生成

---

## 📞 联系方式

有问题或建议？欢迎联系：

- 📧 Email: your.email@example.com
- 💬 Issues: [GitHub Issues](https://github.com/yourusername/VocFr/issues)

---

<div align="center">

**Made with ❤️ using Swift and SwiftUI**

[⬆ 回到顶部](#vocfr---法语学习-app)

</div>
