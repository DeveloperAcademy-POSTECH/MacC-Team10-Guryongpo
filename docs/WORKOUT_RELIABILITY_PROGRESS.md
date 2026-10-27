# 운동 데이터 안정화 작업 진행 기록

갱신일: 2026-10-27 (America/New_York)

## 작업 범위와 보존 상태

- 브랜치: `fix/workout-data-reliability`
- 시작 커밋: `613389d` (`develop`의 1.4.2 수정 병합)
- 이전 세션 변경을 보존해 P0 코드 검토, P1 저장·조회 수정, P3 속도·거리 표시 수정을 로컬 커밋했다. P2 빌드·자동 테스트·모의 데이터 UI 검증은 완료했고, 실제 장치 검증은 남아 있다.
- 기존 사용자 변경: `Common/Resource/Localizable.xcstrings`, `SoccerBeat.xcodeproj/project.pbxproj`의 번역·정렬·서명·버전 설정. 덮어쓰거나 되돌리지 않는다.
- 이전 세션 시작 시 보관한 비교 기준: `/tmp/soccerbeat-reliability-baseline/`. 커밋에는 이 기준 이후의 이번 작업 변경만 선별한다.
- 기존 HealthKit 운동·샘플은 복구를 위해 삭제하지 않는다. 새 복구 저널은 앱의 별도 로컬 파일이다.
- 단계별 로컬 커밋은 허용됨. 푸시·병합·PR 생성은 하지 않는다.

## 확인된 버그와 근본 원인

| 항목 | 코드에서 확인한 원인 | 확실성 |
| --- | --- | --- |
| 완료 직후 기록 손실 위험 | `showingSummaryView.didSet`의 초기화와 비동기 `endWorkoutSession`이 같은 mutable builder/metrics를 사용했다. 종료 화면은 저장 결과 대신 3초 후 완료 버튼을 표시했다. | 높음: 코드상 경합. 첨부 사례 각각의 원인은 미확정 |
| 경로 저장 실패·누락 | `insertRouteData` 완료를 기다리지 않은 채 `finishRoute` 실행. 오류는 `try?`로 소실되며 복구용 원본이 없었다. | 높음 |
| 메타데이터 저장 실패 위험 | `Double.rounded(at:) -> String` 확장과 숫자 변환이 충돌하여 `Int?`/`Double?`가 `Any`에 들어갔다. 기존 Calories 구성은 binary property-list 직렬화에 실패한다. | 타입·직렬화 결함 확인. 실제 HealthKit 실패 기기 재현은 미실시 |
| 건강 앱에는 심박이 있으나 차트 없음 | iPhone 변환은 문자열 메타데이터만 읽고 실제 심박 샘플을 조회하지 않았다. | 높음 |
| 경로 일부만 읽힘 | 첫 번째 `HKWorkoutRoute`만 조회. 부분 오류와 workout/route 메타데이터 병합이 부정확했다. | 높음 |
| 현재 속도 0, 최고속도 유지 | 잘못된 GPS 측정에서 detector의 `pause()`가 현재 속도를 0으로 만들고 최고속도는 유지했다. 콜백 중단 시 freshness 확인도 없었다. | 높음 |
| 늦게 동기화된 정보가 상세에 반영되지 않음 | 매 조회마다 새 UUID 생성, 상세 화면은 전달받은 값만 보유, 지도 모델은 최초 데이터로 캐시됐다. | 높음 |
| 새 관찰·재조회와 프로필 평균 충돌 | `ProfileModel.calculateAverageAbility`가 이전 평균을 초기화하지 않고 다시 더했다. 반복 조회 시 값이 누적된다. | 높음. 재개 후 순수 집계 함수로 수정, 회귀 테스트 통과 |

## 이전 세션 변경 검토 및 수정 완료 항목

