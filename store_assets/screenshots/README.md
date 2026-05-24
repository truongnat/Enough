# Google Play Store Screenshots

This directory contains real device screenshots for Google Play Store listings.

## Structure

```
screenshots/
├── phone/              # 9:16 portrait (1080x1920 recommended)
├── tablet_7/           # 7-inch tablet landscape (1280x800)
├── tablet_10/          # 10-inch tablet landscape (1280x800)
└── README.md
```

## Requirements

- **Format**: PNG or JPEG (PNG recommended)
- **Aspect Ratio**: 9:16 portrait (for phone)
- **Resolution**: 
  - Minimum: 320px on shortest edge
  - Maximum: 3840px on longest edge
  - **Recommended**: 1080x1920 (emulator Pixel 7/8)
- **File Size**: Optimized (< 8MB per image)

## Screenshots for Phone (9:16)

1. **01_home_dashboard.png** — Home screen showing next alarm, today's sessions, and all alarms list
2. **02_create_stop_alarm.png** — Create Stop Alarm form with fields filled (name, stop type, time, mode)
3. **03_alarm_session.png** — Stop Session modal/screen showing "ĐẾN GIỜ DỪNG" with confirmation button
4. **04_stop_receipt.png** — Stop Receipt/Paper showing completed session details
5. **05_history_stats.png** — History or Stats screen with session list and weekly summary

## How to Generate Screenshots

### Prerequisites

- Flutter SDK installed
- Android SDK with ADB in PATH
- Android emulator running (recommended: **Pixel 7 / Pixel 8 with 1080x1920 resolution**)
- Device connected or emulator started

### Quick Start

1. **Start emulator** (if using emulator):
   ```bash
   emulator -avd Pixel_7_API_33 &
   # or use Android Studio's AVD Manager
   ```

2. **Verify device connection**:
   ```bash
   adb devices
   ```

3. **Run capture script**:
   ```bash
   bash scripts/capture_play_store_screenshots.sh
   ```

   The script will:
   - Check ADB connection
   - Clean and prepare build
   - Run app with `SCREENSHOT_MODE=true` (loads demo data automatically)
   - Navigate through each screen and capture
   - Pull screenshots from device
   - Save to `store_assets/screenshots/phone/`

### Manual Steps (if script fails)

1. Launch app with screenshot mode:
   ```bash
   flutter run \
       -d <device_id> \
       --dart-define=SCREENSHOT_MODE=true
   ```

2. Manually navigate to each screen and capture:
   ```bash
   # Take screenshot
   adb shell screencap -p /sdcard/Pictures/screenshot.png
   
   # Pull to computer
   adb pull /sdcard/Pictures/screenshot.png ./store_assets/screenshots/phone/01_home_dashboard.png
   ```

3. Rename files to match the numbering scheme (01_, 02_, etc.)

## Screenshot Mode (SCREENSHOT_MODE)

When `SCREENSHOT_MODE=true` is passed via `--dart-define`:

- App automatically seeds demo data on startup (Hive database)
- Disables debug banner
- Loads 3 demo Stop Alarms, 2 demo Stop Sessions, 1 demo Receipt, and weekly stats
- Data is purely for demo and doesn't persist after app close
- Only works in debug mode (`kDebugMode`)

## Demo Data Seeded

When `SCREENSHOT_MODE=true`:

### Alarms (3)
1. "Dừng code trước khi ngủ" — Coding, 23:30, Strict mode, Enabled, Weekdays
2. "Dừng lướt điện thoại" — Scrolling, 22:15, General mode, Enabled, Daily
3. "Đi ngủ đúng giờ" — Sleep, 00:00, General mode, **Disabled**, Weekdays

### Stop Sessions (2, today)
1. Completed session for alarm 1 (Coding)
2. Snoozed session for alarm 2 (Scrolling)

### Stop Receipts (1)
- Completed receipt for "Dừng code" with success result

### Weekly Stats
- 12 sessions this week, 9 completed, 2 snoozed, 1 missed
- 120 total minutes this week
- 2 completed today, 1 snoozed today

## Emulator Setup Recommendation

### For Pixel 7 (1080x1920)

1. **Open Android Studio** → **Device Manager**
2. **Create Virtual Device** (if not exists):
   - Device: Pixel 7
   - API Level: 33 or higher (Android 13+)
   - RAM: 4GB, Storage: 2GB
3. **Launch emulator**:
   ```bash
   emulator -avd Pixel_7_API_33
   ```

### Verify Resolution
```bash
adb shell wm size
# Output should be: 1080x1920
```

## Image Optimization

If screenshots are too large or need optimization:

### Using ImageMagick
```bash
convert input.png -quality 92 -resize 1080x1920 output.png
```

### Using Python PIL
```python
from PIL import Image
img = Image.open('input.png')
img = img.resize((1080, 1920))
img.save('output.png', 'PNG', optimize=True)
```

## Troubleshooting

### Screenshot is blank or black
- App might still be loading, wait 3-5 seconds
- Check app logs: `adb logcat`

### Cannot navigate to screens
- Deep links might not be working, use physical navigation in app
- Ensure demo data is loaded: check Hive database in app

### Images are wrong size or aspect ratio
- Check emulator resolution: `adb shell wm size`
- Resize with ImageMagick or PIL if needed (keep 9:16 ratio)

### ADB not found
- Ensure Android SDK is installed
- Add to PATH: `export PATH=$PATH:~/Library/Android/sdk/platform-tools`
- Restart terminal

## Google Play Submission

1. **Verify all 5 images exist and meet requirements**
2. **Upload to Google Play Console**:
   - Go to: App Content → Screenshots
   - Select "Phone screenshots (portrait)"
   - Upload PNG files in order
3. **Preview on different devices** in Play Console
4. **Check for issues**: overlays, text cutoff, poor visibility

## Updating Screenshots

When app UI changes:

1. Run script again: `bash scripts/capture_play_store_screenshots.sh`
2. Verify new screenshots look good
3. Commit to repository (optional)
4. Upload new screenshots to Google Play Console

## Notes

- Screenshots are **NOT** committed to production builds (SCREENSHOT_MODE is debug-only)
- Demo data is **temporary** and cleared after app restart
- Images should show **actual UI in use** (not empty states or loading screens)
- Keep screenshots updated with latest app features and design
- Ensure **Vietnamese text** is visible and readable (app is in Vietnamese)

---

Last updated: 2026-05-24
