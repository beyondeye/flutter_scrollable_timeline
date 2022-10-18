import 'package:flutter/widgets.dart';

abstract class IScrollableTimelineDraggingState {
  abstract bool isDragging;
}

class NonSharedDraggingState  implements IScrollableTimelineDraggingState {
  NonSharedDraggingState();
  @override
  bool isDragging=false;
}

// see https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
class ScrollableTimelineSharedDragging extends InheritedWidget implements IScrollableTimelineDraggingState {
  ScrollableTimelineSharedDragging({
    super.key,
    required super.child,
  });

  @override
  bool isDragging= false;

  static ScrollableTimelineSharedDragging? of(BuildContext context) {
    final ScrollableTimelineSharedDragging? result = context.dependOnInheritedWidgetOfExactType<ScrollableTimelineSharedDragging>();
//    assert(result != null, 'No ScrollableTimelineDraggingState found in context');
    return result;
  }
  @override
  bool updateShouldNotify(ScrollableTimelineSharedDragging old) => isDragging != old.isDragging;


}
