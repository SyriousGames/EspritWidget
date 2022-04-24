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

/// Dispatched when a particle dies and is about to be removed from the system.
/// As soon as the event has been handled the particle will be removed but at the
/// time of the event it still exists so its properties (e.g. its location) can be
/// read from it.
///
/// @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_DEAD
// [Event(name="particleDead", type="org.flintparticles.common.events.ParticleEvent")]

/// Dispatched when a particle is created and has just been added to the emitter.
///
/// @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_CREATED
// [Event(name="particleCreated", type="org.flintparticles.common.events.ParticleEvent")]

/// Dispatched when a pre-existing particle is added to the emitter.
///
/// @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_ADDED
// [Event(name="particleAdded", type="org.flintparticles.common.events.ParticleEvent")]

/// Dispatched when an emitter attempts to update the particles' state but it
/// contains no particles. This event will be dispatched every time the update
/// occurs and there are no particles in the emitter. The update does not occur
/// when the emitter has not yet been started, when the emitter is paused, and
/// after the emitter has been stopped, so the event will not be dispatched
/// at these times.
///
/// <p>See the firework example for an example that uses this event.</p>
///
/// @see start();
/// @see pause();
/// @see stop();
///
/// @eventType org.flintparticles.common.events.EmitterEvent.EMITTER_EMPTY
// [Event(name="emitterEmpty", type="org.flintparticles.common.events.EmitterEvent")]

/// Dispatched when the particle system has updated and the state of the particles
/// has changed.
///
/// @eventType org.flintparticles.common.events.EmitterEvent.EMITTER_UPDATED
// [Event(name="emitterUpdated", type="org.flintparticles.common.events.EmitterEvent")]

/// Dispatched when the counter for the particle system has finished its cycle and so
/// the system will not emit any more particles unless the counter is changed or restarted.
///
/// @eventType org.flintparticles.common.events.EmitterEvent.COUNTER_COMPLETE
// [Event(name="counterComplete", type="org.flintparticles.common.events.EmitterEvent")]

// Caches lists used for drawing particles:
// Since we're only calling drawRawAtlas once at any one time, this are global
// and sized to the largest potential size.
const int _maxParticles = 20000;
final Float32List _rstTransforms = Float32List(_maxParticles * 4);
final Float32List _texRects = Float32List(_maxParticles * 4);
final Int32List _colors = Int32List(_maxParticles);

/// The emitter class contains the common behaviour used by these two concrete
/// classes.
///
/// <p>An Emitter manages the creation and ongoing state of particles. It uses
/// a number of utility classes to customise its behaviour.</p>
///
/// <p>An emitter uses Initializers to customise the initial state of particles
/// that it creates; their position, velocity, color etc. These are added to the
/// emitter using the addInitializer method.</p>
///
/// <p>An emitter uses Actions to customise the behaviour of particles that
/// it creates; to apply gravity, drag, fade etc. These are added to the emitter
/// using the addAction method.</p>
///
/// <p>An emitter uses Activities to alter its own behaviour, to move it or rotate
/// it for example.</p>
///
/// <p>An emitter uses a Counter to know when and how many particles to emit.</p>
///
/// <p>All timings in the emitter are based on actual time passed,
/// independent of the frame rate of the flash movie.</p>
///
/// <p>Most functionality is best added to an emitter using Actions,
/// Initializers, Activities and Counters. This offers greater
/// flexibility to combine behaviours without needing to subclass
/// the Emitter classes.</p>
///
/// An [Emitter] is a [Node] so it can be directly added to the node graph and be manipulated like any other [Node].
class Emitter extends Node {
  /// Default factory to manage the creation, reuse and destruction of particles
  static final _staticFactory = ParticleFactory();

  /// The [SpriteSheet] from which particles are retrieved.
  final SpriteSheet? spriteSheet;
  String? defaultParticleName;
  Paint particlePaint = Paint();

  /// Paint used for glow effects.
  Paint backgroundParticlePaint = Paint();
  BlendMode particleBlendMode = BlendMode.modulate;

  /// Set these values if you desire all of the particles to have a glow effect. The value is a standard deviation, or sigma, is the amount of
  /// glow in the X-axis. See https://drafts.fxtf.org/filter-effects/#feGaussianBlurElement .
  double? glowStdDevX;

