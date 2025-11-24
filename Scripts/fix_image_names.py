#!/usr/bin/env python3
"""
Fix nameOfImage fields in Unite JSON files.

Problems to fix:
1. Hyphens not converted to underscores (grands-parents, dix-sept, etc.)
2. Accented characters not converted to ASCII (café, sucré)
3. Homonym conflicts (café coffee vs café coffee shop, sucré vs sucre)
"""

import json
from pathlib import Path

def main():
    fixes = {
        'Unite2.json': [
            {
                'canonical': 'grands-parents',
                'old': 'grands-parents_image.png',
                'new': 'grands_parents_image.png',
                'reason': 'Hyphen should be underscore'
            },
            {
                'canonical': 'dix-sept',
                'old': 'dix-sept_image.png',
                'new': 'dix_sept_image.png',
                'reason': 'Hyphen should be underscore'
            },
            {
                'canonical': 'dix-huit',
                'old': 'dix-huit_image.png',
                'new': 'dix_huit_image.png',
                'reason': 'Hyphen should be underscore'
            },
            {
                'canonical': 'dix-neuf',
                'old': 'dix-neuf_image.png',
                'new': 'dix_neuf_image.png',
                'reason': 'Hyphen should be underscore'
            },
        ],
        'Unite4.json': [
            {
                'canonical': 'café',
                'chinese': '咖啡馆',
                'old': 'café_image.png',
                'new': 'cafe_place_image.png',
                'reason': 'ASCII + homonym conflict with U2 café (coffee)'
            },
            {
                'canonical': 'sucré',
                'old': 'sucré_image.png',
                'new': 'sucre_adjective_image.png',
                'reason': 'ASCII + homonym conflict with sucre (sugar)'
            },
        ]
    }

    project_root = Path(__file__).parent.parent
    json_dir = project_root / 'VocFr' / 'Data' / 'JSON'

    print('🔧 Fixing nameOfImage fields in Unite JSON files')
    print('=' * 80)

    for unite_file, fix_list in fixes.items():
        json_path = json_dir / unite_file

        if not json_path.exists():
            print(f'⚠️  {unite_file} not found, skipping')
            continue

        # Load JSON
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        changes_made = 0

        # Apply fixes
        for fix in fix_list:
            canonical = fix['canonical']
            old_name = fix['old']
            new_name = fix['new']
            reason = fix['reason']
            chinese = fix.get('chinese')

            # Find and update the word
            for section in data.get('sections', []):
                for word in section.get('words', []):
                    if word.get('canonical') == canonical:
                        # Additional check for chinese if specified (for homonyms)
                        if chinese and word.get('chinese') != chinese:
                            continue

                        if word.get('nameOfImage') == old_name:
                            word['nameOfImage'] = new_name
                            changes_made += 1
                            print(f'✓ {unite_file}: {canonical}')
                            print(f'  {old_name} → {new_name}')
                            print(f'  Reason: {reason}')
                            print()

        if changes_made > 0:
            # Save updated JSON
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f'💾 Saved {changes_made} change(s) to {unite_file}')
            print()

    print('=' * 80)
    print('✅ Done! Please review the changes and commit.')
    print()
    print('Next steps:')
    print('1. Generate missing images for the renamed files')
    print('2. Update Assets.xcassets if needed')
    print('3. Commit the JSON changes')

if __name__ == '__main__':
    main()
