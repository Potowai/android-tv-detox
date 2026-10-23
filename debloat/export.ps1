# Reads the TV's package state and writes it here, before touching anything.
#
#   powershell -ExecutionPolicy Bypass -File debloat\export.ps1 -Ip 192.168.1.50
param([string]$Ip = '192.168.1.50')
$ErrorActionPreference = 'Stop'
$adb = 'adb'
$here = $PSScriptRoot

function Sh([string]$cmd) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { (& $adb -s "$Ip`:5555" shell $cmd 2>&1) } finally { $ErrorActionPreference = $prev }
}

& $adb connect "$Ip`:5555" | Out-Null
$state = (& $adb devices) | Where-Object { $_ -like "$Ip`:5555*" }
if ($state -notmatch '\bdevice\b') { throw "no device at $Ip`:5555 ($state)" }

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
function Save([string]$file, [string]$title, $lines) {
    $body = "# $title - $stamp`r`n" + (($lines | Sort-Object) -join "`r`n") + "`r`n"
    [IO.File]::WriteAllText((Join-Path $here $file), $body, (New-Object Text.UTF8Encoding($false)))
    "$file : $($lines.Count) packages"
}

$disabled = Sh 'pm list packages -d' | ForEach-Object { $_ -replace '^package:', '' } | Where-Object { $_ }
$suspended = Sh 'pm list packages' | ForEach-Object { $_ -replace '^package:', '' } | Where-Object { $_ }
$thirdParty = Sh 'pm list packages -3 -e' | ForEach-Object { $_ -replace '^package:', '' } | Where-Object { $_ }

Save 'disabled.txt' 'packages disabled on this TV' $disabled
Save 'third-party.txt' 'third-party packages still enabled' $thirdParty

# Suspended packages don't have a list command of their own; ask each one.
$sus = @()
foreach ($p in $suspended) {
    $dump = Sh "dumpsys package $p | grep -m1 suspended="
    if ($dump -match 'suspended=true') { $sus += $p }
}
Save 'suspended.txt' 'packages suspended on this TV' $sus
