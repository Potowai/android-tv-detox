# 3. Network: the TV has an IP but does not answer

**English** · [Français](fr/03-network.md)

Two different failures looked alike: "the TV shows an IP, but nothing reaches it". They do not
have the same cause, so diagnose them in this order.

## Episode 1: joined to Wi-Fi, unreachable on the LAN

Measured from the PC:

| Test | Result |
|---|---|
| Ping `192.168.1.20` (the IP the TV displayed) | no answer |
| ARP for the TV's MAC | no entry |
| TCP `5555`, `8009`, `6466` across all 254 addresses | only the Fire Stick |
| mDNS (`_googlecast`, `_androidtvremote2`) | silence |
| SSDP `M-SEARCH` | silence |

The TV still showed "Connected, excellent signal" and an IP. But its address existed nowhere on
the network: the lease was a memory, not a route. Chromecast could not work either (it is LAN
only).

The way out was a **static IP** on the TV, which immediately made ADB and Cast reachable again.
If you have to do the same, write down the address: everything after that depends on it.

## Episode 2: "the internet is broken" in every app

With the static IP in place, ADB and Cast worked, but no app could play anything. Two commands
were enough to see why:

```bash
adb shell ip route
# 192.168.1.0/24 dev wlan0 …          <- no default route, or a wrong one

adb shell dumpsys connectivity | grep -o '0\.0\.0\.0/0 -> [0-9.]*'
# 0.0.0.0/0 -> 192.168.1.1            <- the router is 192.168.1.254
```

The **gateway** field of the static configuration had been filled with `192.168.1.1` (the default
of many routers) instead of `192.168.1.254`. The TV could reach the router and the LAN — hence
ADB, Cast and local discovery — but every packet bound for the internet went to a non-existent
address.

DNS was fine (`8.8.8.8`, `8.8.4.4`, plus the router's IPv6 resolver): this was routing, not
resolution.

### Fix

On the TV: **Settings → Network & Internet → [SSID] → IP settings → Static**

| Field | Value |
|---|---|
| IP address | your reserved address |
| Subnet mask | `255.255.255.0` |
| **Gateway** | **`192.168.1.254`** (your router) |
| DNS 1 | `192.168.1.254`, or `1.1.1.1` |
| DNS 2 | `8.8.4.4` (optional) |

Verify:

```bash
adb shell ip route | grep default        # default via 192.168.1.254 dev wlan0
adb shell ping -c 2 1.1.1.1             # 0% packet loss
adb shell ping -c 2 google.com          # 0% packet loss
```

## What to remember

- **A displayed IP proves nothing.** Cross-check ARP + ping + ports + mDNS: if ARP does not
  answer, the device is not on that segment, whatever its screen says.
- **Cast does not need the internet**: it lives on the LAN. Cast working while apps cannot play
  anything means broken routing, not an account or DRM problem.
- A wrong **gateway** is the classic static-IP trap: local apps keep working, everything else dies
  silently.
- On the test TV the Wi-Fi **drops in standby** and ADB disconnects: the scripts here wait for the
  TV to come back (`watch-tv.ps1`, `push-when-awake.ps1`) instead of failing.
