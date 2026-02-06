# Lando 词典 · UI 设计规范

本文档整理自当前 Flutter 代码实现，用于开发、设计与 Figma 协作时统一 UI。所有数值与 `lib/theme/app_colors.dart`、各 feature 内组件保持一致。

---

## 一、设计基础

| 项目 | 说明 |
|------|------|
| 设计语言 | Material Design 3 |
| 主题 | `useMaterial3: true`，支持浅色 / 深色 / 跟随系统；**主题色（主色）为蓝色**，浅色与深色模式下均使用蓝色，形成本 App 特有视觉 |
| 多语言 | 支持 en, zh, ja, hi, id, pt, ru；文案需预留换行与长文本空间 |

---

## 二、色彩规范

### 2.1 主题色与语义色（ColorScheme）

- **主色（品牌色）**：`colorScheme.primary` — **蓝色**。来自 `Colors.lightBlue` 种子色，浅色与深色模式下均为蓝色，用于 Tab 选中、主按钮、链接、强调标签、图标强调等，形成本 App 统一主题色。
- **主色容器**：`colorScheme.primaryContainer`、`onPrimaryContainer`
- **表面与背景**：`surface`、`surfaceContainer`、`surfaceContainerHighest`
- **前景**：`onSurface`、`onSurface` + alpha（0.3 / 0.5 / 0.6 / 0.7）
- **轮廓**：`outline`、`outline.withValues(alpha: 0.1)` 用于分割线
- **AppBar 背景**：`colorScheme.inversePrimary`
- **错误**：`colorScheme.error`、`errorContainer`、`onError`、`onErrorContainer`
- **成功/警告/信息**：代码中定义 `AppColors.success/warning/info`，UI 上以 theme 为主

### 2.2 使用约定

- 主操作、选中态、Tab 选中：`primary`
- 次要强调（如标签、检测语言）：`primaryContainer` 或 `primary.withValues(alpha: 0.3)`
- 正文：`onSurface`；次要文案：`onSurface` alpha 0.5～0.7
- 分割线：`onSurface.withValues(alpha: 0.1)` 或 `outline.withValues(alpha: 0.1)`，高度 0.5～1
- 危险操作（删除、清空）：`colorScheme.error` 或 `foregroundColor: theme.colorScheme.error`

### 2.3 浅色 / 深色（主色均为蓝色）

- 浅色：背景白、文字深，主色为蓝色（如 lightBlue）。
- 深色：背景 `#121212`、底部栏 `#1E1E1E`，文字浅，主色仍为蓝色（如 lightBlue.shade300），保证对比可读。
- 所有组件需在两种主题下可读，避免硬编码色值，优先使用 `theme.colorScheme`；蓝色主题色在两种模式下一致使用。

---

## 三、字体与排版（Typography）

### 3.1 使用 TextTheme 的场合

- **页面/区块标题**：`theme.textTheme.titleLarge`（加粗、primary 色）— 如词典来源名
- **小节标题**：`theme.textTheme.titleMedium`（加粗、onSurface）— 如词性、短语、网络翻译
- **正文强调**：`theme.textTheme.titleMedium`（primary）— 如简单释义
- **大标题（查词词头）**：`theme.textTheme.headlineMedium`（加粗、onSurface）

### 3.2 字号与字重（代码中实际使用）

| 用途 | fontSize | fontWeight | 颜色 |
|------|----------|------------|------|
| 查词词头、列表主标题 | 18 | bold | onSurface |
| 空状态文案、错误信息正文 | 16 | normal | onSurface / error |
| 列表释义、正文、输入框 | 14 | normal / w500 | onSurface / onSurface 0.7 |
| 短语副文案、标签内文 | 13 | normal | onSurface 0.8 |
| 音标标签、时间戳、考试标签、小标签 | 12 | normal / w500 | onSurface 0.5～0.6 / primary |
| 输入框光标高度 | — | — | cursorHeight: 16 |

### 3.3 行高与行数

- 正文 `height: 1.5`（如查询页简单结果）
- 副标题/释义限制：`maxLines: 1` 或 `maxLines: 2`，`overflow: TextOverflow.ellipsis`

---

## 四、间距规范（Spacing）

### 4.1 基准与常用值（单位：dp/pt）

