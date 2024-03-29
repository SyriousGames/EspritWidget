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

/// The RotationalQuadraticDrag action applies drag to the particle to slow it
/// down when it's rotating. The drag force is proportional to the square of the
/// angular velocity of the particle. For other types of rotational drag see the
/// RotationalLinerDrag and RotationalFriction actions.
///
/// @see RotationalFriction
/// @see RotationalLinearDrag

class RotationalQuadraticDrag extends ActionBase {
  /// The amount of drag. A higher number produces a stronger drag force.
  double drag;

  /// The constructor creates a RotationalQuadraticDrag action for use by
  /// an emitter. To add a RotationalQuadraticDrag to all particles created
  /// by an emitter, use the emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param drag The amount of drag. A higher number produces a stronger drag
  /// force.
  RotationalQuadraticDrag(this.drag);

  /// Calculates the rotational drag on the particle and applies it for the
  /// period of time indicated.
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
    double scale = 1 - drag * time * p.angVelocity / p.inertia;
    if (scale < 0) {
      p.angVelocity = 0;
    } else {
      p.angVelocity *= scale;
    }
  }
}
