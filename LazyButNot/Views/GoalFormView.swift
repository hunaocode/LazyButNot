import SwiftUI
import UIKit

struct GoalFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var goalStore: GoalStore
    @StateObject private var viewModel: GoalFormViewModel
    private let goal: Goal?

    init(goal: Goal? = nil) {
        self.goal = goal
        _viewModel = StateObject(wrappedValue: GoalFormViewModel(goal: goal))
    }

    private let weekdayOptions: [(Int, String)] = [
        (1, String(localized: "weekday.sun", defaultValue: "周日")),
        (2, String(localized: "weekday.mon", defaultValue: "周一")),
        (3, String(localized: "weekday.tue", defaultValue: "周二")),
        (4, String(localized: "weekday.wed", defaultValue: "周三")),
        (5, String(localized: "weekday.thu", defaultValue: "周四")),
        (6, String(localized: "weekday.fri", defaultValue: "周五")),
        (7, String(localized: "weekday.sat", defaultValue: "周六")),
    ]

    private let offsetOptions: [Int] = [60, 30, 15, 10, 5]
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showSettingsAction = false

    var body: some View {
        Form {
            Section(String(localized: "goal_form.section.basic_info", defaultValue: "基本信息")) {
                TextField(String(localized: "goal_form.name", defaultValue: "目标名称"), text: $viewModel.name)
                TextField(String(localized: "goal_form.minimum_action_placeholder", defaultValue: "最小完成标准，例如：做 1 题"), text: $viewModel.minimumAction)
                TextField(String(localized: "goal_form.description", defaultValue: "目标说明"), text: $viewModel.descriptionText, axis: .vertical)

                Picker(String(localized: "goal_form.category", defaultValue: "分类"), selection: $viewModel.category) {
                    ForEach(GoalCategory.allCases) { category in
                        Text(category.localizedTitle).tag(category)
                    }
                }
            }

            Section(String(localized: "goal_form.section.schedule", defaultValue: "周期")) {
                Picker(String(localized: "goal_form.period_type", defaultValue: "周期类型"), selection: $viewModel.periodType) {
                    ForEach(GoalPeriodType.allCases) { periodType in
                        Text(periodType.localizedTitle).tag(periodType)
                    }
                }

                if viewModel.periodType == .weeklyCount {
                    Stepper(L10n.weeklyTargetCount(viewModel.weeklyTargetCount), value: $viewModel.weeklyTargetCount, in: 1...14)
                }

                if viewModel.periodType == .weeklyFixedDays {
                    weekdayPicker
                }
            }

            Section(String(localized: "goal_form.section.reminders", defaultValue: "提醒")) {
                DatePicker(String(localized: "goal_form.default_reminder_time", defaultValue: "默认提醒时间"), selection: $viewModel.reminderDate, displayedComponents: .hourAndMinute)
                DatePicker(String(localized: "goal_form.deadline_time", defaultValue: "截止时间"), selection: $viewModel.deadlineDate, displayedComponents: .hourAndMinute)

                Toggle(String(localized: "goal_form.enable_supervision", defaultValue: "开启监督提醒"), isOn: $viewModel.supervisionEnabled)
                    .onChange(of: viewModel.supervisionEnabled) { _, enabled in
                        if enabled {
                            normalizeRingEnabledIfNeeded()
                        } else {
                            viewModel.ringEnabled = false
                        }
                    }

                if viewModel.supervisionEnabled {
                    offsetPicker
                    Toggle(alarmToggleTitle, isOn: ringToggleBinding)

                    Text(alarmHintText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Toggle(String(localized: "goal_form.pause_goal", defaultValue: "暂停目标"), isOn: $viewModel.isPaused)
            }
        }
        .navigationTitle(goal == nil ? String(localized: "goal_form.create_title", defaultValue: "新建目标") : String(localized: "goal_form.edit_title", defaultValue: "编辑目标"))
        .task {
            normalizeRingEnabledIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "common.cancel", defaultValue: "取消")) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "common.save", defaultValue: "保存")) {
                    save()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .onChange(of: viewModel.customSupervisionOffset) { _, newValue in
            viewModel.supervisionOffsets.insert(newValue)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if showSettingsAction {
                Button(String(localized: "common.cancel", defaultValue: "取消"), role: .cancel) { }
                Button(String(localized: "common.confirm", defaultValue: "确定")) {
                    openAppSettings()
                }
            } else {
                Button(String(localized: "common.ok", defaultValue: "知道了"), role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "goal_form.fixed_days", defaultValue: "固定日"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(weekdayOptions, id: \.0) { weekday, label in
                    let selected = viewModel.selectedWeekdays.contains(weekday)
                    Button {
                        if selected {
                            viewModel.selectedWeekdays.remove(weekday)
                        } else {
                            viewModel.selectedWeekdays.insert(weekday)
                        }
                    } label: {
                        Text(label)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selected ? Color.orange : Color(.secondarySystemBackground))
                            .foregroundStyle(selected ? Color.white : Color.primary)
                            .clipShape(Capsule(style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var offsetPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "goal_form.supervision_offsets", defaultValue: "监督提前量"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(offsetOptions, id: \.self) { offset in
                    let selected = viewModel.supervisionOffsets.contains(offset)
                    Button {
                        if selected {
                            viewModel.supervisionOffsets.remove(offset)
                        } else {
                            viewModel.supervisionOffsets.insert(offset)
                        }
                    } label: {
                        Text(L10n.minuteCount(offset))
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selected ? Color.orange : Color(.secondarySystemBackground))
                            .foregroundStyle(selected ? Color.white : Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            MinuteSelectionField(
                title: String(localized: "common.custom", defaultValue: "自定义"),
                value: $viewModel.customSupervisionOffset,
                presetOptions: offsetOptions,
                customRange: Array(1...180),
                highlightsCustomSelection: true,
                placeholderText: String(localized: "common.not_set", defaultValue: "未设置"),
                allowsClearingCustomSelection: true,
                isSelectionActive: hasCustomSupervisionOffset,
                onClearSelection: clearCustomSupervisionOffset
            )
        }
        .padding(.vertical, 4)
    }

    private var alarmToggleTitle: String {
        if #available(iOS 26.0, *) {
            return String(localized: "goal_form.enable_alarm_style_reminder", defaultValue: "开启闹钟式提醒")
        }
        return String(localized: "goal_form.enable_reminder_sound", defaultValue: "开启提醒声音")
    }

    private var alarmHintText: String {
        if #available(iOS 26.0, *) {
            return String(localized: "goal_form.alarm_hint_supported", defaultValue: "开启后，到截止前会像系统闹钟一样提醒你；如果没开权限，需要先到系统设置里允许。")
        }
        return String(localized: "goal_form.alarm_hint_unsupported", defaultValue: "当前系统版本不支持闹钟式提醒，只能使用普通通知。")
    }

    private var ringToggleBinding: Binding<Bool> {
        Binding(
            get: { viewModel.ringEnabled },
            set: { newValue in
                if newValue {
                    attemptEnableRingReminder()
                } else {
                    viewModel.ringEnabled = false
                }
            }
        )
    }

    private func save() {
        let savedGoal = goalStore.saveGoal(
            existingGoalID: goal?.id,
            name: viewModel.name,
            description: viewModel.descriptionText,
            category: viewModel.category,
            minimumAction: viewModel.minimumAction,
            periodType: viewModel.periodType,
            weeklyTargetCount: viewModel.weeklyTargetCount,
            selectedWeekdays: Array(viewModel.selectedWeekdays),
            reminderDate: viewModel.reminderDate,
            deadlineDate: viewModel.deadlineDate,
            supervisionEnabled: viewModel.supervisionEnabled,
            supervisionOffsets: Array(viewModel.supervisionOffsets.isEmpty ? [10, 5] : viewModel.supervisionOffsets),
            ringEnabled: viewModel.ringEnabled,
            isPaused: viewModel.isPaused
        )

        Task {
            _ = await NotificationManager.shared.requestNotificationAuthorization()
            await NotificationManager.shared.scheduleNotifications(for: savedGoal)
        }

        dismiss()
    }

    private var hasCustomSupervisionOffset: Bool {
        viewModel.supervisionOffsets.contains(viewModel.customSupervisionOffset) &&
        !offsetOptions.contains(viewModel.customSupervisionOffset)
    }

    private func clearCustomSupervisionOffset() {
        viewModel.supervisionOffsets.remove(viewModel.customSupervisionOffset)
    }

    private func normalizeRingEnabledIfNeeded() {
        guard viewModel.supervisionEnabled else {
            viewModel.ringEnabled = false
            return
        }

        if #available(iOS 26.0, *) {
            viewModel.ringEnabled = NotificationManager.shared.alarmPermissionState() == .authorized
        } else {
            viewModel.ringEnabled = false
        }
    }

    private func attemptEnableRingReminder() {
        guard viewModel.supervisionEnabled else {
            viewModel.ringEnabled = false
            return
        }

        guard #available(iOS 26.0, *) else {
            viewModel.ringEnabled = false
            presentAlert(
                title: String(localized: "common.unsupported_system", defaultValue: "当前系统不支持"),
                message: String(localized: "goal_form.alarm_requires_ios26", defaultValue: "闹钟式提醒需要 iOS 26 及以上版本，升级系统后才可以使用。")
            )
            return
        }

        switch NotificationManager.shared.alarmPermissionState() {
        case .authorized:
            viewModel.ringEnabled = true
        case .denied:
            viewModel.ringEnabled = false
            presentSettingsAlert(
                title: String(localized: "goal_form.alarm_permission_disabled", defaultValue: "闹钟权限未开启"),
                message: String(localized: "goal_form.alarm_permission_settings_message", defaultValue: "请前往系统设置，为“懒人不懒”打开闹钟权限后再使用闹钟式提醒。")
            )
        case .notDetermined:
            Task { @MainActor in
                let result = await NotificationManager.shared.requestAlarmAuthorization()
                if result == .authorized {
                    viewModel.ringEnabled = true
                } else {
                    viewModel.ringEnabled = false
                    presentSettingsAlert(
                        title: String(localized: "goal_form.alarm_permission_disabled", defaultValue: "闹钟权限未开启"),
                        message: String(localized: "goal_form.alarm_permission_required_message", defaultValue: "未开启闹钟权限时，无法使用闹钟式提醒。请前往系统设置打开权限。")
                    )
                }
            }
        case .unavailable, .unknown:
            viewModel.ringEnabled = false
            presentAlert(
                title: String(localized: "common.unsupported_system", defaultValue: "当前系统不支持"),
                message: String(localized: "goal_form.alarm_unavailable_message", defaultValue: "当前设备暂时无法使用闹钟式提醒。")
            )
        }
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showSettingsAction = false
        showingAlert = true
    }

    private func presentSettingsAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showSettingsAction = true
        showingAlert = true
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
