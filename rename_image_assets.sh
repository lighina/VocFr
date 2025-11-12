#!/bin/bash

# Script to rename French-accented Image Sets in Assets.xcassets
# This fixes the issue where Word.imageName uses ASCII names but Assets still have accented names

ASSETS_DIR="VocFr/Assets.xcassets"

echo "🔧 开始重命名 Image Sets..."
echo "目录: $ASSETS_DIR"
echo ""

# Check if Assets directory exists
if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ 错误: 找不到 Assets.xcassets 目录"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

# Array of renames: old_name|new_name
declare -a renames=(
    "éponge_image.imageset|eponge_image.imageset"
    "école_image.imageset|ecole_image.imageset"
    "fenêtre_image.imageset|fenetre_image.imageset"
    "garçon_image.imageset|garcon_image.imageset"
    "mère_image.imageset|mere_image.imageset"
    "père_image.imageset|pere_image.imageset"
    "frère_image.imageset|frere_image.imageset"
    "grand-mère_image.imageset|grand_mere_image.imageset"
    "grand-père_image.imageset|grand_pere_image.imageset"
    "derrière_image.imageset|derriere_image.imageset"
    "zéro_image.imageset|zero_image.imageset"
    "écouter_image.imageset|ecouter_image.imageset"
)

renamed_count=0
skipped_count=0

for rename_pair in "${renames[@]}"; do
    IFS='|' read -r old_name new_name <<< "$rename_pair"

    old_path="$ASSETS_DIR/$old_name"
    new_path="$ASSETS_DIR/$new_name"

    if [ -d "$old_path" ]; then
        echo "✓ 重命名: $old_name → $new_name"
        mv "$old_path" "$new_path"

        # Update Contents.json to use ASCII filename for PNG
        contents_json="$new_path/Contents.json"
        if [ -f "$contents_json" ]; then
            # Extract the old PNG name from Contents.json
            old_png=$(basename "$old_name" .imageset)
            new_png=$(basename "$new_name" .imageset)

            # Update Contents.json
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "s/${old_png}/${new_png}/g" "$contents_json"
            else
                # Linux
                sed -i "s/${old_png}/${new_png}/g" "$contents_json"
            fi

            echo "  ✓ 更新 Contents.json"

            # Rename PNG files inside
            for png_file in "$new_path"/*.png; do
                if [ -f "$png_file" ]; then
                    png_basename=$(basename "$png_file")
                    # If PNG still has accents, rename it
                    if [[ $png_basename == *é* ]] || [[ $png_basename == *è* ]] || [[ $png_basename == *ê* ]] || [[ $png_basename == *à* ]] || [[ $png_basename == *ç* ]]; then
                        new_png_name=$(echo "$png_basename" | sed 's/é/e/g; s/è/e/g; s/ê/e/g; s/à/a/g; s/ô/o/g; s/ù/u/g; s/ç/c/g; s/-/_/g')
                        mv "$png_file" "$new_path/$new_png_name"
                        echo "  ✓ 重命名 PNG: $png_basename → $new_png_name"
                    fi
                fi
            done
        fi

        ((renamed_count++))
    else
        echo "⊘ 跳过 (不存在): $old_name"
        ((skipped_count++))
    fi
done

echo ""
echo "============================================"
echo "✅ 完成！"
echo "   重命名: $renamed_count 个 Image Sets"
echo "   跳过: $skipped_count 个 (已重命名或不存在)"
echo "============================================"
echo ""
echo "📝 后续步骤:"
echo "1. 在 Xcode 中检查 Assets.xcassets，确认图片正确重命名"
echo "2. Clean Build Folder (Shift+Cmd+K)"
echo "3. 删除模拟器中的 App"
echo "4. 运行 App 测试图片显示"
