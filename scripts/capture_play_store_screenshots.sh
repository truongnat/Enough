#!/bin/bash
set -e

echo "🎬 Google Play Store Screenshot Capture Script"
echo "=============================================="
echo ""

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }

# ── Config ────────────────────────────────────────────────────────────────────
PACKAGE_NAME="com.truongnat.enough"
ANDROID_SCREENSHOT_PATH="/sdcard/Pictures"
DEVICE_TIMEOUT=90

# Device profiles: name|avd_name|folder|width|height
DEVICE_PROFILES=(
  "phone|Pixel_10_Pro_XL|store_assets/screenshots/phone|1080|1920"
  "tablet_7inch|Tablet_7inch|store_assets/screenshots/tablet_7inch|1200|1920"
  "tablet_10inch|Tablet_10inch|store_assets/screenshots/tablet_10inch|1600|2560"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

wait_for_app() {
  local device=$1
  local timeout=$2
  local count=0
  log_info "Waiting for app to launch (timeout: ${timeout}s)..."
  while [ $count -lt $timeout ]; do
    if adb -s "$device" shell pidof "$PACKAGE_NAME" > /dev/null 2>&1; then
      log_success "App is running"
      return 0
    fi
    count=$((count + 1))
    sleep 1
  done
  log_warning "App launch timeout - proceeding anyway"
  return 1
}

capture_screenshot() {
  local device=$1; local folder=$2; local filename=$3; local wait_secs=${4:-2}
  log_info "Capturing: $filename"
  sleep "$wait_secs"
  local remote="${ANDROID_SCREENSHOT_PATH}/${filename}"
  adb -s "$device" shell rm -f "$remote" 2>/dev/null || true
  adb -s "$device" shell screencap -p "$remote"
  mkdir -p "$folder"
  adb -s "$device" pull "$remote" "$folder/$filename" > /dev/null 2>&1
  if [ -f "$folder/$filename" ]; then
    local size; size=$(stat -f%z "$folder/$filename" 2>/dev/null || stat -c%s "$folder/$filename")
    if [ "$size" -gt 0 ]; then
      log_success "Saved: $filename ($(du -h "$folder/$filename" | awk '{print $1}'))"
      return 0
    fi
  fi
  log_error "Failed: $filename"; return 1
}

# Tap with coordinate scaling from base 1080x1920 → actual resolution
tap() {
  local device=$1; local x=$2; local y=$3; local res=$4; local wait=${5:-2}
  local actual_w; actual_w=$(echo "$res" | cut -d'x' -f1)
  local actual_h; actual_h=$(echo "$res" | cut -d'x' -f2)
  local sx=$((x * actual_w / 1080))
  local sy=$((y * actual_h / 1920))
  log_info "Tap ($sx,$sy) scaled from ($x,$y)"
  adb -s "$device" shell input tap "$sx" "$sy"
  sleep "$wait"
}

back() {
  local device=$1; local wait=${2:-2}
  adb -s "$device" shell input keyevent KEYCODE_BACK
  sleep "$wait"
}

# ── Screenshot sequence per device ────────────────────────────────────────────
# Coordinates are in 1080x1920 normalized space.
# Nav bar item centers (measured from actual 1344x2992 phone, normalized):
#   Home:     x=169  y=1801
#   History:  x=357  y=1801
#   FAB(+):   x=540  y=1759
#   Stats:    x=723  y=1801
#   Settings: x=911  y=1801
# History list first item center: x=540, y=485

capture_all_screens() {
  local device=$1; local folder=$2; local res=$3
  echo ""
  log_info "=== Capturing screenshots for: $folder ==="
  echo ""

  # Restart app cleanly
  adb -s "$device" shell am force-stop "$PACKAGE_NAME" 2>/dev/null || true
  sleep 1
  adb -s "$device" shell am start -n "${PACKAGE_NAME}/.MainActivity"
  wait_for_app "$device" "$DEVICE_TIMEOUT"
  log_info "Waiting for app initialization and demo data seed..."
  sleep 6

  # ── 01 Home Dashboard ─────────────────────────────────────────────────────
  capture_screenshot "$device" "$folder" "01_home_dashboard.png" 2

  # ── 02 Create Stop Alarm (via FAB) ────────────────────────────────────────
  log_info "→ Navigating to Create Alarm..."
  tap "$device" 540 1759 "$res" 3
  capture_screenshot "$device" "$folder" "02_create_stop_alarm.png" 2
  back "$device" 3

  # ── 03 History screen ─────────────────────────────────────────────────────
  log_info "→ Navigating to History tab..."
  tap "$device" 357 1801 "$res" 3
  capture_screenshot "$device" "$folder" "03_history.png" 2

  # ── 04 Receipt Detail (tap first history item) ────────────────────────────
  log_info "→ Tapping first history item..."
  tap "$device" 540 485 "$res" 3
  capture_screenshot "$device" "$folder" "04_stop_receipt.png" 2
  back "$device" 2

  # ── 05 Stats ──────────────────────────────────────────────────────────────
  log_info "→ Navigating to Stats tab..."
  tap "$device" 723 1801 "$res" 3
  capture_screenshot "$device" "$folder" "05_stats.png" 2

  echo ""
  log_info "Verifying files in $folder..."
  local missing=0
  for f in "01_home_dashboard.png" "02_create_stop_alarm.png" "03_history.png" "04_stop_receipt.png" "05_stats.png"; do
    if [ -f "$folder/$f" ]; then log_success "✓ $f"
    else log_error "✗ $f MISSING"; missing=$((missing + 1)); fi
  done

  if [ $missing -eq 0 ]; then
    log_success "All 5 screenshots captured for $(basename "$folder")!"
  else
    log_error "$missing screenshot(s) missing"
  fi
}

# ── Start emulator and wait ───────────────────────────────────────────────────
EMU_PID=""

start_emulator() {
  local avd=$1
  log_info "Starting emulator: $avd..."
  pkill -f "qemu.*$avd" 2>/dev/null || true
  sleep 3

  ~/Library/Android/sdk/emulator/emulator \
    -avd "$avd" -no-snapshot-load -no-audio -no-window > /tmp/emu_"${avd}".log 2>&1 &
  EMU_PID=$!

  log_info "Waiting for emulator to boot (up to 120s)..."
  local timeout=120; local count=0
  while [ $count -lt $timeout ]; do
    local dev; dev=$(adb devices 2>/dev/null | grep -E 'emulator.*\bdevice\b' | awk '{print $1}' | head -1)
    if [ -n "$dev" ]; then
      local done; done=$(adb -s "$dev" shell getprop sys.boot_completed 2>/dev/null | tr -d '[:space:]')
      if [ "$done" = "1" ]; then
        log_success "Emulator booted: $dev"
        sleep 3
        return 0
      fi
    fi
    count=$((count + 1))
    sleep 1
  done
  log_error "Emulator boot timeout"
}

get_device_serial() {
  adb devices 2>/dev/null | grep -E 'emulator.*\bdevice\b' | awk '{print $1}' | head -1
}

# ── Main ──────────────────────────────────────────────────────────────────────

# Check ADB
if ! command -v adb &> /dev/null; then
  log_error "ADB not found. Add to PATH: export PATH=\$PATH:~/Library/Android/sdk/platform-tools"
  exit 1
fi

# Build app (release with SCREENSHOT_MODE)
log_info "Building release APK with SCREENSHOT_MODE=true..."
cd "$(dirname "$0")/.." || exit 1
flutter clean > /dev/null 2>&1 || true
flutter pub get > /dev/null 2>&1
flutter build apk --release --dart-define=SCREENSHOT_MODE=true 2>&1 | tail -3
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  log_error "APK not found: $APK_PATH"
  exit 1
fi
log_success "APK built: $APK_PATH"
echo ""

# ── Capture per device profile ────────────────────────────────────────────────
TARGET=${1:-"all"}   # Usage: ./script.sh [all|phone|tablet_7inch|tablet_10inch]

for profile in "${DEVICE_PROFILES[@]}"; do
  IFS='|' read -r name avd folder base_w base_h <<< "$profile"

  # Skip if not target
  if [ "$TARGET" != "all" ] && [ "$TARGET" != "$name" ]; then
    continue
  fi

  echo ""
  log_info "════════════════════════════════════════"
  log_info "Device: $name ($avd)"
  log_info "════════════════════════════════════════"

  # Start emulator
  start_emulator "$avd"
  sleep 2
  DEVICE=$(get_device_serial)
  if [ -z "$DEVICE" ]; then
    log_error "No emulator found after boot"; continue
  fi
  log_success "Device: $DEVICE"

  # Get actual resolution
  RESOLUTION=$(adb -s "$DEVICE" shell wm size 2>/dev/null | grep -o '[0-9]*x[0-9]*' || echo "${base_w}x${base_h}")
  log_info "Resolution: $RESOLUTION"

  # Install APK
  log_info "Installing APK..."
  adb -s "$DEVICE" install -r "$APK_PATH" > /dev/null 2>&1
  log_success "APK installed"

  # Capture screenshots
  capture_all_screens "$DEVICE" "$folder" "$RESOLUTION"

  # Stop emulator
  log_info "Stopping emulator..."
  adb -s "$DEVICE" emu kill 2>/dev/null || true
  [ -n "$EMU_PID" ] && kill "$EMU_PID" 2>/dev/null || true
  sleep 3
done

echo ""
log_success "Done! All screenshots ready for Google Play Store"
echo ""
echo "📁 Folders:"
for profile in "${DEVICE_PROFILES[@]}"; do
  IFS='|' read -r name avd folder base_w base_h <<< "$profile"
  if [ "$TARGET" = "all" ] || [ "$TARGET" = "$name" ]; then
    echo "   $name → $(pwd)/$folder"
    ls -lh "$folder"/*.png 2>/dev/null || true
  fi
done
