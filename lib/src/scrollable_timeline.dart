import 'dart:async';

import 'package:flutter/material.dart';

import 'item_widget.dart';


// see https://stackoverflow.com/questions/69960331/constant-constructor-and-function-in-dart
// anonymous function cannot be const in dart
void _stub(double t) {}

class ScrollableTimeline extends StatefulWidget {
  final int lengthSecs;
  final int stepSecs;
  final Stream<double>? timeStream;
  final Function(double) onItemSelected;
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

  ScrollableTimeline(
      {required this.lengthSecs,
      required this.stepSecs,
      this.timeStream,
      this.onItemSelected= _stub,
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
  _ScrollableTimelineState createState() => _ScrollableTimelineState();
}

class _ScrollableTimelineState extends State<ScrollableTimeline> {
  // *DARIO* Similar to a standard [ScrollController] but with the added convenience
  // mechanisms to read and go to item indices rather than a raw pixel scroll
  late FixedExtentScrollController _scrollController;
  late int curItem; //TODO: why late? make it instead nullable
  late double curTime; //TODO: why late? make it instead nullable
  List<ItemWidgetData> itemDatas = [];
  bool isDragging=false;
  StreamSubscription<double>? timeStreamSub;

  @override
  void initState() {
    super.initState();
    isDragging=false; //if isDragging then ignore stream updates about current playing time
    //*DARIO* the code in this method should be refactore and made more general for different kinds of horizontal pickers?
    final divisions = (widget.lengthSecs / widget.stepSecs).ceil() + 1;
    var t = 0;
    for (var i = 0; i <= divisions; i++) {
      final secs = t % 60;
      final mins = (t / 60).floor();
      itemDatas.add(ItemWidgetData(value:t, valueMins: mins, valueSecs: secs, color: widget.passiveItemsTextColor, fontSize: 14.0));
      t += widget.stepSecs;
    }
    //TODO initial time value should be provided from outside
    setScrollController();
    //important: set timeStreamSub after setting up scrollController
    timeStreamSub = widget.timeStream?.listen((t) {
      if(isDragging) return; //ignore time update if dragging
      //TODO check if t in the range of the scrollable timeline: if not then clip position to inside the allowed range
      _scrollController.jumpTo(t*widget.pixPerSecs);
    });
  }


  @override
  void dispose() {
    super.dispose();
    timeStreamSub?.cancel();
  }

  void setScrollController() {
    //TODO don't use FixedExtentScrollController?
    _scrollController = FixedExtentScrollController(initialItem: 0);
//    _scrollController.jumpTo(value);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          final tick=widget.pixPerSecs;
          if (scrollNotification is ScrollStartNotification) {
//            print("*FLT* Scroll Start ${_scrollController.offset / tick}");
            isDragging=true;
            this.widget.onDragStart(_scrollController.offset / tick);
//          } else if (scrollNotification is ScrollUpdateNotification) {
//            print("*FLT* Scroll Update ${_scrollController.offset / tick}");
          } else if (scrollNotification is ScrollEndNotification) {
//            print("*FLT*Scroll End ${_scrollController.offset / tick}");
            this.widget.onDragEnd(_scrollController.offset / tick);
            isDragging=false;
          }
          return true;
        },
        child: Container(
            padding: const EdgeInsets.all(8),
            height: widget.height,
            alignment: Alignment.center,
            color: widget.backgroundColor,
            //see https://stackoverflow.com/questions/58863899/scroll-finishing-callback-in-flutter
            child: Stack(
              //*DARIO* use a stack here in order to show the (optional) cursor on top of the scrollview
              children: <Widget>[
                RotatedBox(
                  //*DARIO* needed to make ListWheelScrollView horizontal
                  quarterTurns: 3,
                  child: ListWheelScrollView(
                      controller: _scrollController,
                      itemExtent: widget.itemExtent.toDouble(),
                      //the size in pixel of each item in the scale
                      useMagnifier: false,
                      //*DARIO* magnification of center item
                      magnification: 1.0,
                      //*DARIO* magnification of center item (not continuous)
                      squeeze: 1,
                      //*DARIO* squeeze factor for item size (itemExtent) to show more items
                      diameterRatio: 2,
                      //default is 2.0 (the smaller it is the smallest is the wheel diameter (more compression at border
                      perspective: 0.001,
                      //default is 0.003 (must be 0<p <0.01) (how farthest item in the circle are shown with reduced size
                      onSelectedItemChanged: (item) { //TODO: we actually don't need onSelectedItemChanged (we actually don't need ListWheelScrollView
                        curItem = item;
                        curTime = _scrollController.offset;
                        widget.onItemSelected((itemDatas[item].value).toDouble());
                      },
                      children: itemDatas.map((ItemWidgetData curValue) {
                        return ItemWidget(curValue, widget.backgroundColor);
                      }).toList()),
                ),
                Visibility(
                  //*DARIO* visibility modifier to make the cursor optional
                  visible: widget.showCursor,
                  child: Container(
                    alignment: Alignment.center,
                    //put it at the center
                    padding: const EdgeInsets.all(5),
                    //*DARIO* this padding define how close to top and bottom border the cursor get
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(
                              10), //*DARIO* this is the radius at the top and bottom of the cursor: it is almost invisible
                        ),
                        color: widget.cursorColor.withOpacity(
                            0.3), //*dario* make the cursor semi-transparent
                      ),
                      width: 3, //*DARIO* this is the width of the cursor
                    ),
                  ),
                )
              ],
            )));
  }
}
