#!/bin/sh
# Simulates the IoT camera: takes a license-plate photo from camera/samples
# and saves it into the named volume via add-car.sh.
# Usage: ./scripts/simulate-camera.sh [plate]   e.g. ./scripts/simulate-camera.sh 482-17-305
# Without a plate, a random photo is used.
set -e
cd "$(dirname "$0")/.."

if [ -n "$1" ]; then
  PHOTO="camera/samples/$1.png"
  if [ ! -f "$PHOTO" ]; then
    echo "No photo for plate $1. Available plates:"; ls camera/samples | sed 's/\.png$//'
    exit 1
  fi
else
  PHOTO="$(ls camera/samples/*.png | awk 'BEGIN{srand()} {a[NR]=$0} END{print a[int(rand()*NR)+1]}')"
fi

echo "📸 Camera captured $(basename "$PHOTO" .png)"
sh scripts/add-car.sh "$PHOTO"
