#!/bin/sh
# Adds a car: copies ANY license-plate photo into the named volume "plates-data"
# (through the storage container). The dashboard shows it within 5 seconds.
# Usage: ./scripts/add-car.sh <photo.png|jpg|jpeg|webp>
#   The plate number is taken from the file name, e.g. 905-31-462.png
set -e
cd "$(dirname "$0")/.."

SRC="$1"
if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: $0 <photo file>   e.g. $0 camera/samples/905-31-462.png"; exit 1
fi
case "$SRC" in
  *.png|*.PNG|*.jpg|*.JPG|*.jpeg|*.JPEG|*.webp|*.WEBP) ;;
  *) echo "Not an image (png/jpg/jpeg/webp): $SRC"; exit 1 ;;
esac

NAME="$(basename "$SRC")"
PLATE="${NAME%.*}"
EXT="${NAME##*.}"
STAMP="$(date +%Y%m%d-%H%M%S)"
FILE="${PLATE}_${STAMP}.${EXT}"
DEST="/usr/local/apache2/htdocs/images/$FILE"

docker compose cp "$SRC" "storage:$DEST"
docker compose exec -T storage chmod 644 "$DEST"   # Apache must be able to read it
echo "🚗 Car added to volume plates-data: $PLATE  ->  $FILE"
