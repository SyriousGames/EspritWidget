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

// TODO ??
/// The PerformanceAdjusted counter causes the emitter to emit particles
/// continuously at a steady rate. It then adjusts this rate downwards if
/// the frame rate is below a target frame rate, until it reaches an emission
/// rate at which the system can maintain the target frame rate.
//class PerformanceAdjusted implements Counter {
//  double _timeToNext;
//  double _rateMin;
//  double _rateMax; // TODO This isn't used
//  double _target;
//  double _rate;
//  List<int> _times;
//  double _timeToRateCheck;
//  bool _running;
//
//  /// The constructor creates a PerformanceAdjusted counter for use by an
//  /// emitter. To add a PerformanceAdjusted counter to an emitter use the
//  /// emitter's counter property.
//  ///
//  /// @param rateMin The minimum number of particles to emit per second.
//  /// The counter will never drop the rate below this value.
//  /// @param rateMax The maximum number of particles to emit per second.
//  /// The counter will start at this rate and adjust downwards if the frame
//  /// rate is below the target.
//  /// @param targetFrameRate The frame rate that the counter should aim for.
//  /// Always set this slightly below your actual frame rate since flash will
//  /// drop frames occasionally even when performance is fine. So, for example,
//  /// if your movie's frame rate is 30fps and you want to target this rate,
//  /// set the target rate to 26fps.
//  PerformanceAdjusted(
//      [double rateMin = 0, double rateMax = 0, double targetFrameRate = 24]) {
//    _running = false;
//    _rateMin = rateMin;
//    _rate = _rateMax = rateMax;
//    _target = targetFrameRate;
//    _times = List<int>();
//    _timeToRateCheck = 0;
//  }
//
//  /// The minimum number of particles to emit per second. The counter
//  /// will never drop the rate below this value.
//  double get rateMin {
//    return _rateMin;
//  }
//
//  void set rateMin(double value) {
//    _rateMin = value;
//    _timeToRateCheck = 0;
//  }
//
//  /// The maximum number of particles to emit per second. the counter
//  /// will start at this rate and adjust downwards if the frame rate is
//  /// below the target frame rate.
//  double get rateMax {
//    return _rateMax;
//  }
//
//  void set rateMax(double value) {
//    _rate = _rateMax = value;
//    _timeToRateCheck = 0;
//  }
//
//  /// The frame rate that the counter should aim for. Always set this
//  /// slightly below your actual frame rate since flash will drop frames
//  /// occasionally even when performance is fine. So, for example, if your
//  /// movie's frame rate is 30fps and you want to target this rate, set the
//  /// target rate to 26fps.
//  double get targetFrameRate {
//    return _target;
//  }
//
//  void set targetFrameRate(double value) {
//    _target = value;
//  }
//
//  /// Stops the emitter from emitting particles
//  void stop() {
//    _running = false;
//  }
//
//  /// Resumes the emitter after a stop
//  void resume() {
//    _running = true;
//  }
//
//  /// Initializes the counter. Returns 0 to indicate that the emitter should
//  /// emit no particles when it starts.
//  ///
//  /// <p>This method is called within the emitter's start method
//  /// and need not be called by the user.</p>
//  ///
//  /// @param emitter The emitter.
//  /// @return 0
//  ///
//  /// @see org.flintparticles.common.counters.Counter#startEmitter()
//  int startEmitter(Emitter emitter) {
//    _running = true;
//    newTimeToNext();
//    return 0;
//  }
//
//  void newTimeToNext() {
//    _timeToNext = 1 / _rate;
//  }
//
//  /// Uses the time and current rate to calculate how many particles the
//  /// emitter should emit now. Also monitors the frame rate and adjusts
//  /// the emission rate down if the frame rate drops below the target.
//  ///
//  /// <p>This method is called within the emitter's update loop and need not
//  /// be called by the user.</p>
//  ///
//  /// @param emitter The emitter.
//  /// @param time The time, in seconds, since the previous call to this method.
//  /// @return the number of particles the emitter should create.
//  ///
//  /// @see org.flintparticles.common.counters.Counter#updateEmitter()
//  int updateEmitter(Emitter emitter, double time) {
//    if (!_running) {
//      return 0;
//    }
//
//    if (_rate > _rateMin && (_timeToRateCheck -= time) <= 0) {
//      // adjust rate
//      double t;
//      // This is average the rate of 10 frames.
//      if (_times.add(t = /*getTimer()*/ (stage.juggler.elapsedTime * 1000)) >
//          9) {
//        double frameRate = (10000 / (t - _times.shift())).round();
//        if (frameRate < _target) {
//          _rate = ((_rate + _rateMin) * 0.5).floor();
//          _times.length = 0;
//
//          if (!(_timeToRateCheck =
//              Particle(emitter.particlesList[0]).lifetime)) {
//            _timeToRateCheck = 2;
//          }
//        }
//      }
//    }
//
//    double emitTime = time;
//    int count = 0;
//    emitTime -= _timeToNext;
//    while (emitTime >= 0) {
//      ++count;
//      newTimeToNext();
//      emitTime -= _timeToNext;
//    }
//    _timeToNext = -emitTime;
//
//    return count;
//  }
//
//  /// Indicates if the counter has emitted all its particles. For this counter
//  /// this will always be false.
//  bool get complete {
//    return false;
//  }
//
//  /// Indicates if the counter is currently emitting particles
//  bool get running {
//    return _running;
//  }
//}
