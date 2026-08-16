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
MOND_COMMIT="500d76082f0ca021ddd591c05d129ebbc26c20df"

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
test "$(git -C "$MOND" rev-parse HEAD)" = "$MOND_COMMIT"

COMMON_SWIFT=(
    -target "$TARGET"
    -sdk "$SDK"
    -parse-as-library
    -module-cache-path "$BUILD/ModuleCache"
)

xcrun swiftc "${COMMON_SWIFT[@]}" \
    -swift-version 6 \
    -O \
    -emit-library -static \
    -emit-module \
    -module-name PartyUI \
    -emit-module-path "$MODULES/PartyUI.swiftmodule" \
    -o "$LIBS/libPartyUI.a" \
    "${PARTY_SOURCES[@]}"

xcrun swiftc "${COMMON_SWIFT[@]}" \
    -swift-version 5 \
    -O \
    -emit-library -static \
    -emit-module \
    -module-name ZIPFoundation \
    -emit-module-path "$MODULES/ZIPFoundation.swiftmodule" \
    -o "$LIBS/libZIPFoundation.a" \
    "${ZIP_SOURCES[@]}"

xcrun clang \
    -target "$TARGET" \
    -isysroot "$SDK" \
    -fPIC \
    -I "$MOND/mond/exploit/bad_query" \
    -c "$MOND/mond/exploit/bad_query/bad_query.c" \
    -o "$OBJ/mond_bad_query.o"

xcrun swiftc "${COMMON_SWIFT[@]}" \
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
if otool -L "$OUT" | grep -E '/(PartyUI|ZIPFoundation)'; then
    echo "Mond 2.1 verifier failed: PartyUI/ZIPFoundation must be statically embedded" >&2
    exit 1
fi

# UI text literals may be optimized/coalesced by Swift, so binary string scans
# are not a reliable proof of source inclusion. Verify the compiled Swift types
# instead; stage-mond-2.0.sh separately verifies exact upstream 2.1 source/UI.
nm "$OUT" | xcrun swift-demangle > "$BUILD/Mond2Embedded.symbols"
for symbol in \
    'Mond2Embedded.mond' \
    'Mond2Embedded.ContentView' \
    'Mond2Embedded.SettingsView' \
    'Mond2Embedded.TendiesView' \
    'Mond2Embedded.SantanderView'; do
    if ! grep -Fq "$symbol" "$BUILD/Mond2Embedded.symbols"; then
        echo "Mond 2.1 verifier failed: compiled dylib missing Swift symbol: $symbol" >&2
        exit 1
    fi
    echo "Verified compiled Mond 2.1 Swift symbol: $symbol"
done

# This is an integration-adapter diagnostic and therefore should remain a
# concrete binary string even under optimization.
grep -aFq 'exact upstream mond 2.1 runtime configured commit=500d76082f0ca021ddd591c05d129ebbc26c20df' "$OUT"

# -emit-library intentionally does not export an executable _main entry point.
# The upstream @main source is still compiled unchanged, proven by the
# Mond2Embedded.mond App type above and the clean exact source checkout.
if nm "$OUT" | grep -Eq '[[:space:]]_main$'; then
    echo "Mond 2.1 verifier failed: embedded dylib unexpectedly exports executable _main" >&2
    exit 1
fi

# Compilation is not allowed to mutate the staged upstream repositories.
test -z "$(git -C "$MOND" status --porcelain)"
test -z "$(git -C "$PARTYUI" status --porcelain)"
test -z "$(git -C "$ZIPFOUNDATION" status --porcelain)"

shasum -a 256 "$OUT"
echo "Built isolated exact Mond 2.1 dylib without modifying upstream source"
