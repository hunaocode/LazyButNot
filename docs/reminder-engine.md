# 提醒引擎规则

## 1. 文档目的

本文件用于固化当前提醒系统的真实实现，作为后续改动 `NotificationManager`、目标调度逻辑、AlarmKit 路径时的单一事实源。

所有涉及以下内容的改动，都应先阅读本文件：
- 目标提醒调度
- 监督提醒调度
- AlarmKit 监督闹钟
- 打卡完成后的重排逻辑
- 前后台触发提醒同步的时机

## 2. 当前调度模型

当前工程不再采用“长期重复提醒 + 当天跳过”的模型，而是统一采用“固定日期预设窗口”模型。

统一规则：
- 普通提醒和监督提醒都按固定日期预设
- AlarmKit 监督闹钟也按固定日期预设
- 当前预设窗口以天为单位计算
- 当前 `rollingScheduleHorizonDays = 7`

实现位置：
- [NotificationManager.swift](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/LazyButNot/Services/NotificationManager.swift)

## 3. 各周期的日期生成规则

### 3.1 每日

规则：
- 若目标今天未完成，则窗口包含今天起未来 7 天
- 若目标今天已完成，则窗口从明天开始，覆盖未来 7 天

影响：
- 当天完成后，今天剩余提醒不会再被补回

### 3.2 每周固定日

规则：
- 不直接按“7 个自然日”生成
- 系统会向后扫描 `rollingScheduleHorizonDays * 3`
- 当前即向后扫描 21 天
- 把扫描范围内命中的 `selectedWeekdays` 日期全部收集出来并预设

示例：
- 若选择“周一、周三、周五”，当前会预设未来 21 天内命中的所有周一、周三、周五

### 3.3 每周次数

规则：
- 使用 `weeklyCountReminderDates(for:)` 生成未来候选日期
- 若当前周已达标，则从下周开始生成日期
- 若当前周未达标，则从今天开始生成日期
- 若目标今天已完成，则在重排时过滤掉今天

## 4. 完成后的提醒处理

当前规则：
- 用户当天打卡后，会先清掉该目标现有 reminder、本地监督通知和 AlarmKit 闹钟
- 然后根据“今天是否已完成”重新生成窗口
- 若今天已完成，则新窗口不包含今天

结果：
- 当天剩余监督提醒会被取消
- 明天及之后的窗口重新生成

这个规则适用于：
- `daily`
- `weeklyFixedDays`
- `weeklyCount`

## 5. 普通通知与 AlarmKit 分工

### 5.1 普通通知

规则：
- 普通提醒始终使用本地通知
- 若监督提醒开启但 AlarmKit 不可用或未授权，则监督提醒也回退为本地通知

### 5.2 AlarmKit

规则：
- 仅用于监督提醒
- 仅在 `ringEnabled == true` 且 iOS 26+ 且已授权时启用
- 当前走 fixed-date schedule，不再依赖 repeating schedule

边界：
- 目标监督提醒尚未接入复杂 `AppIntent`
- 当前只使用统一 stop button 风格的 alert

## 6. 前后台与重排触发时机

当前规则：
- App 首次进入前台激活时，会执行一次启动期全量调度
- 后续普通前后台切换，不再自动全量重排目标提醒
- 设置页可手动触发“重新同步所有提醒”
- 目标新建、编辑、暂停/恢复、删除、打卡完成，也会触发对应目标的重新调度

注意：
- 不要再把“每次回到前台都 scheduleAll”加回来
- 这会直接导致重复重排、数量抖动和日志噪音

## 7. 当前已知限制

### 7.1 没有自动补窗机制

当前实现没有后台自动续上未来窗口的能力。

含义：
- 超出已预设窗口后，提醒不会自动续期
- 需要依赖以下任一动作重新生成未来提醒：
- App 启动首轮调度
- 设置页“重新同步所有提醒”
- 目标相关操作触发的 `scheduleNotifications(for:)`

### 7.2 本地通知数量风险

当前提醒模型是 fixed-date 预设。

因此：
- 目标越多
- 每个目标的监督提前量越多
- 预设窗口越长

本地通知总数就越容易上升。

工程上需要保守看待 `UNUserNotificationCenter` 的 pending 数量风险，不要随意扩大窗口。

## 8. 修改本模块时必须同步检查

任何修改以下内容时，都必须同步检查三类周期：
- `daily`
- `weeklyFixedDays`
- `weeklyCount`

以及四类路径：
- 新建目标
- 编辑目标
- 当天完成打卡
- 设置页重新同步

此外还必须检查：
- `removeNotifications(for:)` 是否仍能覆盖旧 identifier
- AlarmKit 的 cancel 范围是否和 fixed-date window 一致
- 文档 `PRODUCT_REQUIREMENTS.md` 是否仍与真实实现一致
