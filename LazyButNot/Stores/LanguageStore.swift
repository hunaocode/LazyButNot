import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans
    case english

    var id: String { rawValue }

    var localeIdentifier: String? {
        switch self {
        case .system:
            nil
        case .zhHans:
            "zh-Hans"
        case .english:
            "en"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .zhHans:
            Locale(identifier: "zh-Hans")
        case .english:
            Locale(identifier: "en")
        }
    }

    var displayName: String {
        switch self {
        case .system:
            String(localized: "debug.language.system", defaultValue: "跟随系统")
        case .zhHans:
            String(localized: "debug.language.zh_hans", defaultValue: "简体中文")
        case .english:
            String(localized: "debug.language.english", defaultValue: "English")
        }
    }
}

@MainActor
final class LanguageStore: ObservableObject {
    @Published var selectedLanguage: AppLanguage {
        didSet {
            persist(selectedLanguage)
            refreshID = UUID()
        }
    }

    @Published private(set) var refreshID = UUID()

    private let storageKey = "selected_app_language"

    init() {
        let rawValue = UserDefaults.standard.string(forKey: storageKey)
        self.selectedLanguage = rawValue.flatMap(AppLanguage.init(rawValue:)) ?? .system
        persist(selectedLanguage)
    }

    var currentLocale: Locale {
        selectedLanguage.locale
    }

    private func persist(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)

        if let localeIdentifier = language.localeIdentifier {
            UserDefaults.standard.set([localeIdentifier], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }
}
