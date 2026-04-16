import SwiftUI

struct GoalsListView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var showingCreateSheet = false
    @State private var selectedGoalID: UUID?

    var body: some View {
        List {
            if goalStore.goals.isEmpty {
                EmptyStateView(
                    title: "还没有目标",
                    subtitle: "把大目标拆成最小动作，再交给提醒系统去盯。",
                    systemImage: "list.bullet.clipboard"
                )
                .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(goalStore.goals) { goal in
                    Button {
                        selectedGoalID = goal.id
                    } label: {
                        goalRowCard(goal)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteGoals)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(themeStore.selectedTheme.palette.screenBackground)
        .navigationTitle("目标")
        .navigationDestination(item: $selectedGoalID) { goalID in
            GoalDetailView(goalID: goalID)
        }
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

    private func deleteGoals(at offsets: IndexSet) {
        for index in offsets {
            let goal = goalStore.goals[index]
            NotificationManager.shared.removeNotifications(for: goal)
            goalStore.delete(goalID: goal.id)
        }
    }

    private func goalRowCard(_ goal: Goal) -> some View {
        let palette = themeStore.selectedTheme.palette
        let weekCount = GoalStore.currentWeekCompletionCount(for: goal)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.iconBackground)
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: goal.category.iconName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(goal.name)
                            .font(.headline)
                            .foregroundStyle(palette.primaryText)
                        if goal.isPaused {
                            statusTag("暂停")
                        }
                    }

                    Text(goal.minimumAction)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                infoPill(title: "分类", value: goal.category.rawValue)
                infoPill(title: "提醒", value: String(format: "%02d:%02d", goal.reminderHour, goal.reminderMinute))
                if goal.periodType == .weeklyCount {
                    infoPill(title: "本周", value: "\(weekCount)/\(goal.weeklyTargetCount)")
                } else {
                    infoPill(title: "坚持", value: "\(GoalStore.streak(for: goal, allowMinimumCompletion: true)) 天")
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
                .shadow(color: palette.shadow, radius: 16, y: 10)
        )
    }

    private func statusTag(_ text: String) -> some View {
        let palette = themeStore.selectedTheme.palette
        return Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.chipFill)
            )
            .foregroundStyle(palette.chipText)
    }

    private func infoPill(title: String, value: String) -> some View {
        let palette = themeStore.selectedTheme.palette
        return VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(palette.subtleText)
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(palette.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}
