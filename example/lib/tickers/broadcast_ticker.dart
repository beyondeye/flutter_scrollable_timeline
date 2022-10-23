import 'dart:async';

class BroadcastTicker {
  final double tmin;
  final double tmax;
  final double tstep;
  final int? ticks;
  double curt;
  late Stream<double> stream;
  // see https://dart.dev/articles/libraries/creating-streams
  BroadcastTicker(this.tmin, this.tmax, {this.tstep = 1.0, this.ticks=1000}):curt=tmin {
    final interval =Duration(microseconds: (tstep*1000000).toInt());
    late StreamController<double> controller;
    Timer? timer;
    int counter = 0;

    void tick(_) {
      curt += tstep;
      curt = curt.clamp(tmin, tmax);
      controller.add(curt); // Ask stream to send counter values as event.
      if (counter == ticks) {
        timer?.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
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
//        onPause: stopTimer,
//        onResume: startTimer,
        onCancel: stopTimer);

    stream= controller.stream;
  }

}
