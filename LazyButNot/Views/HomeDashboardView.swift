import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var showingCreateSheet = false
    @State private var showingCountdownSheet = false

    private var todayGoals: [Goal] {
        goalStore.goals
            .filter { GoalStore.isDueToday($0) || GoalStore.isCompletedToday($0) }
            .sorted { GoalStore.todayDeadline(for: $0) < GoalStore.todayDeadline(for: $1) }
    }

    private var completedGoals: [Goal] {
        todayGoals.filter { GoalStore.isCompletedToday($0) }
    }

    private var pendingGoals: [Goal] {
        todayGoals.filter { GoalStore.isDueToday($0) && !GoalStore.isCompletedToday($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryCard

                if pendingGoals.isEmpty && completedGoals.isEmpty {
                    EmptyStateView(
                        title: String(localized: "home.empty_today.title", defaultValue: "今天还没有目标"),
                        subtitle: String(localized: "home.empty_today.subtitle", defaultValue: "先建立一个最小可执行目标"),
                        systemImage: "flag.checkered.2.crossed"
                    )
                } else {
                    if !pendingGoals.isEmpty {
                        sectionTitle(String(localized: "home.section.pending", defaultValue: "待完成"))

                        ForEach(pendingGoals) { goal in
                            GoalCardView(
                                goal: goal,
                                status: GoalStore.completionStatus(for: goal),
                                weekCount: GoalStore.currentWeekCompletionCount(for: goal),
                                onComplete: { mark(goal, status: .completed) },
                                onMinimumComplete: { mark(goal, status: .minimumCompleted) }
                            )
                        }
                    }

                    if !completedGoals.isEmpty {
                        sectionTitle(String(localized: "home.section.completed", defaultValue: "已完成"))

                        ForEach(completedGoals) { goal in
                            GoalCardView(
                                goal: goal,
                                status: GoalStore.completionStatus(for: goal),
                                weekCount: GoalStore.currentWeekCompletionCount(for: goal),
                                onComplete: { mark(goal, status: .completed) },
                                onMinimumComplete: { mark(goal, status: .minimumCompleted) }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .background(themeStore.selectedTheme.palette.screenBackground)
        .navigationTitle(String(localized: "home.title", defaultValue: "今天"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            NavigationStack {
                GoalFormView()
            }
        }
        .sheet(isPresented: $showingCountdownSheet) {
            CountdownAlarmSheet()
        }
    }

    private var summaryCard: some View {
        let palette = themeStore.selectedTheme.palette
        let completed = completedGoals.count
        let total = todayGoals.count
        let ratio = total == 0 ? 0 : Double(completed) / Double(total)

        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "home.summary.headline", defaultValue: "持续坚持，比爆发更重要"))
                        .font(.title3.bold())
                    Text(L10n.completedSummary(completed, max(total, 1)))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ProgressRingView(progress: ratio, lineWidth: 10, size: 84)
            }

            HStack(spacing: 10) {
                statChip(title: String(localized: "home.section.pending", defaultValue: "待完成"), value: "\(pendingGoals.count)", color: .blue)
                statChip(title: String(localized: "home.section.completed", defaultValue: "已完成"), value: "\(completedGoals.count)", color: .green)
                statChip(title: String(localized: "home.total_goals", defaultValue: "总目标"), value: "\(goalStore.goals.count)", color: .orange)
            }

            Button {
                showingCountdownSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "timer")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "home.focus_mode.title", defaultValue: "开启专注模式"))
                            .font(.headline)
                        Text(String(localized: "home.focus_mode.subtitle", defaultValue: "支持锁屏、灵动岛与待机显示"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .padding(14)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(palette.detailBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .foregroundStyle(.white)
        .shadow(color: palette.shadow, radius: 18, y: 12)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .padding(.top, 6)
    }

    private func statChip(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
            Text(value)
                .font(.headline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func mark(_ goal: Goal, status: CheckInStatus) {
        goalStore.addCheckIn(for: goal.id, status: status)
        if let refreshed = goalStore.goal(withID: goal.id) {
            Task {
                NotificationManager.shared.removeNotifications(for: refreshed)
                await NotificationManager.shared.scheduleNotifications(for: refreshed)
            }
        }
    }
}
