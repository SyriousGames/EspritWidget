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

/// The MinimumDistance action applies an acceleration to the particle to
/// maintain a minimum distance between it and its neighbours.
///
/// <p>This action has a priority of 10, so that it executes
/// before other actions.</p>
class MinimumDistance extends ActionBase {
  late double _min;

  /// The acceleration force applied to avoid the other particles.
  late double acceleration;
  late double _minSq;

  /// The constructor creates a MinimumDistance action for use by an emitter.
  /// To add a MinimumDistance to all particles created by an emitter, use
  /// the emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param minimum The minimum distance, in pixels, that this action
  /// maintains between particles.
  /// @param acceleration The acceleration force applied to avoid the
  /// other particles.
  MinimumDistance([double minimum = 0, double acceleration = 0]) {
    priority = 10;
    this.minimum = minimum;
    this.acceleration = acceleration;
  }

  /// The minimum distance, in pixels, that this action maintains between
  /// particles.
  double get minimum {
    return _min;
  }

  set minimum(double value) {
    _min = value;
    _minSq = value * value;
  }

  /// Instructs the emitter to produce a sorted particle array for optimizing
  /// the calculations in the update method of this action.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see org.flintparticles.common.actions.Action#addedToEmitter()
  @override
  void addedToEmitter(Emitter emitter) {
    emitter.spaceSort = true;
  }

  /// Checks for particles closer than the minimum distance to the current
  /// particle and if any are found applies the acceleration to move the
  /// particles apart.
  ///
  /// <p>This method is called by the emitter and need not be called by the
  /// user.</p>
  ///
  /// @param emitter The Emitter that created the particle.
  /// @param particle The particle to be updated.
  /// @param time The duration of the frame - used for time based updates.
  ///
  /// @see org.flintparticles.common.actions.Action#update()
  @override
  void update(Emitter emitter, Particle particle, double time) {
    Particle p = particle;
    List particles = emitter.particles;
    Particle other;
    int i;
    int len = particles.length;
    double distanceInv;
    double distanceSq;
    double dx;
    double dy;
    double moveX = 0;
    double moveY = 0;
    double factor;
    for (i = p.sortID - 1; i >= 0; --i) {
      other = particles[i];
      if ((dx = p.x - other.x) > _min) break;
      dy = p.y - other.y;
      if (dy > _min || dy < -_min) continue;
      distanceSq = dy * dy + dx * dx;
      if (distanceSq <= _minSq && distanceSq > 0) {
        distanceInv = 1 / sqrt(distanceSq);
        moveX += dx * distanceInv;
        moveY += dy * distanceInv;
      }
    }
    for (i = p.sortID + 1; i < len; ++i) {
      other = particles[i];
      if ((dx = p.x - other.x) < -_min) break;
      dy = p.y - other.y;
      if (dy > _min || dy < -_min) continue;
      distanceSq = dy * dy + dx * dx;
      if (distanceSq <= _minSq && distanceSq > 0) {
        distanceInv = 1 / sqrt(distanceSq);
        moveX += dx * distanceInv;
        moveY += dy * distanceInv;
      }
    }
    if (moveX != 0 || moveY != 0) {
      factor = time * acceleration / sqrt(moveX * moveX + moveY * moveY);
      p.velX += factor * moveX;
      p.velY += factor * moveY;
    }
  }
}