- 워치 저장: 세션/빌더 보유 컨텍스트, `.stopped` 이후 수집 종료·메타데이터·운동·경로 순서 처리, 직렬 경로 입력, 저장 상태 표시.
- `WorkoutRecoveryStore`: 신규 세션의 실제 GPS·메타데이터를 별도 파일에 보관. 저장 시도 의도를 기록하여 모호한 완료에 대한 무조건 재시도를 방지.
- 메타데이터: native 숫자 타입과 실제 관찰 여부 플래그 사용. 누락을 성공한 0 측정으로 취급하지 않음.
- iPhone: 실제 심박 조회, 운동 연결/동일 출처·시간 범위 확인, 모든 경로 조회, 안정적인 workout UUID, 부분 데이터 캐시 보존, HealthKit 변화 관찰.
- UI: 늦은 데이터로 상세 갱신, 경로/심박 부재 안내, 누락 수치 `--`, 실제 심박 시각 사용, 공유 수치에도 누락 반영.
- 속도: 유효한 현재 속도와 최고속도 분리, 시간 경과 시 unavailable 표시, 정상 GPS 도착 시 회복.
- 워치 Dist: 활성/종료 화면 소수점 한 자리.

## 수정된 주요 파일·함수

- `Common/Data/WorkoutManager.swift`: 저장 상태/세션 컨텍스트, iPhone 관찰·캐시 상태, 종료 화면 초기화 경계.
- `Common/Data/WorkoutData.swift`: 센서별 가용성, 실제 심박 시각, 누락 표시용 플래그.
- `Common/Data/WorkoutRecoveryStore.swift`: 저널/실제 위치 파일 저장, 저장 시도 claim, 완료 확인 후 중복 백업 정리.
- `Common/Data/WorkoutData+Reconciliation.swift`: 메타데이터·거리 선택, 부분 조회 결과 병합.
- `SoccerBeat Watch App/Sources/WorkoutManager/WorkoutManager_Watch.swift`: `startWorkout`, `endWorkoutSession`, `beginFinalization`, 위치 delegate, 복구 조회.
- `SoccerBeat Watch App/Sources/WorkoutManager/MatricsIndicator.swift`: `getMetadata`, 통계 반영, 측정 여부 플래그.
- `SoccerBeat Watch App/Sources/WorkoutManager/SprintDetector.swift`: `currentSpeed(at:)`와 invalid/stale 처리.
- `SoccerBeat Watch App/Sources/Features/EndRecording/SummaryView.swift`: 저장 결과 안내, 완료/닫기 제한, 거리 표시.
- `SoccerBeat Watch App/Sources/Features/Progress/`: 현재 속도와 거리 표시.
- `SoccerBeat/Sources/WorkoutManager_Phone/WorkoutManager_Phone+Extensions.swift`: 변환·심박/경로 조회·관찰·재조회·캐시.
- `SoccerBeat/Sources/Features/MatchRecords/`: 상세 갱신, 부분 수치/지도/심박 안내와 차트 축.
- `SoccerBeat/Sources/Features/Share/ShareMatchView.swift`: 누락 수치를 0으로 공유하지 않도록 변경.
- 프로젝트 파일: 신규 공통 helper의 iPhone/watch 타깃 등록만 이번 작업 범위.

## 검증 기록

### 재개 시 확인한 이전 결과

- Reconciliation 테스트: 23개 통과 (`/tmp/soccerbeat-record-tests.log`).
- Recovery 테스트: 11개 통과 (`/tmp/soccerbeat-recovery-tests.log`).
- 속도 테스트 27개, 실제 Matrics 메타데이터 테스트 7개 통과 보고가 있었음. 재개 후 현 소스로 재실행 예정.
- 이전 전체 빌드 실패: `finishRoute`의 non-optional 반환값을 `if let`으로 처리한 오류. 재개 시 이미 소스가 수정되어 있었으며 아래 전체 빌드로 해결을 확인했다.
- 재개 직후 전체 빌드 성공: `/tmp/soccerbeat-reliability-resume-build.log`.
- 실기기 HealthKit 저장·동기화·백그라운드 검증: 수행하지 않음.

### 재개 후 검증 완료

