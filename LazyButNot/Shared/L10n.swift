import Foundation

enum L10n {
    static var appName: String { String(localized: "app.name", defaultValue: "懒人不懒") }
    static var appLaunchSubtitle: String { String(localized: "app.launch.subtitle", defaultValue: "你只需要持续坚持") }

    static var tabHome: String { String(localized: "tab.home", defaultValue: "今日") }
    static var tabGoals: String { String(localized: "tab.goals", defaultValue: "目标") }
    static var tabStats: String { String(localized: "tab.stats", defaultValue: "统计") }
    static var tabSettings: String { String(localized: "tab.settings", defaultValue: "设置") }

    static var countdownDefaultTitle: String {
        String(localized: "countdown.focus_default_title", defaultValue: "专注倒计时")
    }

    static var statusNotDetermined: String {
        String(localized: "status.not_determined", defaultValue: "未决定")
    }

    static var statusDenied: String {
        String(localized: "status.denied", defaultValue: "已拒绝")
    }

    static var statusAuthorized: String {
        String(localized: "status.authorized", defaultValue: "已允许")
    }

    static var statusUnknown: String {
        String(localized: "status.unknown", defaultValue: "未知")
    }

    static var statusProvisional: String {
        String(localized: "status.provisional", defaultValue: "临时允许")
    }

    static var statusEphemeral: String {
        String(localized: "status.ephemeral", defaultValue: "临时会话")
    }

    static var statusEnabled: String {
        String(localized: "status.enabled", defaultValue: "已开启")
    }

    static var statusDisabled: String {
        String(localized: "status.disabled", defaultValue: "已关闭")
    }

    static var statusUnsupported: String {
        String(localized: "status.unsupported", defaultValue: "不支持")
    }

    static var statusActive: String {
        String(localized: "status.active", defaultValue: "进行中")
    }

    static var statusPaused: String {
        String(localized: "status.paused", defaultValue: "已暂停")
    }

    static var statusOn: String {
        String(localized: "common.on", defaultValue: "开启")
    }

    static var statusOff: String {
        String(localized: "common.off", defaultValue: "关闭")
    }

    static var statsWeeklyCompleted: String {
        String(localized: "stats.weekly_completed", defaultValue: "本周完成")
    }

    static var statsWeeklyStatus: String {
        String(localized: "stats.weekly_status", defaultValue: "本周状态")
    }

    static var statsCompletionStreak: String {
        String(localized: "stats.completion_streak", defaultValue: "连续完成")
    }

    static var statsConsistencyStreak: String {
        String(localized: "stats.consistency_streak", defaultValue: "持续坚持")
    }

    static func dayCount(_ count: Int) -> String {
        String(
            format: String(localized: "format.day_count", defaultValue: "%lld 天"),
            locale: .current,
            Int64(count)
        )
    }

    static func minuteCount(_ count: Int) -> String {
        String(
            format: String(localized: "format.minute_count", defaultValue: "%lld 分钟"),
            locale: .current,
            Int64(count)
        )
    }

    static func weeklyTargetCount(_ count: Int) -> String {
        String(
            format: String(localized: "format.weekly_target_count", defaultValue: "每周 %lld 次"),
            locale: .current,
            Int64(count)
        )
    }

    static func timesCount(_ count: Int) -> String {
        String(
            format: String(localized: "format.times_count", defaultValue: "%lld 次"),
            locale: .current,
            Int64(count)
        )
    }

    static func weeklyRemaining(_ count: Int) -> String {
        String(
            format: String(localized: "format.weekly_remaining", defaultValue: "还差 %lld 次"),
            locale: .current,
            Int64(count)
        )
    }

    static func completedSummary(_ completed: Int, _ total: Int) -> String {
        String(
            format: String(localized: "home.completed_summary", defaultValue: "今天完成 %lld / %lld 个目标"),
            locale: .current,
            Int64(completed),
            Int64(total)
        )
    }

    static func weeklyProgressCompact(_ current: Int, _ target: Int) -> String {
        String(
            format: String(localized: "goal.weekly_progress_compact", defaultValue: "本周 %lld/%lld"),
            locale: .current,
            Int64(current),
            Int64(target)
        )
    }

    static func weeklyCompletedMetric(_ current: Int, _ target: Int) -> String {
        String(
            format: String(localized: "goal.weekly_completed_metric", defaultValue: "%lld/%lld"),
            locale: .current,
            Int64(current),
            Int64(target)
        )
    }

    static func deadlineChip(hour: Int, minute: Int) -> String {
        String(
            format: String(localized: "goal.deadline_chip", defaultValue: "截止 %02lld:%02lld"),
            locale: .current,
            Int64(hour),
            Int64(minute)
        )
    }

    static func customMinute(_ minutes: Int) -> String {
        String(
            format: String(localized: "minute.custom_option", defaultValue: "自定义（%lld 分钟）"),
            locale: .current,
            Int64(minutes)
        )
    }

    static func countdownInProgress(_ title: String) -> String {
        String(
            format: String(localized: "countdown.status.in_progress", defaultValue: "%@进行中"),
            locale: .current,
            title
        )
    }

    static func countdownPaused(_ title: String) -> String {
        String(
            format: String(localized: "countdown.status.paused", defaultValue: "%@已暂停"),
            locale: .current,
            title
        )
    }

    static func reminderBody(goalName: String) -> String {
        String(
            format: String(localized: "notification.reminder.body", defaultValue: "现在开始「%@」，先做最小动作也算完成。"),
            locale: .current,
            goalName
        )
    }

    static func supervisionBody(goalName: String, offset: Int) -> String {
        String(
            format: String(localized: "notification.supervision.body", defaultValue: "「%@」将在 %lld 分钟后截止，别忘记完成哦。"),
            locale: .current,
            goalName,
            Int64(offset)
        )
    }

    static func deadlineAlertTitle(goalName: String) -> String {
        String(
            format: String(localized: "notification.deadline_alert.title", defaultValue: "「%@」即将截止"),
            locale: .current,
            goalName
        )
    }

    static func timeHM(hour: Int, minute: Int) -> String {
        String(
            format: String(localized: "format.time_hm", defaultValue: "%02lld:%02lld"),
            locale: .current,
            Int64(hour),
            Int64(minute)
        )
    }

    static func percent(_ value: Int) -> String {
        String(
            format: String(localized: "format.percent", defaultValue: "%lld%%"),
            locale: .current,
            Int64(value)
        )
    }
}
