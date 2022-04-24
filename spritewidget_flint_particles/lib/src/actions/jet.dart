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

/// The Jet Action applies an acceleration to particles only if they are in
/// the specified zone.

class Jet extends ActionBase {
  /// The x component of the acceleration to apply, in
  /// pixels per second per second.
  late double x;

  /// The y component of the acceleration to apply, in
  /// pixels per second per second.
  late double y;

  /// The zone in which to apply the acceleration.
  late Zone zone;

  /// If false (the default) the acceleration is applied
  /// only to particles inside the zone. If true the acceleration is applied
  /// only to particles outside the zone.
  late bool invertZone;

  /// The constructor creates a Jet action for use by an emitter.
  /// To add a Jet to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param x/accelerationX The x component of the acceleration to apply, in
  /// pixels per second per second.
  /// @param y/accelerationY The y component of the acceleration to apply, in
  /// pixels per second per second.
  /// @param zone The zone in which to apply the acceleration.
  /// @param invertZone If false (the default) the acceleration is applied
  /// only to particles inside the zone. If true the acceleration is applied
  /// only to particles outside the zone.
  Jet(this.x, this.y, this.zone, [this.invertZone = false]);

  /// Checks if the particle is inside the zone and, if so, applies the
  /// acceleration to the particle for the period of time indicated.
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
    if (zone.contains(p.x, p.y)) {
      if (!invertZone) {
        p.velX += x * time;
        p.velY += y * time;
      }
    } else {
      if (invertZone) {
        p.velX += x * time;
        p.velY += y * time;
      }
    }
  }
}
