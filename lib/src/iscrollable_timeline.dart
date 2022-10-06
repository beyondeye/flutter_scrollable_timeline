import 'package:flutter/material.dart';
import 'timeline_item_data.dart';

abstract class IScrollableTimeLine {
  abstract final int lengthSecs;
  abstract final int stepSecs;
  abstract final double height;
  abstract final double insideVertPadding;
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

Widget itemMinSecsLabels(String? secsText_,String? minsText_,TimelineItemData curItem) {
  final String secsText = secsText_?? curItem.tSecs.toString();
  final String? minsText = minsText_ ?? curItem.tMins?.toString();
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        "|", //this is the top alignment line
        style: TextStyle(fontSize: 8, color: curItem.color),
      ),
      ...((minsText == null)
          ? [] //nothing to the colum if minsText is null
          : [ //add minutes text if minsText not null
        const SizedBox(height: 5),
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
      const SizedBox(height: 5),
      Text(
        "|", // this is the bottom alignment line
        style: TextStyle(fontSize: 8, color: curItem.color),
      ),
    ],
  );
}