import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    private var progress: (completed: Int, total: Int) {
        GoalStore.todayProgress(goals: goalStore.goals)
    }

    var body: some View {
        List {
            Section(String(localized: "stats.section.overview", defaultValue: "总览")) {
                HStack(spacing: 12) {
                    metricCard(
                        title: String(localized: "stats.total_goals", defaultValue: "目标总数"),
                        value: "\(goalStore.goals.count)",
                        accent: palette.accent
                    )
                    metricCard(
                        title: String(localized: "stats.completed_today", defaultValue: "今日完成"),
                        value: "\(progress.completed)/\(max(progress.total, 1))",
                        accent: palette.accentSecondary
                    )
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                HStack(spacing: 12) {
                    metricCard(
                        title: String(localized: "stats.active_goals", defaultValue: "坚持中目标"),
                        value: "\(goalStore.goals.filter { GoalStore.streak(for: $0, allowMinimumCompletion: true) > 0 }.count)",
                        accent: palette.chipText
                    )
                    metricCard(
                        title: String(localized: "stats.pending_today", defaultValue: "今日待完成"),
                        value: "\(goalStore.goals.filter { GoalStore.isDueToday($0) && !GoalStore.isCompletedToday($0) }.count)",
                        accent: palette.secondaryText
                    )
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section(String(localized: "stats.section.by_goal", defaultValue: "按目标")) {
                if goalStore.goals.isEmpty {
                    EmptyStateView(
                        title: String(localized: "stats.empty", defaultValue: "还没有目标数据"),
                        subtitle: String(localized: "goals.empty.subtitle", defaultValue: "把大目标拆成最小动作，再交给提醒系统去盯。"),
                        systemImage: "chart.bar.xaxis"
                    )
                        .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(goalStore.goals) { goal in
                        let weekCount = GoalStore.currentWeekCompletionCount(for: goal)
                        let weeklyRemaining = GoalStore.weeklyRemainingCount(for: goal)
                        let totalCheckIns = goal.records.filter { $0.status != .missed }.count

                        VStack(alignment: .leading, spacing: 10) {
                            Text(goal.name)
                                .font(.headline)
                                .foregroundStyle(palette.primaryText)

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
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(palette.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .stroke(palette.border, lineWidth: 1)
                                )
                                .shadow(color: palette.shadow, radius: 14, y: 8)
                        )
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "stats.title", defaultValue: "统计"))
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(themeStore.selectedTheme.palette.screenBackground)
    }

    private func metricCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(palette.subtleText)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .shadow(color: palette.shadow, radius: 12, y: 7)
        )
    }

    private func statBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(palette.subtleText)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(palette.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.chipFill)
        )
    }
}
