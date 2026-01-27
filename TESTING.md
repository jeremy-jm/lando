# Lando 测试文档

本文档描述了 Lando 应用的测试套件。

## 测试覆盖范围

### ✅ 已完成的测试

#### 单元测试 (Unit Tests)

1. **模型测试 (Models)**
   - ✅ `QueryHistoryItem` - 查询历史项模型测试
   - ✅ `YoudaoSuggestion` - 有道建议模型测试

2. **存储层测试 (Storage)**
   - ✅ `PreferencesStorage` - 用户偏好设置存储测试
   - ✅ `QueryHistoryStorage` - 查询历史存储测试
   - ✅ `FavoritesStorage` - 收藏存储测试

3. **业务逻辑测试 (Business Logic)**
   - ✅ `QueryBloc` - 查询状态管理测试
   - ✅ `QueryRepository` - 查询仓库测试
   - ✅ `QueryHistoryProvider` - 查询历史提供者测试

4. **服务层测试 (Services)**
   - ✅ `YoudaoSuggestionService` - 有道建议服务测试
   - ✅ `ApiClient` - API客户端测试

#### Widget 测试 (Widget Tests)

1. **页面测试 (Pages)**
   - ✅ `MyHomePage` - 首页测试
   - ✅ `QueryPage` - 查询页面测试

2. **组件测试 (Widgets)**
   - ✅ `TranslationInputWidget` - 翻译输入组件测试
   - ✅ `LanguageSelectorWidget` - 语言选择器测试

## 测试统计

- **单元测试文件**: 10 个
- **Widget 测试文件**: 4 个
- **总测试用例**: 100+ 个

## 运行测试

### 运行所有测试
```bash
cd lando
flutter test
```

### 运行特定测试文件
```bash
flutter test test/unit/models/query_history_item_test.dart
```

### 运行特定测试组
```bash
flutter test --name "QueryHistoryItem"
```

### 生成测试覆盖率报告
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 测试文件结构

```
test/
├── unit/                           # 单元测试
│   ├── models/                     # 模型测试
│   │   ├── query_history_item_test.dart
│   │   └── youdao_suggestion_test.dart
│   ├── providers/                  # Provider 测试
│   │   └── query_history_provider_test.dart
│   ├── storage/                    # 存储层测试
│   │   ├── preferences_storage_test.dart
│   │   ├── query_history_storage_test.dart
│   │   └── favorites_storage_test.dart
│   ├── bloc/                       # BLoC 测试
│   │   └── query_bloc_test.dart
│   ├── repository/                 # Repository 测试
│   │   └── query_repository_test.dart
│   └── services/                   # 服务层测试
│       ├── youdao_suggestion_service_test.dart
│       └── api_client_test.dart
├── widget/                         # Widget 测试
│   ├── home/                       # 首页测试
│   │   └── home_page_test.dart
│   ├── query/                      # 查询页面测试
│   │   └── query_page_test.dart
│   └── widgets/                    # Widget 组件测试
│       ├── translation_input_widget_test.dart
│       └── language_selector_widget_test.dart
├── widget_test.dart                # 主测试文件
└── README.md                       # 测试说明文档
```

## 测试最佳实践

### 1. 测试独立性
每个测试都是独立的，不依赖其他测试的执行顺序。

### 2. Mock 对象
- 使用 Mock 对象隔离被测试的代码
- 避免实际网络请求和文件系统操作
- 使用 `SharedPreferences.setMockInitialValues({})` 模拟存储

### 3. 测试命名
测试名称应该清楚地描述测试的内容：
- ✅ `should save and get theme mode`
- ❌ `test1`

### 4. 测试组织
使用 `group()` 来组织相关的测试：
```dart
group('QueryHistoryProvider', () {
  test('should add query to history', () {
    // ...
  });
  
  test('should navigate backward', () {
    // ...
  });
});
```

### 5. 断言清晰
使用清晰的断言和错误消息：
```dart
expect(result, isNotNull);
expect(result.length, 2);
expect(result[0].word, 'hello');
```

## 持续集成

测试可以在 CI/CD 流程中自动运行：

```yaml
# 示例 GitHub Actions 配置
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    file: coverage/lcov.info
```

## 注意事项

1. **平台特定代码**: 某些测试可能需要平台特定的设置（如桌面平台的窗口管理）
2. **异步操作**: 使用 `await tester.pumpAndSettle()` 等待异步操作完成
3. **本地化**: Widget 测试需要提供本地化支持
4. **资源文件**: 某些测试可能需要资源文件（如图片），确保在测试环境中可用

## 未来改进

- [ ] 添加集成测试
- [ ] 增加测试覆盖率到 90%+
- [ ] 添加性能测试
- [ ] 添加可访问性测试
- [ ] 添加端到端测试

## 贡献指南

添加新功能时，请确保：

1. ✅ 为新功能编写相应的单元测试
2. ✅ 为新 Widget 编写 Widget 测试
3. ✅ 确保所有测试都能通过
4. ✅ 更新本文档

## 问题反馈

如果遇到测试相关问题，请：
1. 检查测试文件是否有语法错误
2. 确保所有依赖都已安装
3. 查看测试输出中的错误信息
4. 在项目 Issues 中报告问题
