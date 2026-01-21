import 'package:flutter/material.dart';

import 'package:lando/services/analytics/analytics_service.dart';

/// A navigator observer that reports page durations to Umeng.
///
/// It keeps a simple in-memory stack of page names and ensures:
/// - when a new page is pushed, previous page ends, new page starts
/// - when a page is popped, that page ends, previous page starts again
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver._();

  static final AnalyticsNavigatorObserver instance =
      AnalyticsNavigatorObserver._();

  final List<String> _pageStack = <String>[];

  String _routeName(Route<dynamic> route) {
    // Prefer explicit route settings name; fall back to runtimeType.
    final name = route.settings.name;
    if (name != null && name.trim().isNotEmpty) return name;
    return route.runtimeType.toString();
  }

  void _start(String page) {
    AnalyticsService.instance.pageStart(page);
  }

  void _end(String page) {
    AnalyticsService.instance.pageEnd(page);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is! PageRoute) return;

    final next = _routeName(route);
    final prev = _pageStack.isNotEmpty ? _pageStack.last : null;
    if (prev != null) _end(prev);

    _pageStack.add(next);
    _start(next);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is! PageRoute) return;

    final popped = _routeName(route);
    if (_pageStack.isNotEmpty && _pageStack.last == popped) {
      _pageStack.removeLast();
    } else {
      _pageStack.remove(popped);
    }
    _end(popped);

    if (previousRoute is PageRoute) {
      final prev = _routeName(previousRoute);
      // Only restart if it's actually on stack top or stack is empty.
      if (_pageStack.isNotEmpty && _pageStack.last != prev) {
        // Keep stack consistent.
        _pageStack.add(prev);
      }
      _start(prev);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute is PageRoute) {
      final oldName = _routeName(oldRoute);
      if (_pageStack.isNotEmpty && _pageStack.last == oldName) {
        _pageStack.removeLast();
      } else {
        _pageStack.remove(oldName);
      }
      _end(oldName);
    }

    if (newRoute is PageRoute) {
      final newName = _routeName(newRoute);
      _pageStack.add(newName);
      _start(newName);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is! PageRoute) return;

    final name = _routeName(route);
    final wasTop = _pageStack.isNotEmpty && _pageStack.last == name;
    _pageStack.remove(name);

    // Only end if it was the visible/top page.
    if (wasTop) {
      _end(name);
      final prev = _pageStack.isNotEmpty ? _pageStack.last : null;
      if (prev != null) _start(prev);
    }
  }
}

