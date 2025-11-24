#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
generate_image.py

从 UniteX.json 或单个单词生成 Studio Ghibli 水彩风透明插画。

功能：
- 模式 1：整份 JSON 批量生成（所有带 nameOfImage 的词）。
- 模式 2：只生成 JSON 中某一个词（--only-word）。
- 模式 3：完全不依赖 JSON，单独生成一个词（--plain-word）。
  - 默认 icon 风格（直边 + 透明背景）。
  - 可用 --prompt-type scene 强制场景风格。
  - 可用 --extra-prompt 为该词追加额外提示（只在 plain-word 模式下可用）。

通用特性：
- 使用 gpt-image-1，size 默认 1024x1024。
- 再等比缩放并居中裁剪为 target x target（默认 512x512）。
- 可选 --remove-background 做一次简单抠背景。
- 输出文件名：
    - JSON 模式：使用 JSON 中的 nameOfImage。
    - plain-word 模式：使用 {word}_image.png。
"""

import os
import json
import argparse
import base64
from io import BytesIO
from pathlib import Path
from typing import Any, Dict, Iterable

import numpy as np
from PIL import Image
from openai import OpenAI

client = OpenAI()

# ================== VocFr Project Path Configuration ===================

def get_project_root() -> Path:
    """Get the VocFr project root directory."""
    # Navigate up from: image -> Vocabulary -> Scripts -> VocFr (project root)
    return Path(__file__).parent.parent.parent.parent

def get_unite_json_path(unite_num: int) -> Path:
    """Get path to Unite JSON file."""
    project_root = get_project_root()
    return project_root / "VocFr" / "Data" / "JSON" / f"Unite{unite_num}.json"

def get_default_output_dir() -> Path:
    """Get default output directory for generated images."""
    project_root = get_project_root()
    return project_root / "VocFr" / "Resources" / "Images" / "tempVocPic"

# ================== 统一 Studio Ghibli 风格 Prompt ===================

ICON_PROMPT = """
Studio Ghibli–inspired watercolor illustration of the French word "{word}".
Category: {category}.

Draw a single, clear object or character that represents this word for
children's vocabulary learning. No background scene, no environment.

Soft warm tones, gentle shading, tender hand-painted watercolor feeling.
The object should have volume and a subtle cast shadow, with rounded,
friendly shapes.

CLEAN EDGES ONLY: no watercolor bleed, no feathering.
Transparent background ONLY (pure alpha, no paper texture or color).
No gradient, no halo, no glow, no vignette, no outer shadow, no noise.

Object perfectly centered in the canvas with clean margins.
No text, no labels.

{extra}
""".strip()

SCENE_PROMPT = """
Studio Ghibli–inspired watercolor scene for the French word "{word}".
Category: {category}.

Draw a simple, readable scene that clearly represents this word for
children's vocabulary learning (for example a room, place, or landscape).

Soft warm tones, gentle shading, tender hand-painted watercolor feeling.
Use watercolor textures, you may keep slightly softer, organic edges,
but avoid heavy vignette or strong glow.

Transparent background ONLY if possible (no solid colored background).
No text, no writing. Scene roughly centered with some breathing space
around it.

