# Lando 词典 · AI UI 生成提示词（通用）

本文档为 **Figma AI**、[Google Stitch](https://stitch.withgoogle.com/) 及同类 AI UI 生成工具准备的统一提示词，用于生成词典应用（Lando 词典）的全部界面线框/高保真。  
请按「产品说明 → 全局导航 → 设计系统 → 逐屏描述」顺序理解并生成；设计系统数值与 [ui_spec.md](ui_spec.md)、`lib/theme/app_colors.dart`、`lib/theme/app_design.dart` 一致。

---

## 一、产品与平台说明

- **产品**：词典 / 翻译应用（名称：Lando 词典 / Lando Dictionary）。
- **技术**：Flutter，需同时支持**手机**与**桌面**（平板可复用手机布局）。
- **平台**：iOS、Android、macOS、Windows、Linux。
- **设计约束**：
  - 支持**浅色**与**深色**两种模式；**主题色（主色）统一为蓝色**（如 #03A9F4），浅色与深色模式下主色均为蓝色，界面元素在两种模式下均清晰可读。
  - 支持多语言（en, zh, ja, hi, id, pt, ru）；文案需预留换行与长文本空间。
- **风格**：Material Design 3（`useMaterial3: true`），圆角卡片、清晰层级、底部主导航；**品牌色为蓝色**，用于 Tab 选中、主按钮、链接、强调标签等。

---

## 二、全局导航结构

- **根布局**：底部一条 **BottomTabBar**，仅两个 Tab，整 App 仅此一级 Tab。
  - **Tab 1**：首页（查词入口）。图标：Home / 房子。文案：**首页** 或 **翻译**（二选一展示）。
  - **Tab 2**：我的（个人与设置）。图标：Person / 人形。文案：**我的**。
- 切换 Tab 时，仅切换主内容区，底部 TabBar 始终可见；无顶部全局 AppBar 时，各子页自己带 AppBar。
- 除根 Tab 外，其余均为**全屏堆栈页面**（从右侧推入），带返回按钮。

---

## 三、如何使用本文档

- **方式一（推荐）**：将「六、总览提示词」整段复制到 AI 工具的文本输入框，一次性描述整 App 的导航与设计系统，再按需追加「五、逐屏 UI 描述」中某一屏的细节。
- **方式二**：分步生成时，先输入「一、二」+「四、设计系统」摘要 +「屏幕 1 + 屏幕 3」生成主导航与首页、我的，再逐屏输入「五」中屏幕 2、4～9。
- **方式三**：仅生成某一屏时，结合「四、设计系统」+「五、逐屏 UI 描述」中对应屏幕的段落。

**按画板生成时**：可按屏幕 1～9 分别生成 9 个画板（Frame），标注名称如 "1_Home", "2_Query", "3_Me" …；或先生成「屏幕 1 + 屏幕 2」再补充其余。

**工具差异**：
- **Figma AI**：可将「二、全局导航」+「五」中某几屏一起输入；若只接受一段话，用「七、单段浓缩提示词」。
- **Stitch**：适合先贴「六、总览提示词」再按屏追加；导出代码时可对照 `app_design.dart`、`app_colors.dart` 与 l10n key。

建议首句提示：  
「请生成一个词典应用的 UI，主题色为蓝色（浅色与深色模式均使用蓝色主色）。先画底部两个 Tab：首页、我的；再画首页内容：Logo、输入框、语言选择器（源语言 ↔ 目标语言）。」  
然后按需追加：「再画查询页面：顶部返回+语言对+设置图标，输入框下带发音/复制/前后/检测语言/清除，下方多块结果卡片…」等。

---

## 四、设计系统（必读 · 与 ui_spec.md 一致）

生成 UI 时请严格遵循以下数值，与 [ui_spec.md](ui_spec.md) 及 `lib/theme/app_colors.dart`、`lib/theme/app_design.dart` 保持一致。

### 4.1 设计基础

| 项目 | 说明 |
|------|------|
| 设计语言 | Material Design 3 |
| 主题 | 支持浅色 / 深色 / 跟随系统；**主题色（主色）为蓝色**，浅色与深色模式下均使用蓝色 |
| 多语言 | 支持 en, zh, ja, hi, id, pt, ru；文案需预留换行与长文本空间 |

### 4.2 色彩规范

**主题色与语义色（ColorScheme）**  
- **主色（品牌色）**：`colorScheme.primary` — 蓝色（如 #03A9F4 / lightBlue），用于 Tab 选中、主按钮、链接、强调标签、图标强调等。  
- **主色容器**：`primaryContainer`、`onPrimaryContainer`  
- **表面与背景**：`surface`、`surfaceContainer`、`surfaceContainerHighest`  
- **前景**：`onSurface`；次要文案 `onSurface` + alpha（0.3 / 0.5 / 0.6 / 0.7）  
- **轮廓**：`outline`；分割线 `outline.withValues(alpha: 0.1)`  
- **AppBar 背景**：`colorScheme.inversePrimary`  
- **错误**：`error`、`errorContainer`、`onError`、`onErrorContainer`  

**使用约定**  
- 主操作、选中态、Tab 选中：`primary`  
- 次要强调（如标签、检测语言）：`primaryContainer` 或 `primary.withValues(alpha: 0.3)`  
- 正文：`onSurface`；次要文案：`onSurface` alpha 0.5～0.7  
- 分割线：`onSurface.withValues(alpha: 0.1)` 或 `outline.withValues(alpha: 0.1)`，高度 0.5～1  
- 危险操作（删除、清空）：`colorScheme.error`  

**浅色 / 深色**：浅色背景白、文字深；深色背景 `#121212`、底部栏 `#1E1E1E`，主色在两种模式下均为蓝色（深色可用 lightBlue.shade300 保证对比）。

### 4.3 字体与排版（Typography）

**TextTheme 使用**  
- 页面/区块标题（如词典来源名）：`titleLarge`，加粗、primary  
- 小节标题（词性、短语、网络翻译）：`titleMedium`，加粗、onSurface  
- 正文强调（如简单释义）：`titleMedium`，primary  
- 大标题（查词词头）：`headlineMedium`，加粗、onSurface  

**字号与字重（实际使用）**

| 用途 | fontSize | fontWeight | 颜色 |
|------|----------|------------|------|
| 查词词头、列表主标题 | 18 | bold | onSurface |
| 空状态文案、错误正文 | 16 | normal | onSurface / error |
| 列表释义、正文、输入框 | 14 | normal / w500 | onSurface / onSurface 0.7 |
| 短语副文案、标签内文 | 13 | normal | onSurface 0.8 |
| 音标、时间戳、考试标签、小标签 | 12 | normal / w500 | onSurface 0.5～0.6 / primary |
| 输入框光标 | — | — | cursorHeight: 16 |

**行高与行数**：正文行高 1.5；副标题/释义可 `maxLines: 1` 或 2，`overflow: ellipsis`。

### 4.4 间距规范（dp）

| 名称   | 数值 | 用途                           |
|--------|------|--------------------------------|
| 极小   | 2    | 标签内垂直 padding             |
| 小     | 4    | 列表项内间距、Divider 前后     |
| 中     | 6, 8 | 图标与文字、卡片内、圆角 6/8   |
| 标准   | 10, 12 | 输入框水平 10、语言条 8、图标 12 |
| 常规   | 16   | 页面水平 padding、卡片、区块   |
| 大     | 24   | 区块间、卡片底部、空状态内     |
| 超大   | 32, 40 | 分组 Divider 高度 32；首页 Logo 上下 40 |

**页面级**：水平边距 `symmetric(horizontal: 16)` 或 `left/right/top 16`；列表内边距 8 或 16；分组标题 `fromLTRB(16, 16, 16, 8)`；首页垂直节奏：上 40 → Logo → 40 → 输入框 → 16 → 语言选择器。

### 4.5 圆角（Border Radius）

| 数值 | 用途 |
|------|------|
| 4 | 小标签（考试级别、词性小标签）、可点击文本高亮 |
| 6 | 语言选择器芯片、互换按钮容器 |
| 8 | 工具条、发音按钮容器、错误横幅、语言选择器外层、列表内装饰 |
| 12 | 输入框、输入框容器、结果卡片、简单结果容器、列表卡片（部分） |
| 20 | 导航后退/前进按钮的 InkWell 圆角 |

### 4.6 按钮规范

**图标按钮**  
| 场景 | 图标尺寸 | padding | 说明 |
|------|----------|---------|------|
| AppBar 返回 | 16 | 默认 | arrow_back_ios_new, size 16 |
| AppBar 设置/词典设置 | 18 | 默认 | Icons.settings, size 18 |
| 输入框工具条（发音、复制、清除） | 16 | zero, constraints 紧凑 | 紧凑一排 |
| 导航后退/前进 | 20 | 36×36 点击区域 | 在工具条内 |
| 发音（词典卡片内） | 20 | 8 | Icons.volume_up |
| 短语内发音 | 16 | 4 | 小喇叭 |
| 列表项删除 | 默认 | 默认 | Icons.delete_outline |
| 收藏星标 | 默认 | 8 | Icons.star / Icons.star_border |

**文字按钮**：次要/取消用 `TextButton`；危险确认用 `foregroundColor: error`；主操作用 `ElevatedButton`（如「验证代理」padding vertical 16）。  
**其他**：语言选择器 — 文字 + Icons.arrow_drop_down (size 18)，padding 水平 12、垂直 6；互换语言 — 容器 padding 6，Icons.swap_horiz size 18；列表项整行可点击，trailing 为 IconButton 或 ChevronRight。

### 4.7 输入框规范

- 容器：`surfaceContainerHighest`，圆角 12，无描边或 borderSide: none  
- 内容内边距：`contentPadding: horizontal 10, vertical 7`  
- 光标：cursorHeight: 16；行数：minLines: 1, maxLines: 6  
- 行为：textInputAction: search；占位符：l10n「输入要翻译的文本」

### 4.8 卡片与容器

- **结果卡片（词典平台卡）**：padding 16，圆角 12，背景 surfaceContainer；卡片间距底部 24。  
- **列表项卡片（收藏/历史）**：margin horizontal 8 vertical 4；ListTile contentPadding 16 H 8 V；Card + ListTile，trailing 删除图标。  
- **输入框外容器**：背景 surfaceContainerHighest，圆角 12，输入框与工具条同一视觉块。  
- **工具条（输入框下方）**：高度 30，padding 水平 8；内部导航区 padding 8×4；分割用 border bottom 0.5、outline alpha 0.1。

### 4.9 列表与分割

- ListView padding 8 或 16；ListTile：leading 图标（primary），title + subtitle，trailing 箭头或 IconButton；分组标题：titleMedium + bold + primary，padding fromLTRB(16, 16, 16, 8)。  
- Divider 默认 height 0.5、onSurface alpha 0.1；分组间 Divider(height: 32)。

### 4.10 导航与页面框架

- **底部导航栏**：背景 surface alpha 0.98（浅色），顶部分割线 0.5、outline alpha 0.1；选中 primary、未选中 onSurface 0.6；selectedLabelStyle bold、unselectedLabelStyle normal；BottomNavigationBarType.fixed，仅 2 项；桌面端可选 BackdropFilter blur(20)。  
- **AppBar**：背景 inversePrimary；leading 返回箭头 size 16；actions 图标 18。  
- **页面主体**：SafeArea bottom: false 时保留底部给 TabBar；默认 padding left/right/top 16 或 symmetric horizontal 16 + top 16。

### 4.11 图标使用

Material Icons：home, person, settings, favorite, history, delete_outline, volume_up, content_copy, arrow_back, arrow_forward, clear, star, star_border, info_outline, chevron_right, swap_horiz, arrow_drop_down, book, settings_ethernet, privacy_tip_outlined, description_outlined, code_outlined。尺寸见 4.6，未注明处默认 24。

### 4.12 空状态与弹窗

- **空状态**：居中 Column — Icon size 64、onSurface alpha 0.3 + SizedBox(16) + Text；文案 fontSize 18、onSurface alpha 0.6。  
- **确认弹窗**：AlertDialog title、content、actions 取消 + 确认；危险确认 confirmButtonStyle 使用 error。  
- **SnackBar**：成功/提示默认样式 duration 1～2 秒；错误可设 errorContainer，duration 2～3 秒。

### 4.13 页面布局摘要（按屏）

| 页面 | 水平 padding | 顶部/区块间距 | 备注 |
|------|--------------|----------------|------|
| 首页 | 16 | 40 / 40 / 16 | 居中列，Logo 100×100 |
| 查询页 | 16 | 16, 24（输入与结果间） | AppBar + 输入+工具条 + 可滚动结果 |
| 我的 | 0 | 列表直接 | 可选头像区 + ListView |
| 收藏/历史 | 8 | AppBar 下即列表 | 列表 margin 8,4 |
| 设置 | 0 | 分组 16,16,8；Divider 32 | ListView 分组 |
| 词典设置 | 0 | 列表 | 单列表 + 单选 |
| 代理设置 | 16 | 16/24 | Card 内 16 |
| 关于 | 16 | 16；区块 32 | 顶部 Logo 80，版权底部 padding 16 |

### 4.14 设计统一要求（给 AI 的补充说明）

- **主题色**：蓝色，浅色与深色模式下主色均为蓝色；用于 Tab 选中、主按钮、链接、强调标签、图标、小节标题。  
- **圆角**：卡片、输入框、按钮 8～12 pt。**间距**：卡片与列表 16pt 边距，项间距 8pt。**层级**：背景色、卡片、分割线区分区块。**图标**：Material Icons，强调用蓝色。**多语言**：以中文为主展示，长文案可换行或省略号。

---

## 五、逐屏 UI 描述（供逐屏生成）

### 屏幕 1：首页（Home / 翻译 Tab 内容）

**用途**：查词入口。无顶部 AppBar（在 Tab 内时）。

**布局**：垂直居中、单列、左右留白（如 16pt）。

**从上到下依次**：

1. **顶部留白**（如 40pt）。
2. **Logo**：一张方形 Logo 图（占位尺寸约 100×100 pt），居中；可标注「Logo 占位」。
3. **留白**（如 40pt）。
4. **查询输入框**：单行输入框（可扩展为多行），圆角（如 12pt），带背景色与无描边或浅描边。Placeholder 文案：**输入要翻译的文本** / "Enter text to translate"。行为说明（仅给 AI 理解）：支持自动联想，下方会弹出建议列表；回车后跳转到「查询页面」并显示结果。UI 上只需画出：一个输入框 + 下方**可折叠的建议下拉区域**（可先画成一条「建议列表占位」或留空）。
5. **留白**（如 16pt）。
6. **语言选择器（整行居中）**：结构为 **[源语言]** · **[互换箭头图标]** · **[目标语言]**。源/目标：各为一个可点击的芯片/按钮，内为文字 + 下拉箭头（如 ▼）；中间为**水平互换箭头**图标（如 ↔）。示例文案：**中文** ↔ **英语**；未设置时显示 **Auto** ↔ **Auto**。视觉：同一行、水平居中、间距均匀。

**本屏要点**：Logo + 单输入框 + 语言「源 ↔ 目标」一行；风格简洁、居中。

---

### 屏幕 2：查询页面（Query / 查词结果页）

**用途**：输入/修改查询词、查看多来源词典结果。从首页「回车」或从历史/收藏点击进入。

**顶部 AppBar**：左侧**返回**按钮（< 或箭头）；中间**语言选择器**（与首页相同的「源语言 ↔ 目标语言」一行，可缩短为只显示文案，如「中文 ↔ 英语」）；右侧**设置/词典设置**图标（齿轮或词典图标），点击进入设置或词典设置。

**主体（从上到下）**：

1. **查询输入框 + 工具条**：**输入框**与首页同风格，多行能力，Placeholder 同上；下方有**联想建议列表**（可折叠）。**紧贴输入框下方的一行工具条**（同一卡片/同一背景内）：喇叭图标（**发音**）、复制图标（**复制**）、后退箭头（**后退**，历史上一词）、前进箭头（**前进**，历史下一词）、一段短文案**识别为：英语**（或「Detected: English」）、清除图标（**清除**）。工具条为单行、图标与文案横向排列、可部分置灰表示不可用。
2. **留白**（如 24pt）。
3. **查询结果区（可滚动）**：每个**数据来源**一块**卡片**（圆角、有内边距、有背景与边框或阴影）。卡片内结构**从上到下**固定为：**来源名称**（如「Youdao」「Bing」「Apple」，标题样式、加粗）；**查询词**（大号加粗，同一行右侧可带**收藏星标**空心/实心）；**发音行**：美式文案「US」+ 音标文字 + **发音按钮**（喇叭），英式文案「UK」+ 音标文字 + **发音按钮**，可横排、中间留白；**词性 + 词义**：小节标题「词性」或「Part of speech」，列表**词性标签**（如 n. / v.）+ 释义文本、可多行；**考试级别**（若有）如「CET4」「CET6」等标签横向排列；**单词时态/变形**（若有）如「过去式」「过去分词」+ 对应单词；**短语**（若有）短语原文 + 释义、列表，每条可带小喇叭；**网络翻译**（若有）键值对或列表。若有多来源，则**重复上述卡片**上下堆叠，来源名不同即可（Youdao / Bing / Apple 等）。

**本屏要点**：AppBar（返回 + 语言对 + 设置图标）；输入框 + 联想 + 发音/复制/前后/检测语言/清除；下方为多块「来源卡片」，每块含来源、单词、美/英发音、词性词义、考试、时态、短语、网络翻译。

---

### 屏幕 3：我的（Me）

**用途**：个人入口与设置入口。**顶部**（可选）：无 AppBar，或简单标题「我的」。

**主体**：**个人信息区（顶部）**：**头像**圆形、居中或偏上，占位图或默认头像（如 64×64 或 80×80 pt）；**名字**头像下方一行，如「用户」/ "User" 或占位「我的名字」。**列表（全宽）**：三条**列表项**，每条左侧图标 + 标题 + 右侧箭头（>）— 项 1 心形图标 + **收藏** + >；项 2 历史/时钟图标 + **查词记录**（或「查询历史」）+ >；项 3 齿轮图标 + **设置** + >；项与项之间可有分割线。

**本屏要点**：头像 + 名字；下方三条入口（收藏、查词记录、设置）。

---

### 屏幕 4：收藏页（Favorites）

**用途**：展示已收藏的单词列表。**AppBar**：标题**收藏**；右侧**删除/清空**图标（如垃圾桶轮廓），点击清空全部收藏。

**主体**：若为空：居中显示空状态图标 + 文案「暂无收藏」/ "No favorites yet"。若有数据：**列表**，每条为一张**卡片**或**ListTile**— 主标题**单词**（加粗、大字）；副标题**释义摘要**（1～2 行）、**时间**（如 "14:30" 或 "昨天 14:30"）；右侧**删除**图标（单条删除）；整条可点击进入「查询页面」并带出该词。

**本屏要点**：标题「收藏」+ 右上角清空图标；列表每行：单词、释义、时间、删除图标。

---

### 屏幕 5：查询历史页（History）

**用途**：展示查词历史记录。**AppBar**：标题**查词记录** 或 **查询历史**；右侧**清空**图标（同收藏页），清空全部历史。

**主体**：若为空：居中显示空状态 + 文案「暂无查词记录」/ "No history yet"。若有数据：**列表**，每条与收藏页类似— 主标题**查询词**；副标题释义摘要 + **时间**；右侧**删除**图标；整条可点击进入「查询页面」并带出该词。

**本屏要点**：与收藏页结构一致，仅标题和空状态文案不同。

---

### 屏幕 6：设置页（Settings）

**用途**：主题、语言、快捷键、词典设置、代理、关于、清除数据。**AppBar**：标题 **设置**。

**主体**：单列列表，分**区块**（可用分组标题区分）：**1. 通用 / General**— 主题模式（副标题「在浅色、深色或跟随系统之间切换」），三个单选**跟随系统** / **浅色** / **深色**；语言（副标题「选择语言」），单选列表英语、中文、日语、印地语、印尼语、葡萄牙语、俄语（每项一行）；快捷键（仅桌面端可显示）一行标题、右侧箭头、进入快捷键设置。**2. 词典 / Dictionary**— 词典设置（副标题「配置发音和翻译设置」）、代理设置（副标题「配置网络代理」），右侧箭头。**3. 关于 / About**— 关于（副标题「关于本应用、版本信息与法律文档」），右侧箭头。**4. 数据**— 清除本地数据（副标题「清除所有本地数据…」），无箭头、整行可点，可用红色或警示色强调。

**本屏要点**：分组标题 + 列表项（主题单选、语言单选、词典设置、代理设置、关于、清除数据）。

---

### 屏幕 7：词典设置页（Dictionary Settings）

**用途**：选择发音来源。**AppBar**：标题 **词典设置**，左侧返回。

**主体**：一行说明「发音来源」或「选择要使用的发音服务」。**单选列表**（每项一行）：系统、有道、必应 / Bing、谷歌 / Google、百度 / Baidu、苹果 / Apple。

**本屏要点**：标题「词典设置」+ 发音来源单选列表（6 项）。

---

### 屏幕 8：代理设置页（Proxy Settings）

**用途**：配置 HTTP 代理。**AppBar**：标题 **代理设置**，返回。

**主体**：**代理是否启用**一个 **Switch**，标题「启用代理」，副标题简短说明；**代理地址**标签「代理地址」+ 单行输入框、Placeholder 如 "localhost"；**代理端口**标签「代理端口」+ 数字输入框、Placeholder 如 "9091"；可选校验状态文案（成功/失败）或「验证」按钮。

**本屏要点**：开关 + 地址输入框 + 端口输入框。

---

### 屏幕 9：关于页（About）

**用途**：应用信息与法律链接。**AppBar**：标题 **关于**，返回。

**主体（从上到下）**：**1. 顶部品牌区**— **Logo**与首页同款 Logo 图（或图标），居中，约 80×80 pt；**应用名称**如「兰多·词典」/ "Lando Dictionary"；**版本号**如「版本 1.0.0」；**Build 号**如「构建号 1」/ "Build 1"。**2. 简介**— 一段短文案，居中或左对齐，如「一款使用第三方服务进行查词且无广告的翻译软件」。**3. 列表**— **版本信息**一行、右侧**复制**图标；**隐私政策**一行、右侧 >；**服务条款 / Terms of Service**一行、右侧 >；**开源代码许可证**一行、右侧 >。**4. 版权**— 底部居中小字，如「版权所有 © 2024 兰多·词典。保留所有权利。」

**本屏要点**：Logo + 名称 + 版本 + Build + 简介 + 版本信息(复制) + 隐私/条款/许可证 + 版权。

---

## 六、总览提示词（英文，可直接粘贴到 Stitch / 同类工具）

若工具支持长文本，可将下面整段复制后粘贴；设计系统与 [ui_spec.md](ui_spec.md) 对齐。

```
Design a dictionary/translation app UI named "Lando Dictionary" in Material Design 3 style, for both mobile and desktop (responsive). The app has a single bottom tab bar with exactly 2 tabs; all other screens are full-screen stack pages with a back button.

Design system (strict, align with ui_spec):
- Primary/brand: blue (#03A9F4 or lightBlue). Use for: selected tab, primary buttons, links, accents, section titles, key icons. Same blue in light and dark. Secondary emphasis: primaryContainer or primary 0.3. Danger: colorScheme.error.
- Light: scaffold #F5F5F5 or white; onSurface for text. Dark: background #121212; bottom bar #1E1E1E; primary still blue (e.g. lightBlue 300). Surfaces: surface, surfaceContainer, surfaceContainerHighest. AppBar background: inversePrimary. Divider: onSurface/outline 0.1, height 0.5–1.
- Typography: titleLarge bold primary (section/source name); titleMedium bold onSurface (subsection); headlineMedium bold onSurface (query word). Body 14–16px; caption 12px. Line height 1.5; subtitle maxLines 1–2, ellipsis.
- Spacing (dp): 2, 4, 6, 8, 10, 12, 16, 24, 32, 40. Page horizontal 16; card padding 16; list padding 8 or 16; section title fromLTRB(16,16,16,8). Home rhythm: 40 → Logo → 40 → input → 16 → language row.
- Radius: 4 (tags, highlight), 6 (chips, swap), 8 (toolbar, buttons, error banner), 12 (input, cards), 20 (nav back/forward InkWell).
- Icons: Material Icons — home, person, settings, favorite, history, delete_outline, volume_up, content_copy, arrow_back_ios_new, arrow_forward, clear, star/star_border, swap_horiz, arrow_drop_down, chevron_right. Sizes: 16 (app bar back, toolbar); 18 (settings, language dropdown); 20 (toolbar nav, card pronounce); 24 default. Language selector padding H12 V6; swap container padding 6.
- Input: surfaceContainerHighest, radius 12, no border; contentPadding H10 V7; cursorHeight 16; minLines 1 maxLines 6; textInputAction search.
- Cards: result card padding 16, radius 12, surfaceContainer, bottom 24. List card margin 8,4; ListTile contentPadding 16 H 8 V. Toolbar height 30, padding H8, inner 8×4, border bottom 0.5 outline 0.1.
- Empty state: Icon 64 onSurface 0.3 + SizedBox(16) + Text 18px onSurface 0.6. Confirm: AlertDialog; danger confirm = error. SnackBar success 1–2s; error errorContainer 2–3s.

Navigation:
- Bottom tab: Tab 1 "Translation"/"首页" (home), Tab 2 "Me"/"我的" (person). Background surface 0.98, top divider 0.5 outline 0.1; selected primary bold, unselected onSurface 0.6. Fixed, 2 items only. Desktop optional BackdropFilter blur(20).
- Other screens: AppBar inversePrimary, leading back 16, actions 18. Body SafeArea (bottom false when tab bar), padding 16.

Screens to include (summary):
1. Home: centered column — logo 100×100, spacing 40, search input, spacing 16, language row "[Source] ↔ [Target]" (e.g. Chinese ↔ English or Auto ↔ Auto), each tappable with dropdown.
2. Query: AppBar (back, "Source ↔ Target", settings). Body: same input + toolbar row (speaker, copy, back, forward, "Detected: English", clear). Below: scrollable result cards per source (Youdao, Bing, Apple) — each card: source name, word + star, US/UK phonetic + play, part of speech + meanings, exam tags, word forms, phrases, web translations.
3. Me: avatar + name at top; list: Favorites, Query history, Settings (each with icon + chevron right).
4. Favorites: AppBar "Favorites", right clear-all icon. List: word (bold), meaning snippet, time, delete per row.
5. History: same as Favorites, title "Query history", empty "No history yet".
6. Settings: sections — General (theme: Follow system / Light / Dark; language list; Shortcuts); Dictionary (Dictionary settings, Proxy settings); About; Clear local data (destructive).
7. Dictionary settings: single list — pronunciation source: System, Youdao, Bing, Google, Baidu, Apple (radio).
8. Proxy: switch "Enable proxy", field "Proxy address", field "Proxy port".
9. About: logo, app name, version, build, description; rows: Version info + copy, Privacy policy, Terms of Service, Open source licenses; footer copyright.

Support light and dark theme throughout; all copy should allow for long text (e.g. localization: English, Chinese, Japanese, Hindi, Indonesian, Portuguese, Russian).
```

---

## 七、单段浓缩提示词（仅接受一段话时使用）

若 AI 工具只接受一段短提示，可使用下面浓缩版（中英混合，便于模型理解）：

```
Design a dictionary/translation app UI (Material 3 style) for mobile and desktop. Use blue as the primary/brand color in both light and dark theme (tabs, buttons, links, accents). Navigation: Bottom tab bar with 2 tabs only — Tab 1 "首页/Home" (home icon), Tab 2 "我的/Me" (person icon). All other screens are full-screen stack pages with back button. Screen 1 Home: Centered layout. App logo (square, ~100pt). Single rounded search input with placeholder "输入要翻译的文本". Below: language selector row — [Source language] ↔ [Target language] (e.g. 中文 ↔ 英语 or Auto ↔ Auto), each tappable with dropdown arrow. Screen 2 Query: AppBar with back, center "源语言 ↔ 目标语言", right settings icon. Body: same search input; directly below it a toolbar row: speaker (pronounce), copy, back arrow, forward arrow, "识别为: 英语", clear. Below: scrollable result area — multiple cards per data source (Youdao, Bing, Apple). Each card: source name, query word + star, US phonetic + play button, UK phonetic + play button, part of speech + meanings, exam tags, word forms, phrases, web translations. Screen 3 Me: Top: circular avatar, display name "用户". List: Favorites (heart icon), Query history (history icon), Settings (gear icon); each row with chevron right. Screen 4 Favorites: AppBar title "收藏", right trash icon (clear all). List of cards: word (bold), meaning snippet, timestamp, delete icon per row. Screen 5 History: Same as Favorites but title "查词记录", empty state "暂无查词记录". Screen 6 Settings: Sections — General: theme (Follow system / Light / Dark), language (English, 中文, 日本語, Hindi, Indonesian, Portuguese, Russian), shortcuts; Dictionary: Dictionary settings, Proxy settings; About; Clear local data (destructive). Screen 7 Dictionary settings: Title "词典设置". Single list: Pronunciation source — System, Youdao, Bing, Google, Baidu, Apple (radio). Screen 8 Proxy: Switch "启用代理", field "代理地址", field "代理端口". Screen 9 About: Logo, app name "Lando Dictionary", version, build number, short description, row "版本信息" + copy icon, rows Privacy policy / Terms of Service / Open source licenses (chevron), footer copyright.
```

---

## 八、与代码的对应说明

- **设计系统**：数值以 [ui_spec.md](ui_spec.md) 为准，与 `lib/theme/app_colors.dart`、`lib/theme/app_design.dart` 及各 feature 组件一致。
- **导出代码时**：可参考 `app_design.dart`、`app_colors.dart` 替换为项目常量；文案使用 `lib/l10n/` 下的 key（如 `appTitle`, `enterTextToTranslate`, `settings`, `favorites` 等）以支持多语言。
- **路由**：见 `lib/routes/app_routes.dart`（home, query, settings, me, favorites, history, dictionarySettings, proxySettings, about）。页面布局数值见本文档 4.13 页面布局摘要。

---

**文档结束**。本文档适用于 Figma AI、Google Stitch 及同类 AI UI 生成工具；与当前 Flutter 代码及 [ui_spec.md](ui_spec.md) 一致。生成后可将输出与 `lib/features/` 下对应页面及 ui_spec 逐项对照微调。
