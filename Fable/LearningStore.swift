import Combine
import Foundation

enum ReadingPhase: String, Codable {
    case story
    case guess
    case reveal
    case insight
}

struct StoryProgress: Codable {
    var phase: ReadingPhase = .story
    var sceneIndex = 0
    var isSaved = false
    var startedAt: Date?
    var completedAt: Date?
    var nextReviewAt: Date?
    var successfulReviews = 0
    var readingUpdatedAt: Date?
    var savedUpdatedAt: Date?
    var reviewUpdatedAt: Date?

    var isComplete: Bool { completedAt != nil }
    var hasStarted: Bool { startedAt != nil || phase != .story || sceneIndex > 0 }
    var isDue: Bool { nextReviewAt.map { $0 <= .now } ?? false }

    func merging(_ other: StoryProgress) -> StoryProgress {
        var result = self
        result.startedAt = [startedAt, other.startedAt].compactMap { $0 }.min()
        result.completedAt = [completedAt, other.completedAt].compactMap { $0 }.min()
        if (other.readingUpdatedAt ?? .distantPast) > (readingUpdatedAt ?? .distantPast) {
            result.phase = other.phase
            result.sceneIndex = other.sceneIndex
            result.readingUpdatedAt = other.readingUpdatedAt
        }
        if (other.savedUpdatedAt ?? .distantPast) > (savedUpdatedAt ?? .distantPast) {
            result.isSaved = other.isSaved
            result.savedUpdatedAt = other.savedUpdatedAt
        } else if savedUpdatedAt == nil && other.savedUpdatedAt == nil {
            result.isSaved = isSaved || other.isSaved
        }
        if (other.reviewUpdatedAt ?? .distantPast) > (reviewUpdatedAt ?? .distantPast) {
            result.nextReviewAt = other.nextReviewAt
            result.successfulReviews = other.successfulReviews
            result.reviewUpdatedAt = other.reviewUpdatedAt
        } else if reviewUpdatedAt == nil && other.reviewUpdatedAt == nil {
            result.nextReviewAt = [nextReviewAt, other.nextReviewAt].compactMap { $0 }.min()
            result.successfulReviews = max(successfulReviews, other.successfulReviews)
        }
        return result
    }
}

enum LearningEventKind: String, Codable {
    case completedStory
    case reviewed
}

struct LearningEvent: Codable, Identifiable {
    let id: String
    let storyID: String
    let kind: LearningEventKind
    let occurredAt: Date
}

enum ReaderTextSize: String, CaseIterable, Codable, Identifiable {
    case standard
    case comfortable
    case large

    var id: String { rawValue }
    var title: String {
        switch self {
        case .standard: "标准"
        case .comfortable: "舒适"
        case .large: "大字"
        }
    }
    var scale: CGFloat {
        switch self {
        case .standard: 1
        case .comfortable: 1.13
        case .large: 1.28
        }
    }
}

struct FablePreferences: Codable {
    var readerTextSize: ReaderTextSize = .standard
}

enum CloudSyncStatus {
    case off
    case active
    case unavailable
}

private struct CloudSnapshot: Codable {
    let progressByID: [String: StoryProgress]
    let eventsByID: [String: LearningEvent]
    let preferences: FablePreferences
    let preferencesUpdatedAt: Date
}

@MainActor
final class LearningStore: ObservableObject {
    @Published private(set) var progressByID: [String: StoryProgress]
    @Published private(set) var eventsByID: [String: LearningEvent]
    @Published private(set) var preferences: FablePreferences
    @Published private(set) var isCloudSyncEnabled: Bool
    @Published private(set) var cloudStatus: CloudSyncStatus

    private let defaults: UserDefaults
    private let cloudStore: NSUbiquitousKeyValueStore
    private let progressKey = "learningProgressV2"
    private let eventsKey = "learningEventsV1"
    private let preferencesKey = "fablePreferencesV1"
    private let cloudEnabledKey = "iCloudSyncEnabledV1"
    private let cloudKeyPrefix = "fable.snapshot."
    private let deviceID: String
    private var preferencesUpdatedAt: Date
    private var cloudObserver: NSObjectProtocol?

