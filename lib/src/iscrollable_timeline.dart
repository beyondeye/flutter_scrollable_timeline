import 'package:flutter/material.dart';

abstract class IScrollableTimeLine {
  abstract final int lengthSecs;
  abstract final int stepSecs;
  abstract final double height;
  abstract final double insideVertPadding;
  abstract final Color backgroundColor;
  abstract final bool showCursor;
  abstract final bool showMins;
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
