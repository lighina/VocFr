# Phase 3.2: MVVM 架构重构 - WordDetailView

**完成日期**: 2025-11-13
**状态**: ✅ 已完成

## 概述

Phase 3.2 将 WordDetailView 的业务逻辑提取到 WordDetailViewModel，实现 MVVM 架构模式。

## 目标

- ✅ 分离 WordView 的业务逻辑和 UI 逻辑
- ✅ 创建 WordDetailViewModel 管理单词导航和状态
- ✅ 提高代码可测试性和可维护性
- ✅ 保持 UI 的流畅性和用户体验

## 实施内容

### 1. 创建 WordDetailViewModel.swift

**文件**: `VocFr/ViewModels/WordDetailViewModel.swift` (136 lines)

#### 核心职责

- **导航管理**: 处理单词的前后导航
- **状态管理**: 管理卡片显示、洗牌模式
- **数据管理**: 维护原始和洗牌的单词列表

#### 关键属性

```swift
@Observable
class WordDetailViewModel {
    // Dependencies
    let section: Section

    // State
    private(set) var currentWordIndex: Int
    private(set) var showWordCard: Bool = true
    private(set) var isShuffled: Bool = false
    private var shuffledWords: [SectionWord]
    private let originalWords: [SectionWord]

    // Computed Properties
    var words: [SectionWord] { ... }
    var currentWord: Word? { ... }
    var canGoToPrevious: Bool { ... }
    var canGoToNext: Bool { ... }
    var totalWords: Int { ... }
    var currentPosition: Int { ... }
}
```

#### 核心方法

```swift
// Navigation
func goToPrevious()
func goToNext()

// Display Control
func toggleWordCard()
func showCard()
func hideCard()

// Shuffle
func toggleShuffle()
func reshuffle()
```

#### 智能特性

**洗牌模式位置保持**:
```swift
func toggleShuffle() {
    isShuffled.toggle()

    // 切换洗牌模式时，尝试保持当前单词位置
    if let currentWord = self.currentWord {
        let newWords = isShuffled ? shuffledWords : originalWords
        if let newIndex = newWords.firstIndex(where: { $0.word?.id == currentWord.id }) {
            currentWordIndex = newIndex
        } else {
            currentWordIndex = 0
        }
    }
}
```

### 2. 重构 WordDetailView

**Before** (部分示例):
```swift
struct WordDetailView: View {
    let section: Section
    let currentWordIndex: Int

    @State private var showWordCard: Bool = true
    @State private var isShuffled: Bool = false
    @State private var shuffledWords: [SectionWord] = []
    @State private var originalWords: [SectionWord] = []

    var body: some View {
        // ... 直接使用 @State 变量
        if showWordCard {
            // ...
        }

        Button(action: { showWordCard.toggle() }) {
            // ...
        }
    }

    private func goToPrevious() {
        // ... 直接修改 state
        currentWordIndex -= 1
    }
}
```

**After**:
```swift
struct WordDetailView: View {
    @State private var viewModel: WordDetailViewModel

    init(section: Section, currentWordIndex: Int) {
        self._viewModel = State(initialValue: WordDetailViewModel(
            section: section,
            currentWordIndex: currentWordIndex
        ))
    }

    var body: some View {
        // ... 使用 ViewModel
        if viewModel.showWordCard {
            // ...
        }

        Button(action: { viewModel.toggleWordCard() }) {
            // ...
        }
    }

    private func goToPrevious() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToPrevious()  // 委托给 ViewModel
        }
        // ... 触觉反馈
    }
}
```

### 3. 关键重构点

#### 状态委托

| Before | After |
|--------|-------|
| `@State private var showWordCard: Bool` | `viewModel.showWordCard` |
| `@State private var isShuffled: Bool` | `viewModel.isShuffled` |
| `@State private var currentWordIndex: Int` | `viewModel.currentWordIndex` |
| `@State private var originalWords: [SectionWord]` | Managed in ViewModel |
| `@State private var shuffledWords: [SectionWord]` | Managed in ViewModel |

#### 行为委托

| Before | After |
|--------|-------|
| `showWordCard.toggle()` | `viewModel.toggleWordCard()` |
| `showWordCard = true` | `viewModel.showCard()` |
| `currentWordIndex -= 1` | `viewModel.goToPrevious()` |
| `currentWordIndex += 1` | `viewModel.goToNext()` |
| `isShuffled.toggle()` | `viewModel.toggleShuffle()` |

#### 初始化逻辑移除

**Before**:
```swift
.onAppear {
    if originalWords.isEmpty {
        originalWords = section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })
        shuffledWords = originalWords.shuffled()
    }
}
```

**After**:
```swift
// ViewModel 的 init 中处理
init(section: Section, currentWordIndex: Int = 0) {
    self.section = section
    self.currentWordIndex = currentWordIndex

    let sortedWords = section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })
    self.originalWords = sortedWords
    self.shuffledWords = sortedWords.shuffled()
}
```

### 4. Section 上下文传递

为了支持 Phase 2.6 的音频架构（同一单词在不同 section 有不同音频），保持了 section 上下文传递:

```swift
// ViewModel 存储 section
let section: Section

// 音频播放使用正确的 section 上下文
audioManager.playWordAudio(for: word, in: viewModel.section) { success in
    // ...
}
```

## 代码改进统计

### WordView.swift 变化

**状态管理简化**:
- Before: 5 个 @State 变量
- After: 1 个 @State viewModel

