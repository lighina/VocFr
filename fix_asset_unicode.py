#!/usr/bin/env python3
"""
Fix Unicode normalization issues in VocFr asset filenames.

This script converts all image filenames from NFC (Normalization Form Composed)
to NFD (Normalization Form Decomposed) to match macOS filesystem expectations.

macOS uses NFD: é = e + combining acute accent (2 characters)
Linux/Git uses NFC: é = precomposed character (1 character)
"""

import os
import unicodedata
import shutil
import sys

def normalize_filename(filename, target_form='NFD'):
    """Normalize filename to target Unicode form."""
    return unicodedata.normalize(target_form, filename)

def fix_assets_unicode():
    """Fix all image asset filenames in the project."""

    assets_dir = 'VocFr/Assets.xcassets'

    if not os.path.exists(assets_dir):
        print(f"❌ Error: {assets_dir} not found")
        print("Please run this script from the VocFr project root directory")
        sys.exit(1)

    print("🔍 Scanning for images with French accents...\n")

    fixed_count = 0
    error_count = 0

    # Special case: Fix the typo in derrière_image.png
    typo_fixes = {
        'derrièr_image.png': 'derrière_image.png'
    }

    for root, dirs, files in os.walk(assets_dir):
        if not root.endswith('.imageset'):
            continue

        imageset_name = os.path.basename(root)

        # Check if this imageset has accented characters
        if not any(c in imageset_name for c in ['é', 'è', 'ê', 'à', 'ç', 'ô', 'ù', 'î']):
            continue

        print(f"📁 Processing: {imageset_name}")

        for filename in files:
            if not filename.endswith('.png'):
                continue

            old_path = os.path.join(root, filename)

            # First, fix any typos
            new_filename = typo_fixes.get(filename, filename)

            # Then normalize to NFD for macOS
            new_filename_nfd = normalize_filename(new_filename, 'NFD')
            new_path = os.path.join(root, new_filename_nfd)

            # Check if normalization or typo fix is needed
            if old_path != new_path:
                try:
                    # Rename the file
                    print(f"  ✏️  Renaming:")
                    print(f"     From: {filename}")
                    print(f"     To:   {new_filename_nfd}")

                    # On macOS, the filesystem automatically uses NFD
                    # so we just rename to the correct name
                    if os.path.exists(old_path):
                        shutil.move(old_path, new_path)
                        fixed_count += 1
                        print(f"  ✅ Fixed\n")
                    else:
                        print(f"  ⚠️  File not found: {old_path}\n")
                        error_count += 1

                except Exception as e:
                    print(f"  ❌ Error: {e}\n")
                    error_count += 1
            else:
                print(f"  ✓ Already correct: {filename}\n")

    print("\n" + "="*60)
    print(f"✨ Summary:")
    print(f"   Fixed: {fixed_count} files")
    if error_count > 0:
        print(f"   Errors: {error_count} files")
    print("="*60)

    if fixed_count > 0:
        print("\n📝 Next steps:")
        print("1. Open Xcode and clean the build folder (Shift+Cmd+K)")
        print("2. Rebuild the project (Cmd+B)")
        print("3. The image issues should be resolved")

    return fixed_count, error_count

if __name__ == '__main__':
    print("🛠️  VocFr Asset Filename Unicode Fixer\n")

    # Check if we're in the right directory
    if not os.path.exists('VocFr.xcodeproj'):
        print("❌ Error: VocFr.xcodeproj not found")
        print("Please run this script from the VocFr project root:")
        print("  cd /Volumes/DevSSD/Code/Swift/Projects/VocFr")
        print("  python3 fix_asset_unicode.py")
        sys.exit(1)

    try:
        fixed, errors = fix_assets_unicode()
        sys.exit(0 if errors == 0 else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️  Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
