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

/// The AntiGravity action applies a force to the particle to push it away from
/// a single point - the center of the effect. The force applied is inversely
/// proportional to the square of the distance from the particle to the point.
///
/// <p>This is the same as the GravityWell action with a negative force.</p>
///
/// @see org.flintparticles.twoD.actions.GravityWell

class AntiGravity extends GravityWell {
  /// The constructor creates an AntiGravity action for use by an emitter.
  /// To add an AntiGravity to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param power The strength of the force - larger numbers produce a
  /// stronger force.
  /// @param x The x coordinate of the point away from which the force pushes
  /// the particles.
  /// @param y The y coordinate of the point away from which the force pushes
  /// the particles.
  /// @param epsilon The minimum distance for which the anti-gravity force is
  /// calculated. Particles closer than this distance experience the
  /// anti-gravity as if they were this distance away. This stops the
  /// anti-gravity effect blowing up as distances get small.
  AntiGravity(
      [double power = 0, double x = 0, double y = 0, double epsilon = 1])
      : super(power, x, y, epsilon);

  /// The strength of the anti-gravity force - larger numbers produce a
  /// stronger force.
  @override
  double get power {
    return -super.power;
  }

  @override
  set power(double value) {
    super.power = -value;
  }
}
