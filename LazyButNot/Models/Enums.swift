import Foundation

enum GoalCategory: String, CaseIterable, Codable, Identifiable {
    case study = "学习"
    case fitness = "健身"
    case reading = "阅读"
    case routine = "作息"
    case work = "工作"
    case custom = "自定义"

    var id: String { rawValue }

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
    case daily = "每天"
    case weeklyFixedDays = "每周固定日"
    case weeklyCount = "每周次数"

    var id: String { rawValue }
}

enum CheckInStatus: String, CaseIterable, Codable, Identifiable {
    case completed = "完成"
    case minimumCompleted = "保底完成"
    case missed = "未完成"

    var id: String { rawValue }

    var tintName: String {
        switch self {
        case .completed: "green"
        case .minimumCompleted: "orange"
        case .missed: "red"
        }
    }
}
