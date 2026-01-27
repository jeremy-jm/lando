# Lando 测试套件

本目录包含 Lando 应用的所有单元测试和 Widget 测试。

## 测试结构

```
test/
├── unit/                    # 单元测试
│   ├── models/             # 模型测试
│   │   ├── query_history_item_test.dart
│   │   └── youdao_suggestion_test.dart
│   ├── providers/          # Provider 测试
│   │   └── query_history_provider_test.dart
│   ├── storage/            # 存储层测试
│   │   ├── preferences_storage_test.dart
│   │   ├── query_history_storage_test.dart
│   │   └── favorites_storage_test.dart
│   ├── bloc/               # BLoC 测试
│   │   └── query_bloc_test.dart
│   ├── repository/         # Repository 测试
│   │   └── query_repository_test.dart
│   └── services/           # 服务层测试
│       ├── youdao_suggestion_service_test.dart
│       └── api_client_test.dart
├── widget/                  # Widget 测试
│   ├── home/               # 首页测试
│   │   └── home_page_test.dart
│   └── widgets/           # Widget 组件测试
│       └── translation_input_widget_test.dart
└── widget_test.dart        # 主测试文件（运行所有测试）
```

## 运行测试

### 运行所有测试
```bash
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
```

## 测试覆盖范围

### 单元测试
- ✅ 模型类（QueryHistoryItem, YoudaoSuggestion）
- ✅ 存储服务（PreferencesStorage, QueryHistoryStorage, FavoritesStorage）
- ✅ 业务逻辑（QueryBloc, QueryRepository, QueryHistoryProvider）
- ✅ 服务层（YoudaoSuggestionService, ApiClient）

### Widget 测试
- ✅ 首页组件（MyHomePage）
- ✅ 翻译输入组件（TranslationInputWidget）

## 测试最佳实践

1. **独立性**: 每个测试应该是独立的，不依赖其他测试的执行顺序
2. **可重复性**: 测试应该能够在任何环境下重复运行并得到相同结果
3. **快速执行**: 单元测试应该快速执行，避免长时间等待
4. **清晰命名**: 测试名称应该清楚地描述测试的内容
5. **Mock 依赖**: 使用 Mock 对象隔离被测试的代码

## 添加新测试

当添加新功能时，请确保：

1. 为新功能编写相应的单元测试
2. 为新 Widget 编写 Widget 测试
3. 确保测试覆盖率达到项目要求
4. 所有测试都能通过

## 注意事项

- 测试使用 `SharedPreferences.setMockInitialValues({})` 来模拟存储
- Widget 测试需要提供必要的本地化支持
- 某些测试可能需要网络请求，使用 Mock 对象来避免实际网络调用
