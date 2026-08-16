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
MOND_COMMIT="87b38b2726160c6d1cfacbbfa834a2572d7ca333"

bash scripts/stage-mond-2.0.sh
rm -rf "$BUILD"
mkdir -p "$MODULES" "$LIBS" "$OBJ" "$(dirname "$OUT")"

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

# Verify the exact upstream 2.0 behavior at source level before compilation.
# Swift may coalesce UI literals in optimized Mach-O output, so raw-string
# searches of the dylib are not a reliable proof of UI presence.
grep -Fq '@StateObject private var state = AppState()' "$MOND/mond/mond.swift"
grep -Fq 'UserDefaults.standard.register(defaults: ["exploit_method": "bad_query"])' "$MOND/mond/mond.swift"
grep -Fq 'grant_all(state: state)' "$MOND/mond/mond.swift"
grep -Fq 'Text("Explore Tendies")' "$MOND/mond/views/tweaks/posterboard/PosterView.swift"
grep -Fq 'SantanderView()' "$MOND/mond/views/app/ContentView.swift"
grep -Fq 'Text("Run Exploit")' "$MOND/mond/views/app/SettingsView.swift"
grep -Fq 'Text("Generate Token")' "$MOND/mond/views/app/SettingsView.swift"
grep -Fq 'Your sandbox token is invalid.' "$MOND/mond/views/app/SettingsView.swift"
test -z "$(git -C "$MOND" status --porcelain)"

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
if otool -L "$OUT" | grep -E '/(PartyUI|ZIPFoundation)'; then
    echo "Mond 2.0 verifier failed: PartyUI/ZIPFoundation must be statically embedded" >&2
    exit 1
fi

# Prove the exact upstream Swift sources emitted code into the dylib. This is
# stronger than depending on optimizer-sensitive raw UI string layout.
nm "$OUT" | xcrun swift-demangle > "$BUILD/Mond2Embedded.symbols"
for symbol in \
    'Mond2Embedded.mond' \
    'Mond2Embedded.ContentView' \
    'Mond2Embedded.SettingsView' \
    'Mond2Embedded.PosterView' \
    'Mond2Embedded.TendiesView' \
    'Mond2Embedded.SantanderView'; do
    if ! grep -Fq "$symbol" "$BUILD/Mond2Embedded.symbols"; then
        echo "Mond 2.0 verifier failed: compiled dylib missing Swift symbol: $symbol" >&2
        exit 1
    fi
    echo "Verified compiled Mond 2.0 Swift symbol: $symbol"
done

grep -aFq 'exact upstream mond 2.0 runtime configured commit=87b38b2726160c6d1cfacbbfa834a2572d7ca333' "$OUT"

# -emit-library intentionally produces a dylib rather than an executable entry
# point. Upstream mond.swift is still compiled unchanged, proven above by the
# Mond2Embedded.mond symbol and the exact clean source checkout.
if nm "$OUT" | grep -Eq '[[:space:]]_main$'; then
    echo "Mond 2.0 verifier failed: embedded dylib unexpectedly exports executable _main" >&2
    exit 1
fi

for repo in "$MOND" "$PARTYUI" "$ZIPFOUNDATION"; do
    test -z "$(git -C "$repo" status --porcelain)" || {
        echo "Mond 2.0 verifier failed: staged upstream repository became dirty: $repo" >&2
        git -C "$repo" status --short >&2
        exit 1
    }
done

shasum -a 256 "$OUT"
echo "Built isolated exact Mond 2.0 dylib without modifying upstream source"
