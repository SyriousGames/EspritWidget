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

/// The CollisionRadiusInit Initializer sets the collision radius of the particle.
/// During collisions the particle is treated as a circle, regardless of its actual
/// shape. This sets the size of that sphere or circle.
class CollisionRadiusInit extends InitializerBase {
  /// The collision radius for particles
  /// initialized by the instance.
  double radius;

  /// The constructor creates a CollisionRadiusInit initializer for use by
  /// an emitter. To add a CollisionRadiusInit to all particles created by an emitter, use the
  /// emitter's addInitializer method.
  ///
  /// @param radius The collision radius for particles
  /// initialized by the instance.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addInitializer()
  CollisionRadiusInit([this.radius = 1]);

  @override
  void initialize(Emitter emitter, Particle particle) {
    particle.collisionRadius = radius;
  }
}
