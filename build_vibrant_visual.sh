#!/bin/bash
set -e

BASE="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android"
SRC="$BASE/newb-source"
PACK_DIR="$BASE/piglix-rtx-shader"
OUT_DIR="/Users/sopanvijaypatil/Downloads"
MCPACK_NAME="Piglix_Vibrant_Visual_Engine.mcpack"

UUID_HEADER="51234081-1FF2-4214-AD84-465578371D11"
UUID_MODULE="42DA1BF3-5ABA-48F0-8BA3-5A228C93CB50"
PACK_NAME="Piglix Vibrant Visual Engine"
PACK_DESC="§dPiglix · Vibrant Visual Engine\n§7Pink Morning Rays · Sky Blue Noon · Very Orange Sunset · Navy Starry Night\n§eReal-Time Shadows & God-Rays\n§cRequired: MB Loader"

echo "=========================================="
echo ">>> Building: $PACK_NAME"
echo "=========================================="

cd "$SRC"
bash build.sh pack -p android

echo ">>> Copying compiled materials to pack..."
cp -R build/pack-android/renderer/* "$PACK_DIR/renderer/"
cp -R build/pack-android/subpacks/* "$PACK_DIR/subpacks/"

# Also update root workspace renderer and subpacks
cp -R build/pack-android/renderer/* "$BASE/renderer/"
cp -R build/pack-android/subpacks/* "$BASE/subpacks/"

echo ">>> Updating manifests with new UUIDs..."
python3 -c "
import json

for f in ['$PACK_DIR/manifest.json', '$BASE/manifest.json']:
    try:
        data = json.load(open(f))
        data['header']['name'] = '$PACK_NAME'
        data['header']['description'] = '''$PACK_DESC'''
        data['header']['uuid'] = '$UUID_HEADER'
        data['modules'][0]['uuid'] = '$UUID_MODULE'
        json.dump(data, open(f, 'w'), indent=2)
        print('Updated:', f)
    except Exception as e:
        print('Error updating', f, e)
"

echo ">>> Packaging $MCPACK_NAME into $OUT_DIR..."
cd "$PACK_DIR"
rm -f "$OUT_DIR/$MCPACK_NAME"
zip -r "$OUT_DIR/$MCPACK_NAME" . -x ".*" > /dev/null

echo "=========================================="
echo "SUCCESS! Created: $OUT_DIR/$MCPACK_NAME"
echo "Header UUID: $UUID_HEADER"
echo "Module UUID: $UUID_MODULE"
echo "=========================================="
