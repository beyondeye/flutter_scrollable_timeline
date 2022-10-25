import 'dart:ui';

import 'package:flutter/material.dart';

/// [TimelineScrollBehavior]  is needed for making a ScrollView scrollable with mouse.
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag
class TimelineScrollBehavior extends MaterialScrollBehavior {
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
