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

/// The Particle class is a set of  properties shared by all particles.
/// It is deliberately lightweight, with only one method. The Initializers
/// and Actions modify these properties directly. This means that the same
/// particles can be used in many different emitters, allowing Particle
/// objects to be reused.
///
/// Particles are usually created by the ParticleFactory class. This class
/// just simplifies the reuse of Particle objects which speeds up the
/// application.
class Particle {
  /// The scale of the particle ( 1 is normal size ).
  double scale = 1;

  /// The mass of the particle ( 1 is the default ).
  double mass = 1;

  /// The radius of the particle, for collision approximation
  double collisionRadius = 1;

  /// The name of the [SpriteTexture] which will be used to paint the particle. This must be derived from the same [SpriteSheet]
  /// defined by the [Emitter] which contains this particle.
  String? spriteTextureName;

  /// If this particle is itself an [Emitter], this is the emitter which acts as a particle. These emitters
  /// should have their position, scale, and rotation relative to the center, because that's how Particles expect to be
  /// rendered.
  Emitter? subEmitter;

  /// The color to apply to the particle.
  late Color color;

  /// The lifetime of the particle, in seconds.
  double lifetime = 0;

  /// The age of the particle, in seconds.
  double age = 0;

  /// The energy of the particle. 1 = full energy, 0 = no energy.
  double energy = 1;

  /// Whether the particle is dead and should be removed from the stage.
  bool isDead = false;

  /// The dictionary object enables actions and activities to add additional properties to the particle.
  /// Any object adding properties to the particle should use a reference to itself as the dictionary
  /// key, thus ensuring it doesn't clash with other object's properties. If multiple properties are
  /// needed, the dictionary value can be an object with a number of properties.
  Map get dictionary {
    if (_dictionary == null) {
      _dictionary = Map();
    }
    return _dictionary!;
  }

  Map? _dictionary;

  /// The x coordinate of the particle in pixels.
  double x = 0;

  /// The y coordinate of the particle in pixels.
  double y = 0;

  /// The x coordinate of the particle prior to the latest update.
  double previousX = 0;

  /// The y coordinate of the particle prior to the latest update.
  double previousY = 0;

  /// The x coordinate of the velocity of the particle in pixels per second.
  double velX = 0;

  /// The y coordinate of the velocity of the particle in pixels per second.
  double velY = 0;

  /// The rotation of the particle in degrees.
  double rotation = 0;

  /// The angular velocity of the particle in degrees per second.
  double angVelocity = 0;

  double? _previousMass;
  double? _previousRadius;
  double _inertia = 0;

  RSTransform? cachedRSTransform;
  double? cachedScale;
  double? cachedRotation;
  double? cachedX;
  double? cachedY;

  /// The moment of inertia of the particle about its center point
  double get inertia {
    if (mass != _previousMass || collisionRadius != _previousRadius) {
      _inertia = mass * collisionRadius * collisionRadius * 0.5;
      _previousMass = mass;
      _previousRadius = collisionRadius;
    }
    return _inertia;
  }

  /// The position in the emitter's horizontal spacial sorted array
  int sortID = -1;

  /// Creates a particle. Alternatively particles can be reused by using a [ParticleFactory] to create
  /// and manage them. Usually the emitter will create the particles and the user doesn't need
  /// to create them.
  Particle() {
    clear();
  }

  /// Sets the particle's properties to their default values.
  void clear() {
    scale = 1;
    mass = 1;
    collisionRadius = 1;
    lifetime = 0;
    age = 0;
    energy = 1;
    isDead = false;
    spriteTextureName = null;
    subEmitter = null;
    color = const Color.fromARGB(0xff, 0xff, 0xff, 0xff);
    _dictionary = null;
    x = 0;
    y = 0;
    previousX = 0;
    previousY = 0;
    velX = 0;
    velY = 0;
    rotation = 0;
    angVelocity = 0;
    sortID = -1;
  }

  void revive() {
    lifetime = 0;
    age = 0;
    energy = 1;
    isDead = false;
  }
}
