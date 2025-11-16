#!/usr/bin/env python3
"""
Rename Image Sets with French accents to ASCII-safe names.

This script renames both the Image Set directories and updates the
imageName values in the seeding code to use ASCII-only names.
"""

import os
import re
import unicodedata
import shutil

# Mapping of accented names to ASCII-safe names
RENAME_MAP = {
    'mère_image': 'mere_image',
    'père_image': 'pere_image',
    'grand-mère_image': 'grand_mere_image',
    'grand-père_image': 'grand_pere_image',
    'frère_image': 'frere_image',
    'derrière_image': 'derriere_image',
    'fenêtre_image': 'fenetre_image',
    'école_image': 'ecole_image',
    'écouter_image': 'ecouter_image',
    'éponge_image': 'eponge_image',
    'zéro_image': 'zero_image',
    'garçon_image': 'garcon_image',
}

def rename_imagesets():
    """Rename Image Set directories."""
    assets_dir = 'VocFr/Assets.xcassets'
    renamed = []

    print("📁 Renaming Image Set directories...\n")

    for old_name, new_name in RENAME_MAP.items():
        old_dir = os.path.join(assets_dir, f'{old_name}.imageset')
        new_dir = os.path.join(assets_dir, f'{new_name}.imageset')

        if os.path.exists(old_dir):
            # Normalize paths for macOS
            old_dir_norm = unicodedata.normalize('NFD', old_dir)

            # Try both NFC and NFD versions
            actual_old_dir = None
            if os.path.exists(old_dir):
                actual_old_dir = old_dir
            elif os.path.exists(old_dir_norm):
                actual_old_dir = old_dir_norm

            if actual_old_dir:
                print(f"  ✏️  {old_name}.imageset → {new_name}.imageset")
                shutil.move(actual_old_dir, new_dir)
                renamed.append((old_name, new_name))
            else:
                print(f"  ⚠️  Not found: {old_name}.imageset")
        else:
            print(f"  ℹ️  Already renamed or not found: {old_name}.imageset")

    return renamed

def update_seed_file(renamed):
    """Update imageName values in FrenchWord.swift."""
    seed_file = 'VocFr/Data/Seeds/FrenchWord.swift'

    print(f"\n📝 Updating {seed_file}...\n")

    with open(seed_file, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    replacements = 0

    for old_name, new_name in renamed:
        # Replace in string literals
        old_pattern = f'"{old_name}"'
        new_pattern = f'"{new_name}"'
        count = content.count(old_pattern)
        if count > 0:
            content = content.replace(old_pattern, new_pattern)
            replacements += count
            print(f"  ✅ Replaced '{old_name}' → '{new_name}' ({count} occurrences)")

    if content != original_content:
        with open(seed_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\n  💾 Saved {replacements} replacements")
    else:
        print("  ℹ️  No changes needed")

    return replacements

def update_contents_json(renamed):
    """Update Contents.json files in renamed imagesets."""
    assets_dir = 'VocFr/Assets.xcassets'

    print(f"\n📋 Updating Contents.json files...\n")

    for old_name, new_name in renamed:
        imageset_dir = os.path.join(assets_dir, f'{new_name}.imageset')
        contents_json = os.path.join(imageset_dir, 'Contents.json')

        if os.path.exists(contents_json):
            with open(contents_json, 'r', encoding='utf-8') as f:
                content = f.read()

            # Update PNG filename references
            old_png = f'{old_name}.png'
            new_png = f'{new_name}.png'

            if old_png in content:
                content = content.replace(old_png, new_png)

                with open(contents_json, 'w', encoding='utf-8') as f:
                    f.write(content)

                print(f"  ✅ Updated {new_name}.imageset/Contents.json")

                # Also rename the PNG file if it exists
                old_png_path = os.path.join(imageset_dir, old_png)
                new_png_path = os.path.join(imageset_dir, new_png)

                if os.path.exists(old_png_path):
                    os.rename(old_png_path, new_png_path)
                    print(f"  ✅ Renamed PNG: {old_png} → {new_png}")

def main():
    print("🛠️  VocFr Image Asset ASCII Name Converter\n")
    print("This will rename all Image Sets with French accents to ASCII-safe names.\n")

    if not os.path.exists('VocFr.xcodeproj'):
        print("❌ Error: VocFr.xcodeproj not found")
        print("Please run this from the project root directory")
        return 1

    # Step 1: Rename Image Set directories
    renamed = rename_imagesets()

    if not renamed:
        print("\n✨ All Image Sets already have ASCII names!")
        return 0

    # Step 2: Update Contents.json files
    update_contents_json(renamed)

    # Step 3: Update seed file
    update_seed_file(renamed)

    print("\n" + "="*60)
    print("✨ Summary:")
    print(f"   Renamed: {len(renamed)} Image Sets")
    print(f"   Updated: FrenchWord.swift")
    print("="*60)

    print("\n📝 Next steps:")
    print("1. In Xcode: Product → Clean Build Folder (Shift+Cmd+K)")
    print("2. Delete the app from simulator (long press → delete)")
    print("3. Build and run (Cmd+R)")
    print("4. Images should now display correctly!")

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
