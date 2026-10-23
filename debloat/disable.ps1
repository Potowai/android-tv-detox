# Disables the packages listed in disabled-candidates.txt, one by one, with a log.
# Disables - never uninstalls: enable.ps1 brings everything back.
#
#   powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip 192.168.1.50 -DryRun
#   powershell -ExecutionPolicy Bypass -File debloat\disable.ps1 -Ip 192.168.1.50
#
# PERSISTENT packages are skipped unless -IncludePersistent is given: the system expects them
# and disabling them can leave the TV in a strange state.
param(
    [string]$Ip = '192.168.1.50',
    [switch]$DryRun,
    [switch]$IncludePersistent
)
$ErrorActionPreference = 'Stop'
$adb = 'adb'
$here = $PSScriptRoot
$list = Join-Path $here 'disabled-candidates.txt'
$log = Join-Path $here 'disabled-by-this-script.txt'
if (-not (Test-Path $list)) { throw "no package list: $list" }

function Adb([string[]]$argv) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { (& $adb @argv 2>&1) } finally { $ErrorActionPreference = $prev }
}
function Sh([string]$cmd) { Adb @('-s', "$Ip`:5555", 'shell', $cmd) }

& $adb connect "$Ip`:5555" | Out-Null
$state = (& $adb devices) | Where-Object { $_ -like "$Ip`:5555*" }
if ($state -notmatch '\bdevice\b') { throw "no device at $Ip`:5555 ($state)" }

$pkgs = Get-Content $list | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
$done = @()
$skipped = @()

foreach ($p in $pkgs) {
    $info = (Sh "dumpsys package $p | grep -E 'flags=|pkgFlags=' | head -2") -join ' '
    if (-not $info) { $skipped += "$p (not installed)"; continue }
    $persistent = $info -match 'PERSISTENT'
    if ($persistent -and -not $IncludePersistent) { $skipped += "$p (PERSISTENT)"; continue }
    if ($DryRun) { Write-Host "would disable $p"; $done += $p; continue }

    $out = (Sh "pm disable-user --user 0 $p") -join ' '
    if ($out -match 'new state') { Write-Host "disabled $p"; $done += $p }
    else { $skipped += "$p ($out)" }
}

if (-not $DryRun -and $done.Count) {
    $existing = @()
    if (Test-Path $log) { $existing = Get-Content $log | Where-Object { $_.Trim() -and -not $_.StartsWith('#') } }
    $all = @($existing) + $done | Sort-Object -Unique
    [IO.File]::WriteAllText($log, (($all -join "`r`n") + "`r`n"), (New-Object Text.UTF8Encoding($false)))
}

"disabled: $($done.Count)"
if ($skipped.Count) { "skipped:`r`n  " + ($skipped -join "`r`n  ") }
if (-not $DryRun) { 'now run export.ps1 and compare with disabled.txt' }
