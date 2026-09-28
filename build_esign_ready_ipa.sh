#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT/build"
ARCHIVE="$BUILD_DIR/HYperRegedit-original-identity.xcarchive"
IPA="$BUILD_DIR/HYper-Regedit-Key-Enabled-unsigned.ipa"
LOG="$BUILD_DIR/xcodebuild.log"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

command -v xcodebuild >/dev/null || {
    echo "xcodebuild is required on macOS" >&2
    exit 127
}

echo "========================================"
echo "Xcode version"
echo "========================================"
xcodebuild -version

echo
echo "========================================"
echo "Building OGIOS"
echo "========================================"

set +e

xcodebuild \
    -project "$ROOT/ThreeOneOSFive.xcodeproj" \
    -scheme OGIOS \
    -configuration Release \
    -sdk iphoneos \
    -archivePath "$ARCHIVE" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    archive \
    2>&1 | tee "$LOG"

BUILD_STATUS=${PIPESTATUS[0]}

set -e

echo
echo "========================================"
echo "xcodebuild exit code: $BUILD_STATUS"
echo "========================================"

if [ "$BUILD_STATUS" -ne 0 ]; then
    echo
    echo "========================================"
    echo "BUILD ERRORS"
    echo "========================================"

    grep -nE \
        "error:|fatal error:|Command .* failed|SwiftCompile|CompileSwift|\([0-9]+ failures\)" \
        "$LOG" || true

    echo
    echo "========================================"
    echo "LAST 150 LOG LINES"
    echo "========================================"

    tail -n 150 "$LOG"

    exit "$BUILD_STATUS"
fi

APP="$ARCHIVE/Products/Applications/OGIOS.app"

if [ ! -d "$APP" ]; then
    echo "ERROR: OGIOS.app was not found:"
    echo "$APP"
    exit 1
fi

echo
echo "========================================"
echo "Preparing IPA"
echo "========================================"

PATCH_DIR="$APP/Patches"
mkdir -p "$PATCH_DIR"

for package in "$APP"/*.3105; do
    [ -e "$package" ] || continue
    mv "$package" "$PATCH_DIR/"
done

/usr/libexec/PlistBuddy \
    -c "Set :CFBundleExecutable OGIOS" \
    "$APP/Info.plist" || true

/usr/libexec/PlistBuddy \
    -c "Set :CFBundlePackageType APPL" \
    "$APP/Info.plist" || true

mkdir -p "$BUILD_DIR/Payload"

cp -R "$APP" "$BUILD_DIR/Payload/"

(
    cd "$BUILD_DIR"
    /usr/bin/zip -qry "$IPA" Payload
    rm -rf Payload
)

if [ ! -f "$IPA" ]; then
    echo "ERROR: IPA was not created"
    exit 1
fi

echo
echo "========================================"
echo "BUILD SUCCESS"
echo "========================================"
echo "IPA:"
echo "$IPA"
echo
echo "Archive:"
echo "$ARCHIVE"