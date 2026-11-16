#!/bin/sh
# Simulates the IoT camera: "photographs" a car and saves the image
# into the storage service (inside the named volume).
# Usage: ./scripts/simulate-camera.sh [plate]      e.g. ./scripts/simulate-camera.sh 123-45-678
set -e
cd "$(dirname "$0")/.."

if [ -n "$1" ]; then
  PLATE="$1"
else
  # random Israeli-style plate: 123-45-678
  PLATE="$(awk 'BEGIN{srand(); printf "%03d-%02d-%03d", int(rand()*900)+100, int(rand()*90)+10, int(rand()*900)+100}')"
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
FILE="${PLATE}_${STAMP}.svg"
TMP="$(mktemp)"

sh scripts/make-plate.sh "$PLATE" "$TMP"
chmod 644 "$TMP"   # Apache must be able to read the file
docker compose cp "$TMP" "storage:/usr/local/apache2/htdocs/images/$FILE"
rm -f "$TMP"
echo "📸 Camera captured: $PLATE  ->  $FILE"
