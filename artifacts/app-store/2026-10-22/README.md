# LazyButNot App Store 截图

制作日期：2026-10-22。

## 上传文件

`upload/` 中为排版后的最终 PNG，每组按文件名顺序上传：

1. `01-today.png`：今日清单。
2. `02-goals.png`：目标与最小行动。
3. `03-stats.png`：坚持统计。
4. `04-themes.png`：外观主题。

| 路径 | 商店本地化 | 设备 | 尺寸 |
| --- | --- | --- | --- |
| `upload/zh-Hans/iphone/` | 简体中文 | iPhone 6.9 英寸 | 1320 × 2868 |
| `upload/zh-Hans/ipad/` | 简体中文 | iPad 13 英寸 | 2064 × 2752 |
| `upload/en/iphone/` | 英文 | iPhone 6.9 英寸 | 1320 × 2868 |
| `upload/en/ipad/` | 英文 | iPad 13 英寸 | 2064 × 2752 |

`LazyButNot-AppStore-Screenshots.zip` 仅打包 `upload/` 中的 16 张最终图片。

Git 保存最终上传图片、预览拼图和说明；原始截图 `raw/` 与 ZIP 为本地生成产物，已加入忽略规则。需要 ZIP 时可在仓库根目录执行：

```sh
ditto -c -k --keepParent artifacts/app-store/2026-10-22/upload artifacts/app-store/2026-10-22/LazyButNot-AppStore-Screenshots.zip
```

## 预览与原始截图

- `previews/`：四张拼图，供整体检查；不用于商店上传。
- `raw/`：模拟器原始截图，保留真实 App 界面。另有一张早期采集的中文 iPhone 目标详情截图作为备选。
- 截图设备：iPhone 17 Pro Max、iPad Pro 13-inch (M5)，iOS 26.5。
- 演示目标：阅读、拉伸、英语学习、睡前放下手机。打卡与历史记录是专门制作的演示数据，没有使用私人目标。
- 这套素材没有展示闹钟已触发或 Live Activity，不代替相关真机回归。

## 设计与验证

- 外层为统一暖橙渐变、品牌标识、双语标题及设备边框；App 画面由真实模拟器截图等比缩放组成。
- 输出为无 Alpha 的 PNG，按中文/英文和 iPhone/iPad 分组。
- 已检查四组拼图和代表性全尺寸文件，修正英文 iPad 标题裁切。
- 已执行 Debug 截图构建、Release 模拟器构建和中英文字符串检查。
- 未上传到 App Store Connect；请在各语言对应设备槽位中选择 `upload/` 文件。

## 再次生成

仓库工具见 `docs/screenshot-workflow.md`。演示数据仅注入指定模拟器；已有 `goals.json` 会先另存备份。
