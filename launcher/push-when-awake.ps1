# Pushes the current build to the TV as soon as it is reachable again (it drops off the
# LAN in standby), then restarts the launcher and takes a screenshot.
#
#   powershell -ExecutionPolicy Bypass -File push-when-awake.ps1
param(
    [string]$Ip = '192.168.1.50',
    [int]$Minutes = 45
)
$ErrorActionPreference = 'Stop'
$adb = 'adb'
$root = $PSScriptRoot
$apk = Join-Path $root 'out\tvhome.apk'
$out = Join-Path $root 'out'
$log = Join-Path $out 'push-when-awake.log'

function Log($m) {
    $line = "{0}  {1}" -f (Get-Date -Format 'HH:mm:ss'), $m
    Add-Content -Path $log -Value $line
    Write-Host $line
}
function Adb {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Argv)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { (& $adb @Argv 2>&1) } finally { $ErrorActionPreference = $prev }
}

Log "waiting for $Ip to answer on 5555 (up to $Minutes min)"
$end = (Get-Date).AddMinutes($Minutes)
while ((Get-Date) -lt $end) {
    $c = New-Object System.Net.Sockets.TcpClient
    $open = $false
    try { $open = $c.ConnectAsync($Ip, 5555).Wait(1200) -and $c.Connected } catch {}
    finally { $c.Close() }
    if (-not $open) { Start-Sleep -Seconds 10; continue }

    Adb @('connect', "$Ip`:5555") | Out-Null
    Start-Sleep -Seconds 1
    $state = (& $adb devices) | Where-Object { $_ -like "$Ip`:5555*" }
    if ($state -notmatch '\bdevice\b') {
        Log "answers, but ADB says: $state"
        Start-Sleep -Seconds 15
        continue
    }

    Log 'awake - installing'
    Log ((Adb @('-s', "$Ip`:5555", 'install', '-r', $apk)) -join ' ')
    Adb @('-s', "$Ip`:5555", 'shell', 'am', 'force-stop', 'com.ansub.tvhome') | Out-Null
    Adb @('-s', "$Ip`:5555", 'shell', 'am', 'start', '-n', 'com.ansub.tvhome/.MainActivity') | Out-Null
    Start-Sleep -Seconds 5
    $png = Join-Path $out 'mock-final.png'
    & cmd /c "`"$adb`" -s $Ip`:5555 shell screencap -p /sdcard/final.png && `"$adb`" -s $Ip`:5555 pull /sdcard/final.png `"$png`"" *>> $log
    if (Test-Path $png) { Log "screenshot: $png" }
    Log 'done'
    exit 0
}
Log 'gave up waiting'
exit 1
