#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Update FrenchWord.swift with audioStart/audioEnd using a subtitles TXT/SRT.
Now outputs CMTime(value: ..., timescale: 1000) instead of Double seconds.
- For nouns: match using wordWithArticle (with un/une/des). If not found, try plural "des + plural(noun)".
- For non-nouns: match using word.
"""

import re
import sys
import json
import argparse
import unicodedata
from pathlib import Path
from typing import Dict, Tuple, Optional, List

def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write_text(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

def parse_args():
    ap = argparse.ArgumentParser(description="Inject audioStart/audioEnd into FrenchWord.swift from subtitles")
    ap.add_argument("--subs", required=True, type=Path, help="Path to subtitles .txt/.srt")
    ap.add_argument("--swift", required=True, type=Path, help="Path to FrenchWord.swift")
    ap.add_argument("--out", required=True, type=Path, help="Output Swift file path")
    ap.add_argument("--dry-run", action="store_true", help="Do not write file, just print stats")
    return ap.parse_args()

def srt_to_millis(ts: str) -> int:
    hh, mm, rest = ts.split(":")
    ss, ms = rest.split(",")
    total_ms = (int(hh)*3600 + int(mm)*60 + int(ss))*1000 + int(ms)
    return total_ms

def normalize(s: str) -> str:
    s = s.lower().strip()
    s = s.replace("’", "'")
    s = re.sub(r"\s+", " ", s)
    s = s.replace("-", " ")
    s = "".join(c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn")
    return s

def parse_subtitles(subs_text: str) -> Dict[str, Tuple[int,int,str]]:
    time_block_re = re.compile(
        r"(?P<start>\d{2}:\d{2}:\d{2},\d{3})\s*-->\s*(?P<end>\d{2}:\d{2}:\d{2},\d{3})\s*\n(?P<text>.+?)\n",
        re.MULTILINE
    )
    timeline: Dict[str, Tuple[int,int,str]] = {}
    for m in time_block_re.finditer(subs_text + "\n"):
        start = srt_to_millis(m.group("start"))
        end   = srt_to_millis(m.group("end"))
        text  = m.group("text").strip()
        timeline[normalize(text)] = (start, end, text)
    return timeline

# --- French plural heuristics ---
IRREG_OU_X = {"bijou","caillou","chou","genou","hibou","joujou","pou"}

def plural_candidates(noun_norm: str) -> List[str]:
    n = noun_norm
    cand = set()
    cand.add(n + "s")
    if n.endswith(("s","x","z")):
        cand.add(n)
    if n.endswith("al"):
        cand.add(n[:-2] + "aux")
    if n.endswith("au") or n.endswith("eau"):
        cand.add(n + "x")
    if n.endswith("eu"):
        cand.add(n + "x")
        cand.add(n + "s")
    if n.endswith("ou"):
        cand.add(n + "s")
        if n in IRREG_OU_X:
            cand.add(n + "x")
    if n.endswith("ail"):
        cand.add(n + "s")
        cand.add(n[:-3] + "aux")
    return list(cand)

TYPE_OPEN_RE = re.compile(r"(struct|class)\s+FrenchWord\b[^\\{]*\{", re.DOTALL)
CALL_RE = re.compile(r"(?P<full>(FrenchWord|\.init)\s*\((?P<inside>[^()]*(?:\([^)]*\)[^()]*)*)\))", re.DOTALL)

def ensure_properties(swift_src: str) -> Tuple[str, bool]:
    if "var audioStart" in swift_src and "var audioEnd" in swift_src:
        return swift_src, False
    m = TYPE_OPEN_RE.search(swift_src)
    if not m:
        return swift_src, False
    brace_index = swift_src.find("{", m.start())
    if brace_index == -1:
        return swift_src, False
    insertion = "\n    // Auto-added: timestamps as CMTime (ms precision)\n    var audioStart: CMTime?\n    var audioEnd: CMTime?\n"
    new_src = swift_src[:brace_index+1] + insertion + swift_src[brace_index+1:]
    return new_src, True

def parse_named_args(arg_src: str) -> dict:
    items, depth, buf = [], 0, []
    for ch in arg_src:
        if ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth = max(0, depth-1)
            buf.append(ch)
        elif ch == "," and depth == 0:
            items.append("".join(buf)); buf = []
        else:
            buf.append(ch)
    if buf: items.append("".join(buf))
    args = {}
    for it in items:
        m = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)\s*$", it, re.DOTALL)
        if m:
            args[m.group(1)] = m.group(2)
        else:
            args.setdefault("_positional", []).append(it.strip())
    return args

def get_string_literal(val_src: Optional[str]) -> Optional[str]:
    if not val_src: return None
    m = re.match(r'"\s*(.+?)\s*"', val_src.strip(), re.DOTALL)
    return m.group(1) if m else None

def update_swift(swift_src: str, timeline: Dict[str, Tuple[int,int,str]]) -> Tuple[str, int, List[dict]]:
    new_src, _ = ensure_properties(swift_src)
    changes = 0
    logs: List[dict] = []
    offset = 0

    for m in list(CALL_RE.finditer(new_src)):
        full = m.group("full")
        inside = m.group("inside")
        args = parse_named_args(inside)

        pos_src = args.get("partOfSpeech", "")
        is_noun = ".noun" in pos_src

        w_plain = get_string_literal(args.get("word", "")) if "word" in args else None
        w_with_article = get_string_literal(args.get("wordWithArticle", "")) if "wordWithArticle" in args else None

        match = None
        if is_noun:
            if w_with_article:
                match = timeline.get(normalize(w_with_article))
            if (not match) and w_plain:
                base_norm = normalize(w_plain)
                plurals = plural_candidates(base_norm)
                cand_norms = [f"des {p}" for p in plurals]
                cand_norms.insert(0, f"des {w_plain}")
                for c in cand_norms:
                    res = timeline.get(normalize(c))
                    if res:
                        match = res
                        break
        else:
            if w_plain:
                match = timeline.get(normalize(w_plain))

        if not match:
            continue

        st_ms, en_ms, matched_text = match

        cm_start = f"CMTime(value: {st_ms}, timescale: 1000)"
        cm_end   = f"CMTime(value: {en_ms}, timescale: 1000)"

        updated_call = full
        if "audioStart:" in updated_call:
            updated_call = re.sub(r"audioStart\s*:\s*[^,)]*", f"audioStart: {cm_start}", updated_call)
        else:
            updated_call = updated_call[:-1] + f", audioStart: {cm_start})"

        if "audioEnd:" in updated_call:
            updated_call = re.sub(r"audioEnd\s*:\s*[^,)]*", f"audioEnd: {cm_end}", updated_call)
        else:
            updated_call = updated_call[:-1] + f", audioEnd: {cm_end})"

        if updated_call != full:
            start_idx = m.start() + offset
            end_idx = m.end() + offset
            new_src = new_src[:start_idx] + updated_call + new_src[end_idx:]
            offset += len(updated_call) - (end_idx - start_idx)
            changes += 1
            logs.append({
                "word": w_plain,
                "wordWithArticle": w_with_article,
                "isNoun": is_noun,
                "matchedSubtitle": matched_text,
                "audioStart": cm_start,
                "audioEnd": cm_end
            })

    return new_src, changes, logs

def main():
    args = parse_args()
    subs_text = read_text(args.subs)
    swift_src = read_text(args.swift)

    timeline = parse_subtitles(subs_text)

    updated_src, changes, logs = update_swift(swift_src, timeline)

    report = {
        "subtitleItems": len(timeline),
        "changesApplied": changes,
        "examples": logs[:10],
        "output": str(args.out)
    }

    if args.dry_run:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return

    write_text(args.out, updated_src)
    print(json.dumps(report, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
