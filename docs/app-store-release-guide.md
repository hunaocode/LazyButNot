# 懒人不懒：首次上架 App Store 操作清单

核对日期：2026-10-17。以下按照当前工程的真实能力编写：SwiftUI、iOS 17+、本地目标与打卡记录、通知、iOS 26+ AlarmKit 和倒计时 Live Activity，无账户、无服务器、无广告、无内购。首版建议采用免费公开发行。

操作顺序：**账号与地区 → 固定两个 Bundle ID → 自动签名 → 创建商店 App → 补工程与隐私材料 → 真机测试 → Archive / Upload → TestFlight → 完善商店信息 → 提交审核 → 发布。**

## 0. 本次检查结果

| 项目 | 当前状态 | 上架前处理 |
| --- | --- | --- |
| Xcode | 26.5，iOS SDK 26.5 | 满足 Apple 当前 Xcode 26 / iOS 26 SDK 最低上传要求；提交时再看官方更新 |
| Release 编译 | 模拟器 Release 构建通过 | 不能替代真机测试 |
| Archive | 关闭签名的设备 Archive 通过 | 尚未验证正式分发签名，也没有上传 App Store Connect |
| 签名身份 | 本机目前可见 Apple Development 身份；工程为自动签名 | Archive / Upload 时让 Xcode 创建或选择托管的分发签名，并确认两个 Target 都成功签名 |
| Team | 当前工程中两个 Target 的 Debug / Release 均为 `ZT4G687V3G` | 确认这是你的有效付费开发者团队 |
| 主 App ID | `com.hunaocode.LazyButNot` | 确认该 ID 能在你的团队注册或已归属该团队 |
| 扩展 ID | `com.hunaocode.LazyButNot.widgetextension` | 同上，必须与主 App 同团队 |
| 版本 | 主 App / 扩展均为 Version `1.0`、Build `1` | 第一次上传可以使用；重新上传改过的包递增 Build |
| 最低系统 | 主 App 17.0，扩展 26.0 | 主 App 的 AlarmKit 使用有系统版本判断；保留兼容策略并验证低版本 |
| 内嵌扩展兼容 | 归档包中主 App `MinimumOSVersion = 17.0`、扩展为 `26.0` | 本地 Archive 不代表商店校验通过；正式包必须先跑 Validate App。若出现 `ITMS-90362`，需统一部署目标或调整扩展兼容方案后再上传 |
| 设备 | iPhone + iPad | 保留此配置就要测试 iPad 并提供 iPad 截图 |
| 隐私清单 | 已加入主 App，并在无签名设备 Archive 中确认打包 | 正式签名 Archive 后再复核一次 |
| 隐私政策入口 | 设置页已提供中英文 App 内隐私政策入口；完整政策已发布到公开 HTTPS 页面 | 在 Connect 填写 `https://hunaocode.github.io/LazyButNot/privacy-policy/` |
| 图标 | 全部 AppIcon 已重新生成为无 Alpha PNG；1024×1024 图标填满方形画布且未预裁圆角 | 正式上传前保留一次归档资源复核 |

以上是检查结果，本文没有修改功能代码、签名配置或 Apple 账号中的记录。

## 1. 确认账号、协议与首发地区

