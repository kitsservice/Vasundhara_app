@echo off
echo Building Optimized Android App Bundle (AAB) for Play Store...
call flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
echo Done!

echo Building Optimized Android APK for direct distribution...
call flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --split-per-abi
echo Done!

echo Your optimized release files are located in build/app/outputs/
pause
