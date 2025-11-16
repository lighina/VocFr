#!/usr/bin/env python3
"""
import_translations.py - Import translations from external sources

This script imports translations from JSON or CSV files and updates
the corresponding .lproj/Localizable.strings files.

Usage:
    # Import French translations from JSON
    python import_translations.py --language fr --file french_translations.json

    # Import Spanish translations from CSV
    python import_translations.py --language es --file spanish_translations.csv

    # Dry run (preview changes without writing)
    python import_translations.py --language fr --file fr.json --dry-run

Input formats:
    JSON: {"category": [{"key": "...", "value": "..."}]}
    CSV: Category,Key,Translation (headers required)

Author: Claude
Date: 2025-11-16
Part: Phase D - Multi-Language Support
"""

import os
import sys
import json
import csv
import argparse
import re
from pathlib import Path
from typing import Dict, List, Set

# Supported languages
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


def read_json_translations(file_path: Path) -> Dict[str, str]:
    """
    Read translations from JSON file.

    Expected format:
    {
      "Category Name": [
        {"key": "string.key", "value": "Translated value"}
      ]
    }

    Returns:
        Dictionary mapping keys to translated values
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    translations = {}

    for category, entries in data.items():
        for entry in entries:
            if 'key' in entry and 'value' in entry:
                translations[entry['key']] = entry['value']

    return translations


def read_csv_translations(file_path: Path) -> Dict[str, str]:
    """
    Read translations from CSV file.

    Expected columns: Category, Key, Translation (or similar)

    Returns:
        Dictionary mapping keys to translated values
    """
    translations = {}

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        # Try to detect column names
        fieldnames = reader.fieldnames
        if not fieldnames:
            raise ValueError("CSV file has no headers")

        # Find key and translation columns
        key_col = None
        trans_col = None

        for field in fieldnames:
            field_lower = field.lower()
            if 'key' in field_lower:
                key_col = field
            elif any(word in field_lower for word in ['translation', 'value', 'text']):
                trans_col = field

        if not key_col or not trans_col:
            raise ValueError(
                f"Could not find key and translation columns. "
                f"Available columns: {', '.join(fieldnames)}"
            )

        # Read translations
        for row in reader:
            key = row[key_col].strip()
            value = row[trans_col].strip()
            if key and value:
                translations[key] = value

    return translations


def parse_existing_strings_file(file_path: Path) -> tuple:
    """
    Parse existing .strings file and preserve structure.

    Returns:
        (content_lines, key_to_line_index)
    """
    if not file_path.exists():
        return [], {}

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Build index of keys to line numbers
    key_to_line = {}
    for i, line in enumerate(lines):
        match = re.match(r'^"([^"]+)"\s*=\s*"[^"]*";\s*$', line)
        if match:
            key = match.group(1)
            key_to_line[key] = i

    return lines, key_to_line


def update_strings_file(
    file_path: Path,
    translations: Dict[str, str],
    dry_run: bool = False
) -> Dict[str, int]:
    """
    Update a .strings file with new translations.

    Args:
        file_path: Path to Localizable.strings file
        translations: Dictionary of key -> translated value
        dry_run: If True, don't actually write changes

    Returns:
        Dictionary with statistics: {'updated': N, 'added': N, 'skipped': N}
    """
    stats = {'updated': 0, 'added': 0, 'skipped': 0}

    # Parse existing file
    lines, key_to_line = parse_existing_strings_file(file_path)

    # Process each translation
    for key, new_value in translations.items():
        # Check if key exists
        if key in key_to_line:
            # Update existing key
            line_idx = key_to_line[key]
            old_line = lines[line_idx]

            # Extract old value
            old_match = re.match(r'^"([^"]+)"\s*=\s*"([^"]*)";', old_line)
            if old_match:
                old_value = old_match.group(2)

                # Skip if translation hasn't changed
                if old_value == new_value:
                    stats['skipped'] += 1
                    continue

                # Update line
                new_line = f'"{key}" = "{new_value}";\n'
                lines[line_idx] = new_line
                stats['updated'] += 1
            else:
                stats['skipped'] += 1
        else:
            # Add new key at the end
            if not lines or not lines[-1].endswith('\n'):
                lines.append('\n')
            lines.append(f'"{key}" = "{new_value}";\n')
            stats['added'] += 1

    # Write back to file (unless dry run)
    if not dry_run:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)

    return stats


def main():
    parser = argparse.ArgumentParser(
        description='Import translations from external files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Import French translations from JSON
  python import_translations.py --language fr --file french_translations.json

  # Preview changes without writing (dry run)
  python import_translations.py --language fr --file fr.json --dry-run

  # Import from CSV
  python import_translations.py --language es --file spanish.csv
        """
    )

    parser.add_argument('-l', '--language', required=True,
                        choices=list(SUPPORTED_LANGUAGES.keys()),
                        help='Target language code')
    parser.add_argument('-f', '--file', type=Path, required=True,
                        help='Input file (JSON or CSV)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Preview changes without writing files')

    args = parser.parse_args()

    # Validate input file
    if not args.file.exists():
        print(f"❌ Input file not found: {args.file}")
        sys.exit(1)

    # Determine file format
    file_ext = args.file.suffix.lower()
    if file_ext not in ['.json', '.csv']:
        print(f"❌ Unsupported file format: {file_ext}")
        print("   Supported formats: .json, .csv")
        sys.exit(1)

    # Read translations
    print(f"📖 Reading translations from {args.file}...")
    try:
        if file_ext == '.json':
            translations = read_json_translations(args.file)
        else:  # .csv
            translations = read_csv_translations(args.file)
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        sys.exit(1)

    if not translations:
        print("❌ No translations found in file")
        sys.exit(1)

    print(f"✅ Found {len(translations)} translation(s)")

    # Find target .strings file
    lang_name = SUPPORTED_LANGUAGES[args.language]
    strings_file = VOCFR_DIR / f"{args.language}.lproj" / "Localizable.strings"

    if not strings_file.parent.exists():
        print(f"❌ Language directory not found: {strings_file.parent}")
        sys.exit(1)

    # Update the file
    if args.dry_run:
        print("\n🔍 DRY RUN MODE (no changes will be written)")

    print(f"\n📝 Updating {args.language} ({lang_name}) translations...")

    stats = update_strings_file(strings_file, translations, dry_run=args.dry_run)

    # Print results
    print(f"\n{'📋 Preview:' if args.dry_run else '✅ Results:'}")
    print(f"  Updated: {stats['updated']}")
    print(f"  Added: {stats['added']}")
    print(f"  Unchanged: {stats['skipped']}")
    print(f"  Total: {sum(stats.values())}")

    if args.dry_run:
        print("\n💡 Run without --dry-run to apply changes")
    else:
        print(f"\n✅ Successfully updated {strings_file}")


if __name__ == '__main__':
    main()
