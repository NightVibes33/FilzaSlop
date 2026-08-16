# Mond 2.0 integration provenance

Filza embeds the exact upstream **Mond 2.0** source revision without patching or rewriting Mond source files.

- Repository: `rooootdev/mond`
- Release: `2.0`
- Exact source commit: `87b38b2726160c6d1cfacbbfa834a2572d7ca333`
- Commit message: `mond 2.0` / `bug fixes, new features`
- PartyUI: `830eaac8ebf8a4cbcec08d49e8746033574d1903` (`1.2.0`)
- ZIPFoundation: `22787ffb59de99e5dc1fbfe80b19c97a904ad48d` (`0.9.20`)

The 2.0 tree includes the complete upstream app/tweak implementation, including:

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

## Integration rule

`scripts/stage-mond-2.0.sh` checks out those immutable revisions under `.theos/mond2/` and verifies that every staged repository remains clean. No generated/namespaced Mond copy is produced and no script edits Mond's Swift/C source.

`scripts/build-mond-2.0-embedded.sh` compiles the untouched upstream Mond tree into the isolated `Mond2Embedded.dylib`. The isolation is required because Filza independently carries a different pinned `bad_query` ABI and because Mond 2.0 itself targets iOS 17 while the outer Filza build remains anchored to its existing iOS 16 minimum.

`Mond2EmbeddedHost.swift` is an integration adapter outside the upstream tree. It reproduces the lifecycle from upstream `mond.swift` (startup setup, document-picker swizzle, URL import handling, automatic `grant_all`, unsupported-version warning, and respring overlay) so Mond can run under Filza's already-existing `UIApplication` instead of becoming a second `@main` application.

The outer Filza application identity and version are independent of Mond and remain unchanged: bundle identifier `com.apple.mobile.MobileHouseArrest`, marketing version `4.11`.
