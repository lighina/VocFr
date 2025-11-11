# Phase 2: Data Layer Refactoring - Plan

## 目标

将 FrenchWord.swift (1,461 行) 中的硬编码数据提取到 JSON 文件，创建数据加载服务。

## 当前状态分析

### 文件结构
- **3 个单元** (Unités)
- **15 个章节** (Sections) - 每个单元 5 个章节
- **约 200+ 个单词** (Words)
- **硬编码数据格式**：元组数组
  ```swift
  [(法语, 中文, 性别/词性, 类别, 特殊标记)]
  ```

### 问题
1. **可维护性差** - 数据和代码混在一起
2. **难以扩展** - 添加新单词需要修改代码
3. **文件过大** - 1,461 行，难以浏览
4. **无法热更新** - 数据变更需要重新编译

## JSON Schema 设计

### 文件结构
```
VocFr/Data/JSON/
├── vocabulary.json          # 主数据文件
└── audio_segments.json      # 音频片段数据（可选）
```

### vocabulary.json 结构
```json
{
  "version": "1.0",
  "lastUpdated": "2025-11-11",
  "unites": [
    {
      "id": "unite1",
      "number": 1,
      "title": "À l'école",
      "isUnlocked": true,
      "requiredStars": 0,
      "sections": [
        {
          "id": "section1_1",
          "name": "à l'école",
          "orderIndex": 1,
          "words": [
            {
              "canonical": "bureau",
              "chinese": "课桌",
              "partOfSpeech": "noun",
              "genderOrPos": "masculine",
              "category": "school_objects",
              "elision": false,
              "forms": [
                {
                  "formType": "indefiniteArticle",
                  "french": "un bureau",
                  "articleOnly": "un",
                  "gender": "masculine",
                  "number": "singular",
                  "isMainForm": true
                },
                {
                  "formType": "definiteArticle",
                  "french": "le bureau",
                  "articleOnly": "le",
                  "gender": "masculine",
                  "number": "singular",
                  "isMainForm": false
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## 实施步骤

### Step 1: 创建 JSON 目录和 schema
- [x] 设计 JSON schema
- [ ] 创建目录结构
- [ ] 创建空的 JSON 模板

### Step 2: 数据提取脚本
- [ ] 编写 Python 脚本解析 FrenchWord.swift
- [ ] 提取所有单元、章节、单词数据
- [ ] 生成 vocabulary.json

### Step 3: 创建 DataLoader 服务
- [ ] 创建 `VocabularyDataLoader.swift`
- [ ] 实现 JSON 解码
- [ ] 实现数据验证

### Step 4: 重构 Seeder
- [ ] 修改 `FrenchVocabularySeeder` 使用 DataLoader
- [ ] 移除硬编码数据
- [ ] 保留辅助函数

### Step 5: 测试和验证
- [ ] 单元测试 DataLoader
- [ ] 集成测试数据加载
- [ ] 验证 app 功能正常

## 预期成果

### 代码改进
- ✅ FrenchWord.swift: 1,461 行 → ~300 行 (减少 80%)
- ✅ 新增 VocabularyDataLoader.swift: ~150 行
- ✅ vocabulary.json: ~1,500 行 (结构化数据)

### 优势
1. **数据与代码分离** - 易于维护
2. **可扩展性** - 添加新单词只需编辑 JSON
3. **可读性** - JSON 格式清晰
4. **可移植性** - 数据可用于其他平台
5. **版本控制友好** - Git diff 更清晰

### 性能
- 初次加载时间：可能增加 50-100ms（JSON 解析）
- 内存占用：相似或略低
- 可以后续优化：
  - 懒加载（按需加载单元）
  - 缓存解析结果
  - 异步加载

## 风险和缓解

### 风险 1: JSON 解析错误
**缓解**:
- 完善的错误处理
- 数据验证
- Fallback 到硬编码数据（保留旧代码作为备份）

### 风险 2: 数据格式不兼容
**缓解**:
- 版本号管理
- 向后兼容性设计
- 迁移脚本

### 风险 3: 性能下降
**缓解**:
- 性能基准测试
- 优化 JSON 结构
- 实现缓存机制

## 时间估算

- Step 1: 30 分钟
- Step 2: 2-3 小时（数据提取和验证）
- Step 3: 1-2 小时（DataLoader 实现）
- Step 4: 1 小时（重构 Seeder）
- Step 5: 1 小时（测试）

**总计**: 5-7 小时

## 下一步

开始 Step 1：创建目录结构和 JSON 模板
