#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SWIFT_ROOT = ROOT / "LazyButNot"
CATALOG_PATH = SWIFT_ROOT / "Localizable.xcstrings"

LOCALIZED_CALL_RE = re.compile(r'String\(localized:\s*"([^"]+)"\s*,\s*defaultValue:\s*"([^"]*)"')
LOCALIZED_RESOURCE_RE = re.compile(r'LocalizedStringResource\(\s*"([^"]+)"\s*,\s*defaultValue:\s*"([^"]*)"')
CHINESE_STRING_RE = re.compile(r'"([^"\n]*[\u4e00-\u9fff][^"\n]*)"')

EN_OVERRIDES = {
    "今日": "Today",
    "目标": "Goals",
    "统计": "Stats",
    "设置": "Settings",
    "暖阳橙": "Sunrise Orange",
    "海岸蓝": "Ocean Blue",
    "苔原绿": "Forest Green",
    "基础版": "Base Theme",
    "进阶主题": "Premium Theme",
    "基础主题": "Base Collection",
    "清透浅色": "Fresh Light",
    "暖调氛围": "Warm Atmosphere",
    "深色质感": "Dark Premium",
    "专注": "Focus",
    "学习": "Study",
    "阅读": "Reading",
    "健身": "Fitness",
    "作息": "Routine",
    "工作": "Work",
    "自定义": "Custom",
    "每天": "Daily",
    "每周固定日": "Weekly Fixed Days",
    "每周次数": "Weekly Count",
    "完成": "Completed",
    "保底完成": "Minimum Completed",
    "未完成": "Missed",
    "倒计时闹钟": "Countdown Alarm",
    "倒计时": "Countdown",
    "时间到了": "Time's up",
    "请及时处理这次提醒": "Please handle this reminder now.",
    "正在倒计时": "Counting Down",
    "倒计时已暂停": "Countdown Paused",
    "提醒已触发": "Alert Triggered",
    "已暂停": "Paused",
    "提醒中": "Alerting",
    "通知": "Notifications",
    "权限状态": "Permission Status",
    "通知声音": "Notification Sound",
    "闹钟提醒权限": "Alarm Permission",
    "重新同步所有提醒": "Resync All Reminders",
    "外观主题": "Appearance Themes",
    "预留付费": "Reserved for Paid Plan",
    "产品原则": "Product Principles",
    "最小行动": "Minimum Action",
    "把目标拆到不会失败": "Break goals into actions you won't fail to do",
    "持续坚持": "Stay Consistent",
    "状态差也别完全停下": "Do not stop completely on bad days",
    "主动提醒": "Active Reminder",
    "把记得做，变成被触发": "Turn remembering into being triggered",
    "关于": "About",
    "懒人不懒": "LazyButNot",
    "强调“持续坚持”而不是“高强度自律”的本地打卡 App。": "A local habit app focused on consistency instead of intense discipline.",
    "支持": "Support",
    "联系我们": "Contact Us",
    "问题反馈、建议与定制化需求": "Bug reports, suggestions, and custom requests",
    "如在使用过程中遇到问题或有建议，欢迎通过以下方式联系我们：": "If you run into any issues or have suggestions while using the app, please contact us through the following channel:",
    "我们会在 1–2 个工作日内回复": "We will reply within 1–2 business days.",
    "已复制邮箱": "Email Copied",
    "当前设备无法打开邮件 App，邮箱地址已复制到剪贴板。": "This device cannot open a mail app. The email address has been copied to the clipboard.",
    "个性化需求": "Personalized Requests",
    "如果你有个性化或定制化需求，也欢迎与我们沟通，我们会根据实际情况评估并持续优化产品能力。": "If you have personalized or custom needs, you are also welcome to contact us. We will evaluate them based on the actual situation and continue improving the product.",
    "你只需要持续坚持": "You just need consistency",
    "提醒权限": "Reminder Permission",
    "知道了": "OK",
    "未决定": "Not Determined",
    "已拒绝": "Denied",
    "已允许": "Authorized",
    "临时允许": "Provisional",
    "临时会话": "Ephemeral",
    "未知": "Unknown",
    "已开启": "Enabled",
    "已关闭": "Disabled",
    "不支持": "Unsupported",
    "权限已允许": "Permission Granted",
    "申请通知权限": "Request Notification Permission",
    "申请闹钟权限": "Request Alarm Permission",
    "前往系统设置": "Open System Settings",
    "当前设备上的通知权限和闹钟权限都已允许。": "Notification and alarm permissions are already granted on this device.",
    "系统不会重复弹出授权框。请到系统设置里手动开启通知和闹钟权限。": "The system will not show the permission dialog again. Please enable notification and alarm permissions in Settings.",
    "首次申请时会先请求通知权限，再请求闹钟权限。": "The first request asks for notification permission and then alarm permission.",
    "当前只差闹钟权限；点按钮后应直接弹出闹钟授权。若仍不弹，首次创建闹钟时系统也可能自动触发授权。": "Only alarm permission is missing. Tapping the button should prompt for alarm access. If not, creating the first alarm may trigger it automatically.",
    "首次申请时会弹出系统授权框。": "The system permission dialog will appear on the first request.",
    "通知权限已被拒绝。请到系统设置中手动开启。": "Notification permission was denied. Please enable it in Settings.",
    "闹钟权限已被拒绝。请到系统设置中手动开启。": "Alarm permission was denied. Please enable it in Settings.",
    "权限已更新，闹钟式提醒现在可以使用。": "Permissions updated. Alarm-style reminders are now available.",
    "通知权限已允许，但闹钟权限仍是“未决定”。你现在可以直接新建一个开启“闹钟式提醒”的目标，首次真正创建闹钟时系统也可能自动弹出授权。": "Notification permission is granted, but alarm permission is still not determined. You can create a goal with alarm-style reminders enabled, and the first real alarm may also trigger the prompt.",
    "通知权限已更新。": "Notification permission updated.",
    "系统没有授予新的权限。若之前点过“不允许”，需要到系统设置中手动开启。": "No new permissions were granted. If you denied them before, please enable them manually in Settings.",
    "无法打开系统设置，请手动前往“设置 > 懒人不懒”。": "Unable to open Settings. Please go to Settings > LazyButNot manually.",
    "本周完成": "Completed This Week",
    "本周状态": "This Week Status",
    "已达标": "Completed",
    "连续完成": "Completion Streak",
    "规则": "Rules",
    "最小动作": "Minimum Action",
    "周期": "Schedule",
    "每周目标": "Weekly Target",
    "固定日期": "Fixed Days",
    "提醒时间": "Reminder Time",
    "截止时间": "Deadline",
    "监督提醒": "Supervision Reminder",
    "开启": "Enabled",
    "关闭": "Off",
    "暂停状态": "Pause Status",
    "进行中": "Active",
    "今天操作": "Today's Actions",
    "标记完成": "Mark Completed",
    "标记保底完成": "Mark Minimum Completed",
    "恢复提醒": "Resume Reminder",
    "暂停提醒": "Pause Reminder",
    "历史记录": "History",
    "还没有打卡记录": "No check-in records yet",
    "删除目标": "Delete Goal",
    "目标不存在": "Goal Not Found",
    "目标详情": "Goal Details",
    "编辑": "Edit",
    "删除后将移除该目标及历史记录": "Deleting will remove this goal and its history",
    "删除": "Delete",
    "闹钟式提醒": "Alarm-style Reminder",
    "提醒声音": "Reminder Sound",
    "单次通知音": "Single Notification Sound",
    "还没有目标": "No Goals Yet",
    "把大目标拆成最小动作，再交给提醒系统去盯。": "Break big goals into the smallest actions and let the reminder system keep you on track.",
    "暂停": "Paused",
    "分类": "Category",
    "提醒": "Reminder",
    "本周": "This Week",
    "坚持": "Consistency",
    "今天还没有目标": "No Goals for Today",
    "先建立一个最小可执行目标": "Create a minimum executable goal first",
    "待完成": "Pending",
    "已完成": "Completed",
    "今天": "Today",
    "持续坚持，比爆发更重要": "Consistency matters more than bursts.",
    "雾玫瑰": "Rose Mist",
    "夜幕金": "Midnight Gold",
    "冰川雾紫": "Glacier Lavender",
    "琥珀暮光": "Amber Dusk",
    "薄荷云岚": "Mint Haze",
    "赤陶砂": "Terracotta Sand",
    "极夜青": "Polar Night",
    "总目标": "Total Goals",
    "开启专注模式": "Start Focus Mode",
    "支持锁屏、灵动岛与待机显示": "Supports Lock Screen, Dynamic Island, and StandBy.",
    "取消中...": "Cancelling...",
    "放弃专注": "Give Up Focus",
    "总览": "Overview",
    "目标总数": "Total Goals",
    "今日完成": "Completed Today",
    "坚持中目标": "Goals in Progress",
    "今日待完成": "Pending Today",
    "按目标": "By Goal",
    "还没有目标数据": "No goal data yet",
    "本周进度": "This Week Progress",
    "累计打卡": "Total Check-ins",
    "本周次数": "This Week Count",
    "周日": "Sun",
    "周一": "Mon",
    "周二": "Tue",
    "周三": "Wed",
    "周四": "Thu",
    "周五": "Fri",
    "周六": "Sat",
    "基本信息": "Basic Info",
    "目标名称": "Goal Name",
    "最小完成标准，例如：做 1 题": "Minimum completion standard, e.g. solve 1 question",
    "目标说明": "Goal Description",
    "周期类型": "Schedule Type",
    "默认提醒时间": "Default Reminder Time",
    "开启监督提醒": "Enable Supervision Reminder",
    "暂停目标": "Pause Goal",
    "新建目标": "Create Goal",
    "编辑目标": "Edit Goal",
    "取消": "Cancel",
    "保存": "Save",
    "确定": "Confirm",
    "固定日": "Fixed Days",
    "监督提前量": "Supervision Lead Time",
    "未设置": "Not Set",
    "开启闹钟式提醒": "Enable Alarm-style Reminder",
    "开启提醒声音": "Enable Reminder Sound",
    "开启后，到截止前会像系统闹钟一样提醒你；如果没开权限，需要先到系统设置里允许。": "When enabled, reminders before the deadline will work like system alarms. If permission is not granted, enable it in Settings first.",
    "当前系统版本不支持闹钟式提醒，只能使用普通通知。": "This iOS version does not support alarm-style reminders. Standard notifications will be used.",
    "当前系统不支持": "Unsupported on Current System",
    "闹钟式提醒需要 iOS 26 及以上版本，升级系统后才可以使用。": "Alarm-style reminders require iOS 26 or later.",
    "闹钟权限未开启": "Alarm Permission Disabled",
    "请前往系统设置，为“懒人不懒”打开闹钟权限后再使用闹钟式提醒。": "Please enable alarm permission for LazyButNot in Settings before using alarm-style reminders.",
    "未开启闹钟权限时，无法使用闹钟式提醒。请前往系统设置打开权限。": "Alarm-style reminders cannot be used without alarm permission. Please enable it in Settings.",
    "当前设备暂时无法使用闹钟式提醒。": "Alarm-style reminders are currently unavailable on this device.",
    "专注倒计时": "Focus Countdown",
    "提醒标题": "Reminder Title",
    "场景": "Context",
    "倒计时时长": "Countdown Duration",
    "触发后": "After Trigger",
    "允许再次倒计时": "Allow Repeat Countdown",
    "再次提醒间隔": "Repeat Reminder Interval",
    "说明": "Description",
    "开始后，系统会帮你启动一个带持续提醒的专注倒计时；剩余时间也会同步显示在锁屏和灵动岛上;您可随时右滑清除该倒计时。": "After starting, the system launches a focus countdown with persistent reminders. The remaining time also appears on the Lock Screen and Dynamic Island. You can swipe it away at any time.",
    "创建中...": "Creating...",
    "开始": "Start",
    "倒计时闹钟需要 iOS 26 及以上版本。": "Countdown alarms require iOS 26 or later.",
    "无法创建闹钟": "Unable to Create Alarm",
    "请先在系统中允许本 App 使用闹钟权限。": "Please grant alarm permission for this app in Settings first.",
    "创建失败": "Creation Failed",
    "系统没有成功创建倒计时闹钟，请稍后再试。": "The system failed to create the countdown alarm. Please try again later.",
    "自定义": "Custom",
    "focus.canceling": "Cancelling...",
    "focus.abandon": "Give Up Focus",
    "format.day_count": "%lld days",
    "format.minute_count": "%lld min",
    "format.weekly_target_count": "%lld times per week",
    "format.times_count": "%lld times",
    "format.weekly_remaining": "%lld times remaining",
    "home.completed_summary": "Completed %1$lld / %2$lld goals today",
    "goal.weekly_progress_compact": "Week %1$lld/%2$lld",
    "goal.weekly_completed_metric": "%1$lld/%2$lld",
    "goal.deadline_chip": "Deadline %1$02lld:%2$02lld",
    "minute.custom_option": "Custom (%lld min)",
    "countdown.status.in_progress": "%@ in progress",
    "countdown.status.paused": "%@ paused",
    "notification.reminder.body": "Start \"%@\" now. Even the minimum action counts.",
    "notification.supervision.body": "\"%@\" is due in %2$lld minutes. Don't forget to finish it.",
    "notification.deadline_alert.title": "\"%@\" is almost due",
    "countdown.action.close": "Close",
    "countdown.action.pause": "Pause",
    "countdown.action.repeat": "Repeat",
    "countdown.action.resume": "Resume",
    "notification.action.stop": "Stop",
    "enum.goal_category.study": "Study",
    "enum.goal_category.fitness": "Fitness",
    "enum.goal_category.reading": "Reading",
    "enum.goal_category.routine": "Routine",
    "enum.goal_category.work": "Work",
    "enum.goal_category.custom": "Custom",
    "enum.goal_period_type.daily": "Daily",
    "enum.goal_period_type.weekly_fixed_days": "Weekly Fixed Days",
    "enum.goal_period_type.weekly_count": "Weekly Count",
    "enum.checkin_status.completed": "Completed",
    "enum.checkin_status.minimum_completed": "Minimum Completed",
    "enum.checkin_status.missed": "Missed",
    "goal.badge.checked": "Checked In",
    "goal.badge.minimum_checked": "Minimum Check-in",
    "goal.status.pending": "Pending",
    "stats.weekly_status.completed": "Completed",
    "countdown.context.focus": "Focus",
    "notification.reminder.title": "Time to Check In",
    "notification.supervision.title": "Deadline Approaching",
    "common.close": "Close",
    "common.repeat": "Repeat",
    "common.pause": "Pause",
    "common.resume": "Resume",
    "common.stop": "Stop",
    "countdown.default_title": "Countdown Reminder",
    "countdown.alarm_title": "Countdown Alarm",
    "countdown.short_title": "Countdown",
    "countdown.time_up": "Time's up",
    "countdown.time_up_message": "Please handle this reminder now.",
    "countdown.status.paused_fallback": "Countdown Paused",
    "countdown.status.alert_triggered": "Alert Triggered",
    "countdown.status.paused_short": "Paused",
    "取消": "Cancel",
    "确定": "Confirm",
    "创建中...": "Creating...",
    "创建失败": "Creation Failed",
    "编辑": "Edit",
    "保存": "Save",
    "开始": "Start",
    "说明": "Description",
    "未设置": "Not Set",
    "关闭": "Close",
    "规则": "Rules",
    "目标详情": "Goal Details",
    "删除目标": "Delete Goal",
    "截止时间": "Deadline",
    "提醒时间": "Reminder Time",
    "监督提醒": "Supervision Reminder",
    "固定日期": "Fixed Days",
    "最小动作": "Minimum Action",
    "周期": "Schedule",
    "每周目标": "Weekly Target",
    "今天操作": "Today's Actions",
    "恢复提醒": "Resume Reminder",
    "暂停提醒": "Pause Reminder",
    "标记完成": "Mark Completed",
    "标记保底完成": "Mark Minimum Completed",
    "删除后将移除该目标及历史记录": "Deleting will remove this goal and its history",
    "无法创建闹钟": "Unable to Create Alarm",
    "请先在系统中允许本 App 使用闹钟权限。": "Please grant alarm permission for this app in Settings first.",
    "系统没有成功创建倒计时闹钟，请稍后再试。": "The system failed to create the countdown alarm. Please try again later.",
    "倒计时时长": "Countdown Duration",
    "再次提醒间隔": "Repeat Reminder Interval",
    "触发后": "After Trigger",
    "场景": "Context",
    "提醒标题": "Reminder Title",
    "进行中": "Active",
    "当前系统不支持": "Unsupported on Current System",
    "专注倒计时": "Focus Countdown",
    "总目标": "Total Goals",
    "持续坚持，比爆发更重要": "Consistency matters more than bursts.",
    "目标不存在": "Goal Not Found",
    "调试": "Debug",
    "多语言调试": "Localization Debug",
    "语言调试": "Language Debug",
    "应用语言": "App Language",
    "跟随系统": "Follow System",
    "简体中文": "Simplified Chinese",
    "Debug 设置": "Debug Settings",
    "用于开发阶段快速预览多语言效果。切换后当前界面会立即刷新。": "Use this during development to preview localizations quickly. The current UI refreshes immediately after switching.",
    "%@已暂停": "%@ paused",
    "%@进行中": "%@ in progress",
    "%lld 分钟": "%lld min",
    "%lld 天": "%lld days",
    "%lld 次": "%lld times",
    "「%@」即将截止": "\"%@\" is almost due",
    "「%@」将在 %lld 分钟后截止，别忘记完成哦。": "\"%@\" is due in %lld minutes. Don't forget to finish it.",
    "临近截止": "Deadline Approaching",
    "今天完成 %lld / %lld 个目标": "Completed %lld / %lld goals today",
    "倒计时提醒": "Countdown Reminder",
    "停止": "Stop",
    "已保底打卡": "Minimum Check-in",
    "已打卡": "Checked In",
    "截止 %02lld:%02lld": "Deadline %02lld:%02lld",
    "本周 %lld/%lld": "Week %lld/%lld",
    "每周 %lld 次": "%lld times per week",
    "现在开始「%@」，先做最小动作也算完成。": "Start \"%@\" now. Even the minimum action counts.",
    "继续": "Resume",
    "自定义（%lld 分钟）": "Custom (%lld min)",
    "该打卡了": "Time to Check In",
    "还差 %lld 次": "%lld times remaining",
    "重复": "Repeat",
}


