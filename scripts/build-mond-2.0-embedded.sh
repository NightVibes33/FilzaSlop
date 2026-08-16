#!/usr/bin/env bash
set -euo pipefail

ROOT="${MOND2_STAGE_ROOT:-$PWD/.theos/mond2}"
MOND="$ROOT/mond"
PARTYUI="$ROOT/PartyUI"
ZIPFOUNDATION="$ROOT/ZIPFoundation"
BUILD="$ROOT/build"
MODULES="$BUILD/modules"
LIBS="$BUILD/lib"
OBJ="$BUILD/obj"
OUT="$PWD/.theos/obj/Mond2Embedded.dylib"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
TARGET="arm64-apple-ios17.0"

bash scripts/stage-mond-2.0.sh
rm -rf "$BUILD"
mkdir -p "$MODULES" "$LIBS" "$OBJ" "$(dirname "$OUT")"

# bash 3.2 on macOS has no mapfile/readarray, so populate arrays explicitly.
PARTY_SOURCES=()
while IFS= read -r source; do PARTY_SOURCES+=("$source"); done < <(find "$PARTYUI/Sources/PartyUI" -type f -name '*.swift' -print | sort)
ZIP_SOURCES=()
while IFS= read -r source; do ZIP_SOURCES+=("$source"); done < <(find "$ZIPFOUNDATION/Sources/ZIPFoundation" -maxdepth 1 -type f -name '*.swift' -print | sort)
MOND_SOURCES=()
while IFS= read -r source; do MOND_SOURCES+=("$source"); done < <(find "$MOND/mond" -type f -name '*.swift' -print | sort)

test "${#PARTY_SOURCES[@]}" -gt 0
test "${#ZIP_SOURCES[@]}" -ge 20
test "${#MOND_SOURCES[@]}" -eq 16
printf '%s\n' "${MOND_SOURCES[@]}" | grep -Fq '/mond/mond.swift'
printf '%s\n' "${MOND_SOURCES[@]}" | grep -Fq '/views/tweaks/posterboard/TendiesView.swift'
printf '%s\n' "${MOND_SOURCES[@]}" | grep -Fq '/views/tweaks/SantanderView.swift'

COMMON_SWIFT=(
    -target "$TARGET"
    -sdk "$SDK"
    -parse-as-library
    -module-cache-path "$BUILD/ModuleCache"
)

xcrun --sdk iphoneos swiftc "${COMMON_SWIFT[@]}" \
    -swift-version 6 \
    -O \
    -emit-library -static \
    -emit-module \
    -module-name PartyUI \
    -emit-module-path "$MODULES/PartyUI.swiftmodule" \
    -o "$LIBS/libPartyUI.a" \
    "${PARTY_SOURCES[@]}"

xcrun --sdk iphoneos swiftc "${COMMON_SWIFT[@]}" \
    -swift-version 5 \
    -O \
    -emit-library -static \
    -emit-module \
    -module-name ZIPFoundation \
    -emit-module-path "$MODULES/ZIPFoundation.swiftmodule" \
    -o "$LIBS/libZIPFoundation.a" \
    "${ZIP_SOURCES[@]}"

xcrun --sdk iphoneos clang \
    -target "$TARGET" \
    -isysroot "$SDK" \
    -fPIC \
    -I "$MOND/mond/exploit/bad_query" \
    -c "$MOND/mond/exploit/bad_query/bad_query.c" \
    -o "$OBJ/mond_bad_query.o"

xcrun --sdk iphoneos swiftc "${COMMON_SWIFT[@]}" \
    -swift-version 5 \
    -default-isolation MainActor \
    -O \
    -emit-library \
    -module-name Mond2Embedded \
    -import-objc-header "$MOND/mond/bridging.h" \
    -Xcc -I"$MOND/mond/exploit/bad_query" \
    -I "$MODULES" \
    -L "$LIBS" \
    -lPartyUI \
    -lZIPFoundation \
    "${MOND_SOURCES[@]}" \
    Mond2EmbeddedHost.swift \
    "$OBJ/mond_bad_query.o" \
    -framework UIKit \
    -framework Foundation \
    -framework SwiftUI \
    -framework Combine \
    -framework UniformTypeIdentifiers \
    -framework SafariServices \
    -framework WebKit \
    -framework AVKit \
    -framework AVFoundation \
    -framework ImageIO \
    -lcompression \
    -lz \
    -Xlinker -install_name \
    -Xlinker @rpath/Mond2Embedded.dylib \
    -o "$OUT"

test -s "$OUT"
test "$(lipo -archs "$OUT")" = "arm64"
otool -L "$OUT" | grep -F '@rpath/Mond2Embedded.dylib'
! otool -L "$OUT" | grep -E '/(PartyUI|ZIPFoundation)'

# Exact 2.0 feature/lifecycle markers. These must come from the untouched
# upstream files; the wrapper contributes only the explicit provenance marker.
grep -aFq 'Explore Tendies' "$OUT"
grep -aFq 'HouseArrest' "$OUT"
grep -aFq 'Run Exploit' "$OUT"
grep -aFq 'Generate Token' "$OUT"
grep -aFq 'exact upstream mond 2.0 runtime configured commit=87b38b2726160c6d1cfacbbfa834a2572d7ca333' "$OUT"
nm "$OUT" | grep -Eq '[[:space:]]_main$'

# Compilation is not allowed to mutate the staged upstream repositories.
test -z "$(git -C "$MOND" status --porcelain)"
test -z "$(git -C "$PARTYUI" status --porcelain)"
test -z "$(git -C "$ZIPFOUNDATION" status --porcelain)"

shasum -a 256 "$OUT"
echo "Built isolated exact Mond 2.0 dylib without modifying upstream source"
