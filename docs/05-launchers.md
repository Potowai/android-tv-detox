# 5. Five home screens compared

**English** · [Français](fr/05-launchers.md)

Five open-source launchers, checked with `aapt2 dump badging`: licence, `minSdk`, and what installs
on an **Android 11 (API 30), 1280 × 720, armeabi-v7a** TV. The official, unmodified APKs are in
[`apks/`](../apks/); the screenshots come from their own repositories.

| Launcher | Licence | minSdk | APK here | Android 11 |
|---|---|---|---|---|
| [GlassOS](#glassos) | GPL-3.0 | 22 | `GlassOS-v1.0.2-beta.apk` (0.2 MB) | ✅ |
| [Couchy](#couchy) | GPL-3.0 | 21 | `Couchy-Launcher-v1.0.6.apk` (2.2 MB) | ✅ |
| [tv-launcher (zhengnanli)](#tv-launcher) | MIT | **31** | — (source only) | ❌ Android 12+ |
| [LTvLauncher](#ltvlauncher) | GPL-3.0 | 21 | `LTvLauncher-armeabi-v7a-release.apk` (9.4 MB) | ✅ |
| [UnitedU](#unitedu) | Apache-2.0 | 28 | `unitedu-1.2.0.apk` (13.1 MB) | ✅ |

Switching is one command, no uninstall needed:

```bash
adb install -r apks/Couchy-Launcher-v1.0.6.apk
adb shell cmd package set-home-activity --user 0 <package>/.<Activity>
```

## GlassOS

![GlassOS home screen](img/launchers/glass-home.png)

![GlassOS control centre](img/launchers/glass-control.png)

- **Repo**: [AbhishekKaisar/glassos-tv](https://github.com/AbhishekKaisar/glassos-tv) — GPL-3.0
- **Package**: `io.github.abhishekkaisar.glassos`
- **Idea**: a frosted-glass shelf of favourites, a full app drawer on demand, a control centre, a
  "Top Shelf" of featured content. Very tvOS.
- **On Android 11**: 200 KB, installs and runs (`minSdk` 22, `targetSdk` 28). It is a beta, and the
  old `targetSdk` may become a problem on future Android versions.

## Couchy

![Couchy floating dock](img/launchers/couchy-dock.png)

- **Repo**: [conreo/couchy-launcher](https://github.com/conreo/couchy-launcher) — GPL-3.0
- **Package**: `com.conreo.couchytv`
- **Idea**: one screen, three layouts (carousel, grid, floating glass dock), custom wallpapers,
  clock, network shortcuts. 17 languages, no trackers.
- **On Android 11**: 2.2 MB, `minSdk` 21, `targetSdk` 34 — the most finished of the four that work.

## tv-launcher

![tv-launcher by zhengnanli](img/launchers/zheng-home.jpg)

![tv-launcher quick settings](img/launchers/zheng-quick.jpg)

- **Repo**: [zhengnanli/tv-launcher](https://github.com/zhengnanli/tv-launcher) — MIT
- **Package**: `com.ambient.launcher`
- **Idea**: a small dock of four tiles in a rounded band, a four-column grid, glass selection,
  HDMI / Wi-Fi / settings shortcuts, built for modest hardware.
- **On Android 11**: **no APK here**, on purpose: the manifest declares `minSdkVersion 31`, so
  Android 11 refuses it (`INSTALL_FAILED_OLDER_SDK`). It builds with its own `build.sh` (RecyclerView
  + R8 from Maven) for an Android 12+ TV.

## LTvLauncher

![LTvLauncher home screen](img/launchers/ltv-home.png)

![LTvLauncher grid](img/launchers/ltv-grid.png)

- **Repo**: [leanbitlab-org/LtvLauncher](https://github.com/leanbitlab-org/LtvLauncher) — GPL-3.0
- **Package**: `com.leanbitlab.ltvL`
- **Idea**: categories, widgets (including Wi-Fi data usage), a built-in IPTV player, bright
  selection indicators. The richest of the five.
- **On Android 11**: use the **armeabi-v7a** APK here (the repo also publishes arm64 and
  universal). 9.4 MB, `targetSdk` 35.

## UnitedU

![UnitedU home screen](img/launchers/unitedu-home.jpg)

- **Repo**: [GordonWang1878/UnitedU-launcher](https://github.com/GordonWang1878/UnitedU-launcher) — Apache-2.0
- **Package**: `com.uniteduone.launcher`
- **Idea**: only the apps you choose, in rows of cards; three buttons top-left (Settings, All apps,
  Inputs), the clock top-right; cards 5/6/8 per row.
- **On Android 11**: the one in use. 13.1 MB, `minSdk` 28, PSS ≈ 112 MB — the heaviest of the five
  on a 1 GB TV.

## Takeaways

- **Check `minSdkVersion` and the ABI before installing**: on an older 720p TV, two lines of
  `aapt2 dump badging` save you from an APK that refuses to open.
- **`cmd package set-home-activity`** is enough to switch launchers: none of them needs the others
  uninstalled, and going back is immediate.
- The closest to the "compact cards + bottom bar" mock is **UnitedU**; the lightest and the most
  "glass" is **GlassOS**.
