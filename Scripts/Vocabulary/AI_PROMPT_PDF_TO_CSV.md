# AI Prompt：从 PDF 提取词汇数据生成 CSV

本文档提供了使用 AI（ChatGPT、Claude 等）从 PDF 文件中提取法语词汇数据并生成 CSV 文件的完整 Prompt。

---

## 📋 使用流程

### 步骤 1：准备 PDF 文件
- 确保 PDF 包含法语词汇列表
- 最好包含：法语单词、中文翻译、词性、性别等信息

### 步骤 2：使用 AI 提取数据
1. 上传 PDF 到 ChatGPT/Claude
2. 复制下面的 Prompt
3. 粘贴并发送
4. AI 会分析 PDF 并生成 CSV

### 步骤 3：保存和导入
1. 将 AI 生成的 CSV 内容保存为 `.csv` 文件
2. 使用词汇导入工具导入数据
3. 在 Xcode 中添加生成的 JSON

---

## 🤖 完整 Prompt（复制使用）

```
你好！我需要你帮我从这个 PDF 文件中提取法语词汇数据，并生成符合特定格式的 CSV 文件。

## 任务要求

1. **提取词汇信息**
   - 仔细阅读 PDF 中的所有词汇
   - 提取每个单词的以下信息：
     * 法语原形（canonical）
     * 中文释义（chinese）
     * 词性（part_of_speech）
     * 性别/位置（gender_or_pos）
     * 分类（category）

2. **数据处理规则**

   **词性标准化：**
   - 名词 → noun
   - 动词 → verb
   - 形容词 → adjective
   - 副词 → adverb
   - 介词 → preposition

   **性别标准化（针对名词）：**
   - 阳性：m, le → masculine
   - 阴性：f, la → feminine

   **省音规则（elision）：**
   - 以元音开头的单词 → true
   - 以哑音 h 开头的单词 → true
   - 其他 → false

   **分类建议：**
   - school_objects（学校用品）
   - home（家居）
   - furniture（家具）
   - food（食物）
   - colors（颜色）
   - animals（动物）
   - body_parts（身体部位）
   - clothes（衣物）
   - family（家庭）
   - nature（自然）
   - 根据实际内容选择合适的分类

3. **CSV 格式要求**

   **第一行：Unite 信息**
   ```
   UNITE,unite_id,unite_number,unite_title_fr,unite_title_zh,required_stars,required_gems
   ```

   示例：
   ```
   UNITE,unite4,4,À la maison,在家里,60,0
   ```

   **Section 分隔：**
   - 根据 PDF 的章节结构划分 Section
   - 每个 Section 10-15 个单词为佳
   - 如果 PDF 没有明确章节，按主题分类

   **Section 信息行格式：**
   ```
   SECTION,section_id,section_name,order_index
   ```

   **单词数据行格式：**
   ```
   canonical,chinese,part_of_speech,gender_or_pos,category,elision
   ```

4. **完整 CSV 格式示例**

```csv
# VocFr 词汇数据
UNITE,unite4,4,À la maison,在家里,60,0

SECTION,section4_1,les pièces,1
maison,房子,noun,feminine,home,false
salon,客厅,noun,masculine,home,false
cuisine,厨房,noun,feminine,home,false
chambre,卧室,noun,feminine,home,false
salle de bain,浴室,noun,feminine,home,false

SECTION,section4_2,les meubles,2
table,桌子,noun,feminine,furniture,false
chaise,椅子,noun,feminine,furniture,false
lit,床,noun,masculine,furniture,false
armoire,衣柜,noun,feminine,furniture,false
canapé,沙发,noun,masculine,furniture,false
```

5. **特殊情况处理**

   - **缺少性别信息**：如果 PDF 没有标注性别，请根据法语语法规则推断，或标记为 "unknown"
   - **缺少中文翻译**：保留为空或使用 "-" 占位，我后续会补充
   - **多义词**：选择最常用的释义
   - **词组**：保持完整，如 "salle de bain"
   - **带连字符的词**：保持原样，如 "porte-monnaie"

6. **输出要求**

   - 直接输出完整的 CSV 内容
   - 使用逗号分隔
   - 不要使用制表符
   - 中文使用 UTF-8 编码
   - 每个字段不要加引号（除非包含逗号）

## 附加信息

**Unite 编号：** [请在这里填写，如：4]
**Unite 主题（法语）：** [请在这里填写，如：À la maison]
**Unite 主题（中文）：** [请在这里填写，如：在家里]

请开始处理这个 PDF，生成完整的 CSV 文件。如果 PDF 内容很多，可以分批次输出。
```

---

## 📝 使用示例

