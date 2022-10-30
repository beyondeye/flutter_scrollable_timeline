import 'dart:async';

class BroadcastTicker {
  final double tmin;
  final double tmax;
  final double tstep;
  final int? ticks;
  double curt;
  bool _isCurTimeForced=false;
  late Stream<double> stream;
  late StreamController<double> _controller;
  // see https://dart.dev/articles/libraries/creating-streams
  BroadcastTicker(this.tmin, this.tmax, {this.tstep = 1.0, this.ticks=1000}):curt=tmin {
    final interval =Duration(microseconds: (tstep*1000000).toInt());

    Timer? timer;
    int counter = 0;

    void tick(_) {
      if(_isCurTimeForced) {
        return;
      }
        curt += tstep;
        curt = curt.clamp(tmin, tmax);
        _controller.add(curt); // Ask stream to send counter values as event.
        if (counter == ticks) {
          timer?.cancel();
          _controller.close(); // Ask stream to shut down and tell listeners.
        }
      }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      timer?.cancel();
      timer = null;
    }


    _controller = StreamController<double>.broadcast(
        onListen: startTimer,
//        onPause: stopTimer,
//        onResume: startTimer,
        onCancel: stopTimer);

    stream= _controller.stream;
  }
  void setForcedCurTime(double t) {
    _isCurTimeForced=true;
    curt=t;
    _controller.add(t);
  }
  void resetForcedCurTime() {
    _isCurTimeForced=false;
  }
}
