import Combine
import Foundation

@MainActor
final class GoalStore: ObservableObject {
    @Published private(set) var goals: [Goal] = []

    private let saveURL: URL

    init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = baseURL.appendingPathComponent("LazyButNot", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        self.saveURL = directoryURL.appendingPathComponent("goals.json")
        load()
    }

    func goal(withID id: UUID) -> Goal? {
        goals.first(where: { $0.id == id })
    }

    @discardableResult
    func saveGoal(
        existingGoalID: UUID? = nil,
        name: String,
        description: String,
        category: GoalCategory,
        minimumAction: String,
        periodType: GoalPeriodType,
        weeklyTargetCount: Int,
        selectedWeekdays: [Int],
        reminderDate: Date,
        deadlineDate: Date,
        supervisionEnabled: Bool,
        supervisionOffsets: [Int],
        ringEnabled: Bool,
        isPaused: Bool
    ) -> Goal {
        let calendar = Calendar.current
        let reminderComponents = calendar.dateComponents([.hour, .minute], from: reminderDate)
        let deadlineComponents = calendar.dateComponents([.hour, .minute], from: deadlineDate)

        var goal = existingGoalID.flatMap(goal(withID:)) ?? Goal(
            name: name,
            goalDescription: description,
            category: category,
            minimumAction: minimumAction,
            periodType: periodType
        )

        goal.name = name
        goal.goalDescription = description
        goal.category = category
        goal.minimumAction = minimumAction
        goal.periodType = periodType
        goal.weeklyTargetCount = weeklyTargetCount
        goal.selectedWeekdays = selectedWeekdays.sorted()
        goal.reminderHour = reminderComponents.hour ?? 19
        goal.reminderMinute = reminderComponents.minute ?? 0
        goal.deadlineHour = deadlineComponents.hour ?? 22
        goal.deadlineMinute = deadlineComponents.minute ?? 0
        goal.supervisionEnabled = supervisionEnabled
        goal.supervisionOffsets = supervisionOffsets.sorted(by: >)
        goal.ringEnabled = ringEnabled
        goal.isPaused = isPaused
        goal.updatedAt = .now

        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        } else {
            goals.insert(goal, at: 0)
        }

        persist()
        return goal
    }

    func addCheckIn(for goalID: UUID, status: CheckInStatus, on date: Date = .now, note: String = "") {
        guard let index = goals.firstIndex(where: { $0.id == goalID }) else { return }

        if let recordIndex = goals[index].records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            goals[index].records[recordIndex].status = status
            goals[index].records[recordIndex].note = note
            goals[index].records[recordIndex].createdAt = .now
        } else {
            let record = CheckInRecord(date: date, status: status, note: note)
            goals[index].records.append(record)
        }

        goals[index].records.sort { $0.date > $1.date }
        goals[index].updatedAt = .now
        persist()
    }

    func togglePause(for goalID: UUID) {
        guard let index = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[index].isPaused.toggle()
        goals[index].updatedAt = .now
        persist()
    }

    func delete(goalID: UUID) {
        goals.removeAll(where: { $0.id == goalID })
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else {
            goals = []
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let decoded = try? decoder.decode([Goal].self, from: data) {
            goals = decoded
        } else {
            goals = []
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(goals)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            assertionFailure("Persist failed: \(error)")
        }
    }
}

extension GoalStore {
    static func record(for goal: Goal, on date: Date, calendar: Calendar = .current) -> CheckInRecord? {
        goal.records.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }

    static func isDueToday(_ goal: Goal, on date: Date = .now, calendar: Calendar = .current) -> Bool {
        guard !goal.isPaused else { return false }

        let weekday = calendar.component(.weekday, from: date)
        switch goal.periodType {
        case .daily:
            return true
        case .weeklyFixedDays:
            return goal.selectedWeekdays.contains(weekday)
        case .weeklyCount:
            return true
        }
    }

    static func isCompletedToday(_ goal: Goal, on date: Date = .now, calendar: Calendar = .current) -> Bool {
        guard let record = record(for: goal, on: date, calendar: calendar) else { return false }
        return record.status != .missed
    }

    static func completionStatus(for goal: Goal, on date: Date = .now, calendar: Calendar = .current) -> CheckInStatus? {
        record(for: goal, on: date, calendar: calendar)?.status
    }

    static func todayProgress(goals: [Goal], on date: Date = .now, calendar: Calendar = .current) -> (completed: Int, total: Int) {
        let dueGoals = goals.filter { isDueToday($0, on: date, calendar: calendar) }
        let completed = dueGoals.filter { isCompletedToday($0, on: date, calendar: calendar) }.count
        return (completed, dueGoals.count)
    }

    static func currentWeekCompletionCount(for goal: Goal, on date: Date = .now, calendar: Calendar = .current) -> Int {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        return goal.records.filter { interval.contains($0.date) && $0.status != .missed }.count
    }

    static func streak(for goal: Goal, allowMinimumCompletion: Bool, calendar: Calendar = .current) -> Int {
        let sortedRecords = goal.records.sorted { $0.date > $1.date }
        guard !sortedRecords.isEmpty else { return 0 }

        var streak = 0
        var currentDate = calendar.startOfDay(for: .now)

        while true {
            if let record = sortedRecords.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                let matches = allowMinimumCompletion
                    ? (record.status == .completed || record.status == .minimumCompleted)
                    : (record.status == .completed)

                if matches {
                    streak += 1
                    guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                    currentDate = previousDay
                    continue
                }
            } else if calendar.isDateInToday(currentDate),
                      let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                currentDate = previousDay
                continue
            }

            break
        }

        return streak
    }

    static func todayDeadline(for goal: Goal, on date: Date = .now, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(
            from: DateComponents(
                year: components.year,
                month: components.month,
                day: components.day,
                hour: goal.deadlineHour,
                minute: goal.deadlineMinute
            )
        ) ?? date
    }
}