  /// See [glowStdDevX], except this is for the Y axis.
  double? glowStdDevY;

  /// This is the particle factory used by the emitter to create and dispose
  /// of particles. Any custom
  /// particle factory should implement the ParticleFactory abstract class.
  ParticleFactory particleFactory = _staticFactory;
  bool _particlesAreEmitters = false;
  List<Initializer> _initializers = [];
  List<Action> _actions = [];
  List<Activity> _activities = [];
  List<Particle> _particles = [];
  Counter _counter = ZeroCounter();
  bool _counterCompleteDispatched = false;
  void Function(Emitter)? onCounterComplete;

  bool _running = false;
  bool _started = false;
  bool _updating = false;

  /// Used to alternate the direction in which the particles in the particles
  /// array are processed, to iron out errors from always processing them in
  /// the same order.
  bool _processLastFirst = false;

  /// Identifies whether the particles should be arranged
  /// into spatially sorted arrays - this speeds up proximity
  /// testing for those actions that need it.
  bool spaceSort = false;

  void Function(Emitter)? onEmitterDone;

  /// Called before particle is disposed. If true is returned, particle disposal is completed, otherwise it is aborted.
  bool Function(Emitter, Particle)? onParticleDisposal;

  /// Creates an emitter which emits particles derived from [spriteSheet]. If [defaultParticleName]
  /// is specified, it will be used as the default particle image and an explicit initializer is not required.
  /// When creating the packed sprite sheet, trimming of the textures is acceptable, but do not allow them to be rotated
  /// because this can result in rounding errors (observed if Free Texture Packer). Also, scaling of the textures is
  /// not currently supported.
  Emitter(this.spriteSheet, {this.defaultParticleName});

  /// Creates an emitter which emits particles which themselves are [Emitter]s. You must supply an [Initializer]
  /// which initializes the particle's [subEmitter] property.
  Emitter.ofEmitters()
      : this.spriteSheet = null,
        this._particlesAreEmitters = true;

  /// The array of all initializers being used by this emitter.
  List<Initializer> get initializers {
    return _initializers;
  }

  set initializers(List<Initializer> value) {
    Initializer initializer;
    for (initializer in _initializers) {
      initializer.removedFromEmitter(this);
    }
    _initializers = List.from(value);
    _initializers.sort(prioritySort);
    for (initializer in value) {
      initializer.addedToEmitter(this);
    }
  }

  /// Adds an Initializer object to the Emitter. Initializers set the
  /// initial state of particles created by the emitter.
  ///
  /// @param initializer The Initializer to add
  ///
  /// @see removeInitializer()
  /// @see org.flintParticles.common.initializers.Initializer.getDefaultPriority()
  void addInitializer(Initializer initializer) {
    int len = _initializers.length;
    int i = 0;
    for (; i < len; ++i) {
      if (_initializers[i].priority < initializer.priority) {
        break;
      }
    }
    _initializers.insert(i, initializer);
    initializer.addedToEmitter(this);
  }

  /// Removes an Initializer from the Emitter.
  ///
  /// @param initializer The Initializer to remove
  ///
  /// @see addInitializer()
  void removeInitializer(Initializer initializer) {
    if (_initializers.remove(initializer)) {
      initializer.removedFromEmitter(this);
    }
  }

  /// Detects if the emitter is using a particular initializer or not.
  ///
  /// @param initializer The initializer to look for.
  ///
  /// @return true if the initializer is being used by the emitter, false
  /// otherwise.
  bool hasInitializer(Initializer initializer) {
    return _initializers.indexOf(initializer) != -1;
  }

  /// Detects if the emitter is using an initializer of a particular class.
  ///
  /// @param initializerType The type of initializer to look for.
  ///
  /// @return true if the emitter is using an instance of the class as an
  /// initializer, false otherwise.
  bool hasInitializerOfType(Type initializerType) {
    return _initializers.indexWhere(
            (initializer) => initializer.runtimeType == initializerType) >=
        0;
  }

  /// The array of all actions being used by this emitter.
  List<Action> get actions {
    return _actions;
  }

  set actions(List<Action> value) {
    for (final action in _actions) {
      action.removedFromEmitter(this);
    }
    _actions = List.from(value);
    _actions.sort(prioritySort);
    for (final action in value) {
      action.addedToEmitter(this);
    }
  }

