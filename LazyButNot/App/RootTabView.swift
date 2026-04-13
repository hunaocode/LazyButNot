import SwiftUI

enum RootTab: Hashable {
    case home
    case goals
    case stats
    case settings
}

struct RootTabView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var goalStore: GoalStore

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                HomeDashboardView()
            }
            .tabItem {
                Label("今日", systemImage: "sun.max.fill")
            }
            .tag(RootTab.home)

            NavigationStack {
                GoalsListView()
            }
            .tabItem {
                Label("目标", systemImage: "checklist")
            }
            .tag(RootTab.goals)

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("统计", systemImage: "chart.bar.fill")
            }
            .tag(RootTab.stats)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
            .tag(RootTab.settings)
        }
        .tint(.orange)
        .task {
            let status = await NotificationManager.shared.notificationStatus()
            guard status == .authorized || status == .provisional else { return }
            await NotificationManager.shared.scheduleAll(goals: goalStore.goals)
        }
    }
}
