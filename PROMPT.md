# Un prompt pour ton agent

Le même travail, refait sur une autre TV par un agent (OpenCode, Claude Code, Codex, Cursor…)
qui a accès au shell et à `adb`.

**Mode d'emploi** : donne-lui le bloc ci-dessous tel quel, en remplaçant `<IP_DE_LA_TV>` et
`<MODÈLE>`. L'agent lit ce dépôt, propose une liste de paquets, la fait valider, puis exécute.
Rien n'est destructif sans accord.

*English: copy the block below into your agent, replace the two placeholders, and it will follow
this repository's method on your TV. The prompt is in French; any coding agent handles it.*

---

## Le prompt

```text
Tu es ingénieur Android TV. Tu travailles sur une vraie TV, par ADB, depuis le PC de
l'utilisateur. Ta référence est le dépôt https://github.com/Potowai/tcl-c06-tv : lis le README
et les fichiers de docs/ avant de commencer. Tu refais le même travail sur ma TV
<MODÈLE>, à l'adresse <IP_DE_LA_TV>, port 5555.

OBJECTIF
Une télé qui ne garde que ce qui sert : les applis de streaming de la maison, Chromecast, et un
écran d'accueil calme sans recommandations ni publicité. Ne rien casser, ne rien perdre.

RÈGLES ABSOLUES
1. Désactiver, jamais désinstaller. `pm disable-user --user 0` s'annule avec `pm enable` ;
   `pm uninstall` d'une app système ne s'annule pas.
2. Avant toute modification, écris une liste de retour lisible : les paquets désactivés, et
   l'accueil par défaut actuel, dans un fichier local ET sur la TV (/data/local/tmp/).
3. Ne touche jamais aux paquets marqués PERSISTENT : ils se relancent au boot et une
   désactivation laisse le système incohérent. Si l'un gêne, `pm suspend` seulement.
4. Ne désactive jamais, sans raison explicite et sans proposition de remplacement :
   com.google.android.gms, com.google.android.apps.mediashell, le TV Input Framework
   (com.android.tv*, com.google.android.tv.inputplayer), le clavier, com.android.settings,
   le launcher actuellement par défaut, ni Play Store si l'utilisateur s'en sert.
5. Chromecast doit continuer à marcher. Après chaque vague : port 8009 en écoute,
   `mediashell` et `gms` vivants, et l'utilisateur confirme que le téléphone voit la TV.
6. Une action destructive (redémarrage, désinstallation, changement d'accueil par défaut)
   demande mon accord d'abord. Explique en une phrase ce que ça change.
7. Journalise chaque commande et son résultat. Si une commande échoue, dis-le, ne contourne pas
   en silence.

ÉTAPE 0 — DÉCOUVRIR (lecture seule)
  adb connect <IP_DE_LA_TV>:5555 ; adb devices
  adb shell getprop ro.product.model / ro.build.version.sdk
  adb shell wm size ; adb shell free -m
  adb shell pm list packages -3 -e
  adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
  adb shell netstat -ltn | grep 8009
  adb shell ps -A | grep -E 'mediashell|gms'
Donne-moi un résumé : modèle, version d'Android, définition, RAM libre, apps tierces, accueil
actuel, état de Chromecast.

ÉTAPE 1 — SAUVEGARDER
  adb shell pm list packages -d   -> /data/local/tmp/disabled-<date>.txt
  adb shell pm list packages -e   -> /data/local/tmp/enabled-<date>.txt
  adb pull des deux fichiers
  Pour chaque paquet candidat : adb shell dumpsys package <pkg> | grep -E 'flags=|pkgFlags='
  -> repère les PERSISTENT, exclus-les de la liste.

ÉTAPE 2 — PROPOSER, PUIS DÉSACTIVER
Dresse un tableau des paquets candidats : nom, ce qu'il fait, risque, conséquence si désactivé.
Attends mon OK. Puis désactive par lots de 5 à 10, et après chaque lot :
  adb shell pm list packages -d        (comparer au compte attendu)
  adb shell netstat -ltn | grep 8009
  adb shell ps -A | grep -E 'mediashell|gms'
  adb shell dumpsys package <pkg> | grep -c 'enabled=true'   (contrôle ponctuel)
Si Chromecast ou un service vital tombe : `pm enable` sur le lot, et signale-le.

ÉTAPE 3 — L'ACCUEIL
Deux options, choisis avec moi :
 a) le launcher de ce dépôt (trois cartes, barre unique, fond photo) : `launcher/` contient le
    source, `build.ps1` (Windows) ou `build.sh` (macOS/Linux), et les scripts d'installation ;
 b) un launcher open source existant : vérifie `aapt2 dump badging` — minSdk <= version
    d'Android de la TV, et une ABI compatible (beaucoup de TV modestes sont armeabi-v7a seules).
Puis :
  adb shell cmd package set-home-activity --user 0 <pkg>/.<Activity>
  adb shell cmd role add-role-holder --user 0 android.app.role.HOME <pkg>
  adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
  adb shell input keyevent 3      (vérifier que HOME y arrive vraiment)

ÉTAPE 4 — SI LA TV EST INJOIGNABLE
Ne conclus pas « le Wi-Fi est cassé ». Mesure, dans cet ordre :
  ping <IP> ; arp -a | grep <MAC>
  scan des ports 5555 / 8009 / 6466 sur le /24
  mDNS (_googlecast._tcp) et SSDP
  adb shell ip route ; adb shell dumpsys connectivity | grep -o '0\.0\.0\.0/0 -> [0-9.]*'
Un appareil qui affiche une IP mais ne répond pas à ARP n'est pas sur le LAN.
Une route par défaut qui pointe ailleurs que la box (192.168.1.1 au lieu de 192.168.1.254)
laisse le LAN fonctionner et coupe tout Internet — c'est un champ « passerelle » faux.

ÉTAPE 5 — VÉRIFIER
Redémarre la TV, puis :
  liste des paquets désactivés identique
  HOME -> l'accueil voulu
  port 8009 en écoute, mediashell + gms vivants
  free -m (RAM libérée)
  une app de streaming se lance et lit une vidéo
  Chromecast depuis le téléphone

ÉTAPE 6 — RENDRE COMPTE
Un tableau avant/après : paquets désactivés, RAM libre, accueil, état de Chromecast. La liste
exacte des paquets touchés, et la commande pour tout annuler. Aucune affirmation que tu n'as pas
vérifiée par une commande : cite la commande et sa sortie.
```

## Notes par agent

| Agent | Astuce |
|---|---|
| OpenCode | ouvre le dépôt dans le dossier de travail, il lira `README.md` et `docs/` seul |
| Claude Code | `claude "suis PROMPT.md de ce dépôt pour ma TV <IP>"` |
| Codex / CLI | même chose : le prompt pointe vers le dépôt, pas besoin de coller les docs |
| Sans accès shell | l'agent ne peut pas piloter la TV ; il peut seulement préparer les commandes à coller |

## Ce que ce prompt ne fait pas

Il ne devine pas ta liste d'apps : l'étape 2 propose, tu valides. Il ne désinstalle rien. Et il
n'invente pas de résultat : chaque affirmation du compte rendu doit venir d'une commande passée
sur la TV.
