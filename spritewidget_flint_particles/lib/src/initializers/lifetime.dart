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

/// The Lifetime Initializer sets a lifetime for the particle. It is
/// usually combined with the Age action to age the particle over its
/// lifetime and destroy the particle at the end of its lifetime.
class Lifetime extends InitializerBase {
  /// The maximum lifetime in seconds for particles.
  double? maxLifetime;

  /// The minimum lifetime in seconds for particles.
  double minLifetime;

  /// The constructor creates a Lifetime initializer for use by
  /// an emitter. To add a Lifetime to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// <p>The lifetime of particles initialized by this class
  /// will be a random value between the minimum and maximum
  /// values set. If no maximum value is set, the minimum value
  /// is used with no variation.</p>
  ///
  /// @param minLifetime the minimum lifetime in seconds.
  /// @param maxLifetime the maximum lifetime in seconds.
  ///
  /// @see Emitter.addInitializer.
  Lifetime([this.minLifetime = 0, this.maxLifetime]);

  /// @inheritDoc
  @override
  void initialize(Emitter emitter, Particle particle) {
    if (maxLifetime == null || minLifetime == maxLifetime) {
      particle.lifetime = minLifetime;
    } else {
      particle.lifetime =
          minLifetime + Random().nextDouble() * (maxLifetime! - minLifetime);
    }
  }
}
