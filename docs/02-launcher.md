# 2. A home screen of your own (tvhome)

**English** · [Français](fr/02-launcher.md)

`com.ansub.tvhome` is a minimal Android TV launcher derived from
[Ansub/tv-detox](https://github.com/Ansub/tv-detox) (MIT). The original showed six apps per row
with their banners; this version turns it into a calm screen: three cards, a single bottom bar,
a photo backdrop.

It targets cheap hardware: `minSdk 21`, no image resources, no Gradle, a 1 GB TV runs it.

## What the screen does

- **Three cards per row** (464 × 220 at 1920 × 1080), the app's real icon on the left, its name on
  the right. The icon comes from `PackageManager.getApplicationIcon()` — no banners, nothing
  hand-drawn.
- **Focus**: 2 px `#72A7FF` border, blue halo behind the card, scale 1.025, 160 ms.
- **Bottom bar**: one pill with Home (underlined), HDMI 1, HDMI 2, Play Store, Settings, Add app,
  thin separators. It does not scroll with the apps.
- **Header**: date in full (24 px), 68 px light clock, Wi-Fi and a gear on the right.
- **Backdrop**: a photo bundled in `assets/`, darkened, plus a navy veil that thickens towards the
  bottom. If the asset fails to decode, a gradient takes over — never a black screen.
- **Self-updating row**: an app installed after the row was saved joins it on its own (compared on
  `PackageInfo.firstInstallTime`). A saved row does not move otherwise.

## Geometry (1920 × 1080 design space)

| Element | Value |
|---|---|
| Margin | 92 px |
| Card | 464 × 220, radius 22, gap 18 |
| Grid | heading at 370, cards at 420 |
| Bar | 92 px high, 48 from the bottom, radius 46 |
| Header icons | 30 px, 84 from the right edge |

Everything goes through `px(v) = round(v × screenWidth / 1920)`, so the layout holds on 720p as
well as 1080p.

## Building the APK on Windows (no Gradle)

The project has no Gradle and no Android resources: one manifest, three Java files, some assets.
The chain is direct: `aapt2` → `javac` → `d8` → dex injection → `zipalign` → `apksigner`.

```powershell
powershell -ExecutionPolicy Bypass -File launcher\build.ps1
# -> launcher\out\tvhome.apk
```

Expected variables: `ANDROID_SDK` (build-tools 36.1 + platform android-34) and `JAVA_HOME`
(JDK 21). The defaults in `build.ps1` match a usual Windows install.

Traps met along the way:

- **`d8` from build-tools 34.0.0 crashes** on JDK 21 classes (`NullPointerException … String.length()`
  on `MethodParameters`). Use **36.1**.
- **`javac` 21 rejects `-bootclasspath`**: the script retries with `-classpath` (the `android-34-ext7`
  jar is only a reference).
- **Assets are ignored** without `aapt2 link -A assets`. Without it the APK builds, but the
  backdrop is missing.
- **The SDK's `android.jar` has no `ApplicationInfo.firstInstallTime`** (only `PackageInfo` does):
  hence the small `installedAt()` helper.
- **Signing is a one-way door**: reinstalling over a build signed with another key fails
  (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). `install-tvhome.ps1` therefore uninstalls the old
  launcher — which wipes its preferences, so the row rebuilds from `apps.txt` plus installed apps.

## Installing

```powershell
# install, reset the row, make tvhome the home app
powershell -ExecutionPolicy Bypass -File launcher\install-tvhome.ps1 -Ip <TV_IP>

# or just set the home app
powershell -ExecutionPolicy Bypass -File launcher\set-default-home.ps1 -Ip <TV_IP>
```

`set-default-home.ps1` sets the Android 11 HOME role
(`cmd role add-role-holder android.app.role.HOME`), the older preference
(`cmd package set-home-activity`), then checks with `resolve-activity`.

## Changing the row without reinstalling

```bash
adb shell am start -n com.ansub.tvhome/.MainActivity --es stamp <epoch> --es apps "pkg1,pkg2,pkg3"
adb shell am start -n com.ansub.tvhome/.MainActivity --es stamp <epoch> --es apps auto   # rebuild from installed apps
```

`--es stamp` stops Android from replaying an old intent when it restarts the home screen in the
background.

## The wallpaper

`launcher/assets/wallpaper.jpg` — 1280 × 720, ~63 KB, decoded as RGB_565 (1.8 MB in memory). If
the asset is missing or unreadable, the screen falls back to a gradient.

Credit: "Nautical twilight sunset over Sandy Lake" by Trougnouf, CC BY 4.0,
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Nautical_twilight_sunset_over_Sandy_Lake_(DSCF3005).jpg).
