# 3. Réseau : la TV a une IP mais ne répond pas

**Français** · [English](../03-network.md)

Deux problèmes différents se sont succédé. Ils se ressemblent — « la télé a une IP mais on ne
l'atteint pas » — mais n'ont pas la même cause.

## Épisode 1 : associée au Wi-Fi, injoignable sur le LAN

Symptômes, mesurés depuis le PC :

| Test | Résultat |
|---|---|
| Ping `192.168.1.20` (l'IP affichée par la télé) | aucune réponse |
| ARP pour la MAC `<MAC de la TV>` | aucune entrée |
| TCP `5555`, `8009`, `6466` sur les 254 adresses | seulement le Fire Stick |
| mDNS (`_googlecast`, `_androidtvremote2`) | silence |
| SSDP `M-SEARCH` | silence |

La télé affichait pourtant « Connecté, signal excellent » et une IP. Mais son adresse n'existait
nulle part sur le réseau : le bail était un souvenir, pas une route. Chromecast ne pouvait donc
pas fonctionner non plus (il est LAN-only).

La sortie a été de fixer une **IP statique** sur la télé, ce qui a immédiatement rendu ADB et
Cast de nouveau joignables.

## Épisode 2 : « Internet est cassé » dans les apps

Une fois l'IP statique posée, ADB et Cast marchaient, mais aucune app ne lisait de vidéo.
La cause était visible en deux commandes :

```bash
adb shell ip route
# 192.168.1.0/24 dev wlan0 …          <- pas de route par défaut, ou une mauvaise

adb shell dumpsys connectivity | grep -o '0\.0\.0\.0/0 -> [0-9.]*'
# 0.0.0.0/0 -> 192.168.1.1            <- la Freebox est 192.168.1.254
```

Le champ **Passerelle** de la configuration statique avait été saisi à `192.168.1.1`
(la valeur par défaut de beaucoup de routeurs) au lieu de `192.168.1.254`. Résultat : la télé
atteignait la box et le LAN — donc ADB, Cast, la découverte locale — mais tout paquet destiné à
Internet partait vers une adresse inexistante.

Les DNS, eux, étaient corrects (`8.8.8.8`, `8.8.4.4`, plus le résolveur IPv6 de la Freebox) :
ce n'était pas un problème de résolution, mais bien de routage.

### Correction

Sur la télé : **Paramètres → Réseau et Internet → [SSID] → Paramètres IP → Statique**

| Champ | Valeur |
|---|---|
| Adresse IP | `192.168.1.50` |
| Masque | `255.255.255.0` |
| **Passerelle** | **`192.168.1.254`** |
| DNS 1 | `192.168.1.254` (ou `1.1.1.1`) |
| DNS 2 | `8.8.4.4` (facultatif) |

Vérification :

```bash
adb shell ip route | grep default        # default via 192.168.1.254 dev wlan0
adb shell ping -c 2 1.1.1.1             # 0% packet loss
adb shell ping -c 2 google.com          # 0% packet loss
```

## Ce qu'il faut retenir

- **Une IP affichée ne prouve rien.** Croiser ARP + ping + ports + mDNS : si l'ARP ne répond pas,
  l'appareil n'est pas sur ce segment, quel que soit ce qu'affiche son écran.
- **Cast ne dépend pas d'Internet** : il vit sur le LAN. Un Cast qui marche avec des apps qui ne
  lisent rien, c'est un routage cassé, pas un problème de compte ou de DRM.
- Un champ **Passerelle** faux est le piège classique d'une IP statique : les apps locales
  continuent de fonctionner, tout le reste meurt silencieusement.
- Sur cette télé, le Wi-Fi **tombe en veille** et l'ADB se déconnecte : les scripts de ce dépôt
  attendent le retour de la télé (`watch-tv.ps1`, `push-when-awake.ps1`) au lieu d'échouer.
