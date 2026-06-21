#!/usr/bin/env bash
# List each /Applications app and whether its binary is arm64 / x86_64 / universal.

for APP in /Applications/*.app; do
  BIN=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist" 2>/dev/null) || continue
  OUT=$(file "$APP/Contents/MacOS/$BIN" 2>/dev/null || true)
  echo "$(basename "$APP") : $OUT"
done | sed -E 's/^([^:]+) : .* (arm64|x86_64|universal).*$/\1 : \2/i'