1. 登录 <https://developer.apple.com/account/>，在 Membership 中确认 Apple Developer Program 已生效，记录 Team ID。
2. 登录 <https://appstoreconnect.apple.com/>，由 Account Holder 接受 Business（商务）中待处理的最新协议。仅付款成功不等于所有账号流程均已生效。
3. 首版免费、无内购时，通常不需要为了销售结算先完成付费 App 的银行和税务流程。若改为付费下载或加入内购，需要另外签署 Paid Apps Agreement，并完成税务、银行资料。账号或地区合规页面要求的资料仍应按提示完成。
4. 中国大陆开发者还应在 Connect 的 **Business → Agreements → Compliance** 查看是否需要补充《国务院令第 810 号》信息。个人按页面要求填写居民身份证姓名和号码；组织确认 D-U-N-S 与统一社会信用代码资料完整。此项与 App 是否免费、是否在中国大陆商店发行不是同一个判断。
5. 在选销售地区前判断：
   - **中国大陆**：核实本 App 的 APP 备案适用性及 Connect 当前要求；如要求备案，先取得并填写对应的 APP 备案号，名称和主体等信息须与备案一致。网页的 ICP 备案不能直接当作 APP 备案使用。不要只凭“纯本地”自行认定已豁免。若备案尚未准备好，可以先发行到已满足要求的地区，之后增加中国大陆；这不等于已在中国大陆上架。
   - **欧盟**：如实完成 DSA 交易者身份声明。Apple 当前说明，即使不在欧盟发行，也可能在提交新 App 时要求声明身份；在欧盟作为交易者发行还需验证联系信息。个人开发者或免费 App 不自动等于非交易者。
6. 个人账号的商店销售者信息通常显示本人法定姓名。组织账号使用组织相关信息；商店产品名与销售者姓名是不同字段。

完成标准：会员有效、能进入 Connect、待签协议已处理、首发地区已确定。

## 2. 固定 App 的各类 ID

| 名称 | 本项目填写值 / 来源 | 用途 |
| --- | --- | --- |
| Team ID | 以会员页面为准；当前工程为 `ZT4G687V3G` | 标识开发者团队，所有 Target 必须一致 |
| 主 App Bundle ID | `com.hunaocode.LazyButNot` | Xcode、Developer Identifiers、Connect 三处对应 |
| 扩展 Bundle ID | `com.hunaocode.LazyButNot.widgetextension` | 给内嵌 Widget / Live Activity 扩展签名 |
| Developer App ID | 在 Identifiers 注册的 Explicit App ID | 绑定 Bundle ID 和能力；App ID Prefix 由 Apple 管理，新团队通常与 Team ID 相同 |
| SKU | 建议 `lazybutnot-ios-001` | 自定义内部编号，不向用户展示，创建后不能更改 |
| Connect Apple ID | 创建 App 后自动生成的数字 | 商店链接使用的 ID，不是登录邮箱，不需要自己申请 |
| Version | `1.0` | 用户看到的版本号，对应 Connect 版本 |
| Build | `1`，以后递增 | 区分上传的不同二进制包 |
| URL Scheme | 当前 `lazybutnot://` | App 内页面回跳，属于本地 URL 配置，不需要另建 Developer App ID |

进入 Developer → **Certificates, Identifiers & Profiles → Identifiers → + → App IDs → App**，注册两条 **Explicit** 标识：

- Description：`LazyButNot`；Bundle ID：`com.hunaocode.LazyButNot`。
- Description：`LazyButNot Widget Extension`；Bundle ID：`com.hunaocode.LazyButNot.widgetextension`。

当前功能无需为了“提醒”勾选 Push Notifications、Critical Alerts、App Groups 或 iCloud，权限对应关系见第 5 步。

若提示 Bundle ID 不可用，先检查是否已在本团队注册。若归属另一团队，新账号不能仅靠改 Team 接管它；对于尚未发布的新 App，应在创建 Connect 记录和首次上传前改成自己能注册的两个 ID，扩展 ID 保持以主 ID 加点号开头。已发布 App 迁移属于 App Transfer 流程。

一个主 App + 一个扩展，意味着 **两条 Identifier / 两份描述文件，但只有一个 Connect App 记录**。扩展随主 App 一起上传和审核。

## 3. 配证书与描述文件：首版优先使用自动签名

先理解四样东西：

