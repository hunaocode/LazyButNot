import SwiftUI

@main
struct LazyButNotApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var goalStore = GoalStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appRouter)
                .environmentObject(goalStore)
        }
    }
}
