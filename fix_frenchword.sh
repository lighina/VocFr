#!/bin/bash

FILE="VocFr/Data/Seeds/FrenchWord.swift"

echo "🔧 Fixing FrenchWord.swift..."

# 备份
cp "$FILE" "${FILE}.backup"

# 替换所有带重音的图片名称为 ASCII
sed -i '' 's/"mère_image"/"mere_image"/g' "$FILE"
sed -i '' 's/"père_image"/"pere_image"/g' "$FILE"
sed -i '' 's/"grand-mère_image"/"grand_mere_image"/g' "$FILE"
sed -i '' 's/"grand-père_image"/"grand_pere_image"/g' "$FILE"
sed -i '' 's/"frère_image"/"frere_image"/g' "$FILE"
sed -i '' 's/"derrière_image"/"derriere_image"/g' "$FILE"
sed -i '' 's/"fenêtre_image"/"fenetre_image"/g' "$FILE"
sed -i '' 's/"école_image"/"ecole_image"/g' "$FILE"
sed -i '' 's/"écouter_image"/"ecouter_image"/g' "$FILE"
sed -i '' 's/"éponge_image"/"eponge_image"/g' "$FILE"
sed -i '' 's/"zéro_image"/"zero_image"/g' "$FILE"
sed -i '' 's/"garçon_image"/"garcon_image"/g' "$FILE"

echo "✅ Replacements done!"
echo ""
echo "Verifying changes:"
grep -c "mere_image" "$FILE"
grep -c "eponge_image" "$FILE"
grep -c "ecole_image" "$FILE"

