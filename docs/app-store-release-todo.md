# 懒人不懒 App Store 上线待办清单（个人开发者版）

更新日期：2026-10-22

使用方式：完成一项后将 `[ ]` 改成 `[x]`。需要协助时，直接告诉 AI 对应编号，例如：`帮我处理 ASC-12`。

适用身份：以个人身份加入 Apple Developer Program，并以个人名义发布 App。

本清单已经去除组织开发者专属的 D-U-N-S、统一社会信用代码、企业营业执照、组织法律实体核验和企业销售者信息。首版保持免费下载、无内购时，也不把 Paid Apps Agreement、收款银行账户和付费 App 税务结算列为上线前置任务。

个人开发者仍需注意：商店销售者通常显示账号持有人的法定姓名；中国大陆发行资格与 APP/ICP 备案需要按实际情况判断；中国开发者的《国务院令第 810 号》信息和欧盟 DSA 身份声明并不会因为是个人开发者而自动免除。

状态说明：

- `[x]`：已经通过本地检查，或由账号持有人明确确认；后台事项在对应条目注明确认来源。
- `[ ]`：仍需完成或需要人工确认。
- 标记“阻塞”的项目应在首次正式上传前完成。

## 一、账号与发行范围

- [x] `ASC-01` 账号持有人确认 Apple Developer Program 会员有效；公开清单不记录会员到期或续订日期（2026-10-22 确认）。
- [x] `ASC-02` 账号持有人确认角色和发布团队，Team ID 与当前工程一致；公开清单不记录个人姓名（2026-10-22 确认）。
- [ ] `ASC-03` 登录 App Store Connect，在 Business 中检查并处理适用的待处理协议。账号持有人已确认接受 Developer 新协议；Connect 商务页尚待检查，可与创建 App 记录步骤一起核对。
- [x] `ASC-04` 已确定使用个人开发者账号；确认商店销售者名称通常显示账号持有人的法定姓名。
- [ ] `ASC-05` 确定首发地区是否包含中国大陆。
- [ ] `ASC-06` 如果包含中国大陆，确认本 App 是否需要 APP/ICP 备案并准备相应资料。
- [ ] `ASC-07` 在 App Store Connect 检查并完成个人开发者的《国务院令第 810 号》信息；按页面要求准备居民身份证姓名和号码。
- [ ] `ASC-08` 确定是否在欧盟发行，并以个人身份完成 DSA 交易者/非交易者声明；若声明为交易者，需要准备可公开展示的地址或邮政信箱、电话和邮箱。
- [ ] `ASC-09` 确定首版采用免费公开发行。

## 二、Bundle ID、证书与签名

- [x] `ASC-10` 主 App Bundle ID 已配置为 `com.hunaocode.LazyButNot`。
- [x] `ASC-11` Widget 扩展 Bundle ID 已配置为 `com.hunaocode.LazyButNot.widgetextension`。
- [x] `ASC-12` 账号持有人确认主 App 的 Explicit App ID 已新建成功：`com.hunaocode.LazyButNot`（2026-10-22 确认）。
- [x] `ASC-13` 账号持有人确认 Widget 扩展的 Explicit App ID 已新建成功：`com.hunaocode.LazyButNot.widgetextension`（2026-10-22 确认）。
- [x] `ASC-14` 主 App 和 Widget 扩展均已在工程中选择 Team `ZT4G687V3G`。
- [x] `ASC-15` 两个 Target 均使用 Automatically Manage Signing。
- [ ] `ASC-16` 使用当前 Team 将主 App 安装到真机，确认开发签名有效。
- [x] `ASC-17` 分发日志确认主 App 和扩展均选到 Apple Distribution 托管分发证书及各自的 App Store 描述文件；账号持有人确认 Validate 成功（2026-10-22）。

## 三、工程上架阻塞项

- [x] `ASC-18` 【阻塞】新增主 App 的 `PrivacyInfo.xcprivacy`。
- [x] `ASC-19` 【阻塞】在隐私清单中申报 `NSPrivacyAccessedAPICategoryUserDefaults`，Reason 使用 `CA92.1`。
- [x] `ASC-20` 【阻塞】Archive 后确认 `PrivacyInfo.xcprivacy` 已实际打进主 App bundle。
- [x] `ASC-21` 【阻塞】将全部 AppIcon 图片转换为不带 Alpha 通道的 PNG。
- [x] `ASC-22` 【阻塞】确认 1024×1024 商店图标填满方形画布、没有透明区域、没有自行裁圆角。
- [x] `ASC-23` 确认最终包没有使用非豁免加密。
- [x] `ASC-24` 在主 App `Info.plist` 中添加 `ITSAppUsesNonExemptEncryption = NO`，或准备在 Connect 中回答出口合规问卷。
- [x] `ASC-25` 保留主 App iOS 17.0、Widget 扩展 iOS 26.0 的现有配置；账号持有人确认当前归档 Validate 成功。仍需上传处理及低系统真机兼容验证（2026-10-22）。
- [x] `ASC-26` 账号持有人确认关闭代理后正式签名 Validate App 成功；当前验证未报 `ITMS-90362`（2026-10-22）。
- [x] `ASC-27` 主 App 与扩展的 Version 均为 `1.0`、Build 均为 `1`。
- [ ] `ASC-28` 每次重新上传修复后的包时递增主 App 和扩展的 Build。

