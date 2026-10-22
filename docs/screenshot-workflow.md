# App Store 截图工作流

## 当前素材

首版成品：`artifacts/app-store/2026-10-22/`。

每个语言和设备组合提供 4 张：今日、目标、统计、主题。输出规格为 iPhone 1320 × 2868、iPad 2064 × 2752，无 Alpha PNG。中英文分别采集真实本地化 UI，外层再添加品牌与短标题。

## 截图入口

`AppRouter` 与 `RootTabView` 在 `DEBUG && targetEnvironment(simulator)` 下识别环境变量 `LAZYBUTNOT_SCREENSHOT_TAB`：

- `home`：今日。
- `goals`：目标列表。
- `stats`：统计。
- `settings`：设置。
- `themes`：直接展示真实 `ThemeSettingsView`。

没有该环境变量时沿用默认导航。Release 和真机编译均不包含这些入口；提醒权限、调度窗口、前后台调度、打卡逻辑与布局参数保持现有实现。

## 操作步骤

1. 构建 Debug 模拟器 App，并安装到指定截图设备。
2. 使用新建或确认可用于演示的模拟器，首次启动后处理系统权限弹窗。
3. 调用采集工具，分别指定设备 UDID、设备类型和语言：

   ```sh
   bash tools/capture_store_screenshots.sh <UDID> iphone zh-Hans artifacts/app-store/2026-10-22
   bash tools/capture_store_screenshots.sh <UDID> iphone en artifacts/app-store/2026-10-22
   bash tools/capture_store_screenshots.sh <IPAD_UDID> ipad zh-Hans artifacts/app-store/2026-10-22
   bash tools/capture_store_screenshots.sh <IPAD_UDID> ipad en artifacts/app-store/2026-10-22
   ```

   采集工具会停止指定模拟器中的 App，通过 `seed_store_screenshots.swift` 生成本地化演示目标与历史打卡，并重新启动各页面。已有目标文件会先保存 UUID 后缀备份；工具拒绝非 CoreSimulator 路径。

4. iPad 状态栏包含系统日期文字，采集英文版前需将该演示模拟器的系统语言和地区设为英文/美国，并重启设备使状态栏生效。App 启动参数只切换 App 文案，不会同时改变 SpringBoard 的日期语言。
5. 合成版式：

   ```sh
   swift tools/compose_store_screenshots.swift artifacts/app-store/2026-10-22
   ```

6. 检查 `previews/` 全部拼图和全尺寸成品，确认无权限弹窗、错语言、标题裁切、图片变形及私人数据。用 `sips` 检查最终尺寸和 `hasAlpha: no`。
7. 按 `01` 到 `04` 顺序上传各自 `upload/<language>/<device>/` 中的文件。原始图片和预览拼图不混入上传组。

## 验证边界

截图采集验证了这些页面在两类模拟器的实际渲染，未覆盖所有页面、横屏、低系统版本或真机提醒触发。截图完成不能替代完整功能回归。

Apple 尺寸要求：[Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)。
