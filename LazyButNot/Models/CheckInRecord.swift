import Foundation

struct CheckInRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = .now
    var status: CheckInStatus
    var note: String = ""
    var createdAt: Date = .now
}
