#!/bin/bash
set -e

echo "=== 🚀 Building NeonPulse for iOS ==="

mkdir -p build

echo "Step 1: Building Xcode Archive..."
xcodebuild archive \
  -project NeonPulse.xcodeproj \
  -scheme NeonPulse \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/NeonPulse.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

echo "Step 2: Packaging into .ipa..."
rm -rf build/Payload build/NeonPulse.ipa
mkdir -p build/Payload
cp -r build/NeonPulse.xcarchive/Products/Applications/NeonPulse.app build/Payload/
cd build
zip -qr NeonPulse.ipa Payload
cd ..

echo "=== ✅ Done! IPA generated at build/NeonPulse.ipa ==="
ls -lh build/NeonPulse.ipa
