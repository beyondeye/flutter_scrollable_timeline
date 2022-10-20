import 'dart:async';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// a class to periodically fetch the current playing time from a YoutubePlayerController and
/// send the value to broadcast stream
class YoutubeTimeTicker {
  final YoutubePlayerController yt;
  final double timeFetchDelay;
  double curt;
  late Stream<double> stream;
  // see https://dart.dev/articles/libraries/creating-streams
  YoutubeTimeTicker({required this.yt, required this.timeFetchDelay}):curt=0 {
    final interval =Duration(microseconds: (timeFetchDelay*1000000).toInt());
    late StreamController<double> controller;
    Timer? timer;

    Future<void> tick(_) async {
      curt = await yt.currentTime;
      controller.add(curt); // Ask stream to send counter values as event.
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      timer?.cancel();
      timer = null;
    }

    controller = StreamController<double>.broadcast(
        onListen: startTimer,
        onCancel: stopTimer);

    stream= controller.stream;
  }

}
