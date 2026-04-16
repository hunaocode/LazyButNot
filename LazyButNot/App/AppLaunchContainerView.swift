import SwiftUI

struct AppLaunchContainerView: View {
    let contentRefreshID: UUID

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var showingLaunchOverlay = true

    var body: some View {
        ZStack {
            themeStore.selectedTheme.palette.screenBackground
                .ignoresSafeArea()

            RootTabView()
                .id(contentRefreshID)

            if showingLaunchOverlay {
                AppLaunchOverlayView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active, showingLaunchOverlay else { return }

            try? await Task.sleep(for: .milliseconds(900))
            guard showingLaunchOverlay else { return }

            withAnimation(.easeOut(duration: 0.28)) {
                showingLaunchOverlay = false
            }
        }
    }
}
