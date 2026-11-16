# 🅿️ Smart Parking License Plate Tracker

מערכת לניהול כניסת רכבים לחניון חכם – **Track 1 (Lite): Nginx + Apache + Docker Compose**.

מצלמת IoT מצלמת את לוחית הרישוי של כל רכב שנכנס ושומרת את התמונה בשרת אחסון ייעודי.
השומר פותח לוח בקרה בדפדפן ורואה את כל הרכבים שנכנסו – הרשימה מתעדכנת אוטומטית כל 5 שניות.

![CI](../../actions/workflows/docker-ci.yml/badge.svg)

![Dashboard](docs/dashboard.png)

## ארכיטקטורה

```
                 ┌──────────────── parking-net (bridge) ────────────────┐
 Guard browser   │  ┌──────────────┐  /storage/*   ┌──────────────────┐ │
 :8080  ───────────▶│ web (Nginx)  │ ─────────────▶│ storage (Apache) │ │
                 │  │ index.html   │  proxy_pass   │ /htdocs/images   │ │
                 │  └──────────────┘               └────────┬─────────┘ │
                 └──────────────────────────────────────────│───────────┘
 IoT camera (simulate-camera.sh) ── docker compose cp ──────▶│
                                                    volume: plates-data
```

| שירות | Image | פורט | תפקיד |
|---|---|---|---|
| `web` | `nginx:1.27-alpine` | 8080 | מגיש את לוח הבקרה (HTML/JS) ומשמש Reverse Proxy ל-storage |
| `storage` | `httpd:2.4-alpine` | 8081 | שרת אחסון בלבד – מגיש את תמונות הלוחיות |

## מבנה הפרויקט

```
smart-parking-tracker/
├── docker-compose.yml          # אורקסטרציה: 2 שירותים, רשת, volume
├── web/
│   ├── Dockerfile              # nginx + הקונפיג + הדשבורד
│   ├── nginx.conf              # הגשת HTML + proxy ל-/storage/
│   └── index.html              # לוח הבקרה לשומר
├── storage/
│   ├── Dockerfile              # httpd + תמונות התחלתיות
│   └── images/                 # תמונות seed
├── scripts/
│   ├── simulate-camera.sh      # סימולציית מצלמה (Linux/Mac/Git Bash)
│   ├── simulate-camera.ps1     # סימולציית מצלמה (Windows PowerShell)
│   └── make-plate.sh           # יוצר "תמונה" של לוחית (SVG)
└── .github/workflows/
    └── docker-ci.yml           # CI/CD: build + בדיקות + push ל-GHCR
```

## הרצה

```bash
docker compose up -d --build
```

- לוח הבקרה: http://localhost:8080
- שרת האחסון ישירות: http://localhost:8081/images/

סימולציית מצלמה (רכב חדש נכנס):

```bash
./scripts/simulate-camera.sh              # לוחית אקראית
./scripts/simulate-camera.sh 123-45-678   # לוחית מסוימת
```

ב-Windows:

```powershell
.\scripts\simulate-camera.ps1 -Plate 123-45-678
```

הכרטיס החדש יופיע בדשבורד תוך 5 שניות, עם מסגרת ירוקה.

## Data Persistence – הדגמה

```bash
./scripts/simulate-camera.sh 999-99-999
docker compose down          # הקונטיינרים נמחקים
docker compose up -d         # עולים מחדש
# הרכב 999-99-999 עדיין מופיע! התמונות נשמרות ב-volume בשם plates-data
docker volume ls
docker compose down -v       # רק -v מוחק גם את ה-volume
```

## CI/CD

ה-Workflow ‏`.github/workflows/docker-ci.yml` רץ בכל `push` ו-Pull Request:

1. בודק שה-`docker-compose.yml` תקין
2. בונה את שני ה-Images
3. מרים את המערכת ומריץ Smoke tests עם `curl` (דשבורד, proxy, סימולציית מצלמה)
4. **בונוס:** בכל push ל-`main` – מעלה את ה-Images ל-GitHub Container Registry:
   - `ghcr.io/<owner>/parking-web`
   - `ghcr.io/<owner>/parking-storage`

## עבודת צוות

- כל חבר צוות עובד ב-branch משלו (`feature/...`) ופותח Pull Request ל-`main`
- ה-CI חייב לעבור לפני Merge
- לפחות commit אחד מכל חבר צוות

| חבר צוות | אחריות |
|---|---|
| איתי טריגלו | שירות web: Nginx + לוח הבקרה · CI/CD + העלאה ל-GHCR |
| אור חיים עזרייה | שירות storage: Apache + Volume · סימולציית מצלמה · README |
