import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

struct LazyButNotAlarmLiveActivity: Widget {
    private let focusCountdownURL = URL(string: "lazybutnot://countdown/focus")!

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CountdownAlarmMetadata>.self) { context in
            lockScreenView(for: context)
                .activityBackgroundTint(activitySurfaceColor)
                .activitySystemActionForegroundColor(.white)
                .widgetURL(focusCountdownURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    expandedLeadingView(for: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    expandedTrailingView(for: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedBottomView(for: context)
                }
            } compactLeading: {
                compactLeadingView(for: context)
            } compactTrailing: {
                compactTrailingView(for: context)
            } minimal: {
                minimalView(for: context)
            }
            .keylineTint(brandHighlightColor(for: context))
            .widgetURL(focusCountdownURL)
        }
    }

    @ViewBuilder
    private func lockScreenView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                leadingIconView(for: context, size: 44, iconSize: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.metadata?.title ?? "倒计时闹钟")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(titleColor)
                        .lineLimit(1)

                    Text(statusTitle(for: context))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(subtitleColor)
                        .lineLimit(1)
                }

                Spacer(minLength: 12)

                statusBadge(for: context)
            }

            bottomContent(for: context, isCompact: false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(lockScreenBackground(for: context))
    }

    private func expandedLeadingView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        HStack(spacing: 10) {
            leadingIconView(for: context, size: 28, iconSize: 13)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.metadata?.title ?? "倒计时")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(titleColor)
                    .lineLimit(1)

                Text(statusBadgeText(for: context))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
            }
        }
        .padding(.leading, 6)
        .padding(.top, 4)
    }

    private func expandedTrailingView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        statusBadge(for: context)
            .padding(.trailing, 6)
            .padding(.top, 4)
    }

    private func expandedBottomView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        bottomContent(for: context, isCompact: true)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func compactLeadingView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        leadingIconView(for: context, size: 22, iconSize: 11)
    }

    @ViewBuilder
    private func compactTrailingView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        switch context.state.mode {
        case .countdown(let countdown):
            Text(timerText(for: countdown))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(brandHighlightColor(for: context))
        case .paused(let paused):
            Text(shortDurationText(for: remainingDuration(paused)))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(brandHighlightColor(for: context))
        case .alert:
            Image(systemName: "bell.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(brandHighlightColor(for: context))
        @unknown default:
            Image(systemName: "bell.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(brandHighlightColor(for: context))
        }
    }

    private func minimalView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        ZStack {
            Circle()
                .fill(brandHighlightColor(for: context).opacity(0.22))
            Image(systemName: iconName(for: context))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(brandHighlightColor(for: context))
        }
        .frame(width: 26, height: 26)
    }

    @ViewBuilder
    private func bottomContent(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>,
        isCompact: Bool
    ) -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            timerPanel(for: context, isCompact: isCompact)
        }
    }

    @ViewBuilder
    private func timerPanel(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>,
        isCompact: Bool
    ) -> some View {
        switch context.state.mode {
        case .countdown(let countdown):
            timerContent(
                value: .countdown(startDate: countdown.startDate, endDate: countdown.fireDate),
                isCompact: isCompact,
                accentColor: brandHighlightColor(for: context)
            )
        case .paused(let paused):
            timerContent(
                value: .staticText(shortDurationText(for: remainingDuration(paused))),
                isCompact: isCompact,
                accentColor: pausedAccentColor
            )
        case .alert:
            alertPanel(for: context, isCompact: isCompact)
        @unknown default:
            alertPanel(for: context, isCompact: isCompact)
        }
    }

    private func timerContent(
        value: TimerPanelValue,
        isCompact: Bool,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            switch value {
            case .countdown(let startDate, let endDate):
                Text(timerInterval: startDate...endDate, countsDown: true)
                    .font(.system(size: isCompact ? 32 : 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            case .staticText(let text):
                Text(text)
                    .font(.system(size: isCompact ? 32 : 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, isCompact ? 0 : 2)
    }

    private func alertPanel(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>,
        isCompact: Bool
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(alertAccentColor.opacity(0.18))
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                    .foregroundStyle(alertAccentColor)
            }
            .frame(width: isCompact ? 36 : 40, height: isCompact ? 36 : 40)

            VStack(alignment: .leading, spacing: 3) {
                Text("时间到了")
                    .font(.system(size: isCompact ? 16 : 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.98))
                Text("请及时处理这次提醒")
                    .font(.system(size: isCompact ? 12 : 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.64))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, isCompact ? 14 : 16)
        .padding(.vertical, isCompact ? 12 : 14)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 18 : 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.33, green: 0.15, blue: 0.14),
                            Color(red: 0.18, green: 0.09, blue: 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 18 : 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func statusBadge(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        Text(statusBadgeText(for: context))
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(brandHighlightColor(for: context))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(brandHighlightColor(for: context).opacity(0.16))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(brandHighlightColor(for: context).opacity(0.28), lineWidth: 1)
                    )
            )
    }

    private func leadingIconView(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>,
        size: CGFloat,
        iconSize: CGFloat
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            brandHighlightColor(for: context).opacity(0.30),
                            brandHighlightColor(for: context).opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: iconName(for: context))
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(brandHighlightColor(for: context))
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func statusTitle(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> String {
        switch context.state.mode {
        case .countdown:
            return context.attributes.metadata?.context.countdownTitle ?? "正在倒计时"
        case .paused:
            return context.attributes.metadata?.context.pausedTitle ?? "倒计时已暂停"
        case .alert:
            return "提醒已触发"
        @unknown default:
            return "提醒已触发"
        }
    }

    private func statusBadgeText(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> String {
        switch context.state.mode {
        case .countdown:
            return "倒计时"
        case .paused:
            return "已暂停"
        case .alert:
            return "提醒中"
        @unknown default:
            return "提醒中"
        }
    }

    private func iconName(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> String {
        context.attributes.metadata?.context.systemImageName ?? "hourglass.circle.fill"
    }

    private func lockScreenBackground(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        activitySurfaceColor,
                        Color(red: 0.10, green: 0.16, blue: 0.23)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(brandHighlightColor(for: context).opacity(0.16))
                    .frame(width: 120, height: 120)
                    .blur(radius: 18)
                    .offset(x: 26, y: -34)
            }
    }

    private func brandHighlightColor(
        for context: ActivityViewContext<AlarmAttributes<CountdownAlarmMetadata>>
    ) -> Color {
        switch context.state.mode {
        case .paused:
            return pausedAccentColor
        case .alert:
            return alertAccentColor
        case .countdown:
            return brandPrimaryColor
        @unknown default:
            return brandPrimaryColor
        }
    }

    private func timerText(for countdown: AlarmPresentationState.Mode.Countdown) -> String {
        shortDurationText(for: max(countdown.fireDate.timeIntervalSinceNow, 0))
    }

    private func remainingDuration(_ paused: AlarmPresentationState.Mode.Paused) -> TimeInterval {
        max(paused.totalCountdownDuration - paused.previouslyElapsedDuration, 0)
    }

    private func shortDurationText(for duration: TimeInterval) -> String {
        let totalSeconds = max(Int(duration.rounded(.down)), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

private extension LazyButNotAlarmLiveActivity {
    enum TimerPanelValue {
        case countdown(startDate: Date, endDate: Date)
        case staticText(String)
    }

    var brandPrimaryColor: Color {
        Color(red: 1.0, green: 0.53, blue: 0.0)
    }

    var pausedAccentColor: Color {
        Color(red: 0.48, green: 0.79, blue: 1.0)
    }

    var alertAccentColor: Color {
        Color(red: 1.0, green: 0.39, blue: 0.35)
    }

    var activitySurfaceColor: Color {
        Color(red: 0.07, green: 0.12, blue: 0.18)
    }

    var titleColor: Color {
        Color(red: 0.90, green: 0.82, blue: 0.72)
    }

    var subtitleColor: Color {
        Color(red: 0.68, green: 0.62, blue: 0.57)
    }
}
