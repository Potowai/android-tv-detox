# 6. Dossier complet : une TCL C06

**Français** · [English](../06-case-study.md)

Les chiffres et les faits d'une TV nettoyée de bout en bout. C'est un exemple, pas une recette :
sur un autre modèle, les paquets diffèrent, mais la démarche et les vérifications sont les mêmes.

## La télé

| | |
|---|---|
| Modèle | TCL C06 (Google TV, Android 11 / API 30) |
| Écran | 1280 × 720, interface en français |
| RAM | 939 Mo (917 Mo visibles) |
| CPU | armeabi-v7a uniquement (pas d'arm64) |
| Réseau | Wi-Fi 2,4 GHz, ADB sur le port 5555 |

## Résultat

| | |
|---|---|
| Accueil par défaut | `com.uniteduone.launcher/.MainActivity` (UnitedU 1.2.0) |
| Ancien accueil | `com.ansub.tvhome` toujours installé, inactif (retour possible en une commande) |
| Apps désactivées | 47 |
| Apps PERSISTENT suspendues | 2 (`com.tcl.factory.view`, `com.tcl.system.server`) |
| Chromecast | `8009` en écoute, `mediashell` + `gms` actifs |
| RAM libre après nettoyage | ~356 Mo au premier reboot, ~50 Mo une fois UnitedU chargé |
| APK qui traînaient | 0 (stockage nettoyé) |

## Ordre des opérations

1. **Débloat**, par vagues de 7 à 10 paquets, avec `pm list packages -d` et le port 8009 vérifiés
   après chaque vague. Les deux `PERSISTENT` n'ont été que suspendus.
2. **Launcher maison** (`com.ansub.tvhome`, fork de tv-detox) : trois cartes, barre unique, fond
   photo — Voir [`02-launcher.md`](02-launcher.md).
3. **Bascule vers UnitedU**, plus proche de l'interface voulue, avec les trois apps de la maison
   dans la première rangée : voir [`04-unitedu.md`](04-unitedu.md).
4. **Réseau** : la télé perdue sur le LAN puis la passerelle statique fausse — voir
   [`03-network.md`](03-network.md).

## Ce qui a posé problème, et pourquoi

- **La télé « connectée » mais sans IP utilisable.** ARP muet, ping muet, ports fermés, mDNS
  muet. Une IP affichée n'est pas une preuve : elle peut venir d'un bail périmé.
- **Le passage en IP statique a rendu le LAN, puis cassé Internet.** Passerelle saisie en
  `192.168.1.1` au lieu de `192.168.1.254` : ADB et Cast marchaient, aucune app ne lisait de
  vidéo.
- **Le Wi-Fi se coupe en veille.** Les scripts d'installation attendent le retour de la télé
  (`watch-tv.ps1`, `push-when-awake.ps1`) au lieu d'échouer.
- **La clé de signature.** Une build signée autrement ne s'installe pas par-dessus : il faut
  désinstaller, ce qui efface les préférences du launcher (dont la rangée).

## Retour arrière complet

```bash
# l'accueil d'origine
adb shell cmd package set-home-activity --user 0 com.tcl.tvlauncher/.MainActivity

# les paquets
adb shell pm list packages -d | sed 's/package://' | xargs -n1 adb shell pm enable
adb shell pm unsuspend --user 0 com.tcl.factory.view
adb shell pm unsuspend --user 0 com.tcl.system.server
```
