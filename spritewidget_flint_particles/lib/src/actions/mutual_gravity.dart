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

/// The MutualGravity Action applies forces to attract each particle towards
/// the other particles. The force applied is inversely proportional to the
/// square of the distance between the particles, in accordance with Newton's
/// law of gravity. This simulates the effect of gravity over large distances
/// (as between planets, for example).
///
/// <p>This action has a priority of 10, so that it executes
/// before other actions.</p>
class MutualGravity extends ActionBase {
  late double _power;
  late double _maxDistance;
  late double _maxDistanceSq;
  late double _epsilonSq;
  double _gravityConst = 1000; // scale sthe power

  /// The constructor creates a MutualGravity action for use by an emitter.
  /// To add a MutualGravity to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param power The strength of the gravitational pull between the
  /// particles.
  /// @param maxDistance The maximum distance between particles for the
  /// gravitational effect to be calculated. You can sometimes speed up
  /// the calculation of this action by
  /// reducing the maxDistance since often only the closest other particles
  /// have a significant effect on the motion of a particle.
  /// @param epsilon The minimum distance for which gravity is calculated.
  /// Particles closer than this distance experience a gravity force as if
  /// they were this distance away. This stops the gravity effect blowing
  /// up as distances get small.
  MutualGravity(
      [double power = 0, double maxDistance = 0, double epsilon = 1]) {
    priority = 10;
    this.power = power;
    this.maxDistance = maxDistance;
    this.epsilon = epsilon;
  }

  /// The strength of the gravity force.
  double get power {
    return _power / _gravityConst;
  }

  set power(double value) {
    _power = value * _gravityConst;
  }

  /// The maximum distance between particles for the gravitational
  /// effect to be calculated. You can sometimes speed up the calculation
  /// of this action by reducing the
  /// maxDistance since often only the closest other particles have a
  /// significant effect on the motion of a particle.
  double get maxDistance {
    return _maxDistance;
  }

  set maxDistance(double value) {
    _maxDistance = value;
    _maxDistanceSq = value * value;
  }

  /// The minimum distance for which the gravity force is calculated.
  /// Particles closer than this distance experience the gravity as it they
  /// were this distance away. This stops the gravity effect blowing up as
  /// distances get very small.
  double get epsilon {
    return sqrt(_epsilonSq);
  }

  set epsilon(double value) {
    _epsilonSq = value * value;
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

  /// Checks all particles near the current particle and applies the
  /// gravity force between them.
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
    if (particle.mass == 0) {
      return;
    }
    Particle p = particle;
    List particles = emitter.particles;
    Particle other;
    int i;
    int len = particles.length;
    double factor;
    double distance;
    double distanceSq;
    double dx;
    double dy;
    for (i = p.sortID + 1; i < len; ++i) {
      other = particles[i];
      if (other.mass == 0) {
        continue;
      }
      if ((dx = other.x - p.x) > _maxDistance) break;
      dy = other.y - p.y;
      if (dy > _maxDistance || dy < -_maxDistance) continue;
      distanceSq = dy * dy + dx * dx;
      if (distanceSq <= _maxDistanceSq && distanceSq > 0) {
        distance = sqrt(distanceSq);
        if (distanceSq < _epsilonSq) {
          distanceSq = _epsilonSq;
        }
        factor = (_power * time) / (distanceSq * distance);
        p.velX += (dx *= factor) * other.mass;
        p.velY += (dy *= factor) * other.mass;
        other.velX -= dx * p.mass;
        other.velY -= dy * p.mass;
      }
    }
  }
}
