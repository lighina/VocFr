#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
make_grid.py

将多张 512x512 的透明 PNG 组合成一个 N×M 的拼图（透明背景）。

用法示例：

    # 3×3：
    python tools/make_grid.py \
        --images outputs/Unite4/*.png \
        --rows 3 --cols 3 \
        --cell 512 --gutter 64 \
        --output outputs/grids/Unite4_3x3.png

"""

import argparse
import glob
import os
from typing import List

from PIL import Image


def make_grid(
    image_paths: List[str],
    rows: int,
    cols: int,
    cell_size: int,
    gutter: int,
    output_path: str,
):
    assert len(image_paths) >= rows * cols, "图片数量不足以填满网格"

    width = cols * cell_size + (cols - 1) * gutter
    height = rows * cell_size + (rows - 1) * gutter

    canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    idx = 0
    for r in range(rows):
        for c in range(cols):
            img_path = image_paths[idx]
            idx += 1

            img = Image.open(img_path).convert("RGBA")
            if img.size != (cell_size, cell_size):
                img = img.resize((cell_size, cell_size), Image.LANCZOS)

            x = c * (cell_size + gutter)
            y = r * (cell_size + gutter)
            canvas.paste(img, (x, y), img)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    canvas.save(output_path)
    print(f"Saved grid -> {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Make transparent grid from PNG icons.")
    parser.add_argument(
        "--images",
        nargs="+",
        required=True,
        help="一组图片路径，支持通配符，如 outputs/Unite4/*.png",
    )
    parser.add_argument("--rows", type=int, required=True, help="行数")
    parser.add_argument("--cols", type=int, required=True, help="列数")
    parser.add_argument("--cell", type=int, default=512, help="单元格尺寸（默认 512）")
    parser.add_argument("--gutter", type=int, default=64, help="格子间距（默认 64）")
    parser.add_argument("--output", required=True, help="输出拼图 PNG 路径")

    args = parser.parse_args()

    paths: List[str] = []
    for pattern in args.images:
        paths.extend(sorted(glob.glob(pattern)))

    make_grid(
        image_paths=paths,
        rows=args.rows,
        cols=args.cols,
        cell_size=args.cell,
        gutter=args.gutter,
        output_path=args.output,
    )


if __name__ == "__main__":
    main()
