# 4. Taking an existing launcher (UnitedU)

**English** · [Français](fr/04-unitedu.md)

## Why

The home-built launcher did exactly what was asked, but the wanted layout looked more like
[UnitedU](https://github.com/GordonWang1878/UnitedU-launcher): compact app cards on one row, three
discreet buttons top-left, the clock top-right, a quiet bottom bar. UnitedU is open source
(Apache-2.0), so installing it beats reimplementing it.

The same recipe works for any launcher you pick from [`05-launchers.md`](05-launchers.md).

## What was done

```bash
adb install -r unitedu-1.2.0.apk
# first run: language (English only, plus Chinese), then "Continue" / "Done"

adb shell cmd package set-home-activity --user 0 com.uniteduone.launcher/.MainActivity
adb shell cmd role add-role-holder --user 0 android.app.role.HOME com.uniteduone.launcher
```

Then, in **Edit Home Screen**, three apps were added to the first row.

Checks:

| Test | Result |
|---|---|
| `resolve-activity` for HOME | `com.uniteduone.launcher/.MainActivity`, `isDefault=true` |
| HOME key | lands on UnitedU |
| Chromecast | `8009` listening, `mediashell` + `gms` alive |
| Launcher memory | PSS ≈ 112 MB (≈ 35 MB for tvhome) |

## Things to know

- **No French.** UnitedU is English and Chinese only; the TV itself stays in its own language.
- **It is heavier.** On a 1 GB TV, 112 MB of PSS is not free. If the TV gets slow or Cast starts
  dropping, switching back is immediate:

  ```bash
  adb shell cmd package set-home-activity --user 0 com.ansub.tvhome/.MainActivity
  ```

  Both launchers stay installed: nothing to reinstall to switch.
- **No system app had to be frozen.** UnitedU takes the Android 11 HOME role, so the stock
  launcher does not need to be disabled.
- **Its local Library** (Settings → General → Library) lets you send an APK, a photo or a video
  from a phone, no cable: the server only runs while that page is open, with no password (LAN
  only).

## Anecdote

UnitedU's README lists "TCL / FFALCON" as *won't install* for some Chinese models. On the C06 used
here (Google TV, Android 11), the APK installs and takes the HOME role without trouble.
