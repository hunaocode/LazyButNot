// Generates demo-only goals in a specified simulator data container.
// Never point this script at a physical-device backup or a production data folder.
import Foundation

guard CommandLine.arguments.count == 3 else {
    fatalError("Usage: swift tools/seed_store_screenshots.swift <simulator-app-data> <zh-Hans|en>")
}
let container = URL(fileURLWithPath: CommandLine.arguments[1])
guard container.path.contains("/CoreSimulator/Devices/"), container.path.contains("/Containers/Data/Application/") else {
    fatalError("Only simulator app containers are supported")
}
let english = CommandLine.arguments[2] == "en"
let fm = FileManager.default
let directory = container.appendingPathComponent("Library/Application Support/LazyButNot")
try fm.createDirectory(at: directory, withIntermediateDirectories: true)
let output = directory.appendingPathComponent("goals.json")
if fm.fileExists(atPath: output.path) {
    let backup = directory.appendingPathComponent("goals-before-screenshots-\(UUID().uuidString).json")
    try fm.copyItem(at: output, to: backup)
}
let calendar = Calendar.current
let today = calendar.startOfDay(for: Date())
let formatter = ISO8601DateFormatter()
func iso(_ date: Date) -> String { formatter.string(from: date) }
let examples: [(String, String, String, String, String, Int, Int)] = [
    ("每天读一点", "Read a little daily", "读 2 页，就算开始", "Read just 2 pages", "reading", 19, 14),
    ("让身体动起来", "Make time to move", "拉伸 5 分钟", "Stretch for 5 minutes", "fitness", 20, 10),
    ("每天学点英语", "A little English daily", "记住 3 个新单词", "Learn 3 new words", "study", 21, 7),
    ("睡前放下手机", "Unplug before bed", "睡前 10 分钟不看屏幕", "Go screen-free for 10 minutes", "routine", 22, 5),
]
let goals: [[String: Any]] = examples.enumerated().map { index, example in
    let records: [[String: Any]] = (1...example.6).map { day in
        let date = calendar.date(byAdding: .day, value: -day, to: today)!
        return ["id": UUID().uuidString, "date": iso(date), "status": day == 3 ? "minimum_completed" : "completed", "note": "", "createdAt": iso(date)]
    } + (index >= 2 ? [["id": UUID().uuidString, "date": iso(today), "status": index == 2 ? "completed" : "minimum_completed", "note": "", "createdAt": iso(today)]] : [])
    return [
        "id": String(format: "10000000-0000-0000-0000-%012d", index + 1),
        "name": english ? example.1 : example.0,
        "goalDescription": english ? "Small steps make it easier to stay consistent." : "从小小的一步开始，让坚持变得轻松。",
        "category": example.4,
        "minimumAction": english ? example.3 : example.2,
        "periodType": "daily", "weeklyTargetCount": 3, "selectedWeekdays": [],
        "reminderHour": example.5, "reminderMinute": 0,
        "deadlineHour": 23, "deadlineMinute": 0,
        "supervisionEnabled": true, "supervisionOffsets": [30, 10],
        "ringEnabled": false, "isPaused": false,
        "createdAt": iso(calendar.date(byAdding: .day, value: -example.6, to: today)!),
        "updatedAt": iso(today), "records": records,
    ]
}
let data = try JSONSerialization.data(withJSONObject: goals, options: [.prettyPrinted, .sortedKeys])
try data.write(to: output, options: .atomic)
print("Seeded 4 \(english ? "English" : "Chinese") demo goals: \(output.path)")
