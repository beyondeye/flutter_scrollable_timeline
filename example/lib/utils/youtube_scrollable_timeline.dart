import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'click_to_expand_message.dart';
import 'youtube_time_ticker.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class YouTubeScrollableTimeline extends StatefulWidget {
  @override
  _YouTubeScrollableTimelineState createState() => _YouTubeScrollableTimelineState();
}

class _YouTubeScrollableTimelineState extends State<YouTubeScrollableTimeline> {
  YoutubeTimeTicker? ytTicker;
  static const double timeFetchDelay=0.1;
  static const double timeLineHeight=100;
  static const double rulerInsidePadding=0;
  static const double rulerOutsidePadding=0;
  static const double rulerSize=8;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //ytTicker cannot be initialized in initState because it need to read context.ytController that is not yet initialized
    ytTicker = YoutubeTimeTicker(
        yt: context.ytController, timeFetchDelay: timeFetchDelay);
  }
  void _pauseVideo(double t) {
    ytTicker?.yt.pauseVideo();
  }

  void _updateSelectedTime(double t) {
    //print("*FLT* drag detected for ScrollableTimelineF to target time $t");
    setState(() {
      ytTicker?.curt = t.roundToDouble();
    });
    _seekToNewTime(t);
  }
  Future<void> _seekToNewTime(double t) async {
    await context.ytController.seekTo(seconds: t, allowSeekAhead: true); //TODO do I need allowSeekAhead true?
    await context.ytController.playVideo();
  }
  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder( //update this widget when video duration updated
        buildWhen: (o,n) {
          return n.metaData.duration != o.metaData.duration;
        },
        builder: (context, value) {
          int lengthSecs = value.metaData.duration.inSeconds + 1;
          //print ("YouTubeScrollableTimeline lengthSecs $lengthSecs");
          if(lengthSecs<20) lengthSecs=20; //to avoid exception when lenghtSecs<stepSecs
          return ScrollableTimelineSharedDragging(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: ExpandablePanel(
                    header: clickToExpandMessage(),
                    collapsed: _timelines1Widget(lengthSecs),
                    expanded: _timelines2Widget(lengthSecs),
                  )
              )
          );
        });
  }


  Widget _timelines1Widget(int lengthSecs) {
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
              onDragStart: _pauseVideo,
              onDragEnd: _updateSelectedTime),
        ]
    );
  }

  Widget _timelines2Widget(int lengthSecs) {
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
              onDragStart: _pauseVideo,
              onDragEnd: _updateSelectedTime),
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
              onDragStart: _pauseVideo,
              onDragEnd: _updateSelectedTime),
        ]
    );
  }

}
