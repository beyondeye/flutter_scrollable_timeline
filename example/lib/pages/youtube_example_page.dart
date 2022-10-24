import 'package:flutter/material.dart';

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:scrollable_timeline_example/widgets/youtube_scrollable_timeline.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../widgets/ytcontrols/meta_data_section.dart';
import '../widgets/ytcontrols/play_pause_button_bar.dart';
import '../widgets/ytcontrols/player_state_section.dart';
import '../widgets/ytcontrols/volume_slider.dart';
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
        //show standard youtube control at the bottom of video window
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
      builder: (context, player) { //the player argument here is the widget containing the youtube player video area
        return Scaffold(
          appBar: AppBar(
            title: const Text('YouTube Example'),
          ),
          body: LayoutBuilder( // LayoutBuilder is used to obtain the parent size constraints and decide further layouts depending on it!
            builder: (context, constraints) {
              int shownSecsMultiples=2; //defalt value (mobile)
              //check if we are running in a browser on a desktop pc
              if (kIsWeb && constraints.maxWidth > 750) {
                shownSecsMultiples=5;
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
                                    child: const VideoExternalControls(),
                                  ),
                                )
                              ]
                      ],
                    )),
                    Expanded(flex: 3,child: YouTubeScrollableTimeline(shownSecsMultiples:shownSecsMultiples))
                  ],
                );
              }

              return ListView(
                children: [
                  player,
                  YouTubeScrollableTimeline(shownSecsMultiples:shownSecsMultiples),
                  ...!showControls ? [] : [const VideoExternalControls()],
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

/// this widget shows the youtube video controls
/// and video information outside the standard youtube embed window
class VideoExternalControls extends StatelessWidget {
  ///
  const VideoExternalControls();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetaDataSection(),
          _space,
          PlayPauseButtonBar(),
          _space,
          const VolumeSlider(),
          _space,
          PlayerStateSection(),

        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);
}