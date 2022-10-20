import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_timeline/scrollable_timeline.dart';
import 'package:scrollable_timeline_example/utils/youtube_time_ticker.dart';
import 'utils/broadcast_ticker.dart';
import 'utils/ticker.dart';

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//import 'package:youtube_player_iframe_example/video_list_page.dart';

import 'widgets/meta_data_section.dart';
import 'widgets/play_pause_button_bar.dart';
import 'widgets/player_state_section.dart';
import 'widgets/source_input_section.dart';
import 'widgets/volume_slider.dart';

class YouTubeScrollableTimeline extends StatefulWidget {
  @override
  _YouTubeScrollableTimelineState createState() => _YouTubeScrollableTimelineState();
}


class _YouTubeScrollableTimelineState extends State<YouTubeScrollableTimeline> {
  late YoutubeTimeTicker ytTicker;
  static const double timeLineHeight=100;
  static const double rulerInsidePadding=0;
  static const double rulerOutsidePadding=0;
  static const double rulerSize=8;

  Widget timelines1Widget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimelineF(
              lengthSecs: 110,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              passiveItemsTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
        ]
    );
  }

  Widget timelines2Widget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScrollableTimelineF(
              lengthSecs: 100,
              stepSecs: 10,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker.stream, //ticker.tick(ticks: 1000
              showCursor: true,
              backgroundColor: Colors.lightBlue.shade50,
              activeItemTextColor: Colors.blue.shade800,
              passiveItemsTextColor: Colors.blue.shade300,
              onDragEnd: updateSelectedTime),
          ScrollableTimelineF(
              lengthSecs: 100,
              stepSecs: 2,
              height: timeLineHeight,
              rulerOutsidePadding: rulerOutsidePadding,
              rulerInsidePadding: rulerInsidePadding,
              rulerSize: rulerSize,
              timeStream: ytTicker.stream, ////ticker2.tick(ticks: 1000
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
    ytTicker = YoutubeTimeTicker(yt: context.ytController, timeFetchDelay: 0.1);
  }

  void updateSelectedTime(double t) {
    //TODO implement this
    /*
    print(
        "*FLT* drag detected for ScrollableTimelineF to target time $t");
    broadcastticker.curt = t.roundToDouble();
    setState(() {
      timelineValue = t;
    });    
     */
  }
  @override
  Widget build(BuildContext context) {
    return ScrollableTimelineSharedDragging(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: ExpandablePanel(
              header: Text("click to expand"),
              collapsed: timelines1Widget(),
              expanded: timelines2Widget(),
            )
        )
    );
  }
}

///
class YoutubeAppDemo extends StatefulWidget {
  @override
  _YoutubeAppDemoState createState() => _YoutubeAppDemoState();
}

class _YoutubeAppDemoState extends State<YoutubeAppDemo> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    )
      ..onInit = () {
        _controller.loadPlaylist(
          list: [
            'tcodrIK2P_I',
            'nPt8bK2gbaU',
            'K18cpp_-gP8',
            'iLnmTe5Q2Qw',
            '_WoCV4c6XOE',
            'KmzdUe0RSJo',
            '6jZDSSZZxjQ',
            'p2lYr3vM_1w',
            '7QUtEmBT_-w',
            '34_PXCzGw1M',
          ],
          listType: ListType.playlist,
          startSeconds: 136,
        );
      }
      ..onFullscreenChange = (isFullScreen) {
        log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      };
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) { //*DARIO* the player here is the widget containing the youtube player video area
        return Scaffold(
          appBar: AppBar(
            title: const Text('Youtube Player IFrame Demo'),
            actions: const [VideoPlaylistIconButton()],
          ),
          body: LayoutBuilder( //*DARIO* LayoutBuilder is used to obtain the parent size constainsts and decide further layouts depending on it!
            builder: (context, constraints) {
              //*DARIO* this is the flutter way to identify if we are running on web platform
              if (kIsWeb && constraints.maxWidth > 750) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          player,
                          const VideoPositionIndicator(),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Controls(),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  player,
                  const VideoPositionIndicator(),
                  const Controls(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

///
class Controls extends StatelessWidget {
  ///
  const Controls();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetaDataSection(),
          _space,
          SourceInputSection(),
          _space,
          PlayPauseButtonBar(),
          _space,
          const VolumeSlider(),
          _space,
          const VideoPositionSeeker(),
          _space,
          PlayerStateSection(),
        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);
}

///
class VideoPlaylistIconButton extends StatelessWidget {
  ///
  const VideoPlaylistIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;
    return IconButton(
      onPressed: () async {
        controller.pauseVideo();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Text("") /* const VideoListPage(), */
          ),
        );
        controller.playVideo();
      },
      icon: const Icon(Icons.playlist_play_sharp),
    );
  }
}

/// *DARIO* it reads the current playtime from getCurrentPositionStream
class VideoPositionIndicator extends StatelessWidget {
  ///
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;
    return StreamBuilder<Duration>(
      stream: controller.getCurrentPositionStream(), //*DARIO* a stream that is periodically updated with current playing time
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data?.inMilliseconds ?? 0;
        final duration = controller.metadata.duration.inMilliseconds;
        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration,
          minHeight: 1,
        );
      },
    );
  }
}

///
class VideoPositionSeeker extends StatelessWidget {
  ///
  const VideoPositionSeeker({super.key});

  @override
  Widget build(BuildContext context) {
    var value = 0.0;
    return Row(
      children: [
        const Text(
          'Seek',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: context.ytController.getCurrentPositionStream(),
            initialData: Duration.zero,
            builder: (context, snapshot) {
              final position = snapshot.data?.inSeconds ?? 0;
              final duration = context.ytController.metadata.duration.inSeconds;

              value = position == 0 || duration == 0 ? 0 : position / duration;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: value,
                    onChanged: (positionFraction) {
                      value = positionFraction;
                      setState(() {});

                      context.ytController.seekTo(
                        seconds: (value * duration).toDouble(),
                        allowSeekAhead: true,
                      );
                    },
                    min: 0,
                    max: 1,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}