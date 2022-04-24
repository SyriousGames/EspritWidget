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

/// The TweenToZone action adjusts the particle's position between two
/// locations as it ages. The start location is wherever the particle starts
/// from, depending on the emitter and the initializers. The end position is
/// a random point within the specified zone. The current position is relative
/// to the particle's energy,
/// which changes as the particle ages in accordance with the energy easing
/// function used. This action should be used in conjunction with the Age action.
class TweenToZone extends ActionBase implements Initializer {
  /// The zone for the particle's position when its energy is 0.
  Zone zone;

  /// The constructor creates a TweenToZone action for use by an emitter.
  /// To add a TweenToZone to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param zone The zone for the particle's position when its energy is 0.
  TweenToZone(this.zone) {
    priority = -10;
  }

  @override
  void addedToEmitter(Emitter emitter) {
    if (!emitter.hasInitializer(this)) {
      emitter.addInitializer(this);
    }
  }

  @override
  void removedFromEmitter(Emitter emitter) {
    emitter.removeInitializer(this);
  }

  void initialize(Emitter emitter, Particle particle) {
    final pt = zone.getLocation();
    _TweenToZoneData data =
        _TweenToZoneData(particle.x, particle.y, pt.x, pt.y);
    particle.dictionary[this] = data;
  }

  /// Calculates the current position of the particle based on it's energy.
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
    if (particle.dictionary[this] == null) {
      initialize(emitter, particle);
    }
    _TweenToZoneData data = particle.dictionary[this];
    particle.x = data.endX + data.diffX * particle.energy;
    particle.y = data.endY + data.diffY * particle.energy;
  }
}

class _TweenToZoneData {
  late double diffX;
  late double diffY;
  late double endX;
  late double endY;

  _TweenToZoneData(double startX, double startY, double endX, double endY) {
    this.diffX = startX - endX;
    this.diffY = startY - endY;
    this.endX = endX;
    this.endY = endY;
  }
}
