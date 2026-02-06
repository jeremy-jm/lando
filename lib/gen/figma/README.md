# Figma 设计同步

本目录用于存放通过 **f2c-mcp** 的 `get_code` 生成的 Flutter 代码与资源。

**本地 Figma 导出项目**：若使用 `docs/Lando Dictionary App UI Design/`（运行在 http://localhost:5173/），可直接从该项目的 `theme.css` 与组件样式同步 UI token 到 `lib/theme/`。详见 [docs/figma_export_ui_sync.md](../docs/figma_export_ui_sync.md)。

## 使用方式

1. 在 Figma 中打开**标准设计文件**（`figma.com/file/...` 或 `figma.com/design/...`），从 URL 获取 `fileKey`。
2. 在 Figma 中为需要导出的画板/组件**复制节点 ID**（右键 → Copy/Paste as → Copy ID）。
3. 调用 f2c-mcp：
   - **get_code**：`fileKey`、`ids`（逗号分隔）、`localPath` 设为本项目 `lib/gen/figma` 的绝对路径，`imgFormat`: `png`，`scaleSize`: `2`。
   - 若文件为私有，需传 `personalToken`（Figma Personal Access Token）。
4. 生成完成后，按计划将设计 token 同步到 `lib/theme/`，并将页面/组件接入各 feature。
5. **文案**：生成代码中的硬编码字符串一律改为 l10n（使用 `AppLocalizations.of(context)!.xxx` 或已有 key），并同步更新 `lib/l10n/*.arb`。
6. **资源**：将 `assets` 子目录中的图标/图在 `pubspec.yaml` 的 `flutter.assets` 中声明（或复制到项目根 `assets/`）。

## Framelink MCP for Figma（同步 UI 数据）

- **get_figma_data**：拉取 Figma 文件的布局、内容、视觉与组件信息。参数：`fileKey`（必填）、`nodeId`（可选，格式 `1234:5678` 或多项 `1:2;3:4`）。
- **download_figma_images**：按节点 ID 下载 SVG/PNG。参数：`fileKey`、`nodes`（`[{ nodeId, fileName }]`）、`localPath`（本目录或 `lib/gen/figma/assets` 的绝对路径）、可选 `pngScale`。

使用同一 **fileKey** 时，Figma **Make** 链接会触发 API **429 Too Many Requests**，与 f2c-mcp 一样无法直接用于 Make。需将设计**另存为标准设计文件**（`figma.com/file/...` 或 `figma.com/design/...`）后再用本 MCP 同步。

## 说明

- Figma **Make** 链接（`figma.com/make/...`）的 fileKey 与标准 API 不兼容（f2c-mcp 返回 404，Framelink/API 返回 429）。请将设计**另存为标准设计文件**后再使用上述 MCP。
- 资源会输出到本目录下的 `assets` 子目录。
