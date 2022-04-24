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

/// The Rotation Initializer sets the rotation of the particle. The rotation is
/// relative to the rotation of the emitter.
class Rotation extends InitializerBase {
  /// The minimum angle in degrees for particles initialised by
  /// this initializer.
  double minAngle;

  /// The maximum angle in degrees for particles initialised by
  /// this initializer.
  double maxAngle;

  /// The constructor creates a Rotation initializer for use by
  /// an emitter. To add a Rotation to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// <p>The rotation of particles initialized by this class
  /// will be a random value between the minimum and maximum
  /// values set. If no maximum value is set, the minimum value
  /// is used with no variation.</p>
  ///
  /// @param minAngle The minimum angle, in degrees, for the particle's rotation.
  /// @param maxAngle The maximum angle, in degrees, for the particle's rotation.
  Rotation(this.minAngle, this.maxAngle);

  @override
  void initialize(Emitter emitter, Particle particle) {
    Particle p = particle;
    if (maxAngle == null) {
      p.rotation += minAngle;
    } else {
      p.rotation += minAngle + Random().nextDouble() * (maxAngle - minAngle);
    }
  }
}
