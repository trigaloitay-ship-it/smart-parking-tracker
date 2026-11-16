# Windows version of simulate-camera.sh
# Usage: .\scripts\simulate-camera.ps1 [-Plate 123-45-678]
param([string]$Plate)
Set-Location (Join-Path $PSScriptRoot "..")

if (-not $Plate) {
  $Plate = "{0:000}-{1:00}-{2:000}" -f (Get-Random -Min 100 -Max 999), (Get-Random -Min 10 -Max 99), (Get-Random -Min 100 -Max 999)
}
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$File  = "${Plate}_${Stamp}.svg"
$Tmp   = New-TemporaryFile

$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="520" height="130" viewBox="0 0 520 130">
  <rect x="4" y="4" width="512" height="122" rx="14" fill="#F7C600" stroke="#111" stroke-width="6"/>
  <rect x="4" y="4" width="70" height="122" rx="14" fill="#1F4FA3"/>
  <text x="39" y="58" font-family="Arial" font-size="22" fill="#fff" text-anchor="middle" font-weight="bold">IL</text>
  <text x="295" y="92" font-family="Arial" font-size="72" font-weight="bold" fill="#111" text-anchor="middle" letter-spacing="4">$Plate</text>
</svg>
"@
[System.IO.File]::WriteAllText($Tmp.FullName, $svg)
docker compose cp $Tmp.FullName "storage:/usr/local/apache2/htdocs/images/$File"
Remove-Item $Tmp
Write-Host "Camera captured: $Plate -> $File"
