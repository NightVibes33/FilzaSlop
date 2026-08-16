<div align="center">

# Filza 27

### A modern jailed Filza toolbox for current iOS research

Filza file browsing, **3105**, **ByeTunes**, **Mond 2.1**, **WebDAV**, and **SSH** — packaged together in one sideloadable IPA.

[![Build](https://github.com/NightVibes33/Filza-27/actions/workflows/verify-upstream-byetunes-ssh.yml/badge.svg?branch=main)](https://github.com/NightVibes33/Filza-27/actions/workflows/verify-upstream-byetunes-ssh.yml)
[![Release](https://img.shields.io/github/v/release/NightVibes33/Filza-27?display_name=tag&label=release)](https://github.com/NightVibes33/Filza-27/releases/latest)
[![iOS](https://img.shields.io/badge/iOS-18%20%7C%2026%20%7C%2027%20beta%201%E2%80%934-111111?logo=apple&logoColor=white)](#compatibility)
[![Architecture](https://img.shields.io/badge/architecture-arm64-111111)](#build--verification)

<br>

[![Download Filza-27.ipa](https://img.shields.io/badge/Download-Filza--27.ipa-2563eb?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/NightVibes33/Filza-27/releases/latest/download/Filza-27.ipa)

**[Release notes](RELEASE_NOTES.md)** · **[Latest release](https://github.com/NightVibes33/Filza-27/releases/latest)** · **[Builds](https://github.com/NightVibes33/Filza-27/actions)**

</div>

---

> [!IMPORTANT]
> **Filza 27 is not a full jailbreak.** It exposes only files and containers the app can actually access. This project does **not** claim kernel read/write, unrestricted `/`, a root shell, an SPTM bypass, or a writable system volume.

## At a glance

| | |
| --- | --- |
| **File browser** | Filza-based jailed filesystem browser |
| **Apps Manager** | 3105 1.0.1 with container tools and Patch Workspace v2 |
| **Music tools** | ByeTunes with downloads, metadata, backups, and repair tools |
| **Mond** | Full pinned Mond 2.1 integration |
| **MobileGestalt** | Gestalt editor through Mond 2.1 |
| **Remote access** | In-process WebDAV and libssh servers |
| **Release model** | Exact-SHA green build required before public IPA publication |
| **Artifact** | Stable `Filza-27.ipa` filename + SHA-256 checksum |

## Latest update · Mond 2.1

The production tree now embeds the **full pinned Mond 2.1 source surface** instead of the older Filza-specific Mond implementation.

- Full Mond 2.1 navigation and shared `AppState` lifecycle.
- **MobileGestalt**, **PosterBoard / Tendies**, and **HouseArrest / Santander** routes.
- Upstream **Run Exploit** and **Generate Token** flow.
- MobileGestalt CacheExtra / safe-offset fixes retained.
- CMG grant-state fix retained.
- Complete arm64 Mond integration verified as part of the Filza 4.11 IPA build.

<details>
<summary><strong>Mond source provenance</strong></summary>
<br>

Mond is pinned to:

```text
rooootdev/mond@500d76082f0ca021ddd591c05d129ebbc26c20df
```

The exact upstream source is preserved under:

```text
ThirdParty/mond-current/Upstream
```

Embedded source receives only mechanical module/symbol namespacing required to coexist inside Filza. Sandbox SPI ABI forwarding is handled by `MondSandboxSPICompat.c` without rewriting Mond behavior.

</details>

See **[`RELEASE_NOTES.md`](RELEASE_NOTES.md)** for the release changelog automatically included in GitHub Releases.

## Feature status

| Feature | Status |
| --- | :---: |
| Verified release IPA | ✅ |
| Filza file browser | ✅ |
| Apps Manager / 3105 1.0.1 | ✅ |
| `.3105` Patch Workspace v2 | ✅ |
| ByeTunes | ✅ |
| YouTube metadata provider | ✅ |
| Mond 2.1 | ✅ |
| MobileGestalt editor | ✅ |
| PosterBoard / Tendies | ✅ |
| HouseArrest / Santander | ✅ |
| WebDAV server | ✅ |
| SSH server | ✅ |
| Home Screen quick actions | ✅ |
| Full jailbreak / writable system volume | ❌ |

## Install

1. **[Download the latest verified `Filza-27.ipa`](https://github.com/NightVibes33/Filza-27/releases/latest/download/Filza-27.ipa)**.
2. Sideload it using your preferred signing method.
3. Keep the base app identity when your signer allows it:

```text
com.apple.mobile.MobileHouseArrest
```

> [!CAUTION]
> Changing the bundle identifier can break MobileHouseArrest-dependent behavior.

Every public `Filza-27.ipa` release is produced from an **exact-SHA green GitHub Actions build on `main`** and ships with `Filza-27-SHA256.txt` for artifact verification.

## Main tools

<details open>
<summary><strong>Apps Manager · 3105</strong></summary>
<br>

Apps Manager embeds **3105 1.0.1**, pinned to:

```text
NightVibes33/3105@90ab4dd35823d58de10e6b8b78236e0e7e1ad32b
```

It includes application search, icon and disk-size recovery where available, container browsing, per-tab navigation, file preview, create/rename/import/replace/delete operations, ZIP creation/extraction, and Patch Workspace handoff.

The embedded **3105 Patch Workspace v2** supports portable `.3105` projects, schema-v2 workspaces, legacy v1 decoding, bundle-ID targets, directory targets, import/export, backups, receipts, transaction journals, and restore flows.

</details>

<details open>
<summary><strong>Music Library · ByeTunes</strong></summary>
<br>

ByeTunes is embedded directly into Filza 27 and includes library browsing, downloads, queue persistence, backups, restore/repair tools, metadata editing, and multi-source metadata routing.

The current build restores the known-working pre-v2.4 YouTubeKit metadata path as the first free YouTube provider while retaining the current ByeTunes integration. Required JavaScript solver resources are bundled inside the IPA.

</details>

<details open>
<summary><strong>Mond 2.1 · Gestalt Editor</strong></summary>
<br>

Available Mond routes include:

- **MobileGestalt**
- **PosterBoard / Tendies**
- **HouseArrest / Santander**
- **Settings / exploit controls**

Exposed access methods:

```text
bad_query
cmg
```

MobileGestalt cache:

```text
/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist
```

The editor includes newer iOS 27 capability mappings alongside Dynamic Island, Always-On Display, Camera Control, Action Button, Stage Manager, Apple Intelligence eligibility, internal-feature, and related controls.

</details>

<details>
<summary><strong>WebDAV</strong></summary>
<br>

Enable from:

**Preferences → Advanced options → Enable WebDAV server**

| Setting | Value |
| --- | --- |
| Default port | `11111` |
| Runtime | In-process, app-hosted |
| Local Network permission | Required when prompted |

Because the service is app-hosted, iOS may suspend it when Filza 27 is backgrounded.

</details>

<details>
<summary><strong>SSH</strong></summary>
<br>

Open **Preferences → SSH SERVER** to configure the in-process libssh server.

| Setting | Value |
| --- | --- |
| Default port | `2222` |
| Runtime | In-process libssh |
| Filesystem access | Same permissions as Filza 27 itself |

Set a password before enabling public-facing authentication.

</details>

## Compatibility

Filza 27 targets the modern iOS behavior used by its bundled container-access methods, including **iOS 18**, **iOS 26**, and **early iOS 27 builds**.

> [!NOTE]
> For iOS 27, useful `bad_query` behavior is associated with **beta 1–4**. Do not assume the same access on beta 5 or newer. Exact access can vary by device and build, so Filza 27 validates real file/directory access instead of treating a returned handle as automatic success.

## Build & verification

The release path is intentionally strict:

```text
main commit
    ↓
exact-SHA verifier
    ↓
arm64 build + package checks
    ↓
verified IPA artifact
    ↓
SHA-256
    ↓
GitHub Release
```

### Verifier

```text
.github/workflows/verify-upstream-byetunes-ssh.yml
```

It verifies pinned dependencies, stages Mond 2.1 / 3105 / ByeTunes sources and resources, builds the arm64 runtime, packages the anchored Filza base IPA, verifies the package, and uploads the exact artifact.

### Publisher

```text
.github/workflows/publish-green-ipa-release.yml
```

The publisher waits for the verifier at the **same commit SHA**, downloads that exact artifact, validates it, calculates SHA-256, and publishes:

```text
Filza-27.ipa
Filza-27-SHA256.txt
```

The release body comes from [`RELEASE_NOTES.md`](RELEASE_NOTES.md) plus the exact workflow run and commit SHA used for the IPA.

## Runtime logs

```text
Documents/FilzaSlop Logs/
```

| File | Purpose |
| --- | --- |
| `Runtime.log` | Main runtime diagnostics |
| `WebDAVStatus.txt` | WebDAV lifecycle/status |
| `SSHStatus.txt` | SSH lifecycle/status |
| `ByeTunesEmbedStage.txt` | ByeTunes embedding diagnostics |

## Current limitations

- A green Actions build proves compilation, linking, packaging, and artifact verification; it cannot prove every private API behaves identically on every device/build.
- `/System/Library` can be readable while remaining on iOS's signed read-only system volume.
- Access to an App Group or data container does not imply access to the entire filesystem.
- Kernel read/write is not established by this project.
- No full jailbreak, root shell, SPTM bypass, or system-volume remount is claimed.
- WebDAV and SSH are app-hosted services and can be suspended in the background.

## Upstream & credits

<details>
<summary><strong>Projects and contributors</strong></summary>
<br>

Filza 27 combines work from multiple open-source projects. Their upstream licenses and notices remain part of the repository.

- [34306/FilzaJailedDS](https://github.com/34306/FilzaJailedDS)
- [0xjohnnydev/FilzaSlop](https://github.com/0xjohnnydev/FilzaSlop)
- [0xjohnnydev/MobileHouseArrest-PoC](https://github.com/0xjohnnydev/MobileHouseArrest-PoC)
- [forcequitOS/bad_query](https://github.com/forcequitOS/bad_query)
- [rooootdev/mond](https://github.com/rooootdev/mond)
- [YangJiiii/3105](https://github.com/YangJiiii/3105)
- [NightVibes33/3105](https://github.com/NightVibes33/3105)
- [EduAlexxis/ByeTunes](https://github.com/EduAlexxis/ByeTunes)
- [swisspol/GCDWebServer](https://github.com/swisspol/GCDWebServer)
- [libssh](https://www.libssh.org/)
- XPF and ChOma contributors
- CrazyMind90
- `SerStars/nugget-wallpapers`
- mightycooldude12

</details>

---

<div align="center">

### Built for modern iOS filesystem and compatibility research.

Research features should be treated as **measured device/build behavior**, not proof of unrestricted system access.

</div>
