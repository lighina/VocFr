#!/usr/bin/env python3
"""
Split vocabulary.json into separate Unite files

This script splits the monolithic vocabulary.json into:
- Unite1.json, Unite2.json, Unite3.json
- metadata.json

Usage:
    python3 split_vocabulary.py
"""

import json
from pathlib import Path
from datetime import datetime

def split_vocabulary():
    """Split vocabulary.json into separate files"""

    # Paths
    input_file = Path("VocFr/Data/JSON/vocabulary.json")
    output_dir = Path("VocFr/Data/JSON")

    print("=== VocFr Data Splitting Tool ===\n")

    # Read input file
    print(f"📖 Reading {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Extract metadata
    metadata = {
        "version": data.get("version", "1.0"),
        "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
        "description": "VocFr Vocabulary Data - Metadata",
        "totalUnites": len(data["unites"]),
        "availableUnites": [u["number"] for u in data["unites"]],
        "dataFormat": "split",
        "audioFormat": "timestamp"  # Will be "individual" after Phase 2.6
    }

    print(f"✅ Found {metadata['totalUnites']} unités\n")

    # Split each unite into separate file
    for unite in data["unites"]:
        unite_number = unite["number"]
        output_file = output_dir / f"Unite{unite_number}.json"

        # Calculate statistics
        section_count = len(unite["sections"])
        word_count = sum(len(s["words"]) for s in unite["sections"])

        print(f"📝 Creating {output_file.name}...")
        print(f"   - Title: {unite['title']}")
        print(f"   - Sections: {section_count}")
        print(f"   - Words: {word_count}")

        # Write unite file
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(unite, f, ensure_ascii=False, indent=2)

        # Calculate file size
        lines = len(json.dumps(unite, ensure_ascii=False, indent=2).split('\n'))
        print(f"   - Size: ~{lines} lines")
        print(f"   ✅ Created\n")

    # Write metadata file
    metadata_file = output_dir / "metadata.json"
    print(f"📝 Creating {metadata_file.name}...")
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)
    print(f"   ✅ Created\n")

    # Summary
    print("=" * 50)
    print("🎉 Split completed successfully!")
    print("\nCreated files:")
    print(f"  - metadata.json")
    for i in range(1, metadata['totalUnites'] + 1):
        print(f"  - Unite{i}.json")

    print("\n📊 Statistics:")
    total_words = sum(
        sum(len(s["words"]) for s in u["sections"])
        for u in data["unites"]
    )
    print(f"  - Total unités: {metadata['totalUnites']}")
    print(f"  - Total words: {total_words}")

    print("\n⚠️  Next steps:")
    print("  1. Verify the generated files")
    print("  2. Update VocabularyDataLoader.swift")
    print("  3. Test the app")
    print("  4. Commit changes")

if __name__ == "__main__":
    try:
        split_vocabulary()
    except FileNotFoundError as e:
        print(f"❌ Error: {e}")
        print("\n💡 Make sure you're running this from the VocFr project root")
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
