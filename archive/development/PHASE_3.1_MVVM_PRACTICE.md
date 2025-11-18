# Phase 3.1: MVVM 架构重构 - PracticeViewModel

## 📋 概述

**完成日期**: 2025-11-13
**目标**: 将 PracticeView 重构为 MVVM 架构，分离业务逻辑和 UI 代码

## 🎯 实施内容

### 1. 创建 PracticeViewModel.swift

**位置**: `VocFr/ViewModels/PracticeViewModel.swift`

**职责**:
- 管理练习会话状态（进度、答案显示、正确计数等）
- 处理所有业务逻辑（答题、重新开始、保存记录）
- 提供计算属性供 View 使用（进度文本、准确率等）

**核心特性**:
- ✅ 使用 `@Observable` 宏（Swift 5.9+）
- ✅ 完全隔离业务逻辑
- ✅ 可测试设计（依赖注入 ModelContext）
- ✅ 清晰的职责划分

### 2. 重构 PracticeView

**变化**:

| 重构前 | 重构后 |
|--------|--------|
| `@State` 直接管理状态 | 使用 `@State private var viewModel` |
| 业务逻辑在 View 中 | 委托给 ViewModel |
| ~184 行代码 | ~145 行代码（减少 21%）|
| 难以测试 | 可通过测试 ViewModel |

**代码对比**:

```swift
// 重构前
@State private var currentWordIndex = 0
@State private var showAnswer = false
@State private var correctCount = 0
@State private var isCompleted = false

private func nextWord() {
    currentWordIndex += 1
    showAnswer = false
    if currentWordIndex >= words.count {
        withAnimation {
            isCompleted = true
        }
        savePracticeRecord()
    }
}

// 重构后
@State private var viewModel: PracticeViewModel

Button("答对了") {
    viewModel.markCorrect()
}
```

## 📊 架构改进

### 职责分离

**Before (PracticeView)**:
- ❌ UI 渲染
- ❌ 状态管理
- ❌ 业务逻辑
- ❌ 数据持久化

**After**:

**PracticeView**:
- ✅ UI 渲染（仅关注展示）

**PracticeViewModel**:
- ✅ 状态管理
- ✅ 业务逻辑
- ✅ 数据持久化

### 提取的状态

| 状态 | 类型 | 说明 |
|------|------|------|
| `currentWordIndex` | Int | 当前单词索引 |
| `showAnswer` | Bool | 是否显示答案 |
| `correctCount` | Int | 正确答案计数 |
| `isCompleted` | Bool | 会话是否完成 |

### 提取的计算属性

| 属性 | 返回类型 | 说明 |
|------|----------|------|
| `words` | [Word] | 排序后的单词列表 |
| `currentWord` | Word? | 当前单词 |
| `totalWords` | Int | 总单词数 |
| `progressText` | String | 进度文本（1 / 10）|
| `correctCountText` | String | 正确计数文本 |
| `accuracyPercentage` | Int | 准确率百分比 |
| `accuracyText` | String | 准确率文本 |
| `resultsSummaryText` | String | 结果摘要文本 |
| `sectionName` | String | 章节名称 |

### 提取的方法

| 方法 | 说明 |
|------|------|
| `showAnswerAction()` | 显示答案 |
| `markCorrect()` | 标记正确并前进 |
| `markIncorrect()` | 标记错误并前进 |
| `restartPractice()` | 重新开始练习 |
| `savePracticeRecord()` | 保存练习记录（私有）|

## 🧪 可测试性

**重构前**:
- ❌ 无法单独测试业务逻辑
- ❌ 需要 UI 测试才能验证状态变化
- ❌ 难以模拟边界条件

**重构后**:
- ✅ 可以独立测试 ViewModel
- ✅ 可以模拟 ModelContext
- ✅ 可以轻松测试各种场景

**测试示例**（待实施）:
```swift
func testMarkCorrect() {
    let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

    viewModel.showAnswerAction()
    viewModel.markCorrect()

    XCTAssertEqual(viewModel.correctCount, 1)
    XCTAssertEqual(viewModel.currentWordIndex, 1)
    XCTAssertFalse(viewModel.showAnswer)
}
```

## 📈 代码质量指标

### 代码行数

| 文件 | 重构前 | 重构后 | 变化 |
|------|--------|--------|------|
| PracticeView.swift | 184 行 | 145 行 | -21% |
| PracticeViewModel.swift | 0 行 | 162 行 | 新增 |
| **总计** | 184 行 | 307 行 | +67% |

**说明**: 虽然总行数增加，但代码更易维护、测试和复用。

### 复杂度

| 指标 | 重构前 | 重构后 |
|------|--------|--------|
| View 职责 | 4个 | 1个（UI渲染）|
| 可测试性 | 低 | 高 |
| 代码重用 | 低 | 高 |

## ✅ 优势

### 1. 可维护性
- ✅ 清晰的职责划分
- ✅ 业务逻辑集中管理
- ✅ 更容易理解和修改

### 2. 可测试性
- ✅ ViewModel 可独立测试
- ✅ 不需要 UI 就能验证逻辑
- ✅ 易于模拟依赖

### 3. 可复用性
- ✅ ViewModel 可在不同 View 中复用
- ✅ 业务逻辑与 UI 框架解耦
- ✅ 可以轻松切换到不同 UI（如 Mac 版本）

### 4. 可扩展性
- ✅ 添加新功能只需修改 ViewModel
- ✅ 不会影响 View 的稳定性
- ✅ 易于添加新的计算属性和方法

## 🔄 下一步

### Phase 3.2: WordListViewModel
**计划内容**:
- 重构单词列表管理
- 提取排序、过滤逻辑
- 音频播放状态管理

### Phase 3.3: UniteViewModel & SectionViewModel
**计划内容**:
- 提取进度跟踪逻辑
- 提取解锁状态管理

### Phase 3.4: 单元测试
**计划内容**:
- 为所有 ViewModel 编写单元测试
- 目标覆盖率: >80%

## 📝 注意事项

### ModelContext 初始化
由于 SwiftUI 的限制，`modelContext` 只能在 View 的 `onAppear` 中获取，因此：

```swift
init(section: Section) {
    self._viewModel = State(initialValue: PracticeViewModel(section: section, modelContext: nil))
}

var body: some View {
    // ...
    .onAppear {
        viewModel = PracticeViewModel(section: viewModel.section, modelContext: modelContext)
    }
}
```

这是 SwiftUI + SwiftData 环境中的最佳实践。

## 🎉 总结

Phase 3.1 成功将 PracticeView 重构为 MVVM 架构：

✅ **PracticeViewModel** 创建完成
✅ **PracticeView** 重构完成
✅ **业务逻辑完全分离**
✅ **代码质量提升**
⏳ **单元测试待实施**（Phase 3.1.1）

**收益**:
- 代码更清晰、更易维护
- 可测试性大幅提升
- 为后续重构奠定基础
