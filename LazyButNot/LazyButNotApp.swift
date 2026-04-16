import SwiftUI

@main
struct LazyButNotApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var goalStore = GoalStore()
    @StateObject private var themeStore = ThemeStore()

    init() {
        NotificationManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appRouter)
                .environmentObject(goalStore)
                .environmentObject(themeStore)
        }
    }
}
