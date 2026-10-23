# Android TV — debloat, home screen and network

**English** · [Français](README.fr.md)

A repeatable way to clean up **any Android TV / Google TV**, give it a minimal home screen, and
keep Chromecast working.

No magic, no miracle APK: rules, verifiable `adb` commands, and the traps met in the field. The
write-up started on a TCL C06 (Android 11); everything model-specific is flagged as such.

## What is in here

| Folder | Contents |
|---|---|
| [`docs/01-debloat.md`](docs/01-debloat.md) | disable without breaking: categories, `PERSISTENT`, undo lists |
| [`docs/02-launcher.md`](docs/02-launcher.md) | a home screen of your own (source, Gradle-free build, install) |
| [`docs/03-network.md`](docs/03-network.md) | TV unreachable, wrong gateway, what Chromecast really needs |
| [`docs/04-unitedu.md`](docs/04-unitedu.md) | take an existing launcher and make it the HOME app |
| [`docs/05-launchers.md`](docs/05-launchers.md) | five open-source launchers compared (licence, minSdk, ABI) |
| [`docs/06-case-study.md`](docs/06-case-study.md) | the full job on a TCL C06, with numbers |
| [`apks/`](apks/) | the official APKs of the launchers compared, with SHA-256 |
| [`debloat/`](debloat/) | scripts to export, disable, and undo |
| [`launcher/`](launcher/) | the launcher: Java, assets, build, install scripts |
| [`PROMPT.md`](PROMPT.md) | a prompt to hand to an agent (OpenCode, Claude Code, Codex…) |

## What it works on

- **Android 9 (API 28) and later** for the modern HOME role (`cmd role add-role-holder`);
  `pm disable-user` has been there for far longer.
- **Google TV and plain Android TV.** **Fire OS** is a different story: `pm` commands work, but the
  home screen cannot be replaced without root.
- Some vendor ROMs **refuse third-party launchers** (TCL/FFALCON depending on the model, recent
  Xiaomi, Skyworth): the debloat method still applies, the home replacement does not.
- Before installing an APK, check `minSdkVersion` and the ABI (`aapt2 dump badging`). Plenty of
  cheap TVs are **armeabi-v7a only** — an arm64 APK simply will not install.

## The method in four steps

1. **Discover and save**: model, SDK, RAM, installed apps, current home app, Cast port 8009, list
   of disabled packages. Anything not written down cannot be undone.
2. **Disable in small waves**, never uninstall, never touch `PERSISTENT` packages, and after every
   wave check that Chromecast and the home screen still answer.
3. **Pick a home screen**: ours, or an open-source one from the comparison; install it through the
   HOME role and verify that the HOME key really lands there.
4. **Diagnose the network** when the TV "has an IP but does not answer": ARP, default route,
   gateway. A displayed IP proves nothing.

## The full job on a TCL C06

47 packages disabled, 2 `PERSISTENT` ones suspended, a home-built launcher then UnitedU as the
home app, and two network failures understood — numbers, commands and screenshots in
[`docs/06-case-study.md`](docs/06-case-study.md).

## The five launchers compared

Four official APKs ready to install and one project that refuses to install on Android 11, with
screenshots, licences and SHA-256 digests: [`docs/05-launchers.md`](docs/05-launchers.md),
binaries in [`apks/`](apks/).

| Launcher | Licence | minSdk | Android 11 |
|---|---|---|---|
| GlassOS | GPL-3.0 | 22 | ✅ |
| Couchy | GPL-3.0 | 21 | ✅ |
| tv-launcher (zhengnanli) | MIT | 31 | ❌ Android 12+ |
| LTvLauncher | GPL-3.0 | 21 | ✅ |
| UnitedU | Apache-2.0 | 28 | ✅ |

### Screenshots

<table>
<tr>
<td align="center"><img src="docs/img/launchers/glass-home.png" width="330"><br><sub><b>GlassOS</b> — frosted glass, app grid on demand</sub></td>
<td align="center"><img src="docs/img/launchers/couchy-dock.png" width="330"><br><sub><b>Couchy</b> — floating dock, three layouts</sub></td>
</tr>
<tr>
<td align="center"><img src="docs/img/launchers/zheng-home.jpg" width="330"><br><sub><b>tv-launcher</b> — four-tile dock (Android 12+)</sub></td>
<td align="center"><img src="docs/img/launchers/ltv-home.png" width="330"><br><sub><b>LTvLauncher</b> — categories and widgets</sub></td>
</tr>
<tr>
<td align="center"><img src="docs/img/launchers/unitedu-real.png" width="330"><br><sub><b>UnitedU</b> — real capture on the test TV</sub></td>
<td align="center"><img src="docs/img/launchers/glass-control.png" width="330"><br><sub>GlassOS, control centre</sub></td>
</tr>
</table>

## Tree

```
apks/       the official APKs of the launchers compared (unmodified)
debloat/    export the package list, disable, undo
launcher/   tvhome source, assets, build and install scripts
docs/       what was done, and why (docs/fr/ holds the French originals)
```

## Quick start

```powershell
# 1. Save the TV's current state
powershell -ExecutionPolicy Bypass -File debloat\export.ps1 -Ip <TV_IP>

# 2. Build the launcher (JDK 21 + build-tools 36.1 + android-34)
powershell -ExecutionPolicy Bypass -File launcher\build.ps1

# 3. Install it and make it the default home app
powershell -ExecutionPolicy Bypass -File launcher\install-tvhome.ps1 -Ip <TV_IP>
```

Every script takes `-Ip`; no real network address is committed here.

## Safety rules applied

- **Disable, never uninstall.** `pm disable-user` is undone by `pm enable`; uninstalling a system
  app cannot be undone without its original APK.
- **Never touch `PERSISTENT` packages** (they restart at boot and disabling them leaves the TV in
  a strange state). The two involved were *suspended* instead, and the flag does not survive a
  reboot — on purpose.
- **Keep an undo list** before any action, and read it back after a reboot.
- **Check Chromecast after every wave**: port `8009` listening, `mediashell` and `gms` alive.

## Redo it with an AI agent

[`PROMPT.md`](PROMPT.md) holds the prompt to paste into OpenCode, Claude Code, Codex or any agent
with shell access: discover the TV, propose a package list and get it approved, disable in waves
with Chromecast checks, install the home screen, then report before/after. Nothing destructive
without consent, nothing claimed without a command.

## Credits

- Original launcher: [Ansub/tv-detox](https://github.com/Ansub/tv-detox), MIT.
  Our fork with the APK: [Potowai/tv-detox](https://github.com/Potowai/tv-detox/releases/latest).
- UnitedU: [GordonWang1878/UnitedU-launcher](https://github.com/GordonWang1878/UnitedU-launcher), Apache-2.0.
- GlassOS, Couchy, LTvLauncher, tv-launcher: see [`apks/README.md`](apks/README.md).
- Wallpaper: "Nautical twilight sunset over Sandy Lake" by **Trougnouf**, CC BY 4.0,
  [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Nautical_twilight_sunset_over_Sandy_Lake_(DSCF3005).jpg).
