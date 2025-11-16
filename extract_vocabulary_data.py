#!/usr/bin/env python3
"""
Extract vocabulary data from FrenchWord.swift to JSON format.

This script parses the hardcoded Swift data and generates vocabulary.json
"""

import re
import json
from datetime import datetime
from typing import List, Dict, Any, Tuple, Optional

def parse_word_tuple(line: str) -> Optional[Tuple[str, str, str, str, Optional[str]]]:
    """
    Parse a word tuple line like:
    ("bureau", "课桌", "masculine", "school_objects", nil),
    or
    ("éponge", "海绵", "feminine", "school_objects", "elision"),

    Returns: (canonical, chinese, genderOrPos, category, elision)
    """
    # Match pattern: ("word", "chinese", "gender", "category", nil/Some),
    pattern = r'\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)",\s*"([^"]+)",\s*(nil|"[^"]+")?\)'

    match = re.search(pattern, line)
    if match:
        canonical = match.group(1)
        chinese = match.group(2)
        gender_or_pos = match.group(3)
        category = match.group(4)
        elision_raw = match.group(5)

        # Parse elision
        elision = None
        if elision_raw and elision_raw != 'nil':
            elision = elision_raw.strip('"')

        return (canonical, chinese, gender_or_pos, category, elision)

    return None

def extract_section_data(content: str, section_func_name: str) -> Optional[Dict[str, Any]]:
    """Extract data from a createSection function"""

    # Find the function
    pattern = rf'private static func {section_func_name}\(\) -> Section \{{(.*?)^\s*return section\s*$.*?^\s*\}}'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)

    if not match:
        print(f"Warning: Could not find function {section_func_name}")
        return None

    func_content = match.group(1)

    # Extract section info
    section_id_match = re.search(r'Section\(id: "([^"]+)", name: "([^"]+)", orderIndex: (\d+)\)', func_content)
    if not section_id_match:
        return None

    section_id = section_id_match.group(1)
    section_name = section_id_match.group(2)
    order_index = int(section_id_match.group(3))

    # Extract words array
    words_pattern = r'let \w+Words: \[\(String, String, String, String, String\?\)\] = \[(.*?)\]'
    words_match = re.search(words_pattern, func_content, re.DOTALL)

    if not words_match:
        print(f"Warning: No words array found in {section_func_name}")
        return {
            "id": section_id,
            "name": section_name,
            "orderIndex": order_index,
            "words": []
        }

    words_content = words_match.group(1)

    # Parse each word tuple
    words = []
    for line in words_content.split('\n'):
        word_data = parse_word_tuple(line)
        if word_data:
            canonical, chinese, gender_or_pos, category, elision = word_data

            word = {
                "canonical": canonical,
                "chinese": chinese,
                "partOfSpeech": "noun" if gender_or_pos in ["masculine", "feminine"] else "verb",
                "genderOrPos": gender_or_pos,
                "category": category,
                "elision": elision == "elision" if elision else False
            }
            words.append(word)

    return {
        "id": section_id,
        "name": section_name,
        "orderIndex": order_index,
        "words": words
    }

def extract_unite_data(content: str, unite_num: int) -> Optional[Dict[str, Any]]:
    """Extract data for a specific unite"""

    func_name = f"createUnite{unite_num}"

    # Find the function
    pattern = rf'private static func {func_name}\(\) -> Unite \{{(.*?)^\s*return unite{unite_num}\s*$.*?^\s*\}}'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)

    if not match:
        print(f"Warning: Could not find function {func_name}")
        return None

    func_content = match.group(1)

    # Extract unite info
    unite_pattern = r'Unite\(\s*id: "([^"]+)",\s*number: (\d+),\s*title: "([^"]+)",\s*isUnlocked: (true|false),\s*requiredStars: (\d+)\s*\)'
    unite_match = re.search(unite_pattern, func_content, re.DOTALL)

    if not unite_match:
        return None

    unite_id = unite_match.group(1)
    number = int(unite_match.group(2))
    title = unite_match.group(3)
    is_unlocked = unite_match.group(4) == "true"
    required_stars = int(unite_match.group(5))

    # Extract section references
    sections_pattern = r'unite\d+\.sections = \[(.*?)\]'
    sections_match = re.search(sections_pattern, func_content, re.DOTALL)

    section_funcs = []
    if sections_match:
        sections_content = sections_match.group(1)
        # Find all createSection calls
        section_funcs = re.findall(r'createSection(\d+_\d+)\(\)', sections_content)

    # Extract each section's data
    sections = []
    for section_func in section_funcs:
        section_data = extract_section_data(content, f"createSection{section_func}")
        if section_data:
            sections.append(section_data)

    return {
        "id": unite_id,
        "number": number,
        "title": title,
        "isUnlocked": is_unlocked,
        "requiredStars": required_stars,
        "sections": sections
    }

def main():
    """Main extraction function"""
    print("🔧 Extracting vocabulary data from FrenchWord.swift...\n")

    # Read the Swift file
    swift_file = "VocFr/Data/Seeds/FrenchWord.swift"

    try:
        with open(swift_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"❌ Error: {swift_file} not found")
        print("Please run this script from the VocFr project root directory")
        return 1

    print("📖 Parsing Swift code...\n")

    # Extract all unites (1, 2, 3)
    unites = []
    for unite_num in [1, 2, 3]:
        print(f"  Extracting Unité {unite_num}...")
        unite_data = extract_unite_data(content, unite_num)
        if unite_data:
            word_count = sum(len(s['words']) for s in unite_data['sections'])
            print(f"    ✅ {len(unite_data['sections'])} sections, {word_count} words")
            unites.append(unite_data)
        else:
            print(f"    ⚠️  Could not extract Unité {unite_num}")

    # Build final JSON structure
    vocabulary_data = {
        "version": "1.0",
        "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
        "description": "VocFr Vocabulary Data - French Learning App",
        "unites": unites
    }

    # Write JSON file
    output_file = "VocFr/Data/JSON/vocabulary.json"
    print(f"\n💾 Writing to {output_file}...")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(vocabulary_data, f, ensure_ascii=False, indent=2)

    # Statistics
    total_sections = sum(len(u['sections']) for u in unites)
    total_words = sum(sum(len(s['words']) for s in u['sections']) for u in unites)

    print("\n" + "="*60)
    print("✨ Extraction Summary:")
    print(f"   Unités: {len(unites)}")
    print(f"   Sections: {total_sections}")
    print(f"   Words: {total_words}")
    print(f"   Output: {output_file}")
    print("="*60)

    return 0

if __name__ == '__main__':
    import sys
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\n⚠️  Operation cancelled")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