    init(defaults: UserDefaults = .standard, cloudStore: NSUbiquitousKeyValueStore = .default) {
        self.defaults = defaults
        self.cloudStore = cloudStore
        if let existingID = defaults.string(forKey: "fableDeviceID") {
            deviceID = existingID
        } else {
            deviceID = UUID().uuidString
            defaults.set(deviceID, forKey: "fableDeviceID")
        }

        let initialProgress: [String: StoryProgress]
        if let data = defaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([String: StoryProgress].self, from: data) {
            initialProgress = decoded
        } else {
            let completed = Set((defaults.string(forKey: "completedStoryIDs") ?? "").split(separator: ",").map(String.init))
            let saved = Set((defaults.string(forKey: "savedStoryIDs") ?? "").split(separator: ",").map(String.init))
            var migrated: [String: StoryProgress] = [:]
            for id in completed.union(saved) {
                var progress = StoryProgress()
                progress.isSaved = saved.contains(id)
                if completed.contains(id) {
                    progress.startedAt = .now
                    progress.completedAt = .now
                    progress.nextReviewAt = .now
                }
                migrated[id] = progress
            }
            initialProgress = migrated
        }
        progressByID = initialProgress

        if let data = defaults.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([String: LearningEvent].self, from: data) {
            eventsByID = decoded
        } else {
            var backfilled: [String: LearningEvent] = [:]
            for (id, progress) in initialProgress {
                if let date = progress.completedAt {
                    let event = LearningEvent(id: "completed:\(id)", storyID: id, kind: .completedStory, occurredAt: date)
                    backfilled[event.id] = event
                }
            }
            eventsByID = backfilled
        }

        if let data = defaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(FablePreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = FablePreferences()
        }
        preferencesUpdatedAt = defaults.object(forKey: "fablePreferencesUpdatedAt") as? Date ?? .distantPast
        isCloudSyncEnabled = defaults.bool(forKey: cloudEnabledKey)
        cloudStatus = .off

        persistLocal()
        cloudObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] _ in
            guard let store = self else { return }
            Task { @MainActor in store.receiveCloudChanges() }
        }
        if isCloudSyncEnabled { connectCloud() }
    }

    deinit {
        if let cloudObserver { NotificationCenter.default.removeObserver(cloudObserver) }
    }

    var events: [LearningEvent] { Array(eventsByID.values) }

    func progress(for id: String) -> StoryProgress {
        progressByID[id] ?? StoryProgress()
    }

    func beginReading(_ id: String) {
        var progress = self.progress(for: id)
        guard progress.startedAt == nil && !progress.isComplete else { return }
        progress.startedAt = .now
        set(progress, for: id)
    }

    func updateReading(_ id: String, phase: ReadingPhase, sceneIndex: Int) {
        var progress = self.progress(for: id)
        if progress.startedAt == nil { progress.startedAt = .now }
        progress.phase = phase
        progress.sceneIndex = sceneIndex
        progress.readingUpdatedAt = .now
        set(progress, for: id)
    }

    func finishReading(_ id: String) {
        var progress = self.progress(for: id)
        progress.phase = .story
        progress.sceneIndex = 0
        progress.readingUpdatedAt = .now
        if progress.completedAt == nil {
            progress.completedAt = .now
            progress.nextReviewAt = Calendar.current.date(byAdding: .day, value: 1, to: .now)
            let event = LearningEvent(id: "completed:\(id)", storyID: id, kind: .completedStory, occurredAt: .now)
            eventsByID[event.id] = event
        }
        set(progress, for: id)
    }

    func toggleSaved(_ id: String) {
        var progress = self.progress(for: id)
        progress.isSaved.toggle()
        progress.savedUpdatedAt = .now
        set(progress, for: id)
    }

    func recordReview(_ id: String, correct: Bool) {
        var progress = self.progress(for: id)
        guard progress.isComplete else { return }
        progress.successfulReviews = correct ? progress.successfulReviews + 1 : 0
        let days = correct ? [3, 7, 14][min(progress.successfulReviews - 1, 2)] : 1
        progress.nextReviewAt = Calendar.current.date(byAdding: .day, value: days, to: .now)
        progress.reviewUpdatedAt = .now
        let event = LearningEvent(id: UUID().uuidString, storyID: id, kind: .reviewed, occurredAt: .now)
        eventsByID[event.id] = event
        set(progress, for: id)
    }

    func setReaderTextSize(_ size: ReaderTextSize) {
        guard preferences.readerTextSize != size else { return }
        preferences.readerTextSize = size
        preferencesUpdatedAt = .now
        persistAndSync()
    }

    func setCloudSyncEnabled(_ enabled: Bool) {
        isCloudSyncEnabled = enabled
        defaults.set(enabled, forKey: cloudEnabledKey)
        if enabled {
            connectCloud()
        } else {
            cloudStatus = .off
        }
    }

    func retryCloudSync() {
        if isCloudSyncEnabled { connectCloud() }
    }

    private func set(_ progress: StoryProgress, for id: String) {
        progressByID[id] = progress
        persistAndSync()
    }

    private func persistAndSync() {
        persistLocal()
        if cloudStatus == .active { writeCloudSnapshot() }
    }

    private func persistLocal() {
        let cutoff = Calendar.current.date(byAdding: .day, value: -400, to: .now) ?? .distantPast
        let recentEvents = eventsByID.filter { $0.value.occurredAt >= cutoff }
        if recentEvents.count != eventsByID.count { eventsByID = recentEvents }
        if let data = try? JSONEncoder().encode(progressByID) { defaults.set(data, forKey: progressKey) }
        if let data = try? JSONEncoder().encode(eventsByID) { defaults.set(data, forKey: eventsKey) }
        if let data = try? JSONEncoder().encode(preferences) { defaults.set(data, forKey: preferencesKey) }
        defaults.set(preferencesUpdatedAt, forKey: "fablePreferencesUpdatedAt")
    }

    private func connectCloud() {
        guard FileManager.default.ubiquityIdentityToken != nil, cloudStore.synchronize() else {
            cloudStatus = .unavailable
            return
        }
        receiveCloudChanges()
        cloudStatus = .active
        writeCloudSnapshot()
    }

    private func receiveCloudChanges() {
        guard isCloudSyncEnabled else { return }
        let snapshots = cloudStore.dictionaryRepresentation
        for (key, value) in snapshots where key.hasPrefix(cloudKeyPrefix) {
            guard let data = value as? Data,
                  let snapshot = try? JSONDecoder().decode(CloudSnapshot.self, from: data) else { continue }
            for (id, remote) in snapshot.progressByID {
                progressByID[id] = progress(for: id).merging(remote)
            }
            eventsByID.merge(snapshot.eventsByID) { local, _ in local }
            if snapshot.preferencesUpdatedAt > preferencesUpdatedAt {
                preferences = snapshot.preferences
                preferencesUpdatedAt = snapshot.preferencesUpdatedAt
            }
        }
        persistLocal()
    }

    private func writeCloudSnapshot() {
        let snapshot = CloudSnapshot(
            progressByID: progressByID,
            eventsByID: eventsByID,
            preferences: preferences,
            preferencesUpdatedAt: preferencesUpdatedAt
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        cloudStore.set(data, forKey: cloudKeyPrefix + deviceID)
    }
}
