import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:lando/services/analytics/analytics_service.dart';

/// Captures taps/clicks globally without interfering with child gestures.
///
/// This uses raw pointer events (via hit test) to observe interactions even when
/// child widgets handle gestures themselves.
///
/// It reports a single Umeng event: `tap` with `{ page: <routeName> }`.
class AnalyticsTapCapture extends StatefulWidget {
  const AnalyticsTapCapture({super.key, required this.child});

  final Widget child;

  @override
  State<AnalyticsTapCapture> createState() => _AnalyticsTapCaptureState();
}

class _AnalyticsTapCaptureState extends State<AnalyticsTapCapture> {
  static const double _maxTapMovePx = 12.0;
  static const Duration _maxTapDuration = Duration(milliseconds: 700);

  final Map<int, Offset> _downPositions = <int, Offset>{};
  final Map<int, DateTime> _downTimes = <int, DateTime>{};

  String _currentPageName() {
    final route = ModalRoute.of(context);
    final name = route?.settings.name;
    if (name != null && name.trim().isNotEmpty) return name;
    return route?.runtimeType.toString() ?? 'unknown';
  }

  void _onPointerDown(PointerDownEvent e) {
    // Only count primary button for mouse; touch/stylus are fine.
    if (e.kind == PointerDeviceKind.mouse &&
        e.buttons != kPrimaryButton) {
      return;
    }
    _downPositions[e.pointer] = e.position;
    _downTimes[e.pointer] = DateTime.now();
  }

  void _onPointerUp(PointerUpEvent e) {
    final down = _downPositions.remove(e.pointer);
    final time = _downTimes.remove(e.pointer);
    if (down == null || time == null) return;

    final dt = DateTime.now().difference(time);
    if (dt > _maxTapDuration) return;

    final dx = e.position.dx - down.dx;
    final dy = e.position.dy - down.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist > _maxTapMovePx) return;

    // Fire-and-forget; Umeng aggregates counts.
    AnalyticsService.instance.event(
      'tap',
      properties: <String, dynamic>{
        'page': _currentPageName(),
      },
    );
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _downPositions.remove(e.pointer);
    _downTimes.remove(e.pointer);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}

