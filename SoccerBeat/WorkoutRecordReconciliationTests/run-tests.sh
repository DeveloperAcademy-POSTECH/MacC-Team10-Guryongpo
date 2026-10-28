#!/bin/bash
set -eu
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
test_dir="$(mktemp -d /tmp/soccerbeat-record-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
frameworks="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/Library/Frameworks"
swift_support="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/usr/lib"
xcrun swiftc -F "$frameworks" -I "$swift_support" -L "$swift_support" -lXCTestSwiftSupport \
    -Xlinker -rpath -Xlinker "$frameworks" -Xlinker -rpath -Xlinker "$swift_support" \
    -Xlinker -rpath -Xlinker "$frameworks/../PrivateFrameworks" \
    "$repo_root/SoccerBeat/Common/Utiles/Double+extension.swift" \
    "$repo_root/SoccerBeat/Common/Data/HeatmapDensity.swift" \
    "$repo_root/SoccerBeat/Common/Data/WorkoutData.swift" \
    "$repo_root/SoccerBeat/Common/Data/WorkoutData+Reconciliation.swift" \
    "$repo_root/SoccerBeat/SoccerBeat/Sources/Features/MatchRecords/ViewControllers/DataConverter.swift" \
    "$repo_root/SoccerBeat/WorkoutRecordReconciliationTests/WorkoutRecordReconciliationTests.swift" \
    -o "$test_dir/record-tests"
"$test_dir/record-tests"
