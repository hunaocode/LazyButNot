import SwiftUI

struct CountdownAlarmSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    @State private var title = "专注倒计时"
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
                Section("倒计时") {
                    TextField("提醒标题", text: $title)

                    Picker("场景", selection: $category) {
                        ForEach(GoalCategory.allCases) { item in
                            Label(item.rawValue, systemImage: item.iconName)
                                .tag(item)
                        }
                    }

                    MinuteSelectionField(
                        title: "倒计时时长",
                        value: $durationMinutes,
                        presetOptions: durationOptions,
                        customRange: customDurationRange
                    )
                }

                Section("触发后") {
                    Toggle("允许再次倒计时", isOn: $repeatEnabled)

                    if repeatEnabled {
                        MinuteSelectionField(
                            title: "再次提醒间隔",
                            value: $repeatMinutes,
                            presetOptions: repeatOptions,
                            customRange: repeatMinuteRange
                        )
                    }
                }

                Section("说明") {
                    Text("开始后，系统会帮你启动一个带持续提醒的专注倒计时；剩余时间也会同步显示在锁屏和灵动岛上;您可随时右滑清除该倒计时。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("倒计时闹钟")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? "创建中..." : "开始") {
                        startCountdown()
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("知道了", role: .cancel) { }
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
                    title: "当前系统不支持",
                    message: "倒计时闹钟需要 iOS 26 及以上版本。"
                )
            case .authorizationDenied:
                presentAlert(
                    title: "无法创建闹钟",
                    message: "请先在系统中允许本 App 使用闹钟权限。"
                )
            case .failed:
                presentAlert(
                    title: "创建失败",
                    message: "系统没有成功创建倒计时闹钟，请稍后再试。"
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
