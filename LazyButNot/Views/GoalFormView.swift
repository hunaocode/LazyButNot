import SwiftUI

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

                if viewModel.supervisionEnabled {
                    offsetPicker
                    Toggle("临近截止带声音提醒", isOn: $viewModel.ringEnabled)
                }

                Toggle("暂停目标", isOn: $viewModel.isPaused)
            }
        }
        .navigationTitle(goal == nil ? "新建目标" : "编辑目标")
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
        }
        .padding(.vertical, 4)
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
            await NotificationManager.shared.requestAuthorization()
            await NotificationManager.shared.scheduleNotifications(for: savedGoal)
        }

        dismiss()
    }
}
