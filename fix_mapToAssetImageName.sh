#!/bin/bash

FILE="VocFr/Data/Seeds/FrenchWord.swift"

echo "🔧 Fixing mapToAssetImageName function..."

# 备份
cp "$FILE" "${FILE}.backup3"

# 替换第 562 行的 fallback
# 从: return "\(canonical)_image"
# 到: return "\(normalizeForAssetName(canonical))_image"

sed -i '' '562s|return "\\(canonical)_image"|return "\\(normalizeForAssetName(canonical))_image"|' "$FILE"

echo "✅ Function fixed!"
echo ""
echo "Verifying line 562:"
sed -n '562p' "$FILE"

