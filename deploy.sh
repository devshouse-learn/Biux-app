#!/bin/bash
set -e

LANE="${1:-version_info}"
BIUX_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_PATH="$BIUX_PATH/ios"

cd "$IOS_PATH" && /opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane "$LANE"
