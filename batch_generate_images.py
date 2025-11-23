#!/usr/bin/env python3
"""
Batch generate image files for all Unités and Sections.

This script automatically generates educational illustration images for all words
across all Unités and Sections in the VocFr vocabulary using OpenAI DALL-E.

Usage:
    python batch_generate_images.py [--api-key API_KEY] [--model MODEL]

Examples:
    # Generate all images with default settings
    python batch_generate_images.py

    # Use DALL-E 2 (cheaper)
    python batch_generate_images.py --model dall-e-2

    # Dry run (show what would be generated without actually generating)
    python batch_generate_images.py --dry-run
"""

import json
import os
import sys
import time
from pathlib import Path
from typing import Dict, List, Tuple
import argparse

try:
    from openai import OpenAI
except ImportError:
    print("❌ Error: OpenAI library not installed.")
    print("📦 Install with: pip install openai")
    sys.exit(1)

# Import from generate_image_dalle.py
from generate_image_dalle import (
    generate_images_for_section,
    load_unite_data
)


def get_all_sections() -> List[Tuple[int, int, str, int]]:
    """
    Get all Unite and Section combinations from JSON files.

    Returns:
        List of tuples: (unite_number, section_index, section_name, word_count)
    """
    sections = []
    base_path = Path(__file__).parent / "VocFr" / "Data" / "JSON"

    # Try to find all Unite JSON files
    for unite_num in range(1, 10):  # Try up to Unite 9
        unite_file = base_path / f"Unite{unite_num}.json"
        if not unite_file.exists():
            continue

        try:
            unite_data = load_unite_data(unite_num)
            for section in unite_data['sections']:
                section_index = section['orderIndex']
                section_name = section['name']

                # Count words that should have images (exclude nameOfImage='none')
                word_count = 0
                for word in section['words']:
                    name_of_image = word.get('nameOfImage', '')
                    if not (name_of_image and name_of_image.lower() in ['none', 'null']):
                        word_count += 1

                sections.append((unite_num, section_index, section_name, word_count))
        except Exception as e:
            print(f"⚠️  Warning: Failed to load Unite {unite_num}: {e}")
            continue

    return sections


def estimate_cost(total_words: int, model: str = "dall-e-3", size: str = "1024x1024") -> Tuple[float, float]:
    """
    Estimate the cost of generating images for all words.

    Args:
        total_words: Total number of words to generate
        model: DALL-E model to use
        size: Image size

    Returns:
        (estimated_cost_usd, cost_per_image)
    """
    # Pricing (as of 2025-11)
    if model == "dall-e-3":
        if size == "1024x1024":
            cost_per_image = 0.040
        else:  # 1024x1792 or 1792x1024
            cost_per_image = 0.080
    else:  # dall-e-2
        if size == "256x256":
            cost_per_image = 0.016
        elif size == "512x512":
            cost_per_image = 0.018
        else:  # 1024x1024
            cost_per_image = 0.020

    estimated_cost = total_words * cost_per_image

    return estimated_cost, cost_per_image


