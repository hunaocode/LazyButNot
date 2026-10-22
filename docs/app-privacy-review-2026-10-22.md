# App Privacy 填写依据（版本 1.0 / Build 1）

核对日期：2026-10-22。目标 App：`com.hunaocode.LazyButNot`。

## 核对结果

- App Store Connect API 显示已上传 Build `1`，处理状态 `VALID`，最低系统 iOS 17.0。
- 本机正式归档为同一 Bundle ID、版本 `1.0`、Build `1`。版本字段一致；没有从 Apple 下载二进制逐字节比对。
- 归档内主 App 的 `PrivacyInfo.xcprivacy`：`NSPrivacyTracking=false`，`NSPrivacyCollectedDataTypes` 为空；申报 UserDefaults 所需 API，理由 `CA92.1`。
- 归档主 App 没有内嵌第三方 `Frameworks` 目录；链接的 Frameworks 是 Apple 系统框架。
- 源码检查未见 `URLSession`、上传任务、广告、第三方分析、跨 App 跟踪或云同步。目标和打卡记录写入 App 沙盒 `Application Support/LazyButNot/goals.json`；主题、语言和专注会话写入本机 `UserDefaults`。
- 提醒使用本机 `UserNotifications`、`AlarmKit` 和 `ActivityKit`。联系入口打开系统邮件 App，邮件由用户主动发送，不由本 App 自动采集或上传。
- 中英文隐私政策与当前本地数据处理方式一致。

根据 Apple 对“收集”的定义：数据需传出设备，供开发者或第三方在超过实时请求所需的时间内访问。仅在设备上处理的数据不计入 App Privacy 收集项。基于以上版本证据，建议选择“否，我们不会从此 App 中收集数据”。

## 后台操作

在 App Store Connect 打开“我的 App → 懒人不懒 → App 隐私”。隐私政策 URL 已填写；若页面仍为空，填入 `https://hunaocode.github.io/LazyButNot/privacy-policy/` 并保存。选择“开始”→“否，我们不会从此 App 中收集数据”→“保存”→核对产品页面预览→“发布”。“用户隐私选择 URL”可留空。

这里的“发布”是发布隐私问卷答案，不会提交 App 版本审核或上架。账号持有人提供的 App Store Connect 页面显示已发布，产品页面预览为“未收集数据”，数据类型显示“未从此 App 中收集数据”；`ASC-77` 已标记完成。若最终安装包与本机归档不同，或者后续加入服务器、广告、分析、账号、远程通知或第三方 SDK，应重新评估并更新回答。

Apple 文档：<https://developer.apple.com/cn/help/app-store-connect/manage-app-information/manage-app-privacy>；数据收集定义：<https://developer.apple.com/app-store/app-privacy-details/>。
