import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dragging_state_provider.dart';
import 'timeline_scrollbehavior.dart';
import 'iscrollable_timeline.dart';
import 'timeline_item_data.dart';
import 'timeline_item_f.dart';


// see https://stackoverflow.com/questions/69960331/constant-constructor-and-function-in-dart
// anonymous function cannot be const in dart
void _stub(double t) {}

/// nPadItems are empty items put at the beginning and end of real time items
///        they are needed in order to allow to scroll to very beginning time
///        and very end time items that, since the indicator is positioned in the
///        center. the value of required pad items is  <= 0.5*(widget width)/(itemExtent)
///        TODO: wait for when widget width is available (see for https://github.com/ayham95/Measured-Size/blob/main/lib/measured_size.dart)
///              and automatically define the required number of pad items
class ScrollableTimelineF extends StatefulWidget  implements IScrollableTimeLine {
  final int lengthSecs;
  final int stepSecs;
  final Stream<double>? timeStream;
  final Function(double) onDragStart;
  final Function(double) onDragEnd;
  final double height;
  final double insideVertPadding;
  final Color backgroundColor;
  final bool showCursor;
  final bool showMinutes;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final int itemExtent; //width in pix of each item
  final double pixPerSecs;
  final int nPadItems;
  final int divisions;
  ScrollableTimelineF(
      {required this.lengthSecs,
      required this.stepSecs,
      this.timeStream,
      this.onDragStart = _stub,
      this.onDragEnd =_stub,
      required this.height,
      this.insideVertPadding=10,
      //TODO currently this default value is set to a very high value, that is appropriate for even full window full width timeline on web platform
      //     but is actually an overkill. I should define this using mediaquery https://api.flutter.dev/flutter/widgets/MediaQuery-class.html
      //     But since I am using ListView.builder with itemBuilder, it is probably OK to leave the code as it is
      this.nPadItems=50,
      this.backgroundColor = Colors.white,
      this.showCursor = true,
      this.showMinutes = true,
      this.cursorColor = Colors.red,
      this.activeItemTextColor = Colors.blue,
      this.passiveItemsTextColor = Colors.grey,
      this.itemExtent = 60
      })
      : assert(stepSecs > 0),
        assert(lengthSecs > stepSecs),
        pixPerSecs=itemExtent/stepSecs,
        divisions=(lengthSecs / stepSecs).ceil() + 1;

  @override
  _ScrollableTimelineFState createState() => _ScrollableTimelineFState();
}

class _ScrollableTimelineFState extends State<ScrollableTimelineF> {
  // Similar to a standard [ScrollController] but with the added convenience
  // mechanisms to read and go to item indices rather than a raw pixel scroll
  late ScrollController _scrollController;
  late IScrollableTimelineDraggingState draggingState;
  StreamSubscription<double>? timeStreamSub;

  @override
  void initState() {
    super.initState();
    //print("*FLT* initState called");
    // if isDragging then ignore stream updates about current playing time
    //by default dragging state is local to this widget (STD
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
    return t*widget.pixPerSecs - (w/2 - widget.itemExtent*(0.5+widget.nPadItems));
  }
  double scrollOffsetToTime(double offset) {
    double w = context.size?.width ?? 0.0;
    return (offset + (w/2 - widget.itemExtent*(0.5+widget.nPadItems)))/widget.pixPerSecs;
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
              //if this scroll is not user generated ignore the notification
              if(!draggingState.isDragging) return false; //allow scroll notification to bubble up
              //final tick = widget.pixPerSecs;
              if (scrollNotification is ScrollStartNotification) {
                //print("*SCR* Scroll Start ${_scrollController.offset / tick}");
                this.widget.onDragStart(_scrollController.offset / widget.pixPerSecs);
//          } else if (scrollNotification is ScrollUpdateNotification) {
//            print("*FLT* Scroll Update ${_scrollController.offset / tick}");
              } else if (scrollNotification is ScrollEndNotification) {
//              print("*SCR* scroll offs: ${_scrollController.offset}");
//              print("*SCR* shown items: ${shown_items}");
                //print("*SCR* Scroll End ${_scrollController.offset / tick}");
                double t=scrollOffsetToTime(_scrollController.offset);
                var isClipped=false;
                if(t<0) {
                  t = 0;
                  isClipped = true;
                }
                if(t>widget.lengthSecs) {
                  t=widget.lengthSecs.toDouble();
                  isClipped=true;
                }
                //TODO the following code forcing back _scrollController to
                // a valid position is not always necessary because _scrollController
                // itself is driven by the current time and if the clippedT is feed
                // back in widget.timeStream, then the clipping will happen automatically
                if(isClipped) {
                  final clippedT=timeToScrollOffset(t);
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    //the following line will cause stack overflow exception if run directly in onNotification() callback
                    _scrollController.jumpTo(clippedT);
                  });
                }
                this.widget.onDragEnd(t);
                //print ("*flt* drag end");
                draggingState.isDragging = false; //this is not redundant:  onLongPressEnd is not always detected
              }
              return false; // allow scroll notification to bubble up (important: otherwise pan gesture is not recognized)
            },
            child: child
        )
    );
  }
  //------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    ScrollableTimelineSharedDragging? sharedDragging=ScrollableTimelineSharedDragging.of(context);
    if(sharedDragging!=null) {
      draggingState=sharedDragging;
    }

    return _gestureConfiguration(context,
        // see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag#setting-a-custom-scrollbehavior-for-a-specific-widget
        child: ScrollConfiguration(
            behavior: TimelineScrollBehavior(),
            child: _timeLineBody()
        )
    );
  }

  //------------------------------------------------------------
  TimelineItemF _itemBuilder(BuildContext buildContext, int index) {
    TimelineItemData itemData;
    if(index<widget.nPadItems || index>=widget.nPadItems+widget.divisions) {
      itemData=TimelineItemData(t: 0, tMins: 0, tSecs: 0, color: widget.backgroundColor, fontSize: 14);
    } else {
      int i=index-widget.nPadItems;
      int t=i*widget.stepSecs;
      final secs = t % 60;
      int? mins;
      if(widget.showMinutes) {
        mins = (t / 60).floor();
      }
      itemData=TimelineItemData(t:t, tMins: mins, tSecs: secs, color: widget.passiveItemsTextColor, fontSize: 14.0);
    }
    return TimelineItemF(itemData, widget.backgroundColor,widget.insideVertPadding);
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
                    itemCount: widget.divisions+2*widget.nPadItems,
                    itemBuilder: _itemBuilder
               ).build(context),
              indicatorWidget(widget)
            ],
          ));
  }
}



