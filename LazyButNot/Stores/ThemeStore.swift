import Foundation

@MainActor
final class ThemeStore: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: storageKey)
        }
    }

    private let storageKey = "selected_app_theme"

    init() {
        let rawValue = UserDefaults.standard.string(forKey: storageKey)
        self.selectedTheme = rawValue.flatMap(AppTheme.init(rawValue:)) ?? .sunrise
    }
}
