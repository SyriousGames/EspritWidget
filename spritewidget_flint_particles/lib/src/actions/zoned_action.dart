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

/// The ZonedAction Action applies an action to the particle only if it is in
/// the specified zone.

class ZonedAction extends ActionBase {
  /// The action to apply when inside the zone.
  late Action action;

  /// The zone in which to apply the action.
  late Zone zone;

  /// If false (the default), the action is applied only to particles inside
  /// the zone. If true, the action is applied only to particles outside the zone.
  late bool invertZone;

  /// The constructor creates a ZonedAction action for use by an emitter.
  /// To add a ZonedAction to all particles created by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.emitters.Emitter#addAction()
  ///
  /// @param action The action to apply when inside the zone.
  /// @param zone The zone in which to apply the action.
  /// @param invertZone If false (the default) the action is applied only to
  /// particles inside the zone. If true the action is applied only to
  /// particles outside the zone.
  ZonedAction(Action action, Zone zone, [bool invertZone = false]) {
    this.action = action;
    this.zone = zone;
    this.invertZone = invertZone;
  }

  /// Provides acces to the priority of the action being used.
  ///
  /// @see org.flintparticles.common.actions.Action#getDefaultPriority()
  @override
  int get priority {
    return action.priority;
  }

  @override
  set priority(int value) {
    action.priority = value;
  }

  /// Calls the addedToEmitter method of the action being used.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see org.flintparticles.common.actions.Action#addedToEmitter()
  @override
  void addedToEmitter(Emitter emitter) {
    action.addedToEmitter(emitter);
  }

  /// Calls the removedFromEmitter method of the action being used.
  ///
  /// @param emitter The emitter this action has been added to.
  ///
  /// @see org.flintparticles.common.actions.Action#removedFromEmitter()
  @override
  void removedFromEmitter(Emitter emitter) {
    action.removedFromEmitter(emitter);
  }

  /// Checks if the particle is in the zone and if so calls the update
  /// method of the action being used.
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
        action.update(emitter, particle, time);
      }
    } else {
      if (invertZone) {
        action.update(emitter, particle, time);
      }
    }
  }
}
