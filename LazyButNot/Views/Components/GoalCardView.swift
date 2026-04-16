import SwiftUI

struct GoalCardView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    let goal: Goal
    let status: CheckInStatus?
    let weekCount: Int
    var navigatesToDetail: Bool = true
    let onComplete: () -> Void
    let onMinimumComplete: () -> Void

    private var statusText: String {
        status?.localizedTitle ?? String(localized: "goal.status.pending", defaultValue: "待完成")
    }

    private var statusColor: Color {
        switch status {
        case .completed: .green
        case .minimumCompleted: .orange
        case .missed: .red
        case nil: .blue
        }
    }

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    private var isCompletedState: Bool {
        status == .completed || status == .minimumCompleted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if navigatesToDetail {
                NavigationLink {
                    GoalDetailView(goalID: goal.id)
                } label: {
                    summaryContent(showsChevron: true)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            } else {
                summaryContent(showsChevron: false)
            }

            actionArea
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .shadow(color: palette.shadow, radius: 16, y: 10)
        )
    }

    private func summaryContent(showsChevron: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: goal.category.iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(palette.iconBackground)
                    )

                VStack(alignment: .leading, spacing: 7) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(palette.primaryText)

                    Text(goal.minimumAction)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(palette.subtleText)
                        .padding(.top, 4)
                }
            }

            HStack(spacing: 8) {
                chip(text: goal.category.localizedTitle)
                if goal.periodType == .weeklyCount {
                    chip(text: L10n.weeklyProgressCompact(weekCount, goal.weeklyTargetCount))
                } else {
                    chip(text: L10n.deadlineChip(hour: goal.deadlineHour, minute: goal.deadlineMinute))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func chip(text: String) -> some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.chipFill)
            )
            .foregroundStyle(palette.chipText)
    }

    @ViewBuilder
    private var actionArea: some View {
        if isCompletedState {
            Group {
                if navigatesToDetail {
                    NavigationLink {
                        GoalDetailView(goalID: goal.id)
                    } label: {
                        completedBadge
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                } else {
                    completedBadge
                }
            }
        } else {
            HStack(spacing: 10) {
                Button(String(localized: "goal.action.complete_short", defaultValue: "完成"), action: onComplete)
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(palette.accent)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(String(localized: "goal.action.minimum_complete_short", defaultValue: "保底完成"), action: onMinimumComplete)
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.68))
                    .foregroundStyle(palette.primaryText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(palette.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var completedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: status == .completed ? "checkmark.circle.fill" : "checkmark.seal.fill")
                .font(.subheadline.weight(.semibold))
            Text(status?.localizedBadgeTitle ?? String(localized: "goal.status.pending", defaultValue: "待完成"))
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(palette.accent.opacity(0.14))
        .foregroundStyle(palette.accent)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.accent.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
