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
    @EnvironmentObject private var themeStore: ThemeStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var didRunStartupTask = false
    private let cancelCountdownURL = URL(string: "lazybutnot://countdown/cancel")!
    private let focusCountdownURL = URL(string: "lazybutnot://countdown/focus")!

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeDashboardView()
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .focusCountdown(let session):
                            FocusCountdownView(session: session)
                        }
                    }
            }
            .tabItem {
                Label(L10n.tabHome, systemImage: "sun.max.fill")
            }
            .tag(RootTab.home)

            NavigationStack {
                GoalsListView()
            }
            .tabItem {
                Label(L10n.tabGoals, systemImage: "checklist")
            }
            .tag(RootTab.goals)

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label(L10n.tabStats, systemImage: "chart.bar.fill")
            }
            .tag(RootTab.stats)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(L10n.tabSettings, systemImage: "gearshape.fill")
            }
            .tag(RootTab.settings)
        }
        .tint(themeStore.selectedTheme.palette.accent)
        .onOpenURL { url in
            Task { @MainActor in
                guard url.scheme == cancelCountdownURL.scheme,
                      url.host == cancelCountdownURL.host else {
                    return
                }

                switch url.path {
                case cancelCountdownURL.path:
                    _ = await CountdownAlarmService.shared.cancelActiveCountdown()
                    router.popToHomeRoot()
                case focusCountdownURL.path:
                    if let session = CountdownAlarmService.shared.activeFocusSession() {
                        router.showFocusCountdown(session)
                    } else {
                        router.popToHomeRoot()
                    }
                default:
                    break
                }
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            CountdownAlarmService.shared.startObservingLiveActivityDismissals()
            await CountdownAlarmService.shared.syncDismissedCountdownIfNeeded()
            if router.homePath.count > 0,
               CountdownAlarmService.shared.activeFocusSession() == nil {
                router.popToHomeRoot()
            }
            if !didRunStartupTask {
                didRunStartupTask = true
                try? await Task.sleep(for: .milliseconds(600))
                await NotificationManager.shared.requestLaunchPermissionsIfNeeded()
                await NotificationManager.shared.scheduleAll(goals: goalStore.goals)
            }
        }
    }
}
