#!/bin/bash
set -e
BASE="/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android"
SRC="$BASE/newb-source"
SHADER="$BASE/piglix-rtx-shader"
DL="/Users/sopanvijaypatil/Downloads"

build_one() {
  local NAME="$1"; local UUID_H="$2"; local UUID_M="$3"
  local DESC="$4"; local OUT="$5"; local CFG="$6"
  echo ">>> Building: $NAME"
  cp "$CFG" "$SRC/src/newb/config.h"
  cd "$SRC" && bash build.sh pack -p android
  cp -R build/pack-android/renderer/* "$SHADER/renderer/"
  cp -R build/pack-android/subpacks/* "$SHADER/subpacks/"
  cd "$SHADER"
  python3 -c "
import json; f='manifest.json'
d=json.load(open(f))
d['header']['uuid']='$UUID_H'
d['modules'][0]['uuid']='$UUID_M'
d['header']['name']='$NAME'
d['header']['description']='$DESC'
json.dump(d,open(f,'w'),indent=2)
"
  rm -f "$DL/$OUT"
  zip -r "$DL/$OUT" . -x ".*" > /dev/null
  echo "<<< Done: $OUT"
}

build_one "Piglix Ash & Ember"    "D686B9EF-361C-49AE-BD92-BA68706F108E" "D8D3F821-0DFC-4F19-9824-F0C1990312BB" "§4Piglix · Ash & Ember\n§7Dark Souls dying world.\nv1.0" "Piglix_Ash_and_Ember.mcpack"    "$BASE/configs/ash_ember.h"
build_one "Piglix Arabian Nights" "A2126C03-0CEC-482E-8480-1C998C13D396" "7577BC63-D34E-457B-9716-3800B04425C2" "§6Piglix · Arabian Nights\n§7Desert gold. Giant moon.\nv1.0"  "Piglix_Arabian_Nights.mcpack"  "$BASE/configs/arabian_nights.h"
build_one "Piglix Permafrost"     "1D28FB66-3007-4D3E-BF88-3F20DBF4B764" "30784782-DE4B-491D-BCD5-8915B96F7526" "§bPiglix · Permafrost\n§7Arctic. Vivid aurora.\nv1.0"         "Piglix_Permafrost.mcpack"      "$BASE/configs/permafrost.h"
build_one "Piglix Eternal Autumn" "6C0AC7D5-B8EE-4373-A983-531D1CBE786A" "65FEE9D1-30FC-40E0-B2D0-88FDAEF9AD5F" "§6Piglix · Eternal Autumn\n§7Cozy fall. Harvest moon.\nv1.0"  "Piglix_Eternal_Autumn.mcpack"  "$BASE/configs/eternal_autumn.h"

echo ""
echo "ALL 4 PACKS REBUILT WITH UNIQUE UUIDs!"
