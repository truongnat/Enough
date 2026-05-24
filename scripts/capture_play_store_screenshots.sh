#!/bin/bash

set -e

echo "🎬 Google Play Store Screenshot Capture Script"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCREENSHOT_FOLDER="store_assets/screenshots/phone"
ANDROID_SCREENSHOT_PATH="/sdcard/Pictures"
DEVICE_TIMEOUT=40
SCREENSHOT_MODE="true"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Check ADB and devices
log_info "Checking ADB connection and devices..."
if ! command -v adb &> /dev/null; then
    log_error "ADB not found. Make sure Android SDK is installed and in PATH."
    echo "  Hint: Add to PATH: export PATH=\$PATH:~/Library/Android/sdk/platform-tools"
    exit 1
fi

DEVICES=$(adb devices | grep -E '^\S+\s+device$' | awk '{print $1}')
if [ -z "$DEVICES" ]; then
    log_error "No Android device or emulator found."
    echo "  Run: adb devices"
    echo "  Or start emulator: emulator -avd Pixel_7_API_33"
    exit 1
fi

DEVICE=$(echo "$DEVICES" | head -1)
log_success "Found device: $DEVICE"

# Check device resolution
RESOLUTION=$(adb -s "$DEVICE" shell wm size 2>/dev/null | grep -o '[0-9]*x[0-9]*' || echo "unknown")
log_info "Device resolution: $RESOLUTION (recommended: 1080x1920)"
echo ""

# 2. Clean and prepare
log_info "Cleaning and preparing build..."
flutter clean > /dev/null 2>&1 || true
flutter pub get > /dev/null 2>&1 || flutter packages get > /dev/null 2>&1

log_success "Build preparation complete"
echo ""

# 3. Build and run app with SCREENSHOT_MODE
log_info "Building and running app in SCREENSHOT_MODE..."
log_warning "This will take 1-2 minutes on first run..."

# Kill any existing flutter run process
pkill -f "flutter run" 2>/dev/null || true
sleep 2

# Start app in release/profile mode for better performance
flutter run \
    -d "$DEVICE" \
    -t lib/main.dart \
    --dart-define=SCREENSHOT_MODE=true \
    --release \
    > /tmp/flutter_run.log 2>&1 &

FLUTTER_PID=$!

# Wait for app to launch
log_info "Waiting for app to launch (timeout: ${DEVICE_TIMEOUT}s)..."
WAIT_COUNT=0
APP_RUNNING=0
while [ $WAIT_COUNT -lt $DEVICE_TIMEOUT ]; do
    # Check if app is running
    if adb -s "$DEVICE" shell pidof com.truongdev.reverse_alarm > /dev/null 2>&1; then
        log_success "App is running"
        APP_RUNNING=1
        break
    fi
    WAIT_COUNT=$((WAIT_COUNT + 1))
    sleep 1
done

if [ $WAIT_COUNT -ge $DEVICE_TIMEOUT ]; then
    log_warning "App launch timeout"
fi

# Extra wait for app initialization and demo data seeding
log_info "Waiting for app initialization..."
sleep 5

echo ""

# Helper function to capture screenshot
capture_screenshot() {
    local filename=$1
    local wait_secs=${2:-2}

    log_info "Capturing: $filename"
    sleep "$wait_secs"

    REMOTE_PATH="${ANDROID_SCREENSHOT_PATH}/${filename}"

    # Remove old screenshot if exists
    adb -s "$DEVICE" shell rm -f "$REMOTE_PATH" 2>/dev/null || true

    # Capture screenshot
    if ! adb -s "$DEVICE" shell screencap -p "$REMOTE_PATH"; then
        log_error "Failed to capture screenshot on device"
        return 1
    fi

    # Pull to local folder
    mkdir -p "$SCREENSHOT_FOLDER"
    if ! adb -s "$DEVICE" pull "$REMOTE_PATH" "$SCREENSHOT_FOLDER/$filename" > /dev/null 2>&1; then
        log_error "Failed to pull screenshot from device"
        return 1
    fi

    # Verify file exists and has size > 0
    if [ -f "$SCREENSHOT_FOLDER/$filename" ]; then
        SIZE=$(stat -f%z "$SCREENSHOT_FOLDER/$filename" 2>/dev/null || stat -c%s "$SCREENSHOT_FOLDER/$filename" 2>/dev/null)
        if [ "$SIZE" -gt 0 ]; then
            log_success "Saved: $filename ($(du -h "$SCREENSHOT_FOLDER/$filename" | awk '{print $1}'))"
            return 0
        else
            log_error "Screenshot is empty: $filename"
            return 1
        fi
    else
        log_error "Failed to save: $filename"
        return 1
    fi
}