| 项目 | 作用 | 是否每个 Target 都要单独创建 |
| --- | --- | --- |
| Apple Development | 开发阶段在真机运行 | 不需要，可供两个 Target 使用 |
| Apple Distribution / Xcode 托管分发签名 | App Store / TestFlight 分发签名 | 不需要给扩展额外建一张证书 |
| 私钥 | 和证书组成签名身份 | 本地创建的私钥在钥匙串中，只有 `.cer` 不足以在另一台 Mac 签名 |
| Provisioning Profile（描述文件） | 关联 App ID、证书、能力；开发描述文件还包含测试设备 | 主 App 和扩展各需要匹配自己的描述文件；自动签名会管理 |

推荐实际操作：

1. Xcode → **Settings → Accounts / Apple Accounts → +**，登录开发者 Apple Account。
2. 打开 `LazyButNot/LazyButNot.xcodeproj`。
3. 选择主 Target `LazyButNot` → **Signing & Capabilities**，勾选 **Automatically manage signing**，选择有效付费 Team，确认 Bundle ID。
4. 对 `LazyButNotWidgetExtension` 做同样操作；Debug 和 Release 都要正确。
5. 连接 iPhone，必要时开启手机的 Developer Mode，在 Xcode 选手机并 Run。Xcode 根据需要创建开发签名与开发描述文件，并处理设备注册。
6. Archive 后的 Distribute App 流程继续选择自动管理签名，交给 Xcode 准备分发描述文件和所需分发签名。

此路径不要求先手工创建 CSR、下载 `.cer`、导出 `.p12`。Xcode Accounts → Team → Manage Certificates 可以检查本地开发/分发证书，但不要把本地“没有 Apple Distribution”直接等同于无法上传，Xcode 也支持托管分发签名。

完成标准：两个 Target 在同一付费团队下签名正常，主 App 能通过 Xcode 安装到真机。自动签名无错误时直接继续。

### 仅在必须手动签名时使用的备用路径

1. 钥匙串访问 → 证书助理 → 从证书颁发机构请求证书，填写邮箱及 Common Name，CA Email 留空，保存 CSR 到磁盘。
2. Developer → Certificates → + → **Apple Distribution** → 上传 CSR → 下载 `.cer` → 双击安装。私钥留在生成 CSR 的 Mac 上；钥匙串“我的证书”中应能展开看到它。
3. Developer → Profiles → + → Distribution 下 **App Store Connect**，选主 App ID、Distribution 证书并生成 `LazyButNot-AppStore`。
4. 为扩展 ID 再生成 `LazyButNotWidget-AppStore`，可使用同一张 Distribution 证书。App Store 描述文件无需添加用户设备 UDID。
5. 下载并安装两个 `.mobileprovision`，在 Xcode Release 手动签名时分别选择对应 Profile 和 Apple Distribution。Debug 仍可使用开发签名。
6. 换 Mac / CI 需要本地签名身份时，从钥匙串导出含私钥的、带密码保护的 `.p12` 并妥善保管；不要提交到 Git。

自动和手动方案选择一套贯穿相应的签名流程。修改 Developer 能力后，手工管理的 Profile 需要重新生成。

## 4. 在 App Store Connect 创建唯一的 App 记录

Connect → **Apps / 我的 App → + → New App / 新建 App**：

| 字段 | 建议填写 |
| --- | --- |
| Platforms | iOS；同一个 iOS App 可以包含 iPhone / iPad |
| Name | `懒人不懒`，若名称被占用再选可用的真实产品名；最多 30 字符 |
| Primary Language | 简体中文 |
| Bundle ID | 选择主 App 的 `com.hunaocode.LazyButNot` |
| SKU | `lazybutnot-ios-001` |
| User Access | 单人开发选择 Full Access 即可 |

Bundle ID 列表找不到时，检查当前 Connect 团队、Identifier 是否已注册，以及账号权限；不要选择扩展 ID。

创建后记录数字 Apple ID。首次上传后 Bundle ID 不能修改；SKU 创建后不能修改。显示名称以后可按版本流程修改。

## 5. 按实际功能配置权限与隐私