## 四、隐私政策与技术支持

- [x] `ASC-29` 【阻塞】编写本项目的中文隐私政策。
- [x] `ASC-30` 准备对应的英文隐私政策。
- [x] `ASC-31` 【阻塞】将隐私政策发布到公开、无需登录的 HTTPS 页面：`https://hunaocode.github.io/LazyButNot/privacy-policy/`。
- [x] `ASC-32` 【阻塞】在 App 设置页增加隐私政策入口。
- [x] `ASC-33` 编写技术支持页面，包含 App 名称、使用说明、权限说明和联系邮箱。
- [x] `ASC-34` 【阻塞】将技术支持页面发布到公开、无需登录的 HTTPS 地址：`https://hunaocode.github.io/LazyButNot/support/`。
- [ ] `ASC-35` 确认客服邮箱 `hunao163@gmail.com` 可以正常收发邮件。

## 五、功能与真机回归

- [x] `ASC-36` Release 模拟器构建通过。
- [x] `ASC-37` 关闭签名的设备 Archive 通过。
- [x] `ASC-38` 当前中英文字符串目录检查无缺失翻译。
- [ ] `ASC-39` 在 iOS 17–25 真机或等效环境验证普通通知兼容路径。
- [ ] `ASC-40` 在 iOS 26+ 真机验证 AlarmKit 授权允许、拒绝和重新开启流程。
- [ ] `ASC-41` 验证短倒计时闹钟能够正常触发。
- [ ] `ASC-42` 验证锁屏、灵动岛和待机显示中的 Live Activity。
- [ ] `ASC-43` 验证 Live Activity 回跳 App 和取消倒计时。
- [ ] `ASC-44` 验证通知权限被拒绝后仍可创建目标和打卡。
- [ ] `ASC-45` 验证允许通知后普通提醒与监督提醒实际触发。
- [ ] `ASC-46` 验证完成/保底完成后，当天对应提醒被取消。
- [ ] `ASC-47` 验证编辑、暂停、恢复、删除目标后的提醒变化。
- [ ] `ASC-48` 验证杀掉 App、重启设备后的数据持久化。
- [ ] `ASC-49` 验证中文和英文界面、通知、AlarmKit 与 Live Activity 文案。
- [ ] `ASC-50` 在 iPhone 小屏和大屏设备检查布局。
- [ ] `ASC-51` 在 iPad 上检查所有主要页面、横竖屏和弹层布局。
- [ ] `ASC-52` 按 `docs/regression-checklist.md` 完成完整回归并记录结果。

## 六、App Store 素材

- [x] `ASC-53` 账号持有人确认创建商店记录时使用名称“懒人不懒”（2026-10-22 确认）。
- [ ] `ASC-54` 确定中文副标题，建议“从最小行动开始，持续坚持”。
- [x] `ASC-55` 准备中文 App 描述。
- [x] `ASC-56` 准备英文 App 名称、副标题和描述。
- [x] `ASC-57` 准备中文关键词，控制在 App Store Connect 限制内。
- [x] `ASC-58` 准备英文关键词。
- [x] `ASC-59` 已准备中英文各 4 张 iPhone 6.9 英寸排版截图（1320 × 2868），见 `artifacts/app-store/2026-10-22/upload/`。
- [x] `ASC-60` 已准备中英文各 4 张 iPad 13 英寸排版截图（2064 × 2752），见 `artifacts/app-store/2026-10-22/upload/`。
- [x] `ASC-61` 截图使用专门创建的演示目标及真实模拟器 UI，最终 PNG 无 Alpha；已检查标题、语言、尺寸和功能宣传（2026-10-22）。
- [x] `ASC-62` 确认商店文案明确 AlarmKit、专注倒计时和相关 Live Activity 需要 iOS 26+。
- [ ] `ASC-63` 准备版权字段中的个人法定姓名，例如 `2026 你的姓名`。

## 七、创建 App Store Connect 记录