- 현재 소스 iOS·watchOS 전체 빌드 성공: `/tmp/soccerbeat-reliability-final-build.log`.
- Matrics 실제 메타데이터/통계 테스트: 7개 통과.
- 로컬 복구 저널/중복 claim 테스트: 11개 통과.
- native SprintDetector/PeakPower 테스트: 27개 통과.
- 부분 기록 병합·반복 평균 집계 테스트: 26개 통과.
- `showingSummaryView` 초기화 경계를 `canDismissWorkoutSummary`와 일치시켜 실패 상태의 세션을 조기 초기화하지 않도록 보완.
- 프로필 평균은 매 조회의 현재 스냅샷에서 다시 계산하며 누락 센서는 평균 분모에서 제외.
- 새 상태 문구 15개의 한국어·영어·스페인어·중국어 간체 컴파일 결과 검증.
- 기존 히트맵 테스트 12개, 경로 타임라인 테스트 25개 통과. 총 108개 자동 테스트 통과.
- 기존 사용자 번역과 프로젝트 설정이 비교 기준과 동일함을 검증. 신규 번역 키·소스 등록만 인덱스에 선별한다.
- 사용자 미커밋 변경을 제외한 `229e1c3`의 `git archive` 스냅샷으로 iOS·watchOS 전체 빌드 성공: `/tmp/soccerbeat-reliability-committed-build.log`. 코드 서명 없이 iOS Simulator 대상으로 빌드했다.

### 상세 화면 표시 검증 완료 (모의 데이터)

- iPhone 17 Pro / iOS 26.5 시뮬레이터에서 별도 임시 사본에만 테스트 진입점을 추가했다. 실제 작업 소스·커밋에는 테스트용 화면과 데이터가 포함되지 않는다.
- 경로·심박이 없는 부분 기록: 기본 바다 지도 대신 경로 부재 안내, 심박 부재 안내, 공유 비활성화 확인.
- 부분 기록의 Field Record: 실제 보유한 `0.2 km`, `37 kcal` 유지. 미측정 최고속도·스프린트·최소/최대 심박은 각각 `--`로 표시됨을 확인.
- 동일 운동 UUID의 추가 데이터를 실제 `fetchWorkoutsSuccess` publisher로 두 번 전달했다. 상세 화면을 닫지 않고 심박 90/110/130의 실제 테스트 시각별 차트, 경로 지도, 최고속도 14·스프린트 1·최소/최대 심박 90/130 표시로 갱신됨을 확인.
- 이 검증은 앱 내부의 데이터 도착·표시 경로를 시험했다. 실제 Watch→HealthKit→iPhone 동기화 성공을 검증한 것은 아니다. 사용한 시뮬레이터는 검증 후 종료했다.

## 미완료 및 다음 작업

1. 아래 실기기 수동 테스트를 개발자가 실제 장치에서 수행한다. 특히 운동·경로 finish 중 강제 종료, 저장 실패, 폰 재연결 후 동기화는 미검증이다.
2. 실패가 재현되면 동일 운동의 시작 시각·UUID, 단계별 오류 로그, 건강 앱에 존재하는 운동/경로/심박을 비교한다. 원본 기록을 삭제하지 않고 실패 경계를 확인한다.
3. 실기기 결과를 이 문서에 추가한 뒤 배포 여부를 판단한다. 이번 작업에서는 푸시·병합·배포하지 않는다.

## 복구 한계와 실기기 검증 항목

- HealthKit 운동 저장과 경로 저장은 별개다. 운동 저장 성공만으로 경로까지 완료됐다고 표시하지 않는다.
- finish 호출 결과가 모호한 경우 동일 운동/경로를 무조건 다시 만들지 않는다. 안정적인 식별자로 먼저 조회하며, 확인할 수 없으면 백업을 유지한다.
- 앱 종료로 소실된 미완료 `HKLiveWorkoutBuilder`를 로컬 GPS만으로 완전히 복원할 수 있다고 보장하지 않는다.
- 수집되지 않은 GPS·심박은 복구할 수 없다. 누락을 임의 좌표·심박·성공한 0으로 보충하지 않는다.
- HealthKit의 빈 읽기 결과만으로 읽기 권한 거부를 확정하지 않는다.
- 실기기 필수: 일반 완료, 즉시 완료 탭, GPS 단절 후 회복, 잠금/백그라운드, 폰 연결 해제 후 재연결, 저장 실패·재확인, 앱 재실행, 이전 운동 호환성, 부분 동기화 후 상세 자동 갱신.