| 功能 | 工程 / 运行时要求 | Developer 后台 / 证书要求 |
| --- | --- | --- |
| 普通本地通知 | `UNUserNotificationCenter` 请求 alert、badge、sound；当前已有 | 不需要 Push Notifications 能力、APNs Key 或推送证书 |
| AlarmKit 闹钟 | iOS 26+；`NSAlarmKitUsageDescription` 非空并调用授权 API；当前已有中英说明 | 当前用法无需另申 Critical Alerts 权限或闹钟证书 |
| 锁屏 / 灵动岛倒计时 | 主 App `NSSupportsLiveActivities = YES`；保留并嵌入 Widget 扩展；当前已有 | 扩展需自己的 Identifier / Profile；当前由本地 AlarmKit 驱动，不需要远程推送 |
| JSON / UserDefaults 本地存储 | App 沙盒内读写；无需向用户弹“文件权限” | 无需 iCloud / App Groups；UserDefaults 需要隐私清单用途声明 |
| 联系我们邮件 | 用户点击后打开邮件 App，无法打开时复制邮箱；当前已有 `mailto` 查询配置 | 不需要通讯录权限或邮件证书 |

当前实现没有使用相机、麦克风、定位、照片、健康数据或广告跟踪，因此无需增加这些权限说明。也无需为本地通知或系统 AlarmKit 额外开启后台音频、Background Fetch 或 Remote notifications。

**隐私有三个分别要完成的项目：**

1. **工程中的 Privacy Manifest**：新增 `PrivacyInfo.xcprivacy`，加入主 App Target 的资源。当前已确认的用途是 App 自己的 UserDefaults 偏好与专注会话，可声明 `NSPrivacyAccessedAPICategoryUserDefaults`，reason 为 `CA92.1`。它不是运行时权限弹窗，也不能由 Connect 的“不收集数据”选项替代。若扩展或后续 SDK 自己使用 required reason API，应在其所属 bundle 内按实际使用补充声明。
2. **用户可读的隐私政策**：发布可公开访问、无需登录的 HTTPS 页面，并在 App 设置页添加入口；Connect 的 Privacy Policy URL 填同一政策页面。说明本地记录、通知与闹钟授权、无广告/跟踪/服务端同步、删除目标与卸载的效果、系统备份可能保存的数据，以及主动邮件反馈的处理和联系邮箱。不要把“没有业务服务器”写成绝对不会发生任何形式的数据备份。
3. **Connect App Privacy 问卷**：基于当前未发现网络上传、统计或广告 SDK 的实现，通常可选择“不收集此 App 的数据”。提交前对最终包与实际服务重新确认；主动客服邮件是否适用可选披露需按 Apple 条件判断，若后来加入统计、崩溃上传、广告、登录或云同步，必须更新答案和政策。

当前代码对应的主 App 隐私清单参考内容：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array><string>CA92.1</string></array>
        </dict>
    </array>
