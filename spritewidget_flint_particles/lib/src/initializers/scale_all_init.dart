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

/// The ScaleAllInit Initializer sets the size of the particles image
/// and adjusts its mass and collision radius accordingly.
///
/// <p>If you want to adjust only the image size use
/// the ScaleImageInit initializer.</p>
///
/// <p>This initializer has a priority of -10 to ensure it occurs after
/// mass and radius assignment classes like CollisionRadiusInit and MassInit.</p>
///
/// @see org.flintparticles.common.initializers.ScaleImageInit
class ScaleAllInit extends InitializerBase {
  /// The minimum scale value for particles initialised by
  /// this initializer. Should be between 0 and 1.
  double minScale;

  /// The maximum scale value for particles initialised by
  /// this initializer. Should be between 0 and 1.
  double? maxScale;

  /// The constructor creates a ScaleAllInit initializer for use by
  /// an emitter. To add a ScaleAllInit to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// <p>The scale factor of particles initialized by this class
  /// will be a random value between the minimum and maximum
  /// values set. If no maximum value is set, the minimum value
  /// is used with no variation.</p>
  ///
  /// @param minScale the minimum scale factor for particles
  /// initialized by the instance.
  /// @param maxScale the maximum scale factor for particles
  /// initialized by the instance.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addInitializer()
  ScaleAllInit(this.minScale, [this.maxScale]) {
    priority = -10;
    maxScale ??= minScale;
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    double scale;
    if (maxScale == null || maxScale == minScale) {
      scale = minScale;
    } else {
      scale = minScale + Random().nextDouble() * (maxScale! - minScale);
    }

    particle.scale = scale;
    particle.mass *= scale * scale;
    particle.collisionRadius *= scale;
  }
}
