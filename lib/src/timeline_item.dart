import 'package:flutter/material.dart';

class TimelineItemData {
  int value;
  int valueMins;
  int valueSecs;
  Color color;
  double fontSize;
  TimelineItemData({required this.value, required this.valueMins, required this.valueSecs, required this.color, required this.fontSize});
}

class TimelineItem extends StatefulWidget {
  final TimelineItemData curItem;
  // potentially independent bg color for each item
  final Color backgroundColor;

  const TimelineItem(
    this.curItem,
    this.backgroundColor,
  {
    Key? key,
  }) : super(key: key);

  @override
  _TimelineItemState createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
  late String minsText, secsText;

  @override
  void initState() {
    super.initState();

    final curItem= widget.curItem;
    secsText = curItem.valueSecs.toString();
    minsText = curItem.valueMins.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: RotatedBox( // this is needed because we rotate ListWheelScrollView to make it horizontal
          quarterTurns: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "|", //this is the top alignment line
                style: TextStyle(fontSize: 8, color: widget.curItem.color),
              ),
              const SizedBox(height: 5),
              RichText( //this is the minutes text  label for this element
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: minsText,
                      style: TextStyle(
                          fontSize: widget.curItem.fontSize,
                          color: widget.curItem.color,
                          fontWeight: secsText == "0"
                              ? FontWeight.w800
                              : FontWeight.w400),
                    ),
                  ],
                ),
              ),
              RichText( // this is the seconds text  label for this element
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: secsText,
                      style: TextStyle(
                          fontSize: widget.curItem.fontSize,
                          color: widget.curItem.color),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "|", // this is the bottom alignment line
                style: TextStyle(fontSize: 8, color: widget.curItem.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
