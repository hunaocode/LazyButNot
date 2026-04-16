import SwiftUI

struct AppLaunchOverlayView: View {
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var isAnimatedIn = false

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    var body: some View {
        ZStack {
            palette.screenBackground
                .ignoresSafeArea()

            Circle()
                .fill(palette.detailBackground)
                .frame(width: 260, height: 260)
                .blur(radius: 20)
                .offset(x: -110, y: -250)
                .opacity(0.38)

            Circle()
                .fill(palette.iconBackground)
                .frame(width: 220, height: 220)
                .blur(radius: 28)
                .offset(x: 140, y: 290)
                .opacity(0.30)

            VStack(spacing: 26) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.26))
                        .frame(width: 158, height: 158)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.30), lineWidth: 1)
                        )

                    Image("LaunchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 126, height: 126)
                }
                .shadow(color: palette.shadow.opacity(0.65), radius: 24, x: 0, y: 18)

                VStack(spacing: 10) {
                    Text(L10n.appName)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(palette.primaryText)

                    Text(L10n.appLaunchSubtitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .scaleEffect(isAnimatedIn ? 1 : 0.94)
            .opacity(isAnimatedIn ? 1 : 0)
            .offset(y: isAnimatedIn ? 0 : 14)
        }
        .onAppear {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.84)) {
                isAnimatedIn = true
            }
        }
    }
}
