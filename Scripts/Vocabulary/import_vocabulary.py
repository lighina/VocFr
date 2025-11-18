#!/usr/bin/env python3
"""
VocFr 词汇数据导入工具

功能：
- 从 CSV 文件读取 Unite/Section/Words 数据
- 自动生成标准 JSON 格式
- 支持数据验证和错误检查
- 支持增量更新（不会覆盖现有数据）

用法：
    python import_vocabulary.py --source vocabulary_unite4.csv --output Unite4.json
    python import_vocabulary.py --source vocabulary_unite4.csv --update --unite 4
"""

import csv
import json
import argparse
from pathlib import Path
from typing import List, Dict, Optional


class VocabularyImporter:
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.json_dir = self.project_root / "VocFr/Data/JSON"

        # 词性映射
        self.part_of_speech_map = {
            'noun': 'noun',
            'verb': 'verb',
            'adj': 'adjective',
            'adjective': 'adjective',
            'adv': 'adverb',
            'adverb': 'adverb',
            'prep': 'preposition',
            'preposition': 'preposition'
        }

        # 性别映射
        self.gender_map = {
            'm': 'masculine',
            'masculine': 'masculine',
            'f': 'feminine',
            'feminine': 'feminine'
        }

    def parse_csv(self, csv_path: str) -> Dict:
        """
        解析 CSV 文件，提取 Unite 数据

        Returns:
            {
                "unite": {...},
                "sections": [...]
            }
        """
        csv_file = Path(csv_path)
        if not csv_file.exists():
            raise FileNotFoundError(f"CSV 文件不存在: {csv_path}")

        unite_data = None
        sections = []
        current_section = None

        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)

            for row in reader:
                # 跳过空行和注释
                if not row or not row[0] or row[0].strip().startswith('#'):
                    continue

                # Unite 信息行
                if row[0].strip() == 'UNITE':
                    if len(row) < 7:
                        print(f"⚠️  Unite 行格式不正确: {row}")
                        continue

                    unite_data = {
                        'id': row[1].strip(),
                        'number': int(row[2].strip()),
                        'title': row[3].strip(),
                        'titleInChinese': row[4].strip(),
                        'isUnlocked': False,
                        'requiredStars': int(row[5].strip()),
                        'requiredGems': int(row[6].strip()),
                        'sections': []
                    }
                    print(f"📚 Unite {unite_data['number']}: {unite_data['title']}")

                # Section 信息行
                elif row[0].strip() == 'SECTION':
                    if len(row) < 4:
                        print(f"⚠️  Section 行格式不正确: {row}")
                        continue

                    # 保存之前的 section
                    if current_section:
                        sections.append(current_section)

                    current_section = {
                        'id': row[1].strip(),
                        'name': row[2].strip(),
                        'orderIndex': int(row[3].strip()),
                        'words': []
                    }
                    print(f"  📂 Section {current_section['orderIndex']}: {current_section['name']}")

                # 词汇数据行
                elif current_section is not None:
                    if len(row) < 6:
                        print(f"⚠️  词汇行格式不正确: {row}")
                        continue

                    canonical = row[0].strip()
                    if not canonical:
                        continue

                    word = {
                        'canonical': canonical,
                        'chinese': row[1].strip(),
                        'partOfSpeech': self._normalize_part_of_speech(row[2].strip()),
                        'genderOrPos': self._normalize_gender(row[3].strip()),
                        'category': row[4].strip(),
                        'elision': row[5].strip().lower() == 'true'
                    }

                    current_section['words'].append(word)
                    print(f"    ✓ {word['canonical']} ({word['chinese']})")

        # 保存最后一个 section
        if current_section:
            sections.append(current_section)

        if not unite_data:
            raise ValueError("CSV 文件中未找到 UNITE 信息行")

        unite_data['sections'] = sections

        return unite_data

    def _normalize_part_of_speech(self, pos: str) -> str:
        """标准化词性"""
        pos_lower = pos.lower().strip()
        return self.part_of_speech_map.get(pos_lower, pos)

    def _normalize_gender(self, gender: str) -> str:
        """标准化性别"""
        gender_lower = gender.lower().strip()
        return self.gender_map.get(gender_lower, gender)

    def validate_data(self, unite_data: Dict) -> List[str]:
        """
        验证数据完整性

        Returns:
            错误列表（如果为空则数据有效）
        """
        errors = []

        # 验证 Unite
        if 'id' not in unite_data or not unite_data['id']:
            errors.append("Unite 缺少 id 字段")
        if 'number' not in unite_data:
            errors.append("Unite 缺少 number 字段")
        if 'title' not in unite_data or not unite_data['title']:
            errors.append("Unite 缺少 title 字段")

        # 验证 Sections
        if 'sections' not in unite_data or not unite_data['sections']:
            errors.append("Unite 没有 Section")
        else:
            for i, section in enumerate(unite_data['sections']):
                section_prefix = f"Section {i+1}"

                if 'id' not in section or not section['id']:
                    errors.append(f"{section_prefix} 缺少 id 字段")
                if 'name' not in section or not section['name']:
                    errors.append(f"{section_prefix} 缺少 name 字段")

                # 验证 Words
                if 'words' not in section or not section['words']:
                    errors.append(f"{section_prefix} 没有单词")
                else:
                    for j, word in enumerate(section['words']):
                        word_prefix = f"{section_prefix} Word {j+1}"

                        required_fields = ['canonical', 'chinese', 'partOfSpeech', 'genderOrPos']
                        for field in required_fields:
                            if field not in word or not word[field]:
                                errors.append(f"{word_prefix} 缺少 {field} 字段")

        return errors

    def save_json(self, unite_data: Dict, output_path: str, dry_run: bool = False):
        """保存为 JSON 文件"""
        if dry_run:
            print(f"\n🔍 预览模式 - 不会实际写入文件")
            print(f"   将保存到: {output_path}")
            return

        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(unite_data, f, ensure_ascii=False, indent=2)

        print(f"\n✅ JSON 文件已保存: {output_path}")
        print(f"   Unite ID: {unite_data['id']}")
        print(f"   Section 数量: {len(unite_data['sections'])}")
        total_words = sum(len(s['words']) for s in unite_data['sections'])
        print(f"   总词汇数: {total_words}")

    def update_existing(self, unite_data: Dict, unite_number: int):
        """
        更新现有 Unite 文件（增量更新）
        """
        json_file = self.json_dir / f"Unite{unite_number}.json"

        if not json_file.exists():
            print(f"⚠️  文件不存在，将创建新文件: {json_file}")
            self.save_json(unite_data, str(json_file))
            return

        # 读取现有数据
        with open(json_file, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)

        print(f"📖 读取现有数据: {json_file}")
        print(f"   现有 Section 数: {len(existing_data.get('sections', []))}")

        # 合并 sections
        existing_section_ids = {s['id']: i for i, s in enumerate(existing_data.get('sections', []))}

        for new_section in unite_data['sections']:
            if new_section['id'] in existing_section_ids:
                # 更新现有 section
                idx = existing_section_ids[new_section['id']]
                existing_data['sections'][idx] = new_section
                print(f"  🔄 更新 Section: {new_section['name']}")
            else:
                # 添加新 section
                existing_data['sections'].append(new_section)
                print(f"  ➕ 添加 Section: {new_section['name']}")

        # 保存
        self.save_json(existing_data, str(json_file))


