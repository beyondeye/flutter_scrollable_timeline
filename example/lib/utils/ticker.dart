class Ticker {
  final double tmin;
  final double tmax;
  final double tstep;
  final int tickperiod;
  double curt;

  Ticker(this.tmin, this.tmax, {this.tstep = 1.0, this.tickperiod = 1})
      : curt = tmin;

  Stream<double> tick({required int ticks}) {
    return Stream.periodic(Duration(seconds: tickperiod), (idx) {
      curt += tstep;
      curt = curt.clamp(tmin, tmax);
      return curt;
    }).take(ticks);
  }
}
