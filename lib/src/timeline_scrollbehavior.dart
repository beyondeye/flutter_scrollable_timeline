import 'dart:ui';

import 'package:flutter/material.dart';

//this is needed for making a ScrollView scrollable with mouse
// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag
class TimelineScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    // etc.
  };
}