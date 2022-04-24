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

/// The RotateVelocity Initializer sets the angular velocity of the particle.
/// It is usually combined with the Rotate action to rotate the particle
/// using this angular velocity.

class RotateVelocity extends InitializerBase {
  /// The maximum angular velocity in degrees per second for particles initialised by
  /// this initializer.
  double maxAngVelocity;

  /// The minimum angular velocity in degrees per second for particles initialised by
  /// this initializer.
  double minAngVelocity;

  /// The constructor creates a RotateVelocity initializer for use by
  /// an emitter. To add a RotateVelocity to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// <p>The angularVelocity of particles initialized by this class
  /// will be a random value between the minimum and maximum
  /// values set. If no maximum value is set, the minimum value
  /// is used with no variation.</p>
  ///
  /// @param minAngVelocity The minimum angularVelocity, in degrees per second, for the particle's angularVelocity.
  /// @param maxAngVelocity The maximum angularVelocity, in degrees per second, for the particle's angularVelocity.
  RotateVelocity(this.minAngVelocity, this.maxAngVelocity);

  /// When reading, returns the average of minAngVelocity and maxAngVelocity.
  /// When writing this sets both maxAngVelocity and minAngVelocity to the
  /// same angular velocity value.
  double get angVelocity {
    return minAngVelocity == maxAngVelocity || maxAngVelocity == null
        ? minAngVelocity
        : (maxAngVelocity + minAngVelocity) / 2;
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    Particle p = particle;
    if (maxAngVelocity == null) {
      p.angVelocity = minAngVelocity;
    } else {
      p.angVelocity = minAngVelocity +
          Random().nextDouble() * (maxAngVelocity - minAngVelocity);
    }
  }
}
