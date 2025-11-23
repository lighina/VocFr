#!/usr/bin/env python3
"""
Generate image files for French vocabulary words using OpenAI DALL-E API.

This script reads vocabulary data from Unite JSON files and generates educational
illustrations for each word using a two-step process:
1. Generate an English scene description using GPT
2. Generate an image using DALL-E with Studio Ghibli watercolor style

Usage:
    python generate_image_dalle.py [--unite UNITE_NUM] [--section SECTION_NUM] [--api-key API_KEY]

Examples:
    # Generate images for Unite 1, Section 1 (default)
    python generate_image_dalle.py

    # Specify API key
    python generate_image_dalle.py --api-key sk-xxx

    # Generate for specific unite/section
    python generate_image_dalle.py --unite 2 --section 3
"""

import json
import os
import sys
import base64
from pathlib import Path
from typing import Dict, Optional
import argparse
import unicodedata
import re
import time

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
        'salle de classe' -> 'salle_de_classe'
    """
    # Replace accented characters
    nfkd = unicodedata.normalize('NFKD', text)
    ascii_text = ''.join([c for c in nfkd if not unicodedata.combining(c)])

    # Convert to lowercase
    ascii_text = ascii_text.lower()

    # Replace spaces with underscores (different from audio which uses hyphens)
    ascii_text = ascii_text.replace(' ', '_')
    ascii_text = ascii_text.replace('-', '_')

    # Remove any remaining special characters except underscores
    ascii_text = re.sub(r'[^a-z0-9_]', '', ascii_text)

    return ascii_text


def generate_scene_description(
    client: OpenAI,
    word_data: Dict,
    model: str = "gpt-4o-mini"
) -> Optional[str]:
    """
    Generate an English scene description for the word using GPT.

    Args:
        client: OpenAI client instance
        word_data: Dictionary containing word information
        model: GPT model to use

    Returns:
        English scene description, or None if failed
    """
    canonical = word_data['canonical']
    part_of_speech = word_data.get('partOfSpeech', 'noun')
    chinese = word_data.get('chinese', '')

    # Prepare the prompt for GPT
    user_prompt = f"""French word: "{canonical}" ({part_of_speech}).
Chinese meaning: {chinese}.

Context: educational illustration for children learning French.

Please describe a simple scene that shows this meaning."""

    system_prompt = """You are a prompt designer for child-friendly educational illustrations.

For each French vocabulary word, you will create a short English description of a simple scene that clearly shows the meaning of the word.

Requirements:
- 1–2 short sentences in English.
- Very concrete and visual.
- Only describe what should be drawn, no camera words, no style words.
- No text, no labels, no words inside the image.
- Suitable for primary school children.
- Keep the number of characters small (1–2 people at most).
- If it is a verb, show a character performing the action.
- If it is a noun, draw the object clearly and simply.

