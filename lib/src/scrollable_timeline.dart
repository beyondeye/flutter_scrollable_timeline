import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'dragging_state_provider.dart';
import 'timeline_scrollbehavior.dart';
import 'iscrollable_timeline.dart';
import 'timeline_item_data.dart';
import 'timeline_item.dart';

// see https://stackoverflow.com/questions/69960331/constant-constructor-and-function-in-dart
// anonymous function cannot be const in dart
void _stub(double t) {}

/// A draggable, scrollable, Timeline showing minutes and seconds optionally
/// synchronized with a [timeStream]
///
/// [onDragStart] : callback when the user start dragging the timeline, called
/// with the current time value when dragging started. When in the
/// dragging state, updates from [timeStream] are ignored
///
/// [onDragEnd] : callback when the user stops dragging the timeline, called with
/// the selected time value when dragging ended.
///
/// [lengthSecs] : the total number of seconds shown in the timeline
///
/// [stepSecs] : the time step to use between items in the timeline
///
/// [timeStream] : an optional stream of time values. when a value is received
/// the timeline is scrolled to the received time value.
///
/// [rulerOutsidePadding] : outside padding of the the "|" ruler marks: top for
/// the top ruler marks, and bottom for the bottom ruler marks
///
/// [rulerInsidePadding] : inside padding of the the "|" ruler marks: bottom for
/// the top ruler marks and top for the bottom ruler marks
///
/// [rulerSize] : size of the top and bottom "|" ruler marks
///
/// [showCursor] true if the central cursor indicating the current selected time
/// should be shown
///
/// [cursorColor] : color for the central cursor indicating the current selected time
///
/// [activeItemTextColor] : not currently used
///
/// [itemTextColor] : text color for minutes and seconds texts in the time line
///
/// [itemExtent] : width of each time mark item (with text of minutes and seconds)
///
/// [showMinutes] : true if both minutes and seconds should be shown in each time mark
///
/// [shownSecsMultiples] : number of seconds between shown seconds marks (1 by default)
///
/// [backgroundColor] : the background color of the timeline
///
/// [nPadItems]  are empty items put at the beginning and end of real time items.
/// They are needed in order to allow to scroll to very beginning time
/// and very end time items, since the indicator is positioned in the
/// center. the value of required pad items is  <= 0.5*(widget width)/(itemExtent)
/// the default value should be ok for all screens and platforms
class ScrollableTimeline extends StatefulWidget implements IScrollableTimeLine {
  final int lengthSecs;
  final int stepSecs;
  final Stream<double>? timeStream;
  final Function(double) onDragStart;
  final Function(double) onDragEnd;
  final double height;
  final double rulerOutsidePadding;
  final double rulerSize;
  final double rulerInsidePadding;
  final Color backgroundColor;
  final bool showCursor;
  final bool showMinutes;
  // if not 1 then print actual number for seconds only they are an integer multiple of shownSecsMultiples
  final int shownSecsMultiples;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color itemTextColor;
  final int itemExtent; //width in pix of each item
  final double pixPerSecs;
  final int nPadItems;
  final double divisions;
  const ScrollableTimeline(
      {required this.lengthSecs,
      required this.stepSecs,
      this.timeStream,
      this.onDragStart = _stub,
      this.onDragEnd = _stub,
      required this.height,
      this.rulerOutsidePadding = 10,
      this.rulerSize = 8,
      this.rulerInsidePadding = 5,
      //TODO currently this default value is set to a very high value, that is appropriate for even full window full width timeline on web platform
      //     but is actually an overkill. I should define this using mediaquery https://api.flutter.dev/flutter/widgets/MediaQuery-class.html
      //     But since I am using ListView.builder with itemBuilder, it is probably OK to leave the code as it is
      //  TODO: wait for when widget width is available (see for https://github.com/ayham95/Measured-Size/blob/main/lib/measured_size.dart)
      //  and automatically define the required number of pad items
      this.nPadItems = 50,
      this.backgroundColor = Colors.white,
      this.showCursor = true,
      this.showMinutes = true,
      this.shownSecsMultiples = 1,
      this.cursorColor = Colors.red,
      this.activeItemTextColor = Colors.blue,
      this.itemTextColor = Colors.grey,
      this.itemExtent = 60})
      : assert(stepSecs > 0),
        assert(lengthSecs > stepSecs),
        assert(rulerSize >= 8,
            "rulerSize smaller than 8 will cause graphic glitches"),
        pixPerSecs = itemExtent / stepSecs,
        divisions = (lengthSecs / stepSecs) + 1;

  @override
  _ScrollableTimelineState createState() => _ScrollableTimelineState();
}

class _ScrollableTimelineState extends State<ScrollableTimeline> {
  late ScrollController _scrollController;
  late IScrollableTimelineDraggingState draggingState;
  StreamSubscription<double>? timeStreamSub;

  @override
  void initState() {
    super.initState();
    //print("*FLT* initState called");
    // if isDragging then ignore stream updates about current playing time
    // by default dragging state is local to this widget (non shared)
    draggingState = NonSharedDraggingState();
    setScrollController();
    //important: set timeStreamSub after setting up scrollController
    timeStreamSub = widget.timeStream?.listen((t) {
      if (draggingState.isDragging) {
        // print("dragging");
        return; //ignore time update if dragging
      }
      // print("not dragging");
      final tClamped = t.clamp(0.0, widget.lengthSecs.toDouble());
      _scrollController.jumpTo(timeToScrollOffset(tClamped));
    });
  }

  double timeToScrollOffset(double t) {
    double w = context.size?.width ?? 0.0;
    return t * widget.pixPerSecs -
        (w / 2 - widget.itemExtent * (0.5 + widget.nPadItems));
  }

