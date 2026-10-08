#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
validation_dir="$(mktemp -d "${TMPDIR:-/tmp}/appsupport-validation.XXXXXX")"
python3 Scripts/check-localizations.py
swift test -j 2 -Xswiftc -warnings-as-errors
for validation_platform in iOS macOS; do
  validation_log="$validation_dir/$validation_platform.log"
  if ! xcodebuild -jobs 2 -scheme AppSupportUI -configuration Debug \
    -destination "generic/platform=$validation_platform" \
    -derivedDataPath "$validation_dir/$validation_platform" \
    SWIFT_VERSION=6 SWIFT_STRICT_CONCURRENCY=complete \
    SWIFT_TREAT_WARNINGS_AS_ERRORS=YES CODE_SIGNING_ALLOWED=NO \
    build > "$validation_log" 2>&1; then
    tail -n 100 "$validation_log"
    exit 1
  fi
  tail -n 3 "$validation_log"
done
printf 'Validation logs: %s\n' "$validation_dir"
