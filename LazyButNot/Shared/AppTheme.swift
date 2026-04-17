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

enum ThemeCollection: String, CaseIterable, Identifiable {
    case base
    case freshLight
    case warmAtmosphere
    case darkPremium

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .base:
            String(localized: "theme.collection.base", defaultValue: "基础主题")
        case .freshLight:
            String(localized: "theme.collection.fresh_light", defaultValue: "清透浅色")
        case .warmAtmosphere:
            String(localized: "theme.collection.warm_atmosphere", defaultValue: "暖调氛围")
        case .darkPremium:
            String(localized: "theme.collection.dark_premium", defaultValue: "深色质感")
        }
    }
}

enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case sunrise
    case ocean
    case forest
    case roseMist
    case midnightGold
    case glacierLavender
    case amberDusk
    case mintHaze
    case terracottaSand
    case polarNight

    var id: String { rawValue }

    var collection: ThemeCollection {
        switch self {
        case .sunrise:
            .base
        case .ocean, .forest, .glacierLavender, .mintHaze:
            .freshLight
        case .roseMist, .amberDusk, .terracottaSand:
            .warmAtmosphere
        case .midnightGold, .polarNight:
            .darkPremium
        }
    }

    var displayName: String {
        switch self {
        case .sunrise:
            String(localized: "theme.sunrise.name", defaultValue: "暖阳橙")
        case .ocean:
            String(localized: "theme.ocean.name", defaultValue: "海岸蓝")
        case .forest:
            String(localized: "theme.forest.name", defaultValue: "苔原绿")
        case .roseMist:
            String(localized: "theme.rose_mist.name", defaultValue: "雾玫瑰")
        case .midnightGold:
            String(localized: "theme.midnight_gold.name", defaultValue: "夜幕金")
        case .glacierLavender:
            String(localized: "theme.glacier_lavender.name", defaultValue: "冰川雾紫")
        case .amberDusk:
            String(localized: "theme.amber_dusk.name", defaultValue: "琥珀暮光")
        case .mintHaze:
            String(localized: "theme.mint_haze.name", defaultValue: "薄荷云岚")
        case .terracottaSand:
            String(localized: "theme.terracotta_sand.name", defaultValue: "赤陶砂")
        case .polarNight:
            String(localized: "theme.polar_night.name", defaultValue: "极夜青")
        }
    }

    var tagline: String {
        switch self {
        case .sunrise:
            String(localized: "theme.tagline.base", defaultValue: "基础版")
        case .ocean, .forest, .roseMist, .midnightGold, .glacierLavender, .amberDusk, .mintHaze, .terracottaSand, .polarNight:
            String(localized: "theme.tagline.premium", defaultValue: "进阶主题")
        }
    }

    var isPremium: Bool {
        switch self {
        case .sunrise:
            false
        case .ocean, .forest, .roseMist, .midnightGold, .glacierLavender, .amberDusk, .mintHaze, .terracottaSand, .polarNight:
            true
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .midnightGold, .polarNight:
            .dark
        case .sunrise, .ocean, .forest, .roseMist, .glacierLavender, .amberDusk, .mintHaze, .terracottaSand:
            .light
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
        case .roseMist:
            ThemePalette(
                accent: Color(red: 0.78, green: 0.29, blue: 0.45),
                accentSecondary: Color(red: 0.93, green: 0.67, blue: 0.70),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.99, green: 0.94, blue: 0.95), Color(red: 0.96, green: 0.89, blue: 0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.95), Color(red: 0.98, green: 0.92, blue: 0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.72, green: 0.25, blue: 0.41), Color(red: 0.95, green: 0.61, blue: 0.67)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.97, green: 0.76, blue: 0.79), Color(red: 0.78, green: 0.29, blue: 0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.31, green: 0.12, blue: 0.18),
                secondaryText: Color(red: 0.48, green: 0.22, blue: 0.30),
                subtleText: Color(red: 0.62, green: 0.37, blue: 0.45),
                chipFill: Color.white.opacity(0.62),
                chipText: Color(red: 0.60, green: 0.22, blue: 0.34),
                border: Color.white.opacity(0.72),
                shadow: Color(red: 0.56, green: 0.22, blue: 0.33).opacity(0.16)
            )
        case .midnightGold:
            ThemePalette(
                accent: Color(red: 0.86, green: 0.69, blue: 0.31),
                accentSecondary: Color(red: 0.98, green: 0.84, blue: 0.53),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.07, green: 0.09, blue: 0.14), Color(red: 0.13, green: 0.15, blue: 0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color(red: 0.15, green: 0.17, blue: 0.24).opacity(0.98), Color(red: 0.21, green: 0.18, blue: 0.15).opacity(0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.28, green: 0.21, blue: 0.11), Color(red: 0.61, green: 0.47, blue: 0.18), Color(red: 0.95, green: 0.78, blue: 0.38)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.99, green: 0.84, blue: 0.49), Color(red: 0.69, green: 0.49, blue: 0.17)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.97, green: 0.94, blue: 0.88),
                secondaryText: Color(red: 0.84, green: 0.78, blue: 0.68),
                subtleText: Color(red: 0.70, green: 0.66, blue: 0.58),
                chipFill: Color(red: 1.0, green: 0.86, blue: 0.48).opacity(0.14),
                chipText: Color(red: 0.98, green: 0.86, blue: 0.56),
                border: Color(red: 1.0, green: 0.85, blue: 0.50).opacity(0.16),
                shadow: Color.black.opacity(0.38)
            )
        case .glacierLavender:
            ThemePalette(
                accent: Color(red: 0.49, green: 0.45, blue: 0.83),
                accentSecondary: Color(red: 0.73, green: 0.84, blue: 0.97),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.94, green: 0.96, blue: 0.99), Color(red: 0.90, green: 0.92, blue: 0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.95), Color(red: 0.92, green: 0.94, blue: 0.99)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.46, green: 0.48, blue: 0.85), Color(red: 0.74, green: 0.82, blue: 0.99)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.82, green: 0.89, blue: 0.99), Color(red: 0.53, green: 0.50, blue: 0.87)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.17, green: 0.19, blue: 0.34),
                secondaryText: Color(red: 0.31, green: 0.34, blue: 0.56),
                subtleText: Color(red: 0.45, green: 0.49, blue: 0.67),
                chipFill: Color.white.opacity(0.66),
                chipText: Color(red: 0.36, green: 0.34, blue: 0.68),
                border: Color.white.opacity(0.74),
                shadow: Color(red: 0.32, green: 0.39, blue: 0.64).opacity(0.14)
            )
        case .amberDusk:
            ThemePalette(
                accent: Color(red: 0.82, green: 0.43, blue: 0.21),
                accentSecondary: Color(red: 0.97, green: 0.72, blue: 0.39),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.99, green: 0.94, blue: 0.88), Color(red: 0.96, green: 0.88, blue: 0.81)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.95), Color(red: 0.98, green: 0.91, blue: 0.84)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.63, green: 0.29, blue: 0.14), Color(red: 0.94, green: 0.61, blue: 0.24), Color(red: 0.99, green: 0.79, blue: 0.46)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.98, green: 0.78, blue: 0.43), Color(red: 0.82, green: 0.43, blue: 0.21)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.27, green: 0.14, blue: 0.08),
                secondaryText: Color(red: 0.46, green: 0.25, blue: 0.16),
                subtleText: Color(red: 0.62, green: 0.40, blue: 0.27),
                chipFill: Color.white.opacity(0.60),
                chipText: Color(red: 0.61, green: 0.30, blue: 0.15),
                border: Color.white.opacity(0.72),
                shadow: Color(red: 0.62, green: 0.30, blue: 0.14).opacity(0.15)
            )
        case .mintHaze:
            ThemePalette(
                accent: Color(red: 0.18, green: 0.63, blue: 0.54),
                accentSecondary: Color(red: 0.63, green: 0.86, blue: 0.77),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.92, green: 0.98, blue: 0.96), Color(red: 0.88, green: 0.96, blue: 0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.95), Color(red: 0.89, green: 0.97, blue: 0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.15, green: 0.55, blue: 0.49), Color(red: 0.42, green: 0.78, blue: 0.68), Color(red: 0.77, green: 0.93, blue: 0.87)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.72, green: 0.92, blue: 0.86), Color(red: 0.20, green: 0.66, blue: 0.56)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.10, green: 0.24, blue: 0.22),
                secondaryText: Color(red: 0.22, green: 0.40, blue: 0.35),
                subtleText: Color(red: 0.37, green: 0.56, blue: 0.50),
                chipFill: Color.white.opacity(0.66),
                chipText: Color(red: 0.15, green: 0.49, blue: 0.41),
                border: Color.white.opacity(0.74),
                shadow: Color(red: 0.19, green: 0.49, blue: 0.41).opacity(0.13)
            )
        case .terracottaSand:
            ThemePalette(
                accent: Color(red: 0.73, green: 0.38, blue: 0.31),
                accentSecondary: Color(red: 0.90, green: 0.67, blue: 0.53),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.97, green: 0.92, blue: 0.87), Color(red: 0.94, green: 0.88, blue: 0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color.white.opacity(0.95), Color(red: 0.96, green: 0.89, blue: 0.84)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.58, green: 0.29, blue: 0.24), Color(red: 0.80, green: 0.47, blue: 0.36), Color(red: 0.93, green: 0.73, blue: 0.60)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.93, green: 0.71, blue: 0.58), Color(red: 0.73, green: 0.38, blue: 0.31)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.29, green: 0.16, blue: 0.14),
                secondaryText: Color(red: 0.46, green: 0.28, blue: 0.23),
                subtleText: Color(red: 0.60, green: 0.43, blue: 0.36),
                chipFill: Color.white.opacity(0.62),
                chipText: Color(red: 0.58, green: 0.31, blue: 0.25),
                border: Color.white.opacity(0.72),
                shadow: Color(red: 0.49, green: 0.28, blue: 0.22).opacity(0.14)
            )
        case .polarNight:
            ThemePalette(
                accent: Color(red: 0.36, green: 0.74, blue: 0.82),
                accentSecondary: Color(red: 0.62, green: 0.90, blue: 0.95),
                screenBackground: LinearGradient(
                    colors: [Color(red: 0.04, green: 0.11, blue: 0.15), Color(red: 0.08, green: 0.18, blue: 0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: LinearGradient(
                    colors: [Color(red: 0.08, green: 0.17, blue: 0.22).opacity(0.98), Color(red: 0.11, green: 0.24, blue: 0.30).opacity(0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                detailBackground: LinearGradient(
                    colors: [Color(red: 0.08, green: 0.29, blue: 0.36), Color(red: 0.13, green: 0.49, blue: 0.58), Color(red: 0.39, green: 0.79, blue: 0.86)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                iconBackground: LinearGradient(
                    colors: [Color(red: 0.52, green: 0.88, blue: 0.93), Color(red: 0.18, green: 0.53, blue: 0.60)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryText: Color(red: 0.89, green: 0.97, blue: 0.98),
                secondaryText: Color(red: 0.69, green: 0.86, blue: 0.88),
                subtleText: Color(red: 0.52, green: 0.72, blue: 0.74),
                chipFill: Color.white.opacity(0.10),
                chipText: Color(red: 0.63, green: 0.89, blue: 0.93),
                border: Color.white.opacity(0.12),
                shadow: Color.black.opacity(0.36)
            )
        }
    }
}
