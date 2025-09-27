# VocFr - 法语学习应用

一个使用 SwiftUI 和 SwiftData 构建的法语词汇学习应用。

## 项目结构

### 核心文件

- **VocFrApp.swift** - 应用的入口点，配置 SwiftData 模型容器
- **Models.swift** - 包含所有 SwiftData 模型定义
- **FrenchWord.swift** - 词汇数据播种器，包含所有法语学习数据
- **ContentView.swift** - 主要的用户界面，包含标签导航

### 视图文件

- **PracticeView.swift** - 单词练习视图
- **ProgressView.swift** - 学习进度追踪视图

### 测试

- **FrenchVocabularyTests.swift** - 使用新的 Swift Testing 框架的单元测试

## 功能特性

### 📚 课程管理
- 3个单元 (Unités)，每个包含5个章节 (Sections)
- 渐进式解锁机制，需要星星来解锁新单元
- 完整的法语词汇数据，包含词性、中文翻译、不同词形

### 🎯 练习系统
- 交互式单词练习
- 显示/隐藏答案功能
- 正确率统计
- 练习记录保存

### 📊 进度追踪
- 总星数统计
- 学习连续天数
- 最近活动记录
- 练习准确率追踪

### 🔊 音频支持
- 音频时间戳数据
- 不同词形的发音片段
- 音频质量和置信度评分

## 数据模型

### 核心模型
- **Unite**: 学习单元
- **Section**: 章节
- **Word**: 单词
- **WordForm**: 单词形式（冠词、性别等）
- **SectionWord**: 章节与单词的关联

### 音频模型
- **AudioFile**: 音频文件
- **AudioSegment**: 音频片段

### 进度模型
- **UserProgress**: 用户整体进度
- **WordProgress**: 单词掌握进度
- **PracticeRecord**: 练习记录

## 词汇内容

### Unité 1: À l'école
1. **à l'école** - 学校用品和人员 (32个词)
2. **les couleurs** - 颜色 (12个词)
3. **les nombres** - 数字0-12 (13个词)
4. **les verbes** - 动词和代词 (15个词)
5. **les prépositions** - 介词 (5个词)

### Unité 2: C'est la fête
1. **la famille** - 家庭成员 (15个词)
2. **les aliments** - 食物和饮料 (40个词)
3. **autres vocables** - 其他词汇 (5个词)
4. **les verbes** - 动词 (7个词)
5. **les nombres jusqu'à 20** - 数字0-20 (21个词)

### Unité 3: Mon chez-moi
1. **la maison** - 房屋结构 (12个词)
2. **dans la chambre** - 房间物品 (16个词)
3. **les jouets** - 玩具 (14个词)
4. **les verbes** - 动词 (15个词)
5. **les prépositions** - 介词 (6个词)

## 特殊功能

### 词形变化
应用正确处理法语的词形变化：
- 阳性/阴性冠词 (un/une, le/la)
- 省音形式 (l' + 元音开头词)
- 复数形式 (les, des)

### 数据验证
- 自动检查缺失的图片资源
- 验证词性和性别信息
- 重复单词ID检测
- 音频覆盖率统计

## 使用方法

1. **首次启动**: 应用会自动导入所有词汇数据
2. **浏览课程**: 在"课程"标签中选择单元和章节
3. **开始练习**: 在章节详情中点击"开始练习"
4. **查看进度**: 在"进度"标签中查看学习统计
5. **管理数据**: 在"设置"标签中重新导入数据或导出报告

## 技术特点

- **SwiftData**: 现代的数据持久化
- **SwiftUI**: 声明式用户界面
- **Swift Testing**: 使用最新的测试框架
- **音频时间戳**: 精确的音频片段定位
- **数据关系**: 完整的关系型数据模型

## 开发说明

项目使用现代的 Swift 开发最佳实践：
- 严格的类型安全
- 关联数据模型
- 异步/并发支持
- 完整的错误处理
- 单元测试覆盖

## 许可证

此项目用于教育目的。