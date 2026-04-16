import SwiftUI

@main
struct LazyButNotApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var goalStore = GoalStore()
    @StateObject private var themeStore = ThemeStore()
    @StateObject private var languageStore = LanguageStore()

    init() {
        NotificationManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .id(languageStore.refreshID)
                .environment(\.locale, languageStore.currentLocale)
                .environmentObject(appRouter)
                .environmentObject(goalStore)
                .environmentObject(themeStore)
                .environmentObject(languageStore)
        }
    }
}
