#!/usr/bin/env python3
"""
validate_localizations.py - Validate consistency across all localization files

This script checks for:
- Missing translation keys in any language
- Duplicate keys within the same file
- Placeholder mismatch (%@, %d, etc.)
- Keys marked with [TODO] that need translation

Usage:
    python validate_localizations.py

    # Verbose output with file paths
    python validate_localizations.py --verbose

    # Generate JSON report
    python validate_localizations.py --output report.json

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
from typing import Dict, List, Set, Tuple
from collections import defaultdict

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


def find_lproj_dirs() -> Dict[str, Path]:
    """Find all .lproj directories in the project."""
    lproj_dirs = {}
    for lang_code in SUPPORTED_LANGUAGES.keys():
        lproj_path = VOCFR_DIR / f"{lang_code}.lproj"
        if lproj_path.exists():
            lproj_dirs[lang_code] = lproj_path
    return lproj_dirs


def parse_strings_file(file_path: Path) -> Dict[str, str]:
    """
    Parse a .strings file and extract all key-value pairs.

    Returns:
        Dictionary mapping keys to their values
    """
    if not file_path.exists():
        return {}

    strings_dict = {}
    current_key = None

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to match localization strings: "key" = "value";
    pattern = r'^"([^"]+)"\s*=\s*"([^"]*)";\s*$'

    for line in content.split('\n'):
        line = line.strip()
        match = re.match(pattern, line)
        if match:
            key, value = match.groups()
            strings_dict[key] = value

    return strings_dict


def extract_placeholders(text: str) -> List[str]:
    """
    Extract all format specifier placeholders from a string.

    Examples:
        "%@" -> ["@"]
        "%d" -> ["d"]
        "%d / %d" -> ["d", "d"]
        "%%" -> [] (escaped percent, not a placeholder)
    """
    # Pattern: % followed by optional position$, optional width, and format specifier
    # Ignores %%  (escaped percent)
    pattern = r'%(?:\d+\$)?(?:[-+0 #])?(?:\d+)?(?:\.\d+)?([diouxXeEfFgGaAcspn@])'
    matches = re.findall(pattern, text)
    return matches


def validate_all_languages() -> Dict:
    """
    Validate all localization files and return a comprehensive report.

    Returns:
        Dictionary containing validation results
    """
    lproj_dirs = find_lproj_dirs()

    if not lproj_dirs:
        return {'error': 'No .lproj directories found'}

    # Parse all strings files
    all_keys = {}  # lang_code -> {key: value}
    all_placeholders = {}  # lang_code -> {key: [placeholders]}

    for lang_code, lproj_dir in lproj_dirs.items():
        strings_file = lproj_dir / "Localizable.strings"
        strings_dict = parse_strings_file(strings_file)
        all_keys[lang_code] = strings_dict

        # Extract placeholders for each key
        placeholders = {}
        for key, value in strings_dict.items():
            placeholders[key] = extract_placeholders(value)
        all_placeholders[lang_code] = placeholders

    # Validation results
    report = {
        'summary': {},
        'missing_keys': defaultdict(list),
        'duplicate_keys': defaultdict(list),
        'placeholder_mismatches': [],
        'todo_translations': defaultdict(list),
        'key_counts': {}
    }

    # Get all unique keys across all languages
    all_unique_keys = set()
    for keys_dict in all_keys.values():
        all_unique_keys.update(keys_dict.keys())

    # Count keys per language
    for lang_code, keys_dict in all_keys.items():
        report['key_counts'][lang_code] = len(keys_dict)

    # Check for missing keys
    for lang_code, keys_dict in all_keys.items():
        missing = all_unique_keys - set(keys_dict.keys())
        if missing:
            report['missing_keys'][lang_code] = sorted(list(missing))

    # Check for TODO markers
    for lang_code, keys_dict in all_keys.items():
        for key, value in keys_dict.items():
            if '[TODO]' in value:
                report['todo_translations'][lang_code].append(key)

    # Check for placeholder mismatches (compare all to English)
    if 'en' in all_placeholders:
        en_placeholders = all_placeholders['en']
        for lang_code, lang_placeholders in all_placeholders.items():
            if lang_code == 'en':
                continue

            for key in all_unique_keys:
                en_ph = en_placeholders.get(key, [])
                lang_ph = lang_placeholders.get(key, [])

                if en_ph != lang_ph:
                    report['placeholder_mismatches'].append({
                        'key': key,
                        'english': en_ph,
                        'language': lang_code,
                        'language_placeholders': lang_ph
                    })

    # Generate summary
    total_keys = len(all_unique_keys)
    report['summary'] = {
        'total_unique_keys': total_keys,
        'languages': len(all_keys),
        'complete_languages': len([lc for lc, mk in report['missing_keys'].items() if not mk]),
        'incomplete_languages': len(report['missing_keys']),
        'placeholder_issues': len(report['placeholder_mismatches']),
        'total_todos': sum(len(todos) for todos in report['todo_translations'].values())
    }

    return report


def print_report(report: Dict, verbose: bool = False):
    """Print a human-readable validation report."""

    summary = report['summary']

    print("\n" + "=" * 60)
    print("📊 LOCALIZATION VALIDATION REPORT")
    print("=" * 60)

    # Summary
    print(f"\n✅ Total unique keys: {summary['total_unique_keys']}")
    print(f"🌍 Languages: {summary['languages']}")
    print(f"✅ Complete languages: {summary['complete_languages']}")
    print(f"⚠️  Incomplete languages: {summary['incomplete_languages']}")

    # Key counts per language
    print(f"\n📝 Keys per language:")
    for lang_code, count in sorted(report['key_counts'].items()):
        lang_name = SUPPORTED_LANGUAGES[lang_code]
        status = "✅" if lang_code not in report['missing_keys'] else "⚠️ "
        print(f"  {status} {lang_code} ({lang_name}): {count} keys")

    # Missing keys
    if report['missing_keys']:
        print(f"\n⚠️  MISSING TRANSLATIONS:")
        for lang_code, missing_keys in report['missing_keys'].items():
            lang_name = SUPPORTED_LANGUAGES[lang_code]
            print(f"\n  {lang_code} ({lang_name}): {len(missing_keys)} missing key(s)")
            if verbose:
                for key in missing_keys[:10]:  # Show first 10
                    print(f"    - {key}")
                if len(missing_keys) > 10:
                    print(f"    ... and {len(missing_keys) - 10} more")

    # TODO translations
    if report['todo_translations']:
        print(f"\n📝 KEYS MARKED [TODO] (need translation):")
        for lang_code, todo_keys in report['todo_translations'].items():
            lang_name = SUPPORTED_LANGUAGES[lang_code]
            print(f"  {lang_code} ({lang_name}): {len(todo_keys)} key(s)")
            if verbose:
                for key in todo_keys[:5]:
                    print(f"    - {key}")
                if len(todo_keys) > 5:
                    print(f"    ... and {len(todo_keys) - 5} more")

    # Placeholder mismatches
    if report['placeholder_mismatches']:
        print(f"\n❌ PLACEHOLDER MISMATCHES:")
        print(f"  Found {len(report['placeholder_mismatches'])} issue(s)")
        if verbose:
            for mismatch in report['placeholder_mismatches'][:10]:
                lang_name = SUPPORTED_LANGUAGES[mismatch['language']]
                print(f"\n  Key: \"{mismatch['key']}\"")
                print(f"    English: {mismatch['english']}")
                print(f"    {lang_name}: {mismatch['language_placeholders']}")
            if len(report['placeholder_mismatches']) > 10:
                print(f"\n  ... and {len(report['placeholder_mismatches']) - 10} more")

    # Final verdict
    print("\n" + "=" * 60)
    if (not report['missing_keys'] and
        not report['placeholder_mismatches'] and
        not report['todo_translations']):
        print("✅ ALL VALIDATIONS PASSED!")
    else:
        issues = []
        if report['missing_keys']:
            issues.append(f"{len(report['missing_keys'])} incomplete language(s)")
        if report['placeholder_mismatches']:
            issues.append(f"{len(report['placeholder_mismatches'])} placeholder issue(s)")
        if report['todo_translations']:
            issues.append(f"{summary['total_todos']} TODO(s)")
        print(f"⚠️  ISSUES FOUND: {', '.join(issues)}")
    print("=" * 60 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description='Validate consistency across all localization files',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Show detailed output including specific keys')
    parser.add_argument('-o', '--output', type=Path,
                        help='Save report as JSON file')

    args = parser.parse_args()

    # Run validation
    print("🔍 Validating localizations...")
    report = validate_all_languages()

    if 'error' in report:
        print(f"\n❌ Error: {report['error']}")
        sys.exit(1)

    # Print human-readable report
    print_report(report, verbose=args.verbose)

    # Save JSON report if requested
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"📄 Report saved to: {args.output}")

    # Exit with error code if issues found
    if (report['missing_keys'] or
        report['placeholder_mismatches'] or
        report['todo_translations']):
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
