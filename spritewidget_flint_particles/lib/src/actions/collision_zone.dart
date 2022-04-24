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

/// The CollisionZone action detects collisions between particles and a zone,
/// modifying the particles' velocities in response to the collision. All
/// particles are approximated to a circular shape for the collisions.
///
/// <p>This action has a priority of -30, so that it executes after most other
/// actions.</p>
class CollisionZone extends ActionBase {
  /// The coefficient of restitution when the particles collide. A value of
  /// 1 gives a pure elastic collision, with no energy loss. A value
  /// between 0 and 1 causes the particles to loose enegy in the collision.
  /// A value greater than 1 causes the particles to gain energy in the collision.
  double bounce;

  /// The zone that the particles should collide with.
  Zone zone;

  /// The constructor creates a CollisionZone action for use by  an emitter.
  /// To add a CollisionZone to all particles managed by an emitter, use the
  /// emitter's addAction method.
  ///
  /// @see org.flintparticles.common.emitters.Emitter#addAction()
  ///
  /// @param zone The zone that the particles should collide with.
  /// @param bounce The coefficient of restitution when the particles collide.
  /// A value of 1 gives a pure elastic collision, with no energy loss. A
  /// value between 0 and 1 causes the particles to loose energy in the
  /// collision. A value greater than 1 causes the particle to gain energy
  /// in the collision.
  CollisionZone(this.zone, [this.bounce = 1]) {
    priority = -30;
  }

  /// Checks for collisions between the particle and the zone.
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
    bool collide = zone.collideParticle(particle, bounce);
    // TODO Do something with collide?
//			if( collide && emitter.hasEventListener( ParticleEvent.ZONE_COLLISION ) )
//			{
//				ParticleEvent ev = new ParticleEvent( ParticleEvent.ZONE_COLLISION, particle );
//				ev.otherObject = zone;
//				emitter.dispatchEvent( ev );
//			}
  }
}