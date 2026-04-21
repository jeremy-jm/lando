# 离线词典集成方案

## 需求概述

将默认查询引擎从 Youdao 在线服务切换为 MDict 离线词典，未命中时自动降级到在线服务。

## 关键决策

| 决策项 | 确认结果 |
|--------|----------|
| 默认引擎 | **MDict 离线优先** |
| 词典文件 | **ECDICT**（MIT 协议，76万+词条） |
| 未命中行为 | **自动降级 Youdao**（无感知） |
| 自定义词典 | **支持导入** .mdx 文件 |
| Web 平台 | **跳过 MDict**，直接用在线服务 |
| UI 风格 | 与现有 ProxySettingsPage 一致 |

## ECDICT 词典信息

| 属性 | 详情 |
|------|------|
| **名称** | ECDICT (English-Chinese Dictionary) |
| **授权** | **MIT License** |
| **作者** | skywind3000 |
| **GitHub** | https://github.com/skywind3000/ECDICT |
| **词条数** | **76万+** |
| **格式** | 需通过项目自带工具链转换为 .mdx |

## 实施方案

### 步骤 1：依赖与资源
- 添加 `mdict_reader` 包到 `pubspec.yaml`
- 在 `assets/` 下创建 `mdict/` 目录用于存放 .mdx 文件
- 在 `tools/` 下创建 ECDICT → MDX 构建脚本

### 步骤 2：核心模块
- 创建 `lib/services/mdict/mdict_manager.dart` — 加载/查询 .mdx 文件
- 创建 `lib/services/mdict/mdict_html_parser.dart` — HTML 解析为 ResultModel

### 步骤 3：翻译服务
- 创建 `lib/services/translation/mdict_translation_service.dart`
- 扩展 `TranslationServiceType` 添加 `mdict` 枚举值
- 扩展 `TranslationServiceFactory` 支持创建 MDict 服务

### 步骤 4：默认行为修改
- `QueryRepository` 默认改为 `mdict`
- `QueryPage` platforms 列表加入 mdict
- MDict 未命中时自动降级到 Youdao

### 步骤 5：存储与初始化
- 扩展 `PreferencesStorage` 存储用户自定义词典配置
- `main.dart` 启动时异步加载默认词典

### 步骤 6：设置 UI
- 新建 `lib/features/me/mdict_settings_page.dart`
- 在 `SettingsPage` 中添加 MDict 设置入口
- 在 `AppRoutes` 注册新路由

### 步骤 7：国际化
- 更新全部 7 个 arb 文件，添加 MDict 相关字符串

## 新增文件清单

| 文件路径 | 说明 |
|----------|------|
| `lib/services/mdict/mdict_manager.dart` | MDict 词典管理器 |
| `lib/services/mdict/mdict_html_parser.dart` | MDict HTML 解析器 |
| `lib/services/translation/mdict_translation_service.dart` | MDict 翻译服务 |
| `lib/features/me/mdict_settings_page.dart` | MDict 设置页面 |
| `tools/build_mdict.sh` | ECDICT → MDX 构建脚本 |
| `assets/mdict/.gitkeep` | 词典资源目录占位 |

## 修改文件清单

| 文件路径 | 修改内容 |
|----------|----------|
| `pubspec.yaml` | 添加 mdict_reader 依赖 |
| `lib/services/translation/translation_service_type.dart` | 添加 mdict 枚举值 |
| `lib/services/translation/translation_service_factory.dart` | 添加 mdict 服务创建逻辑 |
| `lib/features/home/query/query_repository.dart` | 默认改为 mdict |
| `lib/features/home/query/query_page.dart` | platforms 加入 mdict |
| `lib/storage/preferences_storage.dart` | 添加词典相关配置项 |
| `lib/main.dart` | 启动时加载词典 |
| `lib/features/me/settings_page.dart` | 添加 MDict 设置入口 |
| `lib/routes/app_routes.dart` | 注册新路由 |
| `lib/l10n/app_zh.arb` | 添加中文国际化 |
| `lib/l10n/app_en.arb` | 添加英文国际化 |
| `lib/l10n/*.arb` | 其他语言文件 |
