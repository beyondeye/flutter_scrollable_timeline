import 'package:flutter/material.dart';
import 'iscrollable_timeline.dart';
import 'timeline_item_data.dart';

class TimelineItemF extends StatefulWidget {
  final TimelineItemData curItem;
  // potentially independent bg color for each item
  final Color backgroundColor;
  final double rulerOutsidePadding;
  final double rulerSize;
  final double rulerInsidePadding;

  const TimelineItemF(
    this.curItem,
    this.backgroundColor,
      this.rulerOutsidePadding,
      this.rulerSize,
      this.rulerInsidePadding,
      {Key? key}
      ) : super(key: key);

  @override
  _TimelineItemFState createState() => _TimelineItemFState();
}

class _TimelineItemFState extends State<TimelineItemF> {
  late String? minsText;
  late String secsText;

  @override
  void initState() {
    super.initState();

    final curItem= widget.curItem;
    secsText = curItem.tSecs.toString();
    minsText = curItem.tMins?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 1,
          vertical: widget.rulerOutsidePadding,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
          child: itemMinSecsLabels(secsText,minsText, widget.curItem,widget.rulerSize,widget.rulerInsidePadding)
      ),
    );
  }
}