  /// Adds an Action to the Emitter. Actions set the behaviour of particles
  /// created by the emitter.
  ///
  /// @param action The Action to add
  ///
  /// @see removeAction();
  /// @see org.flintParticles.common.actions.Action.getDefaultPriority()
  void addAction(Action action) {
    int len = _actions.length;
    int i = 0;
    for (; i < len; ++i) {
      if (_actions[i].priority < action.priority) {
        break;
      }
    }
    _actions.insert(i, action);
    action.addedToEmitter(this);
  }

  /// Removes an Action from the Emitter.
  ///
  /// @param action The Action to remove
  ///
  /// @see addAction()
  void removeAction(Action action) {
    if (_actions.remove(action)) {
      action.removedFromEmitter(this);
    }
  }

  /// Detects if the emitter is using a particular action or not.
  ///
  /// @param action The action to look for.
  ///
  /// @return true if the action is being used by the emitter, false
  /// otherwise.
  bool hasAction(Action action) {
    return _actions.indexOf(action) != -1;
  }

  /// Detects if the emitter is using an action of a particular class.
  ///
  /// @param actionType The type of action to look for.
  ///
  /// @return true if the emitter is using an instance of the class as an
  /// action, false otherwise.
  bool hasActionOfType(Type actionType) {
    return _actions.indexWhere((action) => action.runtimeType == actionType) >=
        0;
  }

  /// The array of all actions being used by this emitter.
  List<Activity> get activities {
    return _activities;
  }

  set activities(List<Activity> value) {
    for (final activity in _activities) {
      activity.removedFromEmitter(this);
    }
    _activities = List.from(value);
    _activities.sort(prioritySort);
    for (final activity in _activities) {
      activity.addedToEmitter(this);
    }
  }

  /// Adds an Activity to the Emitter. Activities set the behaviour
  /// of the Emitter.
  ///
  /// @param activity The activity to add
  ///
  /// @see removeActivity()
  /// @see org.flintParticles.common.activities.Activity.getDefaultPriority()
  void addActivity(Activity activity) {
    int len = _activities.length;
    int i = 0;
    for (; i < len; ++i) {
      if (_activities[i].priority < activity.priority) {
        break;
      }
    }
    _activities.insert(i, activity);
    activity.addedToEmitter(this);
  }

  /// Removes an Activity from the Emitter.
  ///
  /// @param activity The Activity to remove
  ///
  /// @see addActivity()
  void removeActivity(Activity activity) {
    if (_activities.remove(activity)) {
      activity.removedFromEmitter(this);
    }
  }

  /// Detects if the emitter is using a particular activity or not.
  ///
  /// @param activity The activity to look for.
  ///
  /// @return true if the activity is being used by the emitter, false
  /// otherwise.
  bool hasActivity(Activity activity) {
    return _activities.indexOf(activity) != -1;
  }

  /// Detects if the emitter is using an activity of a particular class.
  ///
  /// @param activityType The type of activity to look for.
  ///
  /// @return true if the emitter is using an instance of the class as an
  /// activity, false otherwise.
  bool hasActivityOfType(Type activityType) {
    return _activities
            .indexWhere((activity) => activity.runtimeType == activityType) >=
        0;
  }

  /// The Counter for the Emitter. The counter defines when and
  /// with what frequency the emitter emits particles.
  Counter get counter {
    return _counter;
  }

  set counter(Counter value) {
    _counter = value;
    if (running != null || running == true) {
      _counter.startEmitter(this);
    }
  }

  /// Indicates if the emitter is currently running.
  bool get running {
    return _running;
  }

  /// Indicates if the emitter has been started and is not stopped.
  bool get started {
    return _started;
  }

  /// The collection of all particles being managed by this emitter.
  List<Particle> get particles {
    return _particles;
  }

  set particles(List<Particle> value) {
    killAllParticles();
    addParticles(value, false);
  }

  /// Used internally to create a particle.
  Particle createParticle() {
    Particle particle = particleFactory.createParticle();
    int len = _initializers.length;
    initParticle(particle);
    for (int i = 0; i < len; ++i) {
      _initializers[i].initialize(this, particle);
    }
    _particles.add(particle);
    return particle;
  }

