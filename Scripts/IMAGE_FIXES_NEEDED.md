# 图片名称修复清单 - 已完成 ✅

**状态**: 所有问题已于 2025-11-28 修复完成

**修复提交**:
- `73ec10e` - 修复Python脚本过滤 "none"/"null" 图片生成
- `ed31f9a` - 修复Swift应用的图片过滤和同形异义词ID冲突

---

## 已修复的问题总结

### 1️⃣ 连字符未转换为下划线 ✅

**问题**: JSON中的nameOfImage保留了连字符，但Swift的normalizeForAssetName()将`-`转换为`_`

**影响的单词**（4个）:
| Unite | 单词 | 中文 | 修复前 | 修复后 |
|-------|------|------|--------|--------|
| U2 | grands-parents | 祖父母 | `grands-parents_image.png` | `grands_parents_image.png` |
| U2 | dix-sept | 十七 | `dix-sept_image.png` | `dix_sept_image.png` |
| U2 | dix-huit | 十八 | `dix-huit_image.png` | `dix_huit_image.png` |
| U2 | dix-neuf | 十九 | `dix-neuf_image.png` | `dix_neuf_image.png` |

**修复方法**: 用户已手动更新JSON和资源文件 ✅

---

### 2️⃣ 同形异义词ID冲突 ✅

**问题**: 相同canonical和partOfSpeech的单词共享同一个Word ID，导致图片错误

**影响的单词**（2个）:
| Unite | 单词 | 中文 | 修复前 | 修复后 |
|-------|------|------|--------|--------|
| U4S2 | café | 咖啡馆 | `café_image.png` (错误) | `cafe_place_image.png` ✅ |
| U4 | sucré | 甜的 | `sucré_image.png` | `sucre_adj_image.png` ✅ |

**根本原因**:
```swift
// 旧的ID生成逻辑（造成冲突）
let wordId = "\(json.canonical)-\(json.partOfSpeech)"
// 两个café都是noun → 同一个ID "café-noun" ❌
```

**修复方案**:
```swift
// 新的ID生成逻辑（已修复）
let wordId = "\(json.canonical)-\(json.partOfSpeech)-\(json.chinese)"
// café (咖啡) → "café-noun-咖啡" ✅
// café (咖啡馆) → "café-noun-咖啡馆" ✅
```

**修复文件**: `VocFr/Services/Data/VocabularyDataLoader.swift`
- 行165: 更新缓存键包含chinese
- 行228: 更新Word ID包含chinese

**注意**: 用户需要删除并重新安装应用以重建数据库 ⚠️

---

### 3️⃣ nameOfImage为"none"的单词仍出现在图片练习中 ✅

**问题**: Words with `nameOfImage: "none"` still appear in Visual Practice and Matching games

**影响的单词**（2个）:
| Unite | 单词 | 中文 | nameOfImage | 状态 |
|-------|------|------|-------------|------|
| U4 | génial | 很棒的 | `"none"` | 已从练习中排除 ✅ |
| U4 | préféré | 最喜欢的 | `"none"` | 已从练习中排除 ✅ |

**根本原因**:
```swift
// 旧代码 - 未过滤"none"
let words = section.sectionWords.compactMap { $0.word }.shuffled()
```

**修复方案**:
```swift
// 新代码 - 使用hasImage属性过滤
let words = section.sectionWords
    .compactMap { $0.word }
    .filter { $0.hasImage }  // ✅ 排除imageName为空或"none"的单词
    .shuffled()
```

**修复文件**:
- `VocFr/ViewModels/PracticeViewModel.swift:92`
- `VocFr/ViewModels/MatchingGameViewModel.swift:131`

**hasImage属性定义** (Models.swift:114):
```swift
var hasImage: Bool {
    return !imageName.isEmpty && imageName.lowercased() != "none"
}
```

---

### 4️⃣ Python图片生成脚本过滤"none"/"null" ✅

**问题**: Python脚本将`nameOfImage: "none"`当作truthy值，仍尝试生成图片

**修复方案**:
```python
# Scripts/Vocabulary/image/generate_image.py:201-212
for section in sections:
    for word in section.get("words", []):
        name_of_image = word.get("nameOfImage")
        # 明确排除"none"和"null"
        if name_of_image and name_of_image.lower() not in ("none", "null"):
            yield word
```

**修复文件**: `Scripts/Vocabulary/image/generate_image.py`

---

## 📋 ASCII 规范化规则

所有修复都遵循以下规则：

1. **法语重音 → ASCII**：
   - é, è, ê, ë → e
   - à, â, ä → a
   - ô, ö → o
   - ù, û, ü → u
   - ï, î → i
   - ç → c

2. **特殊字符 → 下划线**：
   - ` ` (空格) → `_`
   - `'` (撇号) → `_`
   - `-` (连字符) → `_`

3. **同形异义词使用后缀**：
   - café (咖啡) → `cafe_image.png`
   - café (咖啡馆) → `cafe_place_image.png`
   - sucre (糖) → `sucre_image.png`
   - sucré (甜的) → `sucre_adj_image.png`

4. **无图片单词标记**：
   ```json
   "nameOfImage": "none"  // 或 null
   ```

---

## ✅ 验证清单

- [x] 所有连字符单词已更新JSON
- [x] 所有连字符单词的图片资源已重命名
- [x] café和sucré的同形异义词已区分
- [x] Swift代码已更新Word ID生成逻辑
- [x] Python脚本已添加"none"/"null"过滤
- [x] Swift ViewModels已添加hasImage过滤
- [x] 所有修改已提交并推送到GitHub

---

## 📚 相关文档

- [图片生成指南](Vocabulary/image/README.md) - 图片生成工具使用说明
- [词汇导入指南](Vocabulary/VOCABULARY_IMPORT_GUIDE.md) - JSON数据格式说明
- [开发者变更日志](../docs/developer/CHANGELOG.md) - 完整修复记录

---

**创建日期**: 2025-11-27
**完成日期**: 2025-11-28
**维护者**: VocFr Development Team
**状态**: ✅ 已完成 - 此文档保留作为历史记录
