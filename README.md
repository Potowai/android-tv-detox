# TCL C06 — débloat, écran d'accueil et réseau

Tout ce qui a été fait sur une **TCL C06** sous Google TV (Android 11), pour en faire une
télé propre : plus d'apps inutiles, un écran d'accueil qui montre seulement TF1+, SmartTube et
Nuvio, et Chromecast qui continue de fonctionner.

Ce dépôt n'est pas un produit : c'est le dossier de la manip, avec le code, les scripts et les
pièges rencontrés.

## La télé

| | |
|---|---|
| Modèle | TCL C06 (Google TV, Android 11 / API 30) |
| Écran | 1280 × 720, interface en français |
| RAM | 939 Mo (917 Mo visibles) |
| CPU | armeabi-v7a uniquement (pas d'arm64) |
| Réseau | Wi-Fi 2,4 GHz, ADB sur le port 5555 |

## Les trois chantiers

1. **Débloat** — 47 paquets désactivés (jamais désinstallés) et 2 apps PERSISTENT suspendues.
   Chromecast, TF1+, SmartTube et l'accueil sont restés intacts. Voir [`docs/01-debloat.md`](docs/01-debloat.md).
2. **Écran d'accueil** — un launcher maison, `com.ansub.tvhome`, dérivé de
   [Ansub/tv-detox](https://github.com/Ansub/tv-detox) : trois cartes d'apps, une barre unique en bas,
   un fond photo, et une rangée qui se met à jour toute seule quand une app est installée.
   Le fork avec les sources et l'APK : [Potowai/tv-detox](https://github.com/Potowai/tv-detox/releases/latest).
   Voir [`docs/02-launcher.md`](docs/02-launcher.md).
3. **Réseau** — la télé qui disparaît du LAN, l'IP statique, la passerelle au mauvais endroit, et
   Chromecast qui n'était pas en cause. Voir [`docs/03-network.md`](docs/03-network.md).

Ensuite, l'accueil par défaut est passé à **[UnitedU](https://github.com/GordonWang1878/UnitedU-launcher)**
(open source, Apache-2.0), qui ressemble plus à ce qui était voulu. Voir [`docs/04-unitedu.md`](docs/04-unitedu.md).

## Les cinq launchers comparés

Quatre APK officiels prêts à installer et un projet qui refuse de s'installer sur Android 11, avec
captures, licences et empreintes SHA-256 : [`docs/05-launchers.md`](docs/05-launchers.md),
binaires dans [`apks/`](apks/).

| Launcher | Licence | minSdk | Sur la C06 |
|---|---|---|---|
| GlassOS | GPL-3.0 | 22 | ✅ |
| Couchy | GPL-3.0 | 21 | ✅ |
| tv-launcher (zhengnanli) | MIT | 31 | ❌ Android 12+ |
| LTvLauncher | GPL-3.0 | 21 | ✅ |
| UnitedU | Apache-2.0 | 28 | ✅ installé |

## État final

| | |
|---|---|
| Accueil par défaut | `com.uniteduone.launcher/.MainActivity` (UnitedU 1.2.0) |
| Ancien accueil | `com.ansub.tvhome` toujours installé, inactif (retour possible en une commande) |
| Apps désactivées | 47 |
| Apps PERSISTENT suspendues | 2 (`com.tcl.factory.view`, `com.tcl.system.server`) |
| Chromecast | `8009` en écoute, `mediashell` + `gms` actifs |
| APK qui traînaient | 0 (stockage nettoyé) |

## Arborescence

```
apks/       les APK officiels des launchers comparés (non modifiés)
debloat/    export de la liste, désactivation et retour arrière
launcher/   source du launcher tvhome, ressources, build et scripts d'installation
docs/       ce qui a été fait, et pourquoi
```

## Démarrage rapide

```powershell
# 1. Sauver l'état actuel de la télé
powershell -ExecutionPolicy Bypass -File debloat\export.ps1 -Ip 192.168.1.50

# 2. Construire le launcher (JDK 21 + build-tools 36.1 + android-34)
powershell -ExecutionPolicy Bypass -File launcher\build.ps1

# 3. L'installer et en faire l'accueil par défaut
powershell -ExecutionPolicy Bypass -File launcher\install-tvhome.ps1 -Ip 192.168.1.50
```

Remplace `192.168.1.50` par l'adresse de ta télé. Tous les scripts prennent `-Ip` ; les adresses
du réseau d'origine ne sont pas dans ce dépôt.

## Règles de sécurité appliquées

- **Désactiver, jamais désinstaller.** `pm disable-user` se défait avec `pm enable` ; une
  désinstallation d'app système ne se défait pas sans l'APK d'origine.
- **Jamais toucher aux paquets `PERSISTENT`** (ils se relancent au boot et une désactivation
  laisse la télé dans un état bizarre). Les deux concernés ont été *suspendus*, pas désactivés,
  et le flag ne survit pas à un redémarrage — c'est volontaire.
- **Garder une liste de retour** (`/data/local/tmp/tvhome-disabled.txt`) avant toute action,
  et la relire après un reboot pour vérifier qu'elle est complète.
- **Vérifier Chromecast après chaque vague** : port `8009` en écoute, `mediashell` et `gms` vivants.

## Crédits

- Launcher d'origine : [Ansub/tv-detox](https://github.com/Ansub/tv-detox), MIT.
- UnitedU : [GordonWang1878/UnitedU-launcher](https://github.com/GordonWang1878/UnitedU-launcher), Apache-2.0.
- Fond d'écran : « Nautical twilight sunset over Sandy Lake » par **Trougnouf**, CC BY 4.0,
  [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Nautical_twilight_sunset_over_Sandy_Lake_(DSCF3005).jpg).
