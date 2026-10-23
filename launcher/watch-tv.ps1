# Waits for the TV to come back on the LAN, then installs the current build, makes it the
# default home app and takes a screenshot - no further input needed.
#
#   powershell -ExecutionPolicy Bypass -File watch-tv.ps1
#   powershell -ExecutionPolicy Bypass -File watch-tv.ps1 -Hours 48 -Interval 15
#
# The TV is not on this LAN at all right now (no ARP, no IPv6 neighbour), so this polls:
# .13 first, then any host that answers on 5555, and it looks for the TCL MAC in the ARP
# table so it can say "found, but ADB is off" instead of staying silent.
param(
    [int]$Hours = 24,
    [int]$Interval = 20
)
$ErrorActionPreference = 'Stop'
$adb = 'adb'
$root = $PSScriptRoot
$out = Join-Path $root 'out'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Force -Path $out | Out-Null }
$log = Join-Path $out 'watch-tv.log'
$MAC = '38-e7-c0-b2-c1-ff'
$seen = @{}

function Log($m) {
    $line = "{0}  {1}" -f (Get-Date -Format 'dd/MM HH:mm:ss'), $m
    Add-Content -Path $log -Value $line
    Write-Host $line
}

function Adb {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Argv)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { (& $adb @Argv 2>&1) } finally { $ErrorActionPreference = $prev }
}

function Port5555 {
    param([string]$Ip, [int]$Timeout = 1200)
    $c = New-Object System.Net.Sockets.TcpClient
    try { return ($c.ConnectAsync($Ip, 5555).Wait($Timeout) -and $c.Connected) }
    catch { return $false }
    finally { $c.Close() }
}

function Sweep5555 {
    $wait = @{}
    foreach ($n in 1..254) {
        $c = New-Object System.Net.Sockets.TcpClient
        try { $c.BeginConnect("192.168.1.$n", 5555, $null, $null) | Out-Null } catch {}
        $wait["192.168.1.$n"] = $c
    }
    $deadline = (Get-Date).AddSeconds(5)
    $open = @()
    while ((Get-Date) -lt $deadline) {
        foreach ($k in @($wait.Keys)) {
            if ($wait[$k].Connected) { $open += $k; $wait.Remove($k) }
        }
        if ($wait.Count -eq 0) { break }
        Start-Sleep -Milliseconds 100
    }
    foreach ($k in $wait.Keys) { $wait[$k].Close() }
    return $open
}

# --- wait -------------------------------------------------------------------
Log "watching for the TV (mac $MAC) for $Hours h, every $Interval s"
$end = (Get-Date).AddHours($Hours)
$n = 0
while ((Get-Date) -lt $end) {
    $n++

    # The TCL MAC shows up in ARP as soon as the TV is on this LAN, whether or not ADB answers.
    $arpLine = (arp -a | Select-String $MAC)
    if ($arpLine -and -not $seen['arp']) {
        Log "TCL MAC is on the LAN: $($arpLine.Line.Trim())"
        $seen['arp'] = $true
    }

    $cands = @('192.168.1.50')
    if ($n % 3 -eq 0) { $cands += (Sweep5555) }
    foreach ($ip in ($cands | Select-Object -Unique)) {
        if (-not (Port5555 $ip)) { continue }
        Adb @('connect', "$ip`:5555") | Out-Null
        Start-Sleep -Milliseconds 700
        $state = (& $adb devices | Select-String "$([regex]::Escape($ip)):5555") -join ' '
        if ($state -match 'unauthorized') {
            if (-not $seen["unauth:$ip"]) { Log "$ip answers on 5555 but ADB is unauthorized: accept 'Always allow' on the TV"; $seen["unauth:$ip"] = $true }
            continue
        }
        if ($state -notmatch '\sdevice\s') { continue }

        Log "TV reachable at $ip - installing the current build"
        try {
            & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'install-tvhome.ps1') -Ip $ip *>> $log
            & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'set-default-home.ps1') -Ip $ip *>> $log
            $png = Join-Path $out 'home.png'
            & cmd /c "`"$adb`" -s $ip`:5555 exec-out screencap -p > `"$png`""
            if (Test-Path $png) { Log "screenshot: $png ($([int]((Get-Item $png).Length / 1KB)) KB)" }
            Log 'done - tvhome is installed and is the default home app'
            exit 0
        } catch {
            Log "install failed: $($_.Exception.Message) - still watching"
        }
    }
    Start-Sleep -Seconds $Interval
}
Log 'gave up: the TV never came back on the LAN'
exit 1
