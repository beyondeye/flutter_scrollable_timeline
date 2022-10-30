import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'click_to_expand_message.dart';
import '../tickers/youtube_time_ticker.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


/// A Expandable [ScrollableTimeline] integrated with a [YoutubePlayerController]
/// that shows the current playing time.
/// And when dragged stops the video from playing and at the end of dragging
/// set the playing time to the selected time.
///
/// Arguments: [shownSecsMultiple]: which seconds multiples to show in the "seconds" timeline:
/// if 1, show all, if 5 show only multiples of 5, and so on
///
/// [timeFetchDelay]: time delay in seconds between reading of current playing time
///  of youtube video
class YouTubeScrollableTimeline extends StatefulWidget {
  final int shownSecsMultiples;
  final double timeFetchDelay;
  final double timeLineHeight;
  final double rulerInsidePadding;
  final double rulerOutsidePadding;
  final double rulerSize;

  YouTubeScrollableTimeline({
    this.shownSecsMultiples=1,
    this.timeFetchDelay=0.05,
    this.timeLineHeight=100,
    this.rulerInsidePadding=0,
    this.rulerOutsidePadding=0,
    this.rulerSize=8});
  @override
  _YouTubeScrollableTimelineState createState() => _YouTubeScrollableTimelineState();
}

class _YouTubeScrollableTimelineState extends State<YouTubeScrollableTimeline> {
  static const mainTimelineStepSecs=10;
  YoutubeTimeTicker? ytTicker;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ytTicker cannot be initialized in initState because it needs to read context.ytController that is not yet initialized
    ytTicker = YoutubeTimeTicker(
        yt: context.ytController, timeFetchDelay: widget.timeFetchDelay);
  }
  void _pauseVideo(double t) {
    ytTicker?.yt.pauseVideo();
  }

  void _updateSelectedTime(double t) {
    //print("*FLT* drag detected for ScrollableTimelineF to target time $t");
    setState(() {
      ytTicker?.resetForcedCurTime();
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
          if(lengthSecs<2*mainTimelineStepSecs) lengthSecs=2*mainTimelineStepSecs; //to avoid exception when lenghtSecs<stepSecs
          return ScrollableTimelineSharedDragging(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
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
          ScrollableTimeline(
              lengthSecs: lengthSecs,
              stepSecs: mainTimelineStepSecs,
              height: widget.timeLineHeight,
              rulerOutsidePadding: widget.rulerOutsidePadding,
              rulerInsidePadding: widget.rulerInsidePadding,
              rulerSize: widget.rulerSize,
              timeStream: ytTicker?.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              onDragStart: _pauseVideo,
              onDragEnd: _updateSelectedTime),
        ]
    );
  }

  Widget _timelines2Widget(int lengthSecs) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimeline(
              lengthSecs: lengthSecs,
              stepSecs: mainTimelineStepSecs,
              height: widget.timeLineHeight,
              rulerOutsidePadding: widget.rulerOutsidePadding,
              rulerInsidePadding: widget.rulerInsidePadding,
              rulerSize: widget.rulerSize,
              timeStream: ytTicker?.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              enablePosUpdateWhileDragging: true,
              onDragStart: _pauseVideo,
              onDragUpdate: (t) {  ytTicker?.setForcedCurTime(t); }, //no setState needed here, because the updated time stream will already trigger rebuild
              onDragEnd: _updateSelectedTime,
          ),
          ScrollableTimeline(
              lengthSecs: lengthSecs,
              stepSecs: 1,
              shownSecsMultiples: widget.shownSecsMultiples,
              height: widget.timeLineHeight,
              rulerOutsidePadding: widget.rulerOutsidePadding,
              rulerInsidePadding: widget.rulerInsidePadding,
              rulerSize: widget.rulerSize,
              timeStream: ytTicker?.stream, ////ticker2.tick(ticks: 1000
              showCursor: true,
              showMinutes: false,
              backgroundColor: Colors.lightBlue.shade100,
              activeItemTextColor: Colors.blue.shade800,
              itemTextColor: Colors.blue.shade300,
              enablePosUpdateWhileDragging: true,
              onDragStart: _pauseVideo,
              onDragUpdate: (t) {  ytTicker?.setForcedCurTime(t); }, //no setState needed here, because the updated time stream will already trigger rebuild
              onDragEnd: _updateSelectedTime,
          ),
        ]
    );
  }

}
