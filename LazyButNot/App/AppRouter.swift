import SwiftUI

final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .home
}