| 名称 | 数值 | 用途 |
|------|------|------|
| 极小 | 2 | 标签内 padding（vertical） |
| 小 | 4 | 列表项内元素间距、Divider 前后 |
| 中 | 6, 8 | 图标与文字间距、卡片内 padding、圆角 6/8 |
| 标准 | 10, 12 | 输入框 contentPadding 水平 10、语言条水平 8；图标间距 12 |
| 常规 | 16 | 页面水平 padding、卡片 padding、区块间距、SizedBox 主间距 |
| 大 | 24 | 区块间、卡片底部间距、加载/空状态内 padding |
| 超大 | 32, 40 | 分组 Divider 高度 32；首页 Logo 上下 40 |

### 4.2 页面级

- **水平边距**：`EdgeInsets.symmetric(horizontal: 16)` 或 `EdgeInsets.only(left: 16, right: 16, top: 16)`
- **列表内边距**：`padding: const EdgeInsets.all(8)` 或 16
- **分组标题**：`EdgeInsets.fromLTRB(16, 16, 16, 8)`
- **首页垂直节奏**：上 40 → Logo → 40 → 输入框 → 16 → 语言选择器

---

## 五、圆角（Border Radius）

| 数值 | 用途 |
|------|------|
| 4 | 小标签（考试级别、词性小标签）、可点击文本高亮 |
| 6 | 语言选择器芯片、互换按钮容器 |
| 8 | 工具条、发音按钮容器、错误横幅、语言选择器外层、列表内装饰 |
| 12 | 输入框、输入框容器、结果卡片、简单结果容器、列表卡片（部分） |
| 20 | 导航后退/前进按钮的 InkWell 圆角 |

---

## 六、按钮规范

### 6.1 图标按钮（IconButton）

| 场景 | 图标尺寸 | padding | 说明 |
|------|----------|---------|------|
| AppBar 返回 | 16 | 默认 | Icons.arrow_back_ios_new, size: 16 |
| AppBar 设置/词典设置 | 18 | 默认 | Icons.settings, size: 18 |
| 输入框工具条（发音、复制、清除） | 16 | EdgeInsets.zero, constraints: BoxConstraints() | 紧凑一排 |
| 导航后退/前进 | 20 | 36×36 点击区域 | 在工具条内 |
| 发音（词典卡片内） | 20 | 8 | Icons.volume_up |
| 短语内发音 | 16 | 4 | 小喇叭 |
| 列表项删除 | 默认 | 默认 | Icons.delete_outline |
| 收藏星标 | 默认 | 8 | Icons.star / Icons.star_border |

### 6.2 文字按钮

- **次要/取消**：`TextButton`，默认样式
- **危险确认**：`TextButton.styleFrom(foregroundColor: theme.colorScheme.error)`
- **主操作**：`ElevatedButton`，如「验证代理」：`padding: EdgeInsets.symmetric(vertical: 16)`

### 6.3 其他

- **语言选择器**：可点击区域，内为文字 + Icons.arrow_drop_down (size 18)，padding 水平 12、垂直 6
- **互换语言**：容器 padding 6，Icons.swap_horiz size 18
- **列表项**：整行可点击，trailing 为 IconButton 或 ChevronRight

---

## 七、输入框规范

- **容器**：`surfaceContainerHighest`，圆角 12，无描边或 borderSide: none
- **输入区**：`OutlineInputBorder(borderRadius: 12, borderSide: BorderSide.none)`，filled: true
- **内容内边距**：`contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7)`
- **光标**：cursorHeight: 16
- **行数**：minLines: 1, maxLines: 6
- **行为**：textInputAction: TextInputAction.search
- **占位符**：使用 l10n「输入要翻译的文本」

---

## 八、卡片与容器

### 8.1 结果卡片（词典平台卡）

- **padding**：`EdgeInsets.all(16)`
- **圆角**：12
- **背景**：`colorScheme.surfaceContainer`
- **卡片间距**：底部 `padding: EdgeInsets.only(bottom: 24)`

### 8.2 列表项卡片（收藏/历史）

- **margin**：`EdgeInsets.symmetric(horizontal: 8, vertical: 4)`
- **ListTile contentPadding**：`EdgeInsets.symmetric(horizontal: 16, vertical: 8)`
- 使用 `Card` + `ListTile`，trailing 删除图标

### 8.3 输入框外容器

- 背景 `surfaceContainerHighest`，圆角 12，内部输入框与工具条同一视觉块

### 8.4 工具条（输入框下方）