## 관련 커밋

- `613389d`: 작업 시작 기준.
- `9bf0f98`: 중단 시점 진행 기록 생성.
- `1ace499`: 워치 저장 순서·복구 저널·메타데이터·속도 및 거리 표시 수정. 관련 테스트 45개 통과.
- `229e1c3`: iPhone 실제 심박·전체 경로 조회, 부분 데이터 보존, 상세 갱신, 평균 집계 및 상태 번역. 관련 테스트 26개 통과.


## 실기기 수동 테스트 절차 (미실시)

테스트 전 현재 앱/iOS/watchOS 버전과 테스트 시각을 기록한다. 실제 사용자 경기의 삭제·재설치로 복구를 시도하지 않는다.

1. **일반 야외 운동**: iPhone과 Watch에서 권한을 확인하고 야외에서 GPS 준비 후 5분 이상 기록한다. 걷기와 짧은 달리기를 포함한다. 종료 즉시 완료 화면으로 이동해 저장 중에는 닫을 수 없는지 확인한다. 저장 확인 후 앱을 다시 열어 기록을 비교한다.
2. **Apple Health 비교**: 동일 시작/종료 시각의 운동에서 시간, 거리, 활동 에너지, 심박 샘플, 운동 경로를 각각 확인한다. 운동 객체가 있다는 사실만으로 경로 저장 성공을 판단하지 않는다. 사커비트의 심박 차트와 경로가 실제 샘플을 표시하는지 비교한다.
3. **GPS 일시 단절**: 안전한 장소에서 신호가 약해졌다가 회복되는 상황을 시험한다. 측정 불가 속도는 `--`로, 실제 유효한 정지 속도는 `0.0`으로 구분되는지 확인한다. 정상 신호 복귀 후 현재 속도가 회복되고 최고속도는 보존되는지 확인한다.
4. **잠금/백그라운드**: 운동 중 손목을 내리고 다른 화면으로 전환한 뒤 돌아온다. 저장 중 Watch 화면을 끄고 다시 열었을 때 상태가 유지되는지 확인한다. 저장 후 시간·경로·심박이 사라지지 않아야 한다.
5. **iPhone 연결 해제**: 테스트 운동 중 iPhone 연결을 끊고 Watch에서 종료·저장한다. 폰을 다시 연결해 건강 데이터 동기화 후 사커비트를 연다. 이미 상세 화면을 열어둔 상태에서도 추가 데이터가 표시되는지 확인한다. 운동 UUID 기준으로 중복 목록이 생기지 않아야 한다.
6. **부분 기록**: 위치/심박이 실제 없는 테스트 운동에서 남아 있는 시간·거리·칼로리는 계속 표시되어야 한다. 없는 센서는 `--`/안내로 표시되며, `[0,0]` 바다 지도나 임의 심박을 표시하지 않아야 한다.
7. **저장 실패/재확인**: 개발 빌드에서 HealthKit/로컬 파일 실패를 주입해 저장 실패·부분 저장을 시험한다. 확인 전 완료 표시가 없어야 하며, 재확인으로 workout/route 개수가 증가하면 안 된다. 저장이 확인되지 않았거나 유일한 복구본이 RAM에만 남았으면 컨텍스트를 초기화하지 않아야 한다.
8. **강제 종료 경계**: 테스트 전용 기록으로 저장 전/운동 저장 후 경로 저장 전/finish 응답 전의 종료를 각각 시험한다. 재실행 시 기존 저장 객체를 먼저 조회하고, 새 workout을 임의 생성하지 않아야 한다. 자동 복구 불가 시 저널이 유지되는지 개발 도구로 확인한다. 이 경계의 실제 동작은 아직 검증하지 않았다.
9. **이전 기록·반복 새로고침**: 기존 축구/사커비트 달리기 기록을 읽고 3회 이상 새로고침한다. 안정적인 UUID와 기존 유효 데이터가 유지되어야 하며 프로필 평균이 매번 변하면 안 된다. 과거 메타데이터-only 심박에는 임의 시간축을 붙이지 않는다.
10. **거리 표시**: 종료 화면의 약 0.20 km가 `0.2 km`로 표시되는지 확인한다. 내부 원본 거리의 소수 정밀도는 표시 반올림과 별개로 보존되어야 한다.

