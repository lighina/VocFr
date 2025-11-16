#!/usr/bin/env python3
"""
add_new_strings.py - Add new localization strings to all language files

This script helps maintain consistency across all .lproj folders by adding
new translation keys to all language files simultaneously.

Usage:
    # Add a single string
    python add_new_strings.py --key "new.feature.title" --en "New Feature" --category "New Feature View"

    # Add multiple strings from JSON file
    python add_new_strings.py --file new_strings.json

JSON Format:
{
  "Category Name": [
    {
      "key": "new.feature.button",
      "value": "Start New Feature",
      "context": "Button text on new feature page"
    }
  ]
}

Author: Claude
Date: 2025-11-16
Part: Phase D - Multi-Language Support
"""

import os
import sys
import json
import argparse
import re
from pathlib import Path
from typing import Dict, List, Optional

# Supported languages with their codes
SUPPORTED_LANGUAGES = {
    'en': 'English',
    'zh-Hans': 'Chinese (Simplified)',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese'
}

# Base directory for the VocFr project
PROJECT_ROOT = Path(__file__).parent.parent
VOCFR_DIR = PROJECT_ROOT / "VocFr"


def find_lproj_dirs() -> Dict[str, Path]:
    """
    Find all .lproj directories in the project.

    Returns:
        Dictionary mapping language codes to their .lproj directory paths
    """
    lproj_dirs = {}
    for lang_code in SUPPORTED_LANGUAGES.keys():
        lproj_path = VOCFR_DIR / f"{lang_code}.lproj"
        if lproj_path.exists():
            lproj_dirs[lang_code] = lproj_path
    return lproj_dirs


def get_localizable_strings_path(lproj_dir: Path) -> Path:
    """Get the path to Localizable.strings file in an .lproj directory."""
    return lproj_dir / "Localizable.strings"


def read_strings_file(file_path: Path) -> str:
    """Read the contents of a .strings file."""
    if not file_path.exists():
        return ""
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()


def write_strings_file(file_path: Path, content: str):
    """Write content to a .strings file."""
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)


def key_exists_in_file(content: str, key: str) -> bool:
    """Check if a key already exists in the strings file content."""
    pattern = rf'^"{re.escape(key)}"\s*='
    return bool(re.search(pattern, content, re.MULTILINE))


def add_string_to_file(
    file_path: Path,
    key: str,
    value: str,
    category: str = "New Strings",
    lang_code: str = "en"
) -> bool:
    """
    Add a new localization string to a .strings file.

    Args:
        file_path: Path to the Localizable.strings file
        key: The localization key (e.g., "new.feature.title")
        value: The translated value
        category: Category comment for organization
        lang_code: Language code for the file

    Returns:
        True if string was added, False if it already exists
    """
    content = read_strings_file(file_path)

    # Check if key already exists
    if key_exists_in_file(content, key):
        return False

    # Find the position to insert (at the end, before the final newline)
    content = content.rstrip()

    # Add category comment if this is a new category
    category_comment = f"\n// MARK: - {category}\n"
    if category_comment not in content:
        content += f"\n{category_comment}"

    # Add the new string
    new_entry = f'\n"{key}" = "{value}";\n'
    content += new_entry

    # Write back to file
    write_strings_file(file_path, content)
    return True


def add_string_to_all_languages(
    key: str,
    english_value: str,
    category: str = "New Strings",
    translations: Optional[Dict[str, str]] = None
):
    """
    Add a new string to all language files.

    Args:
        key: The localization key
        english_value: English translation
        category: Category for the string
        translations: Optional dictionary of translations for other languages
    """
    lproj_dirs = find_lproj_dirs()

    if not lproj_dirs:
        print("❌ No .lproj directories found!")
        return

    results = {}

    for lang_code, lproj_dir in lproj_dirs.items():
        strings_file = get_localizable_strings_path(lproj_dir)

        # Determine the value for this language
        if lang_code == 'en':
            value = english_value
        elif translations and lang_code in translations:
            value = translations[lang_code]
        else:
            # Mark as needing translation
            value = f"[TODO] {english_value}"

        # Add the string
        added = add_string_to_file(strings_file, key, value, category, lang_code)
        results[lang_code] = added

    # Print results
    print(f"\n📝 Adding key: \"{key}\"")
    for lang_code, added in results.items():
        lang_name = SUPPORTED_LANGUAGES[lang_code]
        if added:
            print(f"✅ Added to {lang_code}.lproj ({lang_name})")
        else:
            print(f"⚠️  Already exists in {lang_code}.lproj ({lang_name})")

    # Count languages needing translation
    todo_count = sum(1 for lang_code, added in results.items()
                     if added and lang_code != 'en')
    if todo_count > 0:
        print(f"\n⚠️  {todo_count} language(s) need translation for \"{key}\"")


def add_strings_from_json(json_file: Path):
    """
    Add multiple strings from a JSON file.

    JSON format:
    {
      "Category Name": [
        {
          "key": "string.key",
          "value": "English value",
          "translations": {
            "fr": "French value",
            "es": "Spanish value"
          }
        }
      ]
    }
    """
    if not json_file.exists():
        print(f"❌ JSON file not found: {json_file}")
        return

    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    total_added = 0

    for category, strings in data.items():
        print(f"\n📂 Category: {category}")
        for string_data in strings:
            key = string_data['key']
            value = string_data['value']
            translations = string_data.get('translations', {})

            add_string_to_all_languages(key, value, category, translations)
            total_added += 1

    print(f"\n✅ Processed {total_added} string(s) from {json_file.name}")


def main():
    parser = argparse.ArgumentParser(
        description='Add new localization strings to all language files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Add a single string
  python add_new_strings.py --key "new.button" --en "Click Me" --category "Buttons"

  # Add from JSON file
  python add_new_strings.py --file new_strings.json
        """
    )

    # Single string mode
    parser.add_argument('--key', help='Localization key (e.g., "new.feature.title")')
    parser.add_argument('--en', '--english', dest='english', help='English translation')
    parser.add_argument('--category', default='New Strings', help='Category name (default: New Strings)')

    # Batch mode
    parser.add_argument('--file', type=Path, help='JSON file with multiple strings')

    args = parser.parse_args()

    # Validate arguments
    if args.file:
        # Batch mode
        add_strings_from_json(args.file)
    elif args.key and args.english:
        # Single string mode
        add_string_to_all_languages(args.key, args.english, args.category)
    else:
        parser.print_help()
        print("\n❌ Error: Either --file or both --key and --en are required")
        sys.exit(1)


if __name__ == '__main__':
    main()
