/// Query history provider for managing navigation history within a session.
///
/// This manages forward/backward navigation similar to browser history.
/// History is session-based and not persisted across app restarts.
class QueryHistoryProvider {
  QueryHistoryProvider();

  final List<String> _history = [];
  int _currentIndex = -1;

  /// Gets the current query in history.
  String? get currentQuery {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// Checks if backward navigation is possible.
  bool get canGoBack => _currentIndex > 0;

  /// Checks if forward navigation is possible.
  bool get canGoForward => _currentIndex >= 0 && _currentIndex < _history.length - 1;

  /// Adds a new query to history.
  ///
  /// If the current position is not at the end, removes all forward history
  /// (similar to browser behavior when navigating to a new page).
  void addQuery(String query) {
    if (query.trim().isEmpty) {
      return;
    }

    final trimmedQuery = query.trim();

    // If we're not at the end of history, remove forward history
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Don't add if it's the same as the current query
    if (_currentIndex >= 0 && _history[_currentIndex] == trimmedQuery) {
      return;
    }

    _history.add(trimmedQuery);
    _currentIndex = _history.length - 1;
  }

  /// Navigates backward in history.
  ///
  /// Returns the previous query, or null if cannot go back.
  String? goBack() {
    if (!canGoBack) {
      return null;
    }
    _currentIndex--;
    return currentQuery;
  }

  /// Navigates forward in history.
  ///
  /// Returns the next query, or null if cannot go forward.
  String? goForward() {
    if (!canGoForward) {
      return null;
    }
    _currentIndex++;
    return currentQuery;
  }

  /// Checks if the given query is the current query in history.
  bool isCurrentQuery(String query) {
    return currentQuery == query.trim();
  }

  /// Clears all history.
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// Gets the total number of queries in history.
  int get historyLength => _history.length;
}