def is_probably_user_facing(text: str) -> bool:
    if text.startswith("com.") or "/" in text or "\\(" in text and "String(localized:" not in text:
        return True
    return True


def iter_swift_files():
    for path in SWIFT_ROOT.rglob("*.swift"):
        yield path


def collect_entries():
    entries = {}
    for path in iter_swift_files():
        content = path.read_text(encoding="utf-8")
        for key, default in LOCALIZED_CALL_RE.findall(content):
            entries[key] = default
        for key, default in LOCALIZED_RESOURCE_RE.findall(content):
            entries[key] = default
        stripped = LOCALIZED_CALL_RE.sub("", content)
        stripped = LOCALIZED_RESOURCE_RE.sub("", stripped)
        for literal in CHINESE_STRING_RE.findall(stripped):
            if not is_probably_user_facing(literal):
                continue
            entries.setdefault(literal, literal)
    return entries


def load_catalog():
    if CATALOG_PATH.exists():
        return json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    return {"sourceLanguage": "zh-Hans", "strings": {}, "version": "1.0"}


def make_string_entry(zh_value: str, en_value: str):
    return {
        "extractionState": "manual",
        "localizations": {
            "en": {"stringUnit": {"state": "translated", "value": en_value}},
            "zh-Hans": {"stringUnit": {"state": "translated", "value": zh_value}},
        },
    }


def dumps_xcode_json(payload):
    text = json.dumps(payload, ensure_ascii=False, indent=2)
    lines = []
    for line in text.splitlines():
        lines.append(re.sub(r'^(\s*)"([^"]+)"\s*:', r'\1"\2" :', line))
    return "\n".join(lines) + "\n"


def main():
    catalog = load_catalog()
    entries = collect_entries()
    existing_strings = catalog.get("strings", {})
    strings = {}
    remaining_keys = set(entries)

    for key in existing_strings:
        if key not in entries:
            continue
        zh_value = entries[key]
        en_value = EN_OVERRIDES.get(key) or EN_OVERRIDES.get(zh_value, zh_value)
        strings[key] = make_string_entry(zh_value, en_value)
        remaining_keys.discard(key)

    for key in sorted(remaining_keys):
        zh_value = entries[key]
        en_value = EN_OVERRIDES.get(key) or EN_OVERRIDES.get(zh_value, zh_value)
        strings[key] = make_string_entry(zh_value, en_value)

    catalog["strings"] = strings
    CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(dumps_xcode_json(catalog), encoding="utf-8")
    print(f"synced {len(entries)} entries to {CATALOG_PATH}")


if __name__ == "__main__":
    main()
