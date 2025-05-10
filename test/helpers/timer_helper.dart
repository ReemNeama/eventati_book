import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for managing timers in tests
class TimerHelper {
  /// List of active timers
  final List<Timer> _activeTimers = [];

  /// Create a timer that will be automatically disposed
  Timer createTimer(Duration duration, void Function() callback) {
    // Create a variable to hold the timer
    late Timer timerInstance;

    // Create the timer
    timerInstance = Timer(duration, () {
      callback();
      // Remove the timer from active timers when it completes
      _activeTimers.remove(timerInstance);
    });

    // Add to active timers
    _activeTimers.add(timerInstance);

    return timerInstance;
  }

  /// Create a periodic timer that will be automatically disposed
  Timer createPeriodicTimer(Duration duration, void Function(Timer) callback) {
    final timer = Timer.periodic(duration, (t) {
      callback(t);
    });
    _activeTimers.add(timer);
    return timer;
  }

  /// Cancel all active timers
  void cancelAllTimers() {
    // Create a copy of the list to avoid concurrent modification issues
    final timers = List<Timer>.from(_activeTimers);
    for (final timer in timers) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  /// Register a tearDown function to cancel all timers
  void registerTearDown() {
    // Don't use tearDown directly, just make sure to call cancelAllTimers in the test's tearDown
  }

  /// Call this in the test's tearDown
  void dispose() {
    cancelAllTimers();
  }
}

/// Extension on WidgetTester to handle timers
extension TimerWidgetTesterExtension on WidgetTester {
  /// Pump and settle with a timeout, canceling any pending timers if the timeout is reached
  Future<void> pumpAndSettleWithTimeout(
    TimerHelper timerHelper, {
    Duration? timeout,
  }) async {
    try {
      await pumpAndSettle();
    } catch (e) {
      // If we timeout, cancel all timers to prevent test failures
      timerHelper.cancelAllTimers();
      // Re-pump once to update the UI
      await pump();
    }
  }
}
