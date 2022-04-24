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

/// Sets the velocity of the particle. It is
/// usually combined with the Move action to move the particle
/// using this velocity.
///
/// <p>The initial velocity is defined using a zone from the
/// org.flintparticles.twoD.zones package. The use of zones enables diverse
/// ranges of velocities. For example, to use a specific velocity,
/// a Point zone can be used. To use a varied speed in a specific
/// direction, a LineZone zone can be used. For a fixed speed in
/// a varied direction, a Disc or DiscSector zone with identical
/// inner and outer radius can be used. A Disc or DiscSector with
/// different inner and outer radius produces a range of speeds
/// in a range of directions.</p>
class Velocity extends InitializerBase {
  /// The zone to use for creating the velocity.
  Zone zone;

  Velocity(this.zone);

  @override
  void initialize(Emitter emitter, Particle particle) {
    Point<double> loc = zone.getLocation();
    if (particle.rotation == 0) {
      particle.velX = loc.x;
      particle.velY = loc.y;
    } else {
      final rotRads = v.radians(particle.rotation);
      final sinp = sin(rotRads);
      final cosp = cos(rotRads);
      particle.velX = cosp * loc.x - sinp * loc.y;
      particle.velY = cosp * loc.y + sinp * loc.x;
    }
  }
}
