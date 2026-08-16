#!/usr/bin/env bash
set -euo pipefail

MOND_COMMIT="500d76082f0ca021ddd591c05d129ebbc26c20df"
PARTYUI_COMMIT="830eaac8ebf8a4cbcec08d49e8746033574d1903"
ZIPFOUNDATION_COMMIT="22787ffb59de99e5dc1fbfe80b19c97a904ad48d"

ROOT="${MOND2_STAGE_ROOT:-$PWD/.theos/mond2}"
MOND="$ROOT/mond"
PARTYUI="$ROOT/PartyUI"
ZIPFOUNDATION="$ROOT/ZIPFoundation"

stage_repo() {
    local url="$1" commit="$2" dest="$3"
    rm -rf "$dest"
    git clone --quiet --filter=blob:none "$url" "$dest"
    git -C "$dest" checkout --quiet --detach "$commit"
    test "$(git -C "$dest" rev-parse HEAD)" = "$commit"
    test -z "$(git -C "$dest" status --porcelain)"
}

mkdir -p "$ROOT"
stage_repo https://github.com/rooootdev/mond.git "$MOND_COMMIT" "$MOND"
stage_repo https://github.com/jailbreakdotparty/PartyUI.git "$PARTYUI_COMMIT" "$PARTYUI"
stage_repo https://github.com/weichsel/ZIPFoundation.git "$ZIPFOUNDATION_COMMIT" "$ZIPFOUNDATION"

required_mond=(
    mond/bridging.h
    mond/exploit/bad_query/bad_query.c
    mond/exploit/bad_query/bad_query.h
    mond/exploit/cmg.swift
    mond/exploit/unsbx.swift
    mond/helpers/keepalive.swift
    mond/helpers/mg.swift
    mond/helpers/posterboard/poster.swift
    mond/helpers/posterboard/tendies.swift
    mond/helpers/sbx.swift
    mond/helpers/utils.swift
    mond/mond.swift
    mond/views/app/ContentView.swift
    mond/views/app/LogView.swift
    mond/views/app/SettingsView.swift
    mond/views/tweaks/GestaltView.swift
    mond/views/tweaks/SantanderView.swift
    mond/views/tweaks/posterboard/PosterView.swift
    mond/views/tweaks/posterboard/TendiesView.swift
)
for rel in "${required_mond[@]}"; do
    test -f "$MOND/$rel" || { echo "Mond 2.1 source missing: $rel" >&2; exit 1; }
done

test -d "$PARTYUI/Sources/PartyUI"
test -d "$ZIPFOUNDATION/Sources/ZIPFoundation"

# Upstream's 2.1 release commit intentionally/actually still contains
# MARKETING_VERSION = 2.0 in the Xcode project. Verify it; do not rewrite it.
grep -Fq 'MARKETING_VERSION = 2.0;' "$MOND/mond.xcodeproj/project.pbxproj"
grep -Fq 'PRODUCT_BUNDLE_IDENTIFIER = com.roooot.mond;' "$MOND/mond.xcodeproj/project.pbxproj"
grep -Fq 'Explore Tendies' "$MOND/mond/views/tweaks/posterboard/PosterView.swift"
grep -Fq 'struct TendiesView' "$MOND/mond/views/tweaks/posterboard/TendiesView.swift"
grep -Fq 'struct SantanderView' "$MOND/mond/views/tweaks/SantanderView.swift"
grep -Fq '@StateObject private var state = AppState.shared' "$MOND/mond/mond.swift"
grep -Fq 'UserDefaults.standard.register(defaults: ["method": "bad_query"])' "$MOND/mond/mond.swift"
grep -Fq 'grant_all(state: state)' "$MOND/mond/mond.swift"
grep -Fq 'sandbox_extension_consume(token)' "$MOND/mond/views/app/SettingsView.swift"
grep -Fq 'private static func cache_extra' "$MOND/mond/helpers/mg.swift"
grep -Fq 'cache_data_safe_offset' "$MOND/mond/helpers/mg.swift"
grep -Fq 'state.mg_granted = result >= 0' "$MOND/mond/exploit/unsbx.swift"
grep -Fq 'state.pb_granted = false' "$MOND/mond/exploit/unsbx.swift"
grep -Fq 'static let shared = AppState()' "$MOND/mond/helpers/utils.swift"

# Hard guarantee: Mond, PartyUI, and ZIPFoundation are immutable upstream
# checkouts. Nothing in this integration patches or rewrites their source.
test -z "$(git -C "$MOND" status --porcelain)"
test -z "$(git -C "$PARTYUI" status --porcelain)"
test -z "$(git -C "$ZIPFOUNDATION" status --porcelain)"

cat > "$ROOT/PINNED.txt" <<PINS
mond=$MOND_COMMIT
PartyUI=$PARTYUI_COMMIT
ZIPFoundation=$ZIPFOUNDATION_COMMIT
PINS

printf 'Staged exact upstream Mond 2.1 %s with PartyUI %s and ZIPFoundation %s; source tree unchanged\n' \
    "$MOND_COMMIT" "$PARTYUI_COMMIT" "$ZIPFOUNDATION_COMMIT"
