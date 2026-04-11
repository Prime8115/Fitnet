# ⚡ Elite Fitness Tracker — Android App

**84-Day Transformation Program · April 10 → July 2, 2025**

A complete Flutter Android app tracking your full body fitness plan: Push, Pull, Legs, Combat (Shadow Boxing, Kickboxing, Sandbag), Full Body Power — across 3 progressive phases.

---

## 📱 App Features

- **Today's Dashboard** — auto-detects your current day
- **84-Day Calendar** — week-by-week view, tap any day for full workout
- **Exercise Tracker** — check off each exercise, built-in workout timer
- **Complete Workout Logging** — log feeling (emoji), energy (1-5), notes
- **Body Metrics** — track weight, body fat %, chest, waist, arm, thigh
- **Progress Charts** — weekly completion bars, phase breakdown
- **Streak Counter** — consecutive training day streaks
- **Post-84 Days** — extend plan OR start a brand new cycle
- **Deload Weeks** — auto-applied on Week 4 and Week 8
- **3 Phases** — Foundation → Intensity → Peak Shred (auto-progressing)
- **SQLite** — all data stored offline on your phone

---

## 🚀 OPTION 1: Build via GitHub Actions (FREE, Recommended)

This is the easiest method — takes ~10 minutes, no installation needed.

### Step 1: Create a free GitHub account
Go to https://github.com and sign up (free).

### Step 2: Create a new repository
1. Click **"New repository"** (green button)
2. Name it: `elite-fitness-tracker`
3. Set to **Private**
4. Click **"Create repository"**

### Step 3: Upload the project files
1. On your new repo page, click **"uploading an existing file"**
2. Upload ALL files from this zip (maintaining folder structure)
3. Click **"Commit changes"**

### Step 4: Watch the build
1. Click the **"Actions"** tab in your GitHub repo
2. You'll see **"Build Android APK"** running automatically
3. Wait ~8-10 minutes for it to finish

### Step 5: Download the APK
1. Click the completed workflow run
2. Scroll down to **"Artifacts"**
3. Click **"elite-fitness-apk"** to download
4. Extract the zip → you have `app-release.apk`

### Step 6: Install on your Android phone
1. Transfer the APK to your phone (WhatsApp, email, Google Drive, USB cable)
2. On your phone: **Settings → Security → Install unknown apps → Allow**
3. Tap the APK file to install
4. Open **"Elite Fitness"** — done! 🎉

---

## 🚀 OPTION 2: Build via Codemagic (Alternative)

1. Go to https://codemagic.io and sign in with GitHub
2. Click **"Add application"** → select your repo
3. Codemagic auto-detects Flutter and the `codemagic.yaml` config
4. Click **"Start new build"**
5. Download the APK from the build artifacts
6. Install on your phone

---

## 🚀 OPTION 3: Online Flutter Builder

1. Go to https://flutlab.io (online Flutter IDE)
2. Create account → New project → Upload files
3. Click Build → Android APK
4. Download and install

---

## 📂 Project Structure

```
elite_fitness_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── data/
│   │   └── workout_data.dart        # All 84-day workout data
│   ├── models/
│   │   └── workout_log.dart         # Data models
│   ├── providers/
│   │   └── fitness_provider.dart    # State management
│   ├── screens/
│   │   ├── splash_screen.dart       # Launch screen
│   │   ├── home_screen.dart         # Bottom nav shell
│   │   ├── dashboard_screen.dart    # Today's workout
│   │   ├── calendar_screen.dart     # 84-day calendar
│   │   ├── workout_detail_screen.dart  # Full workout + tracker
│   │   ├── progress_screen.dart     # Stats & charts
│   │   └── settings_screen.dart     # Plan management
│   └── utils/
│       ├── app_theme.dart           # Dark theme
│       └── database_helper.dart     # SQLite database
├── android/                         # Android config
├── codemagic.yaml                   # Codemagic CI config
├── .github/workflows/build.yml      # GitHub Actions config
└── pubspec.yaml                     # Dependencies
```

---

## 🏋️ The 84-Day Plan Inside the App

| Phase | Weeks | Focus |
|-------|-------|-------|
| Phase 1 — Foundation | 1–4 | 3×10–12, 60–90s rest, learn form |
| **Deload** | **4** | **40% volume, recovery** |
| Phase 2 — Intensity | 5–8 | 4×8–10, supersets, 45–60s rest |
| **Deload** | **8** | **40% volume, recovery** |
| Phase 3 — Peak Shred | 9–12 | 5×5, triple sets, 30–45s rest |

**Weekly Split:**
- Mon: Push (Chest, Shoulders, Triceps)
- Tue: Pull (Back, Biceps, Traps, Forearms)
- Wed: Combat & Core (Shadow Boxing, Kickboxing, Sandbag)
- Thu: Legs + Glutes (Quads, Hams, Calves, Adductors)
- Fri: Full Body Power (Olympic lifts)
- Sat: Combat Conditioning (Full sessions)
- Sun: Active Rest (Yoga, mobility)

---

## 🔧 Modifying the Plan

After 84 days, the app offers:
1. **Extend Plan** — add 4, 8, or 12 more weeks
2. **Start New Cycle** — fresh 84 days with harder targets
3. **Modify Start Date** — if you started on a different day

To add custom workouts, edit `lib/data/workout_data.dart` and rebuild.

---

## 📋 Dependencies Used

```yaml
provider: ^6.1.1          # State management
sqflite: ^2.3.0            # Local SQLite database
path: ^1.9.0               # File path utilities
shared_preferences: ^2.2.2 # Simple key-value storage
intl: ^0.19.0              # Date formatting
percent_indicator: ^4.2.3  # Progress indicators
flutter_slidable: ^3.1.0   # Swipeable list items
fl_chart: ^0.68.0          # Charts
flutter_local_notifications: ^17.2.2  # Workout reminders
vibration: ^2.0.0          # Haptic feedback
uuid: ^4.3.3               # Unique IDs
```

---

*Built for the 84-day elite transformation program. All muscle groups covered.*
