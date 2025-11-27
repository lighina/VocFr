#!/usr/bin/env python3
"""
Generate a text file listing all words from Unite JSON files.
Output format:
    Unite 1

    Section 1

    word1
    word2
    ...
"""

import json
from pathlib import Path


def main():
    # Get project root and JSON directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    json_dir = project_root / "VocFr" / "Data" / "JSON"

    # Output file path
    output_file = json_dir / "all_words_list.txt"

    # Find all Unite JSON files
    unite_files = sorted(json_dir.glob("Unite*.json"), key=lambda x: int(x.stem.replace("Unite", "")))

    if not unite_files:
        print(f"❌ No Unite JSON files found in {json_dir}")
        return

    # Collect all content
    output_lines = []

    for unite_file in unite_files:
        # Extract unite number from filename (e.g., "Unite1.json" -> 1)
        unite_num = int(unite_file.stem.replace("Unite", ""))

        # Load JSON
        with open(unite_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Add Unite header
        output_lines.append(f"Unite {unite_num}")
        output_lines.append("")

        # Process sections
        sections = data.get("sections", [])

        for section in sections:
            section_name = section.get("name", "Unknown")
            words = section.get("words", [])

            # Add section header
            output_lines.append(f"Section {section_name}")
            output_lines.append("")

            # Add words (canonical form only)
            for word in words:
                canonical = word.get("canonical", "")
                if canonical:
                    output_lines.append(canonical)

            output_lines.append("")  # Blank line after each section

        output_lines.append("")  # Extra blank line after each unite

    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines))

    print(f"✅ Word list generated successfully!")
    print(f"📄 Output file: {output_file}")
    print(f"📊 Processed {len(unite_files)} Unite files")


if __name__ == "__main__":
    main()