### 示例对话

**用户：**
```
[上传 PDF: unite4_vocabulary.pdf]
[粘贴上面的 Prompt，并填写附加信息]

Unite 编号：4
Unite 主题（法语）：À la maison
Unite 主题（中文）：在家里
```

**AI 回复：**
```csv
# VocFr 词汇数据 - Unite 4
UNITE,unite4,4,À la maison,在家里,60,0

SECTION,section4_1,les pièces de la maison,1
maison,房子,noun,feminine,home,false
appartement,公寓,noun,masculine,home,false
salon,客厅,noun,masculine,home,false
cuisine,厨房,noun,feminine,home,false
chambre,卧室,noun,feminine,home,false
salle de bain,浴室,noun,feminine,home,false
...
```

---

## 🔍 数据验证

收到 AI 生成的 CSV 后，执行验证：

```bash
# 保存 CSV 文件
# 使用验证模式检查数据
python Scripts/Vocabulary/import_vocabulary.py \
    --source ai_generated.csv \
    --output test.json \
    --validate-only
```

如果有错误，根据提示修正。

---

## ✏️ 常见修正

### 1. 性别错误

AI 可能会推断错误，常见错误：
```csv
# 错误
livre,书,noun,feminine,school,false

# 正确
livre,书,noun,masculine,school,false
```

### 2. 词性不统一

```csv
# 错误（使用了缩写）
grand,大的,adj,masculine,adjective,false

# 正确
grand,大的,adjective,masculine,adjective,false
```

### 3. 省音标记错误

```csv
# 错误
heure,小时,noun,feminine,time,false

# 正确（h 是哑音，需要省音）
heure,小时,noun,feminine,time,true
```

### 4. 分类不一致

确保同一类单词使用相同的 category：
```csv
# 统一使用 home 或 house，不要混用
maison,房子,noun,feminine,home,false
chambre,卧室,noun,feminine,home,false
```

---

## 🎯 优化建议

### 对于大型 PDF

如果 PDF 词汇量很大（>100 个单词）：

1. **分批处理**
   ```
   请先处理前 50 个单词，生成第一个 Section 的 CSV
   ```

2. **逐章节处理**
   ```
   请只处理第 3 章节的词汇，生成 section4_3 的数据
   ```

3. **合并 CSV**
   - 多个 CSV 可以手动合并
   - 或分别导入后使用 `--update` 模式

### 提高准确性

在 Prompt 中添加：

```
特别注意以下常见错误：
1. livre（书）是阳性，不是阴性
2. heure（小时）需要省音（elision = true）
3. 以 -tion 结尾的词通常是阴性
4. 以 -ment 结尾的词通常是阳性
```

---

## 🔧 手动修正流程

1. **用 Excel/Google Sheets 打开 CSV**
2. **逐行检查：**
   - 法语拼写
   - 性别正确性
   - 词性准确性
   - 分类一致性
3. **保存为 UTF-8 CSV**
4. **运行验证**

---

## 📚 参考资源

- [词汇导入指南](VOCABULARY_IMPORT_GUIDE.md)
- [CSV 模板](vocabulary_template.csv)
- [法语性别规则](https://www.francaisfacile.com/exercices/exercice-francais-2/exercice-francais-5029.php)

---

## 💡 高级技巧

### 使用 AI 批量翻译

如果 PDF 只有法语，没有中文：

```
请为以下法语单词提供准确的中文翻译，并以 CSV 格式输出：

canonical,chinese
maison,?
table,?
chaise,?
...
```

### 使用 AI 推断性别

如果 PDF 缺少性别标注：

```
请为以下法语名词标注性别（masculine 或 feminine）：

canonical,gender
maison,?
livre,?
table,?
...
```

### 使用 AI 分组分类

```
请将以下单词按主题分组，每组 10-15 个单词，并为每组命名：

maison, table, chaise, salon, cuisine, lit, armoire, ...

输出格式：
组名（法语）,组名（英文category）,单词列表
```

---

## ⚠️ 注意事项

1. **验证 AI 输出**：AI 可能会犯错，特别是性别和省音
2. **检查编码**：确保 CSV 使用 UTF-8 编码
3. **备份数据**：保留原始 PDF 和 AI 生成的 CSV
4. **逐步验证**：先验证小批量数据，确认格式正确再处理全部

---

## 🎓 学习建议

第一次使用时：
1. 从小 PDF（20-30 个单词）开始
2. 仔细检查 AI 输出
3. 熟悉常见错误类型
4. 建立自己的修正检查清单

---

需要帮助？查看 [完整导入指南](VOCABULARY_IMPORT_GUIDE.md)
