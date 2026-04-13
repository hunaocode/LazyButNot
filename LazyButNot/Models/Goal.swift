import Foundation

struct Goal: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var goalDescription: String
    var category: GoalCategory
    var minimumAction: String
    var periodType: GoalPeriodType
    var weeklyTargetCount: Int
    var selectedWeekdays: [Int]
    var reminderHour: Int
    var reminderMinute: Int
    var deadlineHour: Int
    var deadlineMinute: Int
    var supervisionEnabled: Bool
    var supervisionOffsets: [Int]
    var ringEnabled: Bool
    var isPaused: Bool
    var createdAt: Date = .now
    var updatedAt: Date = .now
    var records: [CheckInRecord] = []

    init(
        id: UUID = UUID(),
        name: String,
        goalDescription: String,
        category: GoalCategory,
        minimumAction: String,
        periodType: GoalPeriodType,
        weeklyTargetCount: Int = 1,
        selectedWeekdays: [Int] = [],
        reminderHour: Int = 19,
        reminderMinute: Int = 0,
        deadlineHour: Int = 22,
        deadlineMinute: Int = 0,
        supervisionEnabled: Bool = true,
        supervisionOffsets: [Int] = [30, 10, 5],
        ringEnabled: Bool = true,
        isPaused: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        records: [CheckInRecord] = []
    ) {
        self.id = id
        self.name = name
        self.goalDescription = goalDescription
        self.category = category
        self.minimumAction = minimumAction
        self.periodType = periodType
        self.weeklyTargetCount = weeklyTargetCount
        self.selectedWeekdays = selectedWeekdays
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.deadlineHour = deadlineHour
        self.deadlineMinute = deadlineMinute
        self.supervisionEnabled = supervisionEnabled
        self.supervisionOffsets = supervisionOffsets
        self.ringEnabled = ringEnabled
        self.isPaused = isPaused
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.records = records
    }

    var reminderTime: DateComponents {
        DateComponents(hour: reminderHour, minute: reminderMinute)
    }

    var deadlineTime: DateComponents {
        DateComponents(hour: deadlineHour, minute: deadlineMinute)
    }
}
