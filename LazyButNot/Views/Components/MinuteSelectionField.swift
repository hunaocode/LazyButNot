import SwiftUI

struct MinuteSelectionField: View {
    private enum ActiveSheet: String, Identifiable {
        case options
        case wheel

        var id: String { rawValue }
    }

    @Binding var value: Int

    let title: String
    let presetOptions: [Int]
    let customRange: [Int]
    let highlightsCustomSelection: Bool
    let placeholderText: String?
    let allowsClearingCustomSelection: Bool
    let isSelectionActive: Bool
    let onClearSelection: (() -> Void)?

    @State private var activeSheet: ActiveSheet?
    @State private var customDraftValue: Int

    init(
        title: String,
        value: Binding<Int>,
        presetOptions: [Int],
        customRange: [Int],
        highlightsCustomSelection: Bool = false,
        placeholderText: String? = nil,
        allowsClearingCustomSelection: Bool = false,
        isSelectionActive: Bool = true,
        onClearSelection: (() -> Void)? = nil
    ) {
        _value = value
        self.title = title
        self.presetOptions = presetOptions
        self.customRange = customRange
        self.highlightsCustomSelection = highlightsCustomSelection
        self.placeholderText = placeholderText
        self.allowsClearingCustomSelection = allowsClearingCustomSelection
        self.isSelectionActive = isSelectionActive
        self.onClearSelection = onClearSelection
        _customDraftValue = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            if !isSelectionActive, let placeholderText {
                Text(placeholderText)
                    .foregroundStyle(.secondary)
            } else if highlightsCustomSelection, !presetOptions.contains(value) {
                Text(displayText)
                    .foregroundStyle(.orange)
                    .fontWeight(.semibold)
            } else if !highlightsCustomSelection || presetOptions.contains(value) {
                Text(displayText)
                    .foregroundStyle(.secondary)
            }
            if allowsClearingCustomSelection, isShowingCustomSelection {
                Button {
                    onClearSelection?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            customDraftValue = value
            activeSheet = .options
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .options:
                minuteOptionsSheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            case .wheel:
                minuteWheelSheet
                    .presentationDetents([.height(280)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var displayText: String {
        L10n.minuteCount(value)
    }

    private var isShowingCustomSelection: Bool {
        isSelectionActive && !presetOptions.contains(value)
    }

    private var customOptionTitle: String {
        if presetOptions.contains(value) {
            return String(localized: "common.custom", defaultValue: "自定义")
        }
        return L10n.customMinute(value)
    }

    private var minuteOptionsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                ForEach(presetOptions, id: \.self) { minutes in
                    optionButton(title: L10n.minuteCount(minutes), minutes: minutes)
                }

                Button {
                    customDraftValue = value
                    activeSheet = .wheel
                } label: {
                    HStack {
                        Text(customOptionTitle)
                            .foregroundStyle(.primary)
                        Spacer()
                        if !presetOptions.contains(value) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                }
                .padding(16)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.close", defaultValue: "关闭")) {
                        activeSheet = nil
                    }
                }
            }
        }
    }

    private var minuteWheelSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(title, selection: $customDraftValue) {
                    ForEach(customRange, id: \.self) { minutes in
                        Text(L10n.minuteCount(minutes)).tag(minutes)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle(String(localized: "common.custom", defaultValue: "自定义"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common.cancel", defaultValue: "取消")) {
                        activeSheet = .options
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.confirm", defaultValue: "确定")) {
                        value = customDraftValue
                        activeSheet = nil
                    }
                }
            }
        }
        .onAppear {
            customDraftValue = customRange.contains(value) ? value : (customRange.first ?? value)
        }
    }

    private func optionButton(title: String, minutes: Int) -> some View {
        Button {
            value = minutes
            activeSheet = nil
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                if value == minutes {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
