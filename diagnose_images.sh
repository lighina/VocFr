#!/bin/bash

echo "🔍 Image Asset Diagnosis Report"
echo "================================"
echo ""

for word in "eponge" "ecole" "mere" "pere" "frere" "garcon" "zero" "fenetre" "derriere" "ecouter" "grand-mere" "grand-pere"; do
    echo "--- Checking: ${word}_image ---"
    
    # Find imageset directory
    imageset=$(find VocFr/Assets.xcassets -name "*${word}*image.imageset" -type d 2>/dev/null | head -1)
    
    if [ -z "$imageset" ]; then
        echo "  ❌ Image set not found"
    else
        echo "  ✅ Found: $(basename "$imageset")"
        
        # Check PNG files
        echo "  PNG files:"
        ls -1 "$imageset"/*.png 2>/dev/null | while read png; do
            echo "    - $(basename "$png")"
        done
        
        # Check Contents.json
        if [ -f "$imageset/Contents.json" ]; then
            filename=$(grep -o '"filename" : "[^"]*"' "$imageset/Contents.json" | cut -d'"' -f4)
            echo "  Contents.json references: $filename"
        fi
    fi
    echo ""
done

echo "--- Checking FrenchWord.swift references ---"
grep -o '"[^"]*_image"' VocFr/Data/Seeds/FrenchWord.swift | grep -E "(éponge|école|mère|père|frère|garçon|zéro|fenêtre|derrière|écouter)" | head -15
