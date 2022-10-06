import 'package:flutter/material.dart';
import 'iscrollable_timeline.dart';
import 'timeline_item_data.dart';
class TimelineItem extends StatefulWidget {
  final TimelineItemData curItem;
  // potentially independent bg color for each item
  final Color backgroundColor;
  final double insideVertPadding;

  const TimelineItem(
    this.curItem,
    this.backgroundColor,
    this.insideVertPadding,
  {
    Key? key,
  }) : super(key: key);

  @override
  _TimelineItemState createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
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
        padding:  EdgeInsets.symmetric(
          horizontal: widget.insideVertPadding, //this actual vertical padding, after rotation
          vertical: 1, //this actual horizontal padding after rotation
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: RotatedBox( // this is needed because we rotate ListWheelScrollView to make it horizontal
          quarterTurns: 1,
          child: itemMinSecsLabels(secsText,minsText, widget.curItem)
      ),
      ),
    );
  }
}