def main():
    parser = argparse.ArgumentParser(
        description='VocFr 词汇数据导入工具',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:

1. 导入新 Unite 数据:
   python import_vocabulary.py \\
       --source vocabulary_unite4.csv \\
       --output VocFr/Data/JSON/Unite4.json

2. 更新现有 Unite（增量添加 Section）:
   python import_vocabulary.py \\
       --source new_sections.csv \\
       --update \\
       --unite 4

3. 预览导入（不实际写入）:
   python import_vocabulary.py \\
       --source vocabulary_unite4.csv \\
       --output Unite4.json \\
       --dry-run
        """
    )

    parser.add_argument('--source', '-s', required=True,
                        help='CSV 源文件路径')
    parser.add_argument('--output', '-o',
                        help='输出 JSON 文件路径（如果不使用 --update）')
    parser.add_argument('--update', action='store_true',
                        help='更新模式：增量添加到现有 Unite 文件')
    parser.add_argument('--unite', '-u', type=int,
                        help='Unite 编号（用于更新模式）')
    parser.add_argument('--project', '-p', default='.',
                        help='项目根目录（默认: 当前目录）')
    parser.add_argument('--dry-run', action='store_true',
                        help='预览模式：不实际写入文件')
    parser.add_argument('--validate-only', action='store_true',
                        help='仅验证数据，不保存')

    args = parser.parse_args()

    # 验证参数
    if not args.update and not args.output:
        parser.error("必须指定 --output 或使用 --update 模式")

    if args.update and not args.unite:
        parser.error("更新模式需要指定 --unite 参数")

    print("=" * 60)
    print("📚 VocFr 词汇数据导入工具")
    print("=" * 60)
    print(f"源文件: {args.source}")
    if args.update:
        print(f"模式: 更新 Unite {args.unite}")
    else:
        print(f"输出: {args.output}")
    print("=" * 60)
    print()

    try:
        importer = VocabularyImporter(args.project)

        # 解析 CSV
        print("📖 解析 CSV 文件...")
        unite_data = importer.parse_csv(args.source)
        print()

        # 验证数据
        print("🔍 验证数据...")
        errors = importer.validate_data(unite_data)
        if errors:
            print("❌ 数据验证失败:")
            for error in errors:
                print(f"  - {error}")
            return 1
        print("✅ 数据验证通过")
        print()

        if args.validate_only:
            print("✅ 验证完成（仅验证模式）")
            return 0

        # 保存或更新
        if args.update:
            importer.update_existing(unite_data, args.unite)
        else:
            importer.save_json(unite_data, args.output, args.dry_run)

        print()
        print("=" * 60)
        print("✅ 导入完成！")
        print("=" * 60)
        print()
        print("📝 下一步:")
        print("  1. 在 Xcode 中将 JSON 文件添加到项目")
        print("  2. 准备对应的图片资源（如需要）")
        print("  3. 准备对应的音频资源")
        print("  4. 运行应用测试新数据")

        return 0

    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    exit(main())
