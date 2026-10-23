# APK des cinq launchers

Ce sont les **APK officiels, non modifiés**, publiés par leurs auteurs. Rien n'a été recompilé
ni repackagé : seuls les fichiers ont été renommés pour rester lisibles. Les empreintes SHA-256
permettent de vérifier qu'un fichier n'a pas bougé.

| Fichier | Paquet | Version | minSdk | SHA-256 |
|---|---|---|---|---|
| `GlassOS-v1.0.2-beta.apk` | `io.github.abhishekkaisar.glassos` | 1.0.2-beta (code 3) | 22 | `56272e5495e7ed5e23df55e2b54efc236f342d177d534579a918566099a5895e` |
| `Couchy-Launcher-v1.0.6.apk` | `com.conreo.couchytv` | 1.0.6 (code 7) | 21 | `9d065bbefada54eaad65e3174e606d03c2f767000efb5ebe6343ea8b6b439c8a` |
| `LTvLauncher-armeabi-v7a-release.apk` | `com.leanbitlab.ltvL` | 2026.10.03 (code 8112) | 21 | `ec77396eb05acbf22c59b27e121f59073e1da397404d0cd6a26f4f1c5eaa8221` |
| `unitedu-1.2.0.apk` | `com.uniteduone.launcher` | 1.2.0 (code 41) | 28 | `29d5cf100490065c033b274ce736511398063ac8cdc38d165799f3d0b127f4d7` |

## Provenance et licences

| Fichier | Source | Licence |
|---|---|---|
| `GlassOS-v1.0.2-beta.apk` | [AbhishekKaisar/glassos-tv v1.0.2-beta](https://github.com/AbhishekKaisar/glassos-tv/releases/tag/v1.0.2-beta) | GPL-3.0 |
| `Couchy-Launcher-v1.0.6.apk` | [conreo/couchy-launcher v1.0.6](https://github.com/conreo/couchy-launcher/releases/tag/v1.0.6) | GPL-3.0 |
| `LTvLauncher-armeabi-v7a-release.apk` | [leanbitlab-org/LtvLauncher v2026.10.03](https://github.com/leanbitlab-org/LtvLauncher/releases/tag/v2026.10.03) | GPL-3.0 |
| `unitedu-1.2.0.apk` | [GordonWang1878/UnitedU-launcher v1.2.0](https://github.com/GordonWang1878/UnitedU-launcher/releases/tag/v1.2.0) | Apache-2.0 |

Les trois projets GPL-3.0 sont redistribués tels quels, avec leur code source disponible aux
adresses ci-dessus. Aucune modification n'a été apportée aux binaires ; si vous modifiez l'un
d'eux, la GPL vous demande de publier vos modifications sous la même licence.

## Le cinquième

`zhengnanli/tv-launcher` n'a pas de release et déclare `minSdkVersion 31` : aucun APK ici, il
refuserait de s'installer sur une télé Android 11. Voir [`../docs/05-launchers.md`](../docs/05-launchers.md).

## Installer

```bash
adb install -r apks/<fichier>.apk
adb shell cmd package set-home-activity --user 0 <paquet>/.<Activity>
```

Un launcher occupe le rôle HOME (Android 11) : `cmd package resolve-activity --brief -a
android.intent.action.MAIN -c android.intent.category.HOME` dit lequel est en place, et
`adb uninstall <paquet>` retire proprement celui qu'on ne veut plus.
