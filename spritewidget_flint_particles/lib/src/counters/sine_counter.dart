/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

part of flint_particles;

/// The Sine counter causes the emitter to emit particles continuously
/// at a rate that varies according to a sine wave.
class SineCounter implements Counter {
  late int _emitted;
  late double _rateMin;
  late double _rateMax;
  late double _period;
  late bool _running;
  late double _timePassed;
  late double _factor;
  late double _scale;

  /// The constructor creates a SineCounter counter for use by an emitter. To
  /// add a SineCounter counter to an emitter use the emitter's counter property.
  ///
  /// @period The period of the sine wave used, in seconds.
  /// @param rateMax The number of particles emitted per second at the peak of
  /// the sine wave.
  /// @param rateMin The number of particles to emit per second at the bottom
  /// of the sine wave.
  ///
  /// @see org.flintparticles.common.emitter.Emitter.counter
  SineCounter([double period = 1, double rateMax = 0, double rateMin = 0]) {
    _running = false;
    _period = period;
    _rateMin = rateMin;
    _rateMax = rateMax;
    _factor = 2 * pi / period;
    _scale = 0.5 * (_rateMax - _rateMin);
  }

  /// Stops the emitter from emitting particles
  void stop() {
    _running = false;
  }

  /// Resumes the emitting of particles after a stop
  void resume() {
    _running = true;
    _emitted = 0;
  }

  /// The number of particles to emit per second at the bottom
  /// of the sine wave.
  double get rateMin {
    return _rateMin;
  }

  set rateMin(double value) {
    _rateMin = value;
    _scale = 0.5 * (_rateMax - _rateMin);
  }

  /// The number of particles emitted per second at the peak of
  /// the sine wave.
  double get rateMax {
    return _rateMax;
  }

  set rateMax(double value) {
    _rateMax = value;
    _scale = 0.5 * (_rateMax - _rateMin);
  }

  /// The period of the sine wave used, in seconds.
  double get period {
    return _period;
  }

  set period(double value) {
    _period = value;
    _factor = 2 * pi / _period;
  }

  /// Initializes the counter. Returns 0 to indicate that the emitter should
  /// emit no particles when it starts.
  ///
  /// <p>This method is called within the emitter's start method
  /// and need not be called by the user.</p>
  ///
  /// @param emitter The emitter.
  /// @return 0
  ///
  /// @see org.flintparticles.common.counters.Counter#startEmitter()
  int startEmitter(Emitter emitter) {
    _running = true;
    _timePassed = 0;
    _emitted = 0;
    return 0;
  }

  /// Uses the time, period, rateMin and rateMax to calculate how many
  /// particles the emitter should emit now.
  ///
  /// <p>This method is called within the emitter's update loop and need not
  /// be called by the user.</p>
  ///
  /// @param emitter The emitter.
  /// @param time The time, in seconds, since the previous call to this method.
  /// @return the number of particles the emitter should create.
  ///
  /// @see org.flintparticles.common.counters.Counter#updateEmitter()
  int updateEmitter(Emitter emitter, double time) {
    if (!_running) {
      return 0;
    }
    _timePassed += time;
    int count = (_rateMax * _timePassed +
            _scale * (1 - cos(_timePassed * _factor)) / _factor)
        .floor();
    int ret = count - _emitted;
    _emitted = count;
    return ret;
  }

  /// Indicates if the counter has emitted all its particles. For this counter
  /// this will always be false.
  bool get complete {
    return false;
  }

  /// Indicates if the counter is currently emitting particles
  bool get running {
    return _running;
  }
}
