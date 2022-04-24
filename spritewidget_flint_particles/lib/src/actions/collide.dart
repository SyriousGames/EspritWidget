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

/// The Collide action detects collisions between particles and modifies their
/// velocities in response to the collision. All particles are approximated to
/// a circular shape for the collisions and they are assumed to be of even
/// density.
///
/// <p>If the particles reach a stationary, or near stationary, state under an
/// accelerating force (e.g. gravity) then they will fall through each other.
/// This is due to the nature of the alogorithm used, which is designed for
/// speed of execution and sufficient accuracy when the particles are in motion,
/// not for absolute precision.</p>
///
/// <p>This action has a priority of -20, so that it executes
/// after other actions.</p>

class Collide extends ActionBase implements FrameUpdatable {
  /// The coefficient of restitution when the particles collide. A value of
  /// 1 gives a pure elastic collision, with no energy loss. A value
  /// between 0 and 1 causes the particles to loose enegy in the collision.
  /// A value greater than 1 causes the particles to gain energy in the collision.
  double bounce;
  late double _maxDistance;
  UpdateOnFrame? _updateActivity;
  // used to alternate the direction of parsing the collisions
  int _sign = 1;

  /// The constructor creates a Collide action for use by  an emitter.
  /// To add a Collide to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param bounce The coefficient of restitution when the particles collide.
  /// A value of 1 gives a pure elastic collision, with no energy loss. A
  /// value between 0 and 1 causes the particles to loose enegy in the
  /// collision. A value greater than 1 causes the particle to gain energy
  /// in the collision.
  Collide([this.bounce = 1]) {
    priority = -20;
    _maxDistance = 0;
  }

  /// Instructs the emitter to produce a sorted particle array for optimizing
  /// the calculations in the update method of this action and
  /// adds an UpdateOnFrame activity to the emitter to call this objects
  /// frameUpdate method once per frame.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see frameUpdate()
  /// @see org.flintparticles.common.activities.UpdateOnFrame
  /// @see org.flintparticles.common.actions.Action#addedToEmitter()
  @override
  void addedToEmitter(Emitter emitter) {
    emitter.spaceSort = true;
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
    }
  }

  /// Called every frame before the particles are updated, this method
  /// calculates the collision radius of the largest two particles, which
  /// aids in optimizing the collision calculations.
  ///
  /// <p>This method is called using an UpdateOnFrame activity that is
  /// created in the addedToEmitter method.</p>
  ///
  /// @param emitter The emitter that is using this action.
  /// @param time The duration of the current animation frame.
  ///
  /// @see org.flintparticles.common.activities.UpdateOnFrame
  void frameUpdate(Emitter emitter, double time) {
    List particles = emitter.particles;
    double max1 = 0;
    double max2 = 0;
    for (Particle p in particles as Iterable<Particle>) {
      if (p.collisionRadius > max1) {
        max2 = max1;
        max1 = p.collisionRadius;
      } else if (p.collisionRadius > max2) {
        max2 = p.collisionRadius;
      }
    }
    _maxDistance = max1 + max2;
    _sign = -_sign;
  }

  /// Causes the particle to check for collisions against all other particles.
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
    List particles = emitter.particles;
    Particle other;
    int i;
    int len = particles.length;
    double factor;
    double distanceSq;
    double collisionDist;
    double dx, dy;
    double n1, n2;
    double relN;
    double m1, m2;
    double f1, f2;
    for (i = particle.sortID + _sign; i < len && i >= 0; i += _sign) {
      other = particles[i];
      if ((dx = other.x - particle.x) * _sign > _maxDistance) break;
      collisionDist = other.collisionRadius + particle.collisionRadius;
      if (dx * _sign > collisionDist) continue;
      dy = other.y - particle.y;
      if (dy > collisionDist || dy < -collisionDist) continue;
      distanceSq = dy * dy + dx * dx;
      if (distanceSq <= collisionDist * collisionDist && distanceSq > 0) {
        factor = 1 / sqrt(distanceSq);
        dx *= factor;
        dy *= factor;
        n1 = dx * particle.velX + dy * particle.velY;
        n2 = dx * other.velX + dy * other.velY;
        relN = n1 - n2;
        if (relN > 0) // colliding, not separating
        {
          m1 = particle.mass;
          m2 = other.mass;
          factor = ((1 + bounce) * relN) / (m1 + m2);
          f1 = factor * m2;
          f2 = -factor * m1;
          particle.velX -= f1 * dx;
          particle.velY -= f1 * dy;
          other.velX -= f2 * dx;
          other.velY -= f2 * dy;
//          if (emitter.hasEventListener(ParticleEvent.PARTICLES_COLLISION)) {
//            ParticleEvent ev = new ParticleEvent(ParticleEvent.PARTICLES_COLLISION, p);
//            ev.otherObject = other;
//            emitter.dispatchEvent(ev);
//          }
        }
      }
    }
  }
}
