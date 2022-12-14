import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import '../widgets/click_to_expand_message.dart';
import '../tickers/broadcast_ticker.dart';

class ExpandableExamplePage extends StatefulWidget {
  @override
  _ExpandableExamplePageState createState() => _ExpandableExamplePageState();
}


class _ExpandableExamplePageState extends State<ExpandableExamplePage> {
  double? timelineValue;
  final broadcastticker = BroadcastTicker(0.0, 100.0);
  static const double timeLineHeight=100;
  static const double rulerInsidePadding=0;
  static const double rulerOutsidePadding=0;
  static const double rulerSize=8;

  Widget timelines1Widget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimeline(
              lengthSecs: 110,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: broadcastticker.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
          Divider(),
          Text(timelineValue.toString()),
        ]
    );
  }

  Widget timelines2Widget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimeline(
              lengthSecs: 100,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: broadcastticker.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              enablePosUpdateWhileDragging: true,
              onDragUpdate: (t) {  broadcastticker.setForcedCurTime(t); }, //no setState needed here, because the updated time stream will already trigger rebuild
              onDragEnd: updateSelectedTime),
          ScrollableTimeline(
              lengthSecs: 100,
              stepSecs: 2,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: broadcastticker.stream, ////ticker2.tick(ticks: 1000
              showCursor: true,
              showMinutes: false,
              backgroundColor: Colors.lightBlue.shade100,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              enablePosUpdateWhileDragging: true,
              onDragUpdate: (t) {  broadcastticker.setForcedCurTime(t); }, //no setState needed here, because the updated time stream will already trigger rebuild
              onDragEnd: updateSelectedTime),
          Divider(),
          Text(timelineValue.toString()),
        ]
    );
  }

  void updateSelectedTime(double t) {
    print(
        "*FLT* drag detected for ScrollableTimelineF to target time $t");
    broadcastticker.curt = t.roundToDouble();
    broadcastticker.resetForcedCurTime();
    setState(() {
      timelineValue = t;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ScrollableTimelineSharedDragging(
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: ExpandablePanel(
                      header: clickToExpandMessage(),
                      collapsed: timelines1Widget(),
                      expanded: timelines2Widget(),
                    )
                )
            )
        )
    );
  }
}
