import SwiftUI

struct ThemePalette {
    let accent: Color
    let accentSecondary: Color
    let screenBackground: LinearGradient
    let cardBackground: LinearGradient
    let detailBackground: LinearGradient
    let iconBackground: LinearGradient
    let primaryText: Color
    let secondaryText: Color
    let subtleText: Color
    let chipFill: Color
    let chipText: Color
    let border: Color
    let shadow: Color
}

enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case sunrise
    case ocean
    case forest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sunrise: "暖阳橙"
        case .ocean: "海岸蓝"
        case .forest: "苔原绿"
        }
    }

    var tagline: String {
        switch self {
        case .sunrise: "基础版"
        case .ocean: "进阶主题"
        case .forest: "进阶主题"
        }
    }

    var isPremium: Bool {
        switch self {
        case .sunrise:
            false
        case .ocean, .forest:
            true
        }
    }

    var palette: ThemePalette {
        switch self {
        case .sunrise:
            ThemePalette(
                accent: Color(red: 0.91, green: 0.39, blue: 0.18),
                accentSecondary: Color(red: 0.98, green: 0.74, blue: 0.25),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.99, green: 0.95, blue: 0.90), Color(red: 0.98, green: 0.90, blue: 0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.96), Color(red: 0.99, green: 0.94, blue: 0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.95, green: 0.49, blue: 0.24), Color(red: 1.0, green: 0.80, blue: 0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.99, green: 0.79, blue: 0.37), Color(red: 0.91, green: 0.39, blue: 0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.23, green: 0.12, blue: 0.06),
                secondaryText: Color(red: 0.46, green: 0.27, blue: 0.16),
                subtleText: Color(red: 0.61, green: 0.42, blue: 0.28),
                chipFill: Color.white.opacity(0.62),
                chipText: Color(red: 0.53, green: 0.23, blue: 0.08),
                border: Color.white.opacity(0.65),
                shadow: Color(red: 0.66, green: 0.26, blue: 0.09).opacity(0.18)
            )
        case .ocean:
            ThemePalette(
                accent: Color(red: 0.10, green: 0.46, blue: 0.78),
                accentSecondary: Color(red: 0.37, green: 0.82, blue: 0.90),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.89, green: 0.96, blue: 0.99), Color(red: 0.84, green: 0.93, blue: 0.97)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.94), Color(red: 0.89, green: 0.97, blue: 0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.08, green: 0.44, blue: 0.75), Color(red: 0.25, green: 0.76, blue: 0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.38, green: 0.83, blue: 0.89), Color(red: 0.10, green: 0.46, blue: 0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.07, green: 0.19, blue: 0.29),
                secondaryText: Color(red: 0.16, green: 0.36, blue: 0.48),
                subtleText: Color(red: 0.31, green: 0.52, blue: 0.63),
                chipFill: Color.white.opacity(0.58),
                chipText: Color(red: 0.08, green: 0.35, blue: 0.58),
                border: Color.white.opacity(0.70),
                shadow: Color(red: 0.05, green: 0.33, blue: 0.48).opacity(0.16)
            )
        case .forest:
            ThemePalette(
                accent: Color(red: 0.18, green: 0.47, blue: 0.30),
                accentSecondary: Color(red: 0.63, green: 0.78, blue: 0.39),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.92, green: 0.96, blue: 0.89), Color(red: 0.87, green: 0.93, blue: 0.84)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.94), Color(red: 0.91, green: 0.96, blue: 0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.18, green: 0.43, blue: 0.24), Color(red: 0.55, green: 0.73, blue: 0.34)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.72, green: 0.83, blue: 0.43), Color(red: 0.18, green: 0.47, blue: 0.30)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.12, green: 0.22, blue: 0.12),
                secondaryText: Color(red: 0.22, green: 0.37, blue: 0.20),
                subtleText: Color(red: 0.36, green: 0.51, blue: 0.30),
                chipFill: Color.white.opacity(0.56),
                chipText: Color(red: 0.17, green: 0.39, blue: 0.20),
                border: Color.white.opacity(0.70),
                shadow: Color(red: 0.14, green: 0.30, blue: 0.16).opacity(0.16)
            )
        }
    }
}
