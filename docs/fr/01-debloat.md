# 1. Débloater une Android TV

**Français** · [English](../01-debloat.md)

## Objectif

L'objectif n'est pas une liste de paquets universelle — elle n'existe pas — mais une méthode :
retirer ce qui ne sert à personne (recommandations, assistants, doubles stores, journaux,
mise en veille publicitaire) sans toucher à ce qui fait fonctionner la télé.

## Règle de base : désactiver, jamais désinstaller

```bash
adb shell pm disable-user --user 0 <paquet>
adb shell pm enable <paquet>          # retour arrière
```

Une app désactivée disparaît de l'interface mais reste sur la télé : elle peut revenir en une
commande. Une app système désinstallée, elle, ne revient que si on retrouve son APK d'origine.

Avant chaque vague, la liste est écrite sur la télé :

```bash
adb shell "pm list packages -d" | sed 's/package://' > /data/local/tmp/disabled.txt
```

Après un redémarrage on relit cette liste et on compare : c'est ce qui a permis de repérer que
`com.tcl.system.server` ne restait pas suspendu (son flag saute au reboot, il est donc listé à part).

## Les paquets PERSISTENT

Deux paquets TCL portent le flag `PERSISTENT` : `com.tcl.factory.view` et `com.tcl.system.server`.
Les désactiver est risqué (le système les relance et peut se retrouver dans un état incohérent),
mais les laisser tourner charge la mémoire pour rien. Ils ont donc été **suspendus** :

```bash
adb shell pm suspend --user 0 <paquet>
adb shell pm unsuspend --user 0 <paquet>
```

Le flag ne survit pas à un redémarrage : après un reboot ils tournent de nouveau. C'est accepté —
ce n'est pas ce qui coûte le plus cher en RAM.

## Ce qui a été gardé, volontairement

| Paquet | Pourquoi |
|---|---|
| `com.google.android.apps.mediashell` | Chromecast |
| `com.google.android.gms` (+ `unstable`) | Chromecast, comptes |
| `com.tcl.guard` | garde-fou TCL, laissé actif |
| `fr.tf1.mytf1` | TF1+ |
| `com.teamsmart.videomanager.tv` | SmartTube |
| `com.nuvio.tv` | Nuvio |
| `com.esaba.downloader` | Downloader (installation d'APK sans PC) |

## Vérifications après chaque vague

1. **Reboot** : `adb reboot`, puis `adb connect` et `pm list packages -d` → le compte doit être le même.
2. **Accueil** : `cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME`
   doit renvoyer l'accueil voulu.
3. **Chromecast** : `netstat -ltn | grep 8009` → en écoute, et `ps -A | grep -E 'mediashell|gms'` → vivants.
4. **RAM** : `free -m`, puis comparaison.

## Nettoyage du stockage

Le dossier `/data/local/tmp` avait accumulé 38 fichiers (APK, captures, listes) : il a été ramené
à une quinzaine, sans aucun APK. Ce qui reste, ce sont les listes de retour et les captures de
diagnostic.

## Reproduire

```powershell
# lit l'état actuel et écrit debloat\disabled.txt + debloat\enabled-third-party.txt
powershell -ExecutionPolicy Bypass -File debloat\export.ps1 -Ip 192.168.1.50

# désactive les paquets listés dans debloat\disabled-candidates.txt
powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip 192.168.1.50 -DryRun
powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip 192.168.1.50

# tout remettre
powershell -ExecutionPolicy Bypass -File debloat\enable.ps1 -Ip 192.168.1.50
```

`disable.ps1` refuse les paquets `PERSISTENT` (il faut passer `-IncludePersistent`) pour éviter
de figer une télé sans le vouloir.