Return only the English description."""

    try:
        print(f"      🤖 Generating scene description for '{canonical}'...")

        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7,
            max_tokens=100
        )

        description = response.choices[0].message.content.strip()
        print(f"      📝 Description: {description}")
        return description

    except Exception as e:
        print(f"      ❌ Error generating description: {e}")
        return None


def generate_image_file(
    client: OpenAI,
    word_data: Dict,
    output_dir: Path,
    unite_num: int = 0,
    section_num: int = 0,
    model: str = "dall-e-3",
    size: str = "1024x1024",
    gpt_model: str = "gpt-4o-mini"
) -> Optional[Path]:
    """
    Generate image file for a single word using OpenAI DALL-E API.

    Args:
        client: OpenAI client instance
        word_data: Dictionary containing word information
        output_dir: Directory to save image files
        unite_num: Unite number (for logging)
        section_num: Section number (for logging)
        model: DALL-E model to use (dall-e-2 or dall-e-3)
        size: Image size (1024x1024, 1024x1792, 1792x1024 for dall-e-3; 256x256, 512x512, 1024x1024 for dall-e-2)
        gpt_model: GPT model for scene description

    Returns:
        Path to generated image file, or None if failed
    """
    canonical = word_data['canonical']
    chinese = word_data.get('chinese', '')

    # Create filename: {canonical}_image.png
    normalized_name = normalize_filename(canonical)
    filename = f"{normalized_name}_image.png"
    output_file = output_dir / filename

    # Check if file already exists
    if output_file.exists():
        print(f"  ⏭️  Skipping '{canonical}' (file exists): {output_file.name}")
        return output_file

    print(f"  🎨 Generating: '{canonical}' ({chinese})")

    # Step 1: Generate scene description using GPT
    scene_description = generate_scene_description(client, word_data, gpt_model)
    if not scene_description:
        return None

    # Step 2: Build final prompt with style guidelines
    style_prompt = """Studio Ghibli–inspired watercolor illustration, soft warm tones, gentle shading, tender hand-painted feeling. Characters/objects with volume, subtle shadows and rounded shapes. Cute, warm, child-friendly. Transparent background ONLY, no paper texture, no gradient, no halo, no glow, no vignette, no noise. Object or character perfectly centered in a 512×512 canvas, with clean margins and no cropping of limbs or props. No text, no handwriting."""

    final_prompt = f"{scene_description} {style_prompt}"

    # For dall-e-2, we need to adjust the size
    actual_size = size
    if model == "dall-e-2" and size not in ["256x256", "512x512", "1024x1024"]:
        actual_size = "512x512"  # Default to 512x512 for dall-e-2
        print(f"      ⚠️  Adjusting size to {actual_size} for dall-e-2")

    try:
        print(f"      🖼️  Generating image with DALL-E ({model})...")

        # Call OpenAI DALL-E API
        response = client.images.generate(
            model=model,
            prompt=final_prompt,
            size=actual_size,
            quality="standard",  # "standard" or "hd" (hd only for dall-e-3)
            n=1,
            response_format="b64_json"  # Get base64 instead of URL for transparency support
        )

        # Get base64 image data
        image_b64 = response.data[0].b64_json

        # Decode and save
        image_data = base64.b64decode(image_b64)
        with open(output_file, 'wb') as f:
            f.write(image_data)

        print(f"      ✅ Saved: {output_file.name}")
        return output_file

    except Exception as e:
        print(f"      ❌ Error generating image for '{canonical}': {e}")
        return None


def load_unite_data(unite_num: int) -> Dict:
    """Load unite data from JSON file."""
    # Navigate up to project root: image_dalle -> Vocabulary -> Scripts -> VocFr (project root)
    project_root = Path(__file__).parent.parent.parent.parent
    json_file = project_root / "VocFr" / "Data" / "JSON" / f"Unite{unite_num}.json"

    if not json_file.exists():
        raise FileNotFoundError(f"Unite file not found: {json_file}")

    with open(json_file, 'r', encoding='utf-8') as f:
        return json.load(f)


def generate_images_for_section(
    client: OpenAI,
    unite_num: int,
    section_num: int,
    output_base_dir: Path,
    model: str = "dall-e-3",
    size: str = "1024x1024",
    gpt_model: str = "gpt-4o-mini",
    delay: float = 1.0
) -> tuple[int, int]:
    """
    Generate image files for all words in a specific section.

    Args:
        delay: Delay in seconds between API calls to avoid rate limiting

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
    output_dir = output_base_dir
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📁 Output directory: {output_dir}\n")

    # Generate images for each word
    success_count = 0
    for i, word_data in enumerate(words, 1):
        print(f"[{i}/{len(words)}]")

        # Check if word should have an image
        name_of_image = word_data.get('nameOfImage', '')
        if name_of_image and name_of_image.lower() in ['none', 'null']:
            print(f"  ⏭️  Skipping '{word_data['canonical']}' (nameOfImage is 'none')")
            print()
            continue

        result = generate_image_file(
            client, word_data, output_dir,
            unite_num=unite_num,
            section_num=section_num,
            model=model,
            size=size,
            gpt_model=gpt_model
        )
        if result:
            success_count += 1

        print()  # Empty line for readability

        # Delay between requests to avoid rate limiting
        if i < len(words):
            time.sleep(delay)

    return success_count, len(words)


def main():
    parser = argparse.ArgumentParser(
        description="Generate images for French vocabulary using OpenAI DALL-E"
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
        '--model', '-m',
        type=str,
        default='dall-e-3',
        choices=['dall-e-2', 'dall-e-3'],
        help='DALL-E model (default: dall-e-3, more expensive but better quality)'
    )
    parser.add_argument(
        '--size',
        type=str,
        default='1024x1024',
        help='Image size (default: 1024x1024). For dall-e-3: 1024x1024, 1024x1792, 1792x1024. For dall-e-2: 256x256, 512x512, 1024x1024'
    )
    parser.add_argument(
        '--gpt-model',
        type=str,
        default='gpt-4o-mini',
        choices=['gpt-4o-mini', 'gpt-4o', 'gpt-4'],
        help='GPT model for scene description (default: gpt-4o-mini)'
    )
    parser.add_argument(
        '--output-dir', '-o',
        type=str,
        help='Output directory (default: /Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Images/tempVocPic/)'
    )
    parser.add_argument(
        '--delay',
        type=float,
        default=1.0,
        help='Delay in seconds between API calls (default: 1.0)'
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
        output_base_dir = Path("/Volumes/DevSSD/Code/Swift/Projects/VocFr/VocFr/Resources/Images/tempVocPic")

    print("=" * 60)
    print("🎨 VocFr Image Generator (OpenAI DALL-E)")
    print("=" * 60)
    print(f"⚙️  DALL-E Model: {args.model}")
    print(f"🖼️  Image Size: {args.size}")
    print(f"🤖 GPT Model: {args.gpt_model}")
    print(f"📂 Output: {output_base_dir}")
    print("=" * 60)
    print()

    # Cost estimation
    if args.model == "dall-e-3":
        if args.size == "1024x1024":
            cost_per_image = 0.040
        else:  # 1024x1792 or 1792x1024
            cost_per_image = 0.080
    else:  # dall-e-2
        if args.size == "256x256":
            cost_per_image = 0.016
        elif args.size == "512x512":
            cost_per_image = 0.018
        else:  # 1024x1024
            cost_per_image = 0.020

    print(f"💰 Cost per image: ${cost_per_image:.3f}")
    print()

    try:
        success, total = generate_images_for_section(
            client=client,
            unite_num=args.unite,
            section_num=args.section,
            output_base_dir=output_base_dir,
            model=args.model,
            size=args.size,
            gpt_model=args.gpt_model,
            delay=args.delay
        )

        estimated_cost = success * cost_per_image
        print("=" * 60)
        print(f"✅ Generation complete: {success}/{total} images")
        print(f"💰 Estimated cost: ${estimated_cost:.2f} USD")
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