- [x] `ASC-64` 账号持有人确认已在 App Store Connect 创建新的 iOS App 记录，用户访问权限为完全访问（2026-10-22 确认）。
- [x] `ASC-65` 账号持有人确认名称已设置为“懒人不懒”（2026-10-22 确认）。
- [x] `ASC-66` 账号持有人确认主要语言已设置为简体中文（2026-10-22 确认）。
- [x] `ASC-67` 账号持有人确认已选择主 App Bundle ID `com.hunaocode.LazyButNot`（2026-10-22 确认）。
- [x] `ASC-68` 账号持有人确认 SKU 已设置为 `lazybutnot-ios-001`（2026-10-22 确认）。
- [ ] `ASC-69` 设置主要类别为 Productivity / 效率。
- [ ] `ASC-70` 设置价格为免费并确认税务类别；当前无内购，不需要为本版本配置付费 App 的收款银行账户。
- [ ] `ASC-71` 选择计划发行的国家和地区。
- [ ] `ASC-72` 检查并决定是否允许在 Apple silicon Mac 和 Apple Vision Pro 上兼容运行。
- [ ] `ASC-73` 完成新版年龄分级问卷。
- [ ] `ASC-74` 如实填写内容版权、医疗设备及其他合规问题。

## 八、App Privacy 与版本元数据

- [ ] `ASC-75` 在 App Privacy 中填写公开的隐私政策 URL。
- [ ] `ASC-76` 基于最终安装包重新确认是否存在数据上传、统计、广告或第三方 SDK。
- [ ] `ASC-77` 若最终行为仍与当前代码一致，将 App Privacy 设置为“不收集此 App 的数据”并发布答案。
- [ ] `ASC-78` 在 iOS App 1.0 页面上传中文 iPhone 和 iPad 截图。
- [ ] `ASC-79` 添加英文商店本地化并上传对应英文素材。
- [ ] `ASC-80` 填写 Description、Keywords、Support URL 和可选 Marketing URL。
- [ ] `ASC-81` 使用个人法定姓名填写 Copyright，并填写本人可及时响应的审核联系人姓名、电话和邮箱。
- [ ] `ASC-82` 将 Sign-in Required 设置为关闭，不提供测试账号。
- [ ] `ASC-83` 在 App Store Connect 填写审核备注，说明本地存储、通知用途、AlarmKit 和倒计时测试路径；可直接使用 `docs/app-store-metadata.md` 中的草稿。

## 九、正式 Archive、上传与 TestFlight

- [ ] `ASC-84` 在 Xcode 选择 `LazyButNot` Scheme 和 Any iOS Device。
- [x] `ASC-85` 已生成用于 Validate 的设备归档，工程 Archive 使用 Release；账号持有人确认验证成功（2026-10-22）。
- [x] `ASC-86` 分发日志确认归档包含主 App 和 `LazyButNotWidgetExtension.appex`（2026-10-22）。
- [x] `ASC-87` 账号持有人确认 Validate App 成功。首次失败为代理路径访问 Apple 云端签名服务时 TLS 错误，关闭代理重试通过（2026-10-22）。
- [ ] `ASC-88` 选择 App Store Connect 正常分发方式上传，不使用 TestFlight Internal Only 包。
- [ ] `ASC-89` 等待 App Store Connect 完成 Build Processing。
- [ ] `ASC-90` 处理 Missing Compliance、二进制警告或 Apple 邮件中的问题。
- [ ] `ASC-91` 创建 TestFlight 内部测试组并添加测试用户。
- [ ] `ASC-92` 在 TestFlight 安装正式分发包，重新验证通知、AlarmKit、Live Activity、冷启动和数据保存。
- [ ] `ASC-93` 将通过验证的 Build 关联到 iOS App 1.0。

## 十、提交审核与发布

- [ ] `ASC-94` 检查版本页面不存在缺少元数据或合规信息的提示。
- [ ] `ASC-95` 首次发行建议选择手动发布。
- [ ] `ASC-96` 点击 Add for Review，将版本加入审核提交。
- [ ] `ASC-97` 在 Draft Submission 中点击 Submit for Review，确认状态进入 Waiting for Review。
- [ ] `ASC-98` 关注 App Store Connect 状态、邮件和 App Review 消息。
- [ ] `ASC-99` 若被拒，区分代码问题与元数据问题后处理；代码变化时递增 Build 并重新上传。
- [ ] `ASC-100` 审核通过后点击 Release This Version。
- [ ] `ASC-101` App Store 页面生效后，从商店全新安装并完成一次核心流程检查。
- [ ] `ASC-102` 保存首版截图、商店文案、审核备注和发布记录，作为后续版本基线。

## 相关文档

- 完整操作说明：`docs/app-store-release-guide.md`
- 产品能力基线：`docs/PRODUCT_REQUIREMENTS.md`
- 提醒系统规则：`docs/reminder-engine.md`
- 回归测试清单：`docs/regression-checklist.md`
- 本地化流程：`docs/localization-workflow.md`
- 中英文隐私政策：`docs/privacy-policy-zh.md`、`docs/privacy-policy-en.md`
- 技术支持页面：`docs/support.md`
- App Store 元数据草稿：`docs/app-store-metadata.md`