### 로그와 자동 테스트가 보장하지 않는 것

- `Workout metadata save failed`, `Route insertion failed`, `Workout saved, route/details pending`, `Workout route discovery failed`, `Workout heart-rate query failed`를 개발 로그에서 구분한다.
- 자동 테스트는 순수 속도 필터, 실제 메타데이터 구성, 복구 파일/claim, 데이터 병합과 집계를 검증한다. HealthKit 서버/장치의 실 저장, 시스템 동기화, OS에 의한 프로세스 종료까지 모킹해 검증한 것은 아니다.
- 재개 후 새 WatchConnectivity 동기화 시스템을 추가하지 않았다. 센서 저장·운동/경로 조회는 HealthKit이 담당하며 세션 미러링을 데이터 저장 완료로 간주하지 않는다.

## 추가 수정: Field Chart 레이아웃 (2026-10-27)

- Field Chart에서 상단 부분 데이터/Reload 배너를 제거했다. 다른 상세 페이지의 안내는 유지한다.
- 차트의 로딩 표시는 콘텐츠 높이를 차지하지 않는 overlay spinner로 변경했다. 로딩 전후 그래프 영역이 압축되지 않는다.
- `PlayerAbilityView`의 그래프가 부모 전체 높이를 차지한 뒤 범례를 추가하던 구조를 수정했다. `RadarViewController.viewDidLayoutSubviews`에서 실제 배정 크기에 맞춰 반경을 계산한다.
- Field Chart의 능력치 영역을 축소하고 심박 그래프에 최소 180pt 높이를 부여했다. 불필요한 하단 여백을 줄이고 페이지 점 영역은 별도로 확보한다. 작은 화면에서는 세로 스크롤로 전체 콘텐츠를 확인한다.
- 심박 시간축은 약 두 개의 눈금과 24시간제 시·분 표기로 간소화했다. 실제 샘플 시각은 변경하지 않는다.
- 빌드 성공: `/tmp/soccerbeat-chart-layout-build.log`, 최종 레이아웃을 포함한 임시 UI 사본 빌드 `/tmp/soccerbeat-chart-layout-ui-final-build.log`.
- iPhone 17 Pro/iOS 26.5: 모의 심박 데이터로 능력치·범례·심박 시간축·페이지 점이 분리됨과 로딩 표시 전후 레이아웃 유지 확인.
- iPhone SE 3세대/iOS 18.2: 범례와 그래프가 겹치지 않음을 확인. 임시 사본의 테스트 전용 스크롤 호출로 하단 시간축/BPM이 페이지 점 위에 표시됨을 확인했다. 자동화 도구의 스와이프 입력으로는 스크롤 동작을 확인하지 못했으므로 실제 터치 스크롤은 수동 검증 항목이다. 테스트용 진입점·스크롤 호출은 작업 소스에 포함하지 않았다.
- 지도 질문에 대한 코드 확인: 지도/경로 부재 안내는 원본 `route.isEmpty`를 기준으로 하지만, 축구공 활성화는 필터를 통과한 `RouteTimeline.points.count > 1`을 기준으로 한다. 원본 좌표가 있어도 정확도 20m 초과·일시정지·중복 시각 등의 필터 후 0~1개면 지도는 보이고 재생은 비활성화된다. 이 두 표시 조건의 차이를 이번에 설명했으며 지도 로직은 변경하지 않았다.

### 후속 조정: 세로 스크롤 제거

- 사용자 요청에 따라 Field Chart의 `ScrollView`와 최소 높이 제한을 제거했다. 제목 아래 실제 남은 높이를 능력치 영역과 심박 영역에 배분해 한 화면에 표시한다. 작은 화면의 심박 그래프는 이전보다 낮아진다.
- 빌드 성공: `/tmp/soccerbeat-chart-no-scroll-build.log`.
- iPhone SE 3세대/iOS 18.2에서 스크롤 없이 능력치·범례·심박 그래프·시간축이 모두 표시되고, 로딩 표시 전후 크기가 유지됨을 모의 데이터로 확인했다. 앞 절의 세로 스크롤 관련 구현·검증 항목은 이 변경으로 대체된다.

