#!/usr/bin/env python3
"""
Check the current state of renamed Image Sets.
"""

import os
import json

RENAMED_SETS = [
    'mere_image', 'pere_image', 'grand_mere_image', 'grand_pere_image',
    'frere_image', 'derriere_image', 'fenetre_image', 'ecole_image',
    'ecouter_image', 'eponge_image', 'zero_image', 'garcon_image'
]

def check_imageset(name):
    """Check the state of an imageset."""
    assets_dir = 'VocFr/Assets.xcassets'
    imageset_dir = os.path.join(assets_dir, f'{name}.imageset')

    print(f"\n=== {name}.imageset ===")

    if not os.path.exists(imageset_dir):
        print("  ❌ Directory does not exist!")
        return

    print("  ✅ Directory exists")

    # Check Contents.json
    contents_json = os.path.join(imageset_dir, 'Contents.json')
    if os.path.exists(contents_json):
        with open(contents_json, 'r') as f:
            data = json.load(f)

        if 'images' in data and len(data['images']) > 0:
            filename = data['images'][0].get('filename', 'NO FILENAME')
            print(f"  📋 Contents.json references: {filename}")

            # Check if PNG file exists
            png_path = os.path.join(imageset_dir, filename)
            if os.path.exists(png_path):
                print(f"  ✅ PNG file exists: {filename}")
            else:
                print(f"  ❌ PNG file NOT found: {filename}")

                # List actual PNG files
                png_files = [f for f in os.listdir(imageset_dir) if f.endswith('.png')]
                if png_files:
                    print(f"  📁 Actual PNG files: {png_files}")
                else:
                    print(f"  📁 No PNG files found!")
    else:
        print("  ❌ Contents.json not found!")

def main():
    print("🔍 Checking renamed Image Sets...\n")

    for name in RENAMED_SETS:
        check_imageset(name)

    print("\n" + "="*60)

if __name__ == '__main__':
    main()