  double scrollOffsetToTime(double offset) {
    double w = context.size?.width ?? 0.0;
    return (offset + (w / 2 - widget.itemExtent * (0.5 + widget.nPadItems))) /
        widget.pixPerSecs;
  }

  @override
  void dispose() {
    super.dispose();
    timeStreamSub?.cancel();
  }

  void setScrollController() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    //the following is not needed: we listern from timeStream instead
//    _scrollController.jumpTo(value);
  }

  //------------------------------------------------------------
  Widget _gestureConfiguration(BuildContext context, {required Widget child}) {
    return GestureDetector(

        // we track  down event, not start, because start event is not sent immediately
        // we track longpress event and not drag or pan because for some reason that events
        // are cancelled when scroll is detected in the enclosed widget
        onLongPressDown: (details) {
          //print("*FLT* long press down");
          draggingState.isDragging = true;
        },
        onLongPressCancel: () {
          //print ("*flt* long press cancel");
          draggingState.isDragging = false;
        },
        onLongPressEnd: (details) {
          //print ("*flt* long press end");
          draggingState.isDragging = false;
        },
        child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // I need to add some empty items at the beginning and compensate for them
              // if this scroll is not user generated ignore the notification
              if (!draggingState.isDragging)
                return false; //allow scroll notification to bubble up
              // final tick = widget.pixPerSecs;
              if (scrollNotification is ScrollStartNotification) {
                //print("*SCR* Scroll Start ${_scrollController.offset / tick}");
                this
                    .widget
                    .onDragStart(_scrollController.offset / widget.pixPerSecs);
//          } else if (scrollNotification is ScrollUpdateNotification) {
//            print("*FLT* Scroll Update ${_scrollController.offset / tick}");
              } else if (scrollNotification is ScrollEndNotification) {
//              print("*SCR* scroll offs: ${_scrollController.offset}");
//              print("*SCR* shown items: ${shown_items}");
                //print("*SCR* Scroll End ${_scrollController.offset / tick}");
                double t = scrollOffsetToTime(_scrollController.offset);
                var isClipped = false;
                if (t < 0) {
                  t = 0;
                  isClipped = true;
                }
                if (t > widget.lengthSecs) {
                  t = widget.lengthSecs.toDouble();
                  isClipped = true;
                }
                //TODO the following code forcing back _scrollController to
                // a valid position is not always necessary because _scrollController
                // itself is driven by the current time and if the clippedT is feed
                // back in widget.timeStream, then the clipping will happen automatically
                if (isClipped) {
                  final clippedT = timeToScrollOffset(t);
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    //the following line will cause stack overflow exception if run directly in onNotification() callback
                    _scrollController.jumpTo(clippedT);
                  });
                }
                this.widget.onDragEnd(t);
                //print ("*flt* drag end");
                draggingState.isDragging =
                    false; //this is not redundant:  onLongPressEnd is not always detected
              }
              return false; // allow scroll notification to bubble up (important: otherwise pan gesture is not recognized)
            },
            child: child));
  }

  //------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    ScrollableTimelineSharedDragging? sharedDragging =
        ScrollableTimelineSharedDragging.of(context);
    if (sharedDragging != null) {
      draggingState = sharedDragging;
    }

    return _gestureConfiguration(context,
        // see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag#setting-a-custom-scrollbehavior-for-a-specific-widget
        child: ScrollConfiguration(
            behavior: TimelineScrollBehavior(), child: _timeLineBody()));
  }

  //------------------------------------------------------------
  TimelineItem _itemBuilder(BuildContext buildContext, int index) {
    TimelineItemData itemData;
    if (index < widget.nPadItems ||
        index >= widget.nPadItems + widget.divisions) {
      itemData = TimelineItemData(
          t: 0,
          tMins: 0,
          tSecs: 0,
          color: widget.backgroundColor,
          fontSize: 14);
    } else {
      int i = index - widget.nPadItems;
      int t = i * widget.stepSecs;
      final secs = t % 60;

      final shownSecs = (secs % widget.shownSecsMultiples == 0) ? secs : null;
      int? mins;
      if (widget.showMinutes) {
        mins = (t / 60).floor();
      }
      itemData = TimelineItemData(
          t: t,
          tMins: mins,
          tSecs: shownSecs,
          color: widget.itemTextColor,
          fontSize: 14.0);
    }
    return TimelineItem(itemData, widget.backgroundColor,
        widget.rulerOutsidePadding, widget.rulerSize, widget.rulerInsidePadding,
        //IMPORTANT: need to specify the key because otherwise, if timeline is updated, the updated TimelineItem object will not be recognized
        //see https://docs.flutter.dev/development/ui/widgets-intro#keys
        //see https://api.flutter.dev/flutter/foundation/Key-class.html
        //see https://www.youtube.com/watch?v=kn0EOS-ZiIc
        key: UniqueKey()); //TODO I could use ObjectKey(itemData) instead
  }

  //------------------------------------------------------------
  // the actual timeline ui
  Container _timeLineBody() {
    return Container(
        //important: if padding is changed, then need to review scrollOffsetToTime() and
        padding: const EdgeInsets.all(0),
        height: widget.height,
        alignment: Alignment.center,
        color: widget.backgroundColor,
        //see https://stackoverflow.com/questions/58863899/scroll-finishing-callback-in-flutter
        child: Stack(
          // use a stack here in order to show the (optional) cursor on top of the scrollview
          children: <Widget>[
            ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    // the size in pixel of each item in the scale
                    itemExtent: widget.itemExtent.toDouble(),
                    itemCount: widget.divisions.ceil() + 2 * widget.nPadItems,
                    itemBuilder: _itemBuilder)
                .build(context),
            indicatorWidget(widget)
          ],
        ));
  }
}
