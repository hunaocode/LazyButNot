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
            case .focus: "专注"
            case .study: "学习"
            case .reading: "阅读"
            case .fitness: "健身"
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
            "\(title)进行中"
        }

        var pausedTitle: String {
            "\(title)已暂停"
        }
    }

    let title: String
    let context: Context
}
#endif
