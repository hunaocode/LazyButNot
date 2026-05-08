import SwiftUI
import UserNotifications
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var goalStore: GoalStore
    @EnvironmentObject private var themeStore: ThemeStore
#if DEBUG
    @EnvironmentObject private var languageStore: LanguageStore
#endif
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var notificationSoundSetting: UNNotificationSetting = .notSupported
    @State private var alarmPermissionState: AlarmPermissionState = .unavailable
    @State private var alarmAuthorizationText: String?
    @State private var requestingPermission = false
    @State private var permissionMessage = ""
    @State private var showingPermissionMessage = false

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    var body: some View {
        List {
            Section(String(localized: "settings.section.notifications", defaultValue: "通知")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(String(localized: "settings.permission_status", defaultValue: "权限状态"))
                            .foregroundStyle(palette.primaryText)
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundStyle(palette.secondaryText)
                    }

                    HStack {
                        Text(String(localized: "settings.notification_sound", defaultValue: "通知声音"))
                            .foregroundStyle(palette.primaryText)
                        Spacer()
                        Text(notificationSoundText)
                            .foregroundStyle(palette.secondaryText)
                    }

                    if let alarmAuthorizationText {
                        HStack {
                            Text(String(localized: "settings.alarm_permission", defaultValue: "闹钟提醒权限"))
                                .foregroundStyle(palette.primaryText)
                            Spacer()
                            Text(alarmAuthorizationText)
                                .foregroundStyle(palette.secondaryText)
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
                    .foregroundStyle(permissionButtonDisabled ? palette.subtleText : palette.accent)

                    Text(permissionHintText)
                        .font(.footnote)
                        .foregroundStyle(palette.subtleText)

                    Button(String(localized: "settings.resync_all_reminders", defaultValue: "重新同步所有提醒")) {
                        Task {
                            await NotificationManager.shared.scheduleAll(goals: goalStore.goals)
                        }
                    }
                    .foregroundStyle(palette.accent)
                }
                .settingsSectionCardStyle(palette)
            }
            
            Section(String(localized: "settings.section.support", defaultValue: "支持")) {
                NavigationLink {
                    ContactUsView()
                        .environmentObject(themeStore)
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.iconBackground)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "envelope.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "settings.contact.title", defaultValue: "联系我们"))
                                .font(.headline)
                                .foregroundStyle(palette.primaryText)
                            Text(String(localized: "settings.contact.entry_subtitle", defaultValue: "问题反馈、建议与定制化需求"))
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryText)
                        }
                    }
                }
                .settingsSectionCardStyle(palette)
            }

            Section(String(localized: "settings.section.themes", defaultValue: "外观主题")) {
                NavigationLink {
                    ThemeSettingsView()
                        .environmentObject(themeStore)
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(themeStore.selectedTheme.palette.detailBackground)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "settings.section.themes", defaultValue: "外观主题"))
                                .font(.headline)
                                .foregroundStyle(palette.primaryText)
                            Text(themeStore.selectedTheme.displayName)
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryText)
                        }
                    }
                }
                .settingsSectionCardStyle(palette)
            }

            Section(String(localized: "settings.section.principles", defaultValue: "产品原则")) {
                VStack(alignment: .leading, spacing: 12) {
                    principleRow(String(localized: "settings.principle.minimum_action.title", defaultValue: "最小行动"), String(localized: "settings.principle.minimum_action.subtitle", defaultValue: "把目标拆到不会失败"))
                    principleRow(String(localized: "settings.principle.consistency.title", defaultValue: "持续坚持"), String(localized: "settings.principle.consistency.subtitle", defaultValue: "状态差也别完全停下"))
                    principleRow(String(localized: "settings.principle.active_reminder.title", defaultValue: "主动提醒"), String(localized: "settings.principle.active_reminder.subtitle", defaultValue: "把记得做，变成被触发"))
                }
                .settingsSectionCardStyle(palette)
            }

            Section(String(localized: "settings.section.about", defaultValue: "关于")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "app.name", defaultValue: "懒人不懒"))
                        .font(.headline)
                        .foregroundStyle(palette.primaryText)
                    Text(String(localized: "settings.about.description", defaultValue: "强调“持续坚持”而不是“高强度自律”的本地打卡 App。"))
                        .foregroundStyle(palette.secondaryText)
                }
                .settingsSectionCardStyle(palette)
            }
            
