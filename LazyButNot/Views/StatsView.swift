import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var goalStore: GoalStore

    private var progress: (completed: Int, total: Int) {
        GoalStore.todayProgress(goals: goalStore.goals)
    }

    var body: some View {
        List {
            Section("总览") {
                HStack(spacing: 12) {
                    metricCard(title: "目标总数", value: "\(goalStore.goals.count)", color: .orange)
                    metricCard(title: "今日完成", value: "\(progress.completed)/\(max(progress.total, 1))", color: .green)
                }

                HStack(spacing: 12) {
                    metricCard(
                        title: "坚持中目标",
                        value: "\(goalStore.goals.filter { GoalStore.streak(for: $0, allowMinimumCompletion: true) > 0 }.count)",
                        color: .blue
                    )
                    metricCard(
                        title: "今日待完成",
                        value: "\(goalStore.goals.filter { GoalStore.isDueToday($0) && !GoalStore.isCompletedToday($0) }.count)",
                        color: .purple
                    )
                }
            }

            Section("按目标") {
                if goalStore.goals.isEmpty {
                    Text("还没有目标数据")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(goalStore.goals) { goal in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(goal.name)
                                .font(.headline)

                            HStack(spacing: 12) {
                                statBlock("连续完成", "\(GoalStore.streak(for: goal, allowMinimumCompletion: false)) 天")
                                statBlock("未中断", "\(GoalStore.streak(for: goal, allowMinimumCompletion: true)) 天")
                                statBlock("本周次数", "\(GoalStore.currentWeekCompletionCount(for: goal))")
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("统计")
        .listStyle(.insetGrouped)
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
