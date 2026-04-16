# AGENTS

## 1. 目的

本文件用于给进入本仓库的 AI coding agent 提供默认工作约束。

目标：
- 降低多轮迭代中的上下文漂移
- 降低“修一个点，破坏另一片”的概率
- 强制提醒系统相关任务先读取稳定规则，而不是直接猜

## 2. 默认工作方式

当任务涉及代码改动时：
- 先理解当前实现
- 先说明根因和影响范围
- 再修改代码
- 改完后做必要验证
- 若规则发生变化，必须同步更新文档

如果任务只是问答、评审或方案讨论，也应先以仓库文档为准，而不是仅依赖聊天上下文。

## 3. 提醒系统相关任务的必读文档

凡是涉及以下内容，必须先阅读这三份文档：
- 目标提醒
- 监督提醒
- AlarmKit
- 打卡完成后的提醒变化
- 前后台调度策略
- 通知数量与窗口策略

必读文档：
- [docs/reminder-engine.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/reminder-engine.md)
- [docs/regression-checklist.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/regression-checklist.md)
- [docs/change-rules.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/change-rules.md)

若任务涉及产品口径或验收范围，还必须阅读：
- [docs/PRODUCT_REQUIREMENTS.md](/Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/docs/PRODUCT_REQUIREMENTS.md)

## 4. 提醒系统的默认硬约束

除非任务明确要求修改，否则以下规则默认不可变：
- 当前提醒模型是 fixed-date window
- 当前 `rollingScheduleHorizonDays = 7`
- `weeklyFixedDays` 搜索窗口是 `rollingScheduleHorizonDays * 3`
- 当天已完成时，重建窗口默认不包含今天
- 普通前后台切换不自动触发 `scheduleAll`
- AlarmKit 仅用于监督提醒

如果确实修改以上任一规则，必须同步更新：
- `docs/reminder-engine.md`
- `docs/regression-checklist.md`
- `docs/PRODUCT_REQUIREMENTS.md`

## 5. 修改前必须先输出的内容

在开始修改提醒系统相关代码前，先输出：
- 根因
- 影响范围
- 必须保持不变的现有规则
- 回归验证清单

如果这些内容说不清，不应直接改代码。

## 5.1 短口令

为减少重复输入，本仓库约定以下短口令：

### `走提醒流程`

含义：
- 先阅读 `AGENTS.md`
- 再阅读：
- `docs/reminder-engine.md`
- `docs/regression-checklist.md`
- `docs/change-rules.md`
- 先不要改代码
- 先输出：
- 根因
- 影响范围
- 必须保持不变的现有规则
- 回归验证清单
- 待用户确认后再修改

适用场景：
- 目标提醒
- 监督提醒
- AlarmKit
- 打卡完成后的提醒变化
- 前后台调度策略

### `走审慎流程`

含义：
- 先阅读 `AGENTS.md`
- 先分析当前实现和影响范围
- 明确不能破坏的既有行为
- 再进行最小必要修改
- 改完后做必要验证
- 若规则变化，更新相关文档

适用场景：
- 一般代码改动
- 可能影响多个模块的修复
- 需要避免回归的功能修改

## 6. Code Review 要求

若用户要求 review：
- 默认采用 code review 模式
- 先列 findings
- 按严重度排序
- 只关注 bug、回归、逻辑不一致、缺少验证
- 给出文件和行号
- 总结放在后面

## 7. 文档优先级

当聊天内容、临时猜测与仓库文档冲突时，默认以仓库中的最新文档和代码实现为准。

如果发现文档和代码不一致：
- 先明确指出不一致
- 再决定是修代码还是修文档
- 不允许忽略漂移继续往前改
