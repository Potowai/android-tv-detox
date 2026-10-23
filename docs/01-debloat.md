# 1. Debloating an Android TV

**English** · [Français](fr/01-debloat.md)

## Goal

A TV that keeps only what it is used for: your streaming apps and casting from a phone. Everything
else — recommendations, logging services, assistants, duplicate stores, the vendor tuner, the
ad-served screensaver — disappears from the home screen and the app drawer.

There is no universal package list: vendor builds differ, and so do people's habits. What is
universal is the method below and the checks that go with it.

## The one rule: disable, never uninstall

```bash
adb shell pm disable-user --user 0 <package>
adb shell pm enable <package>          # undo
```

A disabled app disappears from the UI but stays on the TV: one command brings it back. An
uninstalled system app only comes back if its original APK is found again.

Before every wave, write the undo list on the TV:

```bash
adb shell "pm list packages -d" | sed 's/package://' > /data/local/tmp/disabled.txt
```

After a reboot, read it again and compare. That is how you notice a package that did not stay
disabled.

## PERSISTENT packages

Two kinds of packages must not be disabled: those with the `PERSISTENT` flag. The system expects
them to run, restarts them at boot, and may end up in an inconsistent state if they are frozen.
On the TV this repo was written on, they were **suspended** instead:

```bash
adb shell pm suspend --user 0 <package>
adb shell pm unsuspend --user 0 <package>
```

The flag does not survive a reboot: after a restart they run again. That is accepted — they are
not the biggest cost in RAM.

## What was kept, on purpose

| Package | Why |
|---|---|
| `com.google.android.apps.mediashell` | Chromecast |
| `com.google.android.gms` (+ `unstable`) | Chromecast, accounts |
| `com.tcl.guard` | vendor watchdog, left running |
| the streaming apps in use | the point of the TV |

Never disable, without an explicit reason and a replacement: Google Play services, the media
shell, the TV Input Framework (`com.android.tv*`, `com.google.android.tv.inputplayer`), the
keyboard, the Settings app, the home app currently in use, and the Play Store if the owner uses it.

## Checks after every wave

1. **Reboot**: `adb reboot`, reconnect, `pm list packages -d` → same count as before.
2. **Home**: `cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME`
   returns the expected launcher.
3. **Chromecast**: `netstat -ltn | grep 8009` listening, and `ps -A | grep -E 'mediashell|gms'`
   alive.
4. **RAM**: `free -m`, compared before/after.

## Storage cleanup

`/data/local/tmp` had accumulated 38 files (APKs, screenshots, lists) on the test TV; it was
brought down to about fifteen, with zero APKs left. What stays: undo lists and diagnostic
screenshots.

## Reproduce

```powershell
# reads the current state and writes debloat\disabled.txt + debloat\third-party.txt
powershell -ExecutionPolicy Bypass -File debloat\export.ps1 -Ip <TV_IP>

# disables the packages listed in debloat\disabled-candidates.txt
powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip <TV_IP> -DryRun
powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip <TV_IP>

# bring everything back
powershell -ExecutionPolicy Bypass -File debloat\enable.ps1 -Ip <TV_IP>
```

`disable.ps1` refuses `PERSISTENT` packages unless `-IncludePersistent` is passed, so a TV cannot
be frozen by accident.
