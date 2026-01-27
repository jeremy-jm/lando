<div align="center">
  <img src="https://github.com/jeremy-jm/lando/blob/master/assets/images/logo.png?raw=true" height="256" alt="Lando 标志">
  
  # 兰多词典
  
  #### 🚀 一款集成多种翻译服务的简洁、无广告翻译软件
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)](https://flutter.dev)
</div>

---

## 📖 关于

**兰多词典（Lando）** 是一款免费、开源的翻译词典应用，集成了常用的翻译服务，完全无广告。基于 Flutter 构建，为用户提供简洁快速的查词体验。

### 为什么选择兰多？

作者厌倦了移动平台上翻译应用的启动广告。频繁且短暂的使用中，查词只需要几秒钟，但每次打开软件都要等待至少 5 秒的广告。因此，兰多应运而生——一款完全免费、无广告的替代方案。

---

## ✨ 特性

- 🚫 **无广告** - 完全无广告的使用体验
- 🌍 **多语言支持** - 支持 7 种语言（英语、中文、日语、印地语、印尼语、葡萄牙语、俄语）
- 🎨 **现代界面** - Material Design 3 设计，支持深色/浅色主题
- 🔍 **多种翻译服务** - 当前集成有道翻译；必应、谷歌和 AI 翻译工具即将推出
- 📱 **跨平台** - 支持 iOS、Android、macOS、Windows 和 Linux
- ⚡ **快速轻量** - 快速查词，无多余功能
- 🔖 **历史记录与收藏** - 保存翻译历史和收藏的单词
- 🔊 **发音功能** - 多种发音服务（系统 TTS、有道、百度、必应、谷歌、苹果）
- ⌨️ **全局快捷键** - 可自定义快捷键快速访问（macOS/Windows/Linux）

---

## 🛠️ 支持的平台

| 平台 | 状态 | 备注 |
|------|------|------|
| iOS | ✅ 稳定 | 已完整测试 |
| Android | ✅ 稳定 | 已完整测试 |
| macOS | ✅ 稳定 | 已完整测试 |
| Windows | 🚧 开发中 | 正在积极开发 |
| Linux | 🚧 开发中 | 正在积极开发 |

---

## 🚀 快速开始

### 前置要求

- Flutter SDK (>=3.5.0)
- Dart SDK (>=3.5.0)
- 平台特定的开发工具：
  - **iOS**: Xcode
  - **Android**: Android Studio
  - **macOS**: Xcode Command Line Tools
  - **Windows**: Visual Studio（需要 C++ 支持）
  - **Linux**: GCC, CMake

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/jeremy-jm/lando.git
   cd lando
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   
   # macOS
   flutter run -d macos
   
   # Windows
   flutter run -d windows
   
   # Linux
   flutter run -d linux
   ```

### 构建生产版本

```bash
# 构建 APK (Android)
flutter build apk --release

# 构建 iOS
flutter build ios --release

# 构建 macOS
flutter build macos --release

# 构建 Windows
flutter build windows --release

# 构建 Linux
flutter build linux --release
```

---

## 📱 截图

> 截图即将添加...

---

## 🏗️ 项目结构

```
lando/
├── lib/
│   ├── features/          # 功能模块
│   │   ├── home/          # 首页和翻译
│   │   ├── dictionary/    # 词典视图
│   │   ├── me/            # 设置和个人资料
│   │   └── shared/        # 共享组件
│   ├── l10n/              # 本地化文件
│   ├── models/            # 数据模型
│   ├── network/           # 网络层
│   ├── routes/            # 应用路由
│   ├── services/          # 业务服务
│   ├── storage/           # 本地存储
│   └── theme/             # 主题配置
├── test/                  # 测试文件
└── assets/                # 图片、字体等资源
```

---

## 🧪 测试

运行测试套件：

```bash
# 运行所有测试
flutter test

# 运行并生成覆盖率报告
flutter test --coverage

# 运行特定测试文件
flutter test test/unit/models/query_history_item_test.dart
```

更多详情请查看 [TESTING.md](TESTING.md)。

---

## 🤝 贡献

欢迎贡献代码！如果您有兴趣参与：

1. **Fork 本仓库**
2. **创建功能分支** (`git checkout -b feature/amazing-feature`)
3. **提交更改** (`git commit -m '添加某个很棒的功能'`)
4. **推送到分支** (`git push origin feature/amazing-feature`)
5. **开启 Pull Request**

### 贡献方向

- 🐛 修复 Bug
- ✨ 新功能
- 📝 文档改进
- 🎨 UI/UX 增强
- 🌍 添加更多语言支持
- 🔧 集成更多翻译服务

如果您有想法或建议，请开启 Issue 进行讨论！

---

## 📝 许可证

本项目采用 MIT 许可证 - 详情请查看 [LICENSE](LICENSE) 文件。

---

## 🙏 致谢

- 感谢所有翻译服务提供商
- 感谢 Flutter 社区
- 感谢所有贡献者和用户

---

## 📧 联系方式

- **问题反馈**: [GitHub Issues](https://github.com/jeremy-jm/lando/issues)
- **讨论**: [GitHub Discussions](https://github.com/jeremy-jm/lando/discussions)

---

<div align="center">
  使用 ❤️ 和 Flutter 构建
</div>
