# Windows version of add-car.sh
# Adds a car: copies ANY license-plate photo into the named volume "plates-data"
# Usage: .\scripts\add-car.ps1 <photo>      e.g. .\scripts\add-car.ps1 camera\samples\905-31-462.png
#   The plate number is taken from the file name.
param([Parameter(Mandatory = $true)][string]$Photo)

$Src = Resolve-Path $Photo -ErrorAction SilentlyContinue
if (-not $Src) { Write-Host "File not found: $Photo"; exit 1 }
$Item = Get-Item $Src
if ($Item.Extension -notmatch '^\.(png|jpe?g|webp)$') { Write-Host "Not an image (png/jpg/jpeg/webp): $Photo"; exit 1 }

Set-Location (Join-Path $PSScriptRoot "..")
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$File  = "$($Item.BaseName)_$Stamp$($Item.Extension)"
$Dest  = "/usr/local/apache2/htdocs/images/$File"

docker compose cp $Item.FullName "storage:$Dest"
if ($LASTEXITCODE -ne 0) { exit 1 }
docker compose exec -T storage chmod 644 $Dest   # Apache must be able to read it
Write-Host "Car added to volume plates-data: $($Item.BaseName) -> $File"
