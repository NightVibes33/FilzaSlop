<!-- README design preview only: branch readme-aesthetic-preview -->

<div align="center">

<img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/94.gif" width="108" alt="Animated Gengar" />
&nbsp;&nbsp;&nbsp;
<img src="https://www.gifcen.com/wp-content/uploads/2022/10/gengar-gif.gif" width="150" alt="Animated floating Gengar" />
&nbsp;&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/94.gif" width="108" alt="Animated shiny Gengar" />

# FILZA 27

### `JAILED FILE BROWSER // MODERN iOS RESEARCH TOOLKIT`

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=20&pause=850&color=A855F7&center=true&vCenter=true&width=900&lines=FILZA+%2B+MOND+%2B+3105+%2B+BYETUNES;MODERN+iOS+FILESYSTEM+RESEARCH;EXACT-SHA+GREEN+BUILDS+ONLY;PURPLE+GHOST+MODE+ENABLED" alt="Animated typing intro" />

<br />

[![ENTER](https://img.shields.io/badge/ENTER-FILZA_27-6D28D9?style=for-the-badge&logo=apple&logoColor=white)](#download)
[![VERIFIED IPA](https://img.shields.io/github/actions/workflow/status/NightVibes33/Filza-27/verify-upstream-byetunes-ssh.yml?branch=main&style=for-the-badge&label=VERIFIED%20IPA&logo=githubactions&logoColor=white&color=111111)](https://github.com/NightVibes33/Filza-27/actions/workflows/verify-upstream-byetunes-ssh.yml)
[![LATEST](https://img.shields.io/github/v/release/NightVibes33/Filza-27?display_name=tag&style=for-the-badge&label=LATEST&color=6D28D9)](https://github.com/NightVibes33/Filza-27/releases/latest)

<br />

`iOS 18` · `iOS 26` · `iOS 27 beta 1–4 research` · `arm64` · `sideloadable IPA`

<br />

<img src="https://media3.giphy.com/media/v1.Y2lkPTZjMDliOTUycTIyaTcxbXExbTZ2cDFodXVhZnk4emQwaGlua3ZkOGJqdWNjeWo2eiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/kcKpORRzy95ofrqAEp/giphy.gif" width="520" alt="Animated neon cyberpunk girl" />

<br />

<sub>purple light // terminal glow // ghost energy</sub>

</div>

> [!IMPORTANT]
> **DESIGN PREVIEW BRANCH.** This branch changes the README presentation only. Production remains on `main`.

---

<div align="center">

<img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/94.gif" width="72" alt="Gengar divider" />

### FILE ACCESS WITHOUT THE BORING README

A jailed, sideloadable Filza fork combining the core file browser with app/container management, 3105, ByeTunes, Mond 2.1, WebDAV, SSH, MobileGestalt tooling, and modern iOS filesystem research inside one IPA.

**[DOWNLOAD](#download) · [STACK](#the-stack) · [MOND](#mond-21) · [INSTALL](#install) · [BUILDS](#verified-build-pipeline) · [CREDITS](#credits)**

</div>

---

## Download

<div align="center">

[![DOWNLOAD FILZA 27](https://img.shields.io/badge/DOWNLOAD-Filza--27.ipa-6D28D9?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/NightVibes33/Filza-27/releases/latest/download/Filza-27.ipa)

**Exact-SHA verified build from `main`.**  
Every public release includes `Filza-27.ipa` and `Filza-27-SHA256.txt`.

</div>

> [!CAUTION]
> **Filza 27 is not a full jailbreak.** It does not claim kernel read/write, unrestricted `/`, root shell access, an SPTM bypass, or a writable system volume. It exposes what the running process can actually reach on that device/build.

---

## The stack

| | Component | What it does |
|:--:|---|---|
| 📁 | **Filza 4.11** | Core file browser and filesystem UI |
| 📦 | **3105 1.0.1** | Apps Manager + `.3105` Patch Workspace v2 |
| 🎵 | **ByeTunes** | Music library, downloads, metadata, queues, backups |
| 👁️ | **Mond 2.1** | MobileGestalt, Tendies / PosterBoard, HouseArrest / Santander |
| 🌐 | **WebDAV** | In-process network file server |
| ⌨️ | **SSH** | In-process libssh server |
| ⚡ | **Quick Actions** | Apps Manager, Music Library, Gestalt Editor, Patches |
| ✅ | **Green release gate** | Exact-SHA compile, package, verify, then publish |

```text
FILZA 27
│
├── File Browser
├── Apps Manager ─────────────── 3105
├── Patch Workspace ──────────── .3105 v2
├── Music Library ────────────── ByeTunes
├── Gestalt / PosterBoard ────── Mond 2.1
├── Network Access ───────────── WebDAV + SSH
└── Release Gate ─────────────── exact-SHA green build
```

<div align="center">
<img src="https://www.gifcen.com/wp-content/uploads/2022/10/gengar-gif.gif" width="105" alt="Floating Gengar" />
</div>

---

## Mond 2.1

<details>
<summary><strong>OPEN // Mond integration details</strong></summary>

<br />

The production tree embeds the **full pinned Mond 2.1 functional source surface** instead of the older Filza-specific implementation.

- Pin: `rooootdev/mond@500d76082f0ca021ddd591c05d129ebbc26c20df`
- Full shared `AppState` lifecycle and normal navigation
- MobileGestalt
- PosterBoard / Tendies
- HouseArrest / Santander
- Upstream **Run Exploit** and **Generate Token** flow
- CacheExtra / safe MobileGestalt offset fixes retained
- CMG grant-state fix retained
- Untouched upstream snapshot preserved in `ThirdParty/mond-current/Upstream`
- Generated embedded copy receives only the adapters needed to coexist inside Filza
- Source-completeness gate prevents silent source omissions
- Sandbox SPI ABI forwarding handled through `MondSandboxSPICompat.c`

The MobileGestalt cache used by the editor is:

```text
/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist
```

The editor includes newer iOS 27 capability mappings alongside Dynamic Island, Always-On Display, Camera Control, Action Button, Stage Manager, Apple Intelligence eligibility, internal-feature controls, and related keys.

</details>

---

## 3105 / Apps Manager

<details>
<summary><strong>OPEN // Apps Manager + Patch Workspace</strong></summary>

<br />

Apps Manager embeds **3105 1.0.1**, pinned to:

```text
NightVibes33/3105@90ab4dd35823d58de10e6b8b78236e0e7e1ad32b
```

Included operations cover application search, icon and disk-size recovery where available, container browsing, file preview, create/rename/import/replace/delete actions, ZIP creation/extraction, and Patch Workspace handoff.

The `.3105` Patch Workspace v2 supports portable projects, schema-v2 workspaces, legacy-v1 decoding, bundle-ID targets, directory targets, import/export, backups, receipts, transaction journals, and restore flows.

</details>

---

## ByeTunes

<details>
<summary><strong>OPEN // Music tools</strong></summary>

<br />

ByeTunes is embedded directly into Filza 27 and includes library browsing, downloads, persistent queues, backups, restore/repair tools, metadata editing, and multi-source metadata routing.

The current build restores the known working pre-v2.4 YouTubeKit metadata path as the first free YouTube provider while retaining the current ByeTunes integration. Required JavaScript solver resources are packaged in the IPA.

</details>

---

## Network layer

### WebDAV

Enable WebDAV from:

```text
Preferences → Advanced options → Enable WebDAV server
```

Default port:

```text
11111
```

### SSH

Open:

```text
Preferences → SSH SERVER
```

Default port:

```text
2222
```

Both services inherit the filesystem permissions of the Filza 27 process itself.

---

## Install

1. Download the latest verified [`Filza-27.ipa`](https://github.com/NightVibes33/Filza-27/releases/latest/download/Filza-27.ipa).
2. Sideload it with your preferred signing method.
3. Keep the base app identity when your signer allows it:

```text
com.apple.mobile.MobileHouseArrest
```

Changing that bundle identifier can break MobileHouseArrest-dependent behavior.

---

## Verified build pipeline

<div align="center">

[![BUILD](https://img.shields.io/github/actions/workflow/status/NightVibes33/Filza-27/verify-upstream-byetunes-ssh.yml?branch=main&style=for-the-badge&label=ARM64%20IPA&logo=githubactions&logoColor=white&color=7C3AED)](https://github.com/NightVibes33/Filza-27/actions/workflows/verify-upstream-byetunes-ssh.yml)
[![RELEASE](https://img.shields.io/github/v/release/NightVibes33/Filza-27?display_name=tag&style=for-the-badge&label=RELEASE&color=111111)](https://github.com/NightVibes33/Filza-27/releases/latest)

</div>

```mermaid
flowchart LR
    A[main commit] --> B[pin + source verification]
    B --> C[arm64 compile]
    C --> D[IPA packaging]
    D --> E[artifact verification]
    E --> F[exact-SHA release gate]
    F --> G[Filza-27.ipa]
```

The verifier stages pinned dependencies, validates the Mond functional-source graph, builds the arm64 target, packages the anchored Filza base IPA, validates the finished package, and uploads the artifact. The release workflow then waits for that exact SHA before publishing it.

---

## Logs

Runtime logs live under:

```text
Documents/FilzaSlop Logs/
```

Useful files include:

```text
Runtime.log
WebDAVStatus.txt
SSHStatus.txt
ByeTunesEmbedStage.txt
```

---

## Compatibility

| Target | Status |
|---|---|
| iOS 18 | Research / supported project target |
| iOS 26 | Research / supported project target |
| iOS 27 beta 1–4 | Early-build research target |
| iOS 27 beta 5+ | Do not assume the same access behavior |
| arm64 IPA | Verified by CI |
| Full jailbreak | Not claimed |

---

## Current limitations

- A green Actions build proves compilation, linking, packaging, and artifact verification; it cannot prove every private API behaves identically on every device/build.
- `/System/Library` can be readable while remaining on iOS's signed read-only system volume.
- App Group or data-container access does not imply unrestricted filesystem access.
- Kernel read/write is not established by this project.
- No full jailbreak, root shell, SPTM bypass, or system-volume remount is claimed.
- WebDAV and SSH are app-hosted and can be suspended when iOS backgrounds the app.

---

## Credits

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

---

<div align="center">

<img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/94.gif" width="92" alt="Animated shiny Gengar" />
&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/94.gif" width="92" alt="Animated Gengar" />

### `SEE YOU IN /private/var`

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=16&pause=1000&color=8B5CF6&center=true&vCenter=true&width=760&lines=filesystems+%2F+containers+%2F+gestalt+%2F+patches;built+for+research%2C+not+marketing+slides;ghosts+in+the+filesystem" alt="Animated footer typing" />

<sub>README aesthetic preview // no production changes on main</sub>

</div>
