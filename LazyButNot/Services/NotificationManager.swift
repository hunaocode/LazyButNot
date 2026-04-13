import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleNotifications(for goal: Goal) async {
        removeNotifications(for: goal)
        guard !goal.isPaused else { return }

        switch goal.periodType {
        case .daily, .weeklyCount:
            await scheduleReminder(for: goal, weekday: nil)
        case .weeklyFixedDays:
            for weekday in goal.selectedWeekdays {
                await scheduleReminder(for: goal, weekday: weekday)
            }
        }

        guard goal.supervisionEnabled else { return }

        switch goal.periodType {
        case .daily, .weeklyCount:
            for offset in goal.supervisionOffsets {
                await scheduleSupervision(for: goal, offset: offset, weekday: nil)
            }
        case .weeklyFixedDays:
            for weekday in goal.selectedWeekdays {
                for offset in goal.supervisionOffsets {
                    await scheduleSupervision(for: goal, offset: offset, weekday: weekday)
                }
            }
        }
    }

    func scheduleAll(goals: [Goal]) async {
        for goal in goals {
            await scheduleNotifications(for: goal)
        }
    }

    func removeNotifications(for goal: Goal) {
        let offsets = Set(goal.supervisionOffsets + [60, 30, 15, 10, 5])
        let weekdays = Set(goal.selectedWeekdays + Array(1...7))

        var identifiers = [reminderIdentifier(for: goal)]
        identifiers += weekdays.map { reminderIdentifier(for: goal, weekday: $0) }
        identifiers += offsets.map { supervisionIdentifier(for: goal, offset: $0) }
        identifiers += weekdays.flatMap { weekday in
            offsets.map { offset in supervisionIdentifier(for: goal, offset: offset, weekday: weekday) }
        }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleReminder(for goal: Goal, weekday: Int?) async {
        let content = UNMutableNotificationContent()
        content.title = "该打卡了"
        content.body = "现在开始「\(goal.name)」，先做最小动作也算完成。"
        content.sound = .default

        var components = DateComponents()
        components.hour = goal.reminderHour
        components.minute = goal.reminderMinute
        components.weekday = weekday

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: goal, weekday: weekday),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func scheduleSupervision(for goal: Goal, offset: Int, weekday: Int?) async {
        let content = UNMutableNotificationContent()
        content.title = "临近截止"
        content.body = "「\(goal.name)」将在 \(offset) 分钟后截止，别忘记完成哦。"
        content.sound = goal.ringEnabled ? .default : nil

        let deadlineTotalMinutes = goal.deadlineHour * 60 + goal.deadlineMinute
        let fireMinutes = max(deadlineTotalMinutes - offset, 0)

        var components = DateComponents()
        components.hour = fireMinutes / 60
        components.minute = fireMinutes % 60
        components.weekday = weekday

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: supervisionIdentifier(for: goal, offset: offset, weekday: weekday),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func reminderIdentifier(for goal: Goal, weekday: Int? = nil) -> String {
        if let weekday {
            return "goal.\(goal.id.uuidString).reminder.\(weekday)"
        }
        return "goal.\(goal.id.uuidString).reminder"
    }

    private func supervisionIdentifier(for goal: Goal, offset: Int, weekday: Int? = nil) -> String {
        if let weekday {
            return "goal.\(goal.id.uuidString).supervision.\(weekday).\(offset)"
        }
        return "goal.\(goal.id.uuidString).supervision.\(offset)"
    }
}
