import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/calculators/stopwatch_formatter.dart';

enum StopwatchStatus { idle, running, paused }

/// Controller for the Stopwatch feature.
///
/// Uses Dart's monotonic `Stopwatch` as the timing source
/// (COMPUTATION_LOGIC.md #11) — the periodic `Timer` here ONLY triggers a
/// UI refresh, it never adds elapsed time itself, so timer jitter/delay
/// cannot accumulate drift.
class StopwatchController extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  StopwatchStatus _status = StopwatchStatus.idle;

  StopwatchStatus get status => _status;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
  String get formattedElapsed => formatElapsedTime(elapsedMilliseconds);

  void start() {
    if (_status == StopwatchStatus.running) return;
    _stopwatch.start();
    _status = StopwatchStatus.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_status != StopwatchStatus.running) return;
    _stopwatch.stop();
    _status = StopwatchStatus.paused;
    _stopTicker();
    notifyListeners();
  }

  /// Alias of [start] for the "Continue" action from paused state — kept
  /// as a separate name for readability at call sites.
  void resume() => start();

  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _status = StopwatchStatus.idle;
    _stopTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    // Refresh-only ticker; ~30ms keeps the centisecond display smooth
    // without being wasteful.
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