  /// Emitters do their own particle initialization here - usually involves
  /// positioning and rotating the particle to match the position and rotation
  /// of the emitter. This method is called before any initializers that are
  /// assigned to the emitter, so initializers can override
  /// any properties set here.
  void initParticle(Particle particle) {
    particle.x = position.dx;
    particle.y = position.dy;
    particle.rotation = rotation;
    particle.scale = scale;
    particle.spriteTextureName = defaultParticleName;
  }

  /// Add a particle to the emitter. This enables users to create a
  /// particle externally to the emitter and then pass the particle to this
  /// emitter for management. Or remove a particle from one emitter and add
  /// it to another.
  ///
  /// @param particle The particle to add to this emitter
  /// @param applyInitializers Indicates whether to apply the emitter's
  /// initializer behaviours to the particle (or as true) not (false).
  ///
  /// @see #removeParticle()
  void addParticle(Particle particle, [bool applyInitializers = false]) {
    if (applyInitializers) {
      int len = _initializers.length;
      for (int i = 0; i < len; ++i) {
        _initializers[i].initialize(this, particle);
      }
    }
    _particles.add(particle);
  }

  /// Adds existing particles to the emitter. This enables users to create
  /// particles externally to the emitter and then pass the particles to the
  /// emitter for management. Or remove particles from one emitter and add
  /// them to another.
  ///
  /// @param particles The particles to add to this emitter
  /// @param applyInitializers Indicates whether to apply the emitter's
  /// initializer behaviours to the particle (or as true) not (false).
  ///
  /// @see #removeParticles()
  void addParticles(List<Particle> particles,
      [bool applyInitializers = false]) {
    int len = particles.length;
    int i;
    if (applyInitializers) {
      int len2 = _initializers.length;
      for (int j = 0; j < len2; ++j) {
        for (i = 0; i < len; ++i) {
          _initializers[j].initialize(this, particles[i]);
        }
      }
    }

    for (i = 0; i < len; ++i) {
      _particles.add(particles[i]);
    }
  }

  /// Remove a particle from this emitter. Particle is *not* disposed.
  ///
  /// @param particle The particle to remove.
  /// @return true if the particle was removed, false if it wasn't on this emitter in the first place.
  bool removeParticle(Particle particle) {
    int index = _particles.indexOf(particle);
    if (index != -1) {
      if (_updating) {
        // We're in the update() method right now. Schedule this to run again after we're done.
        scheduleMicrotask(() => removeParticle(particle));
      } else {
        _particles.remove(particle);
      }
      return true;
    }
    return false;
  }

  /// Remove a collection of particles from this emitter. Particles are *not* disposed.
  ///
  /// @param particles The particles to remove.
  void removeParticles(List<Particle> particles) {
    if (_updating) {
      // We're in the update() method right now. Schedule this to run again after we're done.
      scheduleMicrotask(() => removeParticles(particles));
    } else {
      _particles.removeWhere((particle) => particles.contains(particle));
    }
  }

  void _disposeParticle(Particle particle) {
    if (_particlesAreEmitters) {
      particle.subEmitter!.stop();
    }

    var dispose = true;
    if (onParticleDisposal != null) {
      dispose = onParticleDisposal!(this, particle);
    }

    if (dispose) {
      particleFactory.disposeParticle(particle);
    }
  }

  /// Kill all the particles on this emitter.
  void killAllParticles() {
    int len = _particles.length;
    for (int i = 0; i < len; ++i) {
      _disposeParticle(_particles[i]);
    }
    _particles.length = 0;
  }

  void notifyEmitterDone() {
    if (onEmitterDone != null) {
      onEmitterDone!(this);
    }
  }

  /// Starts the emitter. Until start is called, the emitter will not emit or
  /// update any particles.
  void start() {
    _started = true;
    _running = true;
    _counterCompleteDispatched = false;
    int len = _activities.length;
    for (int i = 0; i < len; ++i) {
      _activities[i].initialize(this);
    }
    len = _counter.startEmitter(this);
    for (int i = 0; i < len; ++i) {
      createParticle();
    }
  }

