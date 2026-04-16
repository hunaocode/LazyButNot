import SwiftUI

struct DebugSettingsView: View {
    @EnvironmentObject private var languageStore: LanguageStore

    var body: some View {
        List {
            Section(String(localized: "debug.section.language", defaultValue: "语言调试")) {
                Picker(
                    String(localized: "debug.language.picker_title", defaultValue: "应用语言"),
                    selection: $languageStore.selectedLanguage
                ) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }
                .pickerStyle(.inline)

                Text(String(localized: "debug.language.hint", defaultValue: "用于开发阶段快速预览多语言效果。切换后当前界面会立即刷新。"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "debug.title", defaultValue: "Debug 设置"))
    }
}
