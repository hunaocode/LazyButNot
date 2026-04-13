import SwiftUI

struct GoalsListView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @State private var showingCreateSheet = false

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
            } else {
                ForEach(goalStore.goals) { goal in
                    NavigationLink {
                        GoalDetailView(goalID: goal.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(goal.name)
                                    .font(.headline)
                                Spacer()
                                if goal.isPaused {
                                    Label("暂停", systemImage: "pause.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Text(goal.minimumAction)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                labelValue("分类", goal.category.rawValue)
                                labelValue("提醒", String(format: "%02d:%02d", goal.reminderHour, goal.reminderMinute))
                                labelValue("持续坚持", "\(GoalStore.streak(for: goal, allowMinimumCompletion: true)) 天")
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteGoals)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("目标")
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

    private func labelValue(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
    }
}
