# LazyButNot App Store Connect 工作流

使用 Apple 官方 API 更新商店中英文文案和截图。由另一 iOS 项目的上传工具迁移，未复制其账号配置、私钥和业务文案。依赖 Python 3.10+、OpenSSL。

## 一次性配置

本机已准备 `config/app_store_connect.local.json` 占位模板，被 Git 忽略。新机器使用时从 `config/app_store_connect.example.json` 复制一份。

| 字段 | 填写内容 |
|---|---|
| `auth.issuer_id` | 团队密钥页面的 Issuer ID，不是 Team ID |
| `auth.key_id` | 创建的团队 API 密钥的 Key ID |
| `auth.private_key_path` | `.p8` 文件路径，支持 `~`，建议存放在仓库外 |
| `app.app_id` | App 信息中的数字 Apple ID，不是 Bundle ID 或 SKU |

已预填 Bundle ID `com.hunaocode.LazyButNot`、平台 `IOS`、版本 `1.0`。版本必须与后台完全一致，发新版本时更新；脚本不会创建商店版本。使用本 App 所属团队、具备 App Manager 权限的团队密钥；当前认证不支持个人 API 密钥。

私钥不要发到聊天或写入文档。`.p8`、本机配置、`private/` 被 Git 忽略；带个人信息的后台导出或日志放在 `private/`。不要强行加入 Git。公开客服邮箱和商店文案可以提交。

## 文案和截图

- `localizations/zh-Hans/metadata.json`：中文。
- `localizations/en-US/metadata.json`：英文，商店语言为 `en-US`，截图目录为 `en`。
- 初始内容来自 `docs/app-store-metadata.md`。JSON 是上传来源，后续修改时同步该文档。
- `screenshotSets` 引用 `artifacts/app-store/2026-10-22/upload/` 中的 16 张成品图，没有复制图片。
- 截图相对路径基于对应语言目录；配置中的相对路径基于配置文件目录。
- iPhone API 展示组使用 `APP_IPHONE_67`，iPad 使用 `APP_IPAD_PRO_3GEN_129`；实际接受情况仍需上传验证。
- 首版省略 `whatsNew`，后续版本可添加。未填写的可选字段不会清空后台原值。

## 使用命令

从仓库根目录执行。默认仅预演文案，只有 `--apply` 才写入 Apple。

```bash
# 离线检查：无需密钥，不访问 Apple
python3 toolchain/app_store_connect/upload_localizations.py \
  --config toolchain/app_store_connect/config/app_store_connect.local.json --check

# 联网预演：认证、核对 Bundle ID 和版本，展示拟上传文案
python3 toolchain/app_store_connect/upload_localizations.py \
  --config toolchain/app_store_connect/config/app_store_connect.local.json --dry-run

# 上传文案：写入后重新读取字段核对
python3 toolchain/app_store_connect/upload_localizations.py \
  --config toolchain/app_store_connect/config/app_store_connect.local.json --apply

# 仅预演截图
python3 toolchain/app_store_connect/upload_localizations.py \
  --config toolchain/app_store_connect/config/app_store_connect.local.json \
  --with-screenshots --skip-metadata --dry-run

# 仅上传截图
python3 toolchain/app_store_connect/upload_localizations.py \
  --config toolchain/app_store_connect/config/app_store_connect.local.json \
  --with-screenshots --skip-metadata --apply
```

可加 `--locale zh-Hans` 或 `--locale en-US` 限定语言。默认跳过截图，`--skip-screenshots` 仅作兼容选项。截图模式可能为缺失语言创建本地化，因此首次应先完成文案上传。

## 截图替换与错误处理

默认 `clearBeforeUpload=false`：若该组已有截图，报错停止，不追加、不删除。需要替换时，核对语言和设备组，再将该组设为 `true`；这会删除该组已有截图后上传，完成后改回 `false`。其他设备组不删除。部分上传成功后重试也可能触发保护，需先检查后台现状。

预演列出拟上传文件，不模拟 Apple 的写入校验。上传不是事务，可能部分成功；失败后检查退出码与后台现状。截图完成后检查数量，失败不会自动清空重传。替换前如需保留旧图，应先保存旧素材。

## AI 工作流

短指令示例：“按 App Store Connect 工作流更新中英文描述，先预演”。

1. 阅读本说明和产品文档，确认功能与商店宣传一致。
2. 编辑两个语言 JSON，检查翻译对应，新版本更新配置版本号。
3. 运行 `--check` 和联网 `--dry-run`，核对目标 App、版本、语言及拟上传字段。
4. 按用户授权执行 `--apply`；截图显式启用并限定替换组。
5. 检查退出码和字段回读结果，报告实际完成项目；待办区分本地准备和后台完成。

不打印私钥或 JWT，不提交本机配置，不凭空填写联系人、版权姓名、发行地区或合规答案。

## 能力边界与验证

支持副标题、描述、关键词、推广文本、版本更新说明、隐私政策/支持/营销 URL、创建本地化、截图。名称仅在新建语言时填写，已有名称保留。

未实现审核联系人、审核备注、版权、年龄分级、数据收集问卷、价格、发行地区、安装包上传、提交审核、正式发布。隐私政策 URL 上传不等于发布隐私问卷答案。

`--check` 只检查本地文案及截图路径，不验证认证、后台字段可编辑性、URL 可访问性或图片能否被 Apple 接受。联网预演需要有效密钥，也不能保证后续写入成功。

```bash
python3 -m unittest discover -s toolchain/app_store_connect/tests -v
```
