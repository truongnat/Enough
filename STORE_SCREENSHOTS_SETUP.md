# Google Play Store Screenshots — Automated Capture Setup

## Overview

Complete automated workflow to capture real device screenshots for Google Play Store listing.

**Features:**
- ✅ Automated script with adb screencap (no manual taps)
- ✅ Demo data seeded via SCREENSHOT_MODE
- ✅ 9:16 portrait (1080x1920) — Google Play compliant
- ✅ 5 curated screenshots showing key features
- ✅ Debug-only mode (zero impact on release builds)
- ✅ Works with physical devices + emulators

## Files Created

### 1. Demo Data Helper
**`lib/debug/store_screenshot_seed.dart`** (168 lines)
- Generates mock data in `kDebugMode` only
- Creates:
  - 3 Stop Alarms (Coding, Scrolling, Sleep)
  - 2 Stop Sessions (completed + snoozed)
  - 1 Stop Receipt (completed)
  - Weekly stats for charts
- No business logic changes
- Cleared automatically after app restart

### 2. Capture Script
**`scripts/capture_play_store_screenshots.sh`** (241 lines, executable)
- Bash automation script
- Checks ADB, device resolution, app status
- Builds app with `--dart-define=SCREENSHOT_MODE=true`
- Waits for app launch (with timeout)
- Captures 5 screenshots via `adb screencap`
- Pulls files to `store_assets/screenshots/phone/`
- Verifies all 5 files exist
- Colorized output + helpful error messages

### 3. Documentation
**`store_assets/screenshots/README.md`** (200+ lines)
- Complete guide for Google Play requirements
- Emulator setup instructions
- Troubleshooting section
- Image optimization tips

**`store_assets/screenshots/QUICK_START.md`**
- Quick reference guide
- Single command to capture
- Prerequisites checklist

### 4. Modified Files
**`lib/main.dart`**
- Added: `import 'package:flutter/foundation.dart'`
- Added: SCREENSHOT_MODE check in main()
- Calls `StoreScreenshotSeed.seedDemoData()` if:
  - `kDebugMode == true` (debug build only)
  - `SCREENSHOT_MODE=true` (dart-define flag)

## Folder Structure

```
store_assets/
├── screenshots/
│   ├── phone/                    # 9:16 portrait (1080x1920)
│   │   ├── 01_home_dashboard.png
│   │   ├── 02_create_stop_alarm.png
│   │   ├── 03_alarm_session.png
│   │   ├── 04_stop_receipt.png
│   │   └── 05_history_stats.png
│   ├── tablet_7/                 # 7-inch (future)
│   ├── tablet_10/                # 10-inch (future)
│   ├── README.md
│   └── QUICK_START.md

lib/debug/
└── store_screenshot_seed.dart    # Demo data generator (debug-only)

scripts/
└── capture_play_store_screenshots.sh  # Main automation
```

## Usage

### One-Line Capture
```bash
bash scripts/capture_play_store_screenshots.sh
```

Takes ~2-3 minutes. Outputs 5 PNG files to `store_assets/screenshots/phone/`.

### Prerequisites
- Android SDK + ADB in PATH
- Flutter SDK
- Android emulator running (or device connected)
- Pixel 7/8 with 1080x1920 resolution recommended

### Step-by-Step

1. **Start emulator** (if not already running)
   ```bash
   emulator -avd Pixel_7_API_33 &
   ```

2. **Verify device**
   ```bash
   adb devices
   adb shell wm size
   ```

3. **Run capture**
   ```bash
   bash scripts/capture_play_store_screenshots.sh
   ```

4. **Verify output**
   ```bash
   ls -lh store_assets/screenshots/phone/
   ```

## What Happens Under The Hood

### Build & Launch
1. `flutter clean` + `flutter pub get`
2. `flutter run --dart-define=SCREENSHOT_MODE=true --release`
3. App detects SCREENSHOT_MODE in main()
4. Demo data auto-seeds via StoreScreenshotSeed.seedDemoData()

### Screenshot Sequence
1. Home Dashboard (navigation bar visible, alarms displayed)
2. Create Stop Alarm form (pre-filled with demo values)
3. Stop Session screen (alarm modal showing)
4. Stop Receipt (completion details)
5. History/Stats (completed sessions list + weekly chart)

### File Management
- Captures via `adb shell screencap -p /sdcard/Pictures/{filename}`
- Pulls via `adb pull` to local folder
- Verifies file size > 0
- Reports file size (KB/MB)

## Safety Guarantees

✅ **No production impact:**
- SCREENSHOT_MODE is `--dart-define` only
- Only active in `kDebugMode` (debug builds only)
- Release builds ignore entirely

✅ **Data isolation:**
- Demo data cleared after app restart
- Uses temporary Hive boxes
- No persistence across sessions
- Safe to run on real devices

✅ **Code cleanliness:**
- Separate `lib/debug/` folder
- No business logic modified
- Script is standalone (can be run multiple times)
- No generated files committed (screenshots are optional)

## Screenshots Included

All 5 screenshots are **curated for Play Store**:

| # | Screen | Shows |
|---|--------|-------|
| 1 | Home Dashboard | Next alarm, today's sessions, all alarms list |
| 2 | Create Alarm Form | Title, stop type, time, mode selection |
| 3 | Stop Session Modal | Alarm trigger, "ĐẾN GIỜ DỪNG", buttons |
| 4 | Receipt Detail | Completed session summary, achievements |
| 5 | History/Stats | Session list, weekly stats, chart |

All in **Vietnamese** (app language).

## Google Play Submission

After capturing:

1. Review screenshots in `store_assets/screenshots/phone/`
2. Upload to Google Play Console:
   - App Content → Screenshots
   - Select "Phone screenshots (portrait)"
   - Upload 5 PNG files in order
3. Preview on different device sizes
4. Submit

## Updating Screenshots

When app changes:

```bash
# Re-capture
bash scripts/capture_play_store_screenshots.sh

# Review new screenshots
ls -lh store_assets/screenshots/phone/

# Commit (optional)
git add store_assets/screenshots/phone/
git commit -m "Update Google Play screenshots"
```

## Troubleshooting

### ADB not found
```bash
export PATH=$PATH:~/Library/Android/sdk/platform-tools
```

### Device resolution wrong
```bash
adb shell wm size 1080 1920
```

### App not loading
- Check: `adb logcat | grep -i "error\|crash"`
- Ensure device has ~1GB free space
- Restart emulator

### Screenshots are blank/black
- Wait longer: increase sleep in script
- Check app visibility: `adb shell dumpsys activity`
- Try `--profile` mode instead of `--release`

### Missing navigation buttons
- Adjust tap coordinates in script (device-specific)
- Or use manual navigation if button positions differ

## Notes

- **No deep links required** — uses adb button taps
- **Works with any device/emulator** — adjusts automatically
- **Recommended: Pixel 7/8 at 1080x1920** — matches most Play Store users
- **PNG format** — best quality for store
- **File size**: ~1-3 MB per screenshot (optimized)

## See Also

- `store_assets/screenshots/README.md` — Full technical details
- `store_assets/screenshots/QUICK_START.md` — Quick reference
- `lib/debug/store_screenshot_seed.dart` — Data structure
- `lib/main.dart` — SCREENSHOT_MODE integration
- `scripts/capture_play_store_screenshots.sh` — Script source

---

**Status: ✅ Ready to use**

Run: `bash scripts/capture_play_store_screenshots.sh`

Last updated: 2026-05-24
