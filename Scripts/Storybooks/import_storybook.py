#!/usr/bin/env python3
"""
Storybook Resource Importer
自动导入故事书资源（图片、音频、文本）并生成JSON配置

使用方法:
    python import_storybook.py --source <source_dir> --unite <N> --book <M> [options]

示例:
    python import_storybook.py --source ./storybook_unite1_book1 --unite 1 --book 1 --default
"""

import json
import os
import shutil
import argparse
from pathlib import Path
from typing import List, Dict, Optional


class StorybookImporter:
    """故事书资源导入器"""

    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.json_path = self.project_root / "VocFr/Data/JSON/Storybooks.json"
        self.images_base = self.project_root / "VocFr/Resources/Images/Storybooks"
        self.audio_base = self.project_root / "VocFr/Resources/Audio/Storybooks"

    def parse_transcript(self, transcript_path: str) -> List[Dict[str, str]]:
        """
        解析 transcript.txt 文件

        格式示例:
        === Page 1 ===
        Bonjour ! Je m'appelle Sophie.
        你好！我叫索菲。

        === Page 2 ===
        Voici ma classe.
        这是我的教室。

        也支持标记格式:
        [FR] Bonjour ! Je m'appelle Sophie.
        [ZH] 你好！我叫索菲。
        """
        pages = []
        current_page = {}

        with open(transcript_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        page_num = 0
        for line in lines:
            line = line.strip()

            # 检测新页面标记
            if line.startswith('=== Page ') or line.startswith('## Page '):
                if current_page:
                    pages.append(current_page)
                page_num += 1
                current_page = {'pageNumber': page_num}
                continue

            # 跳过空行
            if not line:
                continue

            # 检测标记格式 [FR] / [ZH]
            if line.startswith('[FR]'):
                current_page['contentFrench'] = line[4:].strip()
            elif line.startswith('[ZH]'):
                current_page['contentChinese'] = line[4:].strip()
            # 自动检测格式（法语在前，中文在后）
            elif 'contentFrench' not in current_page:
                current_page['contentFrench'] = line
            elif 'contentChinese' not in current_page:
                current_page['contentChinese'] = line

        # 添加最后一页
        if current_page:
            pages.append(current_page)

        return pages

    def import_resources(
        self,
        source_dir: str,
        unite_num: int,
        book_num: int,
        title_fr: str,
        title_zh: str,
        is_default: bool = False,
        required_gems: int = 10
    ) -> Dict:
        """
        导入故事书资源

        Args:
            source_dir: 源资源目录（包含图片、音频、transcript.txt）
            unite_num: Unite编号 (1-6)
            book_num: Book编号 (1, 2, 3...)
            title_fr: 法语标题
            title_zh: 中文标题
            is_default: 是否为默认故事书
            required_gems: 所需宝石数量

        Returns:
            故事书JSON数据
        """
        source_path = Path(source_dir)
        transcript_file = source_path / "transcript.txt"

        if not transcript_file.exists():
            raise FileNotFoundError(f"未找到 transcript.txt 文件: {transcript_file}")

        # 1. 解析文本
        print(f"📖 解析 transcript.txt...")
        pages_data = self.parse_transcript(str(transcript_file))
        print(f"   找到 {len(pages_data)} 页内容")

        # 2. 创建目标目录
        unite_id = f"unite{unite_num}"
        book_id = f"Book{book_num}"

        target_images_dir = self.images_base / f"Unite{unite_num}" / book_id
        target_audio_dir = self.audio_base / f"Unite{unite_num}" / book_id

        target_images_dir.mkdir(parents=True, exist_ok=True)
        target_audio_dir.mkdir(parents=True, exist_ok=True)

        print(f"📁 创建目标目录:")
        print(f"   图片: {target_images_dir}")
        print(f"   音频: {target_audio_dir}")

        # 3. 复制封面图片
        cover_src = source_path / "cover.png"
        if cover_src.exists():
            cover_dst = target_images_dir / "cover.png"
            shutil.copy2(cover_src, cover_dst)
            print(f"✅ 复制封面: cover.png")
        else:
            print(f"⚠️  未找到封面图片: cover.png")

        # 4. 复制页面插图和音频
        for page in pages_data:
            page_num = page['pageNumber']

            # 图片
            image_src = source_path / f"page{page_num}.png"
            if image_src.exists():
                image_dst = target_images_dir / f"page{page_num}.png"
                shutil.copy2(image_src, image_dst)
                page['imageName'] = f"storybook_unite{unite_num}_book{book_num}_page{page_num}"
                print(f"✅ 复制图片: page{page_num}.png")
            else:
                page['imageName'] = None
                print(f"⚠️  未找到图片: page{page_num}.png")

            # 音频
            audio_src = source_path / f"story_unite{unite_num}_page{page_num}.mp3"
            if audio_src.exists():
                audio_dst = target_audio_dir / f"story_unite{unite_num}_page{page_num}.mp3"
                shutil.copy2(audio_src, audio_dst)
                page['audioFileName'] = f"story_unite{unite_num}_page{page_num}.mp3"
                print(f"✅ 复制音频: story_unite{unite_num}_page{page_num}.mp3")
            else:
                page['audioFileName'] = None
                print(f"⚠️  未找到音频: story_unite{unite_num}_page{page_num}.mp3")

        # 5. 生成JSON数据
        storybook_id = f"storybook_unite{unite_num}_{'default' if is_default else f'extra{book_num-1}'}"

        storybook_data = {
            "id": storybook_id,
            "title": title_fr,
            "titleInChinese": title_zh,
            "uniteId": unite_id,
            "isUnlocked": False,
            "isDefault": is_default,
            "requiredGems": 0 if is_default else required_gems,
            "orderIndex": (unite_num - 1) * 10 + book_num,
            "coverImageName": f"storybook_unite{unite_num}_book{book_num}_cover",
            "pages": pages_data
        }

        print(f"\n📚 故事书数据生成完成:")
        print(f"   ID: {storybook_id}")
        print(f"   标题: {title_fr} / {title_zh}")
        print(f"   页数: {len(pages_data)}")
        print(f"   类型: {'默认故事书' if is_default else f'额外故事书 ({required_gems}💎)'}")

        return storybook_data

    def update_json(self, storybook_data: Dict, dry_run: bool = False):
        """
        更新 Storybooks.json 文件

        Args:
            storybook_data: 故事书数据
            dry_run: 是否为预览模式（不实际写入文件）
        """
        # 读取现有JSON
        if self.json_path.exists():
            with open(self.json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        else:
            data = {"storybooks": []}

        # 检查是否已存在
        storybooks = data.get("storybooks", [])
        existing_index = None

        for i, sb in enumerate(storybooks):
            if sb['id'] == storybook_data['id']:
                existing_index = i
                break

        if existing_index is not None:
            print(f"\n⚠️  发现已存在的故事书: {storybook_data['id']}")
            print(f"   将替换现有数据")
            storybooks[existing_index] = storybook_data
        else:
            print(f"\n➕ 添加新故事书: {storybook_data['id']}")
            storybooks.append(storybook_data)

        data["storybooks"] = storybooks

        if dry_run:
            print(f"\n🔍 预览模式 - 不写入文件")
            print(f"   将写入到: {self.json_path}")
            return

        # 写入JSON文件
        with open(self.json_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"\n✅ JSON文件已更新: {self.json_path}")
        print(f"   总故事书数量: {len(storybooks)}")


def main():
    parser = argparse.ArgumentParser(
        description='故事书资源导入工具',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:

1. 导入Unite 1的默认故事书:
   python import_storybook.py \\
       --source ./storybook_unite1_book1 \\
       --unite 1 --book 1 \\
       --title-fr "À l'école - Mon premier jour" \\
       --title-zh "在学校 - 我的第一天" \\
       --default

2. 导入Unite 1的额外故事书:
   python import_storybook.py \\
       --source ./storybook_unite1_book2 \\
       --unite 1 --book 2 \\
       --title-fr "Les couleurs de ma classe" \\
       --title-zh "我的教室的颜色" \\
       --gems 10

3. 预览模式（不实际导入）:
   python import_storybook.py \\
       --source ./storybook_unite1_book1 \\
       --unite 1 --book 1 \\
       --title-fr "Test" --title-zh "测试" \\
       --dry-run
        """
    )

    parser.add_argument('--source', '-s', required=True,
                        help='源资源目录路径')
    parser.add_argument('--unite', '-u', type=int, required=True,
                        help='Unite编号 (1-6)')
    parser.add_argument('--book', '-b', type=int, required=True,
                        help='Book编号 (1, 2, 3...)')
    parser.add_argument('--title-fr', required=True,
                        help='法语标题')
    parser.add_argument('--title-zh', required=True,
                        help='中文标题')
    parser.add_argument('--default', action='store_true',
                        help='是否为默认故事书（Test解锁）')
    parser.add_argument('--gems', type=int, default=10,
                        help='所需宝石数量（默认10，默认故事书忽略此参数）')
    parser.add_argument('--project', '-p', default='.',
                        help='项目根目录路径（默认为当前目录）')
    parser.add_argument('--dry-run', action='store_true',
                        help='预览模式，不实际导入文件')

    args = parser.parse_args()

    # 验证参数
    if args.unite < 1 or args.unite > 6:
        print("❌ Unite编号必须在1-6之间")
        return 1

    if args.book < 1:
        print("❌ Book编号必须大于0")
        return 1

    if not os.path.isdir(args.source):
        print(f"❌ 源目录不存在: {args.source}")
        return 1

    # 创建导入器
    importer = StorybookImporter(args.project)

    print("=" * 60)
    print("📚 Storybook Resource Importer")
    print("=" * 60)
    print(f"源目录: {args.source}")
    print(f"Unite {args.unite} - Book {args.book}")
    print(f"标题: {args.title_fr} / {args.title_zh}")
    print(f"类型: {'默认故事书 (Test解锁)' if args.default else f'额外故事书 ({args.gems}💎)'}")
    if args.dry_run:
        print("⚠️  预览模式 - 不会实际导入文件")
    print("=" * 60)
    print()

    try:
        # 导入资源
        storybook_data = importer.import_resources(
            source_dir=args.source,
            unite_num=args.unite,
            book_num=args.book,
            title_fr=args.title_fr,
            title_zh=args.title_zh,
            is_default=args.default,
            required_gems=args.gems
        )

        # 更新JSON
        importer.update_json(storybook_data, dry_run=args.dry_run)

        print("\n" + "=" * 60)
        print("✅ 导入完成！")
        print("=" * 60)

        if not args.dry_run:
            print("\n📝 下一步:")
            print("   1. 在Xcode中将新添加的图片和音频文件添加到项目")
            print("   2. 确保图片添加到 Assets.xcassets")
            print("   3. 确保音频文件正确关联到target")
            print("   4. 运行应用测试故事书功能")

        return 0

    except Exception as e:
        print(f"\n❌ 导入失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    exit(main())
