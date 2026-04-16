# 本地化工作流

## 1. 目标

本文件用于固化当前工程的多语言改造规则，避免后续出现：
- 新 UI 改了但没进字符串目录
- App 内中英文混杂
- Widget / 通知 / Live Activity 漏翻
- 多次迭代后 `xcstrings` 与代码漂移

当前语言：
- `zh-Hans`
- `en`

## 2. 当前实现

工程当前采用：
- `Localizable.xcstrings` 统一管理文案
- `String(localized:..., defaultValue:...)` 与 `LocalizedStringResource(key:defaultValue:)` 管理可见字符串
- 原则上所有用户可见文案都必须显式使用 key；不要再依赖 SwiftUI 字面量自动收集

关键文件：
- [Localizable.xcstrings](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/LazyButNot/Localizable.xcstrings)
- [L10n.swift](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/LazyButNot/Shared/L10n.swift)
- [i18n_sync_catalog.py](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/scripts/i18n_sync_catalog.py)
- [i18n_scan.py](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/scripts/i18n_scan.py)
- [i18n_check.py](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/scripts/i18n_check.py)

## 3. 什么时候必须跑本地化流程

只要改动涉及以下任一内容，就必须同步执行本地化流程：
- 新页面、新弹层、新卡片、新按钮
- 文案调整
- 通知标题或正文
- AlarmKit / Live Activity / Widget 文案
- 主题名、主题标语、营销文案
- 模型层展示文案

## 4. 标准步骤

1. 先完成功能改动
2. 将运行期字符串改成显式本地化
2.1 将页面上的按钮、标题、说明、空态、标签、统计项、Widget 文案、AlarmKit 按钮文案全部改成显式 key
2.2 启动页文案使用 `LaunchScreen.strings`，不要在 `LaunchScreen.storyboard` 中长期保留单语硬编码
3. 执行：

```bash
python3 scripts/i18n_sync_catalog.py
python3 scripts/i18n_scan.py
python3 scripts/i18n_check.py
```

4. 若有缺失翻译：
- 先补显式 key
- 必要时补 `EN_OVERRIDES`
- 重新执行三条命令

5. 若改动影响 App / Widget 资源或共享源码：
- 检查 `Localizable.xcstrings` 是否仍在两个 target 中
- 检查共享本地化源码是否同时加入两个 target

6. 若改动涉及 UI、通知、Widget：
- 额外跑一次 `xcodebuild`

## 5. 模型层约束

当前工程允许直接使用稳定英文 code 作为持久化值，例如：
- `GoalCategory.study`
- `GoalPeriodType.daily`
- `CheckInStatus.completed`

但 UI 不允许直接展示这些持久化值。

必须使用：
- `localizedTitle`
- `localizedBadgeTitle`
- `L10n` 中的格式化方法

## 6. 推荐短指令

如果你后续要让 AI 在涉及 UI 改动后自动补本地化，可直接说：

```text
使用 ios-localization-sync skill，把这次改动涉及的文案同步到多语言并自检。
```

如果是一般功能需求，也可以说：

```text
走审慎流程，功能改完后顺带跑 i18n 流程并修正新增文案。
```
