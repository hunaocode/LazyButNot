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
│   └── PRODUCT_REQUIREMENTS.md
└── create_native_project.rb    # Xcode project generator
```

## Build And Run

1. Open `LazyButNot/LazyButNot.xcodeproj` in Xcode.
2. Select an iPhone simulator or a real device.
3. Build and run the app.

If you run on a real device, allow notifications to test reminder behavior.

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