#if DEBUG
            Section(String(localized: "settings.section.debug", defaultValue: "调试")) {
                NavigationLink {
                    DebugSettingsView()
                        .environmentObject(languageStore)
                } label: {
                    Label(
                        String(localized: "settings.debug.localization_entry", defaultValue: "多语言调试"),
                        systemImage: "globe"
                    )
                    .foregroundStyle(palette.primaryText)
                }
                .settingsSectionCardStyle(palette)
            }
#endif
        }
        .listStyle(.plain)
        .navigationTitle(L10n.tabSettings)
        .scrollContentBackground(.hidden)
        .background(themeStore.selectedTheme.palette.screenBackground)
        .task {
            await refreshNotificationStatus()
        }
        .alert(String(localized: "settings.permission_alert_title", defaultValue: "提醒权限"), isPresented: $showingPermissionMessage) {
            Button(String(localized: "common.ok", defaultValue: "知道了"), role: .cancel) { }
        } message: {
            Text(permissionMessage)
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined: L10n.statusNotDetermined
        case .denied: L10n.statusDenied
        case .authorized: L10n.statusAuthorized
        case .provisional: L10n.statusProvisional
        case .ephemeral: L10n.statusEphemeral
        @unknown default: L10n.statusUnknown
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
        case .enabled: L10n.statusEnabled
        case .disabled: L10n.statusDisabled
        case .notSupported: L10n.statusUnsupported
        @unknown default: L10n.statusUnknown
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
            return String(localized: "settings.permission_button.granted", defaultValue: "权限已允许")
        }

        if notificationStatus == .notDetermined {
            return String(localized: "settings.permission_button.request_notification", defaultValue: "申请通知权限")
        }

        if #available(iOS 26.0, *), notificationStatus == .authorized, alarmPermissionState == .notDetermined {
            return String(localized: "settings.permission_button.request_alarm", defaultValue: "申请闹钟权限")
        }

        return String(localized: "settings.permission_button.open_settings", defaultValue: "前往系统设置")
    }

    private var permissionHintText: String {
        if allPermissionsGranted {
            return String(localized: "settings.permission_hint.all_granted", defaultValue: "当前设备上的通知权限和闹钟权限都已允许。")
        }

        if shouldOpenSystemSettings {
            return String(localized: "settings.permission_hint.open_settings", defaultValue: "系统不会重复弹出授权框。请到系统设置里手动开启通知和闹钟权限。")
        }

        if #available(iOS 26.0, *), alarmPermissionState == .notDetermined {
            return notificationStatus == .notDetermined
                ? String(localized: "settings.permission_hint.first_request_both", defaultValue: "首次申请时会先请求通知权限，再请求闹钟权限。")
                : String(localized: "settings.permission_hint.only_alarm_missing", defaultValue: "当前只差闹钟权限；点按钮后应直接弹出闹钟授权。若仍不弹，首次创建闹钟时系统也可能自动触发授权。")
        }

        return String(localized: "settings.permission_hint.first_request_single", defaultValue: "首次申请时会弹出系统授权框。")
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
            return String(localized: "settings.permission_result.notification_denied", defaultValue: "通知权限已被拒绝。请到系统设置中手动开启。")
        }

        if #available(iOS 26.0, *), alarmPermissionState == .denied {
            return String(localized: "settings.permission_result.alarm_denied", defaultValue: "闹钟权限已被拒绝。请到系统设置中手动开启。")
        }

        if allPermissionsGranted {
            return String(localized: "settings.permission_result.all_granted", defaultValue: "权限已更新，闹钟式提醒现在可以使用。")
        }

        if notificationGranted {
            if #available(iOS 26.0, *), alarmPermissionState == .notDetermined {
                return String(localized: "settings.permission_result.notification_granted_alarm_pending", defaultValue: "通知权限已允许，但闹钟权限仍是“未决定”。你现在可以直接新建一个开启“闹钟式提醒”的目标，首次真正创建闹钟时系统也可能自动弹出授权。")
            }
            return String(localized: "settings.permission_result.notification_updated", defaultValue: "通知权限已更新。")
        }

        return String(localized: "settings.permission_result.no_new_permission", defaultValue: "系统没有授予新的权限。若之前点过“不允许”，需要到系统设置中手动开启。")
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            permissionMessage = String(localized: "settings.permission_result.cannot_open_settings", defaultValue: "无法打开系统设置，请手动前往“设置 > 懒人不懒”。")
            showingPermissionMessage = true
            return
        }

        UIApplication.shared.open(url)
    }

    private func principleRow(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(palette.primaryText)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(.vertical, 4)
    }

}

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    private var showsPremiumReservedBadge: Bool {
        false
    }

    var body: some View {
        List {
            Section(String(localized: "settings.section.themes", defaultValue: "外观主题")) {
                ForEach(ThemeCollection.allCases) { collection in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(collection.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.secondaryText)

                        ForEach(themes(in: collection)) { theme in
                            themeRow(theme)
                        }
                    }
                    .settingsSectionCardStyle(
                        palette,
                        insets: EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                    )
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(String(localized: "settings.section.themes", defaultValue: "外观主题"))
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(palette.screenBackground)
    }

    private func themes(in collection: ThemeCollection) -> [AppTheme] {
        AppTheme.allCases.filter { $0.collection == collection }
    }

    private func themeRow(_ theme: AppTheme) -> some View {
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
                            .foregroundStyle(palette.primaryText)
                        if showsPremiumReservedBadge && theme.isPremium {
                            Text(String(localized: "settings.premium_reserved", defaultValue: "预留付费"))
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(palette.chipFill)
                                .foregroundStyle(palette.chipText)
                                .clipShape(Capsule(style: .continuous))
                        }
                    }
                    Text(theme.tagline)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }

                Spacer()

                if themeStore.selectedTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.palette.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ContactUsView: View {
    @EnvironmentObject private var themeStore: ThemeStore
    @Environment(\.openURL) private var openURL
    @State private var showingCopiedAlert = false

    private let email = "hunao163@gmail.com"

    private var palette: ThemePalette {
        themeStore.selectedTheme.palette
    }

    private var mailURL: URL {
        URL(string: "mailto:\(email)")!
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(palette.iconBackground)
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: "envelope.open.fill")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                        )

                    Text(String(localized: "settings.contact.title", defaultValue: "联系我们"))
                        .font(.title2.bold())
                        .foregroundStyle(palette.primaryText)

                    Text(String(localized: "settings.contact.intro", defaultValue: "如在使用过程中遇到问题或有建议，欢迎通过以下方式联系我们："))
                        .font(.body)
                        .foregroundStyle(palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .contactCardStyle(palette)

                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "settings.contact.email_label", defaultValue: "Email"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.subtleText)

                    Button {
                        guard UIApplication.shared.canOpenURL(mailURL) else {
                            copyEmailToClipboard()
                            return
                        }

                        openURL(mailURL) { accepted in
                            if !accepted {
                                DispatchQueue.main.async {
                                    copyEmailToClipboard()
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                                .font(.subheadline.weight(.semibold))
                            Text(email)
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(palette.accent)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(palette.chipFill)
                        )
                    }
                    .buttonStyle(.plain)

                    Text(String(localized: "settings.contact.response_time", defaultValue: "我们会在 1–2 个工作日内回复"))
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                }
                .contactCardStyle(palette)

                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: "settings.contact.custom_title", defaultValue: "个性化需求"))
                        .font(.headline)
                        .foregroundStyle(palette.primaryText)

                    Text(String(localized: "settings.contact.custom_body", defaultValue: "如果你有个性化或定制化需求，也欢迎与我们沟通，我们会根据实际情况评估并持续优化产品能力。"))
                        .font(.body)
                        .foregroundStyle(palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .contactCardStyle(palette)
            }
            .padding(16)
        }
        .background(palette.screenBackground)
        .navigationTitle(String(localized: "settings.contact.title", defaultValue: "联系我们"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(String(localized: "settings.contact.email_copied_title", defaultValue: "已复制邮箱"), isPresented: $showingCopiedAlert) {
            Button(String(localized: "common.ok", defaultValue: "知道了"), role: .cancel) { }
        } message: {
            Text(String(localized: "settings.contact.email_copied_message", defaultValue: "当前设备无法打开邮件 App，邮箱地址已复制到剪贴板。"))
        }
    }

    private func copyEmailToClipboard() {
        UIPasteboard.general.string = email
        showingCopiedAlert = true
    }
}

private extension View {
    func settingsSectionCardStyle(
        _ palette: ThemePalette,
        insets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    ) -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(palette.border, lineWidth: 1)
                    )
            )
            .listRowInsets(insets)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    func contactCardStyle(_ palette: ThemePalette) -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(palette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(palette.border, lineWidth: 1)
                    )
                    .shadow(color: palette.shadow, radius: 14, y: 8)
            )
    }
}
