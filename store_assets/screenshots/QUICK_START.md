# Quick Start: Capture Google Play Screenshots

## Prerequisites

- Android SDK with ADB installed
- Flutter SDK
- Android Emulator (Pixel 7/8 recommended) or connected device
- Resolution: 1080x1920 (9:16 portrait)

## Setup Emulator (First Time)

### Using Android Studio
1. Open Android Studio → Device Manager
2. Create Virtual Device → Select Pixel 7
3. API Level: 33 or higher
4. Launch emulator

### Using Command Line
```bash
# List available emulators
emulator -list-avds

# Launch emulator
emulator -avd Pixel_7_API_33 &

# Verify resolution
adb shell wm size
# Should output: 1080x1920
```

## Run Screenshot Capture (2-3 minutes)

```bash
bash scripts/capture_play_store_screenshots.sh
```

### What the script does
1. ✓ Checks ADB connection
2. ✓ Cleans and builds app
3. ✓ Runs app with SCREENSHOT_MODE=true (auto-seeds demo data)
4. ✓ Waits for app to launch
5. ✓ Captures 5 screenshots via adb screencap
6. ✓ Saves to `store_assets/screenshots/phone/`
7. ✓ Verifies all files

### Output
```
store_assets/screenshots/phone/
├── 01_home_dashboard.png
├── 02_create_stop_alarm.png
├── 03_alarm_session.png
├── 04_stop_receipt.png
└── 05_history_stats.png
```

## Troubleshooting

### "ADB not found"
```bash
export PATH=$PATH:~/Library/Android/sdk/platform-tools
# Or wherever your Android SDK is installed
```

### "No device found"
```bash
# Check connected devices
adb devices

# Or start emulator
emulator -avd Pixel_7_API_33 &
```

### Screenshot navigation issues
- Script uses button taps to navigate between screens
- If screen order is wrong, manually adjust in script
- Or manually navigate in app and tap "Capture Screenshot" if added

### App doesn't show demo data
- Ensure SCREENSHOT_MODE=true is being passed
- Check app logs: `adb logcat`
- Manually check Hive database: Look for demo_alarm_1, demo_session_1, demo_receipt_1

## Verify Screenshots

After running script:
```bash
# View files
ls -lh store_assets/screenshots/phone/

# Open in Preview (macOS)
open store_assets/screenshots/phone/

# Check image info
file store_assets/screenshots/phone/*.png

# Verify dimensions (should be 1080x1920)
identify store_assets/screenshots/phone/*.png
```

## Next Steps

1. **Review screenshots** — ensure they look good and show real UI
2. **Upload to Google Play Console** — App Content → Screenshots → Phone (portrait)
3. **Preview** — check how they look in different devices
4. **Publish** — submit app with screenshots

## See Also

- `store_assets/screenshots/README.md` — Full documentation
- `lib/debug/store_screenshot_seed.dart` — Demo data structure
- `scripts/capture_play_store_screenshots.sh` — Script source
