import Foundation
import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(AlarmKit)
import AlarmKit
#endif

enum CountdownAlarmScheduleResult: Equatable {
    case success(UUID)
    case unavailable
    case authorizationDenied
    case failed
}

struct FocusCountdownSession: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let alarmID: UUID
    let title: String
    let category: GoalCategory
    let startDate: Date
    let endDate: Date
}

@MainActor
final class CountdownAlarmService {
    static let shared = CountdownAlarmService()
    private let activeCountdownAlarmIDKey = "active_countdown_alarm_id"
    private let activeCountdownScheduledAtKey = "active_countdown_scheduled_at"
    private let activeFocusSessionKey = "active_focus_countdown_session"
    private var liveActivityObservationTask: Task<Void, Never>?
    private var observedActivityIDs: Set<String> = []

    private init() { }

    func schedule(
        title: String,
        durationMinutes: Int,
        repeatMinutes: Int?,
        context: GoalCategory
    ) async -> CountdownAlarmScheduleResult {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return .unavailable }
        guard durationMinutes > 0 else { return .failed }

        if AlarmManager.shared.authorizationState == .notDetermined {
            _ = await NotificationManager.shared.requestAlarmAuthorization()
        }

        guard AlarmManager.shared.authorizationState == .authorized else {
            return .authorizationDenied
        }

        if let existingAlarmID = persistedActiveCountdownAlarmID() {
            _ = await cancelCountdown(id: existingAlarmID, clearPersistedID: true)
        }

