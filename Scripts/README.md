# VocFr Localization Automation Scripts

这些Python脚本帮助您维护VocFr应用的多语言支持，自动化翻译管理流程。

## 脚本概览

### 1. add_new_strings.py - 添加新翻译字符串

当您添加新功能需要新的翻译字符串时使用此脚本。

**功能**:
- 自动将新的翻译键添加到所有7种语言文件中
- 英文直接使用您提供的值
- 其他语言标记为 `[TODO]` 等待翻译
- 支持单个字符串或批量添加（JSON文件）

**使用方法**:

```bash
# 添加单个字符串
python Scripts/add_new_strings.py \
  --key "new.feature.title" \
  --en "New Feature" \
  --category "New Feature View"

# 从JSON文件批量添加
python Scripts/add_new_strings.py --file new_strings.json
```

**JSON格式示例**:
```json
{
  "New Feature View": [
    {
      "key": "new.feature.button",
      "value": "Start New Feature",
      "translations": {
        "zh-Hans": "开始新功能",
        "fr": "Démarrer la nouvelle fonctionnalité"
      }
    }
  ]
}
```

**输出示例**:
```
📝 Adding key: "new.feature.title"
✅ Added to en.lproj (English)
✅ Added to zh-Hans.lproj (Chinese (Simplified))
✅ Added to fr.lproj (French)
✅ Added to es.lproj (Spanish)
✅ Added to de.lproj (German)
✅ Added to it.lproj (Italian)
✅ Added to pt.lproj (Portuguese)

⚠️  6 language(s) need translation for "new.feature.title"
```

---

### 2. validate_localizations.py - 验证翻译完整性

检查所有语言文件的一致性和完整性。

**功能**:
- 检测缺失的翻译键
- 发现重复的键
- 验证占位符一致性（%@, %d等）
- 找出所有标记为 `[TODO]` 的未翻译字符串
- 生成详细报告

**使用方法**:

```bash
# 基本验证
python Scripts/validate_localizations.py

# 详细输出（显示具体缺失的键）
python Scripts/validate_localizations.py --verbose

# 生成JSON报告
python Scripts/validate_localizations.py --output validation_report.json
```

**输出示例**:
```
============================================================
📊 LOCALIZATION VALIDATION REPORT
============================================================

✅ Total unique keys: 273
🌍 Languages: 7
✅ Complete languages: 7
⚠️  Incomplete languages: 0

📝 Keys per language:
  ✅ en (English): 273 keys
  ✅ zh-Hans (Chinese (Simplified)): 273 keys
  ✅ fr (French): 273 keys
  ✅ es (Spanish): 273 keys
  ✅ de (German): 273 keys
  ✅ it (Italian): 273 keys
  ✅ pt (Portuguese): 273 keys

============================================================
✅ ALL VALIDATIONS PASSED!
============================================================
```

---

### 3. export_base_strings.py - 导出基准翻译文件

导出英文基准文件，用于外部翻译或备份。

**功能**:
- 导出所有英文字符串
- 支持JSON、CSV、TXT三种格式
- 按类别组织
- 包含上下文信息

**使用方法**:

```bash
# 导出为JSON（推荐用于重新导入）
python Scripts/export_base_strings.py \
  --format json \
  --output base_strings.json

# 导出为CSV（用于Excel/Google Sheets）
python Scripts/export_base_strings.py \
  --format csv \
  --output base_strings.csv

# 导出为文本（用于人工审阅）
python Scripts/export_base_strings.py \
  --format txt \
  --output base_strings.txt

# 导出JSON但不包含上下文信息
python Scripts/export_base_strings.py \
  --format json \
  --output compact.json \
  --no-context
```

**JSON输出示例**:
```json
{
  "Welcome View": [
    {
      "key": "welcome.title",
      "value": "French Learning",
      "context": "Title text in Welcome View"
    }
  ]
}
```

---

### 4. import_translations.py - 导入外部翻译

从JSON或CSV文件导入翻译到指定语言。

**功能**:
- 从JSON或CSV文件导入翻译
- 更新现有翻译或添加新翻译
- 支持预览模式（dry-run）
- 保留文件原有结构和注释

**使用方法**:

```bash
# 导入法语翻译
python Scripts/import_translations.py \
  --language fr \
  --file french_translations.json

# 预览更改（不实际写入）
python Scripts/import_translations.py \
  --language fr \
  --file french_translations.json \
  --dry-run

# 从CSV导入
python Scripts/import_translations.py \
  --language es \
  --file spanish_translations.csv
```

**输出示例**:
```
📖 Reading translations from french_translations.json...
✅ Found 50 translation(s)

📝 Updating fr (French) translations...

✅ Results:
  Updated: 45
  Added: 5
  Unchanged: 0
  Total: 50

✅ Successfully updated VocFr/fr.lproj/Localizable.strings
```

---

## 常见工作流程

### 场景1: 添加新功能需要新的翻译字符串

