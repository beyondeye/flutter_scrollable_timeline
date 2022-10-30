import 'dart:async';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// a class to periodically fetch the current playing time from a YoutubePlayerController and
/// send the value to broadcast stream
/// see also https://dart.dev/articles/libraries/creating-streams
/// TODO look at implementation of YoutubePlayerController.getCurrentPositionStream
class YoutubeTimeTicker {
  final YoutubePlayerController yt;
  final double timeFetchDelay;
  double curt;
  bool _isCurTimeForced=false;
  late StreamController<double> _controller;
  late Stream<double> stream;
  Timer? _timer;

  Future<void> tick(_) async {
    if(_isCurTimeForced) return;
    try {
      curt = await yt.currentTime;
    } catch (e) {
      print("error reading current play time:$e");
    }
    //print("tick :$curt ");
    _controller.add(curt); // Ask stream to send counter values as event.
  }

  void _startTimer() {
    final interval = Duration(microseconds: (timeFetchDelay*1000000).toInt());
    _timer = Timer.periodic(interval, tick);
  }
  void setForcedCurTime(double t) {
    _isCurTimeForced=true;
    _controller.add(t);
  }
  void resetForcedCurTime() {
    _isCurTimeForced=false;
  }
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  YoutubeTimeTicker({required this.yt, required this.timeFetchDelay}):curt=0 {
    _controller = StreamController<double>.broadcast(
        onListen: _startTimer,
        onCancel: _stopTimer);
    stream= _controller.stream;
  }

  void cancel() {
    _stopTimer();
    _controller.close();
  }

}
