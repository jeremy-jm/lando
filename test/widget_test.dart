// Main test file - runs all tests
//
// This file serves as the entry point for running all tests in the project.
// Individual test files are organized in test/unit/ and test/widget/ directories.
//
// To run all tests: flutter test
// To run specific test: flutter test test/unit/models/query_history_item_test.dart

import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/models/query_history_item_test.dart' as query_history_item_test;
import 'unit/models/youdao_suggestion_test.dart' as youdao_suggestion_test;
import 'unit/providers/query_history_provider_test.dart' as query_history_provider_test;
import 'unit/storage/preferences_storage_test.dart' as preferences_storage_test;
import 'unit/storage/query_history_storage_test.dart' as query_history_storage_test;
import 'unit/storage/favorites_storage_test.dart' as favorites_storage_test;
import 'unit/bloc/query_bloc_test.dart' as query_bloc_test;
import 'unit/repository/query_repository_test.dart' as query_repository_test;
import 'unit/services/youdao_suggestion_service_test.dart' as youdao_suggestion_service_test;
import 'unit/services/api_client_test.dart' as api_client_test;
import 'widget/home/home_page_test.dart' as home_page_test;
import 'widget/query/query_page_test.dart' as query_page_test;
import 'widget/widgets/translation_input_widget_test.dart' as translation_input_widget_test;
import 'widget/widgets/language_selector_widget_test.dart' as language_selector_widget_test;

void main() {
  // Run all test suites
  query_history_item_test.main();
  youdao_suggestion_test.main();
  query_history_provider_test.main();
  preferences_storage_test.main();
  query_history_storage_test.main();
  favorites_storage_test.main();
  query_bloc_test.main();
  query_repository_test.main();
  youdao_suggestion_service_test.main();
  api_client_test.main();
  home_page_test.main();
  query_page_test.main();
  translation_input_widget_test.main();
  language_selector_widget_test.main();
}
