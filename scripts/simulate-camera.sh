#!/bin/sh
# Simulates the IoT camera: "photographs" a car and saves the photo
# into the storage folder (./storage/images, mounted into Apache).
# Usage: ./scripts/simulate-camera.sh [plate]   e.g. ./scripts/simulate-camera.sh 482-17-305
# Without a plate, a random photo from camera/samples is used.
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

PLATE="$(basename "$PHOTO" .png)"
STAMP="$(date +%Y%m%d-%H%M%S)"
FILE="${PLATE}_${STAMP}.png"

cp "$PHOTO" "storage/images/$FILE"
chmod 644 "storage/images/$FILE"   # Apache must be able to read it
echo "📸 Camera captured: $PLATE  ->  storage/images/$FILE"
