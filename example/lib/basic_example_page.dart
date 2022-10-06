import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';

class _Ticker {
  final double tmin;
  final double tmax;
  final double tstep;
  final int tickperiod;
  double curt;
  _Ticker(this.tmin,this.tmax,{this.tstep=1.0,this.tickperiod=1}):curt=tmin;
  Stream<double> tick({required int ticks}) {
    return Stream.periodic(Duration(seconds: tickperiod), (idx) {
      curt+=tstep;
      curt=curt.clamp(tmin, tmax);
      return curt;
    }).take(ticks);
  }
}
class BasicExamplePage extends StatefulWidget {
  @override
  _BasicExamplePageState createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<BasicExamplePage> {
  double? timeline1Value;
  double? timeline2Value;
  double? timeline3Value;
  final ticker= _Ticker(0.0, 100.0);
  final ticker2= _Ticker(0.0, 100.0);
  final ticker3= _Ticker(0.0, 100.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              ScrollableTimelineF(
                lengthSecs: 100,
                stepSecs: 10,
                height: 120,
                insideVertPadding: 10,
                timeStream: ticker2.tick(ticks: 1000),
                showCursor: true,
                backgroundColor: Colors.lightBlue.shade50,
                activeItemTextColor: Colors.blue.shade800,
                passiveItemsTextColor: Colors.blue.shade300,
                onDragEnd: (double t) {
                  print("*FLT* drag detected for ScrollableTimelineF to target time $t");
                  ticker2.curt = t.roundToDouble();
                  setState(() {
                    timeline2Value = t;
                  });
                }
              ),
              Text(timeline2Value.toString()),
              Divider(),
              ScrollableTimelineF(
                  lengthSecs: 100,
                  stepSecs: 2,
                  height: 120,
                  insideVertPadding: 10,
                  timeStream: ticker3.tick(ticks: 1000),
                  showCursor: true,
                  showMinutes: false,
                  backgroundColor: Colors.lightBlue.shade50,
                  activeItemTextColor: Colors.blue.shade800,
                  passiveItemsTextColor: Colors.blue.shade300,
                  onDragEnd: (double t) {
                    print("*FLT* drag detected for ScrollableTimelineF to target time $t");
                    ticker3.curt = t.roundToDouble();
                    setState(() {
                      timeline3Value = t;
                    });
                  }
              ),
              Text(timeline3Value.toString()),
              Divider(),


            ],
          ),
        ),
      ),
    );
  }
}
