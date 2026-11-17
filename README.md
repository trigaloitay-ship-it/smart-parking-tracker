# 🅿️ Smart Parking License Plate Tracker

לוח בקרה חי לשומר בכניסה לחניון. כל לוחית רישוי שהמצלמה מצלמת נשמרת ב-Volume של שרת האחסון,
וקופצת במסך של השומר תוך 5 שניות – **בלי שהוא צריך לרענן את הדף**.

> מסלול: **Track 1 – Lite** (HTML + Nginx + Apache) · Docker Compose · Named Volume · GitHub Actions · GHCR

[![Docker CI/CD](https://github.com/trigaloitay-ship-it/smart-parking-tracker/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/trigaloitay-ship-it/smart-parking-tracker/actions/workflows/docker-ci.yml)

![לוח הבקרה](docs/dashboard.png)

## ארכיטקטורה

```
 דפדפן השומר
     │
     └── http://localhost:8080 ──► web (Nginx)  – מגיש את לוח הבקרה (index.html)
                                     │
                                     │  /storage/  →  proxy_pass  (רשת פנימית parking-net)
                                     ▼
                                  storage (Apache) – מגיש את תמונות הלוחיות
                                     │
                                     └── Named Volume "plates-data" – המקור היחיד לתמונות

 מצלמת IoT (add-car / simulate-camera) ── docker compose cp ──► Volume "plates-data"
```

| שירות | אימג' בסיס | פורט | תפקיד |
|---|---|---|---|
| `web` | `nginx:1.27-alpine` | 8080 | לוח הבקרה לשומר + Reverse Proxy ל-storage |
| `storage` | `httpd:2.4-alpine` | 8081 | שרת אחסון בלבד – מגיש את תמונות המצלמה מה-Volume |

## הרצה

```bash
docker compose up -d --build
```

- לוח הבקרה: http://localhost:8080
- שרת האחסון ישירות: http://localhost:8081/images/

בהרצה הראשונה הלוח **ריק** – אין תמונות בתוך האימג', הכול מגיע מה-Volume.

כיבוי המערכת – הרכבים שכבר נכנסו לא נמחקים, כי הם ב-Volume:

```bash
docker compose down
```

## רכב חדש נכנס – הוספת תמונה ל-Volume

`add-car` מעתיק תמונת לוחית כלשהי (`.png` / `.jpg` / `.jpeg` / `.webp`) לתוך ה-Volume (`docker compose cp`) ומוסיף חותמת זמן.
מספר הלוחית נלקח משם הקובץ, למשל `905-31-462.png`.

```bash
./scripts/add-car.sh camera/samples/905-31-462.png     # Linux / Mac
./scripts/simulate-camera.sh                           # "המצלמה" – תמונה אקראית מ-camera/samples
```

ב-Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\add-car.ps1 camera\samples\905-31-462.png
powershell -ExecutionPolicy Bypass -File .\scripts\simulate-camera.ps1
```

הרכב מופיע בלוח הבקרה תוך 5 שניות, עם **מסגרת ירוקה**.

## הדגמת Volume

1. מרימים את המערכת – הלוח ריק:

   ```bash
   docker compose up -d --build
   ```

2. "המצלמה" מצלמת רכב חדש ושומרת אותו ב-Volume:

   ```bash
   ./scripts/add-car.sh camera/samples/482-17-305.png
   ```

   בלי לרענן: הרכב מופיע בירוק, המונה עולה ל-1.
3. מוחקים ומקימים מחדש את הקונטיינרים:

   ```bash
   docker compose down
   docker compose up -d
   ```

4. הרכב עדיין שם – התמונה שמורה ב-Volume `plates-data` ולא בתוך הקונטיינר:

   ```bash
   docker volume ls
   ```

> ⚠️ הדגל `-v` (`docker compose down -v`) מוחק את `plates-data` יחד עם כל הרכבים. הוא שימושי רק לפני דמו, כדי שהלוח יתחיל ריק.

## CI/CD

בכל `push` ובכל Pull Request רץ ב-GitHub Actions ה-Workflow [`.github/workflows/docker-ci.yml`](.github/workflows/docker-ci.yml):

1. בודק שה-`docker-compose.yml` תקין
2. בונה את שני האימג'ים (`docker compose build`)
3. מרים את המערכת ובודק עם `curl`: הדשבורד, ה-proxy, שה-Volume מתחיל ריק, הוספת רכב, סימולציית מצלמה,
   ושהתמונות שורדות `down` + `up`
4. **בונוס:** ב-push ל-`main`, ורק אם הבדיקות עברו – מעלה את האימג'ים ל-GitHub Container Registry:
   `ghcr.io/trigaloitay-ship-it/parking-web` ו-`ghcr.io/trigaloitay-ship-it/parking-storage`

אם אחת הבדיקות נכשלת, הריצה אדומה, הלוגים מודפסים, ושום אימג' לא עולה ל-GHCR.

## האלמנט האישי שלנו: לוח בקרה חי

השומר לא צריך ללחוץ F5. קוד JavaScript ב-[`web/index.html`](web/index.html):

- כל 5 שניות קורא עם `fetch` את רשימת הקבצים שהמצלמה שמרה ב-Volume (דרך ה-proxy של Nginx).
- מוציא מכל שם קובץ את **מספר הלוחית** ואת **שעת הכניסה** – בלי מסד נתונים.
- בונה כרטיס לכל רכב, מעדכן את **מונה הרכבים** ואת **שעת הכניסה האחרונה**.
- רכב חדש מקבל **מסגרת ירוקה**, כדי שהשומר יראה מיד מי נכנס עכשיו.

בחרנו בזה כי שומר בכניסה לא יושב ומרענן דף – הוא צריך לראות רכב חדש ברגע שהמצלמה מצלמת אותו.
וזה גם מראה בדמו בצורה ברורה את ה-Volume: מוסיפים תמונה ל-Volume, והיא קופצת בלוח.

## שימוש ב-AI

עבדנו עם Claude. הפרומפטים, הטעויות של ה-AI ואיך תיקנו אותן מתועדים ב-[`AI_USAGE.md`](AI_USAGE.md).

## מבנה הפרויקט

```
smart-parking-tracker/
├── docker-compose.yml          # 2 שירותים, רשת parking-net, Named Volume plates-data
├── web/
│   ├── Dockerfile              # Nginx + הקונפיג + לוח הבקרה
│   ├── nginx.conf              # הגשת הדף + proxy ל-/storage/
│   └── index.html              # לוח הבקרה החי
├── storage/
│   └── Dockerfile              # Apache – שרת אחסון בלבד, בלי תמונות בתוך האימג'
├── camera/samples/             # תמונות לוחיות לדוגמה (PNG) – "המצלמה"
├── scripts/
│   ├── add-car.sh / .ps1       # מוסיף תמונת לוחית ל-Volume
│   └── simulate-camera.sh / .ps1  # בוחר תמונה אקראית ומפעיל את add-car
├── docs/                       # המצגת וצילום המסך
├── AI_USAGE.md                 # תיעוד השימוש ב-AI
└── .github/workflows/
    └── docker-ci.yml           # CI/CD: build + בדיקות + push ל-GHCR
```

## הצוות

| שם | אחריות |
|---|---|
| איתי טריגלו | `docker-compose.yml`, לוח הבקרה (web + Nginx), ה-CI/CD וההעלאה ל-GHCR |
| אור חיים עזרייה | שרת האחסון (storage + Apache), ה-Volume, המצלמה (`add-car`), README |

## פתרון בעיות ב-Windows

| הודעת שגיאה | פתרון |
|---|---|
| `'docker' is not recognized` | להתקין Docker Desktop: https://www.docker.com/products/docker-desktop |
| `failed to connect to the docker API` | לפתוח את Docker Desktop ולחכות ל-"Engine running" |
| הסקריפט `add-car.ps1` / `simulate-camera.ps1` נחסם | להריץ עם `powershell -ExecutionPolicy Bypass -File .\scripts\add-car.ps1 <תמונה>` |
| תמונה לא מופיעה בדשבורד | לוודא שהמערכת רצה (`docker compose ps`) ושהסיומת היא png / jpg / webp |
| `service "storage" is not running` | להרים קודם את המערכת: `docker compose up -d` |
