import 'package:flutter/material.dart';

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:scrollable_timeline_example/utils/youtube_scrollable_timeline.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'widgets/meta_data_section.dart';
import 'widgets/play_pause_button_bar.dart';
import 'widgets/player_state_section.dart';
import 'widgets/volume_slider.dart';
///
class YoutubeExamplePage extends StatefulWidget {
  @override
  _YoutubeExamplePageState createState() => _YoutubeExamplePageState();
}

class _YoutubeExamplePageState extends State<YoutubeExamplePage> {
  late YoutubePlayerController _controller;
  static const showControls=false;
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
            'b_sQ9bMltGU', //introducing widget of the week
            'DCKaFaU4jdk', //equality in dart
            'wE7khGHVkYY', //how to create a stateless widget
            'AqCMFXEmf3w', //how to create a statefull widget
            'Zbm3hjPjQMk', //Inherited Widgets Explained
            'kn0EOS-ZiIc', //When to Use Keys
            'OTS-ap9_aXc', //Futures
            'd_m5csmrf7I', //Flutter state management
          ],
          listType: ListType.playlist,
          startSeconds: 0,
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
            title: const Text('YouTube Example'),
            actions: const [VideoPlaylistIconButton()],
          ),
          body: LayoutBuilder( //*DARIO* LayoutBuilder is used to obtain the parent size constainsts and decide further layouts depending on it!
            builder: (context, constraints) {
              //*DARIO* this is the flutter way to identify if we are running on web platform
              if (kIsWeb && constraints.maxWidth > 750) {
                return Column(
                  children: [
                    Expanded(
                      flex: 6,
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: player),
                        ...!showControls
                            ? []
                            : [
                                const Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: const Controls(),
                                  ),
                                )
                              ]
                      ],
                    )),
                    Expanded(flex: 3,child: YouTubeScrollableTimeline())
                  ],
                );
              }

              return ListView(
                children: [
                  player,
                  YouTubeScrollableTimeline(),
                  ...!showControls ? [] : [const Controls()],
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
//          _space,
//          SourceInputSection(),
          _space,
          PlayPauseButtonBar(),
          _space,
          const VolumeSlider(),
          _space,
//          const VideoPositionSeeker(),
//          _space,
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