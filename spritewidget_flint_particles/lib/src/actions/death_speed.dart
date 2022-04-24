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

/// The DeathSpeed action marks the particle as dead if it is travelling faster
/// than the specified speed. The behaviour can be switched to instead mark as
/// dead particles travelling slower than the specified speed.

class DeathSpeed extends ActionBase {
  late double _limit;
  late double _limitSq;

  /// Whether the speed is a minimum (or as true) maximum (speed as false).
  bool isMinimum;

  /// The constructor creates a DeathSpeed action for use by an emitter.
  /// To add a DeathSpeed to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param speed The speed limit for the action in pixels per second.
  /// @param isMinimum If true, particles travelling slower than the speed limit
  /// are killed, otherwise particles travelling faster than the speed limit are
  /// killed.
  DeathSpeed([double speed = double.infinity, this.isMinimum = false]) {
    this.limit = speed;
  }

  /// The speed limit beyond which the particle dies.
  double get limit {
    return _limit;
  }

  set limit(double value) {
    _limit = value;
    _limitSq = value * value;
  }

  /// Checks the particle's speed and marks it as dead if it is moving faster
  /// than the speed limit, if this is a mximum speed limit, or slower if
  /// this is a minimum speed limit.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    Particle p = particle;
    double speedSq = p.velX * p.velX + p.velY * p.velY;
    if ((isMinimum && speedSq < _limitSq) ||
        (!isMinimum && speedSq > _limitSq)) {
      p.isDead = true;
    }
  }
}