- 高度 30，padding 水平 8；内部导航区 padding 8×4，分割用 border bottom 0.5、outline alpha 0.1

---

## 九、列表与分割

### 9.1 列表

- **ListView**：padding 8 或 16
- **ListTile**：leading 图标（primary 色），title + subtitle，trailing 箭头或 IconButton
- **分组标题**：`titleMedium` + bold + primary，padding fromLTRB(16, 16, 16, 8)

### 9.2 Divider

- **默认**：`Divider()` 或 `height: 0.5, color: onSurface.withValues(alpha: 0.1)`
- **分组间**：`Divider(height: 32)` 加大留白

---

## 十、导航与页面框架

### 10.1 底部导航栏（BottomTabBar）

- **背景**：`surface` alpha 0.98（浅色），带顶部分割线 0.5、outline alpha 0.1
- **选中**：`colorScheme.primary`；未选中：`onSurface` alpha 0.6
- **标签**：selectedLabelStyle bold，unselectedLabelStyle normal
- **类型**：BottomNavigationBarType.fixed，仅 2 项（首页、我的）
- 桌面端可选毛玻璃：BackdropFilter blur(20)，与当前实现一致

### 10.2 AppBar

- **背景**：`colorScheme.inversePrimary`
- **标题**：使用 `AppBar(title: Text(...))` 或自定义标题组件（如语言选择器）
- **leading**：返回箭头，size 16
- **actions**：图标 18，如设置

### 10.3 页面主体

- **SafeArea**：bottom: false 时保留底部留给 TabBar
- **默认主体 padding**：left/right/top 16；或 symmetric horizontal 16 + top 16

---

## 十一、图标使用

- **风格**：Material Icons
- **常用**：home, person, settings, favorite, history, delete_outline, volume_up, content_copy, arrow_back, arrow_forward, clear, star, star_border, info_outline, chevron_right, swap_horiz, arrow_drop_down, book, settings_ethernet, info_outline, privacy_tip_outlined, description_outlined, code_outlined
- **尺寸**：见「六、按钮规范」，未注明处默认 24

---

## 十二、空状态与弹窗

### 12.1 空状态（EmptyStateWidget）

- 居中 Column：Icon（size 64，onSurface alpha 0.3）+ SizedBox(16) + Text
- 文案：fontSize 18，onSurface alpha 0.6

### 12.2 确认弹窗（ConfirmDialogWidget）

- AlertDialog：title、content（纯文字）、actions：TextButton 取消 + TextButton 确认
- 危险确认：confirmButtonStyle 使用 `foregroundColor: theme.colorScheme.error`

### 12.3 SnackBar

- 成功/提示：默认样式，duration 1～2 秒
- 错误：可设 `backgroundColor: theme.colorScheme.errorContainer`，duration 2～3 秒

---

## 十三、页面布局摘要（按屏）

| 页面 | 水平 padding | 顶部/区块间距 | 备注 |
|------|--------------|----------------|------|
| 首页 | 16 | 40 / 40 / 16 | 居中列，Logo 100×100 |
| 查询页 | 16 | 16, 24（输入与结果间） | AppBar + 输入+工具条 + 可滚动结果 |
| 我的 | 0 | 列表直接 | 可选头像区 + ListView |
| 收藏/历史 | 8 | AppBar 下即列表 | 列表 margin 8,4 |
| 设置 | 0 | 分组 16,16,8；Divider 32 | ListView 分组 |
| 词典设置 | 0 | 列表 | 单列表 + 单选 |
| 代理设置 | 16 | 16/24 | Card 内 16 |
| 关于 | 16 | 16；区块 32 | 顶部 Logo/图标 80，版权底部 padding 16 |

---

## 十四、与 Figma 的对应建议

- **颜色**：在 Figma 中建立变量，**主色（primary）统一为蓝色**，浅色与深色模式均使用同一蓝色主题；其余对应 `surface`、`onSurface`、`error` 等，并做 Light/Dark 模式
- **文字**：建立样式 Title Large/Medium、Body Medium/Small、Caption（对应 18 bold、16、14、12）
- **间距**：使用 4/8/12/16/24/32/40 的网格
- **圆角**：组件库中统一 4、6、8、12、20
- **图标**：Material Icons 库，尺寸 16、18、20、24

以上规范与当前代码一致，开发与设计可据此统一实现与交付物。
