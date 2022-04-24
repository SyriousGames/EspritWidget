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

/// The Explosion action applies a force on the particles to push them away
/// from a single point - the center of the explosion. The force occurs
/// instantaneously at the central point of the explosion and then ripples
/// out in a shock wave.

class Explosion extends ActionBase implements Resetable, FrameUpdatable {
  static const double POWER_FACTOR = 100000;

  UpdateOnFrame? _updateActivity;

  /// The x coordinate of the center of the explosion.
  late double x;

  /// The y coordinate of the center of the explosion.
  late double y;
  late double _power;
  late double _depth;
  late double _invDepth;
  late double _epsilonSq;
  double _oldRadius = 0;
  double _radius = 0;
  double _radiusChange = 0;

  /// The rate at which the shockwave moves out from the
  /// explosion, in pixels per second.
  double expansionRate = 500;

  /// The constructor creates an Explosion action for use by an emitter.
  /// To add an Explosion to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param power The strength of the explosion - larger numbers produce a
  /// stronger force. (The scale of value has been altered from previous versions
  /// so small numbers now produce a visible effect.)
  /// @param x The x coordinate of the center of the explosion.
  /// @param y The y coordinate of the center of the explosion.
  /// @param expansionRate The rate at which the shockwave moves out from the
  /// explosion, in pixels per second.
  /// @param depth The depth (front-edge to back-edge) of the shock wave.
  /// @param epsilon The minimum distance for which the explosion force is
  /// calculated. Particles closer than this distance experience the explosion
  /// as if they were this distance away. This stops the explosion effect
  /// blowing up as distances get small.
  Explosion(
      [double power = 0,
      double x = 0,
      double y = 0,
      double expansionRate = 300,
      double depth = 10,
      double epsilon = 1]) {
    this.power = power;
    this.x = x;
    this.y = y;
    this.expansionRate = expansionRate;
    this.depth = depth;
    this.epsilon = epsilon;
  }

  /// The strength of the explosion - larger numbers produce a stronger force.
  double get power {
    return _power / POWER_FACTOR;
  }

  set power(double value) {
    _power = value * POWER_FACTOR;
  }

  /// The depth (front-edge to back-edge) of the shock wave.
  double get depth {
    return _depth * 2;
  }

  set depth(double value) {
    _depth = value * 0.5;
    _invDepth = 1 / _depth;
  }

  /// The minimum distance for which the explosion force is calculated.
  /// Particles closer than this distance to the center of the explosion
  /// experience the explosion as it they were this distance away. This
  /// stops the explosion effect blowing up as distances get small.
  double get epsilon {
    return sqrt(_epsilonSq);
  }

  set epsilon(double value) {
    _epsilonSq = value * value;
  }

  /// Adds an UpdateOnFrame activity to the emitter to call this objects
  /// frameUpdate method once per frame.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see frameUpdate()
  /// @see org.flintparticles.common.activities.UpdateOnFrame
  /// @see org.flintparticles.common.actions.Action#addedToEmitter()
  @override
  void addedToEmitter(Emitter emitter) {
    _updateActivity = UpdateOnFrame(this);
    emitter.addActivity(_updateActivity!);
  }

  /// Removes the UpdateOnFrame activity that was added to the emitter in the
  /// addedToEmitter method.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see addedToEmitter()
  /// @see org.flintparticles.common.activities.UpdateOnFrame
  /// @see org.flintparticles.common.actions.Action#removedFromEmitter()
  @override
  void removedFromEmitter(Emitter emitter) {
    if (_updateActivity != null) {
      emitter.removeActivity(_updateActivity!);
      _updateActivity = null;
    }
  }

  /// Resets the explosion to its initial state, so it can start again.
  void reset() {
    _radius = 0;
    _oldRadius = 0;
    _radiusChange = 0;
  }

  /// Called every frame before the particles are updated, this method
  /// calculates the current position of the blast shockwave.
  ///
  /// <p>This method is called using an UpdateOnFrame activity that is
  /// created in the addedToEmitter method.</p>
  ///
  /// @param emitter The emitter that is using this action.
  /// @param time The duration of the current animation frame.
  ///
  /// @see org.flintparticles.common.activities.UpdateOnFrame
  void frameUpdate(Emitter emitter, double time) {
    _oldRadius = _radius;
    _radiusChange = expansionRate * time;
    _radius += _radiusChange;
  }

  /// Calculates the effect of the blast and shockwave on the particle at this
  /// time.
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
    double dx = p.x - x;
    double dy = p.y - y;
    double dSq = dx * dx + dy * dy;
    if (dSq == 0) {
      dSq = 0.02;
      dx = 0.1;
      dy = 0.1;
//				return;
    }
    double d = sqrt(dSq);

    if (d < _oldRadius - _depth) {
      return;
    }
    if (d > _radius + _depth) {
      return;
    }

    double offset = d < _radius ? _depth - _radius + d : _depth - d + _radius;
    double oldOffset =
        d < _oldRadius ? _depth - _oldRadius + d : _depth - d + _oldRadius;
    offset *= _invDepth;
    oldOffset *= _invDepth;
    if (offset < 0) {
      time = time * (_radiusChange + offset) / _radiusChange;
      offset = 0;
    }
    if (oldOffset < 0) {
      time = time * (_radiusChange + oldOffset) / _radiusChange;
      oldOffset = 0;
    }

    double factor;
    if (d < _oldRadius || d > _radius) {
      factor =
          time * _power * (offset + oldOffset) / (_radius * 2 * d * p.mass);
    } else {
      double ratio = (1 - oldOffset) / _radiusChange;
      double f1 = ratio * time * _power * (oldOffset + 1);
      double f2 = (1 - ratio) * time * _power * (offset + 1);
      factor = (f1 + f2) / (_radius * 2 * d * p.mass);
    }
    p.velX += dx * factor;
    p.velY += dy * factor;
  }
}
