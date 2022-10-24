import 'dart:ui';

/// data for defining each of timeline elements
class TimelineItemData {
  // total time in seconds
  int t;
  /// the "minutes" part of the time: if null don't show it
  int? tMins;
  /// the "seconds" part of the time: if null show "|" instead
  int? tSecs;
  /// text color to use for "minutes" and "seconds" text
  Color color;
  /// font size to use for "minutes" and "seconds" text: note that this
  /// size is currently mostly meaningless because we are wrapping the text with FittedBox
  double fontSize;
  TimelineItemData({required this.t, required this.tMins, required this.tSecs, required this.color, required this.fontSize});
}