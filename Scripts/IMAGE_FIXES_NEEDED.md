# 图片名称修复清单

## 问题分类

### 1️⃣ 连字符未转换为下划线（4个）

Swift 的 `normalizeForAssetName()` 将 `-` 转换为 `_`，但 JSON 中的 nameOfImage 保留了连字符。

| Unite | 单词 | 中文 | 当前 nameOfImage | 应修改为 | 状态 |
|-------|------|------|-----------------|---------|------|
| U2 | grands-parents | 祖父母 | `grands-parents_image.png` | `grands_parents_image.png` | ❌ 需修复 |
| U2 | dix-sept | 十七 | `dix-sept_image.png` | `dix_sept_image.png` | ❌ 需修复 |
| U2 | dix-huit | 十八 | `dix-huit_image.png` | `dix_huit_image.png` | ❌ 需修复 |
| U2 | dix-neuf | 十九 | `dix-neuf_image.png` | `dix_neuf_image.png` | ❌ 需修复 |

**修复方法**：
```bash
# 方式 1: 手动编辑 Unite2.json，将上述4个词的 nameOfImage 字段中的 - 改为 _

# 方式 2: 使用修复脚本
cd /home/user/VocFr/Scripts
python3 fix_image_names.py
```

---

### 2️⃣ 重音未转换 + 同形异义词冲突（2个）

| Unite | 单词 | 中文 | PartOfSpeech | 当前 nameOfImage | 应修改为 | 冲突词 |
|-------|------|------|--------------|-----------------|---------|--------|
| U4S2 | café | 咖啡馆 | noun | `café_image.png` | `cafe_place_image.png` | U2 café(咖啡) |
| U4 | sucré | 甜的 | adjective | `sucré_image.png` | `sucre_adjective_image.png` | U2/U5 sucre(糖) |

**问题说明**：
1. **café**: 保留了重音 `é`，且与 Unite 2 的 café(咖啡) 冲突
2. **sucré**: 保留了重音 `é`，且规范化后与 sucre(糖) 冲突

**修复方法**：
```bash
# 手动编辑 Unite4.json
# 1. 找到 café (chinese="咖啡馆")，修改 nameOfImage 为 "cafe_place_image.png"
# 2. 找到 sucré，修改 nameOfImage 为 "sucre_adjective_image.png"
```

---

### 3️⃣ nameOfImage 为 null 导致自动生成不存在的图片（2个）

| Unite | 单词 | 中文 | 当前 nameOfImage | Swift 自动生成 | 图片是否存在 |
|-------|------|------|-----------------|---------------|-------------|
| U4 | génial | 很棒的 | `null` | `genial_image` | ❌ 不存在 |
| U4 | préféré | 最喜欢的 | `null` | `prefere_image` | ❌ 不存在 |

**问题说明**：
当 nameOfImage 为 null 时，Swift 代码会自动生成默认图片名：
```swift
imageName = normalizeForAssetName(json.canonical) + "_image"
```

但这些图片不存在，导致：
- ✅ 在词汇列表中可能不显示（正常）
- ❌ 在 Visual Practice 和 Matching 中仍然出现（错误）

**解决方案 A（推荐）**：将 nameOfImage 设置为 "none" 明确禁用图片
```json
{
  "canonical": "génial",
  "nameOfImage": "none"  // 明确标记为无图片
}
```

**解决方案 B**：生成这些图片
```bash
cd Scripts/Vocabulary/image/
python generate_image.py --unite 4 --only-word génial
python generate_image.py --unite 4 --only-word préféré
```

---

## 🔧 快速修复步骤

### Step 1: 修复 JSON 文件

使用修复脚本或手动编辑：

```bash
cd /home/user/VocFr/Scripts
python3 fix_image_names.py
```

或手动编辑：
- `VocFr/Data/JSON/Unite2.json`: 修复 4 个连字符单词
- `VocFr/Data/JSON/Unite4.json`: 修复 café 和 sucré

### Step 2: 重命名已有图片文件（如果存在）

```bash
cd VocFr/Assets.xcassets

# 如果已经有旧的图片，需要重命名
# 示例：
# mv "grands-parents_image.imageset" "grands_parents_image.imageset"
```

### Step 3: 生成缺失的图片

```bash
cd Scripts/Vocabulary/image/

# 为修复后的文件名生成图片
python generate_image.py --unite 2 --only-word "grands-parents"
python generate_image.py --unite 2 --only-word "dix-sept"
python generate_image.py --unite 2 --only-word "dix-huit"
python generate_image.py --unite 2 --only-word "dix-neuf"

python generate_image.py --unite 4 --section 2 --only-word café
python generate_image.py --unite 4 --only-word sucré

# 可选：为 génial 和 préféré 生成图片
python generate_image.py --unite 4 --only-word génial
python generate_image.py --unite 4 --only-word préféré
```

### Step 4: 测试

在 Xcode 中运行应用，检查：
- ✅ 所有单词的图片都能正常显示
- ✅ Visual Practice 和 Matching 中不再显示没有图片的单词（génial, préféré）

---

## 📋 ASCII 规范化规则提醒

为了避免类似问题，JSON 中的 `nameOfImage` 字段必须遵守：

1. **所有法语重音必须转换为 ASCII**：
   - é, è, ê, ë → e
   - à, â, ä → a
   - ô, ö → o
   - ù, û, ü → u
   - ï, î → i
   - ç → c

2. **空格、撇号、连字符必须转换为下划线**：
   - ` ` (空格) → `_`
   - `'` (撇号) → `_`
   - `-` (连字符) → `_`

3. **同形异义词必须用后缀区分**：
   - café (咖啡) → `cafe_image.png`
   - café (咖啡馆) → `cafe_place_image.png`
   - sucre (糖) → `sucre_image.png`
   - sucré (甜的) → `sucre_adjective_image.png`

4. **没有图片的词应该明确标记**：
   ```json
   "nameOfImage": "none"  // 或 null
   ```

---

## 🛠️ 自动化工具

我已经创建了修复脚本：`/home/user/VocFr/Scripts/fix_image_names.py`

运行后会自动修复所有已知问题。
