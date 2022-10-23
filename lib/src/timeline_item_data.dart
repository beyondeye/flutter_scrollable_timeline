import 'dart:ui';

class TimelineItemData {
  int t;
  /// if null don't show it
  int? tMins;
  /// if null show "|" instead
  int? tSecs;
  Color color;
  double fontSize;
  TimelineItemData({required this.t, required this.tMins, required this.tSecs, required this.color, required this.fontSize});
}