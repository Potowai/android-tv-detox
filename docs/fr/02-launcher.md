# 2. Un écran d'accueil maison (tvhome)

**Français** · [English](../02-launcher.md)

`com.ansub.tvhome` est un launcher Android TV minimal, dérivé de
[Ansub/tv-detox](https://github.com/Ansub/tv-detox) (MIT). Le code d'origine affichait six apps
par ligne avec leurs bannières ; la version de ce dépôt en fait un écran calme : trois cartes,
une barre unique en bas, un fond photo.

## Ce que fait l'écran

- **Trois cartes par ligne** (464 × 220 en 1920 × 1080), icône réelle de l'app à gauche, nom à droite.
  L'icône vient de `PackageManager.getApplicationIcon()` — aucune bannière, aucun visuel dessiné.
- **Focus** : bordure 2 px `#72A7FF`, halo bleu derrière la carte, échelle 1.025, 160 ms.
- **Barre du bas** : une seule pilule avec Accueil (souligné), HDMI 1, HDMI 2, Play Store,
  Paramètres, Ajouter une app, séparateurs fins. Elle ne défile pas avec les apps.
- **En-tête** : date en toutes lettres (24 px), horloge 68 px en light, Wi-Fi et engrenage à droite.
- **Fond** : photo embarquée dans `assets/`, assombrie, plus un voile marine qui s'épaissit vers le bas.
- **Rangée qui se met à jour** : quand une app est installée après l'enregistrement de la rangée,
  elle rejoint l'accueil (comparaison sur `PackageInfo.firstInstallTime`). Une rangée enregistrée
  ne bouge pas autrement.

## Géométrie (espace de conception 1920 × 1080)

| Élément | Valeur |
|---|---|
| Marge | 92 px |
| Carte | 464 × 220, rayon 22, écart 18 |
| Grille | titre à 370, cartes à 420 |
| Barre | hauteur 92, à 48 du bas, rayon 46 |
| Icônes d'en-tête | 30 px, à 84 du bord droit |

Tout passe par `px(v) = round(v × largeurÉcran / 1920)`, donc la mise en page tient sur du 720p
comme sur du 1080p.

## Construire l'APK sous Windows (sans Gradle)

Le projet n'a ni Gradle ni ressources Android : un manifeste, trois fichiers Java, des assets.
La chaîne est donc directe : `aapt2` → `javac` → `d8` → injection du dex → `zipalign` → `apksigner`.

```powershell
powershell -ExecutionPolicy Bypass -File launcher\build.ps1
# -> launcher\out\tvhome.apk
```

Variables attendues : `ANDROID_SDK` (build-tools 36.1 + platform android-34) et `JAVA_HOME`
(JDK 21). Les chemins par défaut de `build.ps1` sont ceux d'une installation Windows classique.

Pièges rencontrés :

- **`d8` de build-tools 34.0.0 plante** avec les classes du JDK 21
  (`NullPointerException … String.length()` sur `MethodParameters`). build-tools **36.1** corrige ça.
- **`javac` 21 refuse `-bootclasspath`** : le script réessaie avec `-classpath` (le jar
  `android-34-ext7` sert de référence).
- **Les assets ne sont pas pris en compte** sans `aapt2 link -A assets`. Sans ça, l'APK se construit
  mais la photo de fond manque.
- **L'`android.jar` du SDK ne contient pas `ApplicationInfo.firstInstallTime`** (seul `PackageInfo`
  l'a) : d'où la petite fonction `installedAt()`.
- **La signature change tout** : réinstaller par-dessus une build signée avec une autre clé échoue
  (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). `install-tvhome.ps1` désinstalle donc l'ancien launcher —
  ce qui efface ses préférences, et la rangée se reconstruit depuis `Apps.LIST` + les apps installées.

## Installer

```powershell
# installe, remet la rangée à zéro et fait de tvhome l'accueil
powershell -ExecutionPolicy Bypass -File launcher\install-tvhome.ps1 -Ip 192.168.1.50

# ou seulement remettre l'accueil par défaut
powershell -ExecutionPolicy Bypass -File launcher\set-default-home.ps1 -Ip 192.168.1.50
```

`set-default-home.ps1` pose le rôle HOME d'Android 11
(`cmd role add-role-holder android.app.role.HOME`), l'ancienne préférence
(`cmd package set-home-activity`) puis vérifie avec `resolve-activity`.

## Changer la rangée sans réinstaller

```bash
adb shell am start -n com.ansub.tvhome/.MainActivity --es stamp <epoch> --es apps "fr.tf1.mytf1,com.teamsmart.videomanager.tv,com.nuvio.tv"
adb shell am start -n com.ansub.tvhome/.MainActivity --es stamp <epoch> --es apps auto   # repartir des apps installées
```

`--es stamp` empêche Android de rejouer un vieil intent quand il relance l'accueil en arrière-plan.

## La photo de fond

`launcher/assets/wallpaper.jpg` — 1280 × 720, ~63 Ko, décodée en RGB_565 (1,8 Mo en mémoire).
Si l'asset est absent ou illisible, l'écran retombe sur un dégradé : pas d'écran noir.

Crédit : « Nautical twilight sunset over Sandy Lake » par Trougnouf, CC BY 4.0,
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Nautical_twilight_sunset_over_Sandy_Lake_(DSCF3005).jpg).
