import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lando/features/home/query/query_repository.dart';

/// Events for [HomeBloc].
sealed class HomeEvent {
  const HomeEvent();
}

/// Triggered when the user has finished entering text and wants to search.
class HomeSearchSubmitted extends HomeEvent {
  const HomeSearchSubmitted(this.query);

  final String query;
}

/// States for [HomeBloc].
@immutable
class HomeState {
  const HomeState({
    this.query = '',
    this.isLoading = false,
    this.result = '',
    this.errorMessage,
  });

  final String query;
  final bool isLoading;
  final String result;
  final String? errorMessage;

  HomeState copyWith({
    String? query,
    bool? isLoading,
    String? result,
    String? errorMessage,
  }) {
    return HomeState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

/// A very lightweight Bloc-like class without external dependencies.
///
/// It exposes a [state] stream and accepts [HomeEvent]s via [add].
class HomeBloc {
  HomeBloc(this._repository) {
    _eventSubscription = _eventController.stream.listen(_handleEvent);
  }

  final QueryRepository _repository;

  final _stateController = StreamController<HomeState>.broadcast();
  final _eventController = StreamController<HomeEvent>();

  late final StreamSubscription<HomeEvent> _eventSubscription;

  HomeState _state = const HomeState();

  HomeState get state => _state;

  Stream<HomeState> get stream => _stateController.stream;

  void add(HomeEvent event) {
    _eventController.add(event);
  }

  void _emit(HomeState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> _handleEvent(HomeEvent event) async {
    if (event is HomeSearchSubmitted) {
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
