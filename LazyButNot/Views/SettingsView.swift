import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var requestingPermission = false

    var body: some View {
        List {
            Section("通知") {
                HStack {
                    Text("权限状态")
                    Spacer()
                    Text(notificationStatusText)
                        .foregroundStyle(.secondary)
                }

                Button {
                    requestPermission()
                } label: {
                    if requestingPermission {
                        ProgressView()
                    } else {
                        Text("申请通知权限")
                    }
                }

                Button("重新同步所有提醒") {
                    Task {
                        await NotificationManager.shared.scheduleAll(goals: goalStore.goals)
                    }
                }
            }

            Section("产品原则") {
                principleRow("最小行动", "把目标拆到不会失败")
                principleRow("持续坚持", "状态差也别完全停下")
                principleRow("主动提醒", "把记得做，变成被触发")
            }

            Section("关于") {
                Text("懒人不懒")
                    .font(.headline)
                Text("强调“持续坚持”而不是“高强度自律”的本地打卡 App。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("设置")
        .task {
            notificationStatus = await NotificationManager.shared.notificationStatus()
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined: "未决定"
        case .denied: "已拒绝"
        case .authorized: "已允许"
        case .provisional: "临时允许"
        case .ephemeral: "临时会话"
        @unknown default: "未知"
        }
    }

    private func requestPermission() {
        requestingPermission = true

        Task {
            _ = await NotificationManager.shared.requestAuthorization()
            notificationStatus = await NotificationManager.shared.notificationStatus()
            requestingPermission = false
        }
    }

    private func principleRow(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
