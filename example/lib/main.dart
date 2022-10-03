import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollable Timeline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

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

class _MyHomePageState extends State<MyHomePage> {
  double? newValue;
  final ticker= _Ticker(0.0, 30.0);
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
                timeStream: ticker.tick(ticks: 60),
                onItemSelected: (value) {
                  setState(() {
                    newValue = value;
                  });
                },
              ),
              Divider(),
              ScrollableTimeline(
                lengthSecs: 300,
                stepSecs: 10,
                height: 120,
                showCursor: false,
                backgroundColor: Colors.lightBlue.shade50,
                activeItemTextColor: Colors.blue.shade800,
                passiveItemsTextColor: Colors.blue.shade300,
                onItemSelected: (value) {},
              ),
              Divider(),
              ScrollableTimeline(
                lengthSecs: 600,
                stepSecs: 5,
                height: 120,
                showCursor: false,
                backgroundColor: Colors.grey.shade900,
                activeItemTextColor: Colors.white,
                passiveItemsTextColor: Colors.amber,
                onItemSelected: (value) {

                },
              ),
              Text(newValue.toString())
            ],
          ),
        ),
      ),
    );
  }
}
