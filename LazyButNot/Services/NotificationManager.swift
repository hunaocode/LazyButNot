import Foundation
import UserNotifications
import os

#if canImport(AlarmKit)
import ActivityKit
import AlarmKit
#endif

struct NotificationCapabilityStatus {
    let authorizationStatus: UNAuthorizationStatus
    let soundSetting: UNNotificationSetting
    let alarmPermissionState: AlarmPermissionState
}

enum ReminderDeliveryMode {
    case notificationOnly
    case alarmKitUnauthorized
    case alarmKitAuthorized
}

enum AlarmPermissionState {
    case unavailable
    case notDetermined
    case denied
    case authorized
    case unknown
}

@MainActor
final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private static let logger = Logger(subsystem: "com.hunaocode.LazyButNot", category: "NotificationManager")

    private let center = UNUserNotificationCenter.current()
    private let rollingScheduleHorizonDays = 7
    private var alarmUpdatesObservationTask: Task<Void, Never>?

    private override init() {
        super.init()
    }

    func configure() {
        center.delegate = self
        startObservingAlarmUpdatesIfNeeded()
    }

    func requestNotificationAuthorization() async -> Bool {
        configure()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            Self.logger.info("requestNotificationAuthorization granted=\(granted, privacy: .public)")
            return granted
        } catch {
            Self.logger.error("requestNotificationAuthorization failed error=\(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    func requestAlarmAuthorization() async -> AlarmPermissionState {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return .unavailable }

        do {
            _ = try await AlarmManager.shared.requestAuthorization()
        } catch {
            Self.logger.error("requestAlarmAuthorization failed error=\(error.localizedDescription, privacy: .public)")
            return alarmPermissionState()
        }

        Self.logger.info("requestAlarmAuthorization state=\(self.alarmPermissionLogText(), privacy: .public)")
        return alarmPermissionState()
        #else
        return .unavailable
        #endif
    }

    func requestAuthorization() async -> Bool {
        let granted = await requestNotificationAuthorization()

        if #available(iOS 26.0, *) {
            _ = await requestAlarmAuthorization()
        }

        return granted
    }

    func requestLaunchPermissionsIfNeeded() async {
        if await notificationStatus() == .notDetermined {
            _ = await requestNotificationAuthorization()
        }

        if #available(iOS 26.0, *), alarmPermissionState() == .notDetermined {
            _ = await requestAlarmAuthorization()
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func capabilityStatus() async -> NotificationCapabilityStatus {
        let settings = await center.notificationSettings()
        return NotificationCapabilityStatus(
            authorizationStatus: settings.authorizationStatus,
            soundSetting: settings.soundSetting,
            alarmPermissionState: alarmPermissionState()
        )
    }

    func alarmAuthorizationDescription() -> String? {
        switch alarmPermissionState() {
        case .unavailable:
            return nil
        case .notDetermined:
            return "未决定"
        case .denied:
            return "已拒绝"
        case .authorized:
            return "已允许"
        case .unknown:
            return "未知"
        }
    }

    func reminderDeliveryMode() -> ReminderDeliveryMode {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return .notificationOnly }

        switch AlarmManager.shared.authorizationState {
        case .authorized:
            return .alarmKitAuthorized
        case .notDetermined, .denied:
            return .alarmKitUnauthorized
        @unknown default:
            return .alarmKitUnauthorized
        }
        #else
        return .notificationOnly
        #endif
    }

    func alarmPermissionState() -> AlarmPermissionState {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return .unavailable }

        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .unknown
        }
        #else
        return .unavailable
        #endif
    }

    func scheduleNotifications(for goal: Goal) async {
        configure()
        Self.logger.info("scheduleNotifications start goalID=\(goal.id.uuidString, privacy: .public) name=\(goal.name, privacy: .public) period=\(goal.periodType.rawValue, privacy: .public) reminder=\(String(format: "%02d:%02d", goal.reminderHour, goal.reminderMinute), privacy: .public) deadline=\(String(format: "%02d:%02d", goal.deadlineHour, goal.deadlineMinute), privacy: .public) supervisionEnabled=\(goal.supervisionEnabled, privacy: .public) ringEnabled=\(goal.ringEnabled, privacy: .public) paused=\(goal.isPaused, privacy: .public) offsets=\(goal.supervisionOffsets.map(String.init).joined(separator: ","), privacy: .public)")
        removeNotifications(for: goal)
        guard !goal.isPaused else { return }
        let completedToday = GoalStore.isCompletedToday(goal)
        let scheduledDates = scheduledDatesForWindow(for: goal, includeToday: !completedToday)

        Self.logger.info("scheduleNotifications fixedDateWindow goalID=\(goal.id.uuidString, privacy: .public) completedToday=\(completedToday, privacy: .public) dateCount=\(scheduledDates.count, privacy: .public)")

        for date in scheduledDates {
            await scheduleReminder(for: goal, date: date)
        }

        guard goal.supervisionEnabled else { return }

        #if canImport(AlarmKit)
        if goal.ringEnabled, #available(iOS 26.0, *) {
            let didScheduleAlarm = await scheduleAlarmKitFixedDatesSupervision(for: goal, dates: scheduledDates)
            Self.logger.info("scheduleNotifications alarmKit fixedDateResult goalID=\(goal.id.uuidString, privacy: .public) success=\(didScheduleAlarm, privacy: .public)")
            return
        }
        #endif

        for date in scheduledDates {
            for offset in goal.supervisionOffsets {
                await scheduleSupervision(for: goal, offset: offset, date: date)
            }
        }
    }

    func scheduleAll(goals: [Goal]) async {
        configure()
        Self.logger.info("scheduleAll start goalCount=\(goals.count, privacy: .public)")
        for goal in goals {
            await scheduleNotifications(for: goal)
        }
        Self.logger.info("scheduleAll finished goalCount=\(goals.count, privacy: .public)")
    }

    func removeNotifications(for goal: Goal) {
        Self.logger.info("removeNotifications goalID=\(goal.id.uuidString, privacy: .public) offsets=\(goal.supervisionOffsets.map(String.init).joined(separator: ","), privacy: .public)")
        let offsets = Set(goal.supervisionOffsets + [60, 30, 15, 10, 5])
        let weekdays = Set(goal.selectedWeekdays + Array(1...7))
        let rollingDates = rollingIdentifierDates()

        var identifiers = [reminderIdentifier(for: goal)]
        identifiers += weekdays.map { reminderIdentifier(for: goal, weekday: $0) }
        identifiers += rollingDates.map { reminderIdentifier(for: goal, date: $0) }
        identifiers += offsets.map { supervisionIdentifier(for: goal, offset: $0) }
        identifiers += rollingDates.flatMap { date in
            offsets.map { offset in supervisionIdentifier(for: goal, offset: offset, date: date) }
        }
        identifiers += weekdays.flatMap { weekday in
            offsets.map { offset in supervisionIdentifier(for: goal, offset: offset, weekday: weekday) }
        }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)

        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            cancelAlarmKitEntries(for: goal)
        }
        #endif
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
        Self.logger.info("scheduled reminder notification goalID=\(goal.id.uuidString, privacy: .public) weekday=\(String(describing: weekday), privacy: .public) at=\(String(format: "%02d:%02d", components.hour ?? -1, components.minute ?? -1), privacy: .public)")
    }

    private func scheduleReminder(for goal: Goal, date: Date) async {
        let fireDate = reminderDate(for: goal, on: date)
        guard fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "该打卡了"
        content.body = "现在开始「\(goal.name)」，先做最小动作也算完成。"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: goal, date: date),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
        Self.logger.info("scheduled reminder notification goalID=\(goal.id.uuidString, privacy: .public) date=\(self.identifierDateString(from: date), privacy: .public) fireDate=\(fireDate.timeIntervalSince1970, privacy: .public)")
    }

    private func scheduleSupervision(for goal: Goal, offset: Int, weekday: Int?) async {
        let content = UNMutableNotificationContent()
        content.title = "临近截止"
        content.body = "「\(goal.name)」将在 \(offset) 分钟后截止，别忘记完成哦。"
        content.sound = goal.ringEnabled ? .default : nil

        let (fireMinutes, dayShift) = supervisionFireTimeComponents(deadlineHour: goal.deadlineHour, deadlineMinute: goal.deadlineMinute, offset: offset)

        var components = DateComponents()
        components.hour = fireMinutes / 60
        components.minute = fireMinutes % 60
        components.weekday = shiftedWeekday(weekday, by: dayShift)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: supervisionIdentifier(for: goal, offset: offset, weekday: weekday),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
        Self.logger.info("scheduled local supervision goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) weekday=\(String(describing: weekday), privacy: .public) fireTime=\(String(format: "%02d:%02d", components.hour ?? -1, components.minute ?? -1), privacy: .public) sound=\(goal.ringEnabled, privacy: .public)")
    }

    private func scheduleSupervision(for goal: Goal, offset: Int, date: Date) async {
        let fireDate = supervisionDate(for: goal, on: date, offset: offset)
        guard fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "临近截止"
        content.body = "「\(goal.name)」将在 \(offset) 分钟后截止，别忘记完成哦。"
        content.sound = goal.ringEnabled ? .default : nil

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: supervisionIdentifier(for: goal, offset: offset, date: date),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
        Self.logger.info("scheduled local supervision goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) date=\(self.identifierDateString(from: date), privacy: .public) fireDate=\(fireDate.timeIntervalSince1970, privacy: .public) sound=\(goal.ringEnabled, privacy: .public)")
    }

    private func reminderIdentifier(for goal: Goal, weekday: Int? = nil) -> String {
        if let weekday {
            return "goal.\(goal.id.uuidString).reminder.\(weekday)"
        }
        return "goal.\(goal.id.uuidString).reminder"
    }

    private func reminderIdentifier(for goal: Goal, date: Date) -> String {
        "goal.\(goal.id.uuidString).reminder.\(identifierDateString(from: date))"
    }

    private func supervisionIdentifier(for goal: Goal, offset: Int, weekday: Int? = nil) -> String {
        if let weekday {
            return "goal.\(goal.id.uuidString).supervision.\(weekday).\(offset)"
        }
        return "goal.\(goal.id.uuidString).supervision.\(offset)"
    }

    private func supervisionIdentifier(for goal: Goal, offset: Int, date: Date) -> String {
        "goal.\(goal.id.uuidString).supervision.\(identifierDateString(from: date)).\(offset)"
    }

    private func weeklyCountReminderDates(for goal: Goal) -> [Date] {
        let calendar = Calendar.current
        let startDate: Date

        if GoalStore.isWeeklyTargetMet(goal) {
            guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: .now),
                  let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek.start) else {
                return []
            }
            startDate = nextWeekStart
        } else {
            startDate = calendar.startOfDay(for: .now)
        }

        return (0..<rollingScheduleHorizonDays).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
    }

    private func scheduledDatesForWindow(for goal: Goal, includeToday: Bool) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let startOffset = includeToday ? 0 : 1
        let candidateDates: [Date]

        switch goal.periodType {
        case .daily:
            candidateDates = (startOffset..<startOffset + rollingScheduleHorizonDays).compactMap {
                calendar.date(byAdding: .day, value: $0, to: today)
            }
        case .weeklyFixedDays:
            candidateDates = (startOffset..<(startOffset + rollingScheduleHorizonDays * 3)).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                    return nil
                }
                let weekday = calendar.component(.weekday, from: date)
                return goal.selectedWeekdays.contains(weekday) ? date : nil
            }
        case .weeklyCount:
            if includeToday {
                candidateDates = weeklyCountReminderDates(for: goal)
            } else {
                candidateDates = weeklyCountReminderDates(for: goal).filter { !calendar.isDate($0, inSameDayAs: today) }
            }
        }

        return candidateDates
    }

    private func rollingIdentifierDates() -> [Date] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        return (0..<(rollingScheduleHorizonDays * 3)).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    private func reminderDate(for goal: Goal, on date: Date) -> Date {
        Calendar.current.date(
            bySettingHour: goal.reminderHour,
            minute: goal.reminderMinute,
            second: 0,
            of: date
        ) ?? date
    }

    private func supervisionDate(for goal: Goal, on date: Date, offset: Int) -> Date {
        let deadlineDate = Calendar.current.date(
            bySettingHour: goal.deadlineHour,
            minute: goal.deadlineMinute,
            second: 0,
            of: date
        ) ?? date
        return deadlineDate.addingTimeInterval(TimeInterval(-offset * 60))
    }

    private func supervisionFireTimeComponents(deadlineHour: Int, deadlineMinute: Int, offset: Int) -> (minutes: Int, dayShift: Int) {
        let deadlineTotalMinutes = deadlineHour * 60 + deadlineMinute
        let shiftedMinutes = deadlineTotalMinutes - offset

        if shiftedMinutes >= 0 {
            return (shiftedMinutes, 0)
        }

        return (shiftedMinutes + 24 * 60, -1)
    }

    private func shiftedWeekday(_ weekday: Int?, by shift: Int) -> Int? {
        guard let weekday else { return nil }
        let normalized = ((weekday - 1 + shift) % 7 + 7) % 7
        return normalized + 1
    }

    private func identifierDateString(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d%02d%02d", year, month, day)
    }

    private func alarmPermissionLogText() -> String {
        switch alarmPermissionState() {
        case .unavailable:
            return "unavailable"
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        case .unknown:
            return "unknown"
        }
    }

    private func startObservingAlarmUpdatesIfNeeded() {
        #if canImport(AlarmKit)
        guard #available(iOS 26.0, *) else { return }
        guard alarmUpdatesObservationTask == nil else { return }

        alarmUpdatesObservationTask = Task {
            Self.logger.info("alarmUpdates observer started")
            for await alarms in AlarmManager.shared.alarmUpdates {
                let summary = alarms.map {
                    "\($0.id.uuidString):\(String(describing: $0.state))"
                }.joined(separator: ",")
                Self.logger.info("alarmUpdates count=\(alarms.count, privacy: .public) alarms=\(summary, privacy: .public)")
            }
        }
        #endif
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

#if canImport(AlarmKit)
@available(iOS 26.0, *)
extension NotificationManager {
    private struct GoalAlarmMetadata: AlarmMetadata {
        let goalID: UUID
        let goalName: String
        let offset: Int
    }

    private func scheduleAlarmKitSupervision(for goal: Goal) async -> Bool {
        guard AlarmManager.shared.authorizationState != .denied else {
            Self.logger.error("scheduleAlarmKitSupervision denied goalID=\(goal.id.uuidString, privacy: .public)")
            return false
        }

        if goal.periodType == .weeklyCount {
            return await scheduleAlarmKitWeeklyCountSupervision(for: goal)
        }

        let recurrence = recurrence(for: goal)
        var didSchedule = false
        Self.logger.info("scheduleAlarmKitSupervision start goalID=\(goal.id.uuidString, privacy: .public) recurrence=\(self.recurrenceLogText(recurrence), privacy: .public)")

        for offset in goal.supervisionOffsets {
            let schedule = alarmSchedule(for: goal, offset: offset, recurrence: recurrence)
            let alarmID = alarmID(for: goal, offset: offset)
            let alert = makeGoalAlarmAlert(title: LocalizedStringResource(stringLiteral: "「\(goal.name)」即将截止"))
            let presentation = AlarmPresentation(alert: alert)
            let attributes = AlarmAttributes(
                presentation: presentation,
                metadata: GoalAlarmMetadata(goalID: goal.id, goalName: goal.name, offset: offset),
                tintColor: .orange
            )
            let configuration = AlarmManager.AlarmConfiguration.alarm(
                schedule: schedule,
                attributes: attributes,
                sound: .default
            )

            do {
                try? AlarmManager.shared.cancel(id: alarmID)
                _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
                didSchedule = true
                let (fireMinutes, dayShift) = supervisionFireTimeComponents(deadlineHour: goal.deadlineHour, deadlineMinute: goal.deadlineMinute, offset: offset)
                Self.logger.info("scheduleAlarmKitSupervision success goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) alarmID=\(alarmID.uuidString, privacy: .public) fireTime=\(String(format: "%02d:%02d", fireMinutes / 60, fireMinutes % 60), privacy: .public) dayShift=\(dayShift, privacy: .public)")
            } catch {
                Self.logger.error("scheduleAlarmKitSupervision failed goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) alarmID=\(alarmID.uuidString, privacy: .public) error=\(error.localizedDescription, privacy: .public)")
                await scheduleAlarmKitFallbackSupervision(for: goal, offset: offset)
                if AlarmManager.shared.authorizationState != .authorized {
                    return false
                }
            }
        }

        return didSchedule
    }

    private func cancelAlarmKitEntries(for goal: Goal) {
        Self.logger.info("cancelAlarmKitEntries goalID=\(goal.id.uuidString, privacy: .public)")
        for offset in goal.supervisionOffsets {
            try? AlarmManager.shared.cancel(id: alarmID(for: goal, offset: offset))
            for date in rollingIdentifierDates() {
                try? AlarmManager.shared.cancel(id: alarmID(for: goal, offset: offset, date: date))
            }
        }
    }

    private func alarmID(for goal: Goal, offset: Int) -> UUID {
        uuidFromString("alarm.\(goal.id.uuidString).\(offset)")
    }

    private func alarmID(for goal: Goal, offset: Int, date: Date) -> UUID {
        uuidFromString("alarm.\(goal.id.uuidString).\(offset).\(identifierDateString(from: date))")
    }

    private func alarmSchedule(
        for goal: Goal,
        offset: Int,
        recurrence: Alarm.Schedule.Relative.Recurrence
    ) -> Alarm.Schedule {
        let (fireMinutes, dayShift) = supervisionFireTimeComponents(deadlineHour: goal.deadlineHour, deadlineMinute: goal.deadlineMinute, offset: offset)
        let time = Alarm.Schedule.Relative.Time(hour: fireMinutes / 60, minute: fireMinutes % 60)
        let shiftedRecurrence = shiftedRecurrence(recurrence, by: dayShift)
        return .relative(.init(time: time, repeats: shiftedRecurrence))
    }

    private func recurrence(for goal: Goal) -> Alarm.Schedule.Relative.Recurrence {
        switch goal.periodType {
        case .daily, .weeklyCount:
            return .weekly([.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday])
        case .weeklyFixedDays:
            let weekdays = goal.selectedWeekdays.compactMap(localeWeekday(from:))
            return weekdays.isEmpty ? .never : .weekly(weekdays)
        }
    }

    private func localeWeekday(from value: Int) -> Locale.Weekday? {
        switch value {
        case 1: .sunday
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        default: nil
        }
    }

    private func shiftedRecurrence(_ recurrence: Alarm.Schedule.Relative.Recurrence, by dayShift: Int) -> Alarm.Schedule.Relative.Recurrence {
        guard dayShift != 0 else { return recurrence }

        switch recurrence {
        case .weekly(let weekdays):
            let shifted = weekdays.map { shiftLocaleWeekday($0, by: dayShift) }
            return .weekly(shifted)
        default:
            return recurrence
        }
    }

    private func shiftLocaleWeekday(_ weekday: Locale.Weekday, by shift: Int) -> Locale.Weekday {
        let ordered: [Locale.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        guard let index = ordered.firstIndex(of: weekday) else { return weekday }
        let normalized = ((index + shift) % ordered.count + ordered.count) % ordered.count
        return ordered[normalized]
    }

    private func scheduleAlarmKitWeeklyCountSupervision(for goal: Goal) async -> Bool {
        let reminderDates = weeklyCountReminderDates(for: goal)
        return await scheduleAlarmKitFixedDatesSupervision(for: goal, dates: reminderDates)
    }

    private func scheduleAlarmKitFixedDatesSupervision(for goal: Goal, dates: [Date]) async -> Bool {
        var didSchedule = false
        Self.logger.info("scheduleAlarmKitFixedDatesSupervision start goalID=\(goal.id.uuidString, privacy: .public) dateCount=\(dates.count, privacy: .public)")

        for date in dates {
            for offset in goal.supervisionOffsets {
                let fireDate = supervisionDate(for: goal, on: date, offset: offset)
                guard fireDate > .now else { continue }

                let alarmID = alarmID(for: goal, offset: offset, date: date)
                let alert = makeGoalAlarmAlert(title: LocalizedStringResource(stringLiteral: "「\(goal.name)」即将截止"))
                let presentation = AlarmPresentation(alert: alert)
                let attributes = AlarmAttributes(
                    presentation: presentation,
                    metadata: GoalAlarmMetadata(goalID: goal.id, goalName: goal.name, offset: offset),
                    tintColor: .orange
                )
                let configuration = AlarmManager.AlarmConfiguration.alarm(
                    schedule: .fixed(fireDate),
                    attributes: attributes,
                    sound: .default
                )

                do {
                    try? AlarmManager.shared.cancel(id: alarmID)
                    _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
                    didSchedule = true
                    Self.logger.info("scheduleAlarmKitFixedDatesSupervision success goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) date=\(self.identifierDateString(from: date), privacy: .public) alarmID=\(alarmID.uuidString, privacy: .public) fireDate=\(fireDate.timeIntervalSince1970, privacy: .public)")
                } catch {
                    Self.logger.error("scheduleAlarmKitFixedDatesSupervision failed goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) date=\(self.identifierDateString(from: date), privacy: .public) alarmID=\(alarmID.uuidString, privacy: .public) error=\(error.localizedDescription, privacy: .public)")
                    await scheduleSupervision(for: goal, offset: offset, date: date)
                    if AlarmManager.shared.authorizationState != .authorized {
                        return false
                    }
                }
            }
        }

        return didSchedule
    }

    private func uuidFromString(_ string: String) -> UUID {
        let utf8 = Array(string.utf8)
        var bytes = [UInt8](repeating: 0, count: 16)

        for (index, byte) in utf8.enumerated() {
            bytes[index % 16] = bytes[index % 16] &+ byte &+ UInt8(index)
        }

        let uuid = uuid_t(bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15])
        return UUID(uuid: uuid)
    }

    private func recurrenceLogText(_ recurrence: Alarm.Schedule.Relative.Recurrence) -> String {
        switch recurrence {
        case .never:
            return "never"
        case .weekly(let weekdays):
            return "weekly:\(weekdays.map { String(describing: $0) }.joined(separator: ","))"
        @unknown default:
            return "unknown"
        }
    }

    private func scheduleAlarmKitFallbackSupervision(for goal: Goal, offset: Int) async {
        switch goal.periodType {
        case .daily:
            await scheduleSupervision(for: goal, offset: offset, weekday: nil)
        case .weeklyFixedDays:
            for weekday in goal.selectedWeekdays {
                await scheduleSupervision(for: goal, offset: offset, weekday: weekday)
            }
        case .weeklyCount:
            break
        }
        Self.logger.info("scheduleAlarmKitFallbackSupervision goalID=\(goal.id.uuidString, privacy: .public) offset=\(offset, privacy: .public) period=\(goal.periodType.rawValue, privacy: .public)")
    }

    private func makeGoalAlarmAlert(title: LocalizedStringResource) -> AlarmPresentation.Alert {
        let stopButton = AlarmButton(
            text: "停止",
            textColor: .white,
            systemImageName: "stop.fill"
        )
        return AlarmPresentation.Alert(title: title, stopButton: stopButton)
    }
}
#endif
