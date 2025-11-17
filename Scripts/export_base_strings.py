#!/usr/bin/env python3
"""
export_base_strings.py - Export English base strings for external translation

This script exports all English localization strings in various formats
for use with external translation services or manual translation.

Usage:
    # Export as JSON
    python export_base_strings.py --format json --output base_strings.json

    # Export as CSV
    python export_base_strings.py --format csv --output base_strings.csv

    # Export as formatted text
    python export_base_strings.py --format txt --output base_strings.txt

Output formats:
    - JSON: Structured by categories, easy to import
    - CSV: Compatible with Excel, Google Sheets
    - TXT: Human-readable format for review

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
from typing import Dict, List
from collections import defaultdict

# Base directory for the VocFr project
PROJECT_ROOT = Path(__file__).parent.parent
VOCFR_DIR = PROJECT_ROOT / "VocFr"


def parse_strings_file_with_categories(file_path: Path) -> Dict[str, List[Dict]]:
    """
    Parse a .strings file and organize entries by category.

    Returns:
        Dictionary mapping category names to lists of string entries
        Each entry is a dict with 'key' and 'value'
    """
    if not file_path.exists():
        return {}

    categories = defaultdict(list)
    current_category = "Uncategorized"

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.rstrip()

            # Check for category marker
            category_match = re.match(r'^//\s*MARK:\s*-\s*(.+)$', line)
            if category_match:
                current_category = category_match.group(1).strip()
                continue

            # Check for string entry
            string_match = re.match(r'^"([^"]+)"\s*=\s*"([^"]*)";', line)
            if string_match:
                key, value = string_match.groups()
                categories[current_category].append({
                    'key': key,
                    'value': value
                })

    return dict(categories)


def export_as_json(categories: Dict, output_path: Path, include_context: bool = True):
    """
    Export strings as JSON.

    Format:
    {
      "Category Name": [
        {
          "key": "string.key",
          "value": "English value",
          "context": "Description of where this string is used"
        }
      ]
    }
    """
    output_data = {}

    for category, entries in categories.items():
        category_entries = []
        for entry in entries:
            item = {
                'key': entry['key'],
                'value': entry['value']
            }
            if include_context:
                # Add context based on key patterns
                item['context'] = infer_context_from_key(entry['key'], category)
            category_entries.append(item)
        output_data[category] = category_entries

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"✅ Exported {count_total_strings(categories)} strings to {output_path}")


def export_as_csv(categories: Dict, output_path: Path):
    """
    Export strings as CSV.

    Columns: Category, Key, English Value, Context
    """
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Category', 'Key', 'English Value', 'Context'])

        for category, entries in categories.items():
            for entry in entries:
                context = infer_context_from_key(entry['key'], category)
                writer.writerow([
                    category,
                    entry['key'],
                    entry['value'],
                    context
                ])

    print(f"✅ Exported {count_total_strings(categories)} strings to {output_path}")


def export_as_txt(categories: Dict, output_path: Path):
    """
    Export strings as formatted text for human reading.

    Format:
    ================
    Category: Welcome View
    ================

    welcome.title
    English: "French Learning"
    Context: Main title on welcome screen
    ---
    """
    with open(output_path, 'w', encoding='utf-8') as f:
        for category, entries in categories.items():
            f.write(f"\n{'=' * 60}\n")
            f.write(f"Category: {category}\n")
            f.write(f"{'=' * 60}\n\n")

            for entry in entries:
                f.write(f"{entry['key']}\n")
                f.write(f"English: \"{entry['value']}\"\n")
                context = infer_context_from_key(entry['key'], category)
                f.write(f"Context: {context}\n")
                f.write(f"{'-' * 40}\n\n")

    print(f"✅ Exported {count_total_strings(categories)} strings to {output_path}")


def infer_context_from_key(key: str, category: str) -> str:
    """
    Infer usage context from the key name and category.

    Examples:
        "welcome.title" -> "Welcome screen title"
        "practice.button.retry" -> "Retry button in practice mode"
    """
    parts = key.split('.')

    # Common patterns
    if 'title' in key:
        return f"Title text in {category}"
    elif 'button' in key:
        action = parts[-1] if len(parts) > 1 else 'button'
        return f"Button text: {action}"
    elif 'description' in key:
        return f"Description text in {category}"
    elif 'message' in key:
        return f"Message text in {category}"
    elif 'label' in key:
        return f"Label text in {category}"
    elif 'alert' in key:
        return f"Alert message in {category}"
    elif 'placeholder' in key:
        return f"Placeholder text for input field"
    else:
        return f"Text used in {category}"


def count_total_strings(categories: Dict) -> int:
    """Count total number of strings across all categories."""
    return sum(len(entries) for entries in categories.values())


def main():
    parser = argparse.ArgumentParser(
        description='Export English base strings for external translation',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Export as JSON (recommended for re-importing)
  python export_base_strings.py --format json --output base_strings.json

  # Export as CSV for Excel/Google Sheets
  python export_base_strings.py --format csv --output base_strings.csv

  # Export as text for human review
  python export_base_strings.py --format txt --output base_strings.txt
        """
    )

    parser.add_argument('-f', '--format', choices=['json', 'csv', 'txt'],
                        required=True, help='Output format')
    parser.add_argument('-o', '--output', type=Path, required=True,
                        help='Output file path')
    parser.add_argument('--no-context', action='store_true',
                        help='Exclude context information (JSON only)')

    args = parser.parse_args()

    # Find English localization file
    en_strings_file = VOCFR_DIR / "en.lproj" / "Localizable.strings"

    if not en_strings_file.exists():
        print(f"❌ English localization file not found: {en_strings_file}")
        sys.exit(1)

    # Parse the file
    print(f"📖 Reading {en_strings_file}...")
    categories = parse_strings_file_with_categories(en_strings_file)

    if not categories:
        print("❌ No strings found in the file")
        sys.exit(1)

    print(f"📊 Found {count_total_strings(categories)} strings in {len(categories)} categories")

    # Export in the requested format
    print(f"\n📝 Exporting as {args.format.upper()}...")

    if args.format == 'json':
        export_as_json(categories, args.output, include_context=not args.no_context)
    elif args.format == 'csv':
        export_as_csv(categories, args.output)
    elif args.format == 'txt':
        export_as_txt(categories, args.output)

    print("\n✅ Export completed successfully!")


if __name__ == '__main__':
    main()