</dict>
</plist>
```

另外确认出口合规：当前未发现非豁免加密功能，确认最终依赖后可以在主 App `Info.plist` 添加 `ITSAppUsesNonExemptEncryption = NO`。该键的意思是“没有使用非豁免加密”，不能因为应用会使用系统安全能力就机械回答相反选项；按 Connect 实际问题如实回答。

## 6. 准备正式包、网页和截图

1. 主 App / 扩展的 Version 均为 `1.0`、Build 均为 `1`；重传更改后的包时两者同步增加 Build。
2. 修正带 Alpha 的 AppIcon，确保商店图标为 1024×1024、无 Alpha，填满方形画布，不自己预裁圆角。
3. 核实 `NSAlarmKitUsageDescription` 覆盖目标监督与专注倒计时两个实际用途，中英文都同步。
4. 发布两个可公开打开的页面：隐私政策和技术支持。支持页至少有 App 名称、联系邮箱、使用与提醒权限说明；当前 App 内邮箱为 `hunao163@gmail.com`，确认这是你维护的地址。
5. 当前支持 iPhone + iPad，准备至少各一组真实界面截图。每个必需尺寸组可传 1–10 张，建议 3–5 张：今日目标、创建目标、统计、专注倒计时、主题。用演示内容，避免私人目标。

当前官方接受的实用竖屏尺寸：

| 设备槽位 | 建议尺寸 | 本项目 |
| --- | --- | --- |
| iPhone 6.9 英寸 | `1320 × 2868`；也接受官方列出的 `1290 × 2796` / `1260 × 2736` | 提供此组可覆盖其他对应 iPhone 槽位的缩放要求 |
| iPad 13 英寸 | `2064 × 2752` 或 `2048 × 2732` | 保留 iPad 支持时必需 |

截图为无 Alpha 的 JPEG / PNG；视频预览可不做。若决定首版只支持 iPhone，应在正式首次上传前调整工程支持设备并重新构建，这不是只在 Connect 不上传 iPad 截图就能实现的。

最低运行系统与构建 SDK 是不同设置：当前用 iOS 26 SDK 构建，主 App 仍可按现有设计支持 iOS 17；不要为了满足 SDK 上传要求直接把主 App 的最低系统提高到 26。扩展使用 AlarmKit，不能直接把其最低系统降到 17。

商店文案应明确专注倒计时、AlarmKit 和本项目的 Live Activity 需要 iOS 26+。当前提醒使用预设时间窗口，不要宣传“永不打开 App 也能永久自动提醒”。

## 7. 真机回归后 Archive 并上传

至少验证：首次启动、拒绝通知后仍可记录目标、允许通知后实际触发、iOS 26 闹钟授权/拒绝、短倒计时锁屏提醒、Live Activity 回跳与取消、完成/保底完成后当天提醒取消、删除/暂停目标、重启后的数据持久化、中英文、iPad 布局。保留低系统支持时，还应验证低于 iOS 26 的兼容路径。详细行为按 `docs/regression-checklist.md`。

Xcode 操作顺序：

1. 选择 Scheme：**LazyButNot**；运行目标选 **Any iOS Device (arm64)** 或对应通用 iOS 设备，不能选模拟器，也不要把 Widget Scheme 当成上传主体。
2. **Product → Archive**。该工程 Archive 使用 Release。
3. 在 **Window → Organizer → Archives** 选新包，必须先执行 **Validate App** 并处理所有错误。当前主 App 最低 iOS 17、内嵌扩展最低 iOS 26，要特别确认验证器是否接受这组 `MinimumOSVersion`；如出现 `ITMS-90362`，不要继续上传，先统一部署目标或重构扩展的系统版本兼容方案。
4. **Distribute App → App Store Connect → Upload**，选择正确团队，自动管理签名，确认包含主 App 和扩展后上传。新版 Xcode 向导可能合并部分页面，选择 App Store Connect 的正常分发路径即可。
5. 要复用到正式发布时，不要选 **TestFlight Internal Only** 类型的包；这种包只供内部测试。
6. 等待 Connect 处理 build；同时查看 Apple 的处理结果邮件。出现 Missing Compliance 时补出口合规答案。单纯上传成功不代表已通过审核。

完成标准：Connect 的对应 App 内能看到已处理完成的 `1.0 (1)`，无阻断性处理错误。

## 8. 用 TestFlight 测试商店分发包

Connect → App → **TestFlight → Internal Testing → 新建测试组 → 添加自己的有效 Connect 用户 → 选择 build**，在手机安装 TestFlight 并接受测试。

内部测试通常不需要单独的 Beta App Review；外部测试通常需要额外的测试审核。最快首版可以先由自己内部测试；TestFlight 本身不是正式上架的强制前置步骤，但有助于发现分发包才出现的问题。TestFlight 不需要为每位测试者登记 UDID。

在分发包重测通知、闹钟、Live Activity、冷启动和数据保存。修复后 Build 从 1 改为 2，重新 Archive / Upload，选新的 build 测试。

## 9. 填完 App Store Connect 的发布页面

### App Information / App 信息

| 字段 | 本项目建议 |
| --- | --- |
| 名称 | 懒人不懒 |
| 副标题 | 从最小行动开始，持续坚持；最多 30 字符 |
| 主要类别 | Productivity / 效率 |
| 次要类别 | 可留空，或在符合实际定位时选 Lifestyle / 生活 |
| Content Rights / 内容版权 | 按当前不提供第三方内容的情况回答；所用素材仍需有使用权 |
| Age Rating / 年龄分级 | 完成当前问卷，由系统生成结果；当前无公开 UGC、聊天、广告、赌博等，不把本地私人目标记录当成公共社交功能 |
| Made for Kids | 当前不作为儿童类别 App 申报；低年龄分级不等于儿童类别 |
| License Agreement | 无自定义条款需求时使用 Apple 标准 EULA |
| 中国大陆 / DSA 等信息 | 按第 1 步准备的真实情况填写 |

若显示医疗器械状态等问题，当前为普通目标打卡工具且没有医疗功能时据实选否，不宣称治疗、诊断效果。无障碍支持标签仅填写已经测试满足的能力。

### Pricing and Availability / 价格与销售范围

- 首版价格选免费，发行方式选公开 App Store。
- 选择已完成相关要求的国家/地区。
- 复查 iPhone / iPad App 在 Apple silicon Mac、Apple Vision Pro 上的可用性；这类兼容分发可能默认开启。未测试且闹钟是主要功能时，可先关闭这些额外平台可用性。

### App Privacy / App 隐私

- 填写公开的 Privacy Policy URL。
- 完成第 5 步所述数据收集问卷并发布隐私答案。
- 隐私选择项是对最终 App 与实际数据处理行为的陈述，不是为了审核而随意选择。

### iOS App 1.0 版本页

| 字段 | 必要程度 / 建议内容 |
| --- | --- |
| Screenshots | 按 iPhone / iPad 支持情况上传 |
| Description | 必填，最多 4000 字符，介绍实际功能；可使用下方草稿 |
| Keywords | 填写相关关键词，最多 100 字符，以英文逗号分隔 |
| Support URL | 必填，公开支持网页 URL，不能只填 `mailto:` |
| Marketing URL | 可选 |
| Promotional Text | 可选，最多 170 字符 |
| Copyright | 填 `2026` 加真实权利人名称，例如 `2026 你的姓名或组织名`，不要照抄未确认的品牌权属 |
| Version | `1.0`，与包一致 |
| Build | 选择刚测试过的、处理完成的正确 build |
| What's New | 首版通常无需填写；后续更新填写真实变化 |
| App Review Information | 填姓名、电话、邮箱，按下述方式提供审核说明 |
| Version Release | 希望过审即上架选自动发布；希望自己控制时间选手动发布 |

可以使用的中文描述草稿：

> 懒人不懒是一款帮助你持续坚持的目标打卡工具。把大目标拆成今天能完成的最小行动，状态好时完成目标，状态一般时也可以保底完成。
>
> 支持每日、每周固定日和每周次数目标；通过完成与保底完成记录行动，查看历史记录和坚持统计，并设置本地提醒与截止监督。
>
> 在 iOS 26 及以上的兼容设备上，允许闹钟权限后，可以使用闹钟式监督提醒与专注倒计时，通过实时活动查看倒计时状态。
>
> 无需注册账户。目标与打卡记录保存在本机，当前不提供账号同步或多设备同步。你还可以选择喜欢的外观主题，让每一次行动都有自己的节奏。

关键词草稿：`习惯,打卡,目标,专注,倒计时,提醒,坚持,自律,效率`。英文商店本地化可使用 `Lazy But Not`，并准备对应英文描述、关键词和截图。App 内中英文资源与 Connect 的商店本地化需要分别管理。

### 审核信息与可粘贴备注

填你能及时接收邮件和电话的联系资料。当前 App 没有账号体系，**Sign-in required / 需要登录 关闭**，无需提供测试账号；当前没有内购，无需创建内购商品记录。

审核备注示例（按最终包实际入口校对）：

```text
Lazy But Not is a local-only goal and habit tracking app. No account or sign-in is required. There are no advertisements or in-app purchases in this version.

