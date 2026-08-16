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

require() {
    local label="$1"
    shift
    echo "[Mond2 verify] $label"
    if ! "$@"; then
        echo "[Mond2 verify] FAILED: $label" >&2
        exit 1
    fi
}

require_grep() {
    local label="$1" needle="$2" file="$3"
    echo "[Mond2 verify] $label"
    if ! grep -aFq "$needle" "$file"; then
        echo "[Mond2 verify] FAILED: $label (missing: $needle)" >&2
        exit 1
    fi
}

require "dylib exists" test -s "$OUT"
require "arm64 architecture" test "$(lipo -archs "$OUT")" = "arm64"
require_grep "install name" '@rpath/Mond2Embedded.dylib' <(otool -L "$OUT")

echo "[Mond2 verify] no dynamic PartyUI/ZIPFoundation dependency"
if otool -L "$OUT" | grep -E '/(PartyUI|ZIPFoundation)'; then
    echo "[Mond2 verify] FAILED: PartyUI or ZIPFoundation remained dynamically linked" >&2
    exit 1
fi

# Exact 2.0 feature/lifecycle markers. These must come from the untouched
# upstream files; the wrapper contributes only the explicit provenance marker.
require_grep "Tendies route" 'Explore Tendies' "$OUT"
require_grep "HouseArrest route" 'HouseArrest' "$OUT"
require_grep "Run Exploit action" 'Run Exploit' "$OUT"
require_grep "Generate Token action" 'Generate Token' "$OUT"
require_grep "external host provenance" 'exact upstream mond 2.0 runtime configured commit=87b38b2726160c6d1cfacbbfa834a2572d7ca333' "$OUT"

echo "[Mond2 verify] upstream @main symbol"
if ! nm "$OUT" | grep -Eq '[[:space:]]_main$'; then
    echo "[Mond2 verify] FAILED: upstream @main symbol not exported" >&2
    nm "$OUT" | grep -E 'main|Mond2Embedded' | head -n 80 || true
    exit 1
fi

# Compilation is not allowed to mutate the staged upstream repositories.
require "Mond repo remains git-clean" test -z "$(git -C "$MOND" status --porcelain)"
require "PartyUI repo remains git-clean" test -z "$(git -C "$PARTYUI" status --porcelain)"
require "ZIPFoundation repo remains git-clean" test -z "$(git -C "$ZIPFOUNDATION" status --porcelain)"

shasum -a 256 "$OUT"
echo "Built isolated exact Mond 2.0 dylib without modifying upstream source"