        let id = UUID()
        let metadata = CountdownAlarmMetadata(
            alarmID: id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "倒计时提醒" : title,
            context: metadataContext(from: context)
        )
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: TimeInterval(durationMinutes * 60),
            postAlert: repeatMinutes.map { TimeInterval($0 * 60) }
        )
        let configuration = makeConfiguration(
            title: metadata.title,
            metadata: metadata,
            countdownDuration: countdownDuration,
            repeatEnabled: repeatMinutes != nil
        )

        do {
            _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
            persistActiveCountdownAlarmID(id)
            persistActiveFocusSession(
                FocusCountdownSession(
                    id: id,
                    alarmID: id,
                    title: metadata.title,
                    category: context,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
                )
            )
            return .success(id)
        } catch {
            return .failed
        }
        #else
        return .unavailable
        #endif
    }

    func cancelActiveCountdown() async -> Bool {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return false }
        guard let id = persistedActiveCountdownAlarmID() else { return false }
        return await cancelCountdown(id: id, clearPersistedID: true)
        #else
        return false
        #endif
    }

    func persistActiveCountdownAlarmID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: activeCountdownAlarmIDKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: activeCountdownScheduledAtKey)
    }

    func clearPersistedActiveCountdownAlarmID() {
        UserDefaults.standard.removeObject(forKey: activeCountdownAlarmIDKey)
        UserDefaults.standard.removeObject(forKey: activeCountdownScheduledAtKey)
        clearPersistedActiveFocusSession()
    }

    func activeFocusSession() -> FocusCountdownSession? {
        guard let data = UserDefaults.standard.data(forKey: activeFocusSessionKey) else {
            return nil
        }

        do {
            let session = try JSONDecoder().decode(FocusCountdownSession.self, from: data)
            if session.endDate <= Date() {
                clearPersistedActiveFocusSession()
                return nil
            }
            return session
        } catch {
            clearPersistedActiveFocusSession()
            return nil
        }
    }

    private func persistedActiveCountdownAlarmID() -> UUID? {
        guard let rawValue = UserDefaults.standard.string(forKey: activeCountdownAlarmIDKey) else {
            return nil
        }
        return UUID(uuidString: rawValue)
    }

    private func persistActiveFocusSession(_ session: FocusCountdownSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: activeFocusSessionKey)
    }

    private func clearPersistedActiveFocusSession() {
        UserDefaults.standard.removeObject(forKey: activeFocusSessionKey)
    }

    func startObservingLiveActivityDismissals() {
        #if canImport(ActivityKit) && canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return }
        guard liveActivityObservationTask == nil else { return }

        liveActivityObservationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            self.observeExistingActivities()

            for await activity in Activity<AlarmAttributes<CountdownAlarmMetadata>>.activityUpdates {
                self.observeActivityState(activity)
            }
        }
        #endif
    }

    func syncDismissedCountdownIfNeeded() async {
        #if canImport(ActivityKit) && canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return }
        guard let activeAlarmID = persistedActiveCountdownAlarmID() else { return }
        guard let scheduledAt = persistedScheduledDate(),
              Date().timeIntervalSince(scheduledAt) > 5 else {
            return
        }

        let hasMatchingActivity = Activity<AlarmAttributes<CountdownAlarmMetadata>>.activities.contains {
            $0.attributes.metadata?.alarmID == activeAlarmID
        }

        if !hasMatchingActivity {
            _ = await cancelCountdown(id: activeAlarmID, clearPersistedID: true)
        }
        #endif
    }

    private func persistedScheduledDate() -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: activeCountdownScheduledAtKey)
        guard timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    @available(iOS 26.0, *)
    private func cancelCountdown(id: UUID, clearPersistedID: Bool) async -> Bool {
        #if canImport(AlarmKit)
        do {
            try AlarmManager.shared.cancel(id: id)
            if clearPersistedID {
                clearPersistedActiveCountdownAlarmID()
            }
            return true
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
}

#if canImport(AlarmKit)
@available(iOS 26.0, *)
private extension CountdownAlarmService {
    typealias CountdownConfiguration = AlarmManager.AlarmConfiguration<CountdownAlarmMetadata>

    func metadataContext(from category: GoalCategory) -> CountdownAlarmMetadata.Context {
        switch category {
        case .study:
            return .study
        case .fitness:
            return .fitness
        case .reading:
            return .reading
        case .routine, .work, .custom:
            return .focus
        }
    }

    func makeConfiguration(
        title: String,
        metadata: CountdownAlarmMetadata,
        countdownDuration: Alarm.CountdownDuration,
        repeatEnabled: Bool
    ) -> CountdownConfiguration {
        let stopButton = AlarmButton(
            text: "关闭",
            textColor: .white,
            systemImageName: "stop.circle.fill"
        )
        let secondaryButton = repeatEnabled ? AlarmButton(
            text: "重复",
            textColor: .white,
            systemImageName: "repeat.circle.fill"
        ) : nil

        let alertPresentation: AlarmPresentation.Alert
        if #available(iOS 26.1, *) {
            alertPresentation = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: title),
                secondaryButton: secondaryButton,
                secondaryButtonBehavior: repeatEnabled ? .countdown : nil
            )
        } else {
            alertPresentation = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: title),
                stopButton: stopButton,
                secondaryButton: secondaryButton,
                secondaryButtonBehavior: repeatEnabled ? .countdown : nil
            )
        }

        let pauseButton = AlarmButton(
            text: "暂停",
            textColor: .white,
            systemImageName: "pause.fill"
        )
        let countdownPresentation = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: metadata.context.countdownTitle),
            pauseButton: pauseButton
        )

        let resumeButton = AlarmButton(
            text: "继续",
            textColor: .white,
            systemImageName: "play.fill"
        )
        let pausedPresentation = AlarmPresentation.Paused(
            title: LocalizedStringResource(stringLiteral: metadata.context.pausedTitle),
            resumeButton: resumeButton
        )

        let attributes = AlarmAttributes(
            presentation: AlarmPresentation(
                alert: alertPresentation,
                countdown: countdownPresentation,
                paused: pausedPresentation
            ),
            metadata: metadata,
            tintColor: metadata.context.tintColor
        )

        return CountdownConfiguration(
            countdownDuration: countdownDuration,
            attributes: attributes,
            sound: .default
        )
    }

    func observeExistingActivities() {
        for activity in Activity<AlarmAttributes<CountdownAlarmMetadata>>.activities {
            observeActivityState(activity)
        }
    }

    func observeActivityState(_ activity: Activity<AlarmAttributes<CountdownAlarmMetadata>>) {
        guard observedActivityIDs.insert(activity.id).inserted else {
            return
        }

        Task { @MainActor [weak self] in
            guard let self else { return }

            for await state in activity.activityStateUpdates {
                if state == .dismissed {
                    guard let alarmID = activity.attributes.metadata?.alarmID else {
                        break
                    }
                    let shouldClearPersistedID = self.persistedActiveCountdownAlarmID() == alarmID
                    _ = await self.cancelCountdown(id: alarmID, clearPersistedID: shouldClearPersistedID)
                    break
                }
            }

            self.observedActivityIDs.remove(activity.id)
        }
    }
}
#endif