{extra}
""".strip()

SCENE_WORDS = {
    "village",
    "rue",
    "trottoir",
    "coin",
    "chemin",
    "parc",
    "aire de jeux",
    "arrêt de bus",
    "école",
    "classe",
    "chambre",
    "cuisine",
    "salon",
    "jardin",
    "salle de bain",
    "salle de classe",
}


def load_unite_json(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def iter_words_with_images(data: Dict[str, Any]) -> Iterable[Dict[str, Any]]:
    """
    支持两种结构：
    - data["sections"][i]["words"][j]
    - data["words"][j]
    只返回有 nameOfImage 的词条。
    """
    if "sections" in data:
        for section in data["sections"]:
            for word in section.get("words", []):
                if word.get("nameOfImage"):
                    yield word
    elif "words" in data:
        for word in data["words"]:
            if word.get("nameOfImage"):
                yield word
    else:
        raise ValueError("JSON 不包含 'sections' 或 'words' 字段，无法识别结构。")


def get_canonical(word: Dict[str, Any]) -> str:
    return (word.get("canonical") or word.get("word") or "").strip()


def get_prompt_type(word: Dict[str, Any], default_icon: bool = True) -> str:
    """
    决定使用 ICON_PROMPT 或 SCENE_PROMPT。

    优先级：
    1. 如果词条中显式有 "promptType": "icon"/"scene" -> 直接使用。
    2. 否则，如果 canonical 在 SCENE_WORDS 里 -> "scene"。
    3. 否则：
        - 如果 default_icon=True -> "icon"
        - 否则 -> "scene"
    """
    explicit = word.get("promptType")
    if explicit in ("icon", "scene"):
        return explicit

    canonical = get_canonical(word).lower()
    if canonical in SCENE_WORDS:
        return "scene"

    return "icon" if default_icon else "scene"


def build_prompt(word: Dict[str, Any], default_icon: bool = True) -> str:
    canonical = get_canonical(word)
    category = word.get("category", "general")
    extra = word.get("imagePrompt") or ""
    prompt_type = get_prompt_type(word, default_icon=default_icon)

    if extra:
        extra = "Additional instruction: " + extra
    else:
        extra = ""

    if prompt_type == "scene":
        tpl = SCENE_PROMPT
    else:
        tpl = ICON_PROMPT

    return tpl.format(word=canonical, category=category, extra=extra)


def generate_image_base(
    word: Dict[str, Any],
    size: str = "1024x1024",
    default_icon: bool = True,
) -> Image.Image:
    prompt = build_prompt(word, default_icon=default_icon)
    result = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size=size,
    )
    b64_data = result.data[0].b64_json
    img_bytes = base64.b64decode(b64_data)
    img = Image.open(BytesIO(img_bytes)).convert("RGBA")
    return img


def resize_and_center_crop(img: Image.Image, target: int = 512) -> Image.Image:
    """
    先等比缩放，使最短边 == target，
    然后从中央裁切成 target × target。
    """

    w, h = img.size

    if w < h:
        new_w = target
        new_h = int(h * (target / w))
    else:
        new_h = target
        new_w = int(w * (target / h))

    img = img.resize((new_w, new_h), Image.LANCZOS)

    left = (new_w - target) // 2
    top = (new_h - target) // 2
    right = left + target
    bottom = top + target

    return img.crop((left, top, right, bottom))


def remove_background_naive(img: Image.Image, tolerance: int = 12) -> Image.Image:
    """
    简单抠背景：
    - 取左上角像素作为背景色；
    - 与该色距离 <= tolerance 的像素透明。
    """
    img = img.convert("RGBA")
    arr = np.array(img)
    bg = arr[0, 0, :3].astype(np.int16)

    rgb = arr[:, :, :3].astype(np.int16)
    dist = np.sqrt(((rgb - bg) ** 2).sum(axis=2))

    mask = dist <= tolerance
    arr[mask, 3] = 0

    return Image.fromarray(arr, mode="RGBA")


def process_word(
    word: Dict[str, Any],
    outdir: str,
    remove_background: bool = False,
    save_raw: bool = False,
    size: str = "1024x1024",
    target: int = 512,
    default_icon: bool = True,
) -> str:
    name_of_image = word["nameOfImage"]
    canonical = get_canonical(word)
    print(f"  -> {canonical}  ({name_of_image})")

    img_raw = generate_image_base(word, size=size, default_icon=default_icon)

    if save_raw:
        raw_dir = os.path.join(outdir, "_raw")
        os.makedirs(raw_dir, exist_ok=True)
        raw_path = os.path.join(raw_dir, name_of_image)
        img_raw.save(raw_path)

    img_final = resize_and_center_crop(img_raw, target=target)

    if remove_background:
        img_final = remove_background_naive(img_final)

    os.makedirs(outdir, exist_ok=True)
    final_path = os.path.join(outdir, name_of_image)
    img_final.save(final_path)
    return final_path


def main():
    parser = argparse.ArgumentParser(
        description="Generate Studio Ghibli–style watercolor images from Unite JSON or a single word."
    )
    parser.add_argument(
        "--unite", "-u",
        type=int,
        help="Unite number (e.g., 1, 2, 3). Will load from VocFr/Data/JSON/UniteX.json",
    )
    parser.add_argument(
        "--json",
        help="Path to Unite JSON file (alternative to --unite). e.g., Unite4.json or full path",
    )
    parser.add_argument(
        "--outdir", "-o",
        help="Output directory for final PNG images. Default: VocFr/Resources/Images/tempVocPic",
    )
    parser.add_argument(
        "--only-word",
        help="When used with --json: only generate this single word (match against 'canonical').",
    )
    parser.add_argument(
        "--plain-word",
        help="Generate a single word WITHOUT using JSON. Example: --plain-word bateau",
    )
    parser.add_argument(
        "--prompt-type",
        choices=["icon", "scene"],
        help="When using --plain-word, choose 'icon' or 'scene'. Default: icon.",
    )
    parser.add_argument(
        "--extra-prompt",
        help="Extra prompt text appended at the end (ONLY valid with --plain-word).",
    )
    parser.add_argument(
        "--remove-background",
        action="store_true",
        help="Run a naive background removal pass after cropping.",
    )
    parser.add_argument(
        "--save-raw",
        action="store_true",
        help="Also save the raw model output (size given by --size) under outdir/_raw.",
    )
    parser.add_argument(
        "--size",
        default="1024x1024",
        help="Image size for OpenAI generation (default: 1024x1024). "
             "Allowed: '1024x1024', '1024x1536', '1536x1024', 'auto'.",
    )
    parser.add_argument(
        "--target",
        type=int,
        default=512,
        help="Target output size (default: 512).",
    )

    args = parser.parse_args()

    # Validate argument combinations
    if args.plain_word and (args.json or args.unite):
        raise SystemExit("不能同时使用 --plain-word 和 --json/--unite，请二选一。")

    if args.unite and args.json:
        raise SystemExit("不能同时使用 --unite 和 --json，请二选一。")

    if not args.plain_word and not args.json and not args.unite:
        raise SystemExit("必须至少指定 --plain-word、--json 或 --unite 之一。")

    if args.extra_prompt and not args.plain_word:
        raise SystemExit("--extra-prompt 只能与 --plain-word 一起使用，在 JSON 模式下禁止使用。")

    # Determine output directory
    if args.outdir:
        outdir = args.outdir
    else:
        outdir = str(get_default_output_dir())

    os.makedirs(outdir, exist_ok=True)

    # Determine JSON path
    json_path = None
    if args.unite:
        json_path = str(get_unite_json_path(args.unite))
        print(f"[Unite mode] Loading Unite {args.unite} from {json_path}")
    elif args.json:
        json_path = args.json

    if args.plain_word:
        word_str = args.plain_word.strip()
        prompt_type = args.prompt_type or "icon"

        word_obj: Dict[str, Any] = {
            "canonical": word_str,
            "nameOfImage": f"{word_str}_image.png",
            "category": "standalone",
            "promptType": prompt_type,
        }

        if args.extra_prompt:
            word_obj["imagePrompt"] = args.extra_prompt

        print(f"[Plain-word mode] Generating single word: {word_str} "
              f"(promptType={prompt_type})")
        try:
            final_path = process_word(
                word_obj,
                outdir=outdir,
                remove_background=args.remove_background,
                save_raw=args.save_raw,
                size=args.size,
                target=args.target,
                default_icon=True,
            )
            print(f"DONE -> {final_path}")
        except Exception as e:
            print(f"FAILED for {word_str}: {e}")
        return

    # JSON mode (either --json or --unite)
    data = load_unite_json(json_path)
    words = list(iter_words_with_images(data))

    if args.only_word:
        target_word_lower = args.only_word.strip().lower()
        words = [w for w in words if get_canonical(w).lower() == target_word_lower]
        if not words:
            print(f"No word with canonical == '{args.only_word}' found in {json_path}.")
            return

    print(f"Loaded {len(words)} word(s) with images from {json_path}")
    print(f"Output directory: {outdir}")

    for word in words:
        canonical = get_canonical(word)
        try:
            print(f"Generating image for: {canonical} ...")
            final_path = process_word(
                word,
                outdir=outdir,
                remove_background=args.remove_background,
                save_raw=args.save_raw,
                size=args.size,
                target=args.target,
                default_icon=True,
            )
            print(f"  OK -> {final_path}")
        except Exception as e:
            print(f"  FAILED for {canonical}: {e}")


if __name__ == "__main__":
    main()
