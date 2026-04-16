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
                let weekCount = GoalStore.currentWeekCompletionCount(for: goal)
                let weeklyRemaining = GoalStore.weeklyRemainingCount(for: goal)

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
                        if goal.periodType == .weeklyCount {
                            metricCard(L10n.statsWeeklyCompleted, L10n.weeklyCompletedMetric(weekCount, goal.weeklyTargetCount), color: .green)
                            metricCard(L10n.statsWeeklyStatus, weeklyRemaining == 0 ? String(localized: "stats.weekly_status.completed", defaultValue: "已达标") : L10n.weeklyRemaining(weeklyRemaining), color: .orange)
                        } else {
                            metricCard(L10n.statsCompletionStreak, L10n.dayCount(GoalStore.streak(for: goal, allowMinimumCompletion: false)), color: .green)
                            metricCard(L10n.statsConsistencyStreak, L10n.dayCount(GoalStore.streak(for: goal, allowMinimumCompletion: true)), color: .orange)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section(String(localized: "goal_detail.section.rules", defaultValue: "规则")) {
                detailRow(String(localized: "goal.minimum_action", defaultValue: "最小动作"), goal.minimumAction)
                detailRow(String(localized: "goal.schedule", defaultValue: "周期"), goal.periodType.localizedTitle)
                if goal.periodType == .weeklyCount {
                    detailRow(String(localized: "goal.weekly_target", defaultValue: "每周目标"), L10n.timesCount(goal.weeklyTargetCount))
                }
                if goal.periodType == .weeklyFixedDays {
                    detailRow(String(localized: "goal.fixed_days", defaultValue: "固定日期"), weekdayText(goal.selectedWeekdays))
                }
                detailRow(String(localized: "goal.reminder_time", defaultValue: "提醒时间"), L10n.timeHM(hour: goal.reminderHour, minute: goal.reminderMinute))
                detailRow(String(localized: "goal.deadline_time", defaultValue: "截止时间"), L10n.timeHM(hour: goal.deadlineHour, minute: goal.deadlineMinute))
                detailRow(String(localized: "goal.supervision_reminder", defaultValue: "监督提醒"), goal.supervisionEnabled ? L10n.statusOn : L10n.statusOff)
                if goal.supervisionEnabled {
                    detailRow(alarmStatusLabel, goal.ringEnabled ? alarmStatusValue : L10n.statusOff)
                }
                detailRow(String(localized: "goal.pause_status", defaultValue: "暂停状态"), goal.isPaused ? L10n.statusPaused : L10n.statusActive)
            }

            Section(String(localized: "goal_detail.section.today_actions", defaultValue: "今天操作")) {
                Button(String(localized: "goal.action.mark_completed", defaultValue: "标记完成")) {
                    mark(.completed)
                }
                .foregroundStyle(.green)

                Button(String(localized: "goal.action.mark_minimum_completed", defaultValue: "标记保底完成")) {
                    mark(.minimumCompleted)
                }
                .foregroundStyle(.orange)

                Button(goal.isPaused ? String(localized: "goal.action.resume_reminder", defaultValue: "恢复提醒") : String(localized: "goal.action.pause_reminder", defaultValue: "暂停提醒")) {
                    togglePause(goalID: goal.id)
                }
            }

            Section(String(localized: "goal_detail.section.history", defaultValue: "历史记录")) {
                let sortedRecords = goal.records.sorted { $0.date > $1.date }
                if sortedRecords.isEmpty {
                    Text(String(localized: "goal_detail.empty_history", defaultValue: "还没有打卡记录"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedRecords) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text(record.status.localizedTitle)
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
                Button(String(localized: "goal.action.delete", defaultValue: "删除目标"), role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
            } else {
                ContentUnavailableView(String(localized: "goal_detail.missing_goal", defaultValue: "目标不存在"), systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(String(localized: "goal_detail.title", defaultValue: "目标详情"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "common.edit", defaultValue: "编辑")) {
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
        .confirmationDialog(String(localized: "goal_detail.delete_confirmation", defaultValue: "删除后将移除该目标及历史记录"), isPresented: $showingDeleteConfirmation) {
            Button(String(localized: "common.delete", defaultValue: "删除"), role: .destructive) {
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
        let labels: [Int: String] = [
            1: String(localized: "weekday.sun", defaultValue: "周日"),
            2: String(localized: "weekday.mon", defaultValue: "周一"),
            3: String(localized: "weekday.tue", defaultValue: "周二"),
            4: String(localized: "weekday.wed", defaultValue: "周三"),
            5: String(localized: "weekday.thu", defaultValue: "周四"),
            6: String(localized: "weekday.fri", defaultValue: "周五"),
            7: String(localized: "weekday.sat", defaultValue: "周六"),
        ]

        return weekdays
            .compactMap { labels[$0] }
            .joined(separator: "、")
    }

    private var alarmStatusLabel: String {
        if #available(iOS 26.0, *) {
            return String(localized: "goal.alarm_style_reminder", defaultValue: "闹钟式提醒")
        }
        return String(localized: "goal.reminder_sound", defaultValue: "提醒声音")
    }

    private var alarmStatusValue: String {
        if #available(iOS 26.0, *) {
            return L10n.statusOn
        }
        return String(localized: "goal.single_notification_sound", defaultValue: "单次通知音")
    }
}
