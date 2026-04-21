# 懒人不懒 LazyButNot

一个强调“先保持连续，再追求强度”的 iOS 目标打卡应用。

An iOS habit-tracking app focused on consistency first, intensity second.

## 中文简介

`懒人不懒` 是一个原生 `SwiftUI` iOS 项目，核心目标不是逼用户高强度自律，而是通过“最小行动 + 周期提醒 + 保底完成”机制，帮助用户把长期目标稳定地坚持下去。

当前版本支持：

- 创建多个独立目标
- 支持每日、每周固定日、每周次数三种周期
- 支持“完成”和“保底完成”两种打卡状态
- 支持本地通知提醒与临近截止监督提醒
- 支持目标暂停、历史记录、连续完成和连续坚持统计
- 数据本地持久化存储，不依赖后端服务

## English Overview

`LazyButNot` is a native `SwiftUI` iOS app for personal goal tracking.

Instead of forcing extreme discipline, it helps users stay consistent through:

- minimum actionable goals
- recurring reminders
- “completed” and “minimum completed” check-ins
- local-only persistence
- simple progress and streak stats

## Tech Stack

- `SwiftUI`
- Native iOS project via `Xcode`
- Local notifications with `UserNotifications`
- Local persistence with JSON storage

Note:
The current implementation stores data locally in JSON files for simplicity and reliability. It can be migrated later to `SwiftData`, `SQLite`, or `Core Data` if needed.

## Project Structure

```text
懒人不懒/
├── LazyButNot/                 # iOS app source code
│   ├── App/
│   ├── Models/
│   ├── Services/
│   ├── Stores/
│   ├── ViewModels/
│   ├── Views/
│   └── LazyButNot.xcodeproj/
├── docs/
│   ├── PRODUCT_REQUIREMENTS.md
│   ├── change-rules.md
│   ├── regression-checklist.md
│   ├── localization-workflow.md
│   └── reminder-engine.md
└── create_native_project.rb    # Xcode project generator
```

## 文档入口 / Documentation Entry Points

中文：
修改这个项目时，不要只看代码。`docs/` 目录下的文档是当前产品行为、修改边界和回归检查的基线。

English:
When modifying this project, do not rely on code alone. Use the docs in `docs/` as the source of truth for product behavior, change constraints, and regression checks.

- `docs/PRODUCT_REQUIREMENTS.md`
  中文：当前产品基线与已实现能力。
  English: Current product baseline and implemented behavior.
- `docs/change-rules.md`
  中文：提醒、AlarmKit、首页卡片、主题覆盖范围和 UI 修改约束。
  English: Change constraints for reminders, AlarmKit, home cards, theme coverage, and UI edits.
- `docs/regression-checklist.md`
  中文：提醒、卡片、主题和布局修改后的必查回归项。
  English: Required regression checks after reminder, card, theme, or layout changes.
- `docs/reminder-engine.md`
  中文：提醒调度模型和当前调度规则。
  English: Reminder scheduling model and current engine rules.
- `docs/localization-workflow.md`
  中文：`Localizable.xcstrings` 和本地化脚本流程。
  English: Localization workflow for `Localizable.xcstrings` and related scripts.

推荐协作顺序 / Recommended collaboration flow:

1. 先读相关文档 / Read the relevant docs first.
2. 保持改动范围收敛 / Keep the change scope narrow.
3. 按回归清单验证 / Verify behavior with the regression checklist.
4. 若真实规则变更，同步更新文档 / Update docs if a real rule changes.

## Build And Run

1. Open `LazyButNot/LazyButNot.xcodeproj` in Xcode.
2. Select an iPhone simulator or a real device.
3. Build and run the app.

If you run on a real device, allow notifications to test reminder behavior.

## UI 修改说明 / UI Change Notes

中文：
对于首页、目标页、统计页、设置页这类卡片页面：

- 如果需求只是“主题适配”或“颜色微调”，默认不要顺手修改 `spacing`、`padding`、`listRowInsets`、`listStyle` 或卡片分组层级。
- 卡片内边距、卡片到页面边缘的外边距、模块与模块之间的间距，必须视为三层不同布局。
- 修改 `SwiftUI List` 页面前，先确定卡片视觉是挂在内容 `.background(...)` 还是 `listRowBackground(...)`，不要混着改。
- 涉及 UI 或主题修改时，请同时参考 `docs/change-rules.md` 和 `docs/regression-checklist.md`。

English:
For card-based pages such as Home, Goals, Stats, and Settings:

- If the request is only about theme adaptation or color polish, do not change spacing, padding, `listRowInsets`, `listStyle`, or card grouping unless explicitly requested.
- Treat card inner padding, page-side outer margin, and module-to-module spacing as three separate layout layers.
- Before changing SwiftUI `List` pages, first decide whether the card visual belongs to content `.background(...)` or `listRowBackground(...)`; do not mix both approaches casually.
- Use `docs/change-rules.md` and `docs/regression-checklist.md` together for any UI or theme work.

## Product Principles

- 中文：不要追求“每天都很猛”，而是追求“不要完全断掉”。
- English: Don’t aim to be intense every day. Aim to not fully break the chain.

## Roadmap

- Check-in backfill
- Widgets
- Apple Watch quick actions
- iCloud sync
- Richer statistics and review views

## License

Currently for personal use.
