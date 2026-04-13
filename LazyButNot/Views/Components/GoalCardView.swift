import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    let status: CheckInStatus?
    let weekCount: Int
    let onComplete: () -> Void
    let onMinimumComplete: () -> Void

    private var statusText: String {
        status?.rawValue ?? "待完成"
    }

    private var statusColor: Color {
        switch status {
        case .completed: .green
        case .minimumCompleted: .orange
        case .missed: .red
        case nil: .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: goal.category.iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.orange.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.name)
                        .font(.headline)

                    Text(goal.minimumAction)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if goal.periodType == .weeklyCount {
                        Text("本周已完成 \(weekCount)/\(goal.weeklyTargetCount) 次")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("截止时间 \(String(format: "%02d:%02d", goal.deadlineHour, goal.deadlineMinute))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(statusText)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(statusColor.opacity(0.14))
                    )
                    .foregroundStyle(statusColor)
            }

            HStack(spacing: 10) {
                Button("完成", action: onComplete)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                Button("保底完成", action: onMinimumComplete)
                    .buttonStyle(.bordered)
                    .tint(.orange)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
        )
    }
}
