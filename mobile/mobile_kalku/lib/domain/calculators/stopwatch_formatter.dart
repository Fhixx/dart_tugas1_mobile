/// Formats elapsed stopwatch time as `HH:MM:SS.CS`, each unit padded to
/// at least 2 digits, per COMPUTATION_LOGIC.md #11.
///
/// Pure function — takes elapsed milliseconds from a monotonic source
/// (Dart `Stopwatch`), never accumulates its own counter from timer ticks.
String formatElapsedTime(int elapsedMilliseconds) {
  final hours = elapsedMilliseconds ~/ 3600000;
  final minutes = (elapsedMilliseconds ~/ 60000) % 60;
  final seconds = (elapsedMilliseconds ~/ 1000) % 60;
  final centiseconds = (elapsedMilliseconds ~/ 10) % 100;

  String pad2(int value) => value.toString().padLeft(2, '0');

  return '${pad2(hours)}:${pad2(minutes)}:${pad2(seconds)}.${pad2(centiseconds)}';
}
