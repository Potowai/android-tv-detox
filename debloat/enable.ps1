# Turns every package this repo disabled back on. Nothing is uninstalled, so this is the
# whole undo: the TV comes back to its stock app list.
#
#   powershell -ExecutionPolicy Bypass -File debloat\enable.ps1 -Ip 192.168.1.50 -DryRun
#   powershell -ExecutionPolicy Bypass -File debloat\enable.ps1 -Ip 192.168.1.50
param(
    [string]$Ip = '192.168.1.50',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$adb = 'adb'
$here = $PSScriptRoot

function Adb([string[]]$argv) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { (& $adb @argv 2>&1) } finally { $ErrorActionPreference = $prev }
}
function Sh([string]$cmd) { Adb @('-s', "$Ip`:5555", 'shell', $cmd) }

& $adb connect "$Ip`:5555" | Out-Null
$state = (& $adb devices) | Where-Object { $_ -like "$Ip`:5555*" }
if ($state -notmatch '\bdevice\b') { throw "no device at $Ip`:5555 ($state)" }

# disabled.txt is the snapshot taken after the debloat; disabled-by-this-script.txt is what
# disable.ps1 itself did. Both are re-enabled, so nothing is missed.
$pkgs = @()
foreach ($f in 'disabled.txt', 'disabled-by-this-script.txt') {
    $path = Join-Path $here $f
    if (Test-Path $path) {
        $pkgs += Get-Content $path | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
    }
}
$pkgs = $pkgs | Sort-Object -Unique
if (-not $pkgs.Count) { throw 'nothing to enable: run export.ps1 first' }

$on = 0
foreach ($p in $pkgs) {
    if ($DryRun) { Write-Host "would enable $p"; continue }
    $out = (Sh "pm enable $p") -join ' '
    if ($out -match 'new state') { Write-Host "enabled $p"; $on++ }
    else { Write-Host "kept off $p ($out)" }
}

# The two suspended ones need their own command.
foreach ($p in @('com.tcl.factory.view', 'com.tcl.system.server')) {
    if (-not $DryRun) { Sh "pm unsuspend --user 0 $p" | Out-Null; Write-Host "unsuspended $p" }
}

if ($DryRun) { "would enable $($pkgs.Count) packages" } else { "enabled $on packages" }
