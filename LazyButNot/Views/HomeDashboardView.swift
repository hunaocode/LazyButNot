import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @State private var showingCreateSheet = false

    private var dueGoals: [Goal] {
        goalStore.goals
            .filter { GoalStore.isDueToday($0) }
            .sorted { GoalStore.todayDeadline(for: $0) < GoalStore.todayDeadline(for: $1) }
    }

    private var completedGoals: [Goal] {
        dueGoals.filter { GoalStore.isCompletedToday($0) }
    }

    private var pendingGoals: [Goal] {
        dueGoals.filter { !GoalStore.isCompletedToday($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryCard

                if pendingGoals.isEmpty && completedGoals.isEmpty {
                    EmptyStateView(
                        title: "今天还没有目标",
                        subtitle: "先建立一个最小可执行目标",
                        systemImage: "flag.checkered.2.crossed"
                    )
                } else {
                    if !pendingGoals.isEmpty {
                        sectionTitle("待完成")

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
                        sectionTitle("已完成")

                        ForEach(completedGoals) { goal in
                            NavigationLink {
                                GoalDetailView(goalID: goal.id)
                            } label: {
                                GoalCardView(
                                    goal: goal,
                                    status: GoalStore.completionStatus(for: goal),
                                    weekCount: GoalStore.currentWeekCompletionCount(for: goal),
                                    onComplete: { mark(goal, status: .completed) },
                                    onMinimumComplete: { mark(goal, status: .minimumCompleted) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("今天")
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
    }

    private var summaryCard: some View {
        let progress = GoalStore.todayProgress(goals: goalStore.goals)
        let ratio = progress.total == 0 ? 0 : Double(progress.completed) / Double(progress.total)

        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("连续坚持，比爆发更重要")
                        .font(.title3.bold())
                    Text("今天完成 \(progress.completed) / \(max(progress.total, 1)) 个目标")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ProgressRingView(progress: ratio, lineWidth: 10, size: 84)
            }

            HStack(spacing: 10) {
                statChip(title: "待完成", value: "\(pendingGoals.count)", color: .blue)
                statChip(title: "已完成", value: "\(completedGoals.count)", color: .green)
                statChip(title: "总目标", value: "\(goalStore.goals.count)", color: .orange)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.95), Color.yellow.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .foregroundStyle(.white)
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
