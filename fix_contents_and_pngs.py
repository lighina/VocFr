#!/usr/bin/env python3
"""
Fix Contents.json and PNG filenames in renamed Image Sets.

This script updates the Contents.json files to reference ASCII PNG filenames
and renames the PNG files themselves.
"""

import os
import json
import shutil

# Mapping of old (with accents) to new (ASCII) names
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

def fix_imageset(old_name, new_name):
    """Fix Contents.json and PNG filename for one imageset."""
    assets_dir = 'VocFr/Assets.xcassets'
    imageset_dir = os.path.join(assets_dir, f'{new_name}.imageset')

    if not os.path.exists(imageset_dir):
        print(f"  ⚠️  Directory not found: {new_name}.imageset")
        return False

    print(f"\n=== {new_name}.imageset ===")

    # Step 1: Update Contents.json
    contents_json = os.path.join(imageset_dir, 'Contents.json')

    if not os.path.exists(contents_json):
        print(f"  ❌ Contents.json not found")
        return False

    with open(contents_json, 'r', encoding='utf-8') as f:
        data = json.load(f)

    old_png = f'{old_name}.png'
    new_png = f'{new_name}.png'

    updated = False
    for image in data.get('images', []):
        if 'filename' in image and image['filename'] == old_png:
            image['filename'] = new_png
            updated = True
            print(f"  ✅ Updated Contents.json: {old_png} → {new_png}")

    if updated:
        with open(contents_json, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    else:
        print(f"  ℹ️  Contents.json already updated or no filename found")

    # Step 2: Rename PNG file
    # Try to find the old PNG file (may be in NFC or NFD encoding)
    old_png_path = os.path.join(imageset_dir, old_png)
    new_png_path = os.path.join(imageset_dir, new_png)

    # Try to find the file
    found_file = None
    if os.path.exists(old_png_path):
        found_file = old_png_path
    else:
        # Try to find any PNG file in the directory
        for filename in os.listdir(imageset_dir):
            if filename.endswith('.png'):
                found_file = os.path.join(imageset_dir, filename)
                break

    if found_file and found_file != new_png_path:
        try:
            shutil.move(found_file, new_png_path)
            print(f"  ✅ Renamed PNG: {os.path.basename(found_file)} → {new_png}")
            return True
        except Exception as e:
            print(f"  ❌ Error renaming PNG: {e}")
            return False
    elif os.path.exists(new_png_path):
        print(f"  ℹ️  PNG already named correctly: {new_png}")
        return True
    else:
        print(f"  ⚠️  PNG file not found")
        return False

def main():
    print("🛠️  Fix Contents.json and PNG filenames\n")
    print("This will update Contents.json files and rename PNG files")
    print("in all renamed Image Sets to use ASCII-only names.\n")

    if not os.path.exists('VocFr.xcodeproj'):
        print("❌ Error: VocFr.xcodeproj not found")
        print("Please run this from the project root directory")
        return 1

    fixed_count = 0
    error_count = 0

    for old_name, new_name in RENAME_MAP.items():
        try:
            if fix_imageset(old_name, new_name):
                fixed_count += 1
            else:
                error_count += 1
        except Exception as e:
            print(f"  ❌ Unexpected error: {e}")
            error_count += 1

    print("\n" + "="*60)
    print("✨ Summary:")
    print(f"   Fixed: {fixed_count} Image Sets")
    if error_count > 0:
        print(f"   Errors: {error_count} Image Sets")
    print("="*60)

    print("\n📝 Next steps:")
    print("1. In Xcode: Product → Clean Build Folder (Shift+Cmd+K)")
    print("2. Delete the app from simulator")
    print("3. Build and run (Cmd+R)")
    print("4. All 12 accent images should now display correctly!")

    return 0 if error_count == 0 else 1

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
