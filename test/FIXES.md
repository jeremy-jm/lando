# 测试修复说明

本文档记录了测试套件中的修复内容。

## 修复的问题

### 1. ApiClient 测试
**问题**: 使用了错误的异常类型断言
**修复**: 
- 添加了 `dart:io` 的 `HttpException` 导入
- 将异常断言从 `isA<Exception>()` 改为 `isA<HttpException>()`
- 将同步测试改为异步测试（添加 `async/await`）

### 2. Widget 测试 - 存储初始化
**问题**: Widget 测试缺少必要的存储初始化
**修复**: 
- 在 `home_page_test.dart` 中添加了 `PreferencesStorage` 初始化
- 在 `query_page_test.dart` 中添加了 `PreferencesStorage` 初始化
- 在 `translation_input_widget_test.dart` 中添加了 `PreferencesStorage` 初始化
- 所有 Widget 测试现在都使用 `setUp` 和 `tearDown` 来管理存储状态

### 3. TranslationInputWidget 测试
**问题**: 某些测试期望的 UI 元素只在特定条件下显示（如需要 `detectedLanguage`）
**修复**:
- 修复了 `should display copy button` 测试，添加了 `detectedLanguage` 参数
- 修复了 `should copy text to clipboard` 测试，添加了 `detectedLanguage` 参数
- 修复了 `should display clear button` 测试，添加了 `detectedLanguage` 参数
- 修复了 `should clear text` 测试，添加了 `detectedLanguage` 参数

### 4. QueryPage 测试
**问题**: 异步操作需要更长的等待时间
**修复**:
- 在测试中添加了适当的 `pump` 和 `pumpAndSettle` 调用
- 增加了等待时间以允许异步操作完成（特别是初始查询的自动触发）

## 测试最佳实践

### 存储初始化
所有需要访问 `PreferencesStorage` 的测试都应该：

```dart
setUp(() async {
  SharedPreferences.setMockInitialValues({});
  await PreferencesStorage.init();
});

tearDown(() async {
  await PreferencesStorage.clearAll();
});
```

### 异步操作
对于包含异步操作的 Widget 测试：

```dart
await tester.pumpWidget(createTestWidget());
await tester.pump(); // 允许第一帧渲染
await tester.pump(const Duration(milliseconds: 100)); // 等待异步操作
await tester.pumpAndSettle(const Duration(seconds: 5)); // 等待所有动画和异步操作完成
```

### 异常处理
使用正确的异常类型：

```dart
// ✅ 正确
expect(() async => await client.getJson('url'), throwsA(isA<HttpException>()));

// ❌ 错误
expect(() => client.getJson('url'), throwsA(isA<Exception>()));
```

## 运行测试

修复后，运行所有测试：

```bash
flutter test
```

如果仍有测试失败，请检查：
1. 是否所有必要的依赖都已初始化
2. 异步操作是否有足够的等待时间
3. Mock 对象是否正确设置
4. 测试环境是否正确配置