  /// Updates the emitter. If using the internal tick, this method
  /// will be called every frame without any action by the user. If not
  /// using the internal tick, the user should call this method on a regular
  /// basis to update the particle system.
  ///
  /// <p>The method asks the counter how many particles to create then creates
  /// those particles. Then it calls sortParticles, applies the activities to
  /// the emitter, applies the Actions to all the particles, removes all dead
  /// particles, and finally dispatches an emitterUpdated event which tells
  /// any renderers to redraw the particles.</p>
  ///
  /// @param time The duration, in seconds, to be applied in the update step.
  ///
  /// @see sortParticles();
  void update(double time) {
    if (!_running) {
      return;
    }

    _updating = true;
    int len = _counter.updateEmitter(this, time);
    for (int i = 0; i < len; ++i) {
      createParticle();
    }

    sortParticles();
    for (int i = 0; i < _activities.length; ++i) {
      _activities[i].update(this, time);
    }

    if (_particles.length > 0) {
      // update particle state
      var particleIterable =
          _processLastFirst ? _particles.reversed : _particles;
      particleIterable.forEach((particle) {
        if (particle.subEmitter != null) {
          particle.subEmitter!.update(time);
        }

        _actions.forEach((action) {
          action.update(this, particle, time);
        });
      });

      _processLastFirst = !_processLastFirst;

      // remove dead particles
      _particles.removeWhere((particle) {
        final remove = particle.isDead;
        if (remove) {
          _disposeParticle(particle);
        }
        return remove;
      });
    } else {
      // Emitter is empty and counter is complete
      if (_counter.complete) {
        _running = false;
        _started = false;
        notifyEmitterDone();
      }
    }

    _updating = false;
    if (!_counterCompleteDispatched && counter.complete) {
      _counterCompleteDispatched = true;
      if (onCounterComplete != null) {
        onCounterComplete!(this);
      }
    }
  }

  /// Used to sort the particles as required.
  void sortParticles() {
    if (spaceSort) {
      _particles.sort((p1, p2) => p1.x.compareTo(p2.x));
      for (int i = 0; i < _particles.length; ++i) {
        _particles[i].sortID = i;
      }
    }
  }

  /// Pauses the emitter.
  void pause() {
    _running = false;
  }

  /// Resumes the emitter after a pause.
  void resume() {
    _running = true;
  }

  /// Stops the emitter, killing all current particles and returning them to the
  /// particle factory for reuse. [onEmitterDone] is notified.
  void stop() {
    _started = false;
    _running = false;
    killAllParticles();
    notifyEmitterDone();
  }

  /// Makes the emitter skip forwards a period of time with a single update.
  /// Used when you want the emitter to look like it's been running for a while.
  ///
  /// @param time The time, in seconds, to skip ahead.
  /// @param frameRate The frame rate for calculating the new positions. The
  /// emitter will calculate each frame over the time period to get the new state
  /// for the emitter and its particles. A higher frameRate will be more
  /// accurate but will take longer to calculate.
  void runAhead(double time, [double frameRate = 10]) {
    double step = 1 / frameRate;
    while (time > 0) {
      time -= step;
      update(step);
    }
  }

  int prioritySort(Behaviour b1, Behaviour b2) {
    return b1.priority - b2.priority;
  }

  void prePaint(Canvas canvas) {
    // Do not apply matrix transformations to the particles. They inherit the Emitters position, scale, and rotation
    // upon initialization, but after this they are independent.
  }

  void postPaint(Canvas canvas) {}

  @override
  void paint(Canvas canvas) {
    final numParticles = _particles.length;
    if (numParticles == 0) {
      return;
    }

    if (_particlesAreEmitters) {
      _paintSubEmitterParticles(canvas);
    } else {
      _paintSpriteSheetParticles(canvas);
    }
  }

