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
        (1, "周日"),
        (2, "周一"),
        (3, "周二"),
        (4, "周三"),
        (5, "周四"),
        (6, "周五"),
        (7, "周六"),
    ]

    private let offsetOptions: [Int] = [60, 30, 15, 10, 5]
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showSettingsAction = false

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("目标名称", text: $viewModel.name)
                TextField("最小完成标准，例如：做 1 题", text: $viewModel.minimumAction)
                TextField("目标说明", text: $viewModel.descriptionText, axis: .vertical)

                Picker("分类", selection: $viewModel.category) {
                    ForEach(GoalCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }

            Section("周期") {
                Picker("周期类型", selection: $viewModel.periodType) {
                    ForEach(GoalPeriodType.allCases) { periodType in
                        Text(periodType.rawValue).tag(periodType)
                    }
                }

                if viewModel.periodType == .weeklyCount {
                    Stepper("每周 \(viewModel.weeklyTargetCount) 次", value: $viewModel.weeklyTargetCount, in: 1...14)
                }

                if viewModel.periodType == .weeklyFixedDays {
                    weekdayPicker
                }
            }

            Section("提醒") {
                DatePicker("默认提醒时间", selection: $viewModel.reminderDate, displayedComponents: .hourAndMinute)
                DatePicker("截止时间", selection: $viewModel.deadlineDate, displayedComponents: .hourAndMinute)

                Toggle("开启监督提醒", isOn: $viewModel.supervisionEnabled)
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

                Toggle("暂停目标", isOn: $viewModel.isPaused)
            }
        }
        .navigationTitle(goal == nil ? "新建目标" : "编辑目标")
        .task {
            normalizeRingEnabledIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
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
                Button("取消", role: .cancel) { }
                Button("确定") {
                    openAppSettings()
                }
            } else {
                Button("知道了", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("固定日")
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
            Text("监督提前量")
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
                        Text("\(offset) 分钟")
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
                title: "自定义",
                value: $viewModel.customSupervisionOffset,
                presetOptions: offsetOptions,
                customRange: Array(1...180),
                highlightsCustomSelection: true,
                placeholderText: "未设置",
                allowsClearingCustomSelection: true,
                isSelectionActive: hasCustomSupervisionOffset,
                onClearSelection: clearCustomSupervisionOffset
            )
        }
        .padding(.vertical, 4)
    }

    private var alarmToggleTitle: String {
        if #available(iOS 26.0, *) {
            return "开启闹钟式提醒"
        }
        return "开启提醒声音"
    }

    private var alarmHintText: String {
        if #available(iOS 26.0, *) {
            return "开启后，到截止前会像系统闹钟一样提醒你；如果没开权限，需要先到系统设置里允许。"
        }
        return "当前系统版本不支持闹钟式提醒，只能使用普通通知。"
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
                title: "当前系统不支持",
                message: "闹钟式提醒需要 iOS 26 及以上版本，升级系统后才可以使用。"
            )
            return
        }

        switch NotificationManager.shared.alarmPermissionState() {
        case .authorized:
            viewModel.ringEnabled = true
        case .denied:
            viewModel.ringEnabled = false
            presentSettingsAlert(
                title: "闹钟权限未开启",
                message: "请前往系统设置，为“懒人不懒”打开闹钟权限后再使用闹钟式提醒。"
            )
        case .notDetermined:
            Task { @MainActor in
                let result = await NotificationManager.shared.requestAlarmAuthorization()
                if result == .authorized {
                    viewModel.ringEnabled = true
                } else {
                    viewModel.ringEnabled = false
                    presentSettingsAlert(
                        title: "闹钟权限未开启",
                        message: "未开启闹钟权限时，无法使用闹钟式提醒。请前往系统设置打开权限。"
                    )
                }
            }
        case .unavailable, .unknown:
            viewModel.ringEnabled = false
            presentAlert(
                title: "当前系统不支持",
                message: "当前设备暂时无法使用闹钟式提醒。"
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
