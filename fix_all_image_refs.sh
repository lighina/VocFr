#!/bin/bash

FILE="VocFr/Data/Seeds/FrenchWord.swift"

echo "🔧 Fixing ALL image references in FrenchWord.swift..."

# 备份
cp "$FILE" "${FILE}.backup2"

# 替换所有出现（不仅仅是带引号的）
perl -i -pe 's/éponge_image/eponge_image/g' "$FILE"
perl -i -pe 's/école_image/ecole_image/g' "$FILE"
perl -i -pe 's/mère_image/mere_image/g' "$FILE"
perl -i -pe 's/père_image/pere_image/g' "$FILE"
perl -i -pe 's/frère_image/frere_image/g' "$FILE"
perl -i -pe 's/garçon_image/garcon_image/g' "$FILE"
perl -i -pe 's/zéro_image/zero_image/g' "$FILE"
perl -i -pe 's/fenêtre_image/fenetre_image/g' "$FILE"
perl -i -pe 's/derrière_image/derriere_image/g' "$FILE"
perl -i -pe 's/écouter_image/ecouter_image/g' "$FILE"
perl -i -pe 's/grand-mère_image/grand_mere_image/g' "$FILE"
perl -i -pe 's/grand-père_image/grand_pere_image/g' "$FILE"

echo "✅ All replacements done!"
echo ""
echo "Verifying - searching for any remaining accented names:"
if grep -E "(éponge|école|mère|père|frère|garçon|zéro|fenêtre|derrière|écouter)_image" "$FILE"; then
    echo "⚠️  Found some remaining accented names above"
else
    echo "✅ No accented image names found - all clean!"
fi

