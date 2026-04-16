import Foundation

enum GoalCategory: String, CaseIterable, Codable, Identifiable {
    case study = "study"
    case fitness = "fitness"
    case reading = "reading"
    case routine = "routine"
    case work = "work"
    case custom = "custom"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .study:
            String(localized: "enum.goal_category.study", defaultValue: "学习")
        case .fitness:
            String(localized: "enum.goal_category.fitness", defaultValue: "健身")
        case .reading:
            String(localized: "enum.goal_category.reading", defaultValue: "阅读")
        case .routine:
            String(localized: "enum.goal_category.routine", defaultValue: "作息")
        case .work:
            String(localized: "enum.goal_category.work", defaultValue: "工作")
        case .custom:
            String(localized: "enum.goal_category.custom", defaultValue: "自定义")
        }
    }

    var iconName: String {
        switch self {
        case .study: "brain.head.profile"
        case .fitness: "figure.strengthtraining.traditional"
        case .reading: "book.closed"
        case .routine: "moon.stars"
        case .work: "briefcase"
        case .custom: "sparkles"
        }
    }
}

enum GoalPeriodType: String, CaseIterable, Codable, Identifiable {
    case daily = "daily"
    case weeklyFixedDays = "weekly_fixed_days"
    case weeklyCount = "weekly_count"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .daily:
            String(localized: "enum.goal_period_type.daily", defaultValue: "每天")
        case .weeklyFixedDays:
            String(localized: "enum.goal_period_type.weekly_fixed_days", defaultValue: "每周固定日")
        case .weeklyCount:
            String(localized: "enum.goal_period_type.weekly_count", defaultValue: "每周次数")
        }
    }
}

enum CheckInStatus: String, CaseIterable, Codable, Identifiable {
    case completed = "completed"
    case minimumCompleted = "minimum_completed"
    case missed = "missed"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .completed:
            String(localized: "enum.checkin_status.completed", defaultValue: "完成")
        case .minimumCompleted:
            String(localized: "enum.checkin_status.minimum_completed", defaultValue: "保底完成")
        case .missed:
            String(localized: "enum.checkin_status.missed", defaultValue: "未完成")
        }
    }

    var localizedBadgeTitle: String {
        switch self {
        case .completed:
            String(localized: "goal.badge.checked", defaultValue: "已打卡")
        case .minimumCompleted:
            String(localized: "goal.badge.minimum_checked", defaultValue: "已保底打卡")
        case .missed:
            localizedTitle
        }
    }

    var tintName: String {
        switch self {
        case .completed: "green"
        case .minimumCompleted: "orange"
        case .missed: "red"
        }
    }
}
