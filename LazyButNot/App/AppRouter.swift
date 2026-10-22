import SwiftUI

enum HomeRoute: Hashable {
    case focusCountdown(FocusCountdownSession)
}

final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .home
    @Published var homePath = NavigationPath()

    init() {
#if DEBUG && targetEnvironment(simulator)
        // Screenshot tooling can select a real tab without changing release navigation.
        switch ProcessInfo.processInfo.environment["LAZYBUTNOT_SCREENSHOT_TAB"] {
        case "goals": selectedTab = .goals
        case "stats": selectedTab = .stats
        case "settings": selectedTab = .settings
        case "themes": selectedTab = .settings
        default: break
        }
#endif
    }

    func showFocusCountdown(_ session: FocusCountdownSession) {
        selectedTab = .home
        homePath = NavigationPath()
        homePath.append(HomeRoute.focusCountdown(session))
    }

    func popToHomeRoot() {
        selectedTab = .home
        homePath = NavigationPath()
    }
}
