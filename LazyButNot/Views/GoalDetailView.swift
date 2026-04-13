import SwiftUI

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var goalStore: GoalStore
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    let goalID: UUID

    var body: some View {
        Group {
            if let goal = goalStore.goal(withID: goalID) {
                List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text(goal.name)
                        .font(.title2.bold())

                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        metricCard("连续完成", "\(GoalStore.streak(for: goal, allowMinimumCompletion: false)) 天", color: .green)
                        metricCard("连续坚持", "\(GoalStore.streak(for: goal, allowMinimumCompletion: true)) 天", color: .orange)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("规则") {
                detailRow("最小动作", goal.minimumAction)
                detailRow("周期", goal.periodType.rawValue)
                if goal.periodType == .weeklyCount {
                    detailRow("每周目标", "\(goal.weeklyTargetCount) 次")
                }
                if goal.periodType == .weeklyFixedDays {
                    detailRow("固定日期", weekdayText(goal.selectedWeekdays))
                }
                detailRow("提醒时间", String(format: "%02d:%02d", goal.reminderHour, goal.reminderMinute))
                detailRow("截止时间", String(format: "%02d:%02d", goal.deadlineHour, goal.deadlineMinute))
                detailRow("监督提醒", goal.supervisionEnabled ? "开启" : "关闭")
                detailRow("暂停状态", goal.isPaused ? "已暂停" : "进行中")
            }

            Section("今天操作") {
                Button("标记完成") {
                    mark(.completed)
                }
                .foregroundStyle(.green)

                Button("标记保底完成") {
                    mark(.minimumCompleted)
                }
                .foregroundStyle(.orange)

                Button(goal.isPaused ? "恢复提醒" : "暂停提醒") {
                    togglePause(goalID: goal.id)
                }
            }

            Section("历史记录") {
                let sortedRecords = goal.records.sorted { $0.date > $1.date }
                if sortedRecords.isEmpty {
                    Text("还没有打卡记录")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedRecords) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text(record.status.rawValue)
                                    .font(.caption.bold())
                                    .foregroundStyle(color(for: record.status))
                            }
                            if !record.note.isEmpty {
                                Text(record.note)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section {
                Button("删除目标", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
            } else {
                ContentUnavailableView("目标不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("目标详情")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let goal = goalStore.goal(withID: goalID) {
                NavigationStack {
                    GoalFormView(goal: goal)
                }
            }
        }
        .confirmationDialog("删除后将移除该目标及历史记录", isPresented: $showingDeleteConfirmation) {
            Button("删除", role: .destructive) {
                deleteGoal(goalID: goalID)
            }
        }
    }

    private func mark(_ status: CheckInStatus) {
        goalStore.addCheckIn(for: goalID, status: status)
        if let goal = goalStore.goal(withID: goalID) {
            Task {
                NotificationManager.shared.removeNotifications(for: goal)
                await NotificationManager.shared.scheduleNotifications(for: goal)
            }
        }
    }

    private func togglePause(goalID: UUID) {
        goalStore.togglePause(for: goalID)

        if let goal = goalStore.goal(withID: goalID) {
            Task {
                if goal.isPaused {
                    NotificationManager.shared.removeNotifications(for: goal)
                } else {
                    await NotificationManager.shared.scheduleNotifications(for: goal)
                }
            }
        }
    }

    private func deleteGoal(goalID: UUID) {
        if let goal = goalStore.goal(withID: goalID) {
            NotificationManager.shared.removeNotifications(for: goal)
            goalStore.delete(goalID: goalID)
        }
        dismiss()
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func metricCard(_ title: String, _ value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }

    private func color(for status: CheckInStatus) -> Color {
        switch status {
        case .completed: .green
        case .minimumCompleted: .orange
        case .missed: .red
        }
    }

    private func weekdayText(_ weekdays: [Int]) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return weekdays
            .compactMap { weekday in
                guard weekday > 0, weekday <= symbols.count else { return nil }
                return symbols[weekday - 1]
            }
            .joined(separator: "、")
    }
}
