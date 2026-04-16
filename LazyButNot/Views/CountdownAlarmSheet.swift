import SwiftUI

struct CountdownAlarmSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    @State private var title = L10n.countdownDefaultTitle
    @State private var durationMinutes = 25
    @State private var category: GoalCategory = .study
    @State private var repeatEnabled = true
    @State private var repeatMinutes = 5
    @State private var isSubmitting = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    private let durationOptions = [5, 10, 15, 25, 45, 60]
    private let repeatOptions = [5, 10, 15]
    private let customDurationRange = Array(1...240)
    private let repeatMinuteRange = Array(1...120)

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "countdown.sheet.section.countdown", defaultValue: "倒计时")) {
                    TextField(String(localized: "countdown.sheet.title_placeholder", defaultValue: "提醒标题"), text: $title)

                    Picker(String(localized: "countdown.sheet.context", defaultValue: "场景"), selection: $category) {
                        ForEach(GoalCategory.allCases) { item in
                            Label(item.localizedTitle, systemImage: item.iconName)
                                .tag(item)
                        }
                    }

                    MinuteSelectionField(
                        title: String(localized: "countdown.sheet.duration", defaultValue: "倒计时时长"),
                        value: $durationMinutes,
                        presetOptions: durationOptions,
                        customRange: customDurationRange
                    )
                }

                Section(String(localized: "countdown.sheet.section.after_trigger", defaultValue: "触发后")) {
                    Toggle(String(localized: "countdown.sheet.repeat_enabled", defaultValue: "允许再次倒计时"), isOn: $repeatEnabled)

                    if repeatEnabled {
                        MinuteSelectionField(
                            title: String(localized: "countdown.sheet.repeat_interval", defaultValue: "再次提醒间隔"),
                            value: $repeatMinutes,
                            presetOptions: repeatOptions,
                            customRange: repeatMinuteRange
                        )
                    }
                }

                Section(String(localized: "common.description", defaultValue: "说明")) {
                    Text(String(localized: "countdown.sheet.description", defaultValue: "开始后，系统会帮你启动一个带持续提醒的专注倒计时；剩余时间也会同步显示在锁屏和灵动岛上;您可随时右滑清除该倒计时。"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(localized: "countdown.alarm_title", defaultValue: "倒计时闹钟"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common.cancel", defaultValue: "取消")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? String(localized: "common.creating", defaultValue: "创建中...") : String(localized: "common.start", defaultValue: "开始")) {
                        startCountdown()
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button(String(localized: "common.ok", defaultValue: "知道了"), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func startCountdown() {
        isSubmitting = true

        Task { @MainActor in
            let result = await CountdownAlarmService.shared.schedule(
                title: title,
                durationMinutes: durationMinutes,
                repeatMinutes: repeatEnabled ? repeatMinutes : nil,
                context: category
            )

            isSubmitting = false

            switch result {
            case .success:
                if let session = CountdownAlarmService.shared.activeFocusSession() {
                    router.showFocusCountdown(session)
                }
                dismiss()
            case .unavailable:
                presentAlert(
                    title: String(localized: "common.unsupported_system", defaultValue: "当前系统不支持"),
                    message: String(localized: "countdown.sheet.unsupported_message", defaultValue: "倒计时闹钟需要 iOS 26 及以上版本。")
                )
            case .authorizationDenied:
                presentAlert(
                    title: String(localized: "countdown.sheet.create_alarm_failed", defaultValue: "无法创建闹钟"),
                    message: String(localized: "countdown.sheet.authorization_denied_message", defaultValue: "请先在系统中允许本 App 使用闹钟权限。")
                )
            case .failed:
                presentAlert(
                    title: String(localized: "common.creation_failed", defaultValue: "创建失败"),
                    message: String(localized: "countdown.sheet.creation_failed_message", defaultValue: "系统没有成功创建倒计时闹钟，请稍后再试。")
                )
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}
