# Phase 2.5 Testing Guide

## 🎉 What Changed

**Data Architecture Refactoring**: Split monolithic `vocabulary.json` into separate files.

### Before (Phase 2)
```
VocFr/Data/JSON/
└── vocabulary.json  (~1963 lines, all 3 unités)
```

### After (Phase 2.5)
```
VocFr/Data/JSON/
├── metadata.json       (229 bytes, metadata)
├── Unite1.json        (18 KB, 77 words)
├── Unite2.json        (20 KB, 88 words)
└── Unite3.json        (15 KB, 63 words)
```

## ✅ What's Completed

1. ✅ Created `split_vocabulary.py` tool
2. ✅ Generated Unite1.json, Unite2.json, Unite3.json
3. ✅ Created metadata.json
4. ✅ Updated VocabularyDataLoader with:
   - `loadSplitFormat()` - loads from metadata + Unite files
   - `loadMonolithicFormat()` - fallback to vocabulary.json
   - `findFile()` - searches bundle for files
5. ✅ Maintained backward compatibility
6. ✅ Committed and pushed to GitHub

## 🧪 Testing Instructions

### Step 1: Sync Your Local Repository

```bash
cd /Volumes/DevSSD/Code/Swift/Projects/VocFr
git pull
```

**Expected files:**
- `VocFr/Data/JSON/Unite1.json`
- `VocFr/Data/JSON/Unite2.json`
- `VocFr/Data/JSON/Unite3.json`
- `VocFr/Data/JSON/metadata.json`
- `VocFr/Services/Data/VocabularyDataLoader.swift` (updated)
- `split_vocabulary.py`

### Step 2: Add JSON Files to Xcode Project

**Important**: New files need to be added to Xcode's build target.

1. Open Xcode
2. Right-click on `VocFr/Data/JSON/` folder in Project Navigator
3. Select "Add Files to VocFr..."
4. Select all new JSON files:
   - ✅ Unite1.json
   - ✅ Unite2.json
   - ✅ Unite3.json
   - ✅ metadata.json
5. Make sure "Copy items if needed" is **UNCHECKED**
6. Make sure "Add to targets: VocFr" is **CHECKED**
7. Click "Add"

### Step 3: Build and Run

1. Clean Build Folder (Cmd + Shift + K)
2. Build (Cmd + B)
3. Run (Cmd + R)

### Step 4: Verify Console Output

Look for these messages in Xcode console:

**✅ Expected Output (Split Format):**
```
📦 Loading split-file format (metadata.json + Unite*.json)
📖 Metadata version: 1.0
📅 Last updated: 2025-11-12
📊 Total unités: 3
🎯 Data format: split
  ✅ Loaded Unite 1: À l'école (77 words)
  ✅ Loaded Unite 2: C'est la fête (88 words)
  ✅ Loaded Unite 3: Mon chez-moi (63 words)
✅ Successfully loaded 3 unités with 228 unique words
```

**⚠️ Fallback Output (If files not added to bundle):**
```
📦 Loading monolithic format (vocabulary.json)
📖 Loaded vocabulary data version: 1.0
📅 Last updated: 2025-11-11
✅ Successfully loaded 3 unités with 228 unique words
```

### Step 5: Test App Functionality

Verify all features work correctly:
- ✅ All unités visible
- ✅ All sections accessible
- ✅ All words display correctly
- ✅ Images show properly
- ✅ Audio plays (timestamp-based, unchanged)
- ✅ Navigation works
- ✅ Progress tracking works

## ❌ Troubleshooting

### Issue: "metadata.json not found"

**Solution**: Files not added to Xcode target.
1. Select each JSON file in Project Navigator
2. Check "Target Membership" in File Inspector (right panel)
3. Ensure "VocFr" target is checked

### Issue: App crashes on launch

**Solution**: Check console for error messages.
- Could be JSON decoding error
- Could be missing file in bundle
- Fallback to vocabulary.json should work

### Issue: Some words missing

**Solution**: Verify all Unite files loaded.
- Check console output
- Should see "Loaded Unite 1, 2, 3"
- Total should be 228 words

## 📊 Performance Notes

- **Load time**: Should be similar or slightly faster (3 small files vs 1 large)
- **Memory**: Unchanged
- **App size**: Slightly larger (split files have more overhead)

## 🔄 Rollback (If Needed)

If there are issues, you can rollback:

```bash
git revert HEAD
git push
```

Then rebuild in Xcode. App will fallback to `vocabulary.json`.

## 🎯 Next Steps

After successful testing:

1. ✅ Verify all functionality works
2. ✅ Check console for any warnings
3. ✅ Test on device (if possible)
4. ⏳ **Optional**: Delete old `vocabulary.json` (or keep for backup)
5. ⏳ **Future**: Phase 2.6 - Audio architecture refactoring

## 📝 Notes

- **Audio format**: Still using timestamp-based audio (unchanged)
- **Backward compatibility**: If split files missing, falls back to vocabulary.json
- **Data consistency**: All 228 words maintained, no data loss
- **Git workflow**: Future changes to specific unités only affect their files

## 🤔 Questions?

If you encounter any issues, check:
1. Console output for error messages
2. File Inspector for target membership
3. Build phases for "Copy Bundle Resources"

---

**Status**: Phase 2.5 Complete ✅
**Next**: Test in Xcode → Phase 3 (MVVM) or Phase 2.6 (Audio)
