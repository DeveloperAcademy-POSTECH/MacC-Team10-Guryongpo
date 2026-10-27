import Foundation

#if os(watchOS)
enum WorkoutSaveState {
    case idle, saving, saved, partial, failed
}
#endif

/// A recovery journal for newly recorded sessions, separate from HealthKit records.
struct WorkoutRecoveryRecord: Codable, Equatable {
    let sessionID: UUID
    let startDate: Date
    var endDate: Date?
    var workoutID: UUID?
    var metadata = Data()
    var finishAttempted = false
    var routeFinishAttempted = false
    var metadataStored = false
    var routePointCount = 0
}

struct WorkoutRouteSample: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let course: Double
    let speed: Double
    let speedAccuracy: Double
    let courseAccuracy: Double
    let timestamp: Date
}

struct WorkoutRecoveryStore {
    let directory: URL

    init(directory: URL = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask)[0]
        .appendingPathComponent("WorkoutRecovery", isDirectory: true)) {
        self.directory = directory
    }

    func save(_ record: WorkoutRecoveryRecord) throws {
        try prepareDirectory()
        let data = try JSONEncoder().encode(record)
        #if os(watchOS)
        try data.write(to: recordURL(record.sessionID), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: recordURL(record.sessionID), options: .atomic)
        #endif
    }

    // Persist the once-only intent before an externally visible HealthKit finalization.
    // If persistence itself fails, no HealthKit call has happened and a retry remains safe.
    func claimWorkoutFinish(_ record: inout WorkoutRecoveryRecord) throws -> Bool {
        guard !record.finishAttempted else { return false }
        record.finishAttempted = true
        do { try save(record) }
        catch {
            record.finishAttempted = false
            throw error
        }
        return true
    }

    func claimRouteFinish(_ record: inout WorkoutRecoveryRecord) throws -> Bool {
        guard !record.routeFinishAttempted else { return false }
        record.routeFinishAttempted = true
        do { try save(record) }
        catch {
            record.routeFinishAttempted = false
            throw error
        }
        return true
    }

    func records() throws -> [WorkoutRecoveryRecord] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                do { return try JSONDecoder().decode(WorkoutRecoveryRecord.self, from: Data(contentsOf: url)) }
                catch {
                    // Leave an unreadable journal intact; do not discard other recoverable sessions.
                    NSLog("WorkoutRecoveryStore: journal could not be read: %@", error.localizedDescription)
                    return nil
                }
            }
    }

    func append(_ samples: [WorkoutRouteSample], to sessionID: UUID) throws {
        guard !samples.isEmpty else { return }
        try prepareDirectory()
        var data = Data()
        for sample in samples {
            data.append(try JSONEncoder().encode(sample))
            data.append(0x0A)
        }
        let url = routeURL(sessionID)
        if !FileManager.default.fileExists(atPath: url.path) {
            #if os(watchOS)
            try Data().write(to: url, options: .completeFileProtectionUntilFirstUserAuthentication)
            #else
            try Data().write(to: url)
            #endif
        }
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }

    /// Rewrite from the retained actual fixes only when a prior append failed.
    func replaceSamples(_ samples: [WorkoutRouteSample], for sessionID: UUID) throws {
        try prepareDirectory()
        var data = Data()
        for sample in samples {
            data.append(try JSONEncoder().encode(sample))
            data.append(0x0A)
        }
        #if os(watchOS)
        try data.write(to: routeURL(sessionID), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: routeURL(sessionID), options: .atomic)
        #endif
    }

    func samples(for sessionID: UUID) throws -> [WorkoutRouteSample] {
        let url = routeURL(sessionID)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let lines = data.split(separator: 0x0A)
        return try lines.enumerated().compactMap { index, line in
            do { return try JSONDecoder().decode(WorkoutRouteSample.self, from: Data(line)) }
            catch {
                // A process interruption can leave only the final append incomplete.
                if index == lines.count - 1 && data.last != 0x0A { return nil }
                throw error
            }
        }
    }

    /// Remove only our redundant recovery files after the HealthKit save was verified.
    func complete(_ sessionID: UUID) throws {
        for url in [recordURL(sessionID), routeURL(sessionID)] {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        }
    }

    private func prepareDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        #if os(watchOS)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                                              ofItemAtPath: directory.path)
        #endif
        var url = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }

    private func recordURL(_ id: UUID) -> URL { directory.appendingPathComponent("\(id.uuidString).json") }
    private func routeURL(_ id: UUID) -> URL { directory.appendingPathComponent("\(id.uuidString).route") }
}
