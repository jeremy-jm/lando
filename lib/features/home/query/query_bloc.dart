import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';

/// Events for [QueryBloc].
sealed class QueryEvent {
  const QueryEvent();
}

/// Triggered when the user has finished entering text and wants to search.
class QuerySearchSubmitted extends QueryEvent {
  const QuerySearchSubmitted(this.query);

  final String query;
}

/// States for [QueryBloc].
@immutable
class QueryState {
  const QueryState({
    this.query = '',
    this.isLoading = false,
    this.result = '',
    this.errorMessage,
    this.usPronunciationUrl,
    this.ukPronunciationUrl,
    this.youdaoResponse,
  });

  final String query;
  final bool isLoading;
  final String result;
  final String? errorMessage;
  final String? usPronunciationUrl;
  final String? ukPronunciationUrl;
  final YoudaoResponse? youdaoResponse;

  QueryState copyWith({
    String? query,
    bool? isLoading,
    String? result,
    String? errorMessage,
    String? usPronunciationUrl,
    String? ukPronunciationUrl,
    YoudaoResponse? youdaoResponse,
  }) {
    return QueryState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
      usPronunciationUrl: usPronunciationUrl,
      ukPronunciationUrl: ukPronunciationUrl,
      youdaoResponse: youdaoResponse,
    );
  }
}

/// A very lightweight Bloc-like class for query functionality.
///
/// It exposes a [state] stream and accepts [QueryEvent]s via [add].
class QueryBloc {
  QueryBloc(this._repository) {
    _eventSubscription = _eventController.stream.listen(_handleEvent);
  }

  final QueryRepository _repository;

  final _stateController = StreamController<QueryState>.broadcast();
  final _eventController = StreamController<QueryEvent>();

  late final StreamSubscription<QueryEvent> _eventSubscription;

  QueryState _state = const QueryState();

  QueryState get state => _state;

  Stream<QueryState> get stream => _stateController.stream;

  void add(QueryEvent event) {
    _eventController.add(event);
  }

  void _emit(QueryState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> _handleEvent(QueryEvent event) async {
    if (event is QuerySearchSubmitted) {
      final query = event.query;
      _emit(_state.copyWith(
        query: query,
        isLoading: true,
        result: '',
        errorMessage: null,
        usPronunciationUrl: null,
        ukPronunciationUrl: null,
        youdaoResponse: null,
      ));
      try {
        final result = await _repository.lookupWithPronunciation(query);
        _emit(_state.copyWith(
          isLoading: false,
          result: result['translation'] ?? '',
          usPronunciationUrl: result['usPronunciationUrl'] as String?,
          ukPronunciationUrl: result['ukPronunciationUrl'] as String?,
          youdaoResponse: result['youdaoResponse'] as YoudaoResponse?,
        ));
      } catch (e) {
        _emit(_state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void dispose() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}
