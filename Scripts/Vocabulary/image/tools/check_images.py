#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
check_images.py

检查生成的 PNG 图片是否：
- 具有透明背景（RGBA）
- 主体是否大致居中
- 主体距离四边的边距是否在期望范围内

用法示例：

    python tools/check_images.py --dir outputs/Unite4 --target 512 --min-margin 40 --max-margin 140
"""

import os
import argparse
from typing import Tuple

import numpy as np
from PIL import Image


def analyze_image(path: str, target: int, min_margin: int, max_margin: int) -> None:
    img = Image.open(path)
    w, h = img.size
    issues = []

    if img.mode != "RGBA":
        issues.append(f"mode={img.mode}, 非 RGBA（无透明通道）")

    if w != target or h != target:
        issues.append(f"size={w}x{h}, 非 {target}x{target}")

    arr = np.array(img)
    if arr.shape[2] == 4:
        alpha = arr[:, :, 3]
        non_empty = np.where(alpha > 0)
        if non_empty[0].size == 0:
            issues.append("整张图都是透明的（没有内容）")
        else:
            top = non_empty[0].min()
            bottom = non_empty[0].max()
            left = non_empty[1].min()
            right = non_empty[1].max()

            top_margin = top
            left_margin = left
            bottom_margin = h - 1 - bottom
            right_margin = w - 1 - right

            margins = [top_margin, bottom_margin, left_margin, right_margin]
            if any(m < min_margin or m > max_margin for m in margins):
                issues.append(
                    f"边距异常 top={top_margin}, bottom={bottom_margin}, "
                    f"left={left_margin}, right={right_margin}"
                )

            print(
                f"{os.path.basename(path)} -> "
                f"margins(px) top={top_margin}, bottom={bottom_margin}, "
                f"left={left_margin}, right={right_margin}"
            )
    else:
        issues.append("没有 alpha 通道")

    if issues:
        print(f"  ⚠ {os.path.basename(path)} 问题: " + "； ".join(issues))


def main():
    parser = argparse.ArgumentParser(description="Check PNG images (alpha + margins + size).")
    parser.add_argument("--dir", required=True, help="目录路径，如 outputs/Unite4")
    parser.add_argument("--target", type=int, default=512, help="期望的宽高（默认 512）")
    parser.add_argument("--min-margin", type=int, default=40, help="最小边距（像素）")
    parser.add_argument("--max-margin", type=int, default=140, help="最大边距（像素）")

    args = parser.parse_args()

    for fname in sorted(os.listdir(args.dir)):
        if not fname.lower().endswith(".png"):
            continue
        path = os.path.join(args.dir, fname)
        analyze_image(path, args.target, args.min_margin, args.max_margin)


if __name__ == "__main__":
    main()