### 후속 조정: 모든 상세 페이지의 상단 배너 제거

- Field Movement·Field Record에서도 부분 데이터/Reload 상단 배너와 공간을 차지하는 로딩 문구를 제거했다. 세 상세 페이지 모두 작은 overlay spinner를 사용한다. 데이터 조회·자동 갱신은 유지한다.
- 빌드 성공: `/tmp/soccerbeat-detail-banner-removal-build.log`.
- Recent Game 확인: `MainView`는 `unavailableMetrics`를 확인하지 않고 `DataConverter.toLevels`를 호출한다. 누락값의 0/기본 점수가 차트에 들어갈 수 있다. 계산식에는 예전 Power 입력도 남아 있다.
- 사용자에게 필수 계산 데이터가 없을 때 차트 대신 안내와 확인된 수치를 표시하고, 계산에 무관한 누락으로 차트를 숨기지 않는 정책을 제안했다. Recent Game 표시·능력치 계산 정책은 이번 변경에 포함하지 않았다.

### 후속 조정: 확인된 값으로 부분 능력치 생성

- 사용자 결정에 따라 Field Chart의 `unavailableMetrics` 전체 숨김 조건을 제거했다. 실제 오류 상태는 기존 오류 표시를 유지하고, 일부 누락만으로는 차트를 숨기지 않는다.
- `DataConverter`: 기존 개별 항목의 1~5 점수 구간을 유지한다. 누락 플래그, 유효하지 않은 숫자, 0 이하 심박은 제외한다. 측정된 거리/속도/스프린트의 0은 유효한 입력이다.
- Power는 수집 여부·과거 값과 관계없이 능력치 입력에서 제외했다. 칼로리로 단순 치환하지 않는다. 저장된 운동/기존 Power 필드를 삭제하거나 변경하지 않는다.
- 각 축은 남은 입력의 가중치를 정규화하고 기존 축 스케일(점수 × 0.75)을 유지한다. 해당 축의 입력이 전부 없으면 다른 확인된 입력 점수의 평균을 임시 사용한다. 확인된 입력이 전혀 없으면 여섯 축을 0으로 반환해 중심만 표시한다.
- 이 방식은 차트 표시를 유지하기 위한 임시 정책이며 축 명칭·측정 타당성·경기 간 비교 기준의 재기획은 별도 후속 작업이다. 경기 시간만 있는 경우에도 시간 점수로 여섯 축을 채운다.
- `WorkoutAverageData`에 누락 정보를 보존하고 `WorkoutRecordReconciliation.average`에서 계산해 평균 비교선에도 동일 정책을 적용한다. 누락 평균이 측정된 0으로 취급되지 않는다.
- MainView의 Recent Game과 MatchDetailView의 차트는 같은 변환 함수를 사용한다. 계산된 값이 바뀌면 UIKit 차트 컨트롤러도 갱신되도록 identity를 지정했다.
- 관련 회귀 테스트 36개 통과(기존 26개 + 능력치 10개): `/tmp/soccerbeat-partial-ability-tests.log`. Power 무영향, 부분 가중치, 실제 0/누락 구분, 최소 심박 0의 최고 점수 방지, 시간만 있는 3분 기록, 평균 누락 보존, 비유한 입력을 검증했다.
- iOS·watchOS 전체 빌드 성공: `/tmp/soccerbeat-partial-ability-build.log`. 사용자 미커밋 설정을 제외한 임시 사본에서 변경 소스를 빌드했다.
- iPhone SE/iOS 18.2 모의 UI: 거리·시간만 있는 기록의 민트색 육각형이 표시됨을 확인. 실제 publisher로 추가 데이터를 두 번 전달하자 열린 화면에서 능력치 및 심박 차트가 갱신됨을 확인했다. 실기기 HealthKit 동기화를 시험한 것은 아니다.
