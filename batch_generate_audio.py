#!/usr/bin/env python3
"""
Batch generate audio files for all Unités and Sections.

This script automatically generates audio files for all words across
all Unités and Sections in the VocFr vocabulary.

Usage:
    python batch_generate_audio.py [--api-key API_KEY] [--voice VOICE]

Examples:
    # Generate all audio with default settings
    python batch_generate_audio.py

    # Use specific voice
    python batch_generate_audio.py --voice nova

    # Dry run (show what would be generated without actually generating)
    python batch_generate_audio.py --dry-run
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

# Import from generate_audio_tts.py
from generate_audio_tts import (
    generate_audio_for_section,
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
                word_count = len(section['words'])
                sections.append((unite_num, section_index, section_name, word_count))
        except Exception as e:
            print(f"⚠️  Warning: Failed to load Unite {unite_num}: {e}")
            continue

    return sections


def estimate_cost(total_words: int, model: str = "gpt-4o-mini-tts") -> Tuple[float, int]:
    """
    Estimate the cost of generating audio for all words.

    Args:
        total_words: Total number of words to generate
        model: TTS model to use

    Returns:
        (estimated_cost_usd, total_characters)
    """
    # Average characters per audio text: "un bureau. le bureau" ≈ 23 chars
    avg_chars_per_word = 23
    total_chars = total_words * avg_chars_per_word

    # Pricing (as of 2025-11)
    if model == "gpt-4o-mini-tts":
        cost_per_1k_chars = 0.015
    elif model == "tts-1":
        cost_per_1k_chars = 0.015
    elif model == "tts-1-hd":
        cost_per_1k_chars = 0.030
    else:
        cost_per_1k_chars = 0.015  # default

    estimated_cost = (total_chars / 1000) * cost_per_1k_chars

    return estimated_cost, total_chars


def main():
    parser = argparse.ArgumentParser(
        description="Batch generate audio files for all VocFr vocabulary"
    )
    parser.add_argument(
        '--api-key', '-k',
        type=str,
        help='OpenAI API key (or set OPENAI_API_KEY environment variable)'
    )
    parser.add_argument(
        '--voice', '-v',
        type=str,
        default='alloy',
        choices=['alloy', 'ash', 'ballad', 'coral', 'echo', 'fable', 'nova', 'onyx', 'sage', 'shimmer'],
        help='TTS voice (default: alloy)'
    )
    parser.add_argument(
        '--model', '-m',
        type=str,
        default='gpt-4o-mini-tts',
        choices=['gpt-4o-mini-tts', 'tts-1', 'tts-1-hd'],
        help='TTS model (default: gpt-4o-mini-tts)'
    )
    parser.add_argument(
        '--speed',
        type=float,
        default=1.0,
        help='Speech speed (default: 1.0)'
    )
    parser.add_argument(
        '--instructions',
        type=str,
        default='Speak français slowly and clearly for language learners. Pause at periods.',
        help='Instructions for gpt-4o-mini-tts model'
    )
    parser.add_argument(
        '--output-dir', '-o',
        type=str,
        help='Output directory (default: VocFr/Resources/Audio/Words)'
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
        help='Skip sections that already have audio files (default: True)'
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
        output_base_dir = Path(__file__).parent / "VocFr" / "Resources" / "Audio" / "Words"

    # Get all sections
    print("=" * 70)
    print("🎵 VocFr Batch Audio Generator")
    print("=" * 70)
    print("📊 Scanning vocabulary data...")
    print()

    sections = get_all_sections()

    if not sections:
        print("❌ No vocabulary data found!")
        sys.exit(1)

    # Calculate totals
    total_words = sum(word_count for _, _, _, word_count in sections)
    estimated_cost, total_chars = estimate_cost(total_words, args.model)

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
    print(f"   Model: {args.model}")
    print(f"   Voice: {args.voice}")
    print(f"   Speed: {args.speed}x")
    if args.model == "gpt-4o-mini-tts" and args.instructions:
        print(f"   Instructions: {args.instructions[:50]}...")
    print(f"   Output: {output_base_dir}")
    print()
    print("💰 Cost Estimate:")
    print(f"   Total characters: ~{total_chars:,}")
    print(f"   Estimated cost: ${estimated_cost:.3f} USD")
    print("=" * 70)
    print()

    if args.dry_run:
        print("🔍 DRY RUN - No audio will be generated")
        print()
        for unite_num, section_idx, section_name, word_count in sections:
            print(f"Would generate: Unite {unite_num}, Section {section_idx} ({section_name}): {word_count} words")
        print()
        print(f"✅ Dry run complete. Total: {total_words} words, ~${estimated_cost:.3f}")
        return

    # Confirm before proceeding
    response = input("⚠️  Proceed with audio generation? (yes/no): ").strip().lower()
    if response not in ['yes', 'y']:
        print("❌ Cancelled by user")
        sys.exit(0)

    print()
    print("=" * 70)
    print("🎙️  Starting batch generation...")
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

        # Check if section already has audio files
        section_output_dir = output_base_dir / f"Unite{unite_num}" / f"Section{section_idx}"
        if args.skip_existing and section_output_dir.exists():
            existing_files = list(section_output_dir.glob("*.mp3"))
            if len(existing_files) >= word_count:
                print(f"   ⏭️  Skipping (already has {len(existing_files)} audio files)")
                total_skipped += word_count
                print()
                continue

        try:
            success, total = generate_audio_for_section(
                client=client,
                unite_num=unite_num,
                section_num=section_idx,
                output_base_dir=output_base_dir,
                voice=args.voice,
                model=args.model,
                speed=args.speed,
                instructions=args.instructions
            )

            total_generated += success
            if success < total:
                total_failed += (total - success)

            print(f"   ✅ Generated {success}/{total} files")

        except Exception as e:
            print(f"   ❌ Error: {e}")
            total_failed += word_count

        print()

        # Small delay to avoid rate limiting
        if i < len(sections):
            time.sleep(0.5)

    # Final summary
    elapsed_time = time.time() - start_time

    print("=" * 70)
    print("🎉 Batch Generation Complete!")
    print("=" * 70)
    print(f"✅ Successfully generated: {total_generated} files")
    if total_skipped > 0:
        print(f"⏭️  Skipped (existing): {total_skipped} files")
    if total_failed > 0:
        print(f"❌ Failed: {total_failed} files")
    print(f"⏱️  Total time: {elapsed_time:.1f} seconds")
    print(f"💰 Estimated cost: ${estimated_cost:.3f} USD")
    print("=" * 70)

    if total_failed > 0:
        print()
        print("⚠️  Some files failed to generate. You may want to:")
        print("   1. Check your API key and quota")
        print("   2. Re-run the script (it will skip existing files)")
        sys.exit(1)


if __name__ == '__main__':
    main()
