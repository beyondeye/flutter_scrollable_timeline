import 'package:flutter/widgets.dart';

abstract class IScrollableTimelineDraggingState {
  abstract bool isDragging;
  abstract int draggingId;
}

/// internal class used in [ScrollableTimeline] when its dragging state is
/// not shared with other timelines (the default situation)
class NonSharedDraggingState implements IScrollableTimelineDraggingState {
  NonSharedDraggingState();
  @override
  bool isDragging = false;
  /// identityHashCode of the widget that is driving the dragging
  int draggingId=0;
}

/// a widget that provides a shared [isDragging] state to children
/// [ScrollableTimeline]
/// widgets, so that they will all stop reacting to external time streams as soon
/// as any of them is dragged.
///
/// see https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
class ScrollableTimelineSharedDragging extends InheritedWidget
    implements IScrollableTimelineDraggingState {
  ScrollableTimelineSharedDragging({
    super.key,
    required super.child,
  });

  @override
  bool isDragging = false;
  int  draggingId =0;

  static ScrollableTimelineSharedDragging? of(BuildContext context) {
    final ScrollableTimelineSharedDragging? result = context
        .dependOnInheritedWidgetOfExactType<ScrollableTimelineSharedDragging>();
//    assert(result != null, 'No ScrollableTimelineDraggingState found in context');
    return result;
  }

  @override
  bool updateShouldNotify(ScrollableTimelineSharedDragging old) =>
      (isDragging != old.isDragging) ||
      (draggingId != draggingId);
}
