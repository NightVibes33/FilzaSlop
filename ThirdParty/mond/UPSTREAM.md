# Mond 2.1 integration provenance

Filza embeds the exact upstream **Mond 2.1** source revision without patching or rewriting Mond source files.

- Repository: `rooootdev/mond`
- Release/tag: `2.1`
- Exact source commit: `500d76082f0ca021ddd591c05d129ebbc26c20df`
- Commit message: `fix tweaks not applying`
- PartyUI: `830eaac8ebf8a4cbcec08d49e8746033574d1903` (`1.2.0`)
- ZIPFoundation: `22787ffb59de99e5dc1fbfe80b19c97a904ad48d` (`0.9.20`)

Upstream's 2.1 commit still contains `MARKETING_VERSION = 2.0` in `mond.xcodeproj`. This integration deliberately leaves that upstream project metadata untouched; the immutable 2.1 tag/commit above is the release identity.

The 2.1 tree includes the complete upstream app/tweak implementation, including:

- `mond/mond.swift`
- `mond/exploit/cmg.swift`
- `mond/exploit/unsbx.swift`
- `mond/exploit/bad_query/*`
- `mond/helpers/mg.swift`
- `mond/helpers/posterboard/poster.swift`
- `mond/helpers/posterboard/tendies.swift`
- `mond/helpers/sbx.swift`
- `mond/views/app/*`
- `mond/views/tweaks/GestaltView.swift`
- `mond/views/tweaks/SantanderView.swift`
- `mond/views/tweaks/posterboard/PosterView.swift`
- `mond/views/tweaks/posterboard/TendiesView.swift`

Mond 2.1's upstream fixes are present unchanged, including its shared `AppState`, `method = bad_query` default, corrected CMG grant-state tracking, `CacheExtra` MobileGestalt writes, and safe cache-offset handling.

## Integration rule

`scripts/stage-mond-2.0.sh` is a legacy-named integration script that now checks out the immutable Mond **2.1** revision under `.theos/mond2/` and verifies that every staged repository remains clean. No generated/namespaced Mond copy is produced and no script edits Mond's Swift/C source.

`scripts/build-mond-2.0-embedded.sh` is likewise legacy-named; it compiles the untouched upstream Mond 2.1 tree into the isolated `Mond2Embedded.dylib`. Isolation prevents symbol/ABI collisions with Filza's independently pinned components and allows upstream Mond's iOS 17 target while the outer Filza build remains anchored to its existing iOS 16 minimum.

`Mond2EmbeddedHost.swift` is an integration adapter outside the upstream tree. It reproduces the lifecycle from upstream 2.1 `mond.swift`: stdout setup, the `method = bad_query` default, Keep Alive startup, document-picker swizzle, URL import handling, shared `AppState`, automatic `grant_all`, unsupported-version warning, and respring overlay. It does not modify upstream Mond UI or feature source.

The outer Filza application identity and version remain independent of Mond and unchanged: bundle identifier `com.apple.mobile.MobileHouseArrest`, marketing version `4.11`.
