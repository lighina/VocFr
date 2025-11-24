#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
batch_generate_images.py

Batch generate Studio Ghibli watercolor images for all Unite vocabulary words.

This script:
- Scans VocFr/Data/JSON/ for all UniteX.json files
- Generates images for all words with 'nameOfImage' field
- Outputs to VocFr/Resources/Images/tempVocPic/ by default
- Skips existing files by default (configurable)
- Supports dry-run mode for preview

Usage:
    # Preview what will be generated
    python batch_generate_images.py --dry-run

    # Generate all images
    python batch_generate_images.py

    # Generate with specific options
    python batch_generate_images.py --size 1024x1024 --target 512

    # Force regenerate all (skip existing = false)
    python batch_generate_images.py --no-skip-existing
"""

import os
import sys
import argparse
from pathlib import Path
from typing import List, Tuple, Dict, Any

# Add parent directory to path to import generate_image module
sys.path.insert(0, str(Path(__file__).parent))

from generate_image import (
    get_project_root,
    get_unite_json_path,
    get_default_output_dir,
    load_unite_json,
    iter_words_with_images,
    get_canonical,
    process_word,
)


def get_all_unites() -> List[int]:
    """
    Scan VocFr/Data/JSON/ directory for all UniteX.json files.
    Returns sorted list of unite numbers.
    """
    project_root = get_project_root()
    json_dir = project_root / "VocFr" / "Data" / "JSON"

    if not json_dir.exists():
        raise FileNotFoundError(f"JSON directory not found: {json_dir}")

    unite_numbers = []
    for json_file in json_dir.glob("Unite*.json"):
        try:
            # Extract number from UniteX.json
            num_str = json_file.stem.replace("Unite", "")
            unite_num = int(num_str)
            unite_numbers.append(unite_num)
        except ValueError:
            print(f"Warning: Could not parse unite number from {json_file.name}")
            continue

    return sorted(unite_numbers)


def get_words_to_generate(
    unite_num: int,
    output_dir: Path,
    skip_existing: bool = True
) -> Tuple[List[Dict[str, Any]], int, int]:
    """
    Get list of words to generate for a given unite.

    Returns:
        (words_to_generate, total_words, skipped_count)
    """
    json_path = get_unite_json_path(unite_num)

    if not json_path.exists():
        print(f"Warning: Unite {unite_num} JSON not found at {json_path}")
        return [], 0, 0

    try:
        data = load_unite_json(str(json_path))
        all_words = list(iter_words_with_images(data))

        if not skip_existing:
            return all_words, len(all_words), 0

        # Filter out words with existing images
        words_to_generate = []
        skipped = 0

        for word in all_words:
            image_name = word.get("nameOfImage")
            if not image_name:
                continue

            image_path = output_dir / image_name
            if image_path.exists():
                skipped += 1
            else:
                words_to_generate.append(word)

        return words_to_generate, len(all_words), skipped

    except Exception as e:
        print(f"Error loading Unite {unite_num}: {e}")
        return [], 0, 0


def main():
    parser = argparse.ArgumentParser(
        description="Batch generate Studio Ghibli watercolor images for all Unites."
    )
    parser.add_argument(
        "--outdir", "-o",
        help="Output directory. Default: VocFr/Resources/Images/tempVocPic",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview mode: show what would be generated without actually generating.",
    )
    parser.add_argument(
        "--no-skip-existing",
        action="store_true",
        help="Regenerate all images, even if they already exist.",
    )
    parser.add_argument(
        "--remove-background",
        action="store_true",
        help="Apply naive background removal to final images.",
    )
    parser.add_argument(
        "--save-raw",
        action="store_true",
        help="Save raw model output before cropping.",
    )
    parser.add_argument(
        "--size",
        default="1024x1024",
        help="OpenAI generation size (default: 1024x1024).",
    )
    parser.add_argument(
        "--target",
        type=int,
        default=512,
        help="Final output size in pixels (default: 512).",
    )
    parser.add_argument(
        "--unites",
        help="Comma-separated list of unite numbers to process (e.g., '1,2,3'). Default: all",
    )

    args = parser.parse_args()

    # Determine output directory
    if args.outdir:
        output_dir = Path(args.outdir)
    else:
        output_dir = get_default_output_dir()

    output_dir.mkdir(parents=True, exist_ok=True)
    skip_existing = not args.no_skip_existing

    # Get unite numbers to process
    if args.unites:
        try:
            unite_numbers = [int(x.strip()) for x in args.unites.split(",")]
        except ValueError:
            print(f"Error: Invalid unite numbers: {args.unites}")
            return 1
    else:
        unite_numbers = get_all_unites()

    if not unite_numbers:
        print("No Unite JSON files found.")
        return 1

    print("=" * 70)
    print("VocFr Batch Image Generation")
    print("=" * 70)
    print(f"Output directory: {output_dir}")
    print(f"Skip existing: {skip_existing}")
    print(f"Unites to process: {unite_numbers}")
    print(f"Mode: {'DRY RUN (preview only)' if args.dry_run else 'GENERATE'}")
    print("=" * 70)
    print()

    # Scan all unites
    total_words = 0
    total_to_generate = 0
    total_skipped = 0

    generation_plan = []

    for unite_num in unite_numbers:
        words, count, skipped = get_words_to_generate(
            unite_num, output_dir, skip_existing
        )

        total_words += count
        total_to_generate += len(words)
        total_skipped += skipped

        if words or count > 0:
            generation_plan.append((unite_num, words, count, skipped))

            status = f"Unite {unite_num}: {len(words)} to generate"
            if skipped > 0:
                status += f", {skipped} exist"
            if count > 0:
                status += f" (total: {count})"
            print(status)

    print()
    print("=" * 70)
    print(f"Summary:")
    print(f"  Total words with images: {total_words}")
    print(f"  To generate: {total_to_generate}")
    print(f"  Skipped (existing): {total_skipped}")
    print("=" * 70)

    if args.dry_run:
        print("\n[DRY RUN] No images were generated.")
        print("Remove --dry-run to actually generate images.")
        return 0

    if total_to_generate == 0:
        print("\nNo images to generate. All images already exist.")
        print("Use --no-skip-existing to regenerate all images.")
        return 0

    # Confirmation
    print()
    response = input(f"Generate {total_to_generate} images? [y/N]: ")
    if response.lower() not in ('y', 'yes'):
        print("Cancelled.")
        return 0

    print()
    print("=" * 70)
    print("Starting generation...")
    print("=" * 70)
    print()

    # Generate images
    success_count = 0
    failure_count = 0

    for unite_num, words, total, skipped in generation_plan:
        if not words:
            continue

        print(f"\n--- Unite {unite_num} ({len(words)} words) ---")

        for i, word in enumerate(words, 1):
            canonical = get_canonical(word)
            image_name = word.get("nameOfImage", "unknown")

            try:
                print(f"  [{i}/{len(words)}] {canonical} ({image_name})...", end=" ")
                final_path = process_word(
                    word,
                    outdir=str(output_dir),
                    remove_background=args.remove_background,
                    save_raw=args.save_raw,
                    size=args.size,
                    target=args.target,
                    default_icon=True,
                )
                print("✓")
                success_count += 1
            except Exception as e:
                print(f"✗ ({e})")
                failure_count += 1

    print()
    print("=" * 70)
    print("Generation complete!")
    print(f"  Success: {success_count}")
    print(f"  Failed: {failure_count}")
    print("=" * 70)

    return 0 if failure_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
