#!/usr/bin/env python3
"""
Fix vocabulary.json partOfSpeech/genderOrPos fields
将 genderOrPos 字段转换为正确的 partOfSpeech
"""
import json

def get_part_of_speech(gender_or_pos):
    """根据 genderOrPos 推断正确的 partOfSpeech"""
    mapping = {
        "masculine": "noun",
        "feminine": "noun",
        "plural": "noun",
        "verb": "verb",
        "adjective": "adjective",
        "number": "number",
        "pronoun": "pronoun",
        "preposition": "preposition"
    }
    return mapping.get(gender_or_pos, "other")

# 读取 JSON
with open("VocFr/Data/JSON/vocabulary.json", 'r', encoding='utf-8') as f:
    data = json.load(f)

total_fixed = 0

# 修复所有单词
for unite in data['unites']:
    for section in unite['sections']:
        for word in section['words']:
            current_pos = word['partOfSpeech']
            gender_or_pos = word['genderOrPos']
            correct_pos = get_part_of_speech(gender_or_pos)

            if current_pos != correct_pos:
                word['partOfSpeech'] = correct_pos
                total_fixed += 1

print(f"✅ 修复了 {total_fixed} 个单词的词性")

# 写回文件
with open("VocFr/Data/JSON/vocabulary.json", 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✅ vocabulary.json 已更新！")
