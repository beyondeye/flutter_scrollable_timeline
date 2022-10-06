import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'timeline_item_data.dart';
import 'timeline_item_f.dart';


// see https://stackoverflow.com/questions/69960331/constant-constructor-and-function-in-dart
// anonymous function cannot be const in dart
void _stub(double t) {}

class ScrollableTimelineF extends StatefulWidget {
  final int lengthSecs;
  final int stepSecs;
  final Stream<double>? timeStream;
  final Function(double) onDragStart;
  final Function(double) onDragEnd;
  final double height;
  final Color backgroundColor;
  final bool showCursor;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final int itemExtent; //width in pix of each item
  final double pixPerSecs;

  ScrollableTimelineF(
      {required this.lengthSecs,
      required this.stepSecs,
      this.timeStream,
      this.onDragStart = _stub,
      this.onDragEnd =_stub,
      required this.height,
      this.backgroundColor = Colors.white,
      this.showCursor = true,
      this.cursorColor = Colors.red,
      this.activeItemTextColor = Colors.blue,
      this.passiveItemsTextColor = Colors.grey,
      this.itemExtent = 60})
      : assert(stepSecs > 0),
        assert(lengthSecs > stepSecs),
        pixPerSecs=itemExtent/stepSecs;

  @override
  _ScrollableTimelineFState createState() => _ScrollableTimelineFState();
}

class _ScrollableTimelineFState extends State<ScrollableTimelineF> {
  // Similar to a standard [ScrollController] but with the added convenience
  // mechanisms to read and go to item indices rather than a raw pixel scroll
  late ScrollController _scrollController;
  late int curItem; //TODO: why late? make it instead nullable
  late double curTime; //TODO: why late? make it instead nullable
  int nleftpaditems=3; //TODO number pad items should be parameters and/or related to widget width
  int nrightpaditems=3; //TODO number pad items should be parameters and/or related to widget width
  List<TimelineItemData> itemDatas = [];
  bool isDragging=false;
  StreamSubscription<double>? timeStreamSub;

  @override
  void initState() {
    super.initState();
    isDragging=false; //if isDragging then ignore stream updates about current playing time
    final divisions = (widget.lengthSecs / widget.stepSecs).ceil() + 1;
    var t = 0;
    for(var i=0; i<nleftpaditems; i++) {
      itemDatas.add(TimelineItemData(value: 0, valueMins: 0, valueSecs: 0, color: widget.backgroundColor, fontSize: 14));
    }
    for (var i = 0; i <= divisions; i++) {
      final secs = t % 60;
      final mins = (t / 60).floor();
      itemDatas.add(TimelineItemData(value:t, valueMins: mins, valueSecs: secs, color: widget.passiveItemsTextColor, fontSize: 14.0));
      t += widget.stepSecs;
    }
    for(var i=0; i<nrightpaditems; i++) {
      itemDatas.add(TimelineItemData(value: 0, valueMins: 0, valueSecs: 0, color: widget.backgroundColor, fontSize: 14));
    }
    //TODO initial time value should be provided from outside
    setScrollController();
    //important: set timeStreamSub after setting up scrollController
    timeStreamSub = widget.timeStream?.listen((t) {
      if(isDragging) return; //ignore time update if dragging
      final clamped_t=t.clamp(0.0, widget.lengthSecs.toDouble());
      _scrollController.jumpTo(timeToScrollOffset(clamped_t));
    });
  }

  double timeToScrollOffset(double t) {
    double w = context.size?.width ?? 0.0;
    return t*widget.pixPerSecs - (w/2 - widget.itemExtent*(0.5+nleftpaditems));
  }
  double scrollOffsetToTime(double offset) {
    double w = context.size?.width ?? 0.0;
    return (offset + (w/2 - widget.itemExtent*(0.5+nleftpaditems)))/widget.pixPerSecs;
  }
  //scrolloffs=t*pixPerSecs
  @override
  void dispose() {
    super.dispose();
    timeStreamSub?.cancel();
  }

  void setScrollController() {
    //TODO don't use FixedExtentScrollController?
    _scrollController = ScrollController(initialScrollOffset: 0);
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
            //TODO currently this gives the wrong results
            // I need to add some empty items at the beginning and compensate for them
            //if this scroll is not user generated ignore the notification
            if(!isDragging) return false; //allow scroll notification to bubble up
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
              //TODO: if drag outside bounds clip back inside bounds
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
         //important: if padding is changed, then need to review scrollOffsetToTime() and
          padding: const EdgeInsets.all(0),
          height: widget.height,
          alignment: Alignment.center,
          color: widget.backgroundColor,
          //see https://stackoverflow.com/questions/58863899/scroll-finishing-callback-in-flutter
          child: Stack(
            // use a stack here in order to show the (optional) cursor on top of the scrollview
            children: <Widget>[
               ListView(
                  scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    // the size in pixel of each item in the scale
                    itemExtent: widget.itemExtent.toDouble(),
                    children: itemDatas.map((TimelineItemData curValue) {
                      return TimelineItemF(curValue, widget.backgroundColor);
                    }).toList()),
              Visibility(
                // visibility modifier to make the cursor optional
                visible: widget.showCursor,
                child: Container(
                  alignment: Alignment.center,
                  //put it at the center
                  padding: const EdgeInsets.all(5),
                  // this padding define how close to top and bottom border the cursor get
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                            10), // this is the radius at the top and bottom of the indicator line: it is almost invisible
                      ),
                      color: widget.cursorColor.withOpacity(
                          0.3), //  make the indicator line semi-transparent
                    ),
                    width: 3, //  this is the width of the indicator line
                  ),
                ),
              )
            ],
          ));
  }
}
