#!/bin/bash
set -eu
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
test_dir="$(mktemp -d /tmp/soccerbeat-route-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
frameworks="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/Library/Frameworks"
swift_support="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/usr/lib"
xcrun swiftc -F "$frameworks" -I "$swift_support" -L "$swift_support" -lXCTestSwiftSupport \
    -Xlinker -rpath -Xlinker "$frameworks" -Xlinker -rpath -Xlinker "$swift_support" \
    -Xlinker -rpath -Xlinker "$frameworks/../PrivateFrameworks" \
    "$repo_root/SoccerBeat/Common/Data/HeatmapDensity.swift" \
    "$repo_root/SoccerBeat/SoccerBeat/Sources/Features/MatchRecords/Subviews/RouteTimeline.swift" \
    "$repo_root/SoccerBeat/RouteTimelineTests/RouteTimelineTests.swift" \
    -o "$test_dir/route-tests"
"$test_dir/route-tests"
