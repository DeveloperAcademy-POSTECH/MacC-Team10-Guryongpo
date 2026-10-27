# 운동 데이터 안정화 작업 진행 기록

갱신일: 2026-10-27 (America/New_York)

## 작업 범위와 보존 상태

- 브랜치: `fix/workout-data-reliability`
- 시작 커밋: `613389d` (`develop`의 1.4.2 수정 병합)
- 현재 안정화 코드는 이전 세션에서 작성된 미커밋 변경이다. 아래 검증 결과와 미완료 목록을 구분한다.
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
| 새 관찰·재조회와 프로필 평균 충돌 | `ProfileModel.calculateAverageAbility`가 이전 평균을 초기화하지 않고 다시 더했다. 반복 조회 시 값이 누적된다. | 높음. 수정 미완료 |

## 이전 세션에서 구현된 내용 — 재검증 필요

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
- 이전 전체 빌드 실패: `finishRoute`의 non-optional 반환값을 `if let`으로 처리한 오류. 현재 소스에는 수정되어 있으나 빌드 성공 여부는 아직 미확인.
- 재개 후 전체 빌드 실행 중: `/tmp/soccerbeat-reliability-resume-build.log`.
- 실기기 HealthKit 저장·동기화·백그라운드 검증: 수행하지 않음.

## 미완료 및 다음 작업

1. 현재 소스 전체 빌드 결과 확인, 컴파일 오류 우선 수정.
2. 저장 실패/부분 성공 상태의 닫기·초기화 경계 검토. `canDismissWorkoutSummary`와 공통 didSet의 일관성 확인.
3. 반복 재조회에서 프로필 평균이 누적되는 문제 수정 및 회귀 검증.
4. 새 상태 안내 문구의 네 언어 번역 추가. 기존 사용자 번역 변경은 제외하여 커밋.
5. 현재 소스로 테스트 실행, 부분 기록→추가 동기화→열린 상세 갱신 시나리오 확인.
6. 단계별 커밋 생성 후 아래 커밋 기록을 갱신.
7. 실기기 수동 테스트 절차와 남은 복구 한계 최종 기록.

## 복구 한계와 실기기 검증 항목

- HealthKit 운동 저장과 경로 저장은 별개다. 운동 저장 성공만으로 경로까지 완료됐다고 표시하지 않는다.
- finish 호출 결과가 모호한 경우 동일 운동/경로를 무조건 다시 만들지 않는다. 안정적인 식별자로 먼저 조회하며, 확인할 수 없으면 백업을 유지한다.
- 앱 종료로 소실된 미완료 `HKLiveWorkoutBuilder`를 로컬 GPS만으로 완전히 복원할 수 있다고 보장하지 않는다.
- 수집되지 않은 GPS·심박은 복구할 수 없다. 누락을 임의 좌표·심박·성공한 0으로 보충하지 않는다.
- HealthKit의 빈 읽기 결과만으로 읽기 권한 거부를 확정하지 않는다.
- 실기기 필수: 일반 완료, 즉시 완료 탭, GPS 단절 후 회복, 잠금/백그라운드, 폰 연결 해제 후 재연결, 저장 실패·재확인, 앱 재실행, 이전 운동 호환성, 부분 동기화 후 상세 자동 갱신.

## 관련 커밋

- `613389d`: 작업 시작 기준.
- 안정화 변경: 아직 커밋되지 않음. 단계별 검증 후 기록 예정.
