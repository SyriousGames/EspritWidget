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

/// The Blast counter causes the emitter to create a single burst of
/// particles when it starts and then emit no further particles.
/// It is used, for example, to simulate an explosion.
class Blast implements Counter {
  /// The number of particles to emit when the emitter starts.
  int _startCount;
  bool _done = false;

  /// The constructor creates a Blast counter for use by an emitter. To
  /// add a Blast counter to an emitter use the emitter's counter property.
  ///
  /// @param startCount The number of particles to emit
  /// when the emitter starts.
  Blast(this._startCount);

  /// Does nothing. Since the blast counter emits a single blast and then
  /// stops, stopping it changes nothing.
  void stop() {}

  /// Does nothing. Since the blast counter emits a single blast and then
  /// stops, stopping and resuming it changes nothing.
  void resume() {}

  /// Initializes the counter. Returns startCount to indicate that the emitter
  /// should emit that many particles when it starts.
  ///
  /// <p>This method is called within the emitter's start method
  /// and need not be called by the user.</p>
  ///
  /// @param emitter The emitter.
  /// @return the value of startCount.
  ///
  /// @see org.flintparticles.common.counters.Counter#startEmitter()
  int startEmitter(Emitter emitter) {
    _done = true;
    return _startCount;
  }

  /// Returns 0 to indicate that no particles should be emitted after the
  /// initial blast.
  ///
  /// <p>This method is called within the emitter's update loop and need not
  /// be called by the user.</p>
  ///
  /// @param emitter The emitter.
  /// @param time The time, in seconds, since the previous call to this method.
  /// @return 0
  ///
  /// @see org.flintparticles.common.counters.Counter#updateEmitter()
  int updateEmitter(Emitter emitter, double time) {
    return 0;
  }

  /// Indicates if the counter has emitted all its particles.
  bool get complete {
    return _done;
  }

  /// Indicates if the counter is currently emitting particles
  bool get running {
    return false;
  }
}
