import 'dart:async';

import 'package:flutter/material.dart';
import 'iscrollable_timeline.dart';
import 'timeline_item_data.dart';
import 'timeline_item.dart';

// see https://stackoverflow.com/questions/69960331/constant-constructor-and-function-in-dart
// anonymous function cannot be const in dart
void _stub(double t) {}

class ScrollableTimeline extends StatefulWidget implements IScrollableTimeLine {
  final int lengthSecs;
  final int stepSecs;
  final Stream<double>? timeStream;
  final Function(double) onDragStart;
  final Function(double) onDragEnd;
  final double height;
  final double insideVertPadding;
  final Color backgroundColor;
  final bool showCursor;
  final bool showMins;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final int itemExtent; //width in pix of each item
  final double pixPerSecs;
  final Function(double) onItemSelected;

  ScrollableTimeline(
      {required this.lengthSecs,
      required this.stepSecs,
      this.timeStream,
      this.onItemSelected= _stub,
      this.onDragStart = _stub,
      this.onDragEnd =_stub,
      required this.height,
      this.insideVertPadding=10,
      this.backgroundColor = Colors.white,
      this.showCursor = true,
      this.showMins = true,
      this.cursorColor = Colors.red,
      this.activeItemTextColor = Colors.blue,
      this.passiveItemsTextColor = Colors.grey,
      this.itemExtent = 60})
      : assert(stepSecs > 0),
        assert(lengthSecs > stepSecs),
        pixPerSecs=itemExtent/stepSecs;

  @override
  _ScrollableTimelineState createState() => _ScrollableTimelineState();
}

class _ScrollableTimelineState extends State<ScrollableTimeline> {
  // Similar to a standard [ScrollController] but with the added convenience
  // mechanisms to read and go to item indices rather than a raw pixel scroll
  late FixedExtentScrollController _scrollController;
  late int curItem; //TODO: why late? make it instead nullable
  late double curTime; //TODO: why late? make it instead nullable
  List<TimelineItemData> itemDatas = [];
  bool isDragging=false;
  StreamSubscription<double>? timeStreamSub;

  @override
  void initState() {
    super.initState();
    isDragging=false; //if isDragging then ignore stream updates about current playing time
    final divisions = (widget.lengthSecs / widget.stepSecs).ceil() + 1;
    var t = 0;
    if(widget.showMins) {
      for (var i = 0; i <= divisions; i++) {
        final secs = t % 60;
        final mins = (t / 60).floor();
        itemDatas.add(TimelineItemData(t:t, tMins: mins, tSecs: secs, color: widget.passiveItemsTextColor, fontSize: 14.0));
        t += widget.stepSecs;
      }
    } else
    {
      for (var i = 0; i <= divisions; i++) {
        final secs = t % 60;
        itemDatas.add(TimelineItemData(t:t, tMins: null, tSecs: secs, color: widget.passiveItemsTextColor, fontSize: 14.0));
        t += widget.stepSecs;
      }
    }
    setScrollController();
    //important: set timeStreamSub after setting up scrollController
    timeStreamSub = widget.timeStream?.listen((t) {
      if(isDragging) return; //ignore time update if dragging
      final tClamped=t.clamp(0.0, widget.lengthSecs.toDouble());
      _scrollController.jumpTo(tClamped*widget.pixPerSecs);
    });
  }

  @override
  void dispose() {
    super.dispose();
    timeStreamSub?.cancel();
  }

  void setScrollController() {
    _scrollController = FixedExtentScrollController(initialItem: 0);
//    _scrollController.jumpTo(value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      // we track  down event, not start, because start event is not sent immediately
      // we track longpress event and not drag or pan because for some reason that events
      // are cancelled when scroll is detected in the enclosed widget
        onLongPressDown: (details) {
          //print("*FLT* long press down");
          isDragging = true;
        },
        onLongPressCancel: () {
          //print ("*flt* long press cancel");
          isDragging = false;
        },

        onLongPressEnd: (details) {
          //print ("*flt* long press end");
          isDragging = false;
        },

      child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            //if this scroll is not user generated ignore the notification
            if(!isDragging) return false; //allow scroll notification to bubble up
            final tick = widget.pixPerSecs;
            if (scrollNotification is ScrollStartNotification) {
              //print("*SCR* Scroll Start ${_scrollController.offset / tick}");
              this.widget.onDragStart(_scrollController.offset / tick);
//          } else if (scrollNotification is ScrollUpdateNotification) {
//            print("*FLT* Scroll Update ${_scrollController.offset / tick}");
            } else if (scrollNotification is ScrollEndNotification) {
              //print("*SCR* Scroll End ${_scrollController.offset / tick}");
              this.widget.onDragEnd(_scrollController.offset / tick);
              isDragging = false; //this is not redundant:  onLongPressEnd is not always detected
            }
            return false; // allow scroll notification to bubble up (important: otherwise pan gesture is not recognized)
          },
          child: timeLineBody()
      )
    );
  }

  //------------------------------------------------------------
  // the actual timeline ui
  Container timeLineBody() {
    return Container(
          padding: const EdgeInsets.all(8),
          height: widget.height,
          alignment: Alignment.center,
          color: widget.backgroundColor,
          //see https://stackoverflow.com/questions/58863899/scroll-finishing-callback-in-flutter
          child: Stack(
            // use a stack here in order to show the (optional) cursor on top of the scrollview
            children: <Widget>[
              RotatedBox(
                //needed to make ListWheelScrollView horizontal
                quarterTurns: 3,
                child: ListWheelScrollView(
                    controller: _scrollController,
                    // the size in pixel of each item in the scale
                    itemExtent: widget.itemExtent.toDouble(),
                    // magnification of center item
                    useMagnifier: false,
                    //  magnification of center item (not continuous)
                    magnification: 1.0,
                    // squeeze factor for item size (itemExtent) to show more items
                    squeeze: 1,
                    // default is 2.0 (the smaller it is the smallest is the wheel diameter (more compression at border
                    diameterRatio: 2,
                    // default is 0.003 (must be 0<p <0.01) (how farthest item in the circle are shown with reduced size
                    perspective: 0.001,

                    onSelectedItemChanged: (item) { //TODO: we actually don't need onSelectedItemChanged (we actually don't need ListWheelScrollView
                      curItem = item;
                      curTime = _scrollController.offset;
                      widget.onItemSelected((itemDatas[item].t).toDouble());
                    },
                    children: itemDatas.map((TimelineItemData curValue) {
                      return TimelineItem(curValue, widget.backgroundColor,widget.insideVertPadding);
                    }).toList()),
              ),
              indicatorWidget(widget)
            ],
          ));
  }
}
