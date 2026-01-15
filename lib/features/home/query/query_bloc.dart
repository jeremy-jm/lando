import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lando/features/home/home_repository.dart';

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
  });

  final String query;
  final bool isLoading;
  final String result;
  final String? errorMessage;

  QueryState copyWith({
    String? query,
    bool? isLoading,
    String? result,
    String? errorMessage,
  }) {
    return QueryState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
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

  final HomeRepository _repository;

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
      _emit(_state.copyWith(query: query, isLoading: true, errorMessage: null));
      try {
        final result = await _repository.lookup(query);
        _emit(_state.copyWith(isLoading: false, result: result));
      } catch (e) {
        _emit(_state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  void dispose() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}