To test the core flow, create a goal in the Goals tab, then mark it as completed or minimum completed on the Today screen. Goal data and check-in history are stored on the device.

Local notification permission is used for goal reminders. On iOS 26 or later, AlarmKit authorization is used for alarm-style deadline reminders and focus countdown timers. The embedded widget extension provides the countdown Live Activity. On earlier supported iOS versions, ordinary local notifications are available instead of AlarmKit features.

To test a countdown on a compatible device, open the focus countdown entry on the Today screen, choose a short duration, allow alarm access, and start it. Lock the device to inspect the Live Activity and the alarm. The countdown can be cancelled from the focus screen.

If permission was denied, the Settings tab provides permission status and a link to system settings. Core goal creation and check-ins do not require notification permission.
```

## 10. 提交审核并发布

1. 检查 Connect 没有缺少 build、截图、支持 URL、隐私政策、隐私答案、年龄分级、地区合规或联系信息的提示。
2. 版本页点 **Add for Review / 添加以供审核**，再在提交页点 **Submit to App Review / 提交审核**。只添加到审核提交草稿并不等于已经正式提交。
3. 关注 Connect 状态和邮件；若被拒，在 App Review 消息中针对具体问题解释或修复。代码变化需要新的 Build 并重新上传；纯元数据问题可按提示改信息后重新提交。
4. 自动发布：通过审核后按所选条件发行。手动发布：状态到 Pending Developer Release 后，点击 **Release This Version**。
5. 商店页面可用后，用商店版本做一次安装与核心流程检查；商店传播和审核用时不保证固定。

## 提交前勾选清单

- [ ] 付费会员有效，最新协议已接受。
- [ ] 两条 Explicit Identifier 都属于正确团队。
- [ ] 主 App / 扩展的 Team、签名、版本和 Build 匹配。
- [ ] 正式签名的 Validate App 已通过，且主 App 17.0 / 扩展 26.0 没有触发内嵌扩展最低系统错误。
- [x] `PrivacyInfo.xcprivacy` 已实际打进需要它的 bundle。
- [x] 无 Alpha 的图标已设置。
- [x] 隐私政策 / 支持页面公开可用，App 内也有隐私政策入口。
- [ ] 真机、低系统兼容路径、iPad、中英文与提醒回归已完成。
- [ ] 正常 App Store Connect 分发包已上传并处理完成。
- [ ] 已用 TestFlight 或等效分发验证完成核心体验。
- [ ] 商店文案、截图、隐私、年龄分级、出口合规、地区与审核备注均已填写。
- [ ] 已明确自动或手动发布方式，并完成最终 Submit。

## Apple 官方依据

- [当前 SDK 等上传要求](https://developer.apple.com/news/upcoming-requirements/)
- [创建 App Store Connect App](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/)
- [App ID、SKU、地区合规等 App 信息](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)
- [App Store Connect 分发描述文件与自动签名](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/)
- [手动创建 CSR](https://developer.apple.com/help/account/certificates/create-a-certificate-signing-request/)
- [AlarmKit 授权与 Widget 扩展要求](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)
- [Required reason API 隐私清单要求](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)
- [Required reason API 用途代码](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons)
- [商店隐私信息与收集定义](https://developer.apple.com/app-store/app-privacy-details/)
- [审核指南，隐私政策参见 5.1.1](https://developer.apple.com/app-store/review/guidelines/)
- [截图尺寸](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [出口合规](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)
- [欧盟 DSA 声明](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/)
- [中国开发者《国务院令第 810 号》合规信息](https://developer.apple.com/cn/help/app-store-connect/manage-compliance-information/manage-information-for-state-council-decree-no-810/)
