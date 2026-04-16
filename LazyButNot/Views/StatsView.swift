import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore

    private var progress: (completed: Int, total: Int) {
        GoalStore.todayProgress(goals: goalStore.goals)
    }

    var body: some View {
        List {
            Section(String(localized: "stats.section.overview", defaultValue: "总览")) {
                HStack(spacing: 12) {
                    metricCard(title: String(localized: "stats.total_goals", defaultValue: "目标总数"), value: "\(goalStore.goals.count)", color: .orange)
                    metricCard(title: String(localized: "stats.completed_today", defaultValue: "今日完成"), value: "\(progress.completed)/\(max(progress.total, 1))", color: .green)
                }

                HStack(spacing: 12) {
                    metricCard(
                        title: String(localized: "stats.active_goals", defaultValue: "坚持中目标"),
                        value: "\(goalStore.goals.filter { GoalStore.streak(for: $0, allowMinimumCompletion: true) > 0 }.count)",
                        color: .blue
                    )
                    metricCard(
                        title: String(localized: "stats.pending_today", defaultValue: "今日待完成"),
                        value: "\(goalStore.goals.filter { GoalStore.isDueToday($0) && !GoalStore.isCompletedToday($0) }.count)",
                        color: .purple
                    )
                }
            }

            Section(String(localized: "stats.section.by_goal", defaultValue: "按目标")) {
                if goalStore.goals.isEmpty {
                    Text(String(localized: "stats.empty", defaultValue: "还没有目标数据"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(goalStore.goals) { goal in
                        let weekCount = GoalStore.currentWeekCompletionCount(for: goal)
                        let weeklyRemaining = GoalStore.weeklyRemainingCount(for: goal)
                        let totalCheckIns = goal.records.filter { $0.status != .missed }.count

                        VStack(alignment: .leading, spacing: 10) {
                            Text(goal.name)
                                .font(.headline)

                            HStack(spacing: 12) {
                                if goal.periodType == .weeklyCount {
                                    statBlock(String(localized: "stats.weekly_progress", defaultValue: "本周进度"), L10n.weeklyCompletedMetric(weekCount, goal.weeklyTargetCount))
                                    statBlock(String(localized: "stats.weekly_status_label", defaultValue: "本周状态"), weeklyRemaining == 0 ? String(localized: "stats.weekly_status.completed", defaultValue: "已达标") : L10n.weeklyRemaining(weeklyRemaining))
                                    statBlock(String(localized: "stats.total_checkins", defaultValue: "累计打卡"), L10n.timesCount(totalCheckIns))
                                } else {
                                    statBlock(String(localized: "stats.completion_streak", defaultValue: "连续完成"), L10n.dayCount(GoalStore.streak(for: goal, allowMinimumCompletion: false)))
                                    statBlock(String(localized: "stats.consistency_streak", defaultValue: "持续坚持"), L10n.dayCount(GoalStore.streak(for: goal, allowMinimumCompletion: true)))
                                    statBlock(String(localized: "stats.weekly_count", defaultValue: "本周次数"), "\(weekCount)")
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "stats.title", defaultValue: "统计"))
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(themeStore.selectedTheme.palette.screenBackground)
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }

    private func statBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
    }
}
