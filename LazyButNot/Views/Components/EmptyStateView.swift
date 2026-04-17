import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    let title: String
    let subtitle: String
    let systemImage: String

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(palette.accent)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(palette.primaryText)

            Text(subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .shadow(color: palette.shadow, radius: 16, y: 10)
        )
    }
}