**逻辑委托**:
- 所有导航逻辑: 委托给 `viewModel.goToPrevious/goToNext()`
- 卡片显示: 委托给 `viewModel.toggleWordCard()/showCard()`
- 洗牌模式: 委托给 `viewModel.toggleShuffle()`

### WordListView 评估

检查了以下文件，发现无需重构:

1. **WordRowView.swift** (67 lines)
   - 纯展示组件
   - 无状态管理
   - 无业务逻辑
   - ✅ 已符合 MVVM 最佳实践

2. **SectionDetailView.swift** (63 lines)
   - 简单列表展示
   - 无 @State 变量
   - 无业务逻辑
   - 仅负责导航
   - ✅ 已符合 MVVM 最佳实践

## 架构优势

### 1. 关注点分离

**ViewModel (业务逻辑)**:
- 单词导航算法
- 洗牌逻辑和状态管理
- 边界检查 (canGoToPrevious/canGoToNext)
- 单词列表管理

**View (UI)**:
- 动画效果
- 触觉反馈
- 布局和样式
- 用户交互

### 2. 可测试性提升

```swift
// 可以直接测试 ViewModel 逻辑，无需 UI
func testNavigationBoundaries() {
    let section = createTestSection(wordCount: 3)
    let viewModel = WordDetailViewModel(section: section, currentWordIndex: 0)

    XCTAssertFalse(viewModel.canGoToPrevious)
    XCTAssertTrue(viewModel.canGoToNext)

    viewModel.goToNext()
    XCTAssertTrue(viewModel.canGoToPrevious)
    XCTAssertTrue(viewModel.canGoToNext)
}
```

### 3. 状态管理清晰

- 所有状态变更通过 ViewModel 方法
- 使用 `@Observable` 自动 UI 更新
- 状态变量使用 `private(set)` 保护，只能通过方法修改

### 4. 代码复用

ViewModel 可以在不同上下文中复用:
- 单词详情视图
- 测试环境
- 未来的 macOS/iPadOS 特定视图

## 技术细节

### @Observable 宏

使用 Swift 5.9+ 的 `@Observable` 宏，相比传统的 `ObservableObject`:

**优势**:
- 更简洁的语法（无需 `@Published`）
- 更好的性能（细粒度观察）
- 自动依赖追踪

**使用**:
```swift
@Observable
class WordDetailViewModel {
    private(set) var currentWordIndex: Int  // 自动观察
    private(set) var showWordCard: Bool     // 自动观察
}
```

### State 初始化模式

```swift
@State private var viewModel: WordDetailViewModel

init(section: Section, currentWordIndex: Int) {
    self._viewModel = State(initialValue: WordDetailViewModel(
        section: section,
        currentWordIndex: currentWordIndex
    ))
}
```

这种模式确保:
1. ViewModel 在 View 初始化时创建
2. 使用正确的初始参数
3. SwiftUI 管理 ViewModel 生命周期

## 与 Phase 3.1 对比

| 特性 | Phase 3.1 (PracticeViewModel) | Phase 3.2 (WordDetailViewModel) |
|------|-------------------------------|----------------------------------|
| **主要职责** | 练习会话管理 | 单词浏览和导航 |
| **状态管理** | 进度追踪、正确率统计 | 导航位置、显示模式 |
| **数据持久化** | 保存练习记录到数据库 | 无持久化需求 |
| **ModelContext** | 需要（用于保存记录） | 不需要 |
| **核心方法** | markCorrect/Incorrect | goToNext/Previous |
| **特殊功能** | 计算准确率、完成检测 | 洗牌模式、位置保持 |

## 测试计划

虽然未实施单元测试（参考 Phase 3.1 的测试环境问题），但架构已为测试做好准备:

### 可测试的场景

```swift
// 1. 导航边界测试
func testNavigationBoundaries()

// 2. 洗牌功能测试
func testShuffleToggle()
func testShufflePreservesCurrentWord()

// 3. 卡片显示测试
func testCardVisibilityToggle()
func testShowCard()

// 4. 边界情况测试
func testEmptySection()
func testSingleWord()
```

### App 测试验证

✅ 已在实际 App 中验证:
- 单词导航 (前进/后退)
- 洗牌模式切换
- 卡片显示/隐藏
- 音频播放（带 section 上下文）
- 手势交互

## 后续工作

### Phase 3.3 候选: UniteViewModel & SectionViewModel

可能的重构目标:
- `UniteListView`: 单元列表逻辑
- `SectionListView`: 章节列表逻辑
- `ProgressViewModel`: 用户进度管理

### Phase 3.4: 完善单元测试

- 配置正确的 ModelContext 测试环境
- 实现完整的 ViewModel 单元测试套件
- 集成测试覆盖关键用户流程

## 总结

Phase 3.2 成功将 WordDetailView 重构为 MVVM 架构:

✅ **完成**:
1. 创建 WordDetailViewModel (136 lines)
2. 重构 WordDetailView 使用 ViewModel
3. 评估 WordListView/WordRowView（无需重构）
4. 保持 Phase 2.6 音频架构兼容性

✅ **改进**:
- 关注点分离更清晰
- 代码可测试性提升
- 状态管理更安全
- 便于未来扩展

✅ **验证**:
- App 功能完全正常
- 用户体验保持一致
- 性能无影响

**下一步**: 用户选择继续 Phase 3.3 或其他优化方向