```bash
# 1. 在代码中使用新的翻译键
Text("new.feature.title".localized)

# 2. 添加英文翻译到所有语言文件
python Scripts/add_new_strings.py \
  --key "new.feature.title" \
  --en "New Feature" \
  --category "New Feature View"

# 3. 如果您能翻译中文，手动编辑 VocFr/zh-Hans.lproj/Localizable.strings
# 将 "[TODO] New Feature" 替换为 "新功能"

# 4. 对于其他语言，联系AI翻译或使用GPT-5
# 5. 验证所有语言文件
python Scripts/validate_localizations.py --verbose
```

### 场景2: 检查翻译完整性

```bash
# 运行验证脚本
python Scripts/validate_localizations.py

# 如果发现缺失的翻译，导出基准文件
python Scripts/export_base_strings.py \
  --format json \
  --output missing_strings.json

# 翻译后重新导入
python Scripts/import_translations.py \
  --language fr \
  --file french_translations.json
```

### 场景3: 准备发布前的完整检查

```bash
# 1. 验证所有翻译
python Scripts/validate_localizations.py --output report.json

# 2. 检查报告，确保没有[TODO]标记
cat report.json | grep -i todo

# 3. 如果发现问题，修复后重新验证
python Scripts/validate_localizations.py

# 4. 在iOS模拟器中测试所有语言
# 打开VocFr -> Settings -> Language -> 依次测试每种语言
```

---

## 技术说明

### 支持的语言

| 代码 | 语言 | 状态 |
|------|------|------|
| en | English | ✅ |
| zh-Hans | 简体中文 | ✅ |
| fr | Français (French) | ✅ |
| es | Español (Spanish) | ✅ |
| de | Deutsch (German) | ✅ |
| it | Italiano (Italian) | ✅ |
| pt | Português (Portuguese) | ✅ |

### 文件位置

```
VocFr/
├── VocFr/
│   ├── en.lproj/Localizable.strings      # 英文（273条）
│   ├── zh-Hans.lproj/Localizable.strings # 中文（273条）
│   ├── fr.lproj/Localizable.strings      # 法语（273条）
│   ├── es.lproj/Localizable.strings      # 西班牙语（273条）
│   ├── de.lproj/Localizable.strings      # 德语（273条）
│   ├── it.lproj/Localizable.strings      # 意大利语（273条）
│   └── pt.lproj/Localizable.strings      # 葡萄牙语（273条）
└── Scripts/
    ├── add_new_strings.py
    ├── validate_localizations.py
    ├── export_base_strings.py
    ├── import_translations.py
    └── README.md                          # 本文件
```

### 占位符说明

翻译时必须保持占位符不变：

| 占位符 | 含义 | 示例 |
|--------|------|------|
| %@ | 字符串 | "Unité %@" → "Unité 1" |
| %d | 整数 | "%d stars" → "5 stars" |
| %% | 百分号 | "%d%%" → "80%" |

**示例**:
```
English: "Accuracy: %d%%"
French: "Précision : %d%%"  ✅ 正确
French: "Précision : %d%"   ❌ 错误（缺少一个%）
```

### 语言特定规则

#### 法语 (fr)
- 冒号、分号、问号、感叹号前需要空格
- 示例: `"Quel est le mot ?"` 不是 `"Quel est le mot?"`

#### 西班牙语 (es)
- 问号和感叹号需要开闭符号
- 示例: `"¿Cuál es la palabra?"` 和 `"¡Perfecto!"`

#### 德语 (de)
- 所有名词首字母大写
- 示例: `"Französisch lernen"` 不是 `"französisch lernen"`

---

## 故障排除

### 问题: 脚本报错 "No .lproj directories found"

**解决方案**:
```bash
# 检查目录结构
ls -la VocFr/*.lproj

# 确保从项目根目录运行脚本
cd /path/to/VocFr
python Scripts/validate_localizations.py
```

### 问题: 占位符不匹配错误

**解决方案**:
```bash
# 运行验证脚本查看具体问题
python Scripts/validate_localizations.py --verbose

# 手动检查并修复指定的键
# 然后重新验证
```

### 问题: 导入翻译时找不到文件

**解决方案**:
```bash
# 使用绝对路径
python Scripts/import_translations.py \
  --language fr \
  --file /absolute/path/to/translations.json

# 或确保从正确的目录运行
cd /path/to/VocFr
python Scripts/import_translations.py \
  --language fr \
  --file ./translations.json
```

---

## 最佳实践

1. **始终先验证**: 在提交代码前运行 `validate_localizations.py`
2. **使用版本控制**: 所有翻译文件都应纳入git版本控制
3. **保持一致性**: 使用相同的术语翻译相似的概念
4. **测试UI**: 切换到每种语言测试UI布局（特别是德语，单词较长）
5. **备份基准文件**: 定期导出英文基准文件作为备份

---

**创建日期**: 2025-11-16
**作者**: Claude
**版本**: 1.0
