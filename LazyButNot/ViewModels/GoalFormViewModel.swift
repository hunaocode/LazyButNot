import Combine
import Foundation

final class GoalFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var descriptionText: String = ""
    @Published var category: GoalCategory = .study
    @Published var minimumAction: String = ""
    @Published var periodType: GoalPeriodType = .daily
    @Published var weeklyTargetCount: Int = 3
    @Published var selectedWeekdays: Set<Int> = []
    @Published var reminderDate: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? .now
    @Published var deadlineDate: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? .now
    @Published var supervisionEnabled: Bool = true
    @Published var supervisionOffsets: Set<Int> = [30, 10, 5]
    @Published var ringEnabled: Bool = true
    @Published var isPaused: Bool = false

    init(goal: Goal? = nil) {
        guard let goal else { return }
        name = goal.name
        descriptionText = goal.goalDescription
        category = goal.category
        minimumAction = goal.minimumAction
        periodType = goal.periodType
        weeklyTargetCount = goal.weeklyTargetCount
        selectedWeekdays = Set(goal.selectedWeekdays)
        reminderDate = Calendar.current.date(from: goal.reminderTime) ?? reminderDate
        deadlineDate = Calendar.current.date(from: goal.deadlineTime) ?? deadlineDate
        supervisionEnabled = goal.supervisionEnabled
        supervisionOffsets = Set(goal.supervisionOffsets)
        ringEnabled = goal.ringEnabled
        isPaused = goal.isPaused
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !minimumAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isPeriodValid
    }

    var isPeriodValid: Bool {
        switch periodType {
        case .daily:
            return true
        case .weeklyFixedDays:
            return !selectedWeekdays.isEmpty
        case .weeklyCount:
            return weeklyTargetCount > 0
        }
    }
}
