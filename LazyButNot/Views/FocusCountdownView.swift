import SwiftUI

struct FocusCountdownView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var isCancelling = false
    @State private var currentTime = Date()

    let session: FocusCountdownSession

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                Spacer(minLength: 118)

                countdownText

                categoryText
                    .padding(.top, 12)

                titleText
                    .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            abandonButton
                .padding(.horizontal, 78)
                .padding(.bottom, 44)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            currentTime = Date()
            if CountdownAlarmService.shared.activeFocusSession() == nil {
                router.popToHomeRoot()
            }
        }
        .onReceive(timer) { currentTime in
            self.currentTime = currentTime
            if currentTime >= session.endDate || CountdownAlarmService.shared.activeFocusSession() == nil {
                router.popToHomeRoot()
            }
        }
    }

    private var countdownText: some View {
        Text(remainingTimeText)
            .font(.system(size: 78, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(accentColor)
            .minimumScaleFactor(0.55)
            .lineLimit(1)
    }

    private var remainingTimeText: String {
        let remainingSeconds = max(Int(session.endDate.timeIntervalSince(currentTime.roundedToSecond)), 0)
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var categoryText: some View {
        HStack(spacing: 6) {
            Text(session.category.rawValue)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
        }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundStyle(secondaryColor)
    }

    private var titleText: some View {
        Text(session.title)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(secondaryColor.opacity(0.64))
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    private var abandonButton: some View {
        Button {
            cancelFocus()
        } label: {
            Text(isCancelling ? "取消中..." : "放弃专注")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.96))
                .padding(.horizontal, 34)
                .frame(height: 54)
                .background(
                    Capsule(style: .continuous)
                        .fill(abandonButtonColor)
                )
        }
        .buttonStyle(.plain)
        .disabled(isCancelling)
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.95, blue: 0.90),
                    Color(red: 0.97, green: 0.97, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 22)
                .offset(x: 78, y: -318)

            Circle()
                .fill(Color.white.opacity(0.92))
                .frame(width: 320, height: 320)
                .blur(radius: 26)
                .offset(x: -36, y: -170)
        }
    }

    private var accentColor: Color {
        switch session.category {
        case .study:
            return Color(red: 0.93, green: 0.50, blue: 0.12)
        case .fitness:
            return Color(red: 0.91, green: 0.44, blue: 0.14)
        case .reading:
            return Color(red: 0.78, green: 0.43, blue: 0.16)
        case .routine:
            return Color(red: 0.81, green: 0.45, blue: 0.17)
        case .work:
            return Color(red: 0.87, green: 0.48, blue: 0.13)
        case .custom:
            return Color(red: 0.84, green: 0.47, blue: 0.17)
        }
    }

    private var secondaryColor: Color {
        Color(red: 0.43, green: 0.37, blue: 0.31)
    }

    private var abandonButtonColor: Color {
        Color(red: 0.42, green: 0.35, blue: 0.29).opacity(0.88)
    }

    private func cancelFocus() {
        guard !isCancelling else { return }
        isCancelling = true

        Task { @MainActor in
            _ = await CountdownAlarmService.shared.cancelActiveCountdown()
            isCancelling = false
            router.popToHomeRoot()
        }
    }
}

private extension Date {
    var roundedToSecond: Date {
        Date(timeIntervalSince1970: floor(timeIntervalSince1970))
    }
}
