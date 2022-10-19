import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'utils/broadcast_ticker.dart';
import 'utils/ticker.dart';


class BasicExamplePage extends StatefulWidget {
  @override
  _BasicExamplePageState createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<BasicExamplePage> {
  double? timeline1Value;
  double? timeline2Value;
  double? timeline3Value;
  final ticker = Ticker(0.0, 100.0);
  final ticker2 = Ticker(0.0, 100.0);
  final broadcastticker = BroadcastTicker(0.0, 100.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ScrollableTimelineSharedDragging(
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          /* TODO ScrollableTimeline removed from sample because dragging stopped working
                          ScrollableTimeline(
                            lengthSecs: 30,
                            stepSecs: 5,
                            height: 120,
                            insideVertPadding: 10,
                            timeStream: ticker.tick(ticks: 1000),
                            onItemSelected: (value) {
                              setState(() {
                                timeline1Value = value;
                              });
                            },
                            onDragEnd: (double t) {
                              print("*FLT* drag detected to target time $t");
                              ticker.curt = t.roundToDouble();
                            },
                          ),
                          Text(timeline1Value.toString()),
                          Divider(),
                           */
                          ScrollableTimelineF(
                              lengthSecs: 100,
                              stepSecs: 10,
                              height: 120,
                              rulerOutsidePadding: 10,
                              timeStream: broadcastticker.stream, //ticker.tick(ticks: 1000
                              showCursor: true,
                              backgroundColor: Colors.lightBlue.shade50,
                              activeItemTextColor: Colors.blue.shade800,
                              passiveItemsTextColor: Colors.blue.shade300,
                              onDragEnd: (double t) {
                                print(
                                    "*FLT* drag detected for ScrollableTimelineF to target time $t");
                                broadcastticker.curt = t.roundToDouble();
                                setState(() {
                                  timeline2Value = t;
                                });
                              }),
                          Text(timeline2Value.toString()),
                          Divider(),
                          ScrollableTimelineF(
                              lengthSecs: 100,
                              stepSecs: 2,
                              height: 120,
                              rulerOutsidePadding: 10,
                              timeStream: broadcastticker.stream, ////ticker2.tick(ticks: 1000
                              showCursor: true,
                              showMinutes: false,
                              backgroundColor: Colors.lightBlue.shade50,
                              activeItemTextColor: Colors.blue.shade800,
                              passiveItemsTextColor: Colors.blue.shade300,
                              onDragEnd: (double t) {
                                print(
                                    "*FLT* drag detected for ScrollableTimelineF to target time $t");
                                broadcastticker.curt = t.roundToDouble();
                                setState(() {
                                  timeline3Value = t;
                                });
                              }),
                          Text(timeline3Value.toString()),
                          Divider(),
                        ]
                    )
                )
            )
        )
    );
  }
}
