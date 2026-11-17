# Windows version of simulate-camera.sh
# Simulates the IoT camera: copies a license-plate photo into storage\images
# Usage: .\scripts\simulate-camera.ps1 [-Plate 482-17-305]
# Without -Plate, a random photo from camera\samples is used.
param([string]$Plate)
Set-Location (Join-Path $PSScriptRoot "..")

if ($Plate) {
  $Photo = Join-Path "camera\samples" "$Plate.png"
  if (-not (Test-Path $Photo)) {
    Write-Host "No photo for plate $Plate. Available plates:"
    Get-ChildItem "camera\samples\*.png" | ForEach-Object { $_.BaseName }
    exit 1
  }
  $Photo = Get-Item $Photo
} else {
  $Photo = Get-ChildItem "camera\samples\*.png" | Get-Random
}

$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$File  = "$($Photo.BaseName)_$Stamp.png"
Copy-Item $Photo.FullName (Join-Path "storage\images" $File)
Write-Host "Camera captured: $($Photo.BaseName) -> storage\images\$File"
