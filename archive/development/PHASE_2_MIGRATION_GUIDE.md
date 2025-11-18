# Phase 2 Migration Guide: JSON Data Loading

## Overview

Phase 2 refactors the data layer to use JSON files instead of hardcoded Swift arrays. This reduces `FrenchWord.swift` from 1,461 lines to ~300 lines and makes vocabulary data easier to maintain.

## What Changed

### 1. New Files Created

#### `VocFr/Data/JSON/vocabulary.json` (7,894 lines)
- Contains all vocabulary data (228 words, 15 sections, 3 unités)
- Structured JSON format with versioning
- Generated from existing FrenchWord.swift data

#### `VocFr/Services/Data/VocabularyDataLoader.swift` (285 lines)
- Service class to load and parse JSON vocabulary data
- Converts JSON to SwiftData models
- Handles word caching to avoid duplicates
- Generates word forms (articles, singular/plural)
- Normalizes French text for image asset names

### 2. Modified Files

#### `VocFr/Data/Seeds/FrenchWord.swift`
- `seedAllData()` now calls `VocabularyDataLoader.loadVocabularyData()`
- Old hardcoded data functions marked as legacy (to be removed after testing)
- Will be reduced from 1,461 to ~300 lines once legacy code is removed

## Testing Steps

### 1. Add vocabulary.json to Xcode Project

**CRITICAL**: The JSON file must be added to the Xcode project bundle

1. Open Xcode
2. In Project Navigator, right-click on `VocFr/Data/JSON/` folder
3. Select "Add Files to VocFr..."
4. Navigate to `VocFr/Data/JSON/vocabulary.json`
5. **IMPORTANT**: Check "Copy items if needed" ✓
6. **IMPORTANT**: Check "Add to targets: VocFr" ✓
7. Click "Add"

### 2. Verify File is in Bundle

1. Select `VocFr` target in Xcode
2. Go to "Build Phases" tab
3. Expand "Copy Bundle Resources"
4. Verify `vocabulary.json` is listed
5. If not, click "+" and add it

### 3. Clean and Build

```bash
# In Xcode:
1. Product → Clean Build Folder (Shift+Cmd+K)
2. Delete app from simulator
3. Product → Build (Cmd+B)
```

### 4. Test Data Loading

Run the app and check console output for:

```
📖 Loading vocabulary data from JSON...
📖 Loaded vocabulary data version: 1.0
📅 Last updated: 2025-11-11
✅ Successfully loaded 228 unique words
✅ Successfully loaded 3 unités from JSON
✅ 成功导入 3 个单元的数据到 SwiftData
```

### 5. Validate Data Integrity

Check that:
- All 3 Unités display correctly
- All 15 Sections are present
- All 228 words load with correct:
  - French canonical form
  - Chinese translations
  - Images (especially accented words like éponge, école, etc.)
  - Word forms (articles)
- Audio playback works
- Practice mode functions correctly

## Expected Console Output

### Success Output
```
📖 Loading vocabulary data from JSON...
📖 Loaded vocabulary data version: 1.0
📅 Last updated: 2025-11-11
✅ Successfully loaded 3 unités with 228 unique words
✅ Successfully loaded 3 unités from JSON
✅ 成功导入 3 个单元的数据到 SwiftData
成功导入 3 个单元的数据
```

### Error Scenarios

#### File Not Found
```
❌ Error: File not found: vocabulary.json not found in bundle
```
**Solution**: Follow "Add vocabulary.json to Xcode Project" steps above

#### JSON Parsing Error
```
❌ Error: Decoding failed: [error details]
```
**Solution**: Check vocabulary.json syntax, ensure it's valid JSON

#### SwiftData Insertion Error
```
❌ Error: [SwiftData error]
```
**Solution**: Check model relationships are properly set

## Comparison: Before vs After

### Before (Hardcoded)
- Data defined in Swift arrays (~1,200 lines)
- Hard to maintain and update
- No versioning
- Difficult to export/import
- Mixed concerns (data + logic)

### After (JSON)
- Data in structured JSON file
- Easy to edit with any text editor
- Version tracked in JSON
- Can be exported/imported easily
- Separation of concerns

## Data Integrity Checklist

Compare the loaded data with original hardcoded data:

- [ ] 3 Unités total
- [ ] Unité 1: "À l'école" (5 sections, unlocked)
- [ ] Unité 2: "La famille" (5 sections, requires 10 stars)
- [ ] Unité 3: "Les animaux" (5 sections, requires 20 stars)
- [ ] 15 Sections total
- [ ] 228 Words total
- [ ] All accented words have correct images (12 words)
- [ ] Word forms generated correctly for nouns
- [ ] Section order preserved (orderIndex)
- [ ] Word order within sections preserved

## Troubleshooting

### Images Not Displaying
- Ensure `VocabularyDataLoader.normalizeForAssetName()` matches image asset names
- Check Assets.xcassets has all required images
- Verify image names are ASCII (no accents)

### Data Mismatch
- Run `validateData()` function
- Compare JSON word count with expected 228 words
- Check console for any warnings

### Performance Issues
- JSON loading should be fast (<1 second)
- If slow, check for excessive logging
- Ensure word cache is working (no duplicates)

## Next Steps After Successful Testing

1. **Verify all features work**:
   - Browse all units and sections
   - View word details
   - Test practice mode
   - Play audio
   - Check progress tracking

2. **Confirm data integrity**:
   - All 228 words present
   - All images display (especially 12 accented words)
   - Word forms correct
   - Section order correct

3. **If everything works**:
   - Can proceed to remove legacy hardcoded data (~1,200 lines)
   - File size will reduce: 1,461 → ~300 lines
   - Commit and push Phase 2 completion

4. **If issues found**:
   - Report errors with console output
   - Can temporarily revert to hardcoded data
   - Debug and fix issues before removing legacy code

## Files to Commit

```
✓ VocFr/Data/JSON/vocabulary.json (new)
✓ VocFr/Services/Data/VocabularyDataLoader.swift (new)
✓ VocFr/Data/Seeds/FrenchWord.swift (modified)
✓ PHASE_2_MIGRATION_GUIDE.md (this file)
```

## Rollback Plan

If JSON loading fails, can easily rollback:

```swift
// In FrenchWord.swift seedAllData():
// Comment out JSON loading:
// let unites = try VocabularyDataLoader.loadVocabularyData()

// Uncomment hardcoded data:
let unites = createAllUnites()
```

Legacy code is preserved until JSON migration is fully verified.

---

**Status**: Ready for testing on Mac with Xcode
**Estimated Testing Time**: 15-20 minutes
**Risk Level**: Low (legacy code preserved as fallback)
