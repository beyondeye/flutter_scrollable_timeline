import 'dart:math';

import 'package:flutter/material.dart';

import 'item_widget.dart';

enum InitialPosition { start, center, end }

class ScrollableTimeline extends StatefulWidget {
  final int lengthSecs;
  final int stepSecs;
  final double height;
  final Function(double) onChanged; //TODO: rename this method onDragEnd and add also method onDragStart
  final InitialPosition initialPosition;
  final Color backgroundColor;
  final bool showCursor;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final bool highlightedCurItem;
  final int itemExtent; //width in pix of each item
  final double pixPerSecs;

  ScrollableTimeline(
      {required this.lengthSecs,
      required this.stepSecs,
      required this.height,
      required this.onChanged,
      this.initialPosition = InitialPosition.center,
      this.backgroundColor = Colors.white,
      this.showCursor = true,
      this.cursorColor = Colors.red,
      this.activeItemTextColor = Colors.blue,
      this.passiveItemsTextColor = Colors.grey,
      this.highlightedCurItem = false,
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
  List<Map> valueMap = [];

  @override
  void initState() {
    super.initState();

    //*DARIO* the code in this method should be refactore and made more general for different kinds of horizontal pickers?
    final divisions = (widget.lengthSecs / widget.stepSecs).ceil() + 1;
    var t = 0;
    for (var i = 0; i <= divisions; i++) {
      final secs = t % 60;
      final mins = (t / 60).floor();
      valueMap.add({
        "value": t,
        "value_s": secs,
        "value_m": mins,
        "fontSize": 14.0,
        "color": widget.passiveItemsTextColor,
      });
      t += widget.stepSecs;
    }
    setScrollController();
  }

  void setScrollController() {
    int initialItem;
    switch (widget.initialPosition) {
      case InitialPosition.start:
        initialItem = 0;
        break;
      case InitialPosition.center:
        initialItem = (valueMap.length ~/ 2);
        break;
      case InitialPosition.end:
        initialItem = valueMap.length - 1;
        break;
    }

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          final tick=widget.pixPerSecs;
          if (scrollNotification is ScrollStartNotification) {
            print("*FLT* Scroll Start ${_scrollController.offset / tick}");
          } else if (scrollNotification is ScrollUpdateNotification) {
            print("*FLT* Scroll Update ${_scrollController.offset / tick}");
          } else if (scrollNotification is ScrollEndNotification) {
            print("*FLT*Scroll End ${_scrollController.offset / tick}");
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
                      itemExtent: 60,
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
                      onSelectedItemChanged: (item) {
                        curItem = item;
                        curTime = _scrollController.offset;
                        widget.onChanged((valueMap[item]["value"] as int).toDouble());
                      },
                      children: valueMap.map((Map curValue) {
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
