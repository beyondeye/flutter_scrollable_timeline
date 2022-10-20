import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'youtube_time_ticker.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//import 'package:youtube_player_iframe_example/video_list_page.dart';


class YouTubeScrollableTimeline extends StatefulWidget {
  YoutubePlayerController yt;
  YouTubeScrollableTimeline(this.yt);
  @override
  _YouTubeScrollableTimelineState createState() => _YouTubeScrollableTimelineState();
}

class _YouTubeScrollableTimelineState extends State<YouTubeScrollableTimeline> {
  YoutubeTimeTicker? ytTicker;
  Duration videoLen= Duration(seconds:60); //default duration
  static const double timeFetchDelay=0.1;
  static const double timeLineHeight=100;
  static const double rulerInsidePadding=0;
  static const double rulerOutsidePadding=0;
  static const double rulerSize=8;

  Widget timelines1Widget(int lengthSecs) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimelineF(
              lengthSecs: lengthSecs,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker?.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              passiveItemsTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
        ]
    );
  }

  Widget timelines2Widget(int lengthSecs) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimelineF(
              lengthSecs: lengthSecs,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker?.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              passiveItemsTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
          ScrollableTimelineF(
              lengthSecs: lengthSecs,
              stepSecs: 2,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker?.stream, ////ticker2.tick(ticks: 1000
              showCursor: true,
              showMinutes: false,
              backgroundColor: Colors.lightBlue.shade100,
              activeItemTextColor: Colors.blue.shade800,
              passiveItemsTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
        ]
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void updateSelectedTime(double t) {
    print("*FLT* drag detected for ScrollableTimelineF to target time $t");
    ytTicker?.curt = t.roundToDouble();
    setState(() {
      context.ytController.seekTo(seconds: t, allowSeekAhead: false); //TODO do I need allowSeekAhead true?
    });
  }
  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
        buildWhen: (o,n) {
          return n.metaData.duration != o.metaData.duration;
        },
        builder: (context, value) {
          ytTicker?.cancel();
          ytTicker = YoutubeTimeTicker(
              yt: context.ytController, timeFetchDelay: timeFetchDelay);
          int lengthSecs = value.metaData.duration.inSeconds + 1;
          return ScrollableTimelineSharedDragging(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: ExpandablePanel(
                    header: Text("click to expand"),
                    collapsed: timelines1Widget(lengthSecs),
                    expanded: timelines2Widget(lengthSecs),
                  )
              )
          );
        });
  }
}
