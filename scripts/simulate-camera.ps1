# Windows version of simulate-camera.sh
# Simulates the IoT camera: takes a photo from camera\samples and saves it
# into the named volume via add-car.ps1.
# Usage: .\scripts\simulate-camera.ps1 [-Plate 482-17-305]
param([string]$Plate)
Set-Location (Join-Path $PSScriptRoot "..")

if ($Plate) {
  $Photo = Join-Path "camera\samples" "$Plate.png"
  if (-not (Test-Path $Photo)) {
    Write-Host "No photo for plate $Plate. Available plates:"
    Get-ChildItem "camera\samples\*.png" | ForEach-Object { $_.BaseName }
    exit 1
  }
} else {
  $Photo = (Get-ChildItem "camera\samples\*.png" | Get-Random).FullName
}

Write-Host "Camera captured $([IO.Path]::GetFileNameWithoutExtension($Photo))"
& (Join-Path $PSScriptRoot "add-car.ps1") $Photo
