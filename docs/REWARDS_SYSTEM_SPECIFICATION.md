# Rewards & Achievement System - 星星奖励与成就系统详细说明

> **版本**: 3.0
> **创建日期**: 2025-11-16
> **最后更新**: 2025-11-17

---

## 目录

1. [系统概述](#系统概述)
2. [星星积分系统](#星星积分系统)
3. [宝石系统](#宝石系统) 🆕
4. [成就系统](#成就系统)
5. [各模式奖励规则](#各模式奖励规则)
6. [单元解锁系统](#单元解锁系统)
7. [游戏解锁系统](#游戏解锁系统) 🆕
8. [故事书系统](#故事书系统) 🆕
9. [连续学习与Streak](#连续学习与streak)
10. [技术实现](#技术实现)
11. [数据持久化](#数据持久化)

---

## 系统概述

VocFr的奖励系统由**三大核心**组成：

```
奖励系统
├── 星星积分系统 (Stars/Points)
│   ├── 学习活动奖励
│   ├── 单元解锁 (主要方式)
│   └── 每日登录
│
├── 宝石系统 (Gems) 🆕
│   ├── Test模式专属奖励
│   ├── Flashcard mastered里程碑
│   ├── 单元解锁 (替代方式)
│   ├── 游戏解锁
│   └── 故事书解锁
│
└── 成就系统 (Achievements)
    ├── 学习里程碑
    ├── 练习成就
    ├── 连续学习
    ├── 积分成就（奖励宝石💎）
    ├── 探索成就
    ├── 游戏玩家成就 🆕
    └── 特殊成就
```

### 设计理念

- **即时反馈**: 每个学习行为立即获得奖励
- **渐进式解锁**: 通过积累星星逐步解锁新内容
- **多维度激励**: 成就系统覆盖学习的各个方面
- **持续动力**: 连续学习奖励保持学习习惯

---

## 星星积分系统

### 1. 核心配置

```swift
// PointsManager.swift
struct RewardPoints {
    // 练习完成奖励（基于准确率）
    static let practice60to79 = 10    // 60-79%
    static let practice80to89 = 15    // 80-89%
    static let practice90to100 = 20   // 90-100%

    // 浏览奖励
    static let sectionBrowse = 5      // 浏览一个Section

    // 每日奖励
    static let dailyLogin = 2         // 每日登录
    static let weekStreak = 50        // 连续7天
}

struct UnlockRequirements {
    static let unite2 = 1000    // 解锁Unite 2需要1000星
    static let unite3 = 2000    // 解锁Unite 3需要2000星
    static let unite4 = 3000    // 解锁Unite 4需要3000星
    static let unite5 = 4000    // 解锁Unite 5需要4000星
    static let unite6 = 5000    // 解锁Unite 6需要5000星
}
```

---

### 2. 星星获取途径

#### A. 学习模式 (Study Mode)

| 活动 | 星星数 | 条件 | 触发时机 |
|------|--------|------|----------|
| 浏览Section | 5⭐ | 查看Section内容 | 进入UniteView |

```swift
// UniteView.swift
PointsManager.shared.awardSectionBrowsePoints(modelContext: modelContext)
```

---

#### B. 练习模式 (Practice Mode)

| 准确率 | 星星数 | 评价 |
|--------|--------|------|
| 90-100% | 20⭐ | 优秀 |
| 80-89% | 15⭐ | 良好 |
| 60-79% | 10⭐ | 及格 |
| <60% | 0⭐ | 需努力 |

```swift
// PracticeViewModel.swift
private func savePracticeSession() {
    let accuracy = Double(correctCount) / Double(wordCount)
    PointsManager.shared.awardPracticePoints(accuracy: accuracy, modelContext: modelContext)
}

// PointsManager.swift
func awardPracticePoints(accuracy: Double, modelContext: ModelContext) {
    let points = calculatePracticePoints(accuracy: accuracy)
    // 60-79%: 10星, 80-89%: 15星, 90-100%: 20星
}
```

---

#### C. 听力练习 (Listening Practice)

**基于播放次数的奖励**

| 播放次数 | 星星数 | 难度 |
|---------|--------|------|
| 1次正确 | 3⭐ | 最难 |
| 2次正确 | 2⭐ | 中等 |
| 3次正确 | 1⭐ | 简单 |
| 答错 | 0⭐ | - |

```swift
// ListeningPracticeViewModel.swift
private func calculatePoints() -> Int {
    var total = 0
    for result in results {
        switch result.playCount {
        case 1: total += 3
        case 2: total += 2
        case 3: total += 1
        default: total += 0
        }
    }
    return total
}

// 完成后奖励
PointsManager.shared.awardStars(points: pointsEarned, modelContext: modelContext,
                                reason: "Listening practice completed")
```

---

#### D. 拼写练习 (Spelling Practice)

**基于提示次数的奖励**

| 提示次数 | 星星数 | 难度 |
|---------|--------|------|
| 0次（无提示） | 5⭐ | 最难 |
| 1次提示 | 3⭐ | 较难 |
| 2次提示 | 2⭐ | 中等 |
| 3次提示 | 1⭐ | 简单 |
| 使用完整提示 | 0⭐ | 太简单 |

```swift
// SpellingViewModel.swift
private func calculateSpellingPoints() -> Int {
    var total = 0
    for result in results {
        if result.isCorrect {
            switch result.hintsUsed {
            case 0: total += 5
            case 1: total += 3
            case 2: total += 2
            case 3: total += 1
            default: total += 0
            }
        }
    }
    return total
}
```

---

#### E. 闪卡练习 (Flashcard)

| 事件 | 星星数 | 说明 |
|------|--------|------|
| 单词正确 | 5⭐ | 标记"认识" |
| 单词掌握 | 10⭐ | 从Box 4升到Box 5 |
| 完成每日复习 | 15⭐ | 完成当天所有应复习卡片 |

```swift
// FlashcardManager.swift
func reviewCard(cardId: String, isCorrect: Bool, context: ModelContext) {
    // ...

    if progress.boxNumber == 5 {
        // Mastered!
        PointsManager.shared.awardStars(
            points: 10,
            modelContext: context,
            reason: "Mastered flashcard"
        )
    } else if isCorrect {
        PointsManager.shared.awardStars(
            points: 5,
            modelContext: context,
            reason: "Flashcard correct"
        )
    }
}

func completeDailyReview(context: ModelContext) {
    PointsManager.shared.awardStars(
        points: 15,
        modelContext: context,
        reason: "Completed daily flashcard review"
    )
}
```

---

#### F. Test模式

**简单公式：星星 = 分数**

| 分数 | 星星数 | 星级 |
|------|--------|------|
| 100分 | 100⭐ | ⭐⭐⭐ |
| 90分 | 90⭐ | ⭐⭐⭐ |
| 85分 | 85⭐ | ⭐⭐ |
| 75分 | 75⭐ | ⭐⭐ |
| 60分 | 60⭐ | ⭐ |
| <60分 | 0⭐ | - |

```swift
// TestViewModel.swift
private func saveTestRecord(result: TestResult) {
    // ... 保存记录

    // Award stars based on performance
    let stars = result.score
    if stars > 0 {
        PointsManager.shared.awardStars(
            points: stars,
            modelContext: modelContext,
            reason: "Test completed with score \(result.score)"
        )
    }
}
```

---

#### G. 游戏模式

##### 配对游戏 (Matching Game)

**基于配对次数的奖励**

| 配对尝试次数 | 每对星星数 | 说明 |
|------------|-----------|------|
| 第1次成功 | 10⭐ | 记忆力优秀 |
| 第2次成功 | 7⭐ | 不错 |
| 第3次及以上 | 5⭐ | 基本 |

**时间奖励（6对配对游戏）**

| 完成时间 | 额外奖励 | 总计可能 |
|---------|---------|---------|
| 1分钟内 | +20⭐ | 最高80⭐ |
| 2分钟内 | +10⭐ | 最高70⭐ |
| 3分钟内 | +5⭐ | 最高65⭐ |

```swift
// MatchingGameViewModel.swift / AllWordsMatchingGameView.swift
private func calculateScore() -> Int {
    var score = 0

    // 基于尝试次数
    for (wordId, attempts) in matchAttempts {
        switch attempts {
        case 1: score += 10
        case 2: score += 7
        default: score += 5
        }
    }

    // 时间奖励
    if elapsedTime < 60 {
        score += 20  // 1分钟内
    } else if elapsedTime < 120 {
        score += 10  // 2分钟内
    } else if elapsedTime < 180 {
        score += 5   // 3分钟内
    }

    return score
}

// 完成后奖励
PointsManager.shared.awardStars(points: score, modelContext: modelContext,
                                reason: "Matching game completed")
```

---

##### Hangman游戏

**基于错误次数的奖励**

| 错误次数 | 星星数 | 说明 |
|---------|--------|------|
| 0-2次 | 10⭐ | 优秀 |
| 3-4次 | 7⭐ | 良好 |
| 5-6次 | 5⭐ | 及格 |
| 失败 | 0⭐ | 未获得 |

```swift
// HangmanViewModel.swift / HangmanAllWordsView.swift
private func calculatePoints(incorrectGuesses: Int) -> Int {
    switch incorrectGuesses {
    case 0...2: return 10
    case 3...4: return 7
    case 5...6: return 5
    default: return 0
    }
}

// 游戏会话结束
private func saveHangmanSession() {
    var totalPoints = 0
    for result in sessionResults {
        if result.won {
            totalPoints += calculatePoints(incorrectGuesses: result.incorrectGuesses)
        }
    }

    PointsManager.shared.awardStars(points: totalPoints, modelContext: modelContext,
                                    reason: "Hangman game session")
}
```

---

#### H. 每日登录

| 事件 | 星星数 | 触发条件 |
|------|--------|---------|
| 每日登录 | 2⭐ | 每天首次打开应用 |
| 7天连续 | 50⭐ | 连续学习7天 |

```swift
// PointsManager.swift
func awardDailyLoginPoints(modelContext: ModelContext) {
    guard let userProgress = getUserProgress(from: modelContext) else { return }

    let calendar = Calendar.current
    let today = Date()

    // 检查今天是否已奖励
    if let lastStudy = userProgress.lastStudyDate,
       calendar.isDate(lastStudy, inSameDayAs: today) {
        return // 已奖励
    }

    // 更新日期
    userProgress.lastStudyDate = today

    // 每日登录奖励
    addPoints(RewardPoints.dailyLogin, to: modelContext, reason: "Daily login")

    // 更新连续天数
    updateStreak(userProgress: userProgress, today: today, calendar: calendar)

    // 检查7天连续奖励
    if userProgress.currentStreak >= 7 && userProgress.currentStreak % 7 == 0 {
        addPoints(RewardPoints.weekStreak, to: modelContext, reason: "7-day streak bonus!")
    }
}
```

---

#### I. 成就解锁

**解锁成就时自动获得奖励星星**

```swift
// AchievementManager.swift
private func handleAchievementUnlock(_ achievement: Achievement, context: ModelContext) {
    print("🏆 Achievement unlocked: \(achievement.titleKey)")

    // Award points
    if achievement.pointsReward > 0 {
        PointsManager.shared.awardStars(
            points: achievement.pointsReward,
            modelContext: context,
            reason: "Achievement unlocked: \(achievement.titleKey)"
        )
    }

    // ... 显示通知
}
```

---

### 3. 星星总览表

| 活动分类 | 活动 | 最低⭐ | 最高⭐ | 频率 |
|---------|------|--------|--------|------|
| **学习** | 浏览Section | 5 | 5 | 每Section一次 |
| **练习** | 看图选词练习 | 10 | 20 | 每次 |
| **听力** | 听音辨词 | 1 | 3 | 每题 |
| **拼写** | 拼写练习 | 1 | 5 | 每题 |
| **闪卡** | 标记正确 | 5 | 5 | 每卡片 |
| **闪卡** | 单词掌握 | 10 | 10 | Box4→Box5 |
| **闪卡** | 完成每日 | 15 | 15 | 每天一次 |
| **测试** | Test模式 | 6 | 10 | 每次 |
| **游戏** | 配对游戏 | 5 | 80 | 每次（含时间奖励） |
| **游戏** | Hangman | 5 | 10 | 每单词 |
| **每日** | 登录 | 2 | 2 | 每天 |
| **连续** | 7天Streak | 50 | 50 | 每7天 |
| **成就** | 解锁成就 | 5 | 200 | 一次性 |

---

## 宝石系统

### 1. 系统概述

**宝石 (Gems 💎)** 是VocFr的高级货币，相比星星更稀有，主要用于：
- **解锁高级功能**：游戏模式、故事书
- **快速解锁单元**：星星不足时的替代方式
- **特殊内容访问**：其他Unite的故事书

### 2. 核心配置

```swift
// UserProgress.swift
class UserProgress {
    var totalGems: Int = 5  // 初始宝石：5💎
    var lastMasteredMilestone: Int = 0  // 用于跟踪Flashcard里程碑
}
```

---

### 3. 宝石获取途径

#### A. Test模式奖励 🎯

**简单公式：宝石 = 分数 ÷ 10**

| 分数 | 星星数 | 宝石数 | 星级 |
|------|--------|--------|------|
| 100分 | 100⭐ | 10💎 | ⭐⭐⭐ |
| 90分 | 90⭐ | 9💎 | ⭐⭐⭐ |
| 80分 | 80⭐ | 8💎 | ⭐⭐ |
| 70分 | 70⭐ | 7💎 | ⭐⭐ |
| 60分 | 60⭐ | 6💎 | ⭐ |

```swift
// TestViewModel.swift
let stars = result.score
let gems = result.score / 10

PointsManager.shared.awardStars(points: stars, ...)
PointsManager.shared.awardGems(gems, ...)
```

**设计理由**：
- Test模式是最综合的练习方式，应获得更高价值奖励
- 鼓励用户定期进行Test巩固学习
- 10:1的转换率让宝石保持稀缺性

---

#### B. Flashcard mastered里程碑 📚

**规则：每mastered 10个词 → 1💎**

| 里程碑 | 宝石奖励 | 累计奖励 |
|--------|----------|----------|
| 10 cards | +1💎 | 1💎 |
| 20 cards | +1💎 | 2💎 |
| 30 cards | +1💎 | 3💎 |
| 50 cards | +2💎 | 5💎 |
| 100 cards | +5💎 | 10💎 |

```swift
// FlashcardManager.swift
private func checkMasteredMilestone(context: ModelContext) {
    let totalMastered = allProgress.filter { $0.isMastered }.count
    let currentMilestone = (totalMastered / 10) * 10

    if currentMilestone > userProgress.lastMasteredMilestone {
        let milestonesPassed = (currentMilestone - userProgress.lastMasteredMilestone) / 10
        PointsManager.shared.awardGems(milestonesPassed, ...)
        userProgress.lastMasteredMilestone = currentMilestone
    }
}
```

**触发时机**：
- 卡片从Box 4移动到Box 5时（达到mastered状态）
- 自动检查是否跨越了新的10的倍数里程碑
- 只在达到新里程碑时奖励，避免重复

**设计理由**：
- Flashcard是长期学习的核心，mastered表示真正掌握
- 鼓励用户持续复习直到完全掌握单词
- 里程碑机制提供清晰的进度感

---

#### C. Section完成奖励 📖

**规则：完成Section的所有练习模式 → 1💎**

所有练习模式包括：
- ✅ Practice (词汇练习)
- ✅ Spelling (拼写练习)
- ✅ Listening (听力练习)
- ✅ Flashcard (复习所有due cards)

```swift
// 实现状态：待实现
// 需要跟踪每个section的练习完成状态
```

---

### 4. 宝石消费用途

#### A. 单元解锁 (替代方式)

**规则：星星不足时，可用宝石解锁**

| Unite | 星星需求 | 宝石需求 | 备注 |
|-------|---------|---------|------|
| Unite 1 | 0⭐ | 0💎 | 默认解锁 |
| Unite 2 | 1000⭐ | 100💎 | 二选一 |
| Unite 3 | 2000⭐ | 200💎 | 二选一 |
| Unite 4 | 3000⭐ | 300💎 | 二选一 |
| Unite 5 | 4000⭐ | 400💎 | 二选一 |
| Unite 6 | 5000⭐ | 500💎 | 二选一 |

```swift
// PointsManager.swift
func unlockWithGems(unite: Unite, modelContext: ModelContext) -> Bool {
    if spendGems(unite.requiredGems, ...) {
        unite.isUnlocked = true
        return true
    }
    return false
}
```

**换算关系**：
- 100💎 ≈ 1000⭐
- 1💎 ≈ 10⭐ 价值
- 完成10次满分Test (100分×10) = 100💎 = 可解锁Unite 2

**设计理由**：
- 提供灵活的解锁路径
- 奖励Test模式的高质量练习
- 保持两种货币的平衡价值

---

#### B. 游戏解锁 🎮

| 游戏 | 状态 | 解锁条件 | 备注 |
|------|------|----------|------|
| Matching Game | ✅ 默认解锁 | 免费 | 入门游戏 |
| Hangman Game | 🔒 锁定 | 10💎 | 需解锁 |
| 未来游戏3 | 🔒 锁定 | 20💎 | 预留 |
| 未来游戏4 | 🔒 锁定 | 30💎 | 预留 |

```json
// GameModes.json
{
  "id": "hangman_game",
  "name": "Hangman",
  "isUnlocked": false,
  "requiredGems": 10,
  "orderIndex": 2
}
```

```swift
// PointsManager.swift
func unlockGameMode(_ gameMode: GameMode, modelContext: ModelContext) -> Bool {
    if spendGems(gameMode.requiredGems, ...) {
        gameMode.isUnlocked = true
        return true
    }
    return false
}
```

**设计理由**：
- Matching Game作为入门游戏免费
- Hangman需要10💎（1次满分Test），合理价格
- 为未来扩展预留空间

---

#### C. 故事书解锁 📚

**规则：**
1. **本Unite故事书**：完成该Unite的Test自动解锁 ✅ 免费
2. **其他Unite故事书**：每本10💎

| 故事书 | 所属Unite | 自动解锁条件 | 宝石解锁 |
|-------|----------|-------------|---------|
| À l'école | Unite 1 | 完成Unite 1 Test | 10💎 |
| C'est la fête | Unite 2 | 完成Unite 2 Test | 10💎 |
| Mon chez-moi | Unite 3 | 完成Unite 3 Test | 10💎 |

```json
// Storybooks.json
{
  "id": "storybook_unite1",
  "title": "À l'école - Mon premier jour",
  "uniteId": "unite1",
  "isUnlocked": false,
  "requiredGems": 10,
  "pages": [...]
}
```

```swift
// PointsManager.swift
func unlockStorybook(_ storybook: Storybook, modelContext: ModelContext) -> Bool {
    if spendGems(storybook.requiredGems, ...) {
        storybook.isUnlocked = true
        return true
    }
    return false
}
```

**设计理由**：
- 完成Test自动解锁本Unite故事书作为奖励
- 想提前阅读其他Unite故事书需付费
- 鼓励循序渐进学习，同时提供灵活性

---

### 5. 宝石系统UI显示

#### A. StarsProgressView (顶部导航)

```
⭐ 1234  💎 56  🔥 7天
```

```swift
// StarsProgressView.swift
HStack(spacing: 16) {
    // Stars
    Image(systemName: "star.fill").foregroundColor(.yellow)
    Text("\(totalStars)")

    // Gems
    Image(systemName: "gem.fill").foregroundColor(.cyan)
    Text("\(totalGems)")
}
```

#### B. TestResultView (Test完成页面)

```
✅ 正确率: 17/20
⏱️ 用时: 7:30
⭐ 获得星星: +85 ⭐
💎 获得宝石: +8 💎
```

---

### 6. 宝石平衡性分析

#### 获取速度估算

| 活动 | 时长 | 获得 | 效率 |
|------|------|------|------|
| Test 100分 | ~10分钟 | 10💎 | 1💎/分钟 |
| Master 10词 | ~30分钟 | 1💎 | 0.033💎/分钟 |
| 完成1 section | ~20分钟 | 1💎 | 0.05💎/分钟 |

**结论**：Test模式是最高效的宝石获取途径（30倍效率）

#### 解锁时间估算

| 目标 | 宝石需求 | Test次数 | 预估时长 |
|------|---------|---------|---------|
| Hangman游戏 | 10💎 | 1次满分 | ~10分钟 |
| Unite 2 (宝石) | 100💎 | 10次满分 | ~100分钟 |
| 故事书 | 10💎 | 1次满分 | ~10分钟 |

**结论**：
- 游戏解锁快速且有趣（1次Test）
- Unite解锁需要努力但可达成（10次Test）
- 故事书作为小奖励易于获得

---

## 成就系统

### 1. 成就分类

```swift
enum AchievementCategory: String, Codable {
    case learning = "Learning Milestones"    // 学习里程碑
    case practice = "Practice Master"        // 练习成就
    case streak = "Consistency"              // 连续学习
    case points = "Star Collector"           // 积分成就
    case exploration = "Explorer"            // 探索成就
    case gameplayer = "Game Player"          // 游戏玩家成就 🆕
    case special = "Special"                 // 特殊成就
}

enum AchievementTier: String, Codable {
    case bronze = "Bronze"      // 青铜
    case silver = "Silver"      // 白银
    case gold = "Gold"          // 黄金
    case platinum = "Platinum"  // 铂金
    case diamond = "Diamond"    // 钻石
}
```

---

### 2. 学习里程碑 (Learning Milestones)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| words_10 | 初学者 | 学习10个单词 | 10 | 🥉Bronze | 5⭐ |
| words_50 | 学徒 | 学习50个单词 | 50 | 🥈Silver | 10⭐ |
| words_100 | 熟练者 | 学习100个单词 | 100 | 🥇Gold | 20⭐ |
| words_200 | 专家 | 学习200个单词 | 200 | 🏆Platinum | 50⭐ |
| words_500 | 大师 | 学习500个单词 | 500 | 💎Diamond | 100⭐ |

```swift
// Achievement.swift - AchievementDefinitions
Achievement(
    id: "words_100",
    titleKey: "achievement.words.100.title",
    descriptionKey: "achievement.words.100.description",
    category: .learning,
    tier: .gold,
    iconName: "text.book.closed.fill",
    targetValue: 100,
    pointsReward: 20,
    orderIndex: 2
)
```

**触发检测**：
```swift
// AchievementManager.swift
func checkLearningMilestones(wordCount: Int, context: ModelContext) {
    let milestones = ["words_10", "words_50", "words_100", "words_200", "words_500"]
    checkProgressAchievements(ids: milestones, currentValue: wordCount, context: context)
}

// 调用时机：每次有新单词被标记为"已学习"（WordProgress.lastReviewed != nil）
```

---

### 3. 练习成就 (Practice Master)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| practice_5 | 新手射手 | 完成5次练习 | 5 | 🥉Bronze | 5⭐ |
| practice_20 | 熟练射手 | 完成20次练习 | 20 | 🥈Silver | 15⭐ |
| practice_50 | Practice Master | 完成50次练习 | 50 | 🥇Gold | 50⭐ |
| perfect_10 | 神射手 | 10次练习100%正确率 | 10 | 🥇Gold | 25⭐ |
| perfect_single_20 | 完美主义者 | 单次练习20题全对 | 1 | 🏆Platinum | 30⭐ |

```swift
// 触发检测
func checkPracticeCount(practiceCount: Int, context: ModelContext) {
    let practiceIds = ["practice_5", "practice_20", "practice_50"]
    checkProgressAchievements(ids: practiceIds, currentValue: practiceCount, context: context)
}

func checkPerfectPractice(perfectCount: Int, isPerfect20: Bool, context: ModelContext) {
    // 10次完美练习
    checkProgressAchievements(ids: ["perfect_10"], currentValue: perfectCount, context: context)

    // 单次20题全对
    if isPerfect20 {
        checkProgressAchievements(ids: ["perfect_single_20"], currentValue: 1, context: context)
    }
}
```

---

### 4. 连续学习 (Consistency)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| streak_3 | 初学者 | 连续学习3天 | 3 | 🥉Bronze | 5⭐ |
| streak_7 | 坚持者 | 连续学习7天 | 7 | 🥈Silver | 15⭐ |
| streak_30 | 学习狂 | 连续学习30天 | 30 | 🥇Gold | 50⭐ |
| streak_100 | 传奇 | 连续学习100天 | 100 | 💎Diamond | 200⭐ |

```swift
// 触发检测
func checkStreak(currentStreak: Int, context: ModelContext) {
    let streakIds = ["streak_3", "streak_7", "streak_30", "streak_100"]
    checkProgressAchievements(ids: streakIds, currentValue: currentStreak, context: context)
}

// 调用时机：每日登录时
```

---

### 5. 积分成就 (Star Collector)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| stars_100 | Star Beginner | 获得100星 | 100 | 🥉Bronze | 2💎 |
| stars_500 | Star Collector | 获得500星 | 500 | 🥈Silver | 5💎 |
| stars_1000 | Star Master | 获得1000星 | 1000 | 🥇Gold | 10💎 |
| stars_2500 | Star Champion | 获得2500星 | 2500 | 🏆Platinum | 20💎 |
| stars_5000 | Star Legend | 获得5000星 | 5000 | 💎Diamond | 50💎 |

**重要变更**: Star Collector 系列成就现在奖励**宝石**而不是星星，因为这些成就代表了长期的学习投入，应该获得更有价值的奖励。

```swift
// 触发检测
func checkPoints(totalPoints: Int, context: ModelContext) {
    let pointsIds = ["stars_100", "stars_500", "stars_1000", "stars_2500", "stars_5000"]
    checkProgressAchievements(ids: pointsIds, currentValue: totalPoints, context: context)
}

// 调用时机：每次星星数量变化时
```

---

### 6. 探索成就 (Explorer)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| unlock_unit_1 | 探索者 | 解锁第一个新单元 | 1 | 🥉Bronze | 10⭐ |
| unlock_unit_3 | 冒险家 | 解锁3个单元 | 3 | 🥈Silver | 20⭐ |
| unlock_unit_5 | Explorer Champion | 解锁5个单元 | 5 | 🏆Platinum | 50💎 |
| complete_section_10 | 勤奋学者 | 完成10个Section练习 | 10 | 🥈Silver | 20⭐ |
| complete_unit_1 | 全能学霸 | 完成1个完整Unit | 1 | 🥇Gold | 50⭐ |

```swift
// 触发检测
func checkUnitUnlocked(unlockedCount: Int, context: ModelContext) {
    let unitIds = ["unlock_unit_1", "unlock_unit_3", "unlock_unit_5"]
    checkProgressAchievements(ids: unitIds, currentValue: unlockedCount, context: context)
}

func checkSectionCompleted(completedCount: Int, context: ModelContext)
func checkUnitCompleted(completedCount: Int, context: ModelContext)
```

---

### 7. 游戏玩家成就 (Game Player) 🆕

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 | 触发条件 |
|--------|------|------|------|------|------|---------|
| unlock_game_1 | Unlocker | 解锁第一个游戏 | 1 | 🥉Bronze | 5⭐ | 解锁任意游戏 |
| hangman_perfect | Hangman Saver | 完美完成Hangman | 1 | 🥇Gold | 5💎 | 0次错误猜测 |
| matching_speed | Speed of Light | 12秒内完成配对 | 1 | 🏆Platinum | 15💎 | 时间≤12秒 |

**新类别说明**: Game Player 成就专注于游戏模式的精通，鼓励玩家尝试不同的学习游戏并追求卓越表现。

```swift
// 触发检测
func checkGameUnlocked(context: ModelContext) {
    checkProgressAchievements(ids: ["unlock_game_1"], currentValue: 1, context: context)
}

func checkHangmanPerfect(context: ModelContext) {
    // 在每个完美单词（incorrectGuesses == 0）完成后立即检查
    checkProgressAchievements(ids: ["hangman_perfect"], currentValue: 1, context: context)
}

func checkMatchingSpeed(timeSpent: TimeInterval, context: ModelContext) {
    if timeSpent <= 12 {
        checkProgressAchievements(ids: ["matching_speed"], currentValue: 1, context: context)
    }
}

// 调用时机：
// - Unlocker: PointsManager.unlockGameMode() 成功后
// - Hangman Saver: HangmanViewModel.winWord() 中 incorrectGuesses == 0 时立即触发
// - Speed of Light: AllWordsMatchingGameView.completeGame() 检查完成时间
```

---

### 8. 特殊成就 (Special)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 | 触发条件 |
|--------|------|------|------|------|------|---------|
| early_bird | 早起鸟 | 早上学习 | 1 | 🥈Silver | 15⭐ | 5:00-8:00 |
| night_owl | 夜猫子 | 晚上学习 | 1 | 🥈Silver | 15⭐ | 22:00-2:00 |
| speed_run | 闪电侠 | 1分钟内完成练习（100%正确） | 1 | 🏆Platinum | 30⭐ | 时间<60s |
| birthday | 生日快乐 | 账户周年纪念日学习 | 1 | 🥇Gold | 20⭐ | 创建日期纪念 |

```swift
// 特殊成就检测
func checkSpecialAchievements(context: ModelContext) {
    let hour = Calendar.current.component(.hour, from: Date())

    // 早起鸟 (5:00-8:00)
    if hour >= 5 && hour < 8 {
        checkProgressAchievements(ids: ["early_bird"], currentValue: 1, context: context)
    }

    // 夜猫子 (22:00-2:00)
    if hour >= 22 || hour < 2 {
        checkProgressAchievements(ids: ["night_owl"], currentValue: 1, context: context)
    }
}

func checkSpeedRun(timeSpent: TimeInterval, accuracy: Double, context: ModelContext) {
    if timeSpent < 60 && accuracy >= 1.0 {
        checkProgressAchievements(ids: ["speed_run"], currentValue: 1, context: context)
    }
}

func checkBirthday(userCreationDate: Date, context: ModelContext) {
    // 检查月日是否相同
    let calendar = Calendar.current
    let today = Date()
    let creationComponents = calendar.dateComponents([.month, .day], from: userCreationDate)
    let todayComponents = calendar.dateComponents([.month, .day], from: today)

    if creationComponents.month == todayComponents.month &&
       creationComponents.day == todayComponents.day {
        checkProgressAchievements(ids: ["birthday"], currentValue: 1, context: context)
    }
}
```

---

### 9. 成就总览表

| 分类 | 成就数量 | 奖励 | 最高难度 |
|------|---------|------|---------|
| 学习里程碑 | 5 | 185⭐ | 500个单词 |
| 练习成就 | 5 | 125⭐ | 50次练习 |
| 连续学习 | 4 | 270⭐ | 100天 |
| 积分成就 | 5 | 87💎 | 5000星 |
| 探索成就 | 5 | 150⭐ + 50💎 | 解锁5个Unit |
| 游戏玩家 🆕 | 3 | 5⭐ + 20💎 | 12秒完成配对 |
| 特殊成就 | 4 | 80⭐ | 速通<60s |
| **总计** | **31** | **815⭐ + 157💎** | - |

**重要说明**：
- 新增 8 个成就（Practice Master +1, Star Collector +2, Explorer +2, Game Player +3）
- 积分成就（Star Collector）现在奖励宝石而非星星
- 总宝石奖励 157💎（Star Collector 87💎 + Explorer Champion 50💎 + Game Player 20💎）

---

## 各模式奖励规则

### 完整对比表

| 模式 | 最低奖励 | 最高奖励 | 计算方式 | 备注 |
|------|---------|---------|---------|------|
| 浏览Section | 5⭐ | 5⭐ | 固定 | 每Section一次 |
| 看图选词练习 | 10⭐ | 20⭐ | 准确率分档 | 60%起 |
| 听力练习 | 1⭐/题 | 3⭐/题 | 播放次数 | 20题最高60⭐ |
| 拼写练习 | 1⭐/题 | 5⭐/题 | 提示次数 | 20题最高100⭐ |
| 闪卡-正确 | 5⭐ | 5⭐ | 固定 | 每次 |
| 闪卡-掌握 | 10⭐ | 10⭐ | 固定 | Box4→5 |
| 闪卡-每日 | 15⭐ | 15⭐ | 固定 | 完成当日任务 |
| Test模式 | 6⭐ | 10⭐ | 分数÷10 | 60分起 |
| 配对游戏 | 30⭐ | 80⭐ | 次数+时间 | 6对，含时间奖励 |
| Hangman | 5⭐ | 10⭐ | 错误次数 | 每单词 |
| 每日登录 | 2⭐ | 2⭐ | 固定 | 每天 |
| 7天连续 | 50⭐ | 50⭐ | 固定 | 每7天 |

---

## 单元解锁系统

### 1. 解锁要求

```swift
struct UnlockRequirements {
    static let unite2 = 50      // Unite 2: 50星 或 100💎
    static let unite3 = 120     // Unite 3: 120星 或 200💎
    static let unite4 = 200     // Unite 4: 200星 或 300💎
    static let unite5 = 300     // Unite 5: 300星 或 400💎
    static let unite6 = 420     // Unite 6: 420星 或 500💎
}
```

### 2. 解锁流程

#### A. 自动星星解锁

```swift
// PointsManager.swift
private func checkAndUnlockUnits(modelContext: ModelContext, totalStars: Int) {
    let descriptor = FetchDescriptor<Unite>(sortBy: [SortDescriptor(\.number)])
    guard let unites = try? modelContext.fetch(descriptor) else { return }

    for unite in unites {
        if !unite.isUnlocked && totalStars >= unite.requiredStars {
            unite.isUnlocked = true
            print("🎉 Unite \(unite.number) unlocked! (\(unite.title))")
        }
    }

    try? modelContext.save()
}
```

#### B. 手动宝石解锁 🆕

```swift
// UnitsView.swift
private func unlockWithGems(_ unite: Unite) {
    let descriptor = FetchDescriptor<UserProgress>()
    guard let userProgress = try? modelContext.fetch(descriptor).first else { return }

    // 检查宝石余额
    if userProgress.totalGems >= unite.requiredGems {
        // 扣除宝石
        userProgress.totalGems -= unite.requiredGems

        // 解锁单元
        unite.isUnlocked = true

        // 保存并检查成就
        try? modelContext.save()
        let unlockedCount = unites.filter { $0.isUnlocked }.count
        AchievementManager.shared.checkUnitUnlocked(unlockedCount: unlockedCount, context: modelContext)
    } else {
        // 宝石不足提示
        insufficientGems = true
    }
}
```

**UI交互**：
- 点击未解锁的Unite显示解锁对话框
- 显示"Unlock with X 💎"选项
- 检查宝石余额，不足时显示错误提示
- 成功解锁后触发Explorer成就检查

### 3. 解锁进度示例

| 星星累计 | 宝石选项 | 已解锁单元 | 下一个 | 还需 |
|---------|---------|-----------|--------|------|
| 0 | - | Unite 1 | Unite 2 | 50⭐ 或 100💎 |
| 50 | 100💎 | Unite 1-2 | Unite 3 | 70⭐ 或 200💎 |
| 120 | 200💎 | Unite 1-3 | Unite 4 | 80⭐ 或 300💎 |
| 200 | 300💎 | Unite 1-4 | Unite 5 | 100⭐ 或 400💎 |
| 300 | 400💎 | Unite 1-5 | Unite 6 | 120⭐ 或 500💎 |
| 420+ | 500💎 | Unite 1-6 | - | - |

**设计理念**：
- 星星路径：循序渐进，通过学习自然解锁
- 宝石路径：快速解锁选项，适合想要跳过内容或提前学习的用户
- 两种方式不冲突，用户可自由选择

---

## 连续学习与Streak

### 1. Streak更新逻辑

```swift
// PointsManager.swift
private func updateStreak(userProgress: UserProgress, today: Date, calendar: Calendar) {
    guard let lastStudy = userProgress.lastStudyDate else {
        // 首次学习
        userProgress.currentStreak = 1
        return
    }

    let daysDifference = calendar.dateComponents([.day], from: lastStudy, to: today).day ?? 0

    if daysDifference == 1 {
        // 连续第N天
        userProgress.currentStreak += 1
    } else if daysDifference > 1 {
        // Streak中断
        userProgress.currentStreak = 1
    }
    // daysDifference == 0: 同一天，不变
}
```

### 2. Streak奖励

| 连续天数 | 奖励 | 类型 |
|---------|------|------|
| 每7天 | 50⭐ | 星星 |
| 3天 | 成就 | 初学者 (5⭐) |
| 7天 | 成就 | 坚持者 (15⭐) |
| 30天 | 成就 | 学习狂 (50⭐) |
| 100天 | 成就 | 传奇 (200⭐) |

---

## 技术实现

### 1. PointsManager - 星星管理器

```swift
class PointsManager {
    static let shared = PointsManager()

    // 核心方法
    func awardPracticePoints(accuracy: Double, modelContext: ModelContext)
    func awardSectionBrowsePoints(modelContext: ModelContext)
    func awardDailyLoginPoints(modelContext: ModelContext)
    func awardStars(points: Int, modelContext: ModelContext, reason: String)

    // 查询方法
    func getTotalStars(from modelContext: ModelContext) -> Int
    func getCurrentStreak(from modelContext: ModelContext) -> Int
    func getNextUnlockRequirement(from modelContext: ModelContext) -> (Int, Int)?

    // 辅助方法
    private func addPoints(_ points: Int, to modelContext: ModelContext, reason: String)
    private func updateStreak(userProgress: UserProgress, today: Date, calendar: Calendar)
    private func checkAndUnlockUnits(modelContext: ModelContext, totalStars: Int)
}
```

---

### 2. AchievementManager - 成就管理器

```swift
@Observable
class AchievementManager {
    static let shared = AchievementManager()

    // 初始化
    func initializeAchievements(in context: ModelContext)
    func syncProgress(context: ModelContext)

    // 检测方法
    func checkLearningMilestones(wordCount: Int, context: ModelContext)
    func checkPracticeCount(practiceCount: Int, context: ModelContext)
    func checkPerfectPractice(perfectCount: Int, isPerfect20: Bool, context: ModelContext)
    func checkStreak(currentStreak: Int, context: ModelContext)
    func checkPoints(totalPoints: Int, context: ModelContext)
    func checkSpecialAchievements(context: ModelContext)

    // 查询方法
    func fetchAllAchievements(context: ModelContext) -> [Achievement]
    func getStatistics(context: ModelContext) -> (total: Int, unlocked: Int, inProgress: Int)
    func getCompletionPercentage(context: ModelContext) -> Int
}
```

---

### 3. Achievement - 成就模型

```swift
@Model
final class Achievement {
    @Attribute(.unique) var id: String
    var titleKey: String
    var descriptionKey: String
    var category: AchievementCategory
    var tier: AchievementTier
    var iconName: String
    var targetValue: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    var pointsReward: Int
    var orderIndex: Int

    // 计算属性
    var progressPercentage: Int {
        guard targetValue > 0 else { return 0 }
        return min(100, Int(Double(currentProgress) / Double(targetValue) * 100))
    }

    var isInProgress: Bool {
        !isUnlocked && currentProgress > 0
    }

    // 方法
    func updateProgress(_ newProgress: Int) -> Bool
    func unlock()
    func reset()
}
```

---

### 4. UserProgress - 用户进度

```swift
@Model
class UserProgress {
    var totalStars: Int = 0
    var currentStreak: Int = 0
    var lastStudyDate: Date?
    var userProgresses: [UserProgress] = []

    @Relationship(deleteRule: .cascade, inverse: \PracticeRecord.userProgress)
    var practiceRecords: [PracticeRecord] = []

    init() {
        self.totalStars = 0
        self.currentStreak = 0
        self.lastStudyDate = nil
    }
}
```

---

## 数据持久化

### 1. Schema配置

```swift
// VocFrApp.swift
let schema = Schema([
    Unite.self,
    Section.self,
    Word.self,
    WordForm.self,
    WordProgress.self,
    UserProgress.self,
    PracticeRecord.self,
    Achievement.self,
    TestRecord.self,
    WrongAnswerRecord.self,
    Item.self
])
```

---

### 2. PracticeRecord - 练习记录

```swift
@Model
class PracticeRecord {
    var sessionDate: Date
    var sessionType: String        // "Practice", "Test - Unité 1", "Matching Game"
    var wordsStudied: Int
    var accuracy: Double
    var timeSpent: TimeInterval

    var userProgress: UserProgress?

    init(sessionDate: Date, sessionType: String, wordsStudied: Int,
         accuracy: Double, timeSpent: TimeInterval) {
        self.sessionDate = sessionDate
        self.sessionType = sessionType
        self.wordsStudied = wordsStudied
        self.accuracy = accuracy
        self.timeSpent = timeSpent
    }
}
```

用途：
- Progress页面Recent Activity显示
- 成就系统统计（练习次数、完美练习）
- 用户行为分析

---

## 完整流程示例

### 场景1：完成一次练习

```swift
// 1. 用户完成练习，准确率85%
let accuracy = 0.85

// 2. 保存练习记录
let record = PracticeRecord(
    sessionDate: Date(),
    sessionType: "Practice",
    wordsStudied: 20,
    accuracy: accuracy,
    timeSpent: 180
)
modelContext.insert(record)

// 3. 奖励星星
PointsManager.shared.awardPracticePoints(accuracy: accuracy, modelContext: modelContext)
// → 获得15⭐ (80-89%)

// 4. 检查成就
AchievementManager.shared.checkPracticeCount(practiceCount: allPractices.count, context: modelContext)
// → 可能解锁"完成5次练习"成就 → 额外5⭐

// 5. 检查单元解锁
// → 如果总星星达到2000，自动解锁Unite 3

// 6. 显示反馈
print("⭐ +15 stars! Total: 2015")
print("🎉 Unite 3 unlocked!")
```

---

### 场景2：连续学习7天

```swift
// Day 1-6: 每日登录
PointsManager.shared.awardDailyLoginPoints(modelContext: modelContext)
// → 每天+2⭐, Streak从1增加到6

// Day 7: 连续7天
PointsManager.shared.awardDailyLoginPoints(modelContext: modelContext)
// → +2⭐ (每日)
// → +50⭐ (7天连续奖励)

// 检查成就
AchievementManager.shared.checkStreak(currentStreak: 7, context: modelContext)
// → 解锁"坚持者"成就 → 额外15⭐

// 总计：2 + 50 + 15 = 67⭐
```

---

### 场景3：Test获得90分

```swift
// 1. 完成测试，20题答对18题
let score = 90  // (18/20) * 100

// 2. 保存TestRecord
let testRecord = TestRecord(...)
modelContext.insert(testRecord)

// 3. 保存PracticeRecord（用于Progress页面）
let practiceRecord = PracticeRecord(
    sessionDate: Date(),
    sessionType: "Test - Unité 1",
    wordsStudied: 20,
    accuracy: 0.9,
    timeSpent: 512
)
modelContext.insert(practiceRecord)

// 4. 奖励星星
let stars = score / 10  // 90 / 10 = 9
PointsManager.shared.awardStars(points: 9, modelContext: modelContext,
                                reason: "Test completed with score 90")
// → +9⭐

// 5. 显示结果
// → ⭐⭐⭐ (90分)
// → "优秀！"
```

---

## 总结

### 星星获取途径总览

```
每日稳定收入：
├── 每日登录: 2⭐
├── 浏览Section: 5⭐ × N个Section
└── 基础练习: 10-20⭐

主动学习收入：
├── 听力练习: 最高60⭐ (20题 × 3⭐)
├── 拼写练习: 最高100⭐ (20题 × 5⭐)
├── 闪卡练习: 每日最高15⭐ + 掌握10⭐/词
├── Test模式: 6-10⭐
├── 配对游戏: 最高80⭐
└── Hangman: 最高10⭐/词

里程碑收入：
├── 7天连续: 50⭐
└── 成就解锁: 5-200⭐
```

### 成就系统总览

```
23个成就，775⭐总奖励

分类：
├── 学习里程碑: 5个成就，185⭐
├── 练习成就: 4个成就，75⭐
├── 连续学习: 4个成就，270⭐
├── 积分成就: 3个成就，85⭐
├── 探索成就: 3个成就，80⭐
└── 特殊成就: 4个成就，80⭐
```

---

## 开发者调试工具 🛠️

### 秘密入口 (Secret Entrance)

**位置**: Achievement 页面

**激活方式**: 快速连续点击奖杯图标 3 次（间隔需小于1秒）

**功能**: 弹出密码输入对话框

#### 秘密代码

**1. "show me the money"**
```swift
// 设置星星和宝石为 999
userProgress.totalStars = 999
userProgress.totalGems = 999
```
- 用途：快速测试高级功能和解锁
- 适用场景：开发测试、演示展示

**2. "shaoyuan"**
```swift
// 解锁所有内容和成就
- 解锁所有 Achievements
- 解锁所有 Unites
- 解锁所有 GameModes
- 解锁所有 Storybooks
```
- 用途：完整功能测试和体验
- 适用场景：功能验证、端到端测试

#### 实现位置

**VocFr/Views/Achievements/AchievementView.swift**:
- 三连击检测：`handleTrophyTap()` (line 222-240)
- 密码执行：`executeSecretCode()` (line 242-256)
- Cheat函数：`showMeTheMoney()`, `shaoyuanCheat()` (line 258-304)

**安全说明**：
- 此功能仅用于开发和测试
- 生产版本应考虑移除或添加额外保护措施
- 不记录到用户数据或分析系统

---

## 总结

### 星星获取途径总览

```
每日稳定收入：
├── 每日登录: 2⭐
├── 浏览Section: 5⭐ × N个Section
└── 基础练习: 10-20⭐

主动学习收入：
├── 听力练习: 最高60⭐ (20题 × 3⭐)
├── 拼写练习: 最高100⭐ (20题 × 5⭐)
├── 闪卡练习: 每日最高15⭐ + 掌握10⭐/词
├── Test模式: 6-10⭐
├── 配对游戏: 最高80⭐
└── Hangman: 最高10⭐/词

里程碑收入：
├── 7天连续: 50⭐
└── 成就解锁: 5-200⭐
```

### 宝石获取途径总览

```
主要途径：
├── Test模式: 6-10💎 (分数÷10)
├── Flashcard里程碑: 每10个掌握词1💎
└── 成就解锁: 2-50💎

成就宝石奖励：
├── Star Collector: 2+5+10+20+50 = 87💎
├── Explorer Champion: 50💎
└── Game Player: 5+15 = 20💎

总计可获得: 157💎 (通过成就)
```

### 成就系统总览

```
31个成就，815⭐ + 157💎 总奖励

分类：
├── 学习里程碑: 5个成就，185⭐
├── 练习成就: 5个成就，125⭐
├── 连续学习: 4个成就，270⭐
├── 积分成就: 5个成就，87💎
├── 探索成就: 5个成就，150⭐ + 50💎
├── 游戏玩家: 3个成就，5⭐ + 20💎
└── 特殊成就: 4个成就，80⭐
```

### 版本更新日志

**Version 3.0 (2025-11-17)**
- 🆕 新增 Game Player 成就类别（3个成就）
- 🆕 Star Collector 改为奖励宝石（5个成就，87💎）
- 🆕 新增 Practice Master (50 sessions, 50⭐)
- 🆕 新增 Explorer Champion (5 units, 50💎)
- 🆕 Unite 支持宝石解锁（手动点击解锁）
- 🆕 秘密入口调试功能
- 🐛 修复 Hangman Perfect 成就立即触发逻辑
- 🐛 修复 Streak 计算bug（保存旧日期）
- 📝 成就总数：23 → 31
- 📝 总奖励：775⭐ → 815⭐ + 157💎

---

**文档维护者**: Claude
**技术栈**: SwiftUI, SwiftData
**最后更新**: 2025-11-17
