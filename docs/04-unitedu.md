# 4. UnitedU comme accueil final

## Pourquoi

Le launcher maison faisait exactement ce qui était demandé, mais la maquette voulue ressemblait
davantage à [UnitedU](https://github.com/GordonWang1878/UnitedU-launcher) : des cartes d'apps
compactes sur une rangée, trois boutons discrets en haut à gauche, l'heure en haut à droite, une
barre d'accueil discrète. UnitedU étant open source (Apache-2.0), il vaut mieux l'installer que
de recopier son interface.

## Ce qui a été fait

```bash
adb install -r unitedu-1.2.0.apk
# premier démarrage : langue (English — l'app n'existe qu'en anglais et chinois),
# puis deux étapes « Continue » / « Done »

adb shell cmd package set-home-activity --user 0 com.uniteduone.launcher/.MainActivity
adb shell cmd role add-role-holder --user 0 android.app.role.HOME com.uniteduone.launcher
```

Puis, dans **Edit Home Screen**, trois apps ajoutées à la première rangée : TF1+, SmartTube, Nuvio.

Vérifications :

| Test | Résultat |
|---|---|
| `resolve-activity` pour HOME | `com.uniteduone.launcher/.MainActivity`, `isDefault=true` |
| Touche HOME | UnitedU |
| Chromecast | `8009` en écoute, `mediashell` + `gms` actifs |
| RAM du launcher | PSS ≈ 112 Mo (contre ≈ 35 Mo pour tvhome) |

## Ce qu'il faut savoir

- **Pas de français.** UnitedU est en anglais et chinois. L'interface de la télé, elle, reste en
  français (la date suit le système, mais le format dépend de l'app).
- **C'est plus lourd.** Sur une télé à 1 Go de RAM, 112 Mo de PSS n'est pas neutre. Si la télé
  devient lente ou si Cast décroche, revenir à tvhome est immédiat :

  ```bash
  adb shell cmd package set-home-activity --user 0 com.ansub.tvhome/.MainActivity
  ```

  Les deux launchers restent installés : rien n'est à réinstaller pour basculer.
- **Rien de système n'a été désactivé pour ça.** UnitedU passe par le rôle HOME d'Android 11,
  donc pas besoin de geler un launcher constructeur.
- **Sa bibliothèque locale** (Settings → General → Library) permet d'envoyer un APK, une photo
  ou une vidéo depuis un téléphone, sans câble : le serveur ne tourne que tant que la page est
  ouverte, sans mot de passe (réseau local uniquement).

## Détail amusant

Le README de UnitedU classe « TCL / FFALCON » en *won't install* pour certains modèles chinois.
Sur cette C06 (Google TV, Android 11), l'APK s'installe et prend le rôle HOME sans problème.
