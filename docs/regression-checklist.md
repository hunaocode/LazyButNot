# 回归检查清单

## 1. 使用方式

任何涉及以下模块的改动，都必须过这份清单：
- `NotificationManager`
- `GoalStore`
- `RootTabView`
- 目标新建/编辑/打卡入口
- AlarmKit 相关逻辑

要求：
- 不允许只验证“当前 bug 修好了”
- 必须同时验证相关既有行为没有被破坏

## 2. 目标调度基础场景

### 2.1 新建目标

- 新建 `daily` 目标后，应生成包含今天在内的 7 天普通提醒
- 新建 `daily` 且开启监督提醒后，应生成对应窗口内的监督提醒
- 新建 `weeklyFixedDays` 目标后，应只生成未来 21 天内命中的选中 weekday
- 新建 `weeklyCount` 目标后，应根据当前周是否达标生成对应未来日期

### 2.2 编辑目标

- 修改 reminder 时间后，旧提醒应被取消，新提醒应按新时间重建
- 修改 deadline 时间后，监督提醒和 AlarmKit 时间应同步更新
- 修改 `selectedWeekdays` 后，旧 weekday 的提醒应清掉，新 weekday 的提醒应生成
- 修改 `supervisionOffsets` 后，旧 offset 的监督提醒应清掉，新 offset 的监督提醒应生成

## 3. 打卡相关场景

### 3.1 当天完成后的取消逻辑

- 当天第一个监督提醒已触发后，用户完成打卡，当天剩余监督提醒必须取消
- 当天完成打卡后，未来窗口应从明天开始重建，不应再包含今天
- 当天重复打卡更新状态时，不应产生重复 reminder / supervision / AlarmKit

### 3.2 每周次数达标

- `weeklyCount` 在当周未达标时，应继续显示为待完成并继续生成本周提醒
- `weeklyCount` 在当周达标后，应停止继续生成当周剩余提醒
- 若今天完成并刚好达标，首页仍应在“已完成”区域保留展示

## 4. 暂停、删除、重同步

- 暂停目标后，不应继续保留该目标的未来提醒
- 恢复目标后，应按当前规则重新生成提醒
- 删除目标后，普通提醒、本地监督、AlarmKit 都应被清空
- 设置页“重新同步所有提醒”后，所有目标应重新按当前规则生成窗口

## 5. 前后台与生命周期

- App 首次进入前台激活时，应只执行一次启动期全量调度
- 后续普通前后台切换，不应重复触发 `scheduleAll`
- Live Activity 被系统侧清除后，倒计时会话应被同步取消

## 6. AlarmKit 路径

- 在 iOS 26+ 且已授权、且 `ringEnabled == true` 时，监督提醒应优先走 AlarmKit
- AlarmKit 授权缺失或失败时，应回退为本地监督通知
- 目标重新调度时，旧 AlarmKit entries 必须被取消
- AlarmKit 日志中的 `dateCount`、`offset`、`alarmUpdates count` 应与当前窗口策略一致

## 7. 数量与窗口

- 当前 `rollingScheduleHorizonDays` 应保持和文档一致
- `weeklyFixedDays` 的搜索窗口应保持为 `rollingScheduleHorizonDays * 3`
- 当天提醒时间已过时，要确认窗口是否出现少铺一天的现象
- 目标数量较多时，要留意本地通知数量是否明显异常增长

## 8. 文档同步

每次涉及提醒模型变更后，必须同步检查：
- [PRODUCT_REQUIREMENTS.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/PRODUCT_REQUIREMENTS.md)
- [reminder-engine.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/reminder-engine.md)

若代码和文档不一致，优先修正文档或代码，不允许长期漂移。

## 9. 首页与主题 UI 回归

涉及首页卡片、目标列表、统计页、设置页或主题系统的改动时，至少补查以下场景：
- 首页未完成卡片：除“完成 / 保底完成”按钮外，其余内容区点击应进入目标详情
- 首页已完成卡片：不应继续显示误导性的打卡按钮，应展示清晰的已打卡状态
- 首页已完成卡片的状态区不应抢占整行布局，视觉上应与未完成卡片区分但不过度突兀
- 切换主题后，首页、目标页、统计页、设置页背景和关键强调色应同步变化
- 目标列表页不应重新冒出系统小箭头或默认上下分割线
