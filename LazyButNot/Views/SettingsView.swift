import SwiftUI
import UserNotifications
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var notificationSoundSetting: UNNotificationSetting = .notSupported
    @State private var alarmPermissionState: AlarmPermissionState = .unavailable
    @State private var alarmAuthorizationText: String?
    @State private var requestingPermission = false
    @State private var permissionMessage = ""
    @State private var showingPermissionMessage = false

    var body: some View {
        List {
            Section("通知") {
                HStack {
                    Text("权限状态")
                    Spacer()
                    Text(notificationStatusText)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("通知声音")
                    Spacer()
                    Text(notificationSoundText)
                        .foregroundStyle(.secondary)
                }

                if let alarmAuthorizationText {
                    HStack {
                        Text("闹钟提醒权限")
                        Spacer()
                        Text(alarmAuthorizationText)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    requestPermission()
                } label: {
                    if requestingPermission {
                        ProgressView()
                    } else {
                        Text(permissionButtonTitle)
                    }
                }
                .disabled(permissionButtonDisabled)

                Text(permissionHintText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("重新同步所有提醒") {
                    Task {
                        await NotificationManager.shared.scheduleAll(goals: goalStore.goals)
                    }
                }
            }

            Section("外观主题") {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        themeStore.selectedTheme = theme
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(theme.palette.detailBackground)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text(theme.displayName)
                                        .foregroundStyle(.primary)
                                    if theme.isPremium {
                                        Text("预留付费")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.orange.opacity(0.12))
                                            .foregroundStyle(.orange)
                                            .clipShape(Capsule(style: .continuous))
                                    }
                                }
                                Text(theme.tagline)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if themeStore.selectedTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(theme.palette.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
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
        .scrollContentBackground(.hidden)
        .background(themeStore.selectedTheme.palette.screenBackground)
        .task {
            await refreshNotificationStatus()
        }
        .alert("提醒权限", isPresented: $showingPermissionMessage) {
            Button("知道了", role: .cancel) { }
        } message: {
            Text(permissionMessage)
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
        if shouldOpenSystemSettings {
            openSystemSettings()
            return
        }

        requestingPermission = true
        let shouldRequestNotification = notificationStatus == .notDetermined
        let shouldRequestAlarm = {
            if #available(iOS 26.0, *) {
                return alarmPermissionState == .notDetermined
            }
            return false
        }()

        Task {
            var notificationGranted = notificationStatus == .authorized

            if shouldRequestNotification {
                notificationGranted = await NotificationManager.shared.requestNotificationAuthorization()
            }

            if shouldRequestAlarm, notificationGranted {
                _ = await NotificationManager.shared.requestAlarmAuthorization()
            }

            await refreshNotificationStatus()
            requestingPermission = false
            permissionMessage = permissionResultMessage(notificationGranted: notificationGranted)
            showingPermissionMessage = true
        }
    }

    private var notificationSoundText: String {
        switch notificationSoundSetting {
        case .enabled: "已开启"
        case .disabled: "已关闭"
        case .notSupported: "不支持"
        @unknown default: "未知"
        }
    }

    private func refreshNotificationStatus() async {
        let capability = await NotificationManager.shared.capabilityStatus()
        notificationStatus = capability.authorizationStatus
        notificationSoundSetting = capability.soundSetting
        alarmPermissionState = capability.alarmPermissionState
        alarmAuthorizationText = NotificationManager.shared.alarmAuthorizationDescription()
    }

    private var permissionButtonTitle: String {
        if allPermissionsGranted {
            return "权限已允许"
        }

        if notificationStatus == .notDetermined {
            return "申请通知权限"
        }

        if #available(iOS 26.0, *), notificationStatus == .authorized, alarmPermissionState == .notDetermined {
            return "申请闹钟权限"
        }

        return "前往系统设置"
    }

    private var permissionHintText: String {
        if allPermissionsGranted {
            return "当前设备上的通知权限和闹钟权限都已允许。"
        }

        if shouldOpenSystemSettings {
            return "系统不会重复弹出授权框。请到系统设置里手动开启通知和闹钟权限。"
        }

        if #available(iOS 26.0, *), alarmPermissionState == .notDetermined {
            return notificationStatus == .notDetermined
                ? "首次申请时会先请求通知权限，再请求闹钟权限。"
                : "当前只差闹钟权限；点按钮后应直接弹出闹钟授权。若仍不弹，首次创建闹钟时系统也可能自动触发授权。"
        }

        return "首次申请时会弹出系统授权框。"
    }

    private var shouldOpenSystemSettings: Bool {
        notificationStatus == .denied || alarmPermissionState == .denied
    }

    private var allPermissionsGranted: Bool {
        if #available(iOS 26.0, *) {
            return notificationStatus == .authorized && alarmPermissionState == .authorized
        }

        return notificationStatus == .authorized
    }

    private var permissionButtonDisabled: Bool {
        allPermissionsGranted || requestingPermission
    }

    private func permissionResultMessage(notificationGranted: Bool) -> String {
        if notificationStatus == .denied {
            return "通知权限已被拒绝。请到系统设置中手动开启。"
        }

        if #available(iOS 26.0, *), alarmPermissionState == .denied {
            return "闹钟权限已被拒绝。请到系统设置中手动开启。"
        }

        if allPermissionsGranted {
            return "权限已更新，闹钟式提醒现在可以使用。"
        }

        if notificationGranted {
            if #available(iOS 26.0, *), alarmPermissionState == .notDetermined {
                return "通知权限已允许，但闹钟权限仍是“未决定”。你现在可以直接新建一个开启“闹钟式提醒”的目标，首次真正创建闹钟时系统也可能自动弹出授权。"
            }
            return "通知权限已更新。"
        }

        return "系统没有授予新的权限。若之前点过“不允许”，需要到系统设置中手动开启。"
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            permissionMessage = "无法打开系统设置，请手动前往“设置 > 懒人不懒”。"
            showingPermissionMessage = true
            return
        }

        UIApplication.shared.open(url)
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