  void _paintSpriteSheetParticles(Canvas canvas) {
    final numParticles =
        _particles.length > _maxParticles ? _maxParticles : _particles.length;

    // Draw new particles first so they are behind old particles
    const texUnrotate = -pi / 2.0;
    int particleIdx = 0;
    for (int i = numParticles - 1; i >= 0; --i, ++particleIdx) {
      Particle p = _particles[i];
      final SpriteTexture tex = spriteSheet![p.spriteTextureName!]!;
      assert(tex != null,
          'Sprite texture name ${p.spriteTextureName} is not defined in the Emitter\'s SpriteSheet');
      final floatBufferParticleIdx0 = particleIdx * 4;
      final floatBufferParticleIdx1 = floatBufferParticleIdx0 + 1;
      final floatBufferParticleIdx2 = floatBufferParticleIdx0 + 2;
      final floatBufferParticleIdx3 = floatBufferParticleIdx0 + 3;
      _texRects[floatBufferParticleIdx0] = tex.fixedFrame!.left;
      _texRects[floatBufferParticleIdx1] = tex.fixedFrame!.top;
      _texRects[floatBufferParticleIdx2] = tex.fixedFrame!.right;
      _texRects[floatBufferParticleIdx3] = tex.fixedFrame!.bottom;

      // In the AS3 Flint Particles, all particles are assumed to be drawn with an origin around the center, rotated
      // around the center, and scaled around the center.
      if (p.cachedRSTransform == null ||
          p.x != p.cachedX ||
          p.y != p.cachedY ||
          p.scale != p.cachedScale ||
          p.rotation != p.cachedRotation) {
        final matrix4 = v.Matrix4.identity()
          ..translate(p.x - tex.size.width / 2 + tex.spriteSourceSize.left,
              p.y - tex.size.height / 2 + tex.spriteSourceSize.top);
        if (p.scale != 1.0 || p.rotation != 0.0) {
          final halfTrimmedWidth = tex.fixedSpriteSourceSize!.width / 2;
          final halfTrimmedHeight = tex.fixedSpriteSourceSize!.height / 2;
          matrix4.translate(halfTrimmedWidth, halfTrimmedHeight);
          matrix4.scale(p.scale);
          final rotation =
              (tex.rotated ? texUnrotate : 0.0) + v.radians(p.rotation);
          matrix4.rotateZ(rotation);
          matrix4.translate(-halfTrimmedWidth, -halfTrimmedHeight);
        }
        final tx = matrix4.storage[12];
        final ty = matrix4.storage[13];
        final ssin = matrix4.storage[1];
        final scos = matrix4.storage[5];

        p.cachedRSTransform = RSTransform(scos, ssin, tx, ty);
        p.cachedX = p.x;
        p.cachedY = p.y;
        p.cachedScale = p.scale;
        p.cachedRotation = p.rotation;
      }

      _rstTransforms[floatBufferParticleIdx0] = p.cachedRSTransform!.scos;
      _rstTransforms[floatBufferParticleIdx1] = p.cachedRSTransform!.ssin;
      _rstTransforms[floatBufferParticleIdx2] = p.cachedRSTransform!.tx;
      _rstTransforms[floatBufferParticleIdx3] = p.cachedRSTransform!.ty;

      _colors[particleIdx] = p.color.value;
    }

    final texRectsView =
        Float32List.sublistView(_texRects, 0, numParticles * 4);
    final rstTransformsView =
        Float32List.sublistView(_rstTransforms, 0, numParticles * 4);
    final colorsView = Int32List.sublistView(_colors, 0, numParticles);

    if (glowStdDevX != null &&
        glowStdDevX != 0 &&
        glowStdDevY != null &&
        glowStdDevY != 0) {
      backgroundParticlePaint.imageFilter =
          ImageFilter.blur(sigmaX: glowStdDevX!, sigmaY: glowStdDevY!);
      canvas.drawRawAtlas(spriteSheet!.image, rstTransformsView, texRectsView,
          colorsView, particleBlendMode, null, backgroundParticlePaint);
    }

    // Note that Skia doesn't use particlePaint.maskFilter when painting with this API.
    canvas.drawRawAtlas(spriteSheet!.image, rstTransformsView, texRectsView,
        colorsView, particleBlendMode, null, particlePaint);
  }

  void _paintSubEmitterParticles(Canvas canvas) {
    final numParticles = _particles.length;
    // Draw new particles first so they are behind old particles
    for (int i = numParticles - 1; i >= 0; --i) {
      Particle p = _particles[i];
      Emitter subEmitter = p.subEmitter!;
      if (p.x != p.cachedX || p.y != p.cachedY) {
        subEmitter.position = Offset(p.x, p.y);
        p.cachedX = p.x;
        p.cachedY = p.y;
      }

      if (p.scale != p.cachedScale) {
        subEmitter.scale = p.scale;
        p.cachedScale = p.scale;
      }

      if (p.rotation != p.cachedRotation) {
        subEmitter.rotation = p.rotation;
        p.cachedRotation = p.rotation;
      }

      subEmitter.paint(canvas);
    }
  }
}
