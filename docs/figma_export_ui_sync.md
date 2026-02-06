# Figma 导出项目 UI 同步说明

本说明描述如何从**本地 Figma 导出项目**（运行在 http://localhost:5173/）或 **Figma 设计文件**同步 UI 到 Flutter App。

## Figma 设计文件（标准文件）

- **Lando**：<https://www.figma.com/design/Uf6gt2qk5wgACZHJZBcfR4/Lando>
  - **Query Page**：node-id=1-135，与 [QueryPage](lib/features/home/query/query_page.dart) 对应。
  - **Settings Page**：node-id=5-239，与 [SettingsPage](lib/features/me/settings_page.dart) 对应。可用 Figma Desktop MCP（get_design_context / get_screenshot）读取节点后对齐布局与样式。

## 数据源

- **路径**：`docs/Lando Dictionary App UI Design/`
- **技术栈**：Vite + React + TypeScript，Tailwind CSS，主题变量在 `src/styles/theme.css`
- **运行**：`npm run dev` 后访问 http://localhost:5173/

## 已同步的 Token

### 颜色（→ `lib/theme/app_colors.dart`）

| Figma 导出 (theme.css) | Flutter 常量 | 说明 |
|------------------------|--------------|------|
| `--input-background: #f3f3f5` | `lightScaffoldBackground` | 浅色画布/输入区背景 |
| `--muted-foreground: #717182` | `lightSecondaryText` | 次要文案 |
| `--destructive: #d4183d` | `AppColors.destructive` | 危险操作（删除、清空等） |
| 组件中 `blue-500` / `blue-600` | `figmaPrimaryBlue` | 主按钮、Logo、链接等 |

### 间距与圆角（→ `lib/theme/app_design.dart`）

| Figma 导出 | Flutter 常量 | 说明 |
|------------|--------------|------|
| `--radius` 0.625rem (10px), radius-sm/md/lg/xl | `radiusXs`~`radiusXl` | 圆角体系 |
| Tailwind `rounded-3xl` (24px) | `radiusLogo` | Logo 等大容器 |
| `px-4` = 16 | `paddingPage` | 页面水平边距 |
| `px-6 py-4` = 24×16 | `paddingCardL`, `paddingInputL` | 卡片/输入大内边距 |
| `mb-10` = 40, `mb-6` = 24, `gap-4` = 16 | `homeTopSpacing` 等 | 首页节奏 |

### 组件对应

- **首页**：Logo (w-24 h-24 / rounded-3xl)、输入框 (rounded-xl, px-6 py-4)、语言选择 (rounded-lg)、互换按钮 (rounded-full, blue)
- **列表/卡片**：`rounded-xl`、`p-4`/`p-6`、`border border-gray-200`
- **设置/词典**：分组标题 `text-sm font-semibold text-gray-500`、列表项 `px-6 py-4`
- **空状态**：图标 w-16 h-16 (64px)、`py-20` 垂直留白

## 图标同步（Figma 导出 lucide-react → Flutter）

图标已统一到 `lib/theme/app_icons.dart`，与 Figma 导出项目（lucide-react）语义对应：

| Lucide (Figma 导出) | Flutter `AppIcons` | Material 对应 |
|---------------------|--------------------|---------------|
| ArrowLeft | back, backAlt | arrow_back_ios_new, arrow_back |
| ArrowRightCircle | forward | arrow_forward |
| ArrowLeftRight | swapHoriz | swap_horiz |
| ChevronRight | chevronRight | chevron_right |
| Home | home | home |
| User | person | person |
| Heart | favorite, favoriteBorder | favorite, favorite_border |
| History | history | history |
| Settings | settings | settings |
| Volume2 | volumeUp | volume_up |
| Copy | copy | content_copy |
| X | clear | clear |
| Star | star, starBorder | star, star_border |
| Search | search | search |
| Trash2 | deleteOutline, delete | delete_outline, delete |

全应用已改用 `AppIcons.xxx`，不再直接使用 `Icons.xxx`。新增或更换图标时只需改 `app_icons.dart`。

## 如何再次同步

1. 在 `docs/Lando Dictionary App UI Design/` 中修改 `src/styles/theme.css` 或组件内 Tailwind 类。
2. 对照上表，在 `lib/theme/app_colors.dart` 与 `lib/theme/app_design.dart` 中更新对应常量和注释。
3. 若新增 CSS 变量或组件样式，在本文档中补充映射关系。
4. 运行 `flutter test test/unit/theme/app_design_test.dart` 确保设计常量测试通过。

## 可选：用浏览器查看对比

本地启动 Figma 导出项目与 Flutter App 后，可并排打开 http://localhost:5173/ 与 Flutter 运行界面，逐屏对比并微调上述 token。
