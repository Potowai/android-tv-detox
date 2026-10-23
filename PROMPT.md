# A prompt for your agent

**English** · [Français](PROMPT.fr.md)

The same job, redone on another TV by an agent (OpenCode, Claude Code, Codex, Cursor…) with shell
and `adb` access.

**How to use it**: paste the block below, replacing `<TV_IP>` and `<MODEL>`. The agent reads this
repository, proposes a package list, gets it approved, then executes. Nothing destructive without
consent.

---

## The prompt

```text
You are an Android TV engineer. You work on a real TV, over ADB, from the user's PC. Your reference
is the repository https://github.com/Potowai/android-tv-detox : read the README and the files under
docs/ before starting. You are doing the same work on my TV <MODEL>, at <TV_IP>, port 5555.

GOAL
A TV that keeps only what it is used for: the household's streaming apps, Chromecast, and a calm
home screen with no recommendations or ads. Break nothing, lose nothing.

HARD RULES
1. Disable, never uninstall. `pm disable-user --user 0` is undone by `pm enable`; uninstalling a
   system app cannot be undone.
2. Before any change, write a readable undo list: disabled packages and the current default home
   app, both locally and on the TV (/data/local/tmp/).
3. Never touch packages flagged PERSISTENT: they restart at boot and disabling them leaves the
   system inconsistent. If one is a problem, `pm suspend` it only.
4. Never disable, without an explicit reason and a replacement proposal: com.google.android.gms,
   com.google.android.apps.mediashell, the TV Input Framework (com.android.tv*,
   com.google.android.tv.inputplayer), the keyboard, com.android.settings, the launcher currently
   in use, or the Play Store if the user relies on it.
5. Chromecast must keep working. After each wave: port 8009 listening, mediashell and gms alive,
   and the user confirms the phone can see the TV.
6. A destructive action (reboot, uninstall, changing the default home app) needs my approval first.
   Explain in one sentence what it changes.
7. Log every command and its result. If a command fails, say so; never work around it silently.

STEP 0 — DISCOVER (read-only)
  adb connect <TV_IP>:5555 ; adb devices
  adb shell getprop ro.product.model / ro.build.version.sdk
  adb shell wm size ; adb shell free -m
  adb shell pm list packages -3 -e
  adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
  adb shell netstat -ltn | grep 8009
  adb shell ps -A | grep -E 'mediashell|gms'
Give me a summary: model, Android version, resolution, free RAM, third-party apps, current home
app, Chromecast state.

STEP 1 — SAVE
  adb shell pm list packages -d   -> /data/local/tmp/disabled-<date>.txt
  adb shell pm list packages -e   -> /data/local/tmp/enabled-<date>.txt
  adb pull both files
  For each candidate: adb shell dumpsys package <pkg> | grep -E 'flags=|pkgFlags='
  -> spot the PERSISTENT ones and leave them out of the list.

STEP 2 — PROPOSE, THEN DISABLE
Build a table of candidate packages: name, what it does, risk, consequence if disabled. Wait for my
OK. Then disable in batches of 5 to 10, and after each batch:
  adb shell pm list packages -d        (compare with the expected count)
  adb shell netstat -ltn | grep 8009
  adb shell ps -A | grep -E 'mediashell|gms'
  adb shell dumpsys package <pkg> | grep -c 'enabled=true'   (spot check)
If Chromecast or a vital service falls over: `pm enable` the batch and report it.

STEP 3 — THE HOME SCREEN
Two options, pick with me:
 a) the launcher in this repository (three cards, single bar, photo backdrop): `launcher/` holds the
    source, `build.ps1` (Windows) or `build.sh` (macOS/Linux), and the install scripts;
 b) an existing open-source launcher: check `aapt2 dump badging` — minSdk <= the TV's Android
    version, and a compatible ABI (many cheap TVs are armeabi-v7a only).
Then:
  adb shell cmd package set-home-activity --user 0 <pkg>/.<Activity>
  adb shell cmd role add-role-holder --user 0 android.app.role.HOME <pkg>
  adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
  adb shell input keyevent 3      (verify HOME really lands there)

STEP 4 — IF THE TV IS UNREACHABLE
Do not conclude "the Wi-Fi is broken". Measure, in this order:
  ping <IP> ; arp -a | grep <MAC>
  scan ports 5555 / 8009 / 6466 across the /24
  mDNS (_googlecast._tcp) and SSDP
  adb shell ip route ; adb shell dumpsys connectivity | grep -o '0\.0\.0\.0/0 -> [0-9.]*'
A device that shows an IP but does not answer ARP is not on the LAN.
A default route pointing somewhere other than the router (192.168.1.1 instead of 192.168.1.254)
keeps the LAN working and kills the internet — a wrong "gateway" field.

STEP 5 — VERIFY
Reboot the TV, then:
  the disabled package list is identical
  HOME -> the wanted launcher
  port 8009 listening, mediashell + gms alive
  free -m (RAM freed)
  a streaming app starts and plays a video
  Chromecast from the phone

STEP 6 — REPORT
A before/after table: disabled packages, free RAM, home app, Chromecast state. The exact list of
packages touched, and the command to undo everything. No claim you did not verify with a command:
quote the command and its output.
```

## Per-agent notes

| Agent | Tip |
|---|---|
| OpenCode | open the repository as the working directory, it will read `README.md` and `docs/` |
| Claude Code | `claude "follow PROMPT.md from this repo for my TV <IP>"` |
| Codex / CLI | same: the prompt points at the repo, no need to paste the docs |
| No shell access | the agent cannot drive the TV; it can only prepare commands for you to paste |

## What this prompt does not do

It does not guess your app list: step 2 proposes, you approve. It uninstalls nothing. And it
invents no results: every claim in the report must come from a command run on the TV.
