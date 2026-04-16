# 提醒日志判读清单

## 1. 文档目的

本文件用于统一判读提醒系统日志，避免“只看一两行 success 就判断正常”。

适用对象：
- `scheduleAll`
- `scheduleNotifications`
- `removeNotifications`
- `cancelAlarmKitEntries`
- `scheduleAlarmKitSupervision`
- `scheduleAlarmKitFixedDatesSupervision`
- `alarmUpdates`

目标：
- 快速判断当前日志是否正常
- 快速识别重复铺设、漏删、漏铺、数量异常
- 给后续改动提供一致的日志验收口径

## 2. 判读顺序

拿到一段日志后，按下面顺序看：

1. 基础上下文
2. 调度策略
3. 旧闹钟是否删干净
4. 新闹钟是否完整铺回
5. 今天的普通提醒是否该存在
6. offset 是否齐全
7. 最终数量是否符合理论值
8. 是否出现典型异常模式

## 3. 基础上下文

先定位这几个字段：
- `goalID`
- `period`
- `reminder`
- `deadline`
- `offsets`
- `paused`
- `supervisionEnabled`
- `ringEnabled`

示例：
- `scheduleNotifications start goalID=... period=daily reminder=19:00 deadline=23:00 supervisionEnabled=true ringEnabled=true paused=false offsets=60,45,30,15,10,5`

如果这些基础字段本身就不对，后面的数量和时间判断都没有意义。

## 4. 先看调度策略

### 4.1 固定日期预铺模式

若日志出现：
- `scheduleNotifications fixedDateWindow ... dateCount=N`
- `scheduleAlarmKitFixedDatesSupervision start ... dateCount=N`

说明当前走的是固定日期预铺模式。

当前仓库默认规则：
- `rollingScheduleHorizonDays = 7`
- `weeklyFixedDays` 的扫描窗口是 `rollingScheduleHorizonDays * 3`

### 4.2 旧动态 recurrence 模式

若日志出现：
- `scheduleAlarmKitSupervision start ... recurrence=...`

说明还在走旧的 recurrence 模式。

若当前代码已经切到 fixed-date window，却仍出现 recurrence 调度，要优先怀疑实现漂移。

## 5. 看旧闹钟有没有删干净

重点看：
- `removeNotifications ...`
- `cancelAlarmKitEntries ...`
- `alarmUpdates count=X -> ... -> 0`

判定规则：
- 如果清理后最终降到 `0`，通常说明旧 AlarmKit 闹钟已删干净
- 如果降不到 `0`，要优先怀疑：
- 删除条件不完整
- 旧 alarmID 映射不完整
- observer 里混入了别的目标的闹钟

注意：
- `removeNotifications` 只说明发起了删除
- 真正是否删干净，要看后面的 `alarmUpdates count`

## 6. 看新闹钟有没有重复铺设

重点看：
- 一轮 `scheduleNotifications start ...`
- 最终 `alarmUpdates count=...`

固定日期预铺模式下，AlarmKit 数量的理论值为：

`日期数 * offset 数量`

例如：
- `dateCount=7`
- `offsets=60,45,30,15,10,5`
- 理论 AlarmKit 数量 = `7 * 6 = 42`

判定规则：
- 最终数量 = 理论值：通常正常
- 最终数量 > 理论值：通常是重复铺设或旧闹钟没删净
- 最终数量 < 理论值：通常是漏铺、失败、被跳过或某些日期未命中

## 7. 看今天的普通提醒是否应该存在

重点看：
- `scheduled reminder notification ... date=YYYYMMDD`

判定思路：
- 如果当前时间已经晚于 `reminder`，今天的普通提醒通常会跳过
- 如果当前时间还没过 `deadline`，今天的截止监督提醒仍可能保留

所以出现下面这种情况，可能完全正常：
- 今天没有普通提醒
- 但今天有截止监督提醒

不要把这种情况误判成漏铺。

## 8. 看 offset 是否完整

重点看每个日期是否都出现了完整 offset 集合。

例如当前 offset 为：
- `60`
- `45`
- `30`
- `15`
- `10`
- `5`

那么同一个日期应看到完整的 6 条 success。

判定规则：
- 缺少某个 offset：说明该档监督提醒漏铺
- 同一天某个 offset 重复出现多次：说明重复创建

## 9. 看最终结果标记

重点看：
- `scheduleNotifications alarmKit result ... success=true`
- `scheduleNotifications alarmKit fixedDateResult ... success=true`
- `scheduleAll finished goalCount=N`

注意：
- `success=true` 只表示流程没有显式报错
- 不代表数量一定正确

最终仍要回到：
- `alarmUpdates count`
- `dateCount`
- `offset`
- 理论数量

一起判断。

## 10. 常见异常模式

### 10.1 重复铺设

特征：
- `alarmUpdates count` 持续上涨
- 最终数量明显大于理论值

最常见原因：
- 新铺设前没有完整删掉旧闹钟
- 同一目标被重复触发 `scheduleNotifications`

### 10.2 清理不完整

特征：
- `cancelAlarmKitEntries` 后，`alarmUpdates count` 降不到 `0`

最常见原因：
- alarmID 跟目标映射不完整
- 删除范围只删了部分 offset / 日期

### 10.3 漏铺

特征：
- `dateCount` 看起来正常
- 但最终数量小于理论值
- 或某些日期缺 offset

最常见原因：
- 某些日期被过滤
- 某个 offset 创建失败
- 今天已过提醒时间，被合理跳过

### 10.4 完成后重排异常

特征：
- 当天完成打卡后，今天剩余提醒没有被清掉
- 或今天已经完成，却又把今天重新铺回来了

最常见原因：
- “completedToday 后不包含今天”的规则失效

## 11. 当前工程的正常示例

如果日志类似下面这样，通常说明正常：

- 旧闹钟从 `count=42` 一路降到 `0`
- 出现 `fixedDateWindow ... dateCount=7`
- 每个日期的 `offset=60,45,30,15,10,5` 都成功
- 最终又回到 `alarmUpdates count=42`

这说明：
- 先删旧
- 再按 7 天 * 6 offsets 重铺
- 没重复
- 没漏删
- 没漏铺

## 12. 推荐输出格式

以后判读提醒日志时，建议按下面格式输出：

1. 调度模式
- fixed-date window / recurrence

2. 删除是否正常
- 旧闹钟是否降到 0

3. 铺设数量是否符合预期
- 理论值
- 实际值

4. 今天的提醒是否合理
- 普通提醒是否该跳过
- 截止监督是否该保留

5. 是否发现异常
- 无异常 / 有异常

6. 若异常，最可能根因
- 重复铺设 / 清理不完整 / 漏铺 / 规则漂移
