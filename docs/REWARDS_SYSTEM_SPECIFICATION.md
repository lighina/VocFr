# Rewards & Achievement System - 星星奖励与成就系统详细说明

> **版本**: 1.0
> **创建日期**: 2025-11-16
> **最后更新**: 2025-11-16

---

## 目录

1. [系统概述](#系统概述)
2. [星星积分系统](#星星积分系统)
3. [成就系统](#成就系统)
4. [各模式奖励规则](#各模式奖励规则)
5. [单元解锁系统](#单元解锁系统)
6. [连续学习与Streak](#连续学习与streak)
7. [技术实现](#技术实现)
8. [数据持久化](#数据持久化)

---

## 系统概述

VocFr的奖励系统由两大核心组成：

```
奖励系统
├── 星星积分系统 (Stars/Points)
│   ├── 学习活动奖励
│   ├── 单元解锁
│   └── 每日登录
│
└── 成就系统 (Achievements)
    ├── 学习里程碑
    ├── 练习成就
    ├── 连续学习
    ├── 积分成就
    ├── 探索成就
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
    static let unite2 = 50      // 解锁Unite 2需要50星
    static let unite3 = 120     // 解锁Unite 3需要120星
    static let unite4 = 200     // 解锁Unite 4需要200星
    static let unite5 = 300     // 解锁Unite 5需要300星
    static let unite6 = 420     // 解锁Unite 6需要420星
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

**简单公式：星星 = 分数 ÷ 10**

| 分数 | 星星数 | 星级 |
|------|--------|------|
| 100分 | 10⭐ | ⭐⭐⭐ |
| 90分 | 9⭐ | ⭐⭐⭐ |
| 85分 | 8⭐ | ⭐⭐ |
| 75分 | 7⭐ | ⭐⭐ |
| 60分 | 6⭐ | ⭐ |
| <60分 | 0⭐ | - |

```swift
// TestViewModel.swift
private func saveTestRecord(result: TestResult) {
    // ... 保存记录

    // Award stars based on performance
    let stars = result.score / 10
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

## 成就系统

### 1. 成就分类

```swift
enum AchievementCategory: String, Codable {
    case learning = "Learning Milestones"    // 学习里程碑
    case practice = "Practice Master"        // 练习成就
    case streak = "Consistency"              // 连续学习
    case points = "Star Collector"           // 积分成就
    case exploration = "Explorer"            // 探索成就
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
| perfect_10 | 神射手 | 10次练习100%正确率 | 10 | 🥇Gold | 25⭐ |
| perfect_single_20 | 完美主义者 | 单次练习20题全对 | 1 | 🏆Platinum | 30⭐ |

```swift
// 触发检测
func checkPracticeCount(practiceCount: Int, context: ModelContext) {
    let practiceIds = ["practice_5", "practice_20"]
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
| stars_100 | 星星收集者 | 获得100星 | 100 | 🥉Bronze | 10⭐ |
| stars_500 | 星辰大海 | 获得500星 | 500 | 🥈Silver | 25⭐ |
| stars_1000 | 星光璀璨 | 获得1000星 | 1000 | 🥇Gold | 50⭐ |

```swift
// 触发检测
func checkPoints(totalPoints: Int, context: ModelContext) {
    let pointsIds = ["stars_100", "stars_500", "stars_1000"]
    checkProgressAchievements(ids: pointsIds, currentValue: totalPoints, context: context)
}

// 调用时机：每次星星数量变化时
```

---

### 6. 探索成就 (Explorer)

| 成就ID | 名称 | 描述 | 目标 | 等级 | 奖励 |
|--------|------|------|------|------|------|
| unlock_unit_1 | 探索者 | 解锁第一个新单元 | 1 | 🥉Bronze | 10⭐ |
| complete_section_10 | 冒险家 | 完成10个Section练习 | 10 | 🥈Silver | 20⭐ |
| complete_unit_1 | 全能学霸 | 完成1个完整Unit | 1 | 🥇Gold | 50⭐ |

```swift
// 触发检测
func checkUnitUnlocked(unlockedCount: Int, context: ModelContext)
func checkSectionCompleted(completedCount: Int, context: ModelContext)
func checkUnitCompleted(completedCount: Int, context: ModelContext)
```

---

### 7. 特殊成就 (Special)

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

### 8. 成就总览表

| 分类 | 成就数量 | 总奖励星星 | 最高难度 |
|------|---------|-----------|---------|
| 学习里程碑 | 5 | 185⭐ | 500个单词 |
| 练习成就 | 4 | 75⭐ | 10次完美 |
| 连续学习 | 4 | 270⭐ | 100天 |
| 积分成就 | 3 | 85⭐ | 1000星 |
| 探索成就 | 3 | 80⭐ | 完成1个Unit |
| 特殊成就 | 4 | 80⭐ | 速通<60s |
| **总计** | **23** | **775⭐** | - |

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
    static let unite2 = 50      // Unite 2: 50星
    static let unite3 = 120     // Unite 3: 120星
    static let unite4 = 200     // Unite 4: 200星
    static let unite5 = 300     // Unite 5: 300星
    static let unite6 = 420     // Unite 6: 420星
}
```

### 2. 解锁流程

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

### 3. 解锁进度示例

| 星星累计 | 已解锁单元 | 下一个 | 还需 |
|---------|-----------|--------|------|
| 0 | Unite 1 | Unite 2 | 50 |
| 50 | Unite 1-2 | Unite 3 | 70 |
| 120 | Unite 1-3 | Unite 4 | 80 |
| 200 | Unite 1-4 | Unite 5 | 100 |
| 300 | Unite 1-5 | Unite 6 | 120 |
| 420+ | Unite 1-6 | - | - |

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
// → 如果总星星达到120，自动解锁Unite 3

// 6. 显示反馈
print("⭐ +15 stars! Total: 125")
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

**文档维护者**: Claude
**技术栈**: SwiftUI, SwiftData
**最后更新**: 2025-11-16
