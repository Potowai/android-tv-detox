# Launcher APKs

**English** · [Français](README.fr.md)

These are the **official, unmodified APKs** published by their authors. Nothing was rebuilt or
repackaged: only the file names were made readable. The SHA-256 digests let you check that a file
did not change.

| File | Package | Version | minSdk | SHA-256 |
|---|---|---|---|---|
| `GlassOS-v1.0.2-beta.apk` | `io.github.abhishekkaisar.glassos` | 1.0.2-beta (3) | 22 | `56272e5495e7ed5e23df55e2b54efc236f342d177d534579a918566099a5895e` |
| `Couchy-Launcher-v1.0.6.apk` | `com.conreo.couchytv` | 1.0.6 (7) | 21 | `9d065bbefada54eaad65e3174e606d03c2f767000efb5ebe6343ea8b6b439c8a` |
| `LTvLauncher-armeabi-v7a-release.apk` | `com.leanbitlab.ltvL` | 2026.10.03 (8112) | 21 | `ec77396eb05acbf22c59b27e121f59073e1da397404d0cd6a26f4f1c5eaa8221` |
| `unitedu-1.2.0.apk` | `com.uniteduone.launcher` | 1.2.0 (41) | 28 | `29d5cf100490065c033b274ce736511398063ac8cdc38d165799f3d0b127f4d7` |

## Provenance and licences

| File | Source | Licence |
|---|---|---|
| `GlassOS-v1.0.2-beta.apk` | [AbhishekKaisar/glassos-tv v1.0.2-beta](https://github.com/AbhishekKaisar/glassos-tv/releases/tag/v1.0.2-beta) | GPL-3.0 |
| `Couchy-Launcher-v1.0.6.apk` | [conreo/couchy-launcher v1.0.6](https://github.com/conreo/couchy-launcher/releases/tag/v1.0.6) | GPL-3.0 |
| `LTvLauncher-armeabi-v7a-release.apk` | [leanbitlab-org/LtvLauncher v2026.10.03](https://github.com/leanbitlab-org/LtvLauncher/releases/tag/v2026.10.03) | GPL-3.0 |
| `unitedu-1.2.0.apk` | [GordonWang1878/UnitedU-launcher v1.2.0](https://github.com/GordonWang1878/UnitedU-launcher/releases/tag/v1.2.0) | Apache-2.0 |

The three GPL-3.0 projects are redistributed as published, with their source available at the
addresses above. No modification was made to the binaries; if you modify one, the GPL asks you to
publish your changes under the same licence.

## The fifth

`zhengnanli/tv-launcher` has no release and declares `minSdkVersion 31`: no APK here, it would
refuse to install on an Android 11 TV. See [`../docs/05-launchers.md`](../docs/05-launchers.md).

## Installing

```bash
adb install -r apks/<file>.apk
adb shell cmd package set-home-activity --user 0 <package>/.<Activity>
```

A launcher holds the HOME role (Android 11): `cmd package resolve-activity --brief -a
android.intent.action.MAIN -c android.intent.category.HOME` tells you which one is in place, and
`adb uninstall <package>` cleanly removes one you no longer want.
