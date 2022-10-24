import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'timeline_item_data.dart';

/// base class for [ScrollableTimeline] implementations
abstract class IScrollableTimeLine {
  abstract final int lengthSecs;
  abstract final int stepSecs;
  abstract final double height;
  abstract final double rulerOutsidePadding;
  abstract final double rulerSize;
  abstract final double rulerInsidePadding;
  abstract final Color backgroundColor;
  abstract final bool showCursor;
  abstract final bool showMinutes;
  abstract final Color cursorColor;
  abstract final Color activeItemTextColor;
  abstract final Color passiveItemsTextColor;
  abstract final int itemExtent; //width in pix of each item
  abstract final double pixPerSecs;
  abstract final Function(double) onDragStart;
  abstract final Function(double) onDragEnd;
}

/// the widget used for showing the current selected time in a scrollable timeline
Widget indicatorWidget(IScrollableTimeLine widget) =>
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
    );

/// a widget showing two lines of text, the upper with minutes and the lower with
/// seconds
/// IMPORTANT: [rulerSize] smaller than 8 will cause graphic glitches. don't use it
Widget itemMinSecsLabels(String? secsText_,String? minsText_,TimelineItemData curItem,
    double rulerSize, double rulerInsidePadding) {
  final String secsText = secsText_?? curItem.tSecs.toString();
  final String? minsText = minsText_ ?? curItem.tMins?.toString();
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        "|", //this is the top alignment line
        style: TextStyle(fontSize: rulerSize, color: curItem.color),
      ),
      SizedBox(height: rulerInsidePadding),
      ...((minsText == null)
          ? [] //nothing to the colum if minsText is null
          : [ //add minutes text if minsText not null
        RichText(
          //this is the minutes text  label for this element
          text: TextSpan(
            children: [
              TextSpan(
                text: minsText,
                style: TextStyle(
                    fontSize: curItem.fontSize,
                    color: curItem.color,
                    fontWeight: secsText == "0"
                        ? FontWeight.w800
                        : FontWeight.w400),
              ),
            ],
          ),
        ),
      ]),
      RichText( // this is the seconds text  label for this element
        text: TextSpan(
          children: [
            TextSpan(
              text: secsText,
              style: TextStyle(
                  fontSize: curItem.fontSize,
                  color: curItem.color),
            )
          ],
        ),
      ),
      SizedBox(height: rulerInsidePadding),
      Text(
        "|", // this is the bottom alignment line
        style: TextStyle(fontSize: rulerSize, color: curItem.color),
      ),
    ],
  );
}