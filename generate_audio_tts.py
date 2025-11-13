#!/usr/bin/env python3
"""
Generate audio files for French vocabulary words using OpenAI TTS API.

This script reads vocabulary data from Unite JSON files and generates audio
for each word in the format: "un/une word, le/la/l' word" with a natural pause.

Usage:
    python generate_audio_tts.py [--unite UNITE_NUM] [--section SECTION_NUM] [--api-key API_KEY]

Examples:
    # Generate audio for Unite 1, Section 1 (default)
    python generate_audio_tts.py

    # Specify API key
    python generate_audio_tts.py --api-key sk-xxx

    # Generate for specific unite/section
    python generate_audio_tts.py --unite 2 --section 3
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional
import argparse
import unicodedata
import re

try:
    from openai import OpenAI
except ImportError:
    print("❌ Error: OpenAI library not installed.")
    print("📦 Install with: pip install openai")
    sys.exit(1)


def normalize_filename(text: str) -> str:
    """
    Normalize French text to create valid filenames.
    Converts accented characters to ASCII equivalents.

    Examples:
        'éponge' -> 'eponge'
        'fenêtre' -> 'fenetre'
        'salle de classe' -> 'salle-de-classe'
    """
    # Replace accented characters
    nfkd = unicodedata.normalize('NFKD', text)
    ascii_text = ''.join([c for c in nfkd if not unicodedata.combining(c)])

    # Convert to lowercase
    ascii_text = ascii_text.lower()

    # Replace spaces with hyphens
    ascii_text = ascii_text.replace(' ', '-')

    # Remove any remaining special characters except hyphens
    ascii_text = re.sub(r'[^a-z0-9-]', '', ascii_text)

    return ascii_text


def get_article_forms(word_data: Dict) -> tuple[str, str]:
    """
    Get the indefinite and definite article forms for a word.

    Returns:
        (indefinite_form, definite_form) - e.g., ("un bureau", "le bureau")
    """
    canonical = word_data['canonical']
    gender = word_data.get('genderOrPos', 'masculine')
    elision = word_data.get('elision', False)

    # Determine articles based on gender and elision
    if gender == 'masculine':
        indefinite = 'un'
        definite = "l'" if elision else 'le'
    elif gender == 'feminine':
        indefinite = 'une'
        definite = "l'" if elision else 'la'
    else:
        # Default to masculine for unknown gender
        indefinite = 'un'
        definite = 'le'

    indefinite_form = f"{indefinite} {canonical}"
    definite_form = f"{definite}{canonical}" if elision else f"{definite} {canonical}"

    return indefinite_form, definite_form


def generate_audio_text(word_data: Dict) -> str:
    """
    Generate the text to be spoken by TTS.

    For nouns: "un/une word. le/la/l' word" (with articles)
    For other parts of speech: "word" (no articles)

    Simple, clean format - language recognition is handled by instructions parameter.
    """
    part_of_speech = word_data.get('partOfSpeech', 'noun')

    # Only add articles for nouns
    if part_of_speech == 'noun':
        indefinite_form, definite_form = get_article_forms(word_data)
        # Nouns: two forms separated by period (long pause)
        audio_text = f"{indefinite_form}. {definite_form}"
    else:
        # Adjectives, verbs, numbers, etc.: just the word itself
        canonical = word_data['canonical']
        audio_text = canonical

    return audio_text


def generate_audio_file(
    client: OpenAI,
    word_data: Dict,
    output_dir: Path,
    voice: str = "alloy",
    model: str = "gpt-4o-mini-tts",
    speed: float = 1.0,
    instructions: str = ""
) -> Optional[Path]:
    """
    Generate audio file for a single word using OpenAI TTS API.

    Args:
        client: OpenAI client instance
        word_data: Dictionary containing word information
        output_dir: Directory to save audio files
        voice: TTS voice to use (alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer)
        model: TTS model (gpt-4o-mini-tts, tts-1, or tts-1-hd)
        speed: Speech speed (0.25 to 4.0, default 1.0)
        instructions: Instructions for the TTS model (only supported by gpt-4o-mini-tts)

    Returns:
        Path to generated audio file, or None if failed
    """
    canonical = word_data['canonical']
    chinese = word_data.get('chinese', '')

    # Generate audio text
    audio_text = generate_audio_text(word_data)

    # Create filename
    normalized_name = normalize_filename(canonical)
    output_file = output_dir / f"{normalized_name}.mp3"

    # Check if file already exists
    if output_file.exists():
        print(f"  ⏭️  Skipping '{canonical}' (file exists): {output_file.name}")
        return output_file

    try:
        print(f"  🎙️  Generating: '{canonical}' ({chinese})")
        print(f"      Text: {audio_text}")

        # Call OpenAI TTS API
        # Build request parameters
        request_params = {
            "model": model,
            "voice": voice,
            "input": audio_text,
            "speed": speed
        }

        # Add instructions if provided (only supported by gpt-4o-mini-tts)
        if instructions and model == "gpt-4o-mini-tts":
            request_params["instructions"] = instructions

        response = client.audio.speech.create(**request_params)

        # Save audio file
        response.stream_to_file(str(output_file))

        print(f"      ✅ Saved: {output_file.name}")
        return output_file

    except Exception as e:
        print(f"      ❌ Error generating audio for '{canonical}': {e}")
        return None


def load_unite_data(unite_num: int) -> Dict:
    """Load unite data from JSON file."""
    json_file = Path(__file__).parent / "VocFr" / "Data" / "JSON" / f"Unite{unite_num}.json"

    if not json_file.exists():
        raise FileNotFoundError(f"Unite file not found: {json_file}")

    with open(json_file, 'r', encoding='utf-8') as f:
        return json.load(f)


def generate_audio_for_section(
    client: OpenAI,
    unite_num: int,
    section_num: int,
    output_base_dir: Path,
    voice: str = "alloy",
    model: str = "gpt-4o-mini-tts",
    speed: float = 1.0,
    instructions: str = ""
) -> tuple[int, int]:
    """
    Generate audio files for all words in a specific section.

    Returns:
        (success_count, total_count)
    """
    # Load unite data
    print(f"📖 Loading Unite {unite_num} data...")
    unite_data = load_unite_data(unite_num)

    # Find the specified section
    section_data = None
    for section in unite_data['sections']:
        if section.get('orderIndex') == section_num:
            section_data = section
            break

    if section_data is None:
        print(f"❌ Section {section_num} not found in Unite {unite_num}")
        return 0, 0

    section_name = section_data['name']
    words = section_data['words']

    print(f"📚 Unite {unite_num}: {unite_data['title']}")
    print(f"📑 Section {section_num}: {section_name}")
    print(f"📝 Total words: {len(words)}\n")

    # Create output directory
    output_dir = output_base_dir / f"Unite{unite_num}" / f"Section{section_num}"
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📁 Output directory: {output_dir}\n")

    # Generate audio for each word
    success_count = 0
    for i, word_data in enumerate(words, 1):
        print(f"[{i}/{len(words)}]")
        result = generate_audio_file(client, word_data, output_dir, voice, model, speed, instructions)
        if result:
            success_count += 1
        print()  # Empty line for readability

    return success_count, len(words)


def main():
    parser = argparse.ArgumentParser(
        description="Generate audio files for French vocabulary using OpenAI TTS"
    )
    parser.add_argument(
        '--unite', '-u',
        type=int,
        default=1,
        help='Unite number (default: 1)'
    )
    parser.add_argument(
        '--section', '-s',
        type=int,
        default=1,
        help='Section number (default: 1)'
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
        help='TTS voice (default: alloy, try coral or nova for better French)'
    )
    parser.add_argument(
        '--model', '-m',
        type=str,
        default='gpt-4o-mini-tts',
        choices=['gpt-4o-mini-tts', 'tts-1', 'tts-1-hd'],
        help='TTS model (default: gpt-4o-mini-tts, supports instructions parameter)'
    )
    parser.add_argument(
        '--output-dir', '-o',
        type=str,
        help='Output directory (default: VocFr/Resources/Audio/Words)'
    )
    parser.add_argument(
        '--speed',
        type=float,
        default=1.0,
        help='Speech speed (0.25 to 4.0, default: 1.0)'
    )
    parser.add_argument(
        '--instructions',
        type=str,
        default='Speak français slowly and clearly for language learners. Pause at periods.',
        help='Instructions for gpt-4o-mini-tts model to control speech characteristics'
    )

    args = parser.parse_args()

    # Get API key
    api_key = args.api_key or os.environ.get('OPENAI_API_KEY')
    if not api_key:
        print("❌ Error: OpenAI API key not provided.")
        print("   Set OPENAI_API_KEY environment variable or use --api-key option.")
        sys.exit(1)

    # Initialize OpenAI client
    client = OpenAI(api_key=api_key)

    # Set output directory
    if args.output_dir:
        output_base_dir = Path(args.output_dir)
    else:
        output_base_dir = Path(__file__).parent / "VocFr" / "Resources" / "Audio" / "Words"

    print("=" * 60)
    print("🎵 VocFr Audio Generator (OpenAI TTS)")
    print("=" * 60)
    print(f"⚙️  Model: {args.model}")
    print(f"🎤 Voice: {args.voice}")
    print(f"🎚️  Speed: {args.speed}x")
    if args.model == "gpt-4o-mini-tts" and args.instructions:
        print(f"📝 Instructions: {args.instructions}")
    print(f"📂 Output: {output_base_dir}")
    print("=" * 60)
    print()

    try:
        success, total = generate_audio_for_section(
            client=client,
            unite_num=args.unite,
            section_num=args.section,
            output_base_dir=output_base_dir,
            voice=args.voice,
            model=args.model,
            speed=args.speed,
            instructions=args.instructions
        )

        print("=" * 60)
        print(f"✅ Generation complete: {success}/{total} files")
        print("=" * 60)

        if success < total:
            sys.exit(1)

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
