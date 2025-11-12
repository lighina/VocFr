#!/usr/bin/env python3
"""
Fix vocabulary.json partOfSpeech/genderOrPos fields
"""
import json
import re

def get_part_of_speech(gender_or_pos: str) -> str:
    """
    Convert genderOrPos to actual partOfSpeech following FrenchWord.swift logic
    """
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

def fix_vocabulary_json(input_file: str, output_file: str):
    """Fix partOfSpeech and genderOrPos in vocabulary.json"""

    print("📖 Reading vocabulary.json...")
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    total_words = 0
    fixed_words = 0

    for unite in data['unites']:
        for section in unite['sections']:
            for word in section['words']:
                total_words += 1

                # Current (incorrect) values
                current_pos = word['partOfSpeech']
                current_gender_or_pos = word['genderOrPos']

                # The current genderOrPos actually contains the correct value
                # that should be used to determine partOfSpeech
                correct_pos = get_part_of_speech(current_gender_or_pos)

                # Update if different
                if current_pos != correct_pos:
                    word['partOfSpeech'] = correct_pos
                    fixed_words += 1
                    print(f"  Fixed: {word['canonical']}")
                    print(f"    Old: partOfSpeech={current_pos}, genderOrPos={current_gender_or_pos}")
                    print(f"    New: partOfSpeech={correct_pos}, genderOrPos={current_gender_or_pos}")

    print(f"\n✅ Processed {total_words} words, fixed {fixed_words} words")

    print(f"\n💾 Writing corrected JSON to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("✅ Done!")

if __name__ == "__main__":
    fix_vocabulary_json(
        "VocFr/Data/JSON/vocabulary.json",
        "VocFr/Data/JSON/vocabulary.json"
    )
