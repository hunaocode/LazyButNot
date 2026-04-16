import SwiftUI

enum HomeRoute: Hashable {
    case focusCountdown(FocusCountdownSession)
}

final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .home
    @Published var homePath = NavigationPath()

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