# Helper to tap button on screen (with coordinate scaling)
tap_screen() {
    local x=$1
    local y=$2
    local width=${3:-1080}
    local height=${4:-1920}
    local wait_after=${5:-2}  # Wait time after tap for transition

    # Scale coordinates to actual device resolution
    local actual_width=$(echo "$RESOLUTION" | cut -d'x' -f1)
    local actual_height=$(echo "$RESOLUTION" | cut -d'x' -f2)
    local scaled_x=$((x * actual_width / width))
    local scaled_y=$((y * actual_height / height))

    log_info "Tapping screen at ($scaled_x, $scaled_y) [scaled from ($x, $y) for ${width}x${height}]"
    adb -s "$DEVICE" shell input tap "$scaled_x" "$scaled_y"
    sleep "$wait_after"
}

# 4. Capture screenshots
echo ""
log_info "Starting screenshot capture sequence..."
echo ""

# 4.1 Home Dashboard (already visible, just capture)
capture_screenshot "01_home_dashboard.png" 2
sleep 1

# 4.2 Create Stop Alarm - tap FAB button (center)
log_info "Navigating to Create Alarm..."
tap_screen 540 1920 1080 1920 3  # Center bottom where FAB is positioned
sleep 1
capture_screenshot "02_create_stop_alarm.png" 3
sleep 1

# Go back to home
log_info "Going back to home..."
adb -s "$DEVICE" shell input keyevent KEYCODE_BACK
sleep 3

# 4.3 Alarm Session - navigate to history tab first, then tap on first item
log_info "Navigating to History tab..."
tap_screen 270 1850 1080 1920 3  # History tab (second from left)
sleep 2
# Tap on first history item
log_info "Tapping on first history item..."
tap_screen 540 960 1080 1920 3
capture_screenshot "03_alarm_session.png" 3
sleep 1

# Go back
adb -s "$DEVICE" shell input keyevent KEYCODE_BACK
sleep 2

# 4.4 Stop Receipt - navigate to receipt detail from history
log_info "Navigating to receipt detail..."
sleep 1
tap_screen 540 960 1080 1920 3  # Tap on first receipt
capture_screenshot "04_stop_receipt.png" 3
sleep 1

# Go back
adb -s "$DEVICE" shell input keyevent KEYCODE_BACK
sleep 2

# 4.5 Stats - navigate via stats tab
log_info "Navigating to Stats tab..."
tap_screen 810 1850 1080 1920 3  # Stats tab (third from left)
sleep 2
capture_screenshot "05_history_stats.png" 3

echo ""

# 5. Verify all screenshots exist
log_info "Verifying screenshot files..."
MISSING=0
for file in "01_home_dashboard.png" "02_create_stop_alarm.png" "03_alarm_session.png" "04_stop_receipt.png" "05_history_stats.png"; do
    if [ -f "$SCREENSHOT_FOLDER/$file" ]; then
        log_success "✓ $file"
    else
        log_error "✗ $file (MISSING)"
        MISSING=$((MISSING + 1))
    fi
done

echo ""

if [ $MISSING -eq 0 ]; then
    log_success "All 5 screenshots captured successfully!"
    echo ""
    echo "📁 Screenshots saved to: $(pwd)/$SCREENSHOT_FOLDER"
    echo ""
    ls -lh "$SCREENSHOT_FOLDER"/*.png 2>/dev/null || true
else
    log_error "$MISSING screenshot(s) are missing"
    log_warning "You may need to manually adjust navigation taps in the script"
fi

echo ""
log_info "Stopping flutter run..."
kill $FLUTTER_PID 2>/dev/null || true
wait $FLUTTER_PID 2>/dev/null || true
pkill -f "flutter run" 2>/dev/null || true

echo ""
log_success "Done! Screenshots are ready for Google Play Store"
log_info "Recommended emulator: Pixel 7 / Pixel 8 with 1080x1920 resolution"
log_info "Next: Review screenshots in $SCREENSHOT_FOLDER and upload to Google Play Console"
