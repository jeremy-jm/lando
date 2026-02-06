# 为什么 App 和 Figma Make 文件看起来不一样？

## 原因说明

当前项目里的 **Figma Make 导出文件**（`Dictionary App UI Design.make`）结构是这样的：

| 文件 | 说明 | 能否用于还原 UI？ |
|------|------|-------------------|
| **canvas.fig** | 实际界面设计（布局、颜色、字体、组件） | ❌ **不能**。这是 Figma 的专有二进制格式（文件头为 `fig-make`），没有公开格式说明，无法从中解析出颜色、字号、间距等设计数据。 |
| **meta.json** | 元数据 | ⚠️ **部分**。只包含画布背景色 `rgb(0.96, 0.96, 0.96)`（即 `#F5F5F5`），已用于 App 浅色背景。没有字体、圆角、间距等。 |
| **ai_chat.json** | 生成该设计时用的**文字提示** | ⚠️ **间接**。内容和 `figma_ai_ui_prompt.md` 一致，是「用文字描述让 Figma AI 画图」，不是从设计稿里导出的 token。 |
| **thumbnail.png** | 缩略图（400×353） | 仅作视觉参考，无法提取精确数值。 |

因此：

- **Figma 里看到的**：是 Figma AI 根据同一段文字提示**画出来的图**，有具体的像素、颜色、圆角等。
- **Flutter 里实现的**：是根据同一段**文字描述** + 项目里的 `ui_spec.md`（从代码总结的规范）+ `meta.json` 里唯一一个背景色**重新实现**的。
- 两边的**数据源不同**：一边是「Figma 的视觉结果」（存在无法解析的 .fig 里），一边是「文字规范 + 一个背景色」，所以**每个页面和 Figma 有差异是正常现象**。

---

## 可行方案

若要让 App **尽量和 Figma 设计一致**，可以选下面一种或多种方式配合使用。

### 方案 A：用标准 Figma 设计文件（推荐）

- 在 Figma 里把当前设计**另存/复制到一份标准设计文件**（即 `figma.com/design/...` 或 `figma.com/file/...` 能打开的那种）。
- 把该设计文件的**链接**（含 fileKey）提供给开发；若有具体画板/节点，可带上 `node-id`。
- 开发侧可以用：
  - **Figma API / 插件**：读取该文件里的颜色、字体、间距等；
  - 或项目里的 **Figma MCP**（`get_figma_data`）按 fileKey 拉取节点数据，再对照实现 Flutter 样式。

这样就有「同一份设计数据源」，而不是只靠文字描述。

### 方案 B：在 Figma 里导出设计 token

- 在 Figma 中整理好：
  - 颜色（主色、背景、表面、错误等）
  - 字体（字号、字重）
  - 圆角、间距等
- 通过 **Figma 变量 / 样式** 或 **插件** 导出为 JSON（或 CSS/其他格式），再在 Flutter 里用同一套数值（例如写进 `app_colors.dart`、`theme`、`ui_spec.md`）。

这样即使不解析 .fig，也能保证数值一致。

### 方案 C：按「页面/组件」人工对齐

- 打开 Figma 设计稿和 App，逐页面对比（可用 `thumbnail.png` 或 Figma 截图作参考）。
- 列出差异（例如：「首页卡片圆角是 16」「标题字号是 20」），在 Flutter 和 `ui_spec.md` 里按条修改。
- 适合做小范围、高保真还原。

### 方案 D：继续以文字规范为主

- 保持以 `figma_ai_ui_prompt.md` + `ui_spec.md` 为唯一规范，把 Figma Make 文件仅当作**视觉参考**（包括 thumbnail）。
- 接受「描述一致、视觉细节会有差异」的现状，除非后续采用 A/B/C 引入真实设计数据。

---

## 小结

| 问题 | 原因 |
|------|------|
| 为什么每个页面和 Figma Make 文件不一样？ | 设计稿在 **canvas.fig** 里，是**不可解析的二进制**；App 只能根据**文字描述 + 一个背景色**实现，没有从 Figma 拿到真实的设计数据。 |
| 怎么才能更一致？ | 使用**标准 Figma 设计文件链接**（方案 A）或**导出设计 token**（方案 B），或**人工逐项对照**（方案 C）。仅靠 .make 里的 .fig 无法自动同步。 |

如果你能提供标准 Figma 设计文件链接（`figma.com/design/...` 或 `figma.com/file/...`），可以在本项目中用 Figma 数据做进一步对齐（例如颜色、字号、圆角、间距等）。

---

## 关于 Figma Make 链接

当前设计链接格式为 **Figma Make**：
`https://www.figma.com/make/vSBP8rKOGYuDBmP3uDmxIY/Dictionary-App-UI-Design`

- 使用该链接中的 ID（`vSBP8rKOGYuDBmP3uDmxIY`）调用 Figma API 时，会返回 **429 Too Many Requests**（请求频率限制），无法稳定拉取设计数据。
- Figma Make 项目与「标准设计文件」可能使用不同后端，API 的 `fileKey` 通常对应的是 `figma.com/design/...` 或 `figma.com/file/...` 里的文件。

**建议**：在 Figma 中打开该 Make 项目后，使用菜单 **复制 / 另存为** 将画布内容复制到一份**新的设计文件**（File → Save as / Duplicate 到 Team 或 Draft），然后分享**新文件的链接**（形如 `https://www.figma.com/design/XXXXXXXX/...`）。拿到该链接后即可用 Figma API / MCP 按 fileKey 拉取节点数据并与 Flutter 对齐。

---

## Flutter 样式同步（基于 ui_spec）

由于 Figma Make API 无法稳定拉取，当前采用**基于 ui_spec.md 的设计规范同步**方式：

- **设计常量**：`lib/theme/app_design.dart` 集中管理间距、圆角、字号、图标尺寸等 token，与 ui_spec 一一对应
- **颜色**：`lib/theme/app_colors.dart` 管理主色、浅色/深色主题
- **全局主题**：`main.dart` 中配置 `inputDecorationTheme`、浅色/深色主题
- **页面与组件**：各 feature 页面、共享组件均引用 `AppDesign` 常量，确保与 Figma 设计规范一致

当获得标准 Figma 设计文件链接后，可通过 Figma MCP 的 `get_figma_data` 拉取真实设计数据，进一步微调 `app_design.dart` 中的数值以达成像素级对齐。
