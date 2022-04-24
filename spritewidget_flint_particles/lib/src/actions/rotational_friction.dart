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

/// The RotationalFriction action applies friction to the particle's rotational
/// movement to slow it down when it's rotating. The frictional force is
/// constant, irrespective of how fast the particle is rotating. For forces
/// proportional to the particle's angular velocity, use one of the rotational
/// drag effects - RotationalLinearDrag and RotationalQuadraticDrag.
///
/// @see RotationalLinearDrag
/// @see RotationalQuadraticDrag

class RotationalFriction extends ActionBase {
  /// The amount of friction. A higher number produces a stronger frictional
  /// force.
  double friction;

  /// The constructor creates a RotationalFriction action for use by an emitter.
  /// To add a RotationalFriction to all particles created by an emitter,
  /// use the emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param friction The amount of friction. A higher number produces a stronger frictional force.
  RotationalFriction(this.friction);

  /// Calculates the effect of the friction on the particle over the
  /// period of time indicated and adjusts the particle's angular velocity
  /// accordingly.
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
    if (p.angVelocity == 0) {
      return;
    }
    double scale = 1 - (friction * time) / ((p.angVelocity) * p.inertia).abs();
    if (scale < 0) {
      p.angVelocity = 0;
    } else {
      p.angVelocity *= scale;
    }
  }
}