def main():
    parser = argparse.ArgumentParser(
        description="Batch generate images for all VocFr vocabulary"
    )
    parser.add_argument(
        '--api-key', '-k',
        type=str,
        help='OpenAI API key (or set OPENAI_API_KEY environment variable)'
    )
    parser.add_argument(
        '--model', '-m',
        type=str,
        default='dall-e-3',
        choices=['dall-e-2', 'dall-e-3'],
        help='DALL-E model (default: dall-e-3)'
    )
    parser.add_argument(
        '--size',
        type=str,
        default='1024x1024',
        help='Image size (default: 1024x1024)'
    )
    parser.add_argument(
        '--gpt-model',
        type=str,
        default='gpt-4o-mini',
        choices=['gpt-4o-mini', 'gpt-4o', 'gpt-4'],
        help='GPT model for scene descriptions (default: gpt-4o-mini)'
    )
    parser.add_argument(
        '--output-dir', '-o',
        type=str,
        help='Output directory (default: /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Images/tempVocPic/)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be generated without actually generating'
    )
    parser.add_argument(
        '--skip-existing',
        action='store_true',
        default=True,
        help='Skip sections that already have image files (default: True)'
    )
    parser.add_argument(
        '--delay',
        type=float,
        default=1.0,
        help='Delay in seconds between API calls (default: 1.0)'
    )

    args = parser.parse_args()

    # Get API key
    if not args.dry_run:
        api_key = args.api_key or os.environ.get('OPENAI_API_KEY')
        if not api_key:
            print("❌ Error: OpenAI API key not provided.")
            print("   Set OPENAI_API_KEY environment variable or use --api-key option.")
            sys.exit(1)
        client = OpenAI(api_key=api_key)
    else:
        client = None

    # Set output directory
    if args.output_dir:
        output_base_dir = Path(args.output_dir)
    else:
        output_base_dir = Path("/Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Images/tempVocPic")

    # Get all sections
    print("=" * 70)
    print("🎨 VocFr Batch Image Generator")
    print("=" * 70)
    print("📊 Scanning vocabulary data...")
    print()

    sections = get_all_sections()

    if not sections:
        print("❌ No vocabulary data found!")
        sys.exit(1)

    # Calculate totals
    total_words = sum(word_count for _, _, _, word_count in sections)
    estimated_cost, cost_per_image = estimate_cost(total_words, args.model, args.size)

    # Display summary
    print(f"📚 Found {len(sections)} sections across {max(s[0] for s in sections)} Unités")
    print(f"📝 Total words to generate: {total_words}")
    print()

    # Group by Unite
    by_unite = {}
    for unite_num, section_idx, section_name, word_count in sections:
        if unite_num not in by_unite:
            by_unite[unite_num] = []
        by_unite[unite_num].append((section_idx, section_name, word_count))

    for unite_num in sorted(by_unite.keys()):
        sections_list = by_unite[unite_num]
        total_words_in_unite = sum(wc for _, _, wc in sections_list)
        print(f"  📖 Unite {unite_num}: {len(sections_list)} sections, {total_words_in_unite} words")
        for section_idx, section_name, word_count in sections_list:
            print(f"     • Section {section_idx}: {section_name} ({word_count} words)")

    print()
    print("=" * 70)
    print("⚙️  Configuration:")
    print(f"   DALL-E Model: {args.model}")
    print(f"   Image Size: {args.size}")
    print(f"   GPT Model: {args.gpt_model}")
    print(f"   Output: {output_base_dir}")
    print(f"   Delay: {args.delay}s between requests")
    print()
    print("💰 Cost Estimate:")
    print(f"   Cost per image: ${cost_per_image:.3f}")
    print(f"   Total images: {total_words}")
    print(f"   Estimated cost: ${estimated_cost:.2f} USD")
    print("=" * 70)
    print()

    if args.dry_run:
        print("🔍 DRY RUN - No images will be generated")
        print()
        for unite_num, section_idx, section_name, word_count in sections:
            print(f"Would generate: Unite {unite_num}, Section {section_idx} ({section_name}): {word_count} words")
        print()
        print(f"✅ Dry run complete. Total: {total_words} words, ~${estimated_cost:.2f}")
        return

    # Confirm before proceeding
    print("⚠️  WARNING: Image generation is expensive!")
    print(f"   This will cost approximately ${estimated_cost:.2f} USD")
    print(f"   Each image costs ${cost_per_image:.3f}")
    print()
    response = input("⚠️  Proceed with image generation? (yes/no): ").strip().lower()
    if response not in ['yes', 'y']:
        print("❌ Cancelled by user")
        sys.exit(0)

    print()
    print("=" * 70)
    print("🎨 Starting batch generation...")
    print("=" * 70)
    print()

    # Track progress
    total_generated = 0
    total_skipped = 0
    total_failed = 0
    start_time = time.time()

    # Generate for each section
    for i, (unite_num, section_idx, section_name, word_count) in enumerate(sections, 1):
        print(f"[{i}/{len(sections)}] Unite {unite_num}, Section {section_idx}: {section_name}")
        print(f"   Words: {word_count}")

        # Check if section already has image files
        if args.skip_existing and output_base_dir.exists():
            existing_files = list(output_base_dir.glob("*_image.png"))
            # This is a rough check - we'd need to check specific words
            # For now, we'll let the individual function handle skipping
            pass

        try:
            success, total = generate_images_for_section(
                client=client,
                unite_num=unite_num,
                section_num=section_idx,
                output_base_dir=output_base_dir,
                model=args.model,
                size=args.size,
                gpt_model=args.gpt_model,
                delay=args.delay
            )

            total_generated += success
            if success < total:
                total_failed += (total - success)

            print(f"   ✅ Generated {success}/{total} images")

        except Exception as e:
            print(f"   ❌ Error: {e}")
            total_failed += word_count

        print()

        # Small delay between sections to avoid rate limiting
        if i < len(sections):
            time.sleep(1.0)

    # Final summary
    elapsed_time = time.time() - start_time
    actual_cost = total_generated * cost_per_image

    print("=" * 70)
    print("🎉 Batch Generation Complete!")
    print("=" * 70)
    print(f"✅ Successfully generated: {total_generated} images")
    if total_skipped > 0:
        print(f"⏭️  Skipped (existing): {total_skipped} images")
    if total_failed > 0:
        print(f"❌ Failed: {total_failed} images")
    print(f"⏱️  Total time: {elapsed_time:.1f} seconds ({elapsed_time/60:.1f} minutes)")
    print(f"💰 Actual cost: ${actual_cost:.2f} USD")
    print("=" * 70)

    if total_failed > 0:
        print()
        print("⚠️  Some images failed to generate. You may want to:")
        print("   1. Check your API key and quota")
        print("   2. Re-run the script (it will skip existing files)")
        sys.exit(1)


if __name__ == '__main__':
    main()
