import Foundation
import SwiftUI

#if canImport(AlarmKit)
import AlarmKit
#endif

#if canImport(AlarmKit)
@available(iOS 26.0, *)
struct CountdownAlarmMetadata: AlarmMetadata {
    let alarmID: UUID
    enum Context: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
        case focus
        case study
        case reading
        case fitness

        var id: String { rawValue }

        var title: String {
            switch self {
            case .focus:
                String(localized: "countdown.context.focus", defaultValue: "专注")
            case .study:
                String(localized: "enum.goal_category.study", defaultValue: "学习")
            case .reading:
                String(localized: "enum.goal_category.reading", defaultValue: "阅读")
            case .fitness:
                String(localized: "enum.goal_category.fitness", defaultValue: "健身")
            }
        }

        var systemImageName: String {
            switch self {
            case .focus: "hourglass.circle.fill"
            case .study: "brain.head.profile"
            case .reading: "book.closed.fill"
            case .fitness: "figure.run.circle.fill"
            }
        }

        var tintColor: Color {
            switch self {
            case .focus: Color.orange
            case .study: Color.blue
            case .reading: Color.indigo
            case .fitness: Color.green
            }
        }

        var countdownTitle: String {
            L10n.countdownInProgress(title)
        }

        var pausedTitle: String {
            L10n.countdownPaused(title)
        }
    }

    let title: String
    let context: Context
}
#endif
