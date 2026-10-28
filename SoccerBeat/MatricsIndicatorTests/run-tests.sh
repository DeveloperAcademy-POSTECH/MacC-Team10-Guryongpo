#!/bin/bash
set -eu
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
test_dir="$(mktemp -d /tmp/soccerbeat-matrics-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
frameworks="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/Library/Frameworks"
swift_support="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/usr/lib"
xcrun swiftc -swift-version 5 -F "$frameworks" -I "$swift_support" -L "$swift_support" -lXCTestSwiftSupport \
    -Xlinker -rpath -Xlinker "$frameworks" -Xlinker -rpath -Xlinker "$swift_support" \
    -Xlinker -rpath -Xlinker "$frameworks/../PrivateFrameworks" \
    "$repo_root/SoccerBeat/SoccerBeat Watch App/Sources/WorkoutManager/MatricsIndicator.swift" \
    "$repo_root/SoccerBeat/Common/Data/PeakPower.swift" \
    "$repo_root/SoccerBeat/Common/Utiles/Double+extension.swift" \
    "$repo_root/SoccerBeat/MatricsIndicatorTests/MatricsIndicatorTests.swift" \
    -o "$test_dir/matrics-tests"
"$test_dir/matrics-tests"
