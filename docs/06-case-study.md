# 6. Case study: one TCL C06

**English** · [Français](fr/06-case-study.md)

Numbers and facts from a TV cleaned end to end. It is an example, not a recipe: on another model the
packages differ, but the process and the checks do not.

## The TV

| | |
|---|---|
| Model | TCL C06 (Google TV, Android 11 / API 30) |
| Display | 1280 × 720, French UI |
| RAM | 939 MB (917 MB visible) |
| CPU | armeabi-v7a only (no arm64) |
| Network | 2.4 GHz Wi-Fi, ADB on port 5555 |

## Result

| | |
|---|---|
| Default home app | `com.uniteduone.launcher/.MainActivity` (UnitedU 1.2.0) |
| Previous home app | `com.ansub.tvhome` still installed, inactive (switch back in one command) |
| Disabled packages | 47 |
| Suspended PERSISTENT packages | 2 (`com.tcl.factory.view`, `com.tcl.system.server`) |
| Chromecast | `8009` listening, `mediashell` + `gms` running |
| Free RAM after cleanup | ~356 MB at the first reboot, ~50 MB once UnitedU is loaded |
| Leftover APKs | 0 (storage cleaned) |

## Order of operations

1. **Debloat**, in waves of 7 to 10 packages, checking `pm list packages -d` and port 8009 after
   each wave. The two `PERSISTENT` packages were only suspended.
2. **Home-built launcher** (`com.ansub.tvhome`, a tv-detox fork): three cards, a single bar, a photo
   backdrop — see [`02-launcher.md`](02-launcher.md).
3. **Switch to UnitedU**, closer to the wanted interface, with the household's three apps on the
   first row: see [`04-unitedu.md`](04-unitedu.md).
4. **Network**: the TV lost on the LAN, then the wrong static gateway — see
   [`03-network.md`](03-network.md).

## What went wrong, and why

- **"Connected" but no usable IP.** ARP silent, ping silent, ports closed, mDNS silent. A displayed
  IP is not proof: it can come from a stale lease.
- **The move to a static IP fixed the LAN, then broke the internet.** Gateway typed as
  `192.168.1.1` instead of `192.168.1.254`: ADB and Cast worked, no app could play a video.
- **Wi-Fi drops in standby.** The install scripts wait for the TV to come back
  (`watch-tv.ps1`, `push-when-awake.ps1`) instead of failing.
- **The signing key.** A build signed with another key cannot install over the old one: it has to
  be uninstalled first, which wipes the launcher's preferences (including the saved row).

## Full rollback

```bash
# the stock home app
adb shell cmd package set-home-activity --user 0 com.tcl.tvlauncher/.MainActivity

# the packages
adb shell pm list packages -d | sed 's/package://' | xargs -n1 adb shell pm enable
adb shell pm unsuspend --user 0 com.tcl.factory.view
adb shell pm unsuspend --user 0 com.tcl.system.server
```
