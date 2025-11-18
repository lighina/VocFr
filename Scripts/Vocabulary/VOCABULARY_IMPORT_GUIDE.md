# VocFr 词汇数据导入指南

本指南将帮助你轻松地为 VocFr 项目添加新的词汇数据（Unite/Section/Words）。

## 📋 目录

- [快速开始](#快速开始)
- [准备数据](#准备数据)
- [运行导入](#运行导入)
- [添加资源文件](#添加资源文件)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 最简流程

1. **复制模板文件**
   ```bash
   cp Scripts/Vocabulary/vocabulary_template.csv my_new_unite.csv
   ```

2. **编辑数据**（用 Excel/Google Sheets）
   - 填写 Unite 信息
   - 填写 Section 信息
   - 填写单词列表

3. **运行导入**
   ```bash
   python Scripts/Vocabulary/import_vocabulary.py \\
       --source my_new_unite.csv \\
       --output VocFr/Data/JSON/Unite4.json
   ```

4. **在 Xcode 中添加 JSON 文件**

5. **运行 App 测试**

---

## 📝 准备数据

### 文件格式

使用 **CSV 格式**，可以用以下工具编辑：
- ✅ Microsoft Excel
- ✅ Google Sheets
- ✅ Numbers (Mac)
- ✅ LibreOffice Calc

### 数据结构

CSV 文件包含三种类型的数据行：

#### 1. UNITE 信息行（必填，第一行）

```csv
UNITE,unite_id,unite_number,unite_title_fr,unite_title_zh,required_stars,required_gems
UNITE,unite4,4,À la maison,在家里,60,0
```

字段说明：
- `unite_id`: 唯一标识（如 `unite4`）
- `unite_number`: 单元编号（整数，如 `4`）
- `unite_title_fr`: 法语标题（如 `À la maison`）
- `unite_title_zh`: 中文标题（如 `在家里`）
- `required_stars`: 解锁所需星星数（整数，如 `60`）
- `required_gems`: 解锁所需宝石数（整数，通常为 `0`）

#### 2. SECTION 信息行

```csv
SECTION,section_id,section_name,order_index
SECTION,section4_1,les pièces,1
```

字段说明：
- `section_id`: 唯一标识（如 `section4_1`）
- `section_name`: 章节名称（如 `les pièces`）
- `order_index`: 排序索引（整数，从 1 开始）

#### 3. 单词数据行

```csv
canonical,chinese,part_of_speech,gender_or_pos,category,elision
maison,房子,noun,feminine,home,false
```

字段说明：

| 字段 | 说明 | 示例 | 必填 |
|------|------|------|------|
| `canonical` | 法语单词原形 | `maison` | ✅ |
| `chinese` | 中文释义 | `房子` | ✅ |
| `part_of_speech` | 词性 | `noun`, `verb`, `adj` | ✅ |
| `gender_or_pos` | 性别/位置 | `masculine`, `feminine` | ✅ |
| `category` | 分类 | `home`, `food` | ✅ |
| `elision` | 是否需要省音 | `true`, `false` | ✅ |

**词性选项：**
- `noun` - 名词
- `verb` - 动词
- `adj` / `adjective` - 形容词
- `adv` / `adverb` - 副词
- `prep` / `preposition` - 介词

**性别选项（名词）：**
- `masculine` / `m` - 阳性
- `feminine` / `f` - 阴性

**省音（elision）：**
- `true` - 需要省音（如 `heure` → `l'heure`）
- `false` - 不需要省音

### 完整示例

```csv
# VocFr 词汇导入模板

# Unite 信息
UNITE,unite4,4,À la maison,在家里,60,0

# Section 1: 房间
SECTION,section4_1,les pièces,1
maison,房子,noun,feminine,home,false
salon,客厅,noun,masculine,home,false
cuisine,厨房,noun,feminine,home,false
chambre,卧室,noun,feminine,home,false
salle de bain,浴室,noun,feminine,home,false

# Section 2: 家具
SECTION,section4_2,les meubles,2
table,桌子,noun,feminine,furniture,false
chaise,椅子,noun,feminine,furniture,false
lit,床,noun,masculine,furniture,false
armoire,衣柜,noun,feminine,furniture,false
canapé,沙发,noun,masculine,furniture,false
```

---

## ⚙️ 运行导入

### 基本用法

```bash
python Scripts/Vocabulary/import_vocabulary.py \\
    --source my_data.csv \\
    --output VocFr/Data/JSON/Unite4.json
```

### 高级选项

#### 1. 预览模式（不实际写入）

```bash
python Scripts/Vocabulary/import_vocabulary.py \\
    --source my_data.csv \\
    --output Unite4.json \\
    --dry-run
```

#### 2. 仅验证数据（不保存）

```bash
python Scripts/Vocabulary/import_vocabulary.py \\
    --source my_data.csv \\
    --output Unite4.json \\
    --validate-only
```

#### 3. 更新模式（增量添加 Section）

```bash
python Scripts/Vocabulary/import_vocabulary.py \\
    --source new_sections.csv \\
    --update \\
    --unite 4
```

这会将新的 Section 添加到现有的 Unite 4 中，不会覆盖原有数据。

---

## 📦 添加资源文件

### 1. 添加 JSON 到 Xcode

1. 打开 Xcode 项目
2. 在项目导航栏找到 `VocFr/Data/JSON/` 文件夹
3. 右键点击文件夹，选择 **"Add Files to VocFr..."**
4. 选择新生成的 JSON 文件
5. 确保勾选：
   - ✅ Copy items if needed（如果需要）
   - ✅ Create groups
   - ✅ Add to targets: VocFr

### 2. 准备图片资源（可选）

如果需要为单词添加图片：

**图片命名规则：**
```
{canonical}.png
```

**示例：**
```
maison.png
salon.png
cuisine.png
```

**添加到 Assets：**
1. 在 Xcode 中打开 `Assets.xcassets`
2. 拖拽所有图片到 Assets
3. 图片会自动以文件名作为资源名称

### 3. 准备音频资源

**音频命名规则：**
```
{canonical}.mp3
```

**示例：**
```
maison.mp3
salon.mp3
cuisine.mp3
```

**添加到项目：**
1. 右键点击 `VocFr/Resources/Audio/` 文件夹
2. 选择 **"Add Files to VocFr..."**
3. 选择所有音频文件
4. 确保勾选 target

---

## ❓ 常见问题

### Q: CSV 文件编码问题怎么办？

**A:** 确保 CSV 文件使用 **UTF-8 编码**。

- **Excel**: 另存为 → CSV UTF-8 (逗号分隔)
- **Google Sheets**: 文件 → 下载 → 逗号分隔值 (.csv)

### Q: 导入后 App 中看不到新数据？

**A:** 检查以下几点：

1. ✅ JSON 文件已添加到 Xcode 项目
2. ✅ JSON 文件已勾选 target
3. ✅ 已重新构建并运行 App (Cmd+K, Cmd+R)
4. ✅ Unite 的 `isUnlocked` 设为 `true`（测试时）

### Q: 如何修改现有 Unite 的数据？

**A:** 两种方法：

**方法 1：直接编辑 JSON**
- 适合小改动
- 直接修改 `VocFr/Data/JSON/UniteX.json`

**方法 2：使用更新模式**
- 适合大量添加
- 创建新 CSV，运行 `--update` 模式

### Q: 单词的分类（category）有哪些？

**A:** 常用分类：

- `school_objects` - 学校用品
- `home` - 家居
- `furniture` - 家具
- `food` - 食物
- `colors` - 颜色
- `animals` - 动物
- `body_parts` - 身体部位
- `clothes` - 衣物
- `family` - 家庭
- `nature` - 自然

### Q: 如何处理有多个单词的短语？

**A:** 直接写完整短语即可：

```csv
salle de bain,浴室,noun,feminine,home,false
porte-monnaie,钱包,noun,masculine,objects,false
```

### Q: 哪些单词需要设置 elision 为 true？

**A:** 以**元音**或**哑音 h** 开头的单词：

```csv
heure,小时,noun,feminine,time,true
arbre,树,noun,masculine,nature,true
école,学校,noun,feminine,place,true
```

效果：`le heure` → `l'heure`, `le arbre` → `l'arbre`

---

## 🎯 最佳实践

### 1. 数据组织

- ✅ 每个 Unite 一个 CSV 文件
- ✅ Section 按难度递增排序
- ✅ 每个 Section 10-15 个单词为佳
- ✅ 同类单词放在同一个 Section

### 2. 命名规范

- ✅ Unite ID: `unite1`, `unite2`, ...
- ✅ Section ID: `section1_1`, `section1_2`, ...
- ✅ 使用小写字母和数字
- ✅ 用下划线分隔

### 3. 质量检查

导入前检查：
- ✅ 所有法语单词拼写正确
- ✅ 中文翻译准确
- ✅ 词性和性别正确
- ✅ 没有重复的单词
- ✅ Section 顺序合理

---

## 📊 数据统计

导入后会看到类似输出：

```
✅ JSON 文件已保存: VocFr/Data/JSON/Unite4.json
   Unite ID: unite4
   Section 数量: 3
   总词汇数: 45
```

---

## 🔧 故障排除

### 脚本错误

**错误：找不到 CSV 文件**
```
FileNotFoundError: CSV 文件不存在
```
解决：检查文件路径是否正确

**错误：缺少必填字段**
```
❌ 数据验证失败:
  - Section 1 Word 3 缺少 chinese 字段
```
解决：检查 CSV 文件，确保所有字段都已填写

**错误：Unite 行格式不正确**
```
⚠️  Unite 行格式不正确
```
解决：确保 UNITE 行有 7 个字段（包括 UNITE 标识）

### Xcode 问题

**JSON 文件添加后没有显示**
- 检查文件是否在正确的文件夹中
- 尝试 Clean Build Folder (Cmd+Shift+K)
- 重新添加文件到项目

**运行时找不到 JSON**
- 确保 JSON 文件已勾选 target
- 检查 Build Phases → Copy Bundle Resources

---

## 📚 参考资源

- [VocFr 项目文档](../../README.md)
- [Storybook 导入指南](../Storybooks/STORYBOOK_IMPORT_GUIDE.md)
- [数据模型说明](../../docs/DATA_MODEL.md)

---

## 💡 提示

- 💾 **备份数据**：导入前备份现有 JSON 文件
- 🧪 **测试优先**：使用 `--dry-run` 预览结果
- 📝 **保留 CSV**：CSV 源文件作为数据的原始记录
- 🔄 **版本控制**：JSON 和 CSV 都提交到 Git

---

需要帮助？查看 [README.md](../../README.md) 或提交 Issue。
