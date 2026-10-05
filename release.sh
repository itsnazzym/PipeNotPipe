#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/PipePipeClient"
for key in KEY_PATH KEY_STORE_PASSWORD KEY_ALIAS KEY_PASSWORD; do
  if [[ -z "${!key:-}" ]]; then
    echo "Missing release signing variable: $key" >&2
    exit 1
  fi
done
./gradlew :core:cache:test :data:media:test :app:assembleRelease :app:lintRelease --console=plain
echo 'Signed APKs: PipePipeClient/app/build/outputs/apk/release'
