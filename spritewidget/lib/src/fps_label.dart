import 'label.dart';

/// A label that displays the approximate frames per second.
class FpsLabel extends Label {
  final List<double> _frameDeltas = List.filled(60, 0.0);
  int _frameDeltasIdx = 0;

  FpsLabel() : super('fps') {
    _frameDeltas.fillRange(0, _frameDeltas.length, 1 / 60.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _frameDeltas[_frameDeltasIdx] = dt;
    ++_frameDeltasIdx;
    if (_frameDeltasIdx >= _frameDeltas.length) {
      _frameDeltasIdx = 0;
    }

    double tot = 0;
    final numDeltas = _frameDeltas.length;
    for (var i = 0; i < numDeltas; i++) {
      tot += _frameDeltas[i];
    }

    final avgDt = tot / numDeltas;
    final fps = avgDt != 0 ? 1 / avgDt : 0;
    text = 'fps: ${fps.toStringAsFixed(2)}';
  }
}